Add-Type -Path  "C:\projects\WPwshF\WpfInPowerShell\Toolkit\bin\Debug\Toolkit.dll"

[WpfToolkit.ViewModelBase]::InvokeCommand = $ExecutionContext.InvokeCommand
[WpfToolkit.ViewModelBase]::InitScript = {
    # could also be implemented as Action<> that we set directly
    # from powershell
    param($self, $PropertyName)
    $self | 
        Add-Member -MemberType ScriptMethod -Name "Set$PropertyName" -Value ([ScriptBlock]::Create("
            param(`$value)
            `$this.'$PropertyName' = `$value
            `$this.OnPropertyChanged('$PropertyName')
        ")) -PassThru | 
        Add-Member -MemberType ScriptMethod -Name "Get$PropertyName" -Value ([ScriptBlock]::Create("
            `$this.'$PropertyName'
        "))
}

[WpfToolkit.ViewModelBase]::BackgroundWorkScript = {
    # gets invoked when a background command is called
    # user passes two scriptblocks
    param ($work, $callback)

    [scriptblock]::Create("
        param(`$this, `$o)
        `$callback = { $callback }

        # store view model into hashtable so we can access 
        # it in the target runspace

        # also store the callback that we will invoke via
        # dispatcher when the main work is down
        `$syncHash = [hashtable]::Synchronized(@{ 
            This = `$this
            Object = `$o
            CallBack = `$callback
         })

        `$psCmd = [powershell]::Create()
        `$newRunspace = [RunspaceFactory]::CreateRunspace()
        `$newRunspace.Open()
            
        `Write-Host 'o is populated: ' (`$null -ne `$syncHash)
        `$newRunspace.SessionStateProxy.SetVariable('syncHash',  `$syncHash) 
        `$psCmd.Runspace = `$newRunspace

        `$sb = [scriptblock]::Create({
            `$this = `$syncHash.This
            `$work = { $work }
            
            function Dispatch (`$ScriptBlock) {
                `[System.Windows.Threading.Dispatcher]::CurrentDispatcher.Invoke(`$ScriptBlock)
            }

            # invoke the main work
            &`$work `$this `$o
            [System.Windows.Threading.Dispatcher]::CurrentDispatcher.Invoke({ 
                function w (`$string) {
                    `$string | Out-File -FilePath 'c:\temp\put.txt' -Append
                }
                `$callback = { $callback }
                w ('callback `$(`$callback)')
                &`$callback `$syncHash.This 
            })
        })

        `$psCmd.AddScript(`$sb)
        `$psCmd.BeginInvoke()")
}