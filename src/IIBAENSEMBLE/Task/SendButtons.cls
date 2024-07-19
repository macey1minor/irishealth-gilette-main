/// Task provided by the WRC to automate the collection of Buttons reports, and to automate them being sent to the WRC for achival and configuration history.
/// Class updated: 12/29/2006
Class IIBAENSEMBLE.Task.SendButtons Extends (%SYS.Task.Definition, %XML.Adaptor) [ Inheritance = right, System = 4 ]
{

Parameter TaskName = "SendButtons";

Parameter XMLNAME = "ProfilerData";

/// if this field is filled, then the files are left in the local Archive  
Property ArchiveDirectory As %String(XMLPROJECTION = "NONE");

/// flag to indicate if this should be a Big Buttons; default is to collect a "Small" Buttons
Property BigButtons As %Boolean [ InitialExpression = 0 ];

/// used to populate the "From:" field in the email generated to send the Buttons report
Property EmailCC As %String(XMLPROJECTION = "NONE");

/// used to populate the "From:" field in the email generated to send the Buttons report
Property EmailFrom As %String(XMLPROJECTION = "NONE") [ InitialExpression = "DefaultSendButtons@InterSystems.com" ];

/// used to populate the "Reply-To:" field in the email generated to send the Buttons report
Property EmailReplyTo As %String(XMLPROJECTION = "NONE");

/// name of SMTP server to use for sending %Buttons; if this is blank, the Buttons report will not be sent to InterSystems
Property SMTPServer As %String(XMLPROJECTION = "NONE");

/// name of SMTP Authenticated User
Property SMTPUser As %String(XMLPROJECTION = "NONE");

/// password of SMTP Authenitcated User
Property SMTPPass As %String(XMLPROJECTION = "NONE");

/// password (stored encrypted) of SMTP Authenitcated User
Property SMTPPort As %String(XMLPROJECTION = "NONE") [ InitialExpression = 25 ];

/// flag to indicate if Butttons should be emailed to the WRC when collected and not associated with a WRC issue#
Property WRCHealthCheckEnabled As %Boolean(XMLPROJECTION = "NONE") [ InitialExpression = 0 ];

/// WRC Issue Number to be included in subject; NOTE: This is cleared after a buttons is sent with this in the Subject line, and needs to be reinitilized through the System Management Portal
Property WRCIssueNumber As %Integer(XMLPROJECTION = "NONE");

/// if there are any Adhocs applies as changed files only, which didn't update the $ZV string, they should be listed here
Property zInfoAdhocNotListedInZV As %String(XMLNAME = "AdhocNotListedInZV");

/// manual field indicating the types of backups used on this instance of Caché
Property zInfoBackupType As %String(XMLNAME = "BackupType");

/// manual field indicating the type and quantity of CPU(s) used on this system
Property zInfoCPUDetails As %String(XMLNAME = "CPUDetails");

/// manual field indicating the type of hardware that this system is running on
Property zInfoHardwareType As %String(MAXLEN = 500, XMLNAME = "HardwareType");

/// manual property indicates what the primary use is for this Caché Instance: Development, Testing, QA or Production
Property zInfoPrimaryPurpose As %String(DISPLAYLIST = ",Development,Testing,Quality Assurance,Production,", VALUELIST = ",Dev,Test,QA,Prod,", XMLNAME = "PrimaryPurpose");

/// total physical memory on the machine
Property zInfoTotalPhysicalMemory As %String(XMLNAME = "TotalPhysicalMemory");

/// any special notes that the customer wants included with the %Buttons
Property zzInfoNotesFromCustomer As %String(MAXLEN = 500, XMLNAME = "NotesFromCustomer");

ClassMethod ArchiveDirectoryIsValid(ArchiveDirectory As %String) As %Status
{
	If (ArchiveDirectory'="") {
		If '##class(%Library.File).DirectoryExists(ArchiveDirectory) Quit $$$ERROR($$$GeneralError,"Directory does not exist")
	}
	Quit $$$OK
}

/// This method is responsible for executing the task
/// At the scheduled time, the Task Manager
/// - creates an instance of this object,
/// - Sets any property values using the stored "Settings" for the task,
/// - and invokes this method to execute the task.
Method OnTask() As %Status
{
	If ..ArchiveDirectory'="" {
		Set Status = ##class(IIBAENSEMBLE.Task.SendButtons).ArchiveDirectoryIsValid(..ArchiveDirectory) 
		If 'Status Quit Status
	}
	If ..BigButtons {
		Set LogType = "Advanced"	
	}
	Else {
		Set LogType = "Basic"	
	}
	Set Status = $$INT^Buttons(LogType,..ArchiveDirectory)
	If $P(Status,"|",1) '= 1 Quit $$$ERROR($$$GeneralError,$P(Status,"|",2))
	Set FullFile = $P(Status,"|",2)
	// Buttons on VMS returns a trailing ";" in the filename which needs to be removed
	Set FullFile = $P(FullFile,";",1)
	// send if they have filled in the required information for Sending the report to the WRC
	If ..SMTPServer '= "",..EmailFrom '= ""  {
		Set s=##class(%Net.SMTP).%New()
		Set AuthUser=$ZSTRIP(..SMTPUser,"<>W")
		Set objAuth=""
		If AuthUser]"" {
			#; use default authentication list
			set objAuth=##class(%Net.Authenticator).%New() 
			Set objAuth.UserName=AuthUser
			Set objAuth.Password=..SMTPPass
		}
		If objAuth set s.authenticator=objAuth
		Set s.smtpserver=..SMTPServer
		Set s.port=..SMTPPort
		Set m = ##class(%Net.MailMessage).%New()
		Set m.From = ..EmailFrom
		Set m.ReplyTo = ..EmailReplyTo
		Set m.Subject = "Automated sending of "_FullFile
		Set m.Charset="iso-8859-1"
		If ..WRCIssueNumber '="" {
			Do m.To.Insert("support@intersystems.com")
			Set m.Subject = "Buttons for WRC"_..WRCIssueNumber
		}
		//Do m.To.Insert("WRCHealthCheck@intersystems.com")
		Do m.To.Insert("bgraham@nuvodia.com")
		If ..EmailCC'="" {
			for i=1:1:$L(..EmailCC,",") {
				Do m.Cc.Insert($P(..EmailCC,",",i))
			}	
		}
		Set Status = ..XMLExportToString(.body,,",indent")
		Set Status = m.TextData.Write(body)
		If $$$ISERR(Status) Quit $$$ERROR($$$GeneralError,Status)
		Set dir = ##class(%File).GetDirectory(FullFile)
		Set file = ##class(%File).GetFilename(FullFile)
		Set Status = m.AttachFile(dir,file,0,"iso-8859-1")
		If $$$ISERR(Status) Quit $$$ERROR($$$GeneralError,Status)
		Set Status = s.Send(m)
		If $$$ISERR(Status) Quit $$$ERROR($$$GeneralError,Status)
	}
	//if the customer hasn't defined an Archive Directory, but they are automatically creating reports on a schedule, then delete the file
	If ..ArchiveDirectory="",..WRCHealthCheckEnabled {
		Set Status = ##class(%File).Delete(FullFile)
	}
	//clear out the WRCIssue number so the customer will need to manually enter it again
	If ..WRCIssueNumber'="" {
		Set ..WRCIssueNumber = ""
		Set ..BigButtons = 0
	}
	Quit $$$OK
}

}
