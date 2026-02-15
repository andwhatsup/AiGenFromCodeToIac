# src/main.py
import logging
import os, json, asyncio, traceback
import re
from pathlib import Path
from pydantic import BaseModel
from typing import TypeVar, Callable, Awaitable
from agents import set_default_openai_key, trace
import shutil

# task agents
from task_agents.source_analyzer import SourceAnalyzerOutput, analyze_codebase
from task_agents.architecture_creator import ArchitectureCreatorOutput, create_architecture
from task_agents.aws_cloud_architecture_creator import (AWSCloudArchitectureCreatorOutput, create_aws_cloud_architecture,)
from task_agents.aws_terraform_engineer import AWSTerraformFilesOutput, create_aws_terraform
from task_agents.code_review_agent import code_review_agent, CodeReviewResult
from task_agents.aws_terraform_basis_engineer import AWSTerraformFilesOutput, create_aws_basis_terraform
# review
from review.eval_agent import EvaluationResult, EvaluationError 
# pretask + evaluation
from pretask.fetch_source import fetch_source
from pretask.remove_tf import snapshot_terraform, purge_terraform
from analysis.repo_analyzer import analyze_repo 
from evaluation.evaluation import evaluate_dir
from utils import record_progress
from evaluation.eval_workflow.replace_lambda import normalize_lambdas_from_gate

# ---- Config -----
KEY_FILE_PATH = "openai.key"
LOG_DIR = Path("log")
PROGRESS_FILE = LOG_DIR / "progress.jsonl"   # one JSON line per app_id run
DEFAULT_DB_PATH = Path(__file__).resolve().parent.joinpath("../../../14217386/TerraDS.sqlite")
DB_PATH = Path(os.getenv("DB_PATH", str(DEFAULT_DB_PATH))).resolve()
REPO_WORKDIR = Path(os.getenv("REPO_WORKDIR", str(Path(__file__).resolve().parent / "../workspace"))).resolve()
MODULE_PATH = os.getenv("MODULE_PATH")  # optional subdir inside repo
MAX_IAC_ITERS = int(os.getenv("MAX_IAC_ITERS", "5"))  # single pass for now
T = TypeVar("T", bound=BaseModel)



def load_completed_ids() -> set[int]:
    if not PROGRESS_FILE.exists():
        return set()
    done: set[int] = set()
    with PROGRESS_FILE.open("r", encoding="utf-8") as f:
        for line in f:
            try:
                item = json.loads(line)
                if item.get("status") == "ok":
                    done.add(int(item["app_id"]))
            except Exception:
                continue
    return done

def _cleanup_workspace(app_id: int) -> None:
    try:
        app_workspace = REPO_WORKDIR / str(app_id)
        shutil.rmtree(app_workspace, ignore_errors=True)
        record_progress(app_id, "eval_test_mode_workspace_deleted",
                        meta={"path": str(app_workspace)})
    except Exception as e:
        record_progress(app_id, "eval_test_mode_workspace_delete_failed",
                        meta={"path": str(REPO_WORKDIR / str(app_id)), "error": str(e)})
        
# ---- inputs -----
def get_app_ids() -> list[int]:
    """Read app IDs from app_id_XX.txt file"""
    p = Path("app_id_1.txt").resolve()
    if not p.exists():
        raise RuntimeError("app_id_1.txt file not found")
    ids: list[int] = []
    raw = p.read_text(encoding="utf-8")
    parts = re.split(r"[,\r\n]+", raw)
    for part in parts:
        s = part.strip()
        if not s or s.startswith("#"):
            continue
        ids.append(int(s))
    if not ids:
        raise RuntimeError("No IDs found in app_id_1.txt")
    print(f"Loaded {len(ids)} app ids from app_id_1.txt")
    return ids

# ---- caching helpers -----
def debug_out(model: BaseModel, name: str) -> None:
    filename = f"log/{name}.json"
    Path(filename).parent.mkdir(parents=True, exist_ok=True)
    with open(filename, "w", encoding="utf-8") as f:
        f.write(model.model_dump_json(indent=2))

async def load_or_run(
    model_class: type[T], name: str, agent_fn: Callable[..., Awaitable[T]], *args
) -> T:
    filename = f"log/{name}.json"
    if os.path.exists(filename):
        with open(filename, "r", encoding="utf-8") as f:
            return model_class.model_validate_json(f.read())
    result: T = await agent_fn(*args)
    debug_out(result, name)
    return result

async def evaluate_ai_terraform(tf_dir: str, output_dir: str, app_id: int,max_retries: int = MAX_IAC_ITERS,) -> tuple[bool, dict]:
    last_result: EvaluationResult | None = None
    
    # Convert string parameters to Path objects
    tf_dir = Path(tf_dir)
    output_dir = Path(output_dir)
    
    for i in range(max(1, max_retries)):
        attempt = i + 1
        ai_eval_result: EvaluationResult | None = None

        try:
            # Optional re-analysis of TF root to refresh gate/overrides
            try:
                _ = await analyze_repo(str(tf_dir))
            except Exception:
                pass
            attempt_dir = (output_dir / f"attempt_{attempt}").resolve()
            attempt_dir.mkdir(parents=True, exist_ok=True)
            ai_analysis_dir = attempt_dir
            ai_analysis_dir.mkdir(parents=True, exist_ok=True)

            has_deployable = await analyze_repo(str(tf_dir), ai_analysis_dir)
            gate = json.loads((ai_analysis_dir / "gate.json").read_text())
            
            # Include the entire gate.json in the progress meta so we have the full JSON in the description
            record_progress(app_id,"ai_source_analyzed",meta={"deployable": has_deployable, "gate": gate,"recommended_roots": gate.get("recommended_roots", []),"varfiles_created": gate.get("varfiles_created", {}),},)
            
            # 3: evaluate ai generated tf code
            # 3.1: check if lambda functions exist and replace with dummy
            normalize_lambdas_from_gate(str(tf_dir), gate)

            ai_res_repo = evaluate_dir(str(tf_dir), str(attempt_dir))
            ok_repo = bool(ai_res_repo.get("ok"))

            if ok_repo:
                # Keep return shape backwards-compatible
                return True, {"ok": True, "attempt": attempt, "report_dir": ai_res_repo}
                
            # 4: when eval_result.ok == False; fill up ai_eval_result
            else:
                # top-level: {'1067203': {'validation': ..., 'plan': ..., 'apply': ...}}
                error_details = ai_res_repo.get("error_details", {}) or {}
                # take the first (and probably only) variant's errors
                variant_errors = next(iter(error_details.values()), {}) if isinstance(error_details, dict) else {}
                message = (variant_errors.get("validation") or variant_errors.get("plan") or variant_errors.get("apply") or "Unknown error")
                
                ai_eval_result = EvaluationResult(ok=False, stage="VALIDATION",
                    errors=[ EvaluationError( code="VALIDATION_FAILED",  message=message,)],
                    attempt=attempt,
                    report_dir=str(attempt_dir),
                    eval_plan=ai_res_repo.get("plan", {}),
                )
            last_result = ai_eval_result
        
        # Catch any unexpected errors during function execution
        except Exception as e:
            error_message = str(e) if e else "Unknown error occurred"
            record_progress(app_id, "eval_ai_exception_msg", meta={"exception": error_message})
            last_result = None 
            return False, {}

        # 5: send output from eval to fix agent
        error_details = ai_res_repo.get("error_details", {}) or {}
        # pick first (and likely only) variant
        variant_errors = next(iter(error_details.values()), {}) if isinstance(error_details, dict) else {}
        record_progress(app_id, "ai_eval_result_errors", meta={"ai_eval_result_errors": ( variant_errors.get("validation") or variant_errors.get("plan") or variant_errors.get("apply"))}, )

        # 6: invoke code review agent to fix the tf code
        # build a reasonably rich context for the agent
        error_message = (
            variant_errors.get("validation")
            or variant_errors.get("plan")
            or variant_errors.get("apply")
            or "Unknown Terraform evaluation error"
        )

        error_context = {
            "app_id": app_id,
            "attempt": attempt,
            "error_message": error_message,
            "evaluation_result": ai_eval_result.model_dump(),
            "raw_eval": ai_res_repo,
        }

        review_result: CodeReviewResult = await code_review_agent.review_terraform(
            tf_dir=tf_dir,
            error_context=error_context,
        )

        record_progress(app_id,"ai_fix_completed",meta={"fixed": review_result.fixed,"changes_made": review_result.changes_made,},)

    # If we exit loop without success:
    return False, (last_result.raw if last_result else {})

# ---- pipeline -----
async def run_for_app(app_id: int) -> None:
    record_progress(app_id, "start")
    try:
        # 1: fetch repo from git
        repo_dir, repo_url = fetch_source(DB_PATH, app_id, REPO_WORKDIR, MODULE_PATH)
        record_progress(app_id, "source_resolved", meta={"repo_url": repo_url})
        
        # 2: analyze repo
        eval_log_dir = LOG_DIR / str(app_id) / "og_eval"
        has_deployable = await analyze_repo(repo_dir,eval_log_dir)
        gate = json.loads((eval_log_dir / "gate.json").read_text())
        
        # Include the entire gate.json in the progress meta so we have the full JSON in the description
        record_progress(app_id,"source_analyzed",meta={"deployable": has_deployable, "gate": gate,"recommended_roots": gate.get("recommended_roots", []),"varfiles_created": gate.get("varfiles_created", {}),},)
        
        # 3: evaluate downloaded repo
        roots = gate.get("recommended_roots") or []

        # 3.1: check if lambda functions exist and replace with dummy
        normalize_lambdas_from_gate(repo_dir, gate)

        res_repo = evaluate_dir(repo_dir, eval_log_dir)
        ok_repo = bool(res_repo.get("ok"))
        record_progress(app_id,"eval_repo_ok" if ok_repo else "eval_repo_fail",meta={"roots": roots, "artifacts": res_repo},)
        if not ok_repo:
            _cleanup_workspace(app_id)
            return # EXIT THE FUNCTION

        # # --- Only activate if you want to skip IaC generation for perfectly valid repos
        # if ok_repo:
        #     _cleanup_workspace(app_id)
        #     return # EXIT THE FUNCTION

        # # --------------------------------

        # 4: snapshot OG TF, then purge from workspace
        snapshot_terraform(repo_dir, app_id)
        record_progress(app_id, "og_snapshot_done")
        purge_terraform(repo_dir)
        record_progress(app_id, "workspace_tf_purged", meta={"repo_dir": str(repo_dir)})



        # --------------------------------
        # 4.5.1: generate IaC with AI Single-Agent
        with trace(f"IaC Simple Generator {app_id}"):
            tf_output = await create_aws_basis_terraform(
                codebase_path=str(repo_dir),
                app_id=app_id,
                # output_subdir="ai_basis_tf",  # optional override
            )
            record_progress(app_id, "iac_basis_generated", meta={"files_count": len(tf_output.files)})
            tf_out_dir = REPO_WORKDIR / str(app_id) / "ai_basis_tf"
        
        ## 4.5.2: evaluate generated IaC simple & fix with Code Review Agent if needed
        if tf_out_dir.exists():
            ok_ai, res_ai = await evaluate_ai_terraform(str(tf_out_dir), LOG_DIR / str(app_id) / "ai_basis_eval", app_id)
            record_progress(app_id,"eval_ai_basis_ok" if ok_ai else "eval_ai_basis_fail",meta={"attempt": res_ai.get("attempt"),"artifacts": res_ai})     
        else:
            record_progress(app_id, "eval_ai_basis_skipped")


        # 4.5.3: snapshot Basis TF, then purge from workspace
        src_dir = Path(REPO_WORKDIR) / str(app_id) / "ai_basis_tf"
        dest_dir = Path("out") / str(app_id) / "ai_tf_base"
        if src_dir.exists():
            # Remove destination if it exists to avoid errors
            if dest_dir.exists():
                shutil.rmtree(dest_dir)
            shutil.move(str(src_dir), str(dest_dir))
        # --------------------------------


        # 5: generate IaC with AI Multi-Agents
        with trace(f"IaC Generator {app_id}"):
            analysis = await load_or_run(
                SourceAnalyzerOutput, f"{app_id}/agent_log/code_analysis", analyze_codebase, str(repo_dir),
            )
            record_progress(app_id, "code_analyzed",meta={"analysis": str(analysis)})
            architecture = await load_or_run(
                ArchitectureCreatorOutput, f"{app_id}/agent_log/architecture", create_architecture, analysis
            )
            aws_cloud_architecture = await load_or_run(
                AWSCloudArchitectureCreatorOutput,
                f"{app_id}/agent_log/aws_cloud_architecture",
                create_aws_cloud_architecture,
                analysis,
                architecture,
            )
            _ = await load_or_run(
                AWSTerraformFilesOutput,f"{app_id}/agent_log/terraform_files",create_aws_terraform, analysis, architecture,aws_cloud_architecture,
                str(repo_dir),
                app_id,
            )
            record_progress(app_id, "iac_generated")
        tf_out_dir = Path(repo_dir)

        ## 6: evaluate generated IaC & fix with Code Review Agent if needed
        if tf_out_dir.exists():
            ok_ai, res_ai = await evaluate_ai_terraform(str(tf_out_dir), LOG_DIR / str(app_id) / "ai_eval", app_id)
            record_progress(app_id,"eval_ai_ok" if ok_ai else "eval_ai_fail",meta={"attempt": res_ai.get("attempt"),"artifacts": res_ai})     
        else:
            record_progress(app_id, "eval_ai_skipped")
        
    except asyncio.CancelledError:
        record_progress(app_id, "cancelled")
    except Exception as e:
        record_progress(app_id,"error", meta={"error": str(e), "traceback": traceback.format_exc()},)
    finally:
        pass



async def main() -> None:
    logger = logging.getLogger("openai.agents")
    logger.setLevel(logging.DEBUG)
    logger.addHandler(logging.StreamHandler())
    logger.addHandler(logging.FileHandler("openai.log", mode="w"))

    all_ids = get_app_ids()
    completed = load_completed_ids()
    pending = [i for i in all_ids if i not in completed]

    logger.info("Total IDs: %d | Completed: %d | Pending: %d", len(all_ids), len(completed), len(pending))

    for app_id in pending:
        # Create all required directories upfront
        for p in [
            Path("out") / str(app_id) / "ai_tf_base",
            Path("out") / str(app_id) / "og_tf",
            LOG_DIR / str(app_id) / "og_eval",
            LOG_DIR / str(app_id) / "ai_eval",
            LOG_DIR / str(app_id) / "agent_log",
            LOG_DIR / str(app_id) / "ai_basis_eval",
        ]:
            p.mkdir(parents=True, exist_ok=True)
        await run_for_app(app_id)

if __name__ == "__main__":
    try:
        with open(KEY_FILE_PATH, "r", encoding="utf-8") as f:
            api_key = f.read().strip()
            set_default_openai_key(api_key)
    except Exception as e:
        print(f"Failed to read OpenAI API key: {e}")
        raise SystemExit(1)
    asyncio.run(main())
