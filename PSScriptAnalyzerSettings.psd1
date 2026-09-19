@{
    # PSScriptAnalyzer configuration for WinKit desktop application
    ExcludeRules = @(
        'PSAvoidGlobalVars',
        'PSUseShouldProcessForStateChangingFunctions',
        'PSAvoidUsingWriteHost'
    )
}

