import json, os, time, uuid
import boto3

sqs = boto3.client("sqs")
QUEUE_URL = os.environ["QUEUE_URL"]

def handler(event, context):
    # event is API Gateway v2 (HTTP API) event
    body_raw = event.get("body") or ""
    if event.get("isBase64Encoded"):
        # If you later enable base64, handle decode here. For now, keep simple.
        pass

    try:
        payload = json.loads(body_raw) if body_raw else {}
    except json.JSONDecodeError:
        return {"statusCode": 400, "headers": {"content-type": "application/json"},
                "body": json.dumps({"error": "Invalid JSON"})}

    msg = {
        "message_id": str(uuid.uuid4()),
        "received_at": int(time.time()),
        "source": "apigw-httpapi",
        "request": {
            "path": event.get("rawPath"),
            "method": event.get("requestContext", {}).get("http", {}).get("method"),
            "ip": event.get("requestContext", {}).get("http", {}).get("sourceIp"),
        },
        "payload": payload,
    }

    sqs.send_message(
        QueueUrl=QUEUE_URL,
        MessageBody=json.dumps(msg),
    )

    return {
        "statusCode": 202,
        "headers": {"content-type": "application/json"},
        "body": json.dumps({"status": "queued", "message_id": msg["message_id"]})
    }
