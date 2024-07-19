/// Copyright 2007 by Inland Imaging Business Associates
Class IIBAENSEMBLE.Task.MSGCLASSDEF Extends %SYS.Task.Definition
{

Parameter TaskName = "MSGCLASSDEF";

Method OnTask() As %Status
{
	set InfoMsg = "Start MSGCLASSDEF at: "_$ZDT($H)_" | "
	
	set SourceConfigName="",MessageBodyClassName=""
	set NameSpace=$ZNSPACE
	
	//&SQL(delete from IIBAENSEMBLE_Task.TaskItemDefinition where ItemType LIKE 'MsgClassDef%' AND NameSpace = :NameSpace)
	
	set TaskRS = ##class(%ResultSet).%New()
    set sql = "select %ID, ItemName, ItemValue "
    set sql = sql_"from IIBAENSEMBLE_Task.TaskItemDefinition "
    set sql = sql_"WHERE ItemType LIKE 'MsgClassDef%' "
    set sql = sql_"AND NameSpace = '"_NameSpace_"'"
    do TaskRS.Prepare(sql)
    do TaskRS.Execute()

    While TaskRS.Next(){
                                
        set TaskId = TaskRS.Get("ID")
        set ItemName = TaskRS.Get("ItemName")
        set ItemValue = TaskRS.Get("ItemValue")

                                                                
        &sql(DELETE FROM IIBAENSEMBLE_Task.TaskItemDefinition WHERE %ID = :TaskId)
        &sql(COMMIT)
                                
        if SQLCODE '=0{
               set Source = "IIBAENSEMBLE.Task"
               set Type = "MSGCLASSDEF"
               //set Name = "DELETE"
               set infoMsg = ItemName_" ("_ItemValue_")"_" : "_TaskId_" (ERR:"_SQLCODE_")"
                                               
               do ##class(Ens.Util.Log).LogWarning(Source,Type,infoMsg)
               //do $SYSTEM.Security.Audit(Source,Type,Name,infoMsg,Name)
               }
                                
        }
	
		
	&sql(DECLARE C1 CURSOR FOR 
		 SELECT %NOLOCK DISTINCT SourceConfigName,MessageBodyClassName INTO :SourceConfigName,:MessageBodyClassName
		 FROM Ens.MessageHeader WHERE MessageBodyClassName IS NOT NULL )
	
		&sql(OPEN C1)
		For { &sql(FETCH C1)  Quit:SQLCODE'=0 
			
			&sql(INSERT INTO IIBAENSEMBLE_Task.TaskItemDefinition (Namespace,ItemType,ItemName,ItemValue) 
				VALUES (:NameSpace,'MsgClassDef^S',:SourceConfigName,:MessageBodyClassName))
		}
	&sql(CLOSE C1)
	
	&sql(DECLARE C2 CURSOR FOR 
		 SELECT %NOLOCK DISTINCT TargetConfigName,MessageBodyClassName INTO :SourceConfigName,:MessageBodyClassName
		 FROM Ens.MessageHeader WHERE MessageBodyClassName IS NOT NULL )
	
		&sql(OPEN C2)
		For { &sql(FETCH C2)  Quit:SQLCODE'=0 
			
			&sql(INSERT INTO IIBAENSEMBLE_Task.TaskItemDefinition (Namespace,ItemType,ItemName,ItemValue) 
				VALUES (:NameSpace,'MsgClassDef^T',:SourceConfigName,:MessageBodyClassName))
		}
	&sql(CLOSE C2)
	
	//temp log info- to see how the transaction is handled.
	set cMode = $SYSTEM.SQL.GetAutoCommit()
	set stat = $SYSTEM.SQL.GetIsolationMode()
	              
	set InfoMsg = InfoMsg_"End MSGCLASSDEF at: "_$ZDT($H)_"  CommitMode="_cMode_"  IsoMode="_stat
	
	do ##class(Ens.Util.Log).LogInfo("IIBAENSEMBLE.Task", "MSGCLASSDEF", InfoMsg)
	
	
	Quit $$$OK
}

ClassMethod QuickUpdate(MsgDate As %String = "")
{
	
	
	set InfoMsg = "Request Completed:  Begin MSGCLASSDEF at "_$ZDT($H)_" |   "
	
	set SourceConfigName="",MessageBodyClassName=""
	set NameSpace=$ZNSPACE
	
	If (MsgDate="" ) {
		S MsgDate=$ZDATE($H,3)
		
	} else {
		s MsgDate=$ZDT($ZDH(MsgDate),3)
	}
	
	If ( MsgDate '="" ) {
		s start=MsgDate_" 00:00:00"
		s end=MsgDate_" 23:59:59"
		
		// w "dates: "_start_" to "_end,!
			
		&sql(DECLARE C3 CURSOR FOR 
		 	SELECT DISTINCT SourceConfigName,MessageBodyClassName INTO :SourceConfigName,:MessageBodyClassName
			 FROM Ens.MessageHeader 
			 where (TimeCreated > :start) and (TimeCreated < :end) 
			 AND MessageBodyClassName IS NOT NULL )
	
			&sql(OPEN C3)
			For { &sql(FETCH C3)  Quit:SQLCODE'=0 
			
				// w !,SourceConfigName,MessageBodyClassName
			
				&sql(INSERT INTO IIBAENSEMBLE_Task.TaskItemDefinition (Namespace,ItemType,ItemName,ItemValue) 
					VALUES (:NameSpace,'MsgClassDef^S',:SourceConfigName,:MessageBodyClassName))
			
			}
		&sql(CLOSE C3)
	
		&sql(DECLARE C4 CURSOR FOR 
		 	SELECT DISTINCT TargetConfigName,MessageBodyClassName INTO :SourceConfigName,:MessageBodyClassName
		 	FROM Ens.MessageHeader 
		 	where ( TimeCreated > :start ) and ( TimeCreated < :end ) 
		 	AND MessageBodyClassName IS NOT NULL )
	
			&sql(OPEN C4)
			For { &sql(FETCH C4)  Quit:SQLCODE'=0 
			
				// w !,SourceConfigName,MessageBodyClassName
			
				&sql(INSERT INTO IIBAENSEMBLE_Task.TaskItemDefinition (Namespace,ItemType,ItemName,ItemValue) 
				VALUES (:NameSpace,'MsgClassDef^T',:SourceConfigName,:MessageBodyClassName))
			
		}
		&sql(CLOSE C4)
	}
	
	set InfoMsg = InfoMsg_"End MSGCLASSDEF at "_$ZDT($H)
	
	//do ##class(Ens.Util.Log).LogInfo("IIBAENSEMBLE.Task", "MSGCLASSDEF", InfoMsg)
	Q InfoMsg
}

}
