# Input bindings are passed in via param block.
param($Timer)

$webAppUrl = "https://$($env:webAppHostname)"

# use Invoke-WebRequest to send a request to the web app's URL and store the result so we can check the status code
# also, track the start and end times for the request so we can calculate the duration later on
$startTime = Get-Date
$result = Invoke-WebRequest -Uri $webAppUrl -SkipHttpErrorCheck
$endTime = Get-Date

# if the status code is in the range of client errors or server errors then mark the test as failed
if ($result.StatusCode -ge 400 -and $result.StatusCode -le 599)
{
    $success = $false
    $message = "Web app responding with HTTP status code $($result.StatusCode)"
}

# create a new app insights client using the instrumentation key stored in the 'APPINSIGHTS_INSTRUMENTATIONKEY' app setting
$appInsightsClient = New-AppInsightsClient -InstrumentationKey $env:APPINSIGHTS_INSTRUMENTATIONKEY

# send the availability test result back to app insights
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
