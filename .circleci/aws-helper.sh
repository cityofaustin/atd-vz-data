#!/usr/bin/env bash

# Determine work branch
case "${CIRCLE_BRANCH}" in
  "production")
    export WORKING_STAGE="production";
    ;;

  "master")
    export WORKING_STAGE="staging";
    ;;
  *)
    unset WORKING_STAGE;
    echo "We can only deploy master or production.";
    exit 1;
    ;;
esac

# Deploys API to AWS
function update_cr3_api {
    if [[ "${WORKING_STAGE}" == "" ]]; then
        echo "No working stage could be determined."
        exit 1;
    fi;

    cd "atd-cr3-api";
    sudo pip install -r requirements.txt;
    echo $ZAPPA_SETTINGS > zappa_settings.json;
    zappa update $WORKING_STAGE;
}
