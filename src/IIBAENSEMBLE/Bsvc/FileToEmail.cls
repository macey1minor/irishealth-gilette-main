/// Copyright 2007 by Inland Imaging Business Associates
Class IIBAENSEMBLE.Bsvc.FileToEmail Extends Ens.BusinessService [ ProcedureBlock ]
{

Property TargetConfigName As %String(MAXLEN = 255);

Property ToAddress As %String;

Property AttachmentPath As %String;

Property AttachmentName As %String;

Property Subject As %String;

Property Body As %String;

/// If a value is provided the attachment is archived to this location
Property ArchivePath As %String;

Property ArchiveDays As %Integer [ InitialExpression = "30" ];

Property CustomProcessingClass As %String;

Property CustomProcessingMethod As %String;

Property WorkingPath As %String;

Parameter SETTINGS As %String = "TargetConfigName,ToAddress,AttachmentPath,AttachmentName,Subject,Body,WorkingPath,CustomProcessingClass,CustomProcessingMethod,ArchivePath,ArchiveDays";

Method OnProcessInput(pInput As %RegisteredObject, pOutput As %RegisteredObject) As %Status
{

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
	Do rset.Execute(..AttachmentPath,..AttachmentName)
	While (rset.Next()) {
		if ($ZB(##class(%File).Attributes(rset.Data("Name")),16,1)=0) {
			$$$TRACE("Processing file: "_rset.Data("Name"))
			
			set tfilefullname = rset.Data("Name")
			set tname = ##class(%File).GetFilename(rset.Data("Name"))
			
			if ..ArchivePath '= "" {
				
					
				set NewFileFullname = ..ArchivePath_"\"_tname
						
				set FileCopy = ##class(%File).CopyFile(rset.Data("Name"),NewFileFullname)
				$$$TRACE("File Copy to "_NewFileFullname_ "  returned: "_FileCopy)
				
				if FileCopy '= 1 { $$$LOGERROR("Email Archive File Rename failed for: "_tfilefullname) }
			
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
			
			$$$TRACE("Continueing processing of: "_tfilefullname)
			if ( ..CustomProcessingMethod '= "" ) {
				$$$TRACE("Custom processing method: "_..CustomProcessingClass_"/"_..CustomProcessingMethod)
					
				s tSC=$ZOBJCLASSMETHOD(..CustomProcessingClass,..CustomProcessingMethod,.tfilefullname)
					
				$$$TRACE("Custom Method complete: "_..CustomProcessingClass_"/"_..CustomProcessingMethod_" returned: "_tSC)
					
				if (tSC '= 1) {
					$$$LOGERROR("Custom Method: "_..CustomProcessingClass_"."_..CustomProcessingMethod_" processing failed for: "_tfilefullname_" with status: "_tSC)
					Q
				}
					
			}
			
			set tname = ##class(%File).GetFilename(tfilefullname)
			set tpath = ##class(%File).GetDirectory(tfilefullname)
			
			set pRequest = ##class(IIBAENSEMBLE.msg.EmailSendRequest).%New()
			set pRequest.Destination = ..ToAddress
			set pRequest.Subject = ..Subject
			set pRequest.Text = ..Body
			set pRequest.AttFile = tname
			set pRequest.AttDir = tpath
			
				
			Set tSC = ..SendRequestAsync(..TargetConfigName,pRequest)
				
			
			
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
