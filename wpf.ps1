Add-Type -AssemblyName PresentationFramework
Add-Type -Path  "$PSScriptRoot\WpfInPowerShell\Toolkit\bin\Debug\Toolkit.dll"


[WpfToolkit.ViewModelBase]::InvokeCommand = $ExecutionContext.InvokeCommand
[WpfToolkit.ViewModelBase]::InitScript = {
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

    $scriptRoot = $PSScriptRoot
    {
        param($this, $o)
        function log ($string) {
            $string | Out-File -FilePath "$PSScriptRoot\log.txt" -Append
        }
        try {
            log "Invoking background task"
            log "`$this: $($this | Out-String)"
            log "`$o: $($o | Out-String)"
            log "`$callback: { $($callback | Out-String) }"

            # store view model into hashtable so we can access 
            # it in the target runspace

            # also store the callback that we will invoke via
            # dispatcher when the main work is done
            $syncHash = [hashtable]::Synchronized(@{ 
                This = $this
                Work = $work
                Object = $o
                CallBack = $callback
                Root = $scriptRoot
             })

            $psCmd = [powershell]::Create()
            $newRunspace = [RunspaceFactory]::CreateRunspace()
            $newRunspace.Open()
            
            $newRunspace.SessionStateProxy.SetVariable('syncHash', $syncHash) 
            $psCmd.Runspace = $newRunspace

            $sb = {
                $o = $syncHash.Object
                $this = $syncHash.This
                $root = $syncHash.Root

                function log ($string) {
                    $string | Out-File -FilePath "$root\log.txt" -Append
                }
                # unbind those scriptblocks otherwise they would get bound to the 
                # original scope and block the execution
                $work = [ScriptBlock]::Create($syncHash.Work)
                $callback = [ScriptBlock]::Create($syncHash.Callback)
            
                # invoke the main work
                try {
                    $functionsToDefine = @{
                        Log = {
                            param($string)
                            $string | Out-File -FilePath "$root\log.txt" -Append
                        }
                        Dispatch = {
                            param($ScriptBlock) 
                            [System.Windows.Threading.Dispatcher]::CurrentDispatcher.Invoke($ScriptBlock)
                        }
                    }
                    $variablesToDefine = [Collections.Generic.List[psvariable]]@()
                    $variablesToDefine.Add((Get-Variable "Root"))
                    $arguments = [Object[]]@($this, $o)

                    $output = $work.InvokeWithContext($functionsToDefine, $variablesToDefine, $arguments)
                }
                catch {
                    log "Invoking work failed with error $($error | Out-String)"
                }
                
                try {  
                    [System.Windows.Threading.Dispatcher]::CurrentDispatcher.Invoke({
                        &$callback $syncHash.This $output
                    })
                }
                catch {
                    log "Invoking callback failed with error $($error | Out-String)"
                }   
            }.GetNewClosure()
        
            $psCmd.AddScript($sb)
            $psCmd.BeginInvoke()
        }
        catch {
            log "Invoking background task failed with error $($error | Out-String)"
        }
    }.GetNewClosure()
}