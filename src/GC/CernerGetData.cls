Include (%occInclude, Ensemble)

Class GC.CernerGetData Extends %Persistent
{

// http://172.25.68.31:57772/csp/docbook/DocBook.UI.Page.cls?KEY=BGOD_gateway#BGOD_gateway_program_odbc

// http://172.25.68.31:57772/csp/documatic/%25CSP.Documatic.cls?APP=1&CLASSNAME=%25Library.ResultSet&LIBRARY=%25SYS

// encntr_ID ,MED_SERVICE,PERSON_ID

// , NAME_LAST, NAME_FIRST , NAME_FULL_FORMATTED

// , FIN , MRN

// , convert (varchar,REG_DT_TM ,101) as AdmitDate

// , convert (varchar,BIRTH_DT_TM ,101) as DOB

// Ensemble needs permission in EDW_IS on each table in the stored Proc

// Stored proc are in ODS_POC

ClassMethod QESGetPatientInfoByFin(Fin As %String(MAXLEN=50)) As %String
{
	//Ensemble must be set as db reader in edw_is
	//  Used in MPILoad
	set tMRN = ""
	set tClinic = ""
	Set conn=##class(%SQLGatewayConnection).%New()
	//set sc = conn.GetConnection("EDWCerner",360)
    Set sc=conn.Connect("Ensemble2TestEdwODS_PocCertSQL64","Ensemble","gtwy2010")
    If $$$ISERR(sc) do $System.Status.DisplayError(sc) quit
    Set res=##class(%ResultSet).%New("%DynamicQueryGW:SQLGW")
	Set parmFin = Fin
	set tproc = "HL7.QESGetPatientInfoByFin "_parmFin 
	Set sc=res.Prepare(tproc,,conn)
    If $$$ISERR(sc) do $System.Status.DisplayError(sc) quit
    Set sc=res.Execute()
    If $$$ISERR(sc) do $System.Status.DisplayError(sc) quit
    
    While res.Next() 
    { // Write !," Facility = ",res.GetData(1),",DOS= ",res.GetData(2) ,",Account= ",res.GetData(3) 
     Set tClinic = res.GetData(1)
    } 
    Set sc=conn.Disconnect()
    Quit tClinic
}

ClassMethod QESGetPatientContactMethodByMRN(MRN As %String(MAXLEN=50)) As %String
{
	//Ensemble must be set as db reader in edw_is
	//  Used for MPILoad
	Set tContactMethod = ""
	Set conn=##class(%SQLGatewayConnection).%New()
	//set sc = conn.GetConnection("EDWCerner",360)
    Set sc=conn.Connect("Ensemble2TestEdwODS_PocCertSQL64","Ensemble","gtwy2010")
    If $$$ISERR(sc) do $System.Status.DisplayError(sc) quit
    Set res=##class(%ResultSet).%New("%DynamicQueryGW:SQLGW")
	Set parmMRN = MRN
	set tproc = "HL7.QESGetPatientContactMethodByMRN "_parmMRN
	Set sc=res.Prepare(tproc,,conn)
    If $$$ISERR(sc) do $System.Status.DisplayError(sc) quit
    Set sc=res.Execute()
    If $$$ISERR(sc) do $System.Status.DisplayError(sc) quit
    
    While res.Next() 
    {  
     Set tContactMethod = res.GetData(1)
    } 
    Set sc=conn.Disconnect()
    Quit tContactMethod
}

ClassMethod CernerGetPatientInfoByFin(Fin As %String(MAXLEN=50)) As %String
{
	set tMRN = ""
	Set conn=##class(%SQLGatewayConnection).%New()
    //set sc = conn.GetConnection("EDWCerner",360)
    // Set sc=conn.Connect("OdsCernerIncr","Ensemble","gtwy2010")
    // Set sc=conn.Connect("OdsCernerIncr","Ensemble","Ensemble","gtwy2010")
    Set sc=conn.Connect("OdsCernerIncr","Ensemble","gtwy2010")
    If $$$ISERR(sc) do $System.Status.DisplayError(sc) quit
    Set res=##class(%ResultSet).%New("%DynamicQueryGW:SQLGW")
	Set parmFin = Fin
	//Set parmFin = "20000430"
	set tproc = "HL7.CernerGetPatientInfoByFin "_parmFin 
    Set sc=res.Prepare(tproc,,conn)
    If $$$ISERR(sc) do $System.Status.DisplayError(sc) quit
    Set sc=res.Execute()
    If $$$ISERR(sc) do $System.Status.DisplayError(sc) quit
    While res.Next() 
    { // Write !," MRN= ",res.GetData(1),",FIN= ",res.GetData(2) ,",DOB= ",res.GetData(3) ,",HSC= ",res.GetData(4),", Name=",res.GetData(5)  ,", Admit=",res.GetData(5) 
     Set tMRN = res.GetData(1)
     //Set tDOB = res.GetData(3)
     //Set tFIN = res.GetData(2)
    } 
    Set sc=conn.Disconnect()
    Quit tMRN
}

ClassMethod CernerGetPatientInfoByName(LastName As %String(MAXLEN=100), FirstName As %String(MAXLEN=100), MiddleName As %String(MAXLEN=100)) As %String
{
	//DOS should come in as  YYYYMMDD
	Set tComma = ","
	Set tQuote = "'"
	set tMRN = ""
    Set conn=##class(%SQLGatewayConnection).%New()
    // set sc = conn.GetConnection("EDWCerner",180)
    Set sc=conn.Connect("OdsCernerIncr","Ensemble","gtwy2010")
    If $$$ISERR(sc) do $System.Status.DisplayError(sc) quit
    Set res=##class(%ResultSet).%New("%DynamicQueryGW:SQLGW")
    Set parmLastName = LastName
    Set parmFirstName = FirstName
    Set parmMiddleName = MiddleName
    if parmMiddleName ="" {Set parmMiddleName = " " }
    set tprocName = "HL7.CernerGetPatientInfoByName "
	SET tproc = tprocName_tQuote_parmLastName_tQuote_tComma_tQuote_parmFirstName_tQuote_tComma_tQuote_parmMiddleName_tQuote
    Set sc=res.Prepare(tproc,,conn)
    //Write !,"tproc="_ tproc
    //$$$TRACE("PROC="_tproc)
    If $$$ISERR(sc) do $System.Status.DisplayError(sc) quit
    Set sc=res.Execute()
    If $$$ISERR(sc) do $System.Status.DisplayError(sc) quit
    While res.Next() 
    {  
      // Write !," MRN= ",res.GetData(1),",FIN= ",res.GetData(2) ,",DOB= ",res.GetData(3) ,",HSC= ",res.GetData(4) ,", Admit=",res.GetData(5) 
      //$$$TRACE("WhileLoop")
     Set tMRN = res.GetData(1)
     //Set tDOB = res.GetData(3)
     //Set tFIN = res.GetData(2)
    }
    //$$$TRACE("MRNData="_tMRN)
    Set sc=conn.Disconnect() 
    Quit tMRN
}

ClassMethod CernerCheckOPMsgEncounter(MRN As %String(MAXLEN=50)) As %String
{
	//Ensemble must be set as db reader in edw_is
	// Used for Check for existing encounter
	Set tTotalCnt = ""
	Set conn=##class(%SQLGatewayConnection).%New()
    Set sc=conn.Connect("OdsCernerIncr","Ensemble","gtwy2010")
    If $$$ISERR(sc) do $System.Status.DisplayError(sc) quit
    Set res=##class(%ResultSet).%New("%DynamicQueryGW:SQLGW")
	Set parmMRN = MRN
	set tproc = "HL7.CernerCheckOPMsgEncounter "_parmMRN
	Set sc=res.Prepare(tproc,,conn)
    If $$$ISERR(sc) do $System.Status.DisplayError(sc) quit
    Set sc=res.Execute()
    If $$$ISERR(sc) do $System.Status.DisplayError(sc) quit
    
    While res.Next() 
    {  
     Set tTotalCnt = res.GetData(1)
    } 
    Set sc=conn.Disconnect()
    Quit tTotalCnt
}

Storage Default
{
<Data name="CernerGetDataDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
</Data>
<DataLocation>^GC.CernerGetDataD</DataLocation>
<DefaultData>CernerGetDataDefaultData</DefaultData>
<IdLocation>^GC.CernerGetDataD</IdLocation>
<IndexLocation>^GC.CernerGetDataI</IndexLocation>
<StreamLocation>^GC.CernerGetDataS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
