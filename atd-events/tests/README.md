# ATD - VZ Events - Testing

We are following a very basic pattern to write and make tests. We use pytest
with a combination of whatever packages you are running in your SQS event.

To get started:

1. Create a virtual environment:
    ```
    $ virtualenv venv
    $ source venv/bin/activate
    ```
2. Install your app packages (if needed):
    ```
    $ pip install pytest
    $ pip install -r your_sqs_folder/requirements.txt
    ```
3. (Optional) Some of the tests already written will require you
to set up additional environment variables. This is because some of
the code interacts with the HASURA api and that code needs to be tested
too. These are the environment variables needed, be sure to provide
variables for the staging environment only: 
   ```
   export HASURA_ADMIN_SECRET="..."
   export HASURA_ENDPOINT="..."
   export HASURA_TRIGGER_API_KEY="..."
   ```
4. Run your tests:
   ```
   # Run a specific test:
   $ pytest -v tests/your_test.py
   $ pytest -v tests/your_tests.py::TestClass::test_method
   ```