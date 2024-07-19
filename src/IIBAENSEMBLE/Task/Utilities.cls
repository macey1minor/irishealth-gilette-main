/// Copyright 2007 by Inland Imaging Business Associates
Class IIBAENSEMBLE.Task.Utilities Extends %Persistent
{

ClassMethod BackupCumu()
{
	do $ZF(-1,"net use z: /DELETE")
	do $ZF(-1,"net use z: \\sqlbackup\Backups4\Ensemble /USER:duvoisin\svc_iibaensemble 118aensem8le")
	do $ZF(-1,"cscript z:\script\deleteolderthan2.vbs cumuincrdblist")
	set tSC = ##class(Backup.General).StartTask("CumuIncrDBList",0,1,"Z:\")
	do $ZF(-1,"net use z: /DELETE")
}

ClassMethod BackupFull()
{
	do $ZF(-1,"net use z: /DELETE")
	do $ZF(-1,"net use z: \\sqlbackup\Backups4\Ensemble /USER:duvoisin\svc_iibaensemble 118aensem8le")
	do $ZF(-1,"cscript z:\script\deleteolderthan2.vbs fulldblist")
	set tSC = ##class(Backup.General).StartTask("FullDBList",0,1,"Z:\")
	do $ZF(-1,"net use z: /DELETE")
}

ClassMethod IsBackupRunning(Info As %RegisteredObject) As %Boolean
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

ClassMethod Alert(Info As %RegisteredObject)
{
	 
	 set Name = ""
	 For {
	 	Set Name=$O(Info(Name))
 		Q:Name=""
 		set Body="The following backup/s are currently running. The requested backup task will not run."_$C(13,10)_$C(13,10)
 		
 		set Body = Body_"Name: "_Info(Name,"Name")_$C(13,10)
 		set Body = Body_"Status: "_Info(Name,"Status")_$C(13,10)
 		set Body = Body_"Type: "_Info(Name,"Type")_$C(13,10)
 		set Body = Body_"Device: "_Info(Name,"Device")_$C(13,10)
 		set Body = Body_"LogFile: "_Info(Name,"LastLogFile")_$C(13,10)
 		
 		set Body = Body_$C(13,10)_$C(13,10)
 		 		
	 }
	 
	 w Body
}

ClassMethod Test()
{
	
	if ..IsBackupRunning(.Info)=0 {
		w "not running" 
	} else {
		do ..Alert(.Info)
	}
}

Storage Default
{
<Data name="UtilitiesDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
</Data>
<DataLocation>^IIBAENSEMBLE.Task.UtilitiesD</DataLocation>
<DefaultData>UtilitiesDefaultData</DefaultData>
<ExtentSize>100000</ExtentSize>
<IdLocation>^IIBAENSEMBLE.Task.UtilitiesD</IdLocation>
<IndexLocation>^IIBAENSEMBLE.Task.UtilitiesI</IndexLocation>
<StreamLocation>^IIBAENSEMBLE.Task.UtilitiesS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
