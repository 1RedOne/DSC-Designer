$inputXML = @"
<Window x:Class="WpfTutorialSamples.Panels.GridColRowSpan"
        xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
       Title="DSC Designer" Width="525" Height="600">
    <Grid>
        <Grid.ColumnDefinitions>
            <ColumnDefinition Width="1*" MaxWidth="240"/>
            <ColumnDefinition Width="2*" />
        </Grid.ColumnDefinitions>
        <Grid.RowDefinitions>
            <RowDefinition Height="5*" MinHeight="150" />
            <RowDefinition Name="GridSplitterRow" Height="Auto"/>
            <RowDefinition Height="2*" MaxHeight="30" MinHeight="30"/>
            <RowDefinition Name="GridSplitterRow2" Height="Auto"/>
            <RowDefinition Height ="Auto" MaxHeight="80"/>
            <RowDefinition Name="GridSplitterRow3" Height="Auto"/>
            <RowDefinition Height ="Auto" MaxHeight="30"/>
        </Grid.RowDefinitions>
        <GroupBox x:Name="groupBox" Header="Resources" HorizontalAlignment="Left" VerticalAlignment="Top"  Margin="0,0,0,5">
            <WrapPanel x:Name="Resources" HorizontalAlignment="Left" Margin="0,0,0,0" VerticalAlignment="Top" >
                <WrapPanel.Background>
                    <LinearGradientBrush EndPoint="0.5,1" StartPoint="0.5,0">
                        <GradientStop Color="#FFBD5B04" Offset="0"/>
                        <GradientStop Color="#FF1AD3E5" Offset="1"/>
                        <GradientStop Color="White" Offset="0.505"/>
                    </LinearGradientBrush>
                </WrapPanel.Background>
                <Button Name="Clear" Content="Remove All" Width="137" />
            </WrapPanel>
        </GroupBox>
        <TabControl x:Name="tabControl" Grid.Column="1" >
        </TabControl>
        <GridSplitter Grid.Row="2" Height="5">
            <GridSplitter.Background>
                <SolidColorBrush Color="{DynamicResource {x:Static SystemColors.HighlightColorKey}}"/>
            </GridSplitter.Background>
        </GridSplitter>
        <DockPanel Grid.ColumnSpan="2" Grid.Row="2">
            <Label Content="Configuration name"/>
            <TextBox Name="ConfName" Text="SampleConfig" VerticalContentAlignment="Center" Width='180'/>
            <Button Name="Export" Content="Export Config"/>
            <Button Name="Clearv2" Content="Clear All"/>
        </DockPanel>
        <DockPanel Grid.ColumnSpan="2" Grid.Row="3">
            <ScrollViewer Height="239" VerticalScrollBarVisibility="Auto">
                <TextBox x:Name="DSCBox" AcceptsReturn="True" TextWrapping="Wrap" Text="Compiled Resource will appear here"/>
            </ScrollViewer>
        </DockPanel>
        <DockPanel X:Name="StatusBar" Grid.ColumnSpan="2" Grid.Row="4">
            <StatusBar DockPanel.Dock="Bottom">
                <StatusBarItem>
                    <TextBlock Name="StatusText" Text="Ready"/>
                </StatusBarItem>
            </StatusBar>
        </DockPanel>
    </Grid>
</Window>

"@ 

Function Update-Window {
[cmdletBinding()]
        Param (
            $Control,
            $Property,
            $Value,
            [switch]$AppendContent
        )
 
        # This is kind of a hack, there may be a better way to do this
        If ($Property -eq "Close") {
            $syncHash.Window.Dispatcher.invoke([action]{$syncHash.Window.Close()},"Normal")
            Return
        }
 
        # This updates the control based on the parameters passed to the function
        $form.Dispatcher.Invoke([action]{
            # This bit is only really meaningful for the TextBox control, which might be useful for logging progress steps
            If ($PSBoundParameters['AppendContent']) {
                $Control.AppendText($Value)
            } Else {
                $Control.$Property = $Value
            }
        }, "Normal")
    }    

$inputXML = $inputXML -replace 'mc:Ignorable="d"','' -replace "x:N",'N' -replace '^<Win.*', '<Window'
[void][System.Reflection.Assembly]::LoadWithPartialName('presentationframework')
[xml]$XAML = $inputXML
#Read XAML
 
    $reader=(New-Object System.Xml.XmlNodeReader $xaml) 
  try{$Form=[Windows.Markup.XamlReader]::Load( $reader )}
catch [System.Management.Automation.MethodInvocationException] {
    Write-Warning "We ran into a problem with the XAML code.  Check the syntax for this control..."
    write-host $error[0].Exception.Message -ForegroundColor Red
    if ($error[0].Exception.Message -like "*button*"){
        write-warning "Ensure your &lt;button in the `$inputXML does NOT have a Click=ButtonClick property.  PS can't handle this`n`n`n`n"}
}
catch{#if it broke some other way <span class="wp-smiley wp-emoji wp-emoji-bigsmile" title=":D">:D</span>
    Write-Host "Unable to load Windows.Markup.XamlReader. Double-check syntax and ensure .net is installed."
        }
 
#===========================================================================
# Store Form Objects In PowerShell
#===========================================================================
 
$xaml.SelectNodes("//*[@Name]") | %{Set-Variable -Name "WPF$($_.Name)" -Value $Form.FindName($_.Name)}
 
Function Get-FormVariables{
if ($global:ReadmeDisplay -ne $true){Write-host "If you need to reference this display again, run Get-FormVariables" -ForegroundColor Yellow;$global:ReadmeDisplay=$true}
write-host "Found the following interactable elements from our form" -ForegroundColor Cyan
get-variable WPF*
}
 
Get-FormVariables
 
    #===========================================================================
    # Use this space to add code to the various form elements in your GUI
    #===========================================================================
    
   #retrieve all DSC resources in the background
    $Runspace = [runspacefactory]::CreateRunspace()

    $PowerShell = [PowerShell]::Create()

    $PowerShell.runspace = $Runspace

    $Runspace.Open()

    [void]$PowerShell.AddScript({

        Get-DscResource         

    })

    if ($AsyncObject.IsCompleted -eq ($true)){Write-host "COMPLETED"}
       else {write-host "Waiting for DSC resources to come back";start-sleep -Milliseconds 500}
$AsyncObject = $PowerShell.BeginInvoke()
$Data = $PowerShell.EndInvoke($AsyncObject)

    $resources = $Data                                                             
    
    #region Add checkboxes for each resource
    ForEach ($resource in $resources){
        $newCheckBox = New-Object System.Windows.Controls.CheckBox                                                                                                                                             
            $newCheckBox.Name = $resource.Name
            $newCheckBox.Content = $resource.Name
            $newCheckBox.Background = "White"
            $newCheckBox.Width = '137'
            
            #region add a tab when checkbox clicked
            $newCheckBox.Add_checked({
                    $WPFStatusText.Text = 'Loading resource...'
                    $TabName = $this.Name
                    $tab = New-Object System.Windows.Controls.TabItem
                    $tab.Name = "$($TabName)Tab"
                    $tab.Header = $TabName
                    
                    $text = New-Object System.Windows.Controls.TextBox
                    $text.AcceptsReturn = $true
                    $text.Text = ((Get-DscResource $this.Name -Syntax).Split("`n") -join "`n")
                    $text.FontFamily = 'Consolas'
                    $text.Add_TextChanged({
                        $WPFDSCBox.Text = @"
configuration $($WpfconfName.Text) { 
    $($WPFtabControl.Items.Content.Text)
}
"@
                        })
                    $tab.Content =  $text

                    $WPFtabControl.AddChild($tab)
                    $WPFStatusText.Text = 'Ready...'
                    })

            $newCheckBox.Add_unchecked({
                    $WPFtabControl.Items.Remove(($WPFtabControl.Items | Where Header -eq $this.Name))
                    })
            
        $i = $WPFResources.Children.Add($newCheckBox)
        #endregion add Checkbox 
        
        #needed a small delay to be able to add and then set the active tab
        start-sleep -milliseconds 100
        $WPFtabControl.SelectedIndex = $i - 1

    }
#endregion add checkboxes

    #region event handlers for other buttons
    $WPFClear.Add_Click({
        $WPFResources.Children | ? Name -ne Clear | % {$_.IsChecked = $False}
        $WPFDSCBox.Text= "Compiled Resource will appear here"
    })

    $WPFClearv2.Add_Click({
        $WPFResources.Children | ? Name -ne Clear | % {$_.IsChecked = $False}
        $WPFDSCBox.Text= "Compiled Resource will appear here"
    })

    $WPFExport.Add_Click({
        $form.Dispatcher.Invoke([action]{$WPFStatusText.Text='Creating Configuration...'})
        write-host "Trying to invoke DSC config"
        try {Invoke-Expression $WPFDSCBox.Text -erroraction STOP}
        catch{write-warning 'aw hell nah'}

        $FolderDialog = New-Object System.Windows.Forms.FolderBrowserDialog
         
        if ($FolderDialog.ShowDialog() -eq "OK"){
            $outDir = $FolderDialog.SelectedPath

            & $WpfconfName.Text -OutPutPath $outDir
       
            [System.Windows.Forms.MessageBox]::Show("DSC Resource Created at $outDir",'DSC Designer')
        
        }
    })
    #endregion 

 
 $Form.ShowDialog() | out-null
