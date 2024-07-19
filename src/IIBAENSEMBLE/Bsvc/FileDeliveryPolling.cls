/// Copyright 2007 by Inland Imaging Business Associates
Class IIBAENSEMBLE.Bsvc.FileDeliveryPolling Extends Ens.BusinessService [ ProcedureBlock ]
{

Parameter ADAPTER As %String = "Ens.InboundAdapter";

Property TargetConfigNames As %String(MAXLEN = 255);

Property FilePath As %String;

Property FileName As %String;

/// Append a timestamp to the filename. Reduces the possibility of duplicate files.
Property AppendTimeStamp As %Boolean [ InitialExpression = 1 ];

Property WorkingPath As %String;

/// Deliver files in the working folder that were not previously sent.
Property ReprocessWorkingFolder As %Boolean [ InitialExpression = 1 ];

Property ArchivePath As %String;

Property ArchiveDays As %Integer [ InitialExpression = "30" ];

// Used to limit the archive clean up to once a day (and/or when interface is started up)

Property ArchiveFolderDate As %TimeStamp;

Property CustomProcessingClass As %String;

Property CustomProcessingMethod As %String;

Property FileModifyWaitTime As %Integer [ InitialExpression = 120 ];

Parameter SETTINGS As %String = "TargetConfigNames,FilePath,FileName,FileModifyWaitTime,AppendTimeStamp,WorkingPath,ReprocessWorkingFolder,CustomProcessingClass,CustomProcessingMethod,ArchivePath,ArchiveDays";

Method OnProcessInput(pInput As %RegisteredObject, pOutput As %RegisteredObject) As %Status
{

	// Clean out Archive files older than 'ArchiveDays' days
	// ...Clean up is done once a day, and/or on startup.
	
	if ( $P(..ArchiveFolderDate,",",1)'=$P($H,",",1) ) {
		Set ..ArchiveFolderDate=$H
		$$$TRACE("Archive Folder Cleanup:"_..ArchiveFolderDate_"| "_$H)
		Set rset = ##class(%ResultSet).%New()
		set rset.ClassName = "%File"
		set rset.QueryName = "FileSet"
		Do rset.Execute(..ArchivePath,..FileName)
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
	}
		
	// Done - Clean out FTP Archive files older than 'ArchiveDays' days
	//
	//
	// Resend files in working directory
	
	if ( ..ReprocessWorkingFolder && (..WorkingPath '= "" ) ) {
		Set rset = ##class(%ResultSet).%New()
		set rset.ClassName = "%File"
		set rset.QueryName = "FileSet"
		Do rset.Execute(..WorkingPath,..FileName)
		While (rset.Next()) {
			$$$TRACE("Send a request to each of the targets")
			
			If ($F(rset.Data("Name"),".ArchiveFailed")=0) {
				For i=1:1:$L(..TargetConfigNames,",") {
					
					Set newRequest = ##class(IIBAENSEMBLE.msg.FileDelivery).%New()
					Set newRequest.FileSpec = ##class(%File).GetFilename(rset.Data("Name"))
					Set newRequest.FilePath= ##class(%File).GetDirectory(rset.Data("Name"))
					Set newRequest.ArchivePath=..ArchivePath
					Set newRequest.ArchiveDays=..ArchiveDays

					S target=$P(..TargetConfigNames,",",i)
					$$$TRACE("Target #"_i_": "_target)
					If ( target '= "" ) {
						$$$TRACE("Sending request to "_target)
						Set tSC = ..SendRequestAsync(target,newRequest)
					}
				}
			} else {
				$$$LOGWARNING("File In working folder that could not be archived: "_rset.Data("Name"))
			}
			
		}
		
		
	}
	
	Do rset.Close()
	
	// Done - Resend of files in working directory
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
			
			// process the file if it was last modified more than FileModifyWaitTime seconds ago
			if ( ($P(LastModified,",",1)>0 ) && (ElapsedTime>..FileModifyWaitTime)) {
				
				if (..AppendTimeStamp) {
					S FileNameList=$LFS(NewFilename,".")
					S FtpTime=$TR($ZDT($H,8,1)," :")
					s NewFilename=$LTS($LIST(FileNameList,1,$LISTLENGTH(FileNameList)-1),".")_"."_FtpTime_"."_$LIST(FileNameList,-1)
				}
				
				
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
					
						Set newRequest = ##class(IIBAENSEMBLE.msg.FileDelivery).%New()
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
				$$$TRACE("File "_NewFilename_" because it was modified "_ElapsedTime_" seconds ago, which is less then 120 seconds")
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
