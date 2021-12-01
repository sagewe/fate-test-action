#!/bin/sh -l

sed -i "s#export PYTHONPATH=.*#export PYTHONPATH=${GITHUB_WORKSPACE}/python:${GITHUB_WORKSPACE}/fateflow/python:${GITHUB_WORKSPACE}/eggroll/python#" ${GITHUB_WORKSPACE}/bin/init_env.sh \
    && sed -i 's#venv=.*#venv=/venv#' ${GITHUB_WORKSPACE}/bin/init_env.sh \
    && bash "${GITHUB_WORKSPACE}/fateflow/bin/service.sh" start

# config fate_test
/venv/bin/pipeline init --ip 127.0.0.1 --port 9380 \
    && /venv/bin/flow init --ip 127.0.0.1 --port 9380 \
    && /venv/bin/fate_test config \
    && sed -i "s#data_base_dir:.*#data_base_dir: ${GITHUB_WORKSPACE}#" /venv/lib/python3.6/site-packages/fate_test/fate_test_config.yaml \
    && sed -i "s#fate_base:.*#fate_base: ${GITHUB_WORKSPACE}#" /venv/lib/python3.6/site-packages/fate_test/fate_test_config.yaml \

test_name=$2
if [ -z "$2" ]
then
    test_name=""
fi

# run fate_test
case $1 in
    dsl)
        /venv/bin/fate_test suite -y -i ${GITHUB_WORKSPACE}/examples/dsl/v2/${test_name}
        ;;
    pipeline)
        /venv/bin/fate_test suite -y -i ${GITHUB_WORKSPACE}/examples/pipeline/${test_name}
        ;;
    *)
        echo "required `dsl` or `pipeline`, found `$1`"
        exit 1
esac


# export results

body="$(find $(pwd)/logs -type f -exec cat {} +)"
body="${body//'%'/'%25'}"
body="${body//$'\n'/'%0A'}"
body="${body//$'\r'/'%0D'}" 
echo "::set-output name=body::$body"