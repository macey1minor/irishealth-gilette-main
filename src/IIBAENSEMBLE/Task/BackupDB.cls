/// Copyright 2007 by Inland Imaging Business Associates
Class IIBAENSEMBLE.Task.BackupDB Extends %SYS.Task.Definition
{

Parameter TaskName = "BackupDB";

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

/// Local Backup Path with trailing \
Property BackupPath As %String(XMLPROJECTION = "NONE");

/// Remote Archive location to copy backup to (unc) with trailing \
Property ArchivePath As %String(XMLPROJECTION = "NONE");

/// Remote Archive location to duplicate the current archive to prior to purging it with new backups with trailing \
Property ArchivePath2 As %String(XMLPROJECTION = "NONE");

/// Type of Backup to perform<br>
/// Use "CopyCurrentArchive" to make a copy of the files in ArchivePath to ArchivePath2
Property BackupTask As %String(XMLPROJECTION = "NONE") [ InitialExpression = "CumuIncrDBList / FullDBList" ];

Method OnTask() As %Status
{
	set tSC = 1
	if ..IsBackupRunning(.Info)=0 {
	
	  If ..BackupTask = "CopyCurrentArchive" {
		  set result = $ZF(-2,"robocopy "_..ArchivePath_" "_..ArchivePath2_" /R:0 /PURGE /XF """_..BackupPath_"copylog.log"" /V /NP /LOG+:"""_..BackupPath_"copylog.log""")
		  if result '= 0 {
		  	set tSC = result
		  } else {
			set tSC = 1
		  }
	  } else {
		
		do ..removeoldbackups()
		
		set tSC = ##class(Backup.General).StartTask(..BackupTask,0,1,..BackupPath)
		
		if 'tSC {
			set tSC = ##class(Backup.General).StartTask("FullDBList",0,1,..BackupPath)
		}
		
		if tSC {
			
			set result = $ZF(-2,"robocopy "_..BackupPath_" "_..ArchivePath_" /R:0 /PURGE /XF """_..BackupPath_"copylog.log"" /V /NP /LOG+:"""_..BackupPath_"copylog.log""")
			if result '= 0 {
				set tSC = result
			} else {
				set tSC = 1
			}
			
			/*
			//This commented code replaced by robo copy commands above
			do ..removeoldarchives()
		
			// do copy of new backup file to archive
			set NewestFile = ""
			Set rset = ##class(%ResultSet).%New()
			set rset.ClassName = "%File"
			set rset.QueryName = "FileSet"
			Do rset.Execute(..BackupPath,"*.cbk","DateModified",0)
			While rset.Next() { set NewestFile = rset.Data("Name") } //get last file which is most recent as sort is ascending
			if NewestFile '= "" {
				set result = $ZF(-2,"copy "_NewestFile_" "_..ArchivePath_##class(%File).GetFilename(NewestFile)_" /Y")
				if result '= 0 {
					set tSC = result
				} else {
					set tSC = 1
				}
			}
			*/
		}
	  }
		
	} else {
		do ..Alert(.Info)
	}

	Quit tSC
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

Method removeoldbackups()
{
	set countofcum = 0, cumsnewerthanfull = ""
	If ..BackupTask = "FullDBList" {
		Set rset = ##class(%ResultSet).%New()
		set rset.ClassName = "%File"
		set rset.QueryName = "FileSet"
		Do rset.Execute(..BackupPath,"*.cbk","DateModified",0)
		While rset.Next() {
			d ##class(%File).Delete(rset.Data("Name"))	
		}
		d rset.Close()		
	}
	If ..BackupTask = "CumuIncrDBList" {
		Set rset = ##class(%ResultSet).%New()
		set rset.ClassName = "%File"
		set rset.QueryName = "FileSet"
		Do rset.Execute(..BackupPath,"CumuIncrDBList*.cbk","DateModified",0)
		While rset.Next() {
			set countofcum = countofcum+1
			set cumsnewerthanfull(countofcum) = rset.Data("Name")
		}
		d rset.Close()
		for i=1:1:countofcum-1 {
			d ##class(%File).Delete(cumsnewerthanfull(i))
		}
	}
}

Method removeoldarchives()
{
	set CurrentFullDate = "", countofcum = 0, cumsnewerthanfull = ""
	Set fullrset = ##class(%ResultSet).%New()
	set fullrset.ClassName = "%File"
	set fullrset.QueryName = "FileSet"
	Do fullrset.Execute(..ArchivePath,"FullDBList*.cbk","DateModified",0)
	While fullrset.Next() { set CurrentFullDate = $TR(fullrset.Data("DateModified"),"- :") } //get last full which is most recent as sort is ascending
	d fullrset.Close()
	if CurrentFullDate'="" {
		If ..BackupTask = "FullDBList" {
			Set rset = ##class(%ResultSet).%New()
			set rset.ClassName = "%File"
			set rset.QueryName = "FileSet"
			Do rset.Execute(..ArchivePath,"*.cbk","DateModified",0)
			While rset.Next() {
				if $TR(rset.Data("DateModified"),"- :") < CurrentFullDate d ##class(%File).Delete(rset.Data("Name"))	
			}
			d rset.Close()		
		}
		If ..BackupTask = "CumuIncrDBList" {
			Set rset = ##class(%ResultSet).%New()
			set rset.ClassName = "%File"
			set rset.QueryName = "FileSet"
			Do rset.Execute(..ArchivePath,"CumuIncrDBList*.cbk","DateModified",0)
			While rset.Next() {
				if $TR(rset.Data("DateModified"),"- :") > CurrentFullDate {
					set countofcum = countofcum+1
					set cumsnewerthanfull(countofcum) = rset.Data("Name")
				}
			}
			d rset.Close()
			for i=1:1:countofcum-1 {
				d ##class(%File).Delete(cumsnewerthanfull(i))
			}
		}
	}
}

}
