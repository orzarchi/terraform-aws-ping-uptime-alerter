import json
import os
from urllib.request import Request, urlopen
from urllib.error import HTTPError
import boto3

ADDRESS = os.environ["ADDRESS"]
TOPIC_ARN = os.environ["SNS_TOPIC_ARN"]
USER_AGENT = 'Mozilla/5.0 (Windows; U; Windows NT 5.1; en-US; rv:1.9.0.7) Gecko/2009021910 Firefox/3.0.7 awsping'


def send_alarm(message):
    print(f"Sending message '{message}' to sns topic {TOPIC_ARN}")
    client = boto3.client('sns')
    response = client.publish(
        TargetArn=TOPIC_ARN,
        Message=json.dumps({'default': message}),
        MessageStructure='json'
    )


def lambda_handler(event, context):
    try:
        request = Request(ADDRESS, headers={'User-Agent': USER_AGENT, })

        with urlopen(request) as response:
            pass
    except HTTPError as e:
        send_alarm(f"Website {ADDRESS} failed check. Status code: {e.code} - {e.reason}")
