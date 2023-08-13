function New-PowerShellAnalysis {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$ScriptDirectory
    )

    try {
        # Get all rules from PSScriptAnalyzer with the severity Error, Warning and Information. Invoke analysis directly after
        Write-Verbose "Get all built-in rules from PSScriptAnalyzer"
        $scriptAnalyzerRules = Get-ScriptAnalyzerRule -Severity Error, Warning, Information
        Write-Verbose "Analyse script directory with PSScriptAnalyzer ($ScriptDirectory)"
        $scriptAnalyzer = Invoke-ScriptAnalyzer -Path $ScriptDirectory -Recurse -IncludeRule $scriptAnalyzerRules

        # When the analysis return a result, return the result. Else return 0
        if ($scriptAnalyzer) {
            return $scriptAnalyzer
        }
        else {
            return 0
        }
    }
    catch {
        Write-Error $_
        Write-Error $_.Exception.Message
    }
}

function New-PullRequestComment {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$Line,

        [Parameter(Mandatory = $true)]
        [string]$Message,

        [Parameter(Mandatory = $true)]
        [string]$ScriptPath
    )

    try {
        # Create new comment in pull request
        Write-Verbose 'Construct Azure DevOps API URI for pull request'
        $uri = "$($Env:SYSTEM_TEAMFOUNDATIONCOLLECTIONURI)$Env:SYSTEM_TEAMPROJECTID/_apis/git/repositories/$($Env:BUILD_REPOSITORY_NAME)/pullRequests/$($Env:SYSTEM_PULLREQUEST_PULLREQUESTID)/threads?api-version=7.0"
        Write-Verbose "URI constructed ($uri)"

        # Construct body for pull request comment
        Write-Verbose 'Construct body for pull request comment'
        $body = @{
            comments = @(
                @{
                    parentCommentId = 0
                    content = $Message
                    commentType = 1                    
                }
            )
            status = 'active'
            threadContext = @{
                filePath = $ScriptPath -replace [regex]::Escape($Env:SYSTEM_DEFAULTWORKINGDIRECTORY), ""
                leftFileEnd = $null
                leftFileStart = $null
                rightFileEnd = @{
                    line = $Line
                    offset = 100
                }
                rightFileStart = @{
                    line = $Line
                    offset = 1
                }
            }
        }

        # Invoke Azure DevOps API to create comment in pull request
        Write-Verbose 'Invoke Azure DevOps API to create comment in pull request'
        $requestParameters = @{
            Uri = $uri
            Method = 'POST'
            Authentication = 'Bearer'
            Token = ($Env:SYSTEM_ACCESSTOKEN | ConvertTo-SecureString -AsPlainText -Force)
            Body = ($body | ConvertTo-Json -Depth 4)
            ContentType = 'application/json'
        }
        $request = Invoke-RestMethod @requestParameters
    }
    catch {
        Write-Error $_
        Write-Error $_.Exception.Message
    }

    return $request
}