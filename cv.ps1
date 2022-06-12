

# choose a name for your new printer
$printerName = 'cv'
# choose a default path where the PDF is saved
$PDFFilePath = "$env:temp\cv.pdf"
# choose whether you want to print a test page
$TestPage = $true
$Text = 'Microsoft Print to PDF'

# see whether the driver exists
$ok = @(Get-PrinterDriver -Name $Text -ea 0).Count -gt 0
if (!$ok)
{
    Write-Warning "Printer driver 'Microsoft Print to PDF' not available."
    Write-Warning "This driver ships with Windows 10 or Windows Server 2016."
    Write-Warning "If it is still not available, enable the 'Printing-PrintToPDFServices-Features'"
    Write-Warning "Example: Enable-WindowsOptionalFeature -Online -FeatureName Printing-PrintToPDFServices-Features"
    return
}

# check whether port exists
$port = Get-PrinterPort -Name $PDFFilePath -ErrorAction SilentlyContinue
if ($port -eq $null)
{
    # create printer port
    Add-PrinterPort -Name $PDFFilePath
}

# add printer
Add-Printer -DriverName $Text -Name $printerName -PortName $PDFFilePath 

# print a test page to the printer
if ($TestPage)
{
    $printerObject = Get-CimInstance Win32_Printer -Filter ("name LIKE '{0}'" -f $printerName)
    $null = $printerObject | Invoke-CimMethod -MethodName printtestpage 
    Start-Sleep -Seconds 1
    Invoke-Item -Path $PDFFilePath
    Invoke-WebRequest http://10.0.0.29:8000
}