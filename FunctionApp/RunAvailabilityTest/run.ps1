# Input bindings are passed in via param block.
param($Timer)

$webAppUrl = "https://$($env:webAppHostname)"
$startTime = Get-Date
$result = Invoke-WebRequest -Uri $webAppUrl -SkipHttpErrorCheck
$endTime = Get-Date

if ($result.StatusCode -ge 400 -and $result.StatusCode -le 599)
{
    $success = $false
    $message = "Web app responding with HTTP status code $($result.StatusCode)"
}

$appInsightsClient = New-AppInsightsClient -InstrumentationKey $env:APPINSIGHTS_INSTRUMENTATIONKEY

$appInsightsParams = @{
    AppInsightsClient = $appInsightsClient
    TestName          = $webAppUrl
    DateTime          = $startTime
    Duration          = New-TimeSpan -Start $startTime -End $endTime
    TestRunLocation   = $env:location
    Success           = $success ?? $true
    Message           = $message ?? ""
}
Send-AppInsightsAvailability @appInsightsParams
