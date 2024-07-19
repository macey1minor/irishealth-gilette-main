Include Ensemble

/// Removes purged objects from a queue list. Current objects will remain.
Class IIBAENSEMBLE.Task.NoObjectQueuePurge
{

ClassMethod RemoveObjectsFromQueue(pQueueName As %String = "") As %Status
{
	if pQueueName="" Quit $$$ERROR($$$EnsErrGeneral,"Invalid QueueName parameter")
	Set tQRef=$S($D($$$EnsQueue):$name($$$EnsQueue), 1:$name($$$EnsSuspended($$$SystemName,"Ens.Queue")))
	if $data(@tQRef@(pQueueName))=0 Quit $$$ERROR($$$EnsErrGeneral,"Queue '"_pQueueName_"' does not exist")
	set tSC=$$$OK
	lock +^Ens.Queue(pQueueName)
	set tPriority=0 for  {
		set tPriority=$o(@tQRef@(pQueueName,tPriority)) quit:tPriority=""
		set tIndex="" for  {
			set tIndex=$o(@tQRef@(pQueueName,tPriority,tIndex)) quit:tIndex=""
			set tSC1=..AbortPurgedItems(pQueueName,tPriority,tIndex)
			if $$$ISERR(tSC1) set tSC=$$$ADDSC(tSC,tSC1)
		}
	}
	lock -^Ens.Queue(pQueueName)
	quit tSC
}

ClassMethod AbortPurgedItems(pQueueName As %String = "", pPriority As %Integer = 0, pIndex As %Integer = 0) As %Status
{
	If pQueueName="" Quit $$$ERROR($$$EnsErrGeneral,"Invalid QueueName parameter")
	If pPriority=0 Quit $$$ERROR($$$EnsErrGeneral,"Invalid Priority parameter")
	Set tQRef=$S($D($$$EnsQueue):$name($$$EnsQueue), 1:$name($$$EnsSuspended($$$SystemName,"Ens.Queue")))
	Set $ZT="Trap",tSC=$$$OK
	Do {
		Lock +@tQRef@(pQueueName)
		If $data(@tQRef@(pQueueName,pPriority,pIndex))=0 Set tSC=$$$ERROR($$$EnsErrGeneral,"QueueItem does not exist - "_pQueueName_":"_pPriority_":"_pIndex) Quit
		Set tId=@tQRef@(pQueueName,pPriority,pIndex)
		Set tMsg=##Class(Ens.MessageHeader).%OpenId(tId)
		If tMsg=$$$NULLOREF {
			Kill @tQRef@(pQueueName,pPriority,pIndex)
			Set @tQRef@(pQueueName,0,"count")=@tQRef@(pQueueName,0,"count")-1
		}
		//Set tMsg=##Class(Ens.MessageHeader).%OpenId(tId)
		//If tMsg=$$$NULLOREF Set tSC=$$$EnsError($$$EnsErrGeneral,"MessageHeader #"_tId_" can not be loaded") Quit
		//Do tMsg.SetStatus($$$eMessageStatusAborted)
		//If tMsg.ReturnQueueName'="" && (tQRef=$name($$$EnsQueue)) {
			//Set tSC = tMsg.NewErrorResponse(.tResponseHeader,$$$ERROR($$$EnsErrGeneral,"Message '"_tId_"' aborted.")) Quit:$$$ISERR(tSC)
			//Set tSC = ##class(Ens.Queue).EnQueue(tResponseHeader) Quit:$$$ISERR(tSC)
		//}
		Lock -@tQRef@(pQueueName)
	} While 0
Exit
	Quit tSC
Trap
	Set $ZT=""
	Lock:$D(tSC) -@tQRef@(pQueueName)
	Set tSC=$$$EnsSystemError
	Goto Exit
}

}
