import os
import requests
import json


def post_to_slack(event, context):
    slack_data = {
    "text": "Hey you app is now running, try out a healtcheck",
    "attachments": [
        {
            "fallback": "Test Healthcheck at ",
            "actions": [
                {
                    "type": "button",
                    "text": "Healthcheck",
                    "url": os.environ['URL']
                }
            ]
        }
    ]
    }
    slack_webhook_url = os.environ['SLACK_WEBHOOK_URL']
    print(event)
    slack_message = "ECS Service {detail[containers][0][name]}-{detail[version]} just changed state to {detail[lastStatus]}".format(**event)
    last_status = (event['detail']['lastStatus'])
    if last_status == 'RUNNING':
        requests.post(slack_webhook_url, data=json.dumps(slack_data), headers={'Content-Type': 'application/json'})
    else:
        pass
    return
