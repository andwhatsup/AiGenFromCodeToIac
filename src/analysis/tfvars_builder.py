# analysis/tfvars_builder.py
from __future__ import annotations

import json
import os
import re
from pathlib import Path
from typing import Dict, List, Optional, Tuple, Any

# Public API:
# - load_existing_var_values(tf_root) -> dict
# - build_missing_vars(required_meta, existing_values, *, app_hint=None) -> dict
# - generate_tfvars_file(tf_root, required_meta, *, app_hint=None, force=False) -> Tuple[Optional[Path], Dict[str, Any], bool]

# required_meta shape (from terraform_scanner.extract_required_variables):
# { var_name: {"type": str|None, "has_default": bool, "default": str|None, "decl_file": str}, ... }


# ----------------------- Public API -----------------------

def load_existing_var_values(tf_root: Path) -> Dict[str, Any]:
    """
    Merge values from all tfvars in the root following Terraform naming habits.
    Supports:
      - terraform.tfvars{.json}
      - *.auto.tfvars{.json}
      - *.tfvars{.json}
    Parses JSON exactly, and .tfvars via a conservative HCL-ish regex for simple scalars.
    Last file wins on key collisions in the scan order below.
    """
    tf_root = Path(tf_root).resolve()
    patterns = [
        "terraform.tfvars.json",
        "terraform.tfvars",
        "*.auto.tfvars.json",
        "*.auto.tfvars",
        "*.tfvars.json",
        "*.tfvars",
    ]
    merged: Dict[str, Any] = {}
    for pat in patterns:
        for p in sorted(tf_root.glob(pat)):
            try:
                vals = _parse_varfile(p)
                if vals:
                    merged.update(vals)
            except Exception:
                # ignore unreadable or unparsable files
                continue
    return merged


def build_missing_vars(
    required_meta: Dict[str, Dict[str, Optional[str]]],
    existing_values: Dict[str, Any],
    *,
    app_hint: Optional[str] = None,
) -> Dict[str, Any]:
    """
    Return only the variables still missing after considering required_meta and existing_values.
    Values are inferred to be LocalStack-safe. app_hint seeds names for buckets, prefixes, etc.
    """
    out: Dict[str, Any] = {}
    for name, meta in required_meta.items():
        # Only treat as required if Terraform has no default
        has_default = bool(meta.get("has_default"))
        if has_default:
            continue
        if name in existing_values:
            continue
        inferred = _infer_localstack_value(name, meta, app_hint=app_hint)
        out[name] = inferred
    return out


def generate_tfvars_file(
    tf_root: Path,
    required_meta: Dict[str, Dict[str, Optional[str]]],
    *,
    app_hint: Optional[str] = None,
    force: bool = False,
) -> Tuple[Optional[Path], Dict[str, Any], bool]:
    """
    Compute missing required variables and, if any, write them to localstack.auto.tfvars.json.
    Returns (path_or_None, provided_values, created_flag).
    If no values are missing, returns (None, {}, False).
    If file exists and force=False, merges conservatively by writing only missing keys; existing keys are untouched.
    """
    tf_root = Path(tf_root).resolve()
    app_hint = app_hint or _default_app_hint(tf_root)

    existing = load_existing_var_values(tf_root)
    missing = build_missing_vars(required_meta, existing, app_hint=app_hint)

    if not missing:
        return None, {}, False

    target = tf_root / "localstack.auto.tfvars.json"
    if target.exists() and not force:
        try:
            prev = json.loads(target.read_text(encoding="utf-8"))
        except Exception:
            prev = {}
        merged = {**prev}
        # write only keys not present to avoid clobber
        for k, v in missing.items():
            if k not in merged:
                merged[k] = v
        to_write = merged
    else:
        to_write = missing

    target.write_text(json.dumps(to_write, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
    return target, missing, True


# ----------------------- Internals: inference -----------------------

_REGION_DEFAULT = os.getenv("LOCALSTACK_AWS_REGION", "us-east-1")
_ACCOUNT_ID = os.getenv("LOCALSTACK_ACCOUNT_ID", "000000000000")

# canonical name seeds for deterministic placeholders
def _default_app_hint(tf_root: Path) -> str:
    # Use last directory name as a stable seed
    return _slug(Path(tf_root).name) or "app"

def _infer_localstack_value(
    name: str,
    meta: Dict[str, Optional[str]],
    *,
    app_hint: Optional[str] = None,
) -> Any:
    """
    Heuristics for common AWS inputs. Keep deterministic and LocalStack-friendly.
    meta["type"] may be a stringified HCL type expression; ignore for robustness.
    """
    key = name.lower()
    seed = _slug(app_hint or "app")

    # Regions and profiles
    if key in {"region", "aws_region"} or key.endswith("_region"):
        return _REGION_DEFAULT
    if key in {"profile", "aws_profile"}:
        return "default"

    # Networking CIDRs
    if key in {"vpc_cidr", "vpc_cidr_block", "cidr_block"} or key.endswith("_cidr") or key.endswith("_cidr_block"):
        # Return a private RFC1918 block; deterministic per variable name
        return _cidr_for(name)

    # Names, prefixes, environment
    if key in {"name", "project", "service", "app"} or key.endswith("_name"):
        return f"{seed}"
    if key.endswith(("_prefix", "_suffix")):
        return f"{seed}"
    if key in {"env", "environment", "stage"}:
        return "dev"

    # Buckets, queues, topics
    if "bucket" in key:
        return f"{seed}-bucket"
    if "queue" in key:
        return f"{seed}-queue"
    if "topic" in key:
        return f"{seed}-topic"

    # IAM and ARNs
    if key in {"role", "role_name"} or key.endswith("_role") or key.endswith("_role_name"):
        return f"{seed}-role"
    if key.endswith("_role_arn") or key.endswith("_arn"):
        # Construct a plausible ARN; service guessed from key
        service = _guess_service_from_key(key)
        return f"arn:aws:{service}:{_REGION_DEFAULT}:{_ACCOUNT_ID}:{seed}"

    # Key pairs, KMS keys
    if key in {"key_name", "ssh_key_name"} or key.endswith("_key_name"):
        return f"{seed}-key"
    if key in {"kms_key_id", "kms_key_arn"} or key.endswith("_kms_key_id"):
        return f"arn:aws:kms:{_REGION_DEFAULT}:{_ACCOUNT_ID}:key/{seed}"

    # Instance/image defaults for EC2 in LocalStack context
    if key in {"instance_type"} or key.endswith("_instance_type"):
        return "t3.micro"
    if key in {"ami", "ami_id"} or key.endswith("_ami") or key.endswith("_ami_id"):
        # Dummy AMI ID pattern; LocalStack doesn't validate against AWS catalog
        return "ami-12345678"

    # Subnet/VPC IDs if expected to be provided
    if key in {"vpc_id"} or key.endswith("_vpc_id"):
        return "vpc-00000000"
    if key in {"subnet_id"} or key.endswith("_subnet_id"):
        return "subnet-00000000"
    if key.endswith("_security_group_id") or key.endswith("_sg_id"):
        return "sg-00000000"

    # S3 object keys, paths
    if key.endswith(("_object_key", "_object", "_path", "_key")) and "kms" not in key:
        return f"{seed}.txt"

    # Generic tags map
    if key in {"tags", "default_tags"} or key.endswith("_tags"):
        return {
            "Name": seed,
            "Environment": "dev",
            "ManagedBy": "localstack",
        }

    # IPs
    if re.search(r"(?:^|_)ip(?:_address)?$", key) or key.endswith(("private_ip","public_ip")):
        # deterministic 10.x.x.x
        oct2 = (abs(hash(name)) % 250) + 1
        oct3 = (abs(hash(name + ":b")) % 250) + 1
        oct4 = (abs(hash(name + ":c")) % 250) + 1
        return f"10.{oct2}.{oct3}.{oct4}"

    # CIDR single
    if re.search(r"(?:^|_)cidr(?:_block)?$", key):
        return _cidr_for(name)  # already returns 10.x.0.0/24

    # CIDR lists (common: cidr_blocks, allowed_cidrs, trusted_networks, source_cidrs)
    if key in {"cidr_blocks","source_cidrs"} or re.search(r"cidr(s)?$", key) or re.search(r"(?:^|_)allowed_.*cidr", key):
        return [_cidr_for(name)]

    # Ports
    if key.endswith(("_port","port")) and "export" not in key:
        return 80
    if key.endswith(("from_port","to_port")):
        return 0 if key.endswith("from_port") else 65535

    # Booleans
    if key.startswith(("enable_","disable_","create_","attach_","associate_")):
        return True

    # Security-related IDs
    if key.endswith(("_sg_id","_security_group_id","_security_group_ids")):
        return [] if key.endswith("ids") else "sg-00000000"


    # Default fallbacks by rough scalar kind
    # Try to coerce meta["type"] to signal list/map defaults. Keep strings safe.
    t = (meta.get("type") or "").lower()
    if "list" in t or "set" in t or key.endswith("s"):
        return []
    if "map" in t or "object" in t or key.endswith("_map"):
        return {}
    # scalar default
    return f"{seed}"


def _guess_service_from_key(key: str) -> str:
    if "lambda" in key:
        return "lambda"
    if "logs" in key or "log" in key:
        return "logs"
    if "s3" in key or "bucket" in key:
        return "s3"
    if "sqs" in key or "queue" in key:
        return "sqs"
    if "sns" in key or "topic" in key:
        return "sns"
    if "kms" in key:
        return "kms"
    if "events" in key or "eventbridge" in key:
        return "events"
    if "iam" in key or "role" in key:
        return "iam"
    if "dynamo" in key or "dynamodb" in key:
        return "dynamodb"
    if "ec2" in key or "instance" in key or "vpc" in key:
        return "ec2"
    return "iam"


def _cidr_for(name: str) -> str:
    """
    Deterministic but simple CIDR generator for placeholders.
    Uses a hash of the variable name to pick a /24 in 10.0.0.0/8.
    """
    h = abs(hash(name)) % 254 + 1  # 1..254
    return f"10.{h}.0.0/24"


def _slug(s: str) -> str:
    s = s.strip().lower()
    s = re.sub(r"[^a-z0-9]+", "-", s)
    s = re.sub(r"-+", "-", s).strip("-")
    return s or "app"


# ----------------------- Internals: parsing -----------------------

def _parse_varfile(path: Path) -> Dict[str, Any]:
    if path.suffix.lower() == ".json":
        return json.loads(path.read_text(encoding="utf-8"))
    # very conservative line parser for .tfvars
    # supports: key = "str" | number | bool | null
    # ignores complex (lists/maps/heredocs)
    out: Dict[str, Any] = {}
    text = path.read_text(encoding="utf-8", errors="ignore")
    assign_re = re.compile(r'^\s*([A-Za-z0-9_]+)\s*=\s*(.+?)\s*$', re.MULTILINE)
    for m in assign_re.finditer(text):
        k = m.group(1)
        raw = m.group(2).strip()
        val = _parse_scalar(raw)
        if val is not _UNPARSED:
            out[k] = val
    return out

_UNPARSED = object()

def _parse_scalar(raw: str) -> Any:
    # strip inline comments // or #
    raw = re.sub(r'\s*(#|//).*$','', raw).strip()
    # quoted string
    if (raw.startswith('"') and raw.endswith('"')) or (raw.startswith("'") and raw.endswith("'")):
        return _unquote(raw[0], raw)
    # bools
    if raw.lower() in {"true", "false"}:
        return raw.lower() == "true"
    # null
    if raw.lower() == "null":
        return None
    # number
    if re.fullmatch(r"-?\d+(\.\d+)?", raw):
        try:
            return int(raw) if "." not in raw else float(raw)
        except Exception:
            return _UNPARSED
    # give up on complex values
    return _UNPARSED

def _unquote(q: str, s: str) -> str:
    body = s[1:-1]
    # minimal unescape for \" and \n
    body = body.replace(r"\"","\"").replace(r"\n","\n")
    return body
