/// Copyright 2007 by Inland Imaging Business Associates
Class IIBAENSEMBLE.Bsvc.FileToFtp Extends Ens.BusinessService [ ProcedureBlock ]
{

Property TargetConfigNames As %String(MAXLEN = 255);

Property FilePath As %String;

Property FileName As %String;

Property WorkingPath As %String;

Property ArchivePath As %String;

Property ArchiveDays As %Integer [ InitialExpression = "30" ];

Property CustomProcessingClass As %String;

Property CustomProcessingMethod As %String;

Parameter SETTINGS As %String = "TargetConfigNames,FilePath,FileName,WorkingPath,CustomProcessingClass,CustomProcessingMethod,ArchivePath,ArchiveDays";

Method OnProcessInput(pInput As %RegisteredObject, pOutput As %RegisteredObject) As %Status
{

	// Clean out Archive files older than 'ArchiveDays' days
	Set rset = ##class(%ResultSet).%New()
	set rset.ClassName = "%File"
	set rset.QueryName = "FileSet"
	Do rset.Execute(..ArchivePath,"*.*")
	Set FileDelete = 1
	While (rset.Next()) {
		// $$$LOGINFO("ZB: "_$ZB(##class(%File).Attributes(rset.Data("Name")),16,1))
		if ($ZB(##class(%File).Attributes(rset.Data("Name")),16,1)=0) {
			// only delete files - skip directories
			If $PIECE($HOROLOG,",") - $PIECE($ZDATETIMEH(rset.Data("DateCreated"),3,1),",") > ..ArchiveDays {
				Set FileDelete = ##class(%File).Delete(rset.Data("Name"))
				If FileDelete = 0 {
					$$$LOGERROR("File delete Failed: "_rset.Data("Name"))
				}
			}
		}
	}
	
	Do rset.Close()
	
		
	// Done - Clean out FTP Archive files older than 'ArchiveDays' days
	//
	//
	// Begin Processing of current Files
	
	
	set file = ""
	set FileRename = 0
	Set rset = ##class(%ResultSet).%New()
	set rset.ClassName = "%File"
	set rset.QueryName = "FileSet"
	Do rset.Execute(..FilePath,..FileName)
	While (rset.Next()) {
		if ($ZB(##class(%File).Attributes(rset.Data("Name")),16,1)=0) {
			$$$TRACE("Processing file: "_rset.Data("Name"))
			
			set NewFilename = ##class(%File).GetFilename(rset.Data("Name"))
			
			Set LastModified=$ZUTIL(140,2,rset.Data("Name"))
			
			S ElapsedTime=($P($H,",",1)-$P(LastModified,",",1))*86400+$P($H,",",2)-$P(LastModified,",",2)
			$$$TRACE("File was modified "_ElapsedTime_" Ago...(File: >"_rset.Data("Name")_"< Last Modified="_LastModified)
			
			// process the file if it was last modified more than 120 seconds ago
			if ( ($P(LastModified,",",1)>0 ) && (ElapsedTime>120)) {
				
				S FileNameList=$LFS(NewFilename,".")
				S FtpTime=$TR($ZDT($H,8,1)," :")
				s NewFilename=$LTS($LIST(FileNameList,1,$LISTLENGTH(FileNameList)-1),".")_"."_FtpTime_"."_$LIST(FileNameList,-1)
				
				
				set tfilename = ..WorkingPath_"\"_NewFilename
						
				set FileRename = ##class(%File).Rename(rset.Data("Name"),tfilename)
				$$$TRACE("Rename to "_tfilename_ "  returned: "_FileRename)
				If FileRename = 1 {
				
					$$$TRACE("Continueing processing of: "_tfilename)
					if ( ..CustomProcessingMethod '= "" ) {
						$$$TRACE("Custom processing method: "_..CustomProcessingClass_"/"_..CustomProcessingMethod)
					
						s tSC=$ZOBJCLASSMETHOD(..CustomProcessingClass,..CustomProcessingMethod,.tfilename)
					
						$$$TRACE("Custom Method complete: "_..CustomProcessingClass_"/"_..CustomProcessingMethod_" returned: "_tSC)
					
						if (tSC) {
							$$$LOGERROR("Custom Method processing failed for: "_tfilename)
							Q
						}
					
					}
				
				
					$$$TRACE("Send a request to each of the targets")
					For i=1:1:$L(..TargetConfigNames,",") {
					
						Set newRequest = ##class(IIBAENSEMBLE.msg.FileToFTP).%New()
						Set newRequest.FileSpec = ##class(%File).GetFilename(tfilename)
						Set newRequest.FilePath= ##class(%File).GetDirectory(tfilename)
						Set newRequest.ArchivePath=..ArchivePath
						Set newRequest.ArchiveDays=..ArchiveDays

						S target=$P(..TargetConfigNames,",",i)
						$$$TRACE("Target #"_i_": "_target)
						If ( target '= "" ) {
							$$$TRACE("Sending request to "_target)
							Set tSC = ..SendRequestAsync(target,newRequest)
						}
					}
				
				} Else {
					$$$LOGINFO("Failed to rename file : "_rset.Data("Name"))
				}
			} Else {
				$$$LOGWARNING("File "_NewFilename_" because it was modified "_ElapsedTime_" seconds ago, which is less then 120 seconds")
			}
		}
	}
	
	Quit $$$OK
}

ClassMethod OnGetConnections(Output pArray As %String, item As Ens.Config.Item)
{
	Set (tValue,tIndex)="" 
	For { 
		Set tIndex = item.Settings.Next(tIndex) Quit:tIndex=""
		Set tSetting = item.Settings.GetAt(tIndex)
		If tSetting.Name="TargetConfigNames" {
			Set tValue=tSetting.Value
		}
	}
	
	For i=1:1:$L(tValue,",") { 
		Set tOne=$P(tValue,",",i)
		If (tOne '= "" ) {
			Set pArray(tOne)=""
		}
	}
	Quit
}

}
