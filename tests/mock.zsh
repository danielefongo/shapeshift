typeset -gA __mocks_invocations

mock() {
    local mockedFunction=$1
    shift
    local params="$@"

    eval """
    $mockedFunction()
    {
        eval \"$params\";
        (( __mocks_invocations[\"$mockedFunction\"] = __mocks_invocations[\"$mockedFunction\"] + 1 ));
    }
    """
    __mocks_invocations["$mockedFunction"]=0
}

mock_calls() {
    mockedFunction=$1

    echo $__mocks_invocations["$mockedFunction"]
}

verify_mock_calls() {
    mockedFunction=$1

    local invocations=$__mocks_invocations["$mockedFunction"]
    assertEquals "wrong number of invocations for $mockedFunction" "$2" "$invocations"
}