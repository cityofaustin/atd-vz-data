# Vision Zero Event Handler

An event handler is basically a python script that
will run every time we submit a message to AWS Simple
Queue Service (SQS). Currently, the Python 3.8 runtime
is being used in AWS Lambda.

A message is basically any trivial text with a limit
of 256kb, as well as 10 metadata optional attributes.
This "message" is submitted to a URL managed by AWS
which will in turn add it to a queue. A queue can be
associated to an AWS Lambda function, so that whenever
a message is received, it triggers the function and the
message is passed to the code in the lambda function.


### Basic Structure

The basic file structure is as follows:

```bash
atd-events
├── README.md
└── crash_update_location
    ├── app.py
    └── requirements.txt
└── <name of your function here>
    ├── app.py
    └── requirements.txt
```

To create a new function, simply create a folder in the
`atd-events` directory and create the `app.py` and
`requirements.txt` file.

### The App File
The `app.py` file will be the entrypoint for the lambda
function to run. You can add any other python code
and files any way you want, but the pipeline is
programmed to look for this file as it's starting point.

Within this file, the main function is called `handler`,
this will the the entry point for your python code.

Example

```python
import json
import time


def handler(event, context):
    """
    Event handler main loop. It handles a single or multiple SQS messages.
    :param dict event: One or many SQS messages
    :param dict context: Event context
    """
    for record in event['Records']:
        timeStr = time.ctime()
        print('Current Timestamp : ', timeStr)
        print(json.dumps(record))
        timeStr = time.ctime()
        print("Done executing: ", timeStr)
```

#### The requirements file
The automated pipeline uses pip to install packages.
If your script needs an additional package (such as
pandas, requests, etc.), you can add its name to
the `requirements.txt` file as you normally would in
any other python project:

```
certifi==2020.4.5.1
chardet==3.0.4
idna==2.9
requests==2.23.0
urllib3==1.25.9
```

You can also pip freeze your current virtual environment:

```bash
$ virtualenv venv
$ source venv/bin/activate
$ pip install requests pandas
$ pip freeze > requirements.txt
```

### Development Pipeline

#### New PRs
First, it is recommended that you create a PR. Whenever a PR is created
a GitHub Action flow will begin creating the python bundles for Lambda and SQS and it
will deploy them automatically.

Secondly, it is recommended that you log in to AWS with your credentials
and visit the SQS page. In there you will see the list of active queues
for example `atd-vz-data-events-crash_update_location_pr_845`. If you
do not see a queue with your PR number, that means it has not been
deployed by CircleCI yet, if so give it a few minutes or check in
CircleCI for errors.

Third, once you find your PR in the SQS list, copy its name and use it
within the staging environment in Hasura. To recall, Hasura events submit
the data to a lambda endpoint along with an API key and the name of the
SQS queue, that is where you need to make the change to your new PR queue.
In this example, you would type in here: `crash_update_location_pr_845`
(ignore the prefix `atd-vz-data-events-` as it is not needed)

#### Closing PRs
Once the PR is merged to master, we rely on GitHub Actions to destroy all
the resources created by CircleCI for your PR. It will only target your PR
any other PRs that are not closed will not be removed until that happens.

**It is very important to change the name of the queue in Hasura back to
master, otherwise it will fail to execute the event**

#### Manual Deployment
While it is possible to deploy manually, there is no
immediate support for it due to these reasons:

1. The SQS needs to be created manually
2. The Lambda function needs to be associated to the queue.
3. The lambda function needs IAM permissions to run and access services.
4. Security-critical API keys are needed to make this happen.
