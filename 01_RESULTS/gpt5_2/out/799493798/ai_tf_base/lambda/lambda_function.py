import json
import os
import boto3


def lambda_handler(event, context):
    """List objects in an S3 bucket.

    Optional path parameter: /list-bucket-content/{folder}
    If provided, it is used as a prefix.
    """

    bucket = os.environ.get("BUCKET_NAME")
    if not bucket:
        return {
            "statusCode": 500,
            "headers": {"content-type": "application/json"},
            "body": json.dumps({"message": "BUCKET_NAME env var is not set"}),
        }

    folder = None
    try:
        folder = (event.get("pathParameters") or {}).get("folder")
    except Exception:
        folder = None

    prefix = folder.strip("/") + "/" if folder else ""

    s3 = boto3.client("s3")
    paginator = s3.get_paginator("list_objects_v2")

    keys = []
    for page in paginator.paginate(Bucket=bucket, Prefix=prefix):
        for obj in page.get("Contents", []) or []:
            keys.append(obj.get("Key"))

    return {
        "statusCode": 200,
        "headers": {"content-type": "application/json"},
        "body": json.dumps({"bucket": bucket, "prefix": prefix, "keys": keys}),
    }
