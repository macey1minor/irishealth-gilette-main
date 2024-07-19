/// Copyright 2007 by Inland Imaging Business Associates
Class IIBAENSEMBLE.Task.PurgeClassObjects Extends %SYS.Task.Definition
{

Parameter TaskName = "PurgeClassObjects";

Method OnTask() As %Status
{

	set ClassName="",PurgeFieldName="",PurgeFieldType="",DaysToKeep=""
	set NameSpace=$ZNSPACE,ItemName="",ItemValue="",tMessageId="",tDoNotDeleteDate=""
	
	&sql(DECLARE C1 CURSOR FOR 
		 SELECT ItemName,ItemValue INTO :ItemName,:ItemValue
		 FROM IIBAENSEMBLE_Task.TaskItemDefinition 
		 WHERE NameSpace = :NameSpace AND ItemType='ClassObjectPurge')
	&sql(OPEN C1)
		For { &sql(FETCH C1)  Quit:SQLCODE'=0 
	
			set ClassName = ItemName
			set PurgeFieldName=$P(ItemValue,"^",1)
			set PurgeFieldType=$P(ItemValue,"^",2)
			set DaysToKeep=$P(ItemValue,"^",3)
			
			//Create list from Class Name
 			set CL = $LFS(ClassName,".")
 			//Create a new sublist of all parts of the name except the last part
 			set CLt = $LI(CL,1,$LL(CL)-1)
 			//Join the parts of that name back into a string delimited by _ except the last part
 			set ClassTable = $LTS(CLt,"_")
 			//Add the last part in, but delimited by . 
 			set ClassTable = ClassTable_"."_$LI(CL,$LL(CL))
			
			If PurgeFieldType="TimeStamp" { Set tDoNotDeleteDate = "'"_$ZDT($H-DaysToKeep,3)_"'" }
			If PurgeFieldType="Date" { Set tDoNotDeleteDate = $H-DaysToKeep }
			
			set InfoMsg = "Start "_ClassName_" Purge at: "_$ZDT($H)_" | "
			set InfoMsg = InfoMsg_"Keep: "_DaysToKeep_" days | "
	
				
			set rs=##class(%ResultSet).%New()
			do rs.Prepare("Select ID from "_ClassTable_" WHERE "_PurgeFieldName_" < "_tDoNotDeleteDate)
			do rs.Execute()
			set count=0
			set errorcount=0
			While rs.Next() {
				Set tSC1=$zobjclassmethod(ClassName,"%DeleteId",rs.Data("ID"))
				if tSC1=1 { set count=count+1 } else {set errorcount=errorcount+1}
				//w rs.Data("ID")
			}
			
			set InfoMsg = InfoMsg_"Objects purged: "_count_" | Objects error on purge: "_errorcount_" | "
			set InfoMsg = InfoMsg_"End Purge at: "_$ZDT($H)
			
			do ##class(Ens.Util.Log).LogInfo("IIBAENSEMBLE.Task", "PurgeClassObjects", InfoMsg)
			
		}
	&sql(CLOSE C1)

	
	Quit $$$OK
}

}
