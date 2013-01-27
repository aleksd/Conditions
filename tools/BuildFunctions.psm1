function Replace-Text
{
	param
	(
        $fileInfo,
		[string]$old,
        [string]$new
	)
	(Get-Content $fileInfo.FullName) | % {$_ -replace $old, $new} | Set-Content -path $fileInfo.FullName
}