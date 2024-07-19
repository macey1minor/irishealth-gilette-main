/// Copyright 2007 by Inland Imaging Business Associates
Class IIBAENSEMBLE.Task.ArchiveHL7 Extends %SYS.Task.Definition
{

Parameter TaskName = "ArchiveHL7";

Property sDate1 As %String;

Property sDate2 As %String;

Property ArchivePath As %String;

Method OnTask() As %Status
{
	
	D ##class(IIBAENSEMBLE.Utilities).ArchiveHL7(..sDate1,..sDate2,..ArchivePath)
	
	
	
	Quit $$$OK
}

}
