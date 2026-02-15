# analysis/localstack_checker.py
from __future__ import annotations

import json
import os
from pathlib import Path
from typing import Dict, Iterable, Optional, Set, Tuple

# ---------- Public API ----------

def check_localstack_compatibility(
    resource_types: Set[str],
    *,
    require_full: bool = False,
    support_matrix: Optional[Dict[str, Dict[str, str]]] = None,
) -> Tuple[bool, Dict[str, object]]:
    """
    Input: set like {"aws_s3_bucket", "aws_lambda_function", ...}
    Output: (deployable, report)
      - deployable: True if no 'none' services. If require_full=True, also rejects 'partial' and 'unknown'.
      - report: {
          "by_service": {service: {"status": "full|partial|none|unknown", "resource_types": [...]}},
          "summary": {"full": [...], "partial": [...], "none": [...], "unknown": [...]},
          "unsupported_resource_types": [...],
        }
    """
    matrix = support_matrix or load_support_matrix()
    svc_to_rtypes: Dict[str, Set[str]] = {}
    for rtype in sorted(resource_types):
        if not rtype.startswith("aws_"):
            # Non-AWS resources are irrelevant for LocalStack; mark unknown service group.
            svc = "_non_aws"
        else:
            svc = _map_rtype_to_service(rtype)
        svc_to_rtypes.setdefault(svc, set()).add(rtype)

    by_service: Dict[str, Dict[str, object]] = {}
    buckets = {"full": set(), "partial": set(), "none": set(), "unknown": set()}
    unsupported_rtypes: Set[str] = set()

    for svc, rtypes in sorted(svc_to_rtypes.items()):
        status = _service_status(svc, matrix)
        by_service[svc] = {"status": status, "resource_types": sorted(rtypes)}

        if status == "none":
            unsupported_rtypes.update(rtypes)
        if status not in buckets:
            status = "unknown"
        buckets[status].add(svc)

    has_none = len(buckets["none"]) > 0
    has_partial_or_unknown = len(buckets["partial"]) > 0 or len(buckets["unknown"]) > 0

    deployable = not has_none and (not require_full or not has_partial_or_unknown)

    report = {
        "by_service": by_service,
        "summary": {k: sorted(v) for k, v in buckets.items()},
        "unsupported_resource_types": sorted(unsupported_rtypes),
        "require_full": require_full,
    }
    return deployable, report


def load_support_matrix(source: Optional[object] = None) -> Dict[str, Dict[str, str]]:
    """
    Load LocalStack support matrix. Each entry: service -> {"status": "full|partial|none", "notes": "..."}.
    Precedence:
      1) explicit dict provided in `source`
      2) JSON file path from `source` if str/Path
      3) JSON file pointed by env LOCALSTACK_SUPPORT_MATRIX
      4) built-in heuristic matrix below
    """
    if isinstance(source, dict):
        return _normalize_matrix(source)
    path: Optional[Path] = None
    if isinstance(source, (str, Path)):
        path = Path(source)
    elif os.getenv("LOCALSTACK_SUPPORT_MATRIX"):
        path = Path(os.getenv("LOCALSTACK_SUPPORT_MATRIX", ""))
    if path:
        try:
            with path.open("r", encoding="utf-8") as f:
                return _normalize_matrix(json.load(f))
        except Exception:
            pass
    return _BUILTIN_MATRIX.copy()


# ---------- Internals ----------

def _service_status(service: str, matrix: Dict[str, Dict[str, str]]) -> str:
    meta = matrix.get(service)
    if not meta:
        return "unknown"
    return meta.get("status", "unknown")

def _normalize_matrix(m: Dict[str, Dict[str, str]]) -> Dict[str, Dict[str, str]]:
    out: Dict[str, Dict[str, str]] = {}
    for k, v in m.items():
        status = (v.get("status") or "").lower()
        if status not in {"full", "partial", "none"}:
            status = "unknown"
        out[k] = {"status": status, "notes": v.get("notes", "")}
    return out

def _map_rtype_to_service(rtype: str) -> str:
    """
    Map Terraform aws_* resource types to LocalStack service buckets.
    Examples:
      aws_s3_bucket -> s3
      aws_lambda_function -> lambda
      aws_apigatewayv2_* -> apigatewayv2
      aws_lb / aws_alb / aws_lb_listener -> elbv2
      aws_cloudwatch_log_group -> logs
      aws_iam_role -> iam
      aws_route_table -> ec2
    """
    # Direct one-to-one common prefixes
    prefix = rtype.removeprefix("aws_")
    top = prefix.split("_", 1)[0]

    # CloudWatch Events / EventBridge old-style resource names
    if prefix.startswith(("cloudwatch_event_", "cloudwatchevent_")):
        return "events"  # localstack service name; provider endpoint key will differ

    # Step Functions
    if prefix.startswith(("sfn_", "stepfunctions_")):
        return "stepfunctions"

    # WAF families
    if prefix.startswith(("wafv2_",)):
        return "wafv2"
    if prefix.startswith(("wafregional_", "waf_",)):
        return "wafregional"

    # EFS
    if prefix.startswith(("efs_",)):
        return "efs"

    # ECR Public
    if prefix.startswith(("ecrpublic_",)):
        return "ecrpublic"
    # --- end additions ---
    # Special cases and regrouping
    if prefix.startswith(("apigatewayv2_",)):
        return "apigatewayv2"
    if prefix.startswith(("apigateway_",)):
        return "apigateway"
    if prefix.startswith(("cloudwatch_log", "logs_", "log_")):
        return "logs"
    if prefix.startswith(("cloudwatch_", "metric_", "alarm_")):
        return "cloudwatch"
    if prefix.startswith(("sqs_",)):
        return "sqs"
    if prefix.startswith(("sns_",)):
        return "sns"
    if prefix.startswith(("dynamodb_",)):
        return "dynamodb"
    if prefix.startswith(("lambda_",)):
        return "lambda"
    if prefix.startswith(("iam_",)):
        return "iam"
    if prefix.startswith(("ecr_",)):
        return "ecr"
    if prefix.startswith(("ecs_",)):
        return "ecs"
    if prefix.startswith(("kms_",)):
        return "kms"
    if prefix.startswith(("ssm_",)):
        return "ssm"
    if prefix.startswith(("secretsmanager_",)):
        return "secretsmanager"
    if prefix.startswith(("events_", "eventbridge_")):
        return "events"  # EventBridge
    if prefix.startswith(("s3control_",)):
        return "s3control"
    if prefix.startswith(("opensearch_", "elasticsearch_")):
        return "opensearch"
    if prefix.startswith(("rds_",)):
        return "rds"
    if prefix.startswith(("redshift_",)):
        return "redshift"
    if prefix.startswith(("glue_",)):
        return "glue"
    if prefix.startswith(("route53_",)):
        return "route53"
    if prefix.startswith(("cloudfront_",)):
        return "cloudfront"
    if prefix.startswith(("cognito_", "cognitoidp_", "cognito_identity_")):
        return "cognito-idp"
    if prefix.startswith(("elb_", "lb_", "alb_", "elbv2_", "listener_")) or prefix in {"lb", "alb"}:
        return "elbv2"
    if top in {"subnet", "vpc", "internet_gateway", "nat_gateway", "route", "route_table",
               "route_table_association", "network_acl", "network_interface", "eip", "security_group",
               "launch_configuration", "launch_template", "ami", "instance", "placement_group",
               "volume", "snapshot", "key_pair"}:
        return "ec2"

    # Fallback to the top-level token (e.g., "s3", "eks", etc.)
    return top

# ---------- Built-in heuristic matrix ----------
# Conservative defaults. Adjust or override as needed for your LocalStack Pro version.
# 'full' means commonly usable for local dev; 'partial' means significant gaps; 'none' means unsupported.
_BUILTIN_MATRIX: Dict[str, Dict[str, str]] = {
    # Core, widely used
    "s3": {"status": "full", "notes": "Buckets, objects, notifications"},
    "dynamodb": {"status": "full", "notes": "Tables, streams (basic)"},
    "sqs": {"status": "full", "notes": "Queues, permissions"},
    "sns": {"status": "full", "notes": "Topics, subscriptions"},
    "lambda": {"status": "full", "notes": "Create/update/invoke; layers basic"},
    "apigateway": {"status": "full", "notes": "REST APIs"},
    "apigatewayv2": {"status": "full", "notes": "HTTP/WebSocket APIs"},
    "logs": {"status": "full", "notes": "CloudWatch Logs groups/streams"},
    "cloudwatch": {"status": "partial", "notes": "Metrics/alarms limited"},
    # Networking and compute
    "ec2": {"status": "partial", "notes": "VPC/subnets/routes/SGs basic; instances limited"},
    "elbv2": {"status": "partial", "notes": "ALB/NLB basic"},
    "autoscaling": {"status": "partial", "notes": "Limited coverage"},
    # Identity and secrets
    "iam": {"status": "partial", "notes": "Basic roles/policies"},
    "kms": {"status": "partial", "notes": "Basic keys; cryptography emulation"},
    "secretsmanager": {"status": "partial", "notes": "Secrets CRUD"},
    "ssm": {"status": "partial", "notes": "Parameters; mixed for other features"},
    # Data and analytics
    "glue": {"status": "partial", "notes": "Catalog basics"},
    "opensearch": {"status": "partial", "notes": "Domains basic"},
    "rds": {"status": "partial", "notes": "Limited emulation"},
    "redshift": {"status": "none", "notes": "Not supported"},
    "athena": {"status": "none", "notes": "Not supported"},
    # Networking/DNS/CDN
    "route53": {"status": "partial", "notes": "Hosted zones basic"},
    "cloudfront": {"status": "full", "notes": "CloudFront distributions supported"},
    # Containers and orchestration
    "ecr": {"status": "partial", "notes": "Repositories basic"},
    "ecs": {"status": "partial", "notes": "Limited control plane"},
    "eks": {"status": "none", "notes": "Not supported"},
    # Identity
    "cognito-idp": {"status": "partial", "notes": "User pools basic"},
    # Edge/others
    "s3control": {"status": "none", "notes": "Not supported"},
    # Catch-alls
    "_non_aws": {"status": "unknown", "notes": "Non-AWS providers"},
    "efs": {"status": "partial", "notes": "Basic file system APIs"},
    "ecrpublic": {"status": "partial", "notes": "Basic coverage"},
    "stepfunctions": {"status": "none", "notes": "Not supported"},
    "wafv2": {"status": "none", "notes": "Not supported"},
    "wafregional": {"status": "none", "notes": "Not supported"},
    # keep "events" because _map_rtype_to_service returns "events"
    "events": {"status": "partial", "notes": "EventBridge/CloudWatch Events basics"},
}

# ---------- Convenience helpers for repo_analyzer ----------

def summarize_services(resource_types: Iterable[str]) -> Dict[str, object]:
    """
    Quick summary suitable for gate.json.
    Returns:
      {
        "service_counts": {"s3": 3, "lambda": 5, ...},
        "resource_type_counts": {"aws_s3_bucket": 2, ...}
      }
    """
    svc_counts: Dict[str, int] = {}
    rt_counts: Dict[str, int] = {}
    for r in resource_types:
        rt_counts[r] = rt_counts.get(r, 0) + 1
        svc = _map_rtype_to_service(r) if r.startswith("aws_") else "_non_aws"
        svc_counts[svc] = svc_counts.get(svc, 0) + 1
    return {"service_counts": svc_counts, "resource_type_counts": rt_counts}
