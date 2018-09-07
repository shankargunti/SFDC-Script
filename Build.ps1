$Buildxmllocation=""
#Remove-Item "Delta\b*.xml"
write-output "<?xml version=`"1.0`" ?>"
<project xmlns:sf=`"antlib:com.salesforce`" basedir=`".`" default=`"R2MrgTrain`"
name=`"Sample usage of Salesforce Ant tasks`"  >
    <!--<property file=`"build.properties`"/>-->
     <property environment=`"env`"/>
  <taskdef uri=`"antlib:com.salesforce`"
           resource=`"com/salesforce/antlib.xml`">
		   </classpath>
		   </taskdef>
		   <echo message =`"Embed a line break:`${sf.username}`"/>
		   <echo message =`"Embed a line break:`${sf.password}`"/>
		   <echo message =`"Embed a line break:`${sf.serverurl}`"/>
		   <!--<echo message=`"`$(sfurl)`"/> <echo message=`"`$(sfusername)`"/> <echo message="`$(sfpassword)`"/>"/>-->
           <target name=`"R2MrgTrain`">
		   <echo message =`"Starting Deployment from GK branch to R2MrgTrain Sandbox`"/> | out-file $BuildxmlLocation"build.xml" -append
		   $TestPath = Get-ChildItem "Delta\src\classes\*test*"
		   $TestPath
		   if(($TestPath).Length -gt 0)
		   {
		   "<sf:deploy allowMissingFiles=`"TRUE`" checkOnly=`"FALSE`" autoUpdatePackage=`"TRUE`" rollbackOnError=`"TRUE`" deployRoot=`"src`" serverurl=`"${sf.serverurl}`" password=`"${sf.password}`" username=`"${sf.username}`" testlevel=`"RunSpecifiedTests`"/>" | out-file $BuildxmlLocation"build.xml" -append
		   }
		   else 
		   {
		   "<sf:deploy allowMissingFiles=`"TRUE`" checkOnly=`"FALSE`" autoUpdatePackage=`"TRUE`" rollbackOnError=`"TRUE`" deployRoot=`"src`" serverurl=`"${sf.serverurl}`" password=`"${sf.password}`" username=`"${sf.username}`"/>" | out-file $BuildxmlLocation"build.xml" -append
		   }
		   $sourceFiles=@()
		   $sourceFiles=Get-ChildItem "Delta\src"|?{$_.Attributes -eq "Directory"}
		   $nametag="
		   classes, ApexClass
		   triggers, Apextrigger"
		   $global:nametag1=@{}
		   $nametag1=($nametag.Replace(",","=")-join "\n") | ConvertFrom-StringData
		   $global:hname=@()
           $hname=$nametag1.getenumerator() | select -ExpandProperty Name
           $global:cnt=$hname.Count
           $hvalue=$nametag1.($hname[0])
foreach($src in $sourceFiles)
  
{
    if($src.Basename -match ("classes") -or $src.Basename -match "triggers")
    {
        foreach($hsrc in $hname)
        {
            if($src.Basename -contains $hsrc)
            {
                if($src.Basename -match ("classes"))
                {
                    $file1=Get-ChildItem $src.FullName -file
                }
                foreach($file2 in $file1)
                {
                    #$s3=$s2.ToString().Split(".")[0]
                    $file3=[System.Io.Path]::GetFileNameWithoutExtension($file2)
                    #$lastword=($file2.To.String().split("."))[-1"]
                    #$file3=($file2.tostring()).trimend("."+$lastword)
                    if(($file2.BaseName -like "Test*" -and $file2.Basename -notlike "*-meta*") -or ($file2.BaseName -like "*Test.cls" -and $file2.Basename -notlike "*-meta*"))
                    {
                        Write-Output "<runTest>$file3</runTest>" | out-file $Buildxmllocation"build.xml" -append

                    }
                    elseif(($file2.BaseName -notlike "Test*" -and $file2.fullname -notlike "*-meta*" -and $file2.BaseName -notlike "$file3" -or ($file2.BaseName -notlike "*Test*" -and $file2.fullname -notlike "*meta*" -and $file2.BaseName -notlike "$file3"))
                {
                    Write-Output"Test File not exists for these classes delta\src\$($src.Basename)\$file3"
                }
                }
            }
        }
    }
}
Write-Output"</sf:deploy> 
</target> 
</project>" | out-file $Buildxmllocation"build.xml" -append
                    
           
