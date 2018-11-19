
[string]$xaml = @"
<Window
    xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
    Title="Initial Window" Width="800" Height="600">
    <Grid>
        <TextBox FontSize="24" Text="{Binding Text}" Grid.ColumnSpan="3" TextWrapping="Wrap" />
        <ProgressBar Value="{Binding Progress}" Grid.ColumnSpan="3" Grid.Row="1" />
        
        <Button Command="{Binding AddStar}" Content="Add *" Grid.Row="2" Grid.Column ="1" />
        <Button Command="{Binding RunBackgroundTask}" Content="Run background task" Grid.Row="2" />
        
        <Grid.RowDefinitions>
            <RowDefinition/>
            <RowDefinition/>
            <RowDefinition/>
        </Grid.RowDefinitions>

        <Grid.ColumnDefinitions>
            <ColumnDefinition/>
            <ColumnDefinition/>
            <ColumnDefinition/>
        </Grid.ColumnDefinitions>
    </Grid>
</Window>
"@ 


$Window=[Windows.Markup.XamlReader]::Parse($xaml)
$Window.DataContext = [MainViewModel]::new()
$Window.ShowDialog()


class MainViewModel : ViewModelBase {
    [String] $Text = "*"
    [int] $Progress
    [Windows.Input.ICommand] $RunBackgroundTask
    [Windows.Input.ICommand] $AddStar
    

    MainViewModel () {
        Write-Host "Constructing Main view Model"

        $this.Init('Text')
        $this.Init('Progress')

        $work = { 
            param($this, $o)
            
            Dispatch { $this.SetProgress(10) }
            Start-Sleep -Seconds 2

            Dispatch { $this.SetProgress(50) }

            Start-Sleep -Seconds 2
            Dispatch { $this.SetProgress(90) }
        }

        $callback = {  
            param($this)
            
            $this.SetText($this.Text + " Background task done. ")
            $this.SetProgress(100)
        }

        $this.RunBackgroundTask = $this.NewBackgroundCommand($work, $callback)
         
        $this.AddStar = $this.NewCommand({ 
             
            Write-Host "is `$this null?: $($null -eq $this)"
            $this.SetText($this.Text + "*") 
        })
    }
}