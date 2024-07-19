Class IIBAENSEMBLE.PurgeProdFeeds Extends %RegisteredObject
{

ClassMethod Purge(Output pDeletedCount As %Integer) As %Status
{
	s %tID = "", %tBodyId = ""
	Set tSC=$$$OK, SQLCODE=0, pDeletedCount=0, pDeletedCount("bodies")=0

	&sql(DECLARE C2 CURSOR FOR
		Select ID,MessageBodyId Into :%tID,:%tBodyId From Ens.MessageHeader
			Where (MessageBodyClassName = 'EnsLib.HL7.Message'
				AND SourceConfigName IN ('MEDICALISPRO.BPROC.RISTOMEDICALIS', 'PASSTHRU.BPROC.RADFLOW', 'PASSTHRU.BSVC.ICTCP')))
	&sql(OPEN C2)
 	For {
	 	&sql(FETCH C2)  Quit:SQLCODE
 		
 		If %tBodyId'=""
 		{
			Set tSC1=$zobjclassmethod("EnsLib.HL7.Message","%DeleteId",%tBodyId)

			Set pDeletedCount("bodies")=pDeletedCount("bodies")+$$$ISOK(tSC1)
 		}

		&sql(DELETE From Ens.MessageHeader Where ID = :%tID)
		Set pDeletedCount=pDeletedCount+%ROWCOUNT
	} Set tCode=SQLCODE &sql(CLOSE C2) Set:'SQLCODE SQLCODE=tCode

	Quit tSC
}

}
