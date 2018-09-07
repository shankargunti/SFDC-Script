param(
[string]$testLevel
)
write-host $testLevel
write-host ${sf.deployroot}


$Buildxmllocation=""
#Remove-Item "Delta\b*.xml"
write-output "<?xml version=`"1.0`"?>
<project xmlns:sf=`"antlib:com.salesforce`" basedir=`".`" default=`"deploy`" name=`"Sample usage of Salesforce Ant tasks`">
    #<property file=`"build.properties`"/>
     	<property environment=`"env`"/>
     	<taskdef uri=`"antlib:com.salesforce`" resource=`"com/salesforce/antlib.xml`">
	</classpath>
	</taskdef>
	<target name=`"deploy`">
		   <echo message =`"Starting Deployment`"/> | out-file $BuildxmlLocation"build.xml" -append
		   
		   if($testLevel -eq "RunSpecifiedTests")
		   {
		   	write-host "Executes Specified tests"
			if((Test-Path -Path "Delta\src\classes\"))
			{
					
			$TestPath = Get-ChildItem "Delta\src\classes\*test*"
			if((($TestPath).Length -gt 0))
		 	{
		   		"<sf:deploy allowMissingFiles=`"`${sf.allowMissingFiles}`" checkOnly=`"`${sf.checkOnly}`" rollbackOnError=`"`${sf.rollbackOnError}`" deployRoot=`"`${sf.deployRoot}`" serverurl=`"`${sf.serverurl}`" password=`"`${sf.password}`" username=`"`${sf.username}`" testLevel=`"RunSpecifiedTests`" autoUpdatePackage=`"true`">" | out-file $BuildxmlLocation"build.xml" -append
		   	}
		  
		   $sourceFiles=@()
		   $sourceFiles=get-childitem "Delta\src"|?{$_.Attributes -eq "Directory"}
		   $nametag="
		   classes, ApexClass
		   triggers, Apextrigger"
		   $global:nametag1=@{}
		   $nametag1=($nametag.Replace(",","=")-join "`n") | ConvertFrom-StringData
		   $global:hname=@()
           $hname=$nametag1.getenumerator() | select -ExpandProperty Name
           $global:cnt=$hname.Count
           $hvalue=$nametag1.($hname[0])
	   ForEach($src in $sourceFiles)
  
	{
    	if($src.Basename -match ("classes") -or $src.Basename -match "triggers")
    	{
       		 foreach($hsrc in $hname)
        	{
            		if($src.Basename -Contains $hsrc)
            		{
                		if($src.Basename -match ("classes"))
                		{
                    			$file1=Get-ChildItem $src.FullName -File
                		}
                		foreach($file2 in $file1)
                		{
                    			#$s3=$s2.ToString().Split(".")[0]
                    			$file3=[System.Io.Path]::GetFileNameWithoutExtension($file2)
                   			if(($file2.BaseName -like "Test*" -and $file2.Basename -notlike "*-meta*") -or ($file2.BaseName -like "*Test" -and $file2.Basename -notlike "*-meta*"))
		                    {
                		        Write-Output "<runTest>$file3</runTest>" | out-file $Buildxmllocation"build.xml" -append

                    		    }
                    		 elseif(($file2.BaseName -notlike "Test*" -and $file2.fullname -notlike "*-meta*" -and $file2.BaseName -notlike "$file3") -or ($file2.BaseName -notlike "*Test*" -and $file2.fullname -notlike "*-meta*" -and $file2.BaseName -notlike "$file3"))
		                {
                		    Write-Output "Test classes not exist for these classes delta\src\$($src.Basename)\$file3"
                		}
                }
            }
        }
    }
}
Write-Output "</sf:deploy> 
</target> 
</project>" | out-file $Buildxmllocation"build.xml" -append
}
else
{
	"<sf:deploy allowMissingFiles=`"`${sf.allowMissingFiles}`" checkOnly=`"`${sf.checkOnly}`" rollbackOnError=`"`${sf.rollbackOnError}`" deployRoot=`"`${sf.deployRoot}`" serverurl=`"`${sf.serverurl}`" password=`"`${sf.password}`" username=`"`${sf.username}`" autoUpdatePackage=`"true`">" | out-file $BuildxmlLocation"build.xml" -append
	write-output "</sf:deploy> 
</target> 
</project>" | out-file $Buildxmllocation"build.xml" -append
}
}
}
elseif($testLevel -eq "RunLocalTests")
{
	write-host "Executes local tests"
	"<sf:deploy allowMissingFiles=`"`${sf.allowMissingFiles}`" checkOnly=`"`${sf.checkOnly}`" rollbackOnError=`"`${sf.rollbackOnError}`" deployRoot=`"`${sf.deployRoot}`" serverurl=`"`${sf.serverurl}`" password=`"`${sf.password}`" username=`"`${sf.username}`" testLevel=`"RunLocalTests`" autoUpdatePackage=`"true`">" | out-file $BuildxmlLocation"build.xml" -append
	write-output "</sf:deploy> 
</target> 
</project>" | out-file $Buildxmllocation"build.xml" -append
}
elseif($testLevel -eq "RunAllTestsInOrg")
{
	write-host "Executes local tests in Org"
	"<sf:deploy allowMissingFiles=`"`${sf.allowMissingFiles}`" checkOnly=`"`${sf.checkOnly}`" rollbackOnError=`"`${sf.rollbackOnError}`" deployRoot=`"`${sf.deployRoot}`" serverurl=`"`${sf.serverurl}`" password=`"`${sf.password}`" username=`"`${sf.username}`" testLevel=`"RunAllTestsInOrg`" autoUpdatePackage=`"true`">" | out-file $BuildxmlLocation"build.xml" -append
	write-output "</sf:deploy> 
</target> 
</project>" | out-file $Buildxmllocation"build.xml" -append
}
else
{
	write-host "Executes no tests"
	"<sf:deploy allowMissingFiles=`"`${sf.allowMissingFiles}`" checkOnly=`"`${sf.checkOnly}`" rollbackOnError=`"`${sf.rollbackOnError}`" deployRoot=`"`${sf.deployRoot}`" serverurl=`"`${sf.serverurl}`" password=`"`${sf.password}`" username=`"`${sf.username}`" testLevel=`"NoTestRun`" autoUpdatePackage=`"true`">" | out-file $BuildxmlLocation"build.xml" -append
	write-output "</sf:deploy> 
</target> 
</project>" | out-file $Buildxmllocation"build.xml" -append
}

	
           
