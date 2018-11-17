$asyncCallback = {
    Param (
        # Event source object
        [System.Management.Automation.Powershell]
        $sender,

        # Inheritor of [System.EventArgs]
        [System.Management.Automation.PSInvocationStateChangedEventArgs]
        $e
    )

    # Ignore initial state change on startup
    if ($e.InvocationStateInfo.State -eq [System.Management.Automation.PSInvocationState]::Running)
    {
        return
    }

    Write-Host $sender.Message
    Write-Host "Event Fired!"
    Write-Host ("Invocation State: {0}" -f $e.InvocationStateInfo.State)

    # Use the NoteProperty references attached to the Powershell object by Add-Member
    [void]$sender.EndInvoke($sender.AsyncResult)
    $sender.Dispose()

    #
    # You can unregister the event from within the event handler, but you
    # shouldn't do so if you plan on recycling/restarting the background
    # powershell instance.
    #
    # Unregister the event subscription
    Unregister-Event -SourceIdentifier $sender.EventSubscriber.Name
}




$ps = [PowerShell]::Create()
$rs = [RunspaceFactory]::CreateRunspace()
$rs.Open()
$ps.Runspace = $rs
$ps.AddScript( {
    #Get-Service
    Get-Process
    Start-Sleep -Seconds 2
} )

#
# Subscribe to the Powershell state changed event. Attach the registration object
# to the Powershell object for future reference.
#
Add-Member -InputObject $ps -MemberType NoteProperty -Name EventSubscriber -Value (
    Register-ObjectEvent -InputObject $ps -EventName InvocationStateChanged -Action $asyncCallback)

<#
 # This call structure is unnecessary as you aren't using the InvocationSettings
 #
 # $psis = New-Object Management.Automation.PSInvocationSettings
 # $aResult = $ps.BeginInvoke($psdcInputs, $psdcOutputs, $psis, $asyncCallback, $ps)
 #>

Add-Member -InputObject $ps -MemberType NoteProperty -Name Message -Value (
    "Hello World! It's Me {0}" -f $ps.EventSubscriber.Name)

$psdcInputs = New-Object Management.Automation.PSDataCollection[String]
$psdcInputs.Complete()
$psdcOutputs = New-Object Management.Automation.PSDataCollection[Object]

Add-Member -InputObject $ps -MemberType NoteProperty -Name AsyncResult -Value (
    $ps.BeginInvoke($psdcInputs, $psdcOutputs))

