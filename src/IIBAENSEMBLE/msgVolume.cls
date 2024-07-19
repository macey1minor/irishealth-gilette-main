/// Copyright 2007 by Inland Imaging Business Associates
Class IIBAENSEMBLE.msgVolume Extends %Persistent
{

Property IDMsgHdr As %String(MAXLEN = 100);

Property Source As %String(MAXLEN = 100);

Property SourceType As %String;

Property TimeCreated As Ens.DataType.UTC;

Property hh As %String;

Property mi As %String;

ClassMethod Execute()
{
	do ##class(IIBAENSEMBLE.msgVolume).delete()
	do ##class(IIBAENSEMBLE.msgVolume).insert()
	do ##class(IIBAENSEMBLE.msgVolume).selectwrite()
}

ClassMethod delete()
{
 &sql(delete from IIBAENSEMBLE.msgVolume)
}

//ClassMethod insert(dttmStart As %String = "2007-04-24 07:00:00", dttmEnd As %String = "2007-04-25 06:59:59")

ClassMethod insert()
{
	set dttmStart = $ZDT($H-2,3)_" 07:00:00"
	set dttmEnd = $ZDT($H-1,3)_" 06:59:59"
	
	
	
	&sql(
	
	insert into IIBAENSEMBLE.msgVolume 
 
		(IDmsghdr, source, TimeCreated, hh, mi)

	select 
		ID
		,SourceConfigName
		,TimeCreated
		,CASE 
			WHEN DATEPART(dd,TimeCreated)=DATEPART(dd,:dttmStart) THEN DATEPART(hh,TimeCreated)-7
			ELSE DATEPART(hh,TimeCreated)+24-7
		END
		,DATEPART(mi,TimeCreated)

	from ens.messageheader 

	where TimeCreated > :dttmStart 
	AND TimeCreated < :dttmEnd
	
	)
}

ClassMethod selectwrite(FilePath As %String = "E:\")
{
	set SQL = ""
	

	set SQL = SQL_"SELECT "
	set SQL = SQL_"cast(RIGHT('0' _ hh,2) "
	set SQL = SQL_"_ RIGHT('0' _ mi,2) as int) as mi, "
	set SQL = SQL_"RIGHT('0' _ hh,2) "
	set SQL = SQL_"_ RIGHT('0' _ mi,2) as hhmi, "
	set SQL = SQL_"count(RIGHT('0' _ hh,2) "
	set SQL = SQL_"_ RIGHT('0' _ mi,2)) as msgcount "
	set SQL = SQL_"FROM IIBAENSEMBLE.msgVolume "
	set SQL = SQL_"group by "
	set SQL = SQL_"RIGHT('0' _ hh,2) "
	set SQL = SQL_"_ RIGHT('0' _ mi,2) "
	set SQL = SQL_"order by mi "
		
	Set rset = ##class(%ResultSet).%New()
	do rset.Prepare(SQL)
	do rset.Execute()
	
	if $E(FilePath,$L(FilePath),$L(FilePath))'="\"{s FilePath=FilePath_"\"}
	
	Set file=##class(%File).%New(FilePath_"msgcount"_##class(Ens.Util.Time).FormatDateTime("%Y%m%d%H%M%S")_".csv")
	Do file.Open("WSN")
	
	Do file.WriteLine("mi,hhmi,msgcount")
	
	While (rset.Next()) {	
		Do file.WriteLine(rset.Data("mi")_","_rset.Data("hhmi")_","_rset.Data("msgcount"))
	}
		
	Do file.Close()
}

/// Return transaction counts by business type for a given day.
/// Transaction date is in ODBC format (2010-02-28)
/// Return value: Total Transactions, Business Service, Business Process, Business Operation
ClassMethod DailyStatsByType(TransactionDate As %String)
{
	
	s total="",bsvc="",bproc="",bop=""
	
	If (TransactionDate="" ) {
		s dateH=$H-2
		
	} else {
		s dateH=$ZDTH(TransactionDate,3)
	}
	s startdttm=$ZDT(dateH,3)_" 07:00:00"
	s enddttm=$ZDT(dateH+1,3)_" 06:59:59"
	
	set SQL="select count (*) as msgcount from Ens.MessageHeader"
	set SQL=SQL_" where TimeCreated > '"_startdttm_"'"
	set SQL=SQL_" AND TimeCreated < '"_enddttm_"'"
	
	Set rset = ##class(%ResultSet).%New()
	do rset.Prepare(SQL)
	do rset.Execute()
	do rset.Next()
	//w "Total Message Count: ",rset.Data("msgcount"),!
	S total=rset.Data("msgcount")
	
	
	set SQL="select count (*) as msgcount from Ens.MessageHeader"
	set SQL=SQL_" where TimeCreated > '"_startdttm_"'"
	set SQL=SQL_" AND TimeCreated < '"_enddttm_"'"
	set SQL=SQL_" And SourceBusinessType='1'"
	
	Set rset = ##class(%ResultSet).%New()
	do rset.Prepare(SQL)
	do rset.Execute()
	do rset.Next()
	//w "Business Service Message Count: ",rset.Data("msgcount"),!
	S bsvc=rset.Data("msgcount")



	set SQL="select count (*) as msgcount from Ens.MessageHeader"
	set SQL=SQL_" where TimeCreated > '"_startdttm_"'"
	set SQL=SQL_" AND TimeCreated < '"_enddttm_"'"
	set SQL=SQL_" And SourceBusinessType='2'"
	
	Set rset = ##class(%ResultSet).%New()
	do rset.Prepare(SQL)
	do rset.Execute()
	do rset.Next()
	//w "Business Process Message Count: ",rset.Data("msgcount"),!
	S bproc=rset.Data("msgcount")


	set SQL="select count (*) as msgcount from Ens.MessageHeader"
	set SQL=SQL_" where TimeCreated > '"_startdttm_"'"
	set SQL=SQL_" AND TimeCreated < '"_enddttm_"'"
	set SQL=SQL_" And TargetBusinessType='3'"
	
	Set rset = ##class(%ResultSet).%New()
	do rset.Prepare(SQL)
	do rset.Execute()
	do rset.Next()
	//w "Business Operation Message Count: ",rset.Data("msgcount"),!
	S bop=rset.Data("msgcount")
	
	
	Q total_","_bsvc_","_bproc_","_bop
}

Storage Default
{
<Data name="msgVolumeDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>IDMsgHdr</Value>
</Value>
<Value name="3">
<Value>Source</Value>
</Value>
<Value name="4">
<Value>TimeCreated</Value>
</Value>
<Value name="5">
<Value>hh</Value>
</Value>
<Value name="6">
<Value>mi</Value>
</Value>
<Value name="7">
<Value>SourceType</Value>
</Value>
</Data>
<DataLocation>^IIBAENSEMBLE.msgVolumeD</DataLocation>
<DefaultData>msgVolumeDefaultData</DefaultData>
<ExtentSize>100000</ExtentSize>
<IdLocation>^IIBAENSEMBLE.msgVolumeD</IdLocation>
<IndexLocation>^IIBAENSEMBLE.msgVolumeI</IndexLocation>
<StreamLocation>^IIBAENSEMBLE.msgVolumeS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
