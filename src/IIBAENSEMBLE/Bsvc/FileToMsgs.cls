/// Copyright 2007 by Inland Imaging Business Associates
Class IIBAENSEMBLE.Bsvc.FileToMsgs Extends Ens.BusinessService [ ProcedureBlock ]
{

Property TargetConfigName As %String(MAXLEN = 255);

Property FilePath As %String;

Property FileName As %String;

Property UNCPath As %String;

Property UNCDriveLetter As %String;

Property UNCUser As %String;

Property UNCPWord As %String;

/// If a value is provided the attachment is archived to this location
Property ArchivePath As %String;

Property ArchiveDays As %Integer [ InitialExpression = "30" ];

Property CustomProcessingClass As %String;

Property CustomProcessingMethod As %String;

Property WorkingPath As %String;

Parameter SETTINGS As %String = "TargetConfigName,FilePath,FileName,WorkingPath,CustomProcessingClass,CustomProcessingMethod,ArchivePath,ArchiveDays";

Method OnProcessInput(pInput As %RegisteredObject, pOutput As %RegisteredObject) As %Status
{
	
	$$$TRACE("OnProcessInput")
	
	set tSC = 1
	
	// Clean out Archive files older than 'ArchiveDays' days
	
	if ..ArchivePath '= "" {
	
		do ##class(IIBAENSEMBLE.Utilities).PurgeArchivedFiles(..ArchivePath,"*.*",..ArchiveDays)
		
	}
			
	// Done - Clean out FTP Archive files older than 'ArchiveDays' days
	//
	//
	// Begin Processing of current Files
	
	
	Set rset = ##class(%ResultSet).%New()
	set rset.ClassName = "%File"
	set rset.QueryName = "FileSet"
	Do rset.Execute(..FilePath,..FileName)
	While (rset.Next()) {
		if ($ZB(##class(%File).Attributes(rset.Data("Name")),16,1)=0) {
			$$$TRACE("Processing file: "_rset.Data("Name"))
			
			set tfilefullname = rset.Data("Name")
			set tname = ##class(%File).GetFilename(rset.Data("Name"))
			
			if ..ArchivePath '= "" {
				
					
				set NewFileFullname = ..ArchivePath_"\"_tname
						
				set FileCopy = ##class(%File).CopyFile(rset.Data("Name"),NewFileFullname)
				$$$TRACE("File Copy to "_NewFileFullname_ "  returned: "_FileCopy)
				
				if FileCopy '= 1 { $$$LOGERROR("File Rename failed for: "_tfilefullname) }
			
			}
			
			
			if ..WorkingPath '="" {
				set NewFileFullname = ..WorkingPath_"\"_tname
				set tSC = ##class(%File).Rename(tfilefullname,NewFileFullname)
				
				if (tSC '= 1) {
					$$$LOGERROR("Could not move file "_tname_" to the working directory "_..WorkingPath)
					Q
				}
				
				s tfilefullname=NewFileFullname
			}
			
			
			if ( ..CustomProcessingMethod '= "" ) {
				$$$TRACE("Custom processing method: "_..CustomProcessingClass_"/"_..CustomProcessingMethod)
				
				
				
				set pFileStream = ##class(%FileCharacterStream).%New()
				Set pFileStream.Filename = tfilefullname
	
				$$$TRACE("stream: "_pFileStream.Filename)
		
				while 'pFileStream.AtEnd {
		
					Set tLine = pFileStream.ReadLine()
					
					
 					
 					if tLine '= "" {
 						s pRequest=$ZOBJCLASSMETHOD(..CustomProcessingClass,..CustomProcessingMethod,tLine,.tSC)
 						$$$TRACE("Custom Method complete: "_..CustomProcessingClass_"/"_..CustomProcessingMethod_" returned: "_tSC)
					
 						if (($ISOBJECT(pRequest) = 0)||(tSC '= 1)) {
							$$$LOGERROR("Custom Method: "_..CustomProcessingClass_"."_..CustomProcessingMethod_" processing failed for: "_tfilefullname_" with status: "_$System.OBJ.DisplayError(tSC))
							Q
						} else {
							Set tSC = ..SendRequestAsync(..TargetConfigName,pRequest)
						}
						
						s pRequest = ""
					
					}
		
					if tSC'=1 { 
						Q
					}
					
				}		
			}			
		}		
	}		
	
	Quit tSC
}

ClassMethod OnGetConnections(Output pArray As %String, item As Ens.Config.Item)
{
	Set (tValue,tIndex)="" 
	For { 
		Set tIndex = item.Settings.Next(tIndex) Quit:tIndex=""
		Set tSetting = item.Settings.GetAt(tIndex)
		If tSetting.Name="TargetConfigName" {
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
