Class IIBAENSEMBLE.MRNConversion.Queue Extends %Persistent
{

Property InputTime As %TimeStamp;

Property ProcessedTime As %TimeStamp;

Property OrgCode As %String [ Required ];

Property OldMRN As %String [ Required ];

Property NewMRN As %String [ Required ];

Property fName As %String [ Required ];

Property lName As %String [ Required ];

Property Sex As %String [ Required ];

Property DOB As %String [ Required ];

Property ConversionMsg As EnsLib.HL7.Message;

Property RegistrationMsg As EnsLib.HL7.Message;

Index ProcessedTime On ProcessedTime;

Index RefID On (OrgCode, NewMRN) [ IdKey, Unique ];

Index OldMRN On (OrgCode, OldMRN);

Property LastServiceDate As %TimeStamp;

ClassMethod AddRecord(Version As %String, OrgCode As %String, OldMRN As %String, NewMRN As %String, fName As %String, lName As %String, DOB As %String, Sex As %String, LastServiceDate As %String) As %Status
{
	#dim tSC As %Status = $$$OK
	Set ADTmsg = ""
	//Save current object
	Set tStore = ##class(IIBAENSEMBLE.MRNConversion.Queue).%New()
	Set tStore.OrgCode = OrgCode
	Set tStore.OldMRN = OldMRN
	Set tStore.NewMRN = NewMRN
	Set tStore.fName = fName
	Set tStore.lName = lName
	Set tStore.DOB = DOB
	Set tStore.Sex = Sex
	Set tStore.InputTime = $ZDATETIME($HOROLOG,3,1)
	//translate to date here and set to default date if invalid 
	Set tStore.LastServiceDate = $ZD($ZDH(LastServiceDate,1,,,,,,,"62947"),3)
	Set tSC = tStore.%Save() q:'tSC tSC
	//update current object with hl7 message using dtl.
	Set tSC = ##class(IIBAENSEMBLE.MRNConversion.HL7Message).Transform(tStore,.HL7msg)
	if Version = "44"
	{
		Set tSC = ##class(IIBAENSEMBLE.MRNConversion.HL7ADTMessage).Transform(tStore,.ADTmsg)
	}
	Set tSC = tStore.%Open()
	Set tStore.RegistrationMsg = ADTmsg
	Set tStore.ConversionMsg = HL7msg
	Set tSC = tStore.%Save()
	Quit tSC
}

ClassMethod DeleteQueue(OrgCode As %String) As %Status
{
	set QueueRS = ##class(%ResultSet).%New()
    set sql = "select %ID "
    set sql = sql_"from IIBAENSEMBLE_MRNConversion.Queue "
    set sql = sql_"WHERE OrgCode = '"_OrgCode_"'"
    do QueueRS.Prepare(sql)
    do QueueRS.Execute()

    While QueueRS.Next(){
                                
        set ItemID = QueueRS.Get("ID")
                                                                        
        &sql(DELETE FROM IIBAENSEMBLE_MRNConversion.Queue WHERE %ID = :ItemID)
        &sql(COMMIT)
                                
        if SQLCODE '=0{
           w "Failed on: "_ItemID,!
           
               }
                                
        }
}

Storage Default
{
<Data name="QueueDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>OnInputTime</Value>
</Value>
<Value name="3">
<Value>ProcessedTime</Value>
</Value>
<Value name="4">
<Value>OrgCode</Value>
</Value>
<Value name="5">
<Value>OldMRN</Value>
</Value>
<Value name="6">
<Value>fName</Value>
</Value>
<Value name="7">
<Value>lName</Value>
</Value>
<Value name="8">
<Value>Sex</Value>
</Value>
<Value name="9">
<Value>DOB</Value>
</Value>
<Value name="10">
<Value>ConversionMsg</Value>
</Value>
<Value name="11">
<Value>NewMRN</Value>
</Value>
<Value name="12">
<Value>InputTime</Value>
</Value>
<Value name="13">
<Value>RegistrationMsg</Value>
</Value>
<Value name="14">
<Value>LastServiceDate</Value>
</Value>
</Data>
<DataLocation>^IIBAENSEMBLE.MRNConvF37D.QueueD</DataLocation>
<DefaultData>QueueDefaultData</DefaultData>
<ExtentSize>100000</ExtentSize>
<IdLocation>^IIBAENSEMBLE.MRNConvF37D.QueueD</IdLocation>
<IndexLocation>^IIBAENSEMBLE.MRNConvF37D.QueueI</IndexLocation>
<StreamLocation>^IIBAENSEMBLE.MRNConvF37D.QueueS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
