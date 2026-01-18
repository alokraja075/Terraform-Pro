def lambda_handler(event, context):
    # Simple hello world response
    return {
        "statusCode": 200,
        "headers": {"Content-Type": "application/json"},
        "body": "Hello from Python Lambda!"
    }
