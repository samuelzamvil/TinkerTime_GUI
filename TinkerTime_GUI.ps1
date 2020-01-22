<#
.NAME
    TinkerTime
#>

function tinkerTime {
    # Sets system time based on GUI input
    param(
        [Parameter(Mandatory)]
        [string]$TimeModifierType,
        [Parameter(Mandatory)]
        [int]$TimeModifierInt
    )
    Set-Date (Get-Date).("Add$TimeModifierType")($TimeModifierInt)
}
function Reset-Date {
    # Modifies registry settings to auto time, runs update, and resets time setting to not sync
    Set-ItemProperty -Path HKLM:\SYSTEM\CurrentControlSet\Services\W32Time\Parameters -Name "Type" -Value "NTP"
    set-service w32time -StartupType auto
    Start-Service W32Time
    Start-Sleep 1
    $Win32tmTimedOut = $false
    Start-Process W32tm -ArgumentList "/resync", "/force"
    Wait-Process -Name w32tm -Timeout 30 -ErrorVariable Win32tmTimedOut
    if ($Win32tmTimedOut){
        Stop-Process -Name w32tm
        [System.Windows.Forms.MessageBox]::Show("Clock reset has timed out.","Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
    }
    Set-ItemProperty -Path HKLM:\SYSTEM\CurrentControlSet\Services\W32Time\Parameters -Name "Type" -Value "NoSync"
}

Add-Type -AssemblyName System.Windows.Forms
[System.Windows.Forms.Application]::EnableVisualStyles()

$ApplicationIcon = [System.Drawing.Icon]::ExtractAssociatedIcon((Join-Path $pwd "\TinkerTime.exe"))

$Form                            = New-Object system.Windows.Forms.Form
$Form.ClientSize                 = '400,400'
$Form.text                       = "TinkerTime GUI"
$Form.TopMost                    = $false
$Form.Icon                       = $ApplicationIcon
$Form.FormBorderStyle = [system.Windows.Forms.FormBorderStyle]::FixedDialog

$ModifyTimeTime_Button           = New-Object system.Windows.Forms.Button
$ModifyTimeTime_Button.text      = "Modify Time"
$ModifyTimeTime_Button.width     = 368
$ModifyTimeTime_Button.height    = 123
$ModifyTimeTime_Button.location  = New-Object System.Drawing.Point(14,88)
$ModifyTimeTime_Button.Font      = 'Microsoft Sans Serif,10'

$ResyncTime_Button               = New-Object system.Windows.Forms.Button
$ResyncTime_Button.text          = "Resync Time"
$ResyncTime_Button.width         = 368
$ResyncTime_Button.height        = 123
$ResyncTime_Button.location      = New-Object System.Drawing.Point(16,233)
$ResyncTime_Button.Font          = 'Microsoft Sans Serif,10'

$TimeInteger_TextBox            = New-Object system.Windows.Forms.TextBox
$TimeInteger_TextBox.multiline  = $false
$TimeInteger_TextBox.text       = 2
$TimeInteger_TextBox.width      = 57
$TimeInteger_TextBox.height     = 10
$TimeInteger_TextBox.location   = New-Object System.Drawing.Point(301,24)
$TimeInteger_TextBox.Font       = 'Microsoft Sans Serif,10'

$TimeModifier_Label              = New-Object system.Windows.Forms.Label
$TimeModifier_Label.text         = "Enter Time Modifier"
$TimeModifier_Label.AutoSize     = $true
$TimeModifier_Label.width        = 47
$TimeModifier_Label.height       = 10
$TimeModifier_Label.location     = New-Object System.Drawing.Point(16,24)
$TimeModifier_Label.Font         = 'Microsoft Sans Serif,10'

$BadInput_ErrorProvider          = New-Object system.Windows.Forms.ErrorProvider
$BadInput_ErrorProvider.Icon     = [System.Drawing.SystemIcons]::Error
$BadInput_ErrorProvider.SetIconPadding($TimeInteger_TextBox, 6)
$BadInput_ErrorProvider.SetIconAlignment($TimeInteger_TextBox, [System.Windows.Forms.ErrorIconAlignment]::MiddleRight)
$BadInput_ErrorProvider.BlinkStyle = [System.Windows.Forms.ErrorBlinkStyle]::NeverBlink

$SelectTime_ListValues = @('Seconds', 'Milliseconds', 'Minutes', 'Hours', 'Days')

$SelectTimeModifierType_ListBox              = New-Object System.Windows.Forms.ComboBox
$SelectTimeModifierType_ListBox.width        = 121
$SelectTimeModifierType_ListBox.height       = 10
$SelectTimeModifierType_ListBox.location     = New-Object System.Drawing.Point(163,24)
$SelectTimeModifierType_ListBox.BeginUpdate()
$SelectTime_ListValues | ForEach-Object { $SelectTimeModifierType_ListBox.Items.Add($_) } >$null
$SelectTimeModifierType_ListBox.EndUpdate()
$SelectTimeModifierType_ListBox.DropDownStyle = [System.Windows.Forms.ComboBoxStyle]::DropDownList
$SelectTimeModifierType_ListBox.SelectedIndex = 0

$Form.controls.AddRange(@($ModifyTimeTime_Button,$ResyncTime_Button,$TimeInteger_TextBox,$TimeModifier_Label,$SelectTimeModifierType_ListBox))


$ModifyTimeTime_Button.Add_Click({
    tinkerTime $SelectTimeModifierType_ListBox.SelectedItem $TimeInteger_TextBox.Text
 })

 $ResyncTime_Button.Add_Click({ 
    Reset-Date
 })

 # Provide error icon on invalid input
 $TimeInteger_TextBox.Add_TextChanged({ 
     if (-not(($TimeInteger_TextBox.Text -as [int]) -is [System.Int32])){
        $BadInput_ErrorProvider.SetError($TimeInteger_TextBox, 'Please Enter a number.')
     }
     else {
        $BadInput_ErrorProvider.Clear()
     }
  })

[void]$Form.ShowDialog()
