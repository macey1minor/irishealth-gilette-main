Include (%occInclude, Ensemble)

Class GC.CernerGetData2019 Extends %Persistent
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

// 06-10-2019 add search of fin by mrn and dos  lgc.sp_HL7_Get_FIN_By_MRN_DOS

//            Parameter 1: MRN  Parameter 2: DOS

// 06-10-2019 search for insurance using fin    lgc.sp_HL7_Get_Insurance_By_FIN_And_Rank

//            Parameter 1: FIN  Parameter 2: Rank

// 06-10-2019 SQLDBDEV16\DEV16 and SQLDBTEST16\DBTEST16 database EDW_IS both contain Prod data - current to previous day

ClassMethod CernerGetPatientInfoByFin(Fin As %String(MAXLEN=50)) As %String
{
	set tableMRNbyFin = ""
	Set conn=##class(%SQLGatewayConnection).%New()
    //set sc = conn.GetConnection("EDWCerner",360)
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
     Set tableMRNbyFin = res.GetData(1)
     //Set tDOB = res.GetData(3)
     //Set tFIN = res.GetData(2)
    } 
    Set sc=conn.Disconnect()
    Quit tableMRNbyFin
}

ClassMethod CernerGetPatientInfoByName(LastName As %String(MAXLEN=100), FirstName As %String(MAXLEN=100), MiddleName As %String(MAXLEN=100)) As %String
{
	//DOS should come in as  YYYYMMDD
	Set tComma = ","
	Set tQuote = "'"
	set tableMRNbyName = ""
    Set conn=##class(%SQLGatewayConnection).%New()
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
    // Write !,"tproc="_ tproc
    // $$$TRACE("PROC="_tproc)
    If $$$ISERR(sc) do $System.Status.DisplayError(sc) quit
    Set sc=res.Execute()
    If $$$ISERR(sc) do $System.Status.DisplayError(sc) quit
    While res.Next() 
    {  
      // Write !," MRN= ",res.GetData(1),",FIN= ",res.GetData(2) ,",DOB= ",res.GetData(3) ,",HSC= ",res.GetData(4) ,", Admit=",res.GetData(5) 
     Set tableMRNbyName = res.GetData(1)
     //Set tDOB = res.GetData(3)
     //Set tFIN = res.GetData(2)
    }
    // $$$TRACE("MRNData="_tableMRNbyName)
    Set sc=conn.Disconnect() 
    Quit tableMRNbyName
}

ClassMethod CernerCheckOPMsgEncounter(MRN As %String(MAXLEN=50)) As %String
{
	//Ensemble must be set as db reader in edw_is
	// Used for Check for existing encounter
	Set tTotalCnt = ""
	Set conn=##class(%SQLGatewayConnection).%New()
	//set sc = conn.GetConnection("EDWCerner",360)
    //Set sc=conn.Connect("Ensemble2TestEdwODS_PocCertSQL64","Ensemble","gtwy2010")
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

ClassMethod CernerGetFinByMRNDos(MRN As %String(MAXLEN=50), DOS As %String(MAXLEN=8)) As %String
{
	//DOS should come in as  YYYYMMDD
	Set tComma = ","
	Set tQuote = "'"
	set tFINbyMRNDos = ""
    Set conn=##class(%SQLGatewayConnection).%New()
    // Set sc=conn.Connect("EnsembleEdwCernerDev_EDW_IS","Ensemble","gtwy2010")
    //  read Prod DB
    Set sc=conn.Connect("EnsembleEdwCernerProd_EDW_IS","Ensemble","gtwy2010")
    If $$$ISERR(sc) do $System.Status.DisplayError(sc) quit
    Set res=##class(%ResultSet).%New("%DynamicQueryGW:SQLGW")
    Set parmMRN = MRN
    Set parmDOS = DOS

    set tprocName = "lgc.sp_HL7_Get_FIN_By_MRN_DOS "
	SET tproc = tprocName_tQuote_parmMRN_tQuote_tComma_tQuote_parmDOS_tQuote
	
    Set sc=res.Prepare(tproc,,conn)
    // Write !,"tproc="_ tproc
    // $$$TRACE("PROC="_tproc)
    If $$$ISERR(sc) do $System.Status.DisplayError(sc) quit
    Set sc=res.Execute()
    If $$$ISERR(sc) do $System.Status.DisplayError(sc) quit
    Set tComma = ""
    Set tFINCount=0
    While res.Next() 
    {  
      // Write !," tFINbyMRNDos= ",res.GetData(1),"-",res.GetData(2),"-",res.GetData(3)
      // Write !," tFINbyMRNDos= ",res.GetData(1),"-",res.GetData(2)
     // Set tFINbyMRNDos = res.GetData(1)_"-"_res.GetData(2)_"-"_res.GetData(3)
     //Set tFINbyMRNDos = res.GetData(1)_"-"_res.GetData(2)
     //Set tFINbyMRNDos = tComma_tFINbyMRNDos_res.GetData(1)
     Set tFINbyMRNDos = tFINbyMRNDos_tComma_res.GetData(1)
     Set tFINCount=tFINCount+1
     Set tComma = ","

    }
      // $$$TRACE("getdata-tFINbyMRNDos="_tFINbyMRNDos)
    Set sc=conn.Disconnect() 
    Quit tFINbyMRNDos_"Count="_tFINCount
}

ClassMethod CernerGetFinInsurance(Fin As %String(MAXLEN=50), InsuranceRank As %String) As %String
{
	//DOS should come in as  YYYYMMDD
	Set tComma = ","
	Set tQuote = "'"
	set tInsName = ""
    Set conn=##class(%SQLGatewayConnection).%New()
    // Set sc=conn.Connect("EnsembleEdwCernerDev_EDW_IS","Ensemble","gtwy2010")
    //   read Prod DB
    Set sc=conn.Connect("EnsembleEdwCernerProd_EDW_IS","Ensemble","gtwy2010")
    
    If $$$ISERR(sc) do $System.Status.DisplayError(sc) quit
    Set res=##class(%ResultSet).%New("%DynamicQueryGW:SQLGW")
    Set parmFIN = Fin
    Set parmRank = InsuranceRank

    // $$$TRACE("getdata-b4-fin-rank="_parmFIN_" "_parmRank)

    set tprocName = "lgc.sp_HL7_Get_Insurance_By_FIN_And_Rank "
	SET tproc = tprocName_tQuote_parmFIN_tQuote_tComma_parmRank
	
    Set sc=res.Prepare(tproc,,conn)
      // Write !,"tproc="_ tproc
      // $$$TRACE("PROC="_tproc)
      // $$$TRACE("ISERR="_$$$ISERR(sc))
      
    If $$$ISERR(sc) do $System.Status.DisplayError(sc) quit
    Set sc=res.Execute()
       // $$$TRACE("ISERR-resexecute="_$$$ISERR(sc))
       
       
    // if error condition set insurance name = *NO Insurance Found*
    Set tNoInsurance="*NO Insurance Found*"
    If $$$ISERR(sc) quit tNoInsurance
    // If $$$ISERR(sc) do $System.Status.DisplayError(sc) quit
    
    While res.Next() 
    {  
     // Write !," tInsName= ",res.GetData(1)
     Set tInsName = res.GetData(1)

    }
    // $$$TRACE("getdata-tInsName="_tInsName)
    Set sc=conn.Disconnect() 
    Quit tInsName
}

Storage Default
{
<Data name="CernerGetData2019DefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
</Data>
<DataLocation>^GC.CernerGetData2019D</DataLocation>
<DefaultData>CernerGetData2019DefaultData</DefaultData>
<IdLocation>^GC.CernerGetData2019D</IdLocation>
<IndexLocation>^GC.CernerGetData2019I</IndexLocation>
<StreamLocation>^GC.CernerGetData2019S</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
