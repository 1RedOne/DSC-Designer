$inputXML = @"
<Window x:Class="FoxDeployDSC_Designer.AutoLoadingDev"
        xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        xmlns:d="http://schemas.microsoft.com/expression/blend/2008"
        xmlns:mc="http://schemas.openxmlformats.org/markup-compatibility/2006"
        xmlns:local="clr-namespace:FoxDeployDSC_Designer"
        mc:Ignorable="d"
        Title="AutoLoadingDev" Height="403.597" Width="371.531">
    <Grid>
        <TabControl x:Name="tabControl" HorizontalAlignment="Left" Height="300" VerticalAlignment="Top" Width="350">
            <TabItem Header="TabItem">
                <Grid Background="#FFE5E5E5">
                    <Grid.ColumnDefinitions>
                        <ColumnDefinition Width="1*" MaxWidth="240" Name="ww"/>
                        <ColumnDefinition Width="2*"  />
                    </Grid.ColumnDefinitions>
                    <StackPanel Name="ElementNames" Background="White">

                    </StackPanel>

                    <StackPanel Grid.Column="1" Name="Elements">
                    </StackPanel>
                </Grid>
            </TabItem>
            <TabItem Header="TabItem" Margin="0">
                <Grid Background="#FFE5E5E5"/>
            </TabItem>
        </TabControl>
        <Button x:Name="button" Content="Load Resource" HorizontalAlignment="Left" Margin="25,314,0,0" VerticalAlignment="Top" Width="105"/>
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

        #Get-DscResource         

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
                    
                    <#
                    $text = New-Object System.Windows.Controls.TextBox
                    $text.AcceptsReturn = $true
                    #$text.Text = ((Get-DscResource $this.Name -Syntax).Split("`n") -join "`n")
                    $text.FontFamily = 'Consolas'
                    $text.Add_TextChanged({
                        $WPFDSCBox.Text = @"
configuration $($WpfconfName.Text) { 
    $($WPFtabControl.Items.Content.Text)
}
"@
                        })
                    $tab.Content =  $text

                    $WPFtabControl.AddChild($tab)#>
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
    $WPFbutton.Add_Click({
        
        $fields = (Get-DscResource User -Syntax).Split("`n")[2..(($sampleSyntax.Split("`n").length)-3)] | ConvertFrom-StringData

        foreach ($field in $fields){
            
            $name = $field.Keys[0] 
            "trying to write $name" >> c:\temp\Gui.log 
            
            if ($name -like "``[*"){$name = $name -replace '\['}
            if ($name -like "Ensure*"){"$name is our special absent/present and should be a radio" >> c:\temp\Gui.log 
            
                     $label =  New-Object System.Windows.Controls.Checkbox
                    $label.Name = "$($name)_Label"
                    $label.Content = "$name"
                    $WPFElementNames.AddChild($label)

                    $label =  New-Object System.Windows.Controls.Label
                    $label.Name = "User$($name)_Label"
                    $label.Content = "Ensure Absent or Present"
                    $WPFElements.AddChild($label)

                   
                    continue
                    }
            if ($field.Values[0] -like "*string*"){"$name should render as a textbox for strings">> c:\temp\Gui.log 
                    $label =  New-Object System.Windows.Controls.Label
                    $label.Name = "User$($name)_Label"
                    $label.Content = "$name"
                    $WPFElementNames.AddChild($label)
                    
                    $text =  New-Object System.Windows.Controls.TextBox
                    $t = New-Object System.Windows.Thickness
                    $t.Bottom = 4
                    $text.Margin= $t 
                    $text.Name = "User$($name)_textinput"
                    
                    
                    $WPFElements.AddChild($text)
                    
                    continue
                }
            if ($field.Values[0] -like "*bool*")  {"$name should render as a checkbox true/false">> c:\temp\Gui.log 
                                       
                    $label =  New-Object System.Windows.Controls.Checkbox
                    $label.Name = "$($name)_Label"
                    $label.Content = "$name"
                    $WPFElements.AddChild($label)
            
            }

        }



        })
    
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
         
    $FolderDialog.ShowDialog() | Out-Null
                
    $outDir = $FolderDialog.SelectedPath

    & $WpfconfName.Text -OutPutPath $outDir
       
    [System.Windows.Forms.MessageBox]::Show("DSC Resource Created at $outDir",'DSC Designer')
    })

    #endregion 

 
 $Form.ShowDialog() | out-null
