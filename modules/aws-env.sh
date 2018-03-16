#!/bin/bash


# Environment
#   N_CONFIG_DIR
#        Required: True
#   N_AWS_ENV_KEYS_FILE_PREFIX
#       Required: False
#       Default Value: "$N_CONFIG_DIR/aws-env-keys"
#   N_AWS_ENV_ACCOUNT_FILE_PREFIX
#       Required: False
#       Default Value: "$N_CONFIG_DIR/aws-env-account"
#    N_AWS_ENV_EXPORT_AS
#        Required: False
#        Default Value: "awsEnv"


_nawsEnvKeysFilePrefix="$(_nAbsolutePath "${N_AWS_ENV_KEYS_FILE_PREFIX-$N_CONFIG_DIR/aws-env-keys-}")"
_nawsEnvAccountFilePrefix="$(_nAbsolutePath "${N_AWS_ENV_ACCOUNT_FILE_PREFIX-$N_CONFIG_DIR/aws-env-account-}")"
_nawsEnvExportAs="${N_AWS_ENV_EXPORT_AS-awsEnv}"

_nawsEnvLoad() {
    local env="$1"

    if [[ "$env" == "" ]]; then
        env="default"
    fi

    local keysFile="$_nawsEnvKeysFilePrefix$env"
    local accountFile="$_nawsEnvAccountFilePrefix$env"

    _nSourceIf "$keysFile"
    _nSourceIf "$accountFile"

    export AWS_ACCESS_KEY_ID="$aws_access_key_id"
    export AWS_SECRET_ACCESS_KEY="$aws_secret_access_key"
    export AWS_SESSION_TOKEN="$aws_session_token"
    export AWS_ACCCUNT_NUMBER="$aws_account_number"

    _nLogOrEcho "AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID"
    _nLogOrEcho "AWS_SECRET_ACCESS_KEY=<hidden>"
    _nLogOrEcho "AWS_SESSION_TOKEN=<hidden>"
    _nLogOrEcho "AWS_ACCCUNT_NUMBER=$AWS_ACCCUNT_NUMBER"
}

_nawsEnvPrintUsage() {
    echo "Usage:"
    echo "$_nawsEnvExportAs"
    echo "    Load aws environment."
    echo "[Options]"
    echo "    <environment>"
    echo "        Load provided environment."
    echo "    -?"
    echo "        Show this message."
}

_nawsEnv() {
    local input="$1"

    if [[ "$input" == "-?" ]]; then
        _nawsEnvPrintUsage
        return $?
    fi

    _nawsEnvLoad "$input"
    return $?
}

alias $_nawsEnvExportAs="_nawsEnv"

_nLog "Use '$_nawsEnvExportAs <env> to load aws environment."
_nLog "Use '$_nawsEnvExportAs -?' to know more about this command."

