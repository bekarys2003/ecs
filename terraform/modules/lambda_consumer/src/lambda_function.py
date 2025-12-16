import json
import logging

logger = logging.getLogger()
logger.setLevel(logging.INFO)

def handler(event, context):
    # SQS event: event["Records"] is a list
    for r in event.get("Records", []):
        body = r.get("body", "")
        logger.info("Raw message body: %s", body)

        try:
            msg = json.loads(body) if body else {}
        except json.JSONDecodeError:
            # Raising error => message will retry and can land in DLQ
            raise RuntimeError("Invalid JSON in SQS message")

        payload = msg.get("payload", msg)

        # Demo: if payload has {"fail": true} then force failure to test retries/DLQ
        if isinstance(payload, dict) and payload.get("fail") is True:
            logger.error("Forced failure requested. Sending to retry/DLQ path.")
            raise RuntimeError("Forced failure for DLQ demo")

        # Pretend processing
        logger.info("Processed payload: %s", json.dumps(payload))
    return {"ok": True}
