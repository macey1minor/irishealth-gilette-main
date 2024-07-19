/// Copyright 2007 by Inland Imaging Business Associates
Class IIBAENSEMBLE.Task.PurgeMessages Extends %SYS.Task.Definition
{

Parameter TaskName = "PurgeMessages";

/// The purge will remove all message older than the number of days to Keep
Property DaysToKeep As %Integer;

Method OnTask() As %Status
{
	set InfoMsg = "Start Purge at: "_$ZDT($H)_" | "
	
	set InfoMsg = InfoMsg_"Keep: "_..DaysToKeep_" days | "
	
	set InfoMsg = InfoMsg_"HL7 TotalCount Before: "_##class(EnsLib.HL7.Message).TotalCount()_" | "
	
	do ##class(Ens.Purge).PurgeAll(.MHCounts,..DaysToKeep,0,1)
	
	set name="" 
	for { 
		set name=$O(MHCounts(name))  
		quit:name=""
		set InfoMsg = InfoMsg_name_": "_MHCounts(name)_" | "
	}
	
	set ackCount = 0
	set rs = ##class(%ResultSet).%New()
    do rs.Prepare("Select ID, TimeCreated from EnsLib_HL7.Message where TimeCreated < '"_$ZD($H-..DaysToKeep,3)_"'")
    do rs.Execute()
    While rs.Next() {
	    set ackCount = ackCount+1
    	do ##class(EnsLib.HL7.Message).%DeleteId(rs.Data("ID"))
    }
    do rs.Close()
 	
 	set InfoMsg = InfoMsg_"Ack Msgs purged: "_ackCount_" | "
	
	set ruleCount = 0
	set rs = ##class(%ResultSet).%New()
    do rs.Prepare("select ID, TimeExecuted from Ens_Rule.RuleLog where TimeExecuted < '"_$ZD($H-..DaysToKeep,3)_"'")
    do rs.Execute()
    While rs.Next() {
	    set ruleCount = ruleCount+1
    	do ##class(Ens.Rule.RuleLog).%DeleteId(rs.Data("ID"))
    }
    do rs.Close()
	
	set InfoMsg = InfoMsg_"Rule log entries purged: "_ruleCount_" | "
	
	
	set InfoMsg = InfoMsg_"HL7 TotalCount After: "_##class(EnsLib.HL7.Message).TotalCount()_" | "
	
	set InfoMsg = InfoMsg_"End Purge at: "_$ZDT($H)
	
	do ##class(Ens.Util.Log).LogInfo("IIBAENSEMBLE.Task", "PurgeMessages", InfoMsg)
	
	Quit $$$OK
}

}
