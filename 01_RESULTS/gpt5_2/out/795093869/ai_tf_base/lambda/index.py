import json
import logging
import os

logger = logging.getLogger()
logger.setLevel(os.getenv("LOG_LEVEL", "INFO"))


def lambda_handler(event, context):
    # Minimal handler: logs S3 event. In the full reference architecture this would
    # call MWAA create_cli_token and trigger a DAG.
    logger.info("Received event: %s", json.dumps(event))
    return {"ok": True}
