## Problem

WPF is super awkward in PowerShell, it would be nice to be able to use powershell classes to work with it.

- Use commands to run code on Model (Command -> Model) - ✔ Done
- Notify UI when property is set. (Model -> UI) - ✔ Done
- Do lightweight work in the command. - ✔ Done
- Do work on background on command.  -  ✔ Done

## Todo:

- multiple background tasks at the same time (seemed to work fine)
- moving additional data from the foreground to the background (a hashtable to splat over $work?)
- moving additional data from the background back to the foreground (collect output from $work and add $output to the callback)

- leveraging CanExecute
- command parameters

- Notify model when property is set. ( UI -> Model) -> probably via custom binding that notifies automatically - is it even needed?
- pattern for cooperative cancellation
- simple stuff should still stay simple!
- not too many conventions!

## Demo

In the demo I have a view written in XAML and a viewModel written as a PowerShell class inheriting from my helper base class.

I am pressing the button that adds `*` to the text to show that the UI is responsive while a long running task is processed in the background. The task in background repeatedly sleeps for 2 seconds and updates the progress via dispatcher. At the end it executes a bigger script via dispatcher to make updating the ViewModel after the task is easier.

![Demo](doc/mvvmpowershell.gif?raw=true)

```powershell
# this is the view model, view model is a programmatical
# representation of the view, when we manipulated the viewodel
# the view should update automatically to present it
class MainViewModel : WpfToolkit.ViewModelBase {
    # those are properties of the view model
    # those properties hold data that we show in the
    # view
    [String] $Text = "*"
    [int] $Progress

    # those are commands, those commands
    # can be triggered by the view to do some action
    [Windows.Input.ICommand] $RunBackgroundTask
    [Windows.Input.ICommand] $AddStar


    MainViewModel () {
        # Init makes up for lack of getters and
        # setters on properties by adding
        # Get* and Set* methods on the view model
        # eg .SetProgress(<value>)
        $this.Init('Text')
        $this.Init('Progress')

        # this scriptblock represents work to be
        # done on background, the work runs in a different
        # runspace, but we make it look very "local"
        # the runspace defines Dispatch function that can
        # be used to Invoke on the default Dispatcher
        $work = {
            param($this, $o)

            Dispatch { $this.SetProgress(10) }
            # running this on the main thread would
            # make the UI unresponsive
            Start-Sleep -Seconds 2

            Dispatch { $this.SetProgress(50) }

            Start-Sleep -Seconds 2
            Dispatch { $this.SetProgress(90) }
        }

        # this whole script will be invoked
        # via dispatcher after $work is done
        $callback = {  
            param($this)


            $this.SetText($this.Text + " Background task done. ")
            $this.SetProgress(100)
        }

        # setting up the commands via helper
        # methods on the base view model.
        $this.RunBackgroundTask = $this.NewBackgroundCommand($work, $callback)
        $this.AddStar = $this.NewCommand({ $this.SetText($this.Text + "*") })
    }
}

# this is the view written in XAML, notice that there are no
# explicit names anywhere, instead of looking up components in the
# underlying code and populating them on update, we are using the
# binding capabilities that are native to WPF. The binding automatically
# synchronizes our ViewModel to the View (and vice versa if we change)
# data in the view (eg. we write something into the text box).

# we also bind the Buttons to commands, instead of looking up the
# the button by name and adding click event handlers.
[string]$xaml = @"
<Window
    xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
    Title="Initial Window" Width="800" Height="600">
    <Grid>
        <TextBox FontSize="24" Text="{Binding Text}"
            Grid.ColumnSpan="3" />
        <ProgressBar Value="{Binding Progress}"
            Grid.ColumnSpan="3" Grid.Row="1" />

        <Button Command="{Binding AddStar}" Content="Add *"
            Grid.Row="2" Grid.Column ="1" />
        <Button Command="{Binding RunBackgroundTask}"
            Content="Run background task" Grid.Row="2" />

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

# here we simply parse the Xaml string
# (make sure the $xaml variable is typed explicitly as String
# otherwise you get errors)
$Window=[Windows.Markup.XamlReader]::Parse($xaml)

# we instantiate the view model and set it as DataContext of the window
$Window.DataContext = [MainViewModel]::new()

# then finally we show the window
$Window.ShowDialog()
```
