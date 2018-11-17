Import-Module "C:\projects\WPwshF\ObservableConcurrentQueue.dll"

$queue = [System.Collections.Concurrent.ObservableConcurrentQueue[object]]::new()
$e = Register-ObjectEvent -InputObject $queue -EventName ContentChanged -Action { Write-Host "new content" }

$psCmd = [powershell]::Create()
$syncHash = [hashtable]::Synchronized(@{})
$newRunspace =[runspacefactory]::CreateRunspace()      
$newRunspace.Open()
$newRunspace.SessionStateProxy.SetVariable("queue",$queue) 
$psCmd.Runspace = $newRunspace
$psCmd.AddScript({
    $counter = 0
    While ($true) {
        $o = { Write-Host  }
        Start-Sleep -Seconds 1
        "$(Get-Date) Adding $()" | Out-File -FilePath "c:\temp\put.txt" -Append
        $queue.Enqueue(++$c)
        "$(Get-Date) Added" | Out-File -FilePath "c:\temp\put.txt" -Append
    }
})
$data = $psCmd.BeginInvoke()


# $psCmd.Stop()