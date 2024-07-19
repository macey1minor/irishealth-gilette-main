/// Copyright 2007 by Inland Imaging Business Associates
/// The names of the Directories to check are stored in TaskItemDefinition as item type NSDir
Class IIBAENSEMBLE.Task.AlertFreeSpace Extends %SYS.Task.Definition
{

Parameter TaskName = "AlertFreeSpace";

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

/// password (stored encrypted) of SMTP Authenitcated User
Property SMTPPort As %String(XMLPROJECTION = "NONE") [ InitialExpression = 25 ];

/// FreeSpace Threshold
Property Threshold As %String(XMLPROJECTION = "NONE") [ InitialExpression = 3000 ];

Method OnTask() As %Status
{
	
 set db = ##class(%Monitor.System.Freespace).%New()
 w db.Initialize()
 
 s DBThreshold=""

 &sql(DECLARE C1 CURSOR FOR 
	 SELECT ItemName, ItemValue INTO :DBDir,:DBThreshold
	 FROM IIBAENSEMBLE_Task.TaskItemDefinition 
	 WHERE ItemType='NSDir')
 &sql(OPEN C1)
   For { &sql(FETCH C1)  Quit:SQLCODE'=0 	
	
	set dbFreeSpace = 0
	
	do ##class(SYS.Database).GetDatabaseFreeSpace(DBDir,.dbFreeSpace)
	
	s:DBThreshold="" DBThreshold=..Threshold
	
	IF dbFreeSpace <= DBThreshold {
		
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
		Set m.Subject = DBDir_" FREESPACE: "_dbFreeSpace_" mb"
		Set m.Charset="iso-8859-1"
		Do m.To.Insert(..EmailTo)
		If ..EmailCC'="" {
			for i=1:1:$L(..EmailCC,",") {
				Do m.Cc.Insert($P(..EmailCC,",",i))
			}	
		}
		Set Status = m.TextData.Write(DBDir_$C(10)_$C(13)_" FREESPACE: "_dbFreeSpace_" mb"_$C(10)_$C(13)_" Threshold: "_DBThreshold_ " mb")
		Set Status = s.Send(m)
		
	  }
	}
   }
	
	Quit $$$OK
}

}
