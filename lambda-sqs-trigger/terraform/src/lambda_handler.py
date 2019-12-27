import os

def main():
    sqs_queue = os.environ.get('SQS_QUEUE', '')
    return {
        "status_code": 200,
        "body": f"queue is {sqs_queue}"
    }

if __name__ == "__main__":
    main()