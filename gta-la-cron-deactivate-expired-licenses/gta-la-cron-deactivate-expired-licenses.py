import boto3
import os

# For checking project acceessibility
if "ENVIRONMENT" in os.environ:
    ENVIRONMENT = os.environ["ENVIRONMENT"]
else:
    ENVIRONMENT = "test"


# set event = None to test locally
def lambda_handler(event, context):
    pass


if __name__ == "__main__":
    lambda_handler(None, None)
