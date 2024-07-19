/// Copyright 2007 by Inland Imaging Business Associates
Class IIBAENSEMBLE.Task.BackupToNetwork Extends %SYS.Task.Definition
{

Parameter TaskName = "BackupToNetwork";

/// used to populate the "From:" field in the email generated to send the Buttons report
Property EmailCC As %String(XMLPROJECTION = "NONE");

/// used to populate the "From:" field in the email generated to send the Buttons report
Property EmailFrom As %String(XMLPROJECTION = "NONE") [ InitialExpression = "EnsTEST@duvoisin.com" ];

/// used to populate the "From:" field in the email generated to send the Buttons report
Property EmailTo As %String(XMLPROJECTION = "NONE") [ InitialExpression = "msimpson@ii-ba.com" ];

/// used to populate the "Reply-To:" field in the email generated to send the Buttons report
Property EmailReplyTo As %String(XMLPROJECTION = "NONE") [ InitialExpression = "EnsTEST@duvoisin.com" ];

/// name of SMTP server to use for sending %Buttons; if this is blank, the Buttons report will not be sent to InterSystems
Property SMTPServer As %String(XMLPROJECTION = "NONE") [ InitialExpression = "smtp.duvoisin.com" ];

/// name of SMTP Authenticated User
Property SMTPUser As %String(XMLPROJECTION = "NONE") [ InitialExpression = "webuser" ];

/// password of SMTP Authenitcated User
Property SMTPPass As %String(XMLPROJECTION = "NONE") [ InitialExpression = "webuser" ];

/// SMTPPort
Property SMTPPort As %String(XMLPROJECTION = "NONE") [ InitialExpression = 25 ];

/// Drive Letter
Property DriveLetter As %String(XMLPROJECTION = "NONE") [ InitialExpression = "Z" ];

/// UNC path
Property uncpath As %String(XMLPROJECTION = "NONE") [ InitialExpression = "\\sqlbackup\Backups4\Ensemble" ];

/// Domain User
Property DomainUser As %String(XMLPROJECTION = "NONE") [ InitialExpression = "duvoisin\svc_iibaensemble" ];

/// Domain user Password
Property DomainPass As %String(XMLPROJECTION = "NONE") [ InitialExpression = "118aensem8le" ];

/// Drive Letter
Property BackupTask As %String(XMLPROJECTION = "NONE") [ InitialExpression = "CumuIncrDBList / FullDBList" ];

Method OnTask() As %Status
{
	
	//if ..IsBackupRunning(.Info)=0 {
	
		do $ZF(-1,"net use "_..DriveLetter_": /DELETE")
		do $ZF(-1,"net use "_..DriveLetter_": "_..uncpath_" /USER:"_..DomainUser_" "_..DomainPass)
		do $ZF(-1,"cscript "_..DriveLetter_":\script\deleteolderthan2.vbs "_..BackupTask)
		set tSC = ##class(Backup.General).StartTask(..BackupTask,0,1,..DriveLetter_":\")
		do $ZF(-1,"net use "_..DriveLetter_": /DELETE")

	//} else {
	//	do ..Alert(.Info)
	//}

	Quit $$$OK
}

Method IsBackupRunning(Info As %RegisteredObject) As %Boolean
{
	set Return = 0
	set rs=##class(%ResultSet).%New("Backup.Task:List")
	do rs.Execute()
	While rs.Next() {
		if rs.Data("Status") = "Running" {
			set Info(rs.Data("Name"),"Name") = rs.Data("Name")
			set Info(rs.Data("Name"),"Type") = rs.Data("Type")
			set Info(rs.Data("Name"),"Device") = rs.Data("Device")
			set Info(rs.Data("Name"),"Description") = rs.Data("Description")
			set Info(rs.Data("Name"),"Status") = rs.Data("Status")
			set Info(rs.Data("Name"),"LastLogFile") = rs.Data("LastLogFile")
			set Return = 1
		}
	}
	
	Quit Return
}

Method Alert(Info As %RegisteredObject)
{
	 
	 set Name = ""
	 For {
	 	Set Name=$O(Info(Name))
 		Q:Name=""
 		set Body="The requested backup task will not run because the following backup is currently running."_$C(13,10)_$C(13,10)
 		
 		set Body = Body_"Name: "_Info(Name,"Name")_$C(13,10)
 		set Body = Body_"Status: "_Info(Name,"Status")_$C(13,10)
 		set Body = Body_"Type: "_Info(Name,"Type")_$C(13,10)
 		set Body = Body_"Device: "_Info(Name,"Device")_$C(13,10)
 		set Body = Body_"LogFile: "_Info(Name,"LastLogFile")_$C(13,10)
 		
 		set Body = Body_$C(13,10)_$C(13,10)
 		 		
	 }
	 
	do ..SendEmail(Body)
}

Method SendEmail(Body As %String)
{

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
		Set m.Subject = "Backup Task Failed"
		Set m.Charset="iso-8859-1"
		Do m.To.Insert(..EmailTo)
		If ..EmailCC'="" {
			for i=1:1:$L(..EmailCC,",") {
				Do m.Cc.Insert($P(..EmailCC,",",i))
			}	
		}
		Set Status = m.TextData.Write(Body)
		Set Status = s.Send(m)
	}
}

}
