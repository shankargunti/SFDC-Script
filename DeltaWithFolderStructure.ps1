Param (
[String]$PrevCommit
)
#Get latest commit id from the TFS-git
$gitLatestCommit=git rev-parse HEAD
write-host $gitLatestCommit


#Copy file from source to destination
function Copy-New-Item {
	$SourceFilePath =$args[0]
	$DestinationFilePath =$args[1]
	
	if( -not (Test-Path $DestinationFilePath)) {
		New-Item -ItemType File -Path $DestinationFilePath -Force
	}
	Copy-Item -Verbose -Path $SourceFilePath -Destination $DestinationFilePath -Force
	}

	#write newly checked-in file names between the commits to a text file
	git diff --name-only $gitLatestCommit $PrevCommit --relative > lastcommitchanges.txt
	
	#source code path from TFS
	$path = $PSScriptRoot 
	write-output "`n" | out-file lastcommitchanges.txt -append


	#source files
	$s1=@()
	$Files =Get-Content -path "$path\lastcommitchanges.txt" #Give the file path which has Github's latest file list
	write-host $Files

	for($i2=0;$i2 -lt $Files.Length;$i2++)
	{
		$s1+=$path+"\"+$Files[$i2].Replace("/","\")    #source path
		#Add Source (Git master branch) reference base path instead of "C:\CICD\"
	}

	#Delta files
	$s11=@()
	for($i2=0;$i2 -lt $Files.Length;$i2++)
	{
		$s11+=$path+"\Delta\"+$Files[$i2].Replace("/","\") #Delta path #Give the Delta drive Path instead of "C:\Devopp\Delta"
	}
	$s2=$s1.Count
	$s2.GetType()
	#all the child items Under src
	$master=Get-ChildItem $path"\src" -recurse
	#iterate through the src/*
	foreach($m in $master)
	{
		#copy all the files listed in lastcommitchanges file from Source to Delta
		for($i2=0;$i2 -lt $s1.Length; $i2 ++)
		{
			if($m.fullname -Contains $s1[$i2])
			{
				$folder=$m.fullname
				Copy-New-Item $folder $s11[$i2]
			}
			else 
			{
			#write-host "Files do not exist in latest build: $s1[$i2]`n"
			}
			
		}
		####Copy META File into Delta ####
		for($i2=0;$i2 -lt $s1.Length;$i2++)
		{
			if($m.fullname -Contains $s1[$i2]+"-meta.xml")
			{
				$folder=$m.fullname
				#meta file name
				$s12=$s11[$i2]+"-meta.xml"
				Copy-New-Item $folder $s12
			}
			else 
			{
					#write-host "Files do not exist in latest build: $s1[$i2]" 
			}
		}
	}
	#Copy class test and meta files into Delta 
	#Get the folder name under src 
	$lastword =(($m.fullname).ToString().split("\"))[-2]
	#Iterate through classes folder for Test Classes(suffix as Test)
If( ($lastword -match "classes") )	
{
	for($i2=0;$i2 -lt $s1.Length ;$i2++)
	{
		if($m.fullname -Contains $s1[$i2].Replace(".cls","")+"Test.cls")
		{
			$folder =$m.fullname
			#testclasss file name (Suffix as Test)
			$s12=$s11[$i2].Replace(".cls","")+"Test.cls"
			Copy-New-Item $folder $s12
	 
		}
		else 
		{
			#write-host "Files do not exist in latest build: $s1[$i2]"
		}
}
for($i2=0;$i2 -lt $s1.length; $i2++)
{
	if($m.fullname -Contains $s1[$i2].Replace(".cls","")+"Test.cls-meta.xml")
	{
		$folder=$m.fullname
		#test class meta file name(suffix as test)
		$s12=$s11[$i2].Replace(".cls"," ")+"Test.cls-meta.xml"
		Copy-New-Item $folder $s12
	}
	else
	{
	##write-host "Files do not exist in latest build: $s1[$i2]"
	}
}

#Copy Testclass and meta file into Delta(Prefix as Test)

for($i2=0;$i2 -lt $s1.Length;$i2++)
{
	#Get the class file and meta
	$lastword=($s1[$i2].ToString().split("\"))[-1]
	$file3=($s1[$i2].tostring()).trimend("$lastword")
	$file3=$file3+"Test"+$lastword
	$file33=$file3+"-meta.xml"
	if($m.fullname -Contains $file3 -or $m.fullname -Contains $file33)
	{
		$folder = $m.fullname
		$s12=$s11[$i2]
		$lastword1=($s12.ToString().split("\"))[-1]
		$file31=($s12.tostring()).trimend($lastword1)
		$file31=$file31+"Test"+$lastword1
		$file34=$file31+"-meta.xml"
		if($m.fullname -Contains $file3)
		{
			Copy-New-Item $folder $file31
		}
		if($m.fullname -Contains $file33)
		{
			Copy-New-Item $folder $file34
		}
	}
}
}
}
