class RelayCommand : Windows.Input.ICommand {
    add_CanExecuteChanged([EventHandler] $value) {
       [System.Windows.Input.CommandManager]::add_RequerySuggested($value)
    }

    remove_CanExecuteChanged([EventHandler] $value) {
        [System.Windows.Input.CommandManager]::remove_RequerySuggested($value)
    }

    hidden [ScriptBlock] $_execute
    hidden [ScriptBlock] $_canExecute
    hidden [object] $_self

    RelayCommand(
        [object] $self
        # [object] $self, [object] $commandParameter -> [void]
        ,[ScriptBlock] $execute
        # [object] $this, $commandParameter -> [bool]
        ,[ScriptBlock] $canExecute) {
        if ($null -eq $self) {
            throw "The reference to the parent was not set, please provide it by passing `$this to the `$self parameter."
        }
        $this._self = $self

        $e = $execute.ToString().Trim()
        if ([string]::IsNullOrWhiteSpace($e))
        {
            throw "Execute script is `$null or whitespace, please provide a valid ScriptBlock."
        }
        $this._execute = [ScriptBlock]::Create("param(`$this, `$parameter)`n&{`n$e`n} `$this `$parameter")
        
        Write-Debug -Message "Execute script $($this._execute)"
        $ce = $canExecute.ToString().Trim()
        if ([string]::IsNullOrWhiteSpace($ce))
        {
            Write-Debug -Message "Can execute script is empty"
            $this._canExecute = $null
        }
        else {
            $this._canExecute = [ScriptBlock]::Create("param(`$this, `$parameter)`n&{`n$ce`n} `$this `$parameter")
        }
    }
    
    [bool] CanExecute([object] $parameter) {
        if ($null -eq $this._canExecute) {
            Write-Debug -Message "Can execute script is empty so it can execute"
            return $true
        } else {
            [bool] $result = $this._canExecute.Invoke($this._self, $parameter)
            if ($result) {
                Write-Debug -Message "Can execute script was run and can execute"
            }else {
                Write-Debug -Message "Can execute script was run and cannot execute"
            }
            return $result
        }
    }

    [void] Execute([object] $parameter) {
        Write-Debug "Executing script on RelayCommand against $($this._self)"
        try {
            $this._execute.Invoke($this._self, $parameter)
            Write-Debug "Script on RelayCommand executed"
        }catch 
        {
            Write-Error "Error handling execute: $_"
        }

    }
}

class ViewModelBase : ComponentModel.INotifyPropertyChanged {
    hidden [ComponentModel.PropertyChangedEventHandler] $_propertyChanged = {}

    [void] add_PropertyChanged([ComponentModel.PropertyChangedEventHandler] $value){
        $p = $this._propertyChanged
        $this._propertyChanged = [Delegate]::Combine($p, $value)
    }

    [void] remove_PropertyChanged([ComponentModel.PropertyChangedEventHandler] $value){
        $this._propertyChanged = [Delegate]::Remove($this._propertyChanged, $value)
    }

    [void]OnPropertyChanged([string] $propertyName) {
        Write-Host "Notified change of property '$propertyName'."
        $this._propertyChanged.Invoke($this, $propertyName)
    }

    hidden [System.Windows.Threading.DispatcherTimer] $_timer

    [void] Init([string] $propertyName) {
        $setter = [ScriptBlock]::Create("
        param(`$value)
        `$this.'$PropertyName' = `$value
        `$this.OnPropertyChanged('$PropertyName')
        ")

        $getter = [ScriptBlock]::Create("`$this.'$propertyName'")

        $this | Add-Member -MemberType ScriptMethod -Name "Set$propertyName" -Value $setter 
        $this | Add-Member -MemberType ScriptMethod -Name "Get$PropertyName" -Value $getter
    }

    [Windows.Input.ICommand] NewBackgroundCommand (
        # [object] $this, [object] $commandParameter -> [void]
        [ScriptBlock] $work
        # [object] $this -> [void]
        ,[ScriptBlock] $callback
        # # [object] $this, $commandParameter -> [bool]
        # [ScriptBlock]$canExecute = $null
        ) {
        $adapted = [scriptblock]::Create("
        param(`$this, `$parameter)
        `$callback = { $callback }

        # store view model into hashtable so we can access 
        # it in the target runspace

        # also store the callback that we will invoke via
        # dispatcher when the main work is down
        `$syncHash = [hashtable]::Synchronized(@{ 
            This = `$this
            Parameter = `$parameter
            CallBack = `$callback
         })

        `$psCmd = [powershell]::Create()
        `$newRunspace = [RunspaceFactory]::CreateRunspace()
        `$newRunspace.Open()

        `$newRunspace.SessionStateProxy.SetVariable('syncHash',  `$syncHash)
        `$psCmd.Runspace = `$newRunspace

        `$sb = [scriptblock]::Create({
            `$this = `$syncHash.This
            `$parameter = `$syncHash.Parameter
            `$work = { $work }
            
            function Dispatch (`$ScriptBlock) {
               `[System.Windows.Threading.Dispatcher]::CurrentDispatcher.Invoke(`$ScriptBlock)
            }

            # invoke the main work
            &`$work `$this `$parameter
            [System.Windows.Threading.Dispatcher]::CurrentDispatcher.Invoke({ 
                function w (`$string) {
                    Write-Debug `$string
                }
                `$callback = { $callback }
                &`$callback `$synchash.this `$synchash.parameter
            })
        })

        `$psCmd.AddScript(`$sb)
        `$psCmd.BeginInvoke()")

        return [RelayCommand]::new($this, $adapted, {})
    }

    [Windows.Input.ICommand] NewCommand (
        # [object] $this, [object] $commandParameter -> [void]
        [ScriptBlock] $execute 
        # [object] $this, $commandParameter -> [bool]
        #,[ScriptBlock]$canExecute
    ) {
        return [RelayCommand]::new($this, $execute, {})
    }

    ViewModelBase () { 
        Write-Host "ViewModelBase constructed"
        $this._timer = [Windows.Threading.DispatcherTimer]::new('Normal')
        $this._timer.Interval = [TimeSpan]::FromMilliseconds(200) 
        $this._timer.add_Tick({ [System.Windows.Threading.Dispatcher]::CurrentDispatcher.Invoke({ }, 'Render') })

        $this._timer.Start();
    }
}

class ViewModel : ViewModelBase {

    ViewModel () {
        $this.add_PropertyChanged({
            param($sender, $propertyChangedArgs)
            Write-Host ($propertyChangedArgs | out-string) })
    }
    
    [void]Notify(){
        $this.OnPropertyChanged("wooooooo")
    }
}