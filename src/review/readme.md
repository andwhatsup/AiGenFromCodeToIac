# Review Module

Interprets evaluation errors and fixes generated Terraform code iteratively.

## Overview

When Terraform validation fails, the review module:
1. Parses evaluation errors
2. Extracts root causes and diagnostic context
3. Routes to Code Review Agent for automated fixes
4. Retries validation until success or max iterations reached

## Main Functions

**`evaluate_dir_structured(tf_dir, output_dir) -> dict`**

Runs evaluation and normalizes results into structured error objects.

**Returns**: Dictionary with categorized errors by stage (VALIDATION, PLAN, POLICY, ARCHITECTURE, etc.)

---

**`dispatch_to_fix_agent(app_id, agent_name, tf_dir, evaluation_result, feedback)`**

Routes evaluation errors to Code Review Agent with rich context.

**Details**:
- Builds error context from evaluation results
- Invokes `code_review_agent.review_terraform()` for fixes
- Records progress for multi-attempt tracking

---

## Data Models

**EvaluationError** - Normalized error (code, message, file, line, resource, extra context)

**EvaluationResult** - Evaluation outcome (ok, stage, errors list, attempt count)

**EvaluationFeedback** - Feedback for fix agent (error context, suggested fixes, risk flags)

## Files

- **eval_agent.py** - Data models and evaluation interpreter (EvaluationResult, EvaluationError, EvaluationFeedback)
- **review_flow.py** - Orchestrates evaluation normalization and fix agent dispatch
- **__init__.py** - Module exports

## Pipeline Integration

1. Evaluation runs and detects Terraform errors
2. Review module normalizes error output
3. Code Review Agent receives rich error context
4. Agent modifies Terraform files to fix issues
5. Main pipeline re-runs evaluation (up to MAX_IAC_ITERS times)
6. Success: Terraform passes validation and deployed
7. Failure after max retries: Logged for manual review
