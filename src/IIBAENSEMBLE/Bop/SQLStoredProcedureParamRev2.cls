/// SQLStoredProcedureParamRev2 copy of SQLStoredProcedureParamTestConn 07/22/2015 By: Al Johnson
/// Does a GetDate and quits if error on connection so detail not lost
/// Last Modified: 05/11/2015 By:Ellen Leichtma
/// Add and testing ..Adapter.TestConnection(0)  
/// Will need to Deploy to PROD and TRAIN  
/// 
/// Last Modified: 8/14/2014 By: Paul Hegel to include changes to property definitions class.  
/// SqlType and Precission were getting defaults and not actual values.  
/// Will need to Deploy to PROD and TRAIN after Ensemble 2014 upgrade.
/// 
/// Last Modified: 7/24/2014 By: Paul Hegel For Ensemble 2012 only (TESTTRAIN and PROD) <br/>
/// Last Updated in Prod:  Don't deploy this to Ensemble 2014 (DEV needs orginal cls)<br/>
/// Copyright 2014 Nuvodia, LLC<br/>
/// Outbound for SQL Stored Procedure indentified in the <PROPERTY>StoredProcName</PROPERTY>.<br/>
/// It Maps the parameters to a Cache' Object defined by  <PROPERTY>SpMessageClass</PROPERTY>.<br/>
/// In this class the Properties parameters must define the the <PARAMETER>EXTERNALSQLTYPE</PARAMETER> and <PARAMETER>MAX_LEN</PARAMETER> if necessary.<br/>
/// See the EnsSQLTypes.INC to find definitions, but here are the commonly used  <PARAMETER>EXTERNALSQLTYPE</PARAMETER>s:<br/>
/// #; *** SQL.H ***<br/>
/// #; SQL data type codes 
/// #define SqlUnknownType     0 /* SqlTypeNull */<br/>
/// #define SqlChar            1<br/>
/// #define SqlNumeric         2<br/>
/// #define SqlDecimal         3<br/>
/// #define SqlInteger         4<br/>
/// #define SqlSmallint        5<br/>
/// #define SqlFloat           6<br/>
/// #define SqlReal            7<br/>
/// #define SqlDouble          8<br/>
/// #define SqlDateTime        9<br/>
/// #define SqlVarchar         12<br/>
/// #; One-parameter shortcuts for date/time data types <br/>
/// #define SqlTypeDate        91<br/>
/// #define SqlTypeTime        92<br/>
/// #define SqlTypeTimestamp   93<br/>
/// #; *** SQLUCODE.H ***
/// #define SqlWChar           (-8)
/// #define SqlWVarchar        (-9)
/// #define SqlWLongVarchar    (-10) = %Stream.GlobalCharacter  (cache' object script type) 
/// #define SqlCWChar          $$$SqlWChar
/// #; *** SQLEXT.H ***
/// #; SQL extended datatypes
/// #define SqlDate            9
/// #define SqlInterval        10
/// #define SqlTime            10
/// #define SqlTimestamp       11
/// #define SqlLongVarchar     (-1) = %Stream.GlobalCharacter  (cache' object script type)
/// #define SqlBinary          (-2)
/// #define SqlVarBinary       (-3)
/// #define SqlLongVarBinary   (-4) = %Stream.GlobalBinary  (cache' object script type) 
/// #define SqlBigint          (-5)
/// #define SqlTinyint         (-6)
/// #define SqlBit             (-7)
/// #define SqlGuid            (-11)
/// Documentation: http://localhost:57773/csp/docbook/DocBook.UI.Page.cls?KEY=ESQL_adapter_methods_creating#ESQL_parameter_in_multidim_sqltype_ctype
Class IIBAENSEMBLE.Bop.SQLStoredProcedureParamRev2 Extends Ens.BusinessOperation [ ProcedureBlock ]
{

Parameter ADAPTER = "EnsLib.SQL.OutboundAdapter";

Parameter INVOCATION = "Queue";

/// The request Message Class Name.  It must extend form <CLASS>%Persistent</CLASS> class
Property SpMessageClass As %String;

/// The name of the Stored Procedure to execute on the DSN data source.
Property StoredProcName As %String;

/*
/// Do Workaround code when using new ODBC Driver.
Property UseWorkaround As %Boolean;
*/
/// Multidimensional Array populated by this process.
Property IOParameters As %String [ MultiDimensional ];

Parameter SETTINGS As %String = "SpMessageClass,StoredProcName";

Method OnMessage(pRequest As %Persistent, Output pResponse As Ens.Response) As %Status
{
	// $$$TRACE("Processing a message.../"_..SpMessageClass_"/"_..StoredProcName)
	#dim tSC = $$$OK
	#dim Output as %ListOfDataTypes
	set tSC = ..Adapter.ExecuteQuery("","Select GetDate()","")
    // $$$TRACE("tSC after Getdate with Quit if error "_tSC)
    quit:$$$ISERR(tSC) tSC  //Added by ellen 06/25/2016
	// used in inline &sql statement as parameter.
	set msgClass = ..SpMessageClass
	set ParmCount = 0
	//set Output = ""
	
	&sql(
		Select Count(*) into:ParmCount 
		from %Dictionary.PropertyDefinition 
		where parent =:msgClass
	)
	
	set pIOParameters = ParmCount +1
	
	// $$$TRACE("Getting sp/message class parameters: "_"Select Name, InitialExpression, Parameters, Type from %Dictionary.PropertyDefinition where parent = '"_..SpMessageClass_"' Order by SequenceNumber")
	Set rs = ##class(%ResultSet).%New()
	Do rs.Prepare("Select ID, Name, InitialExpression, Parameters, Type from %Dictionary.PropertyDefinition where parent = '"_..SpMessageClass_"' Order by SequenceNumber")
	set tSC = rs.Execute() 
	Quit:$$$ISERR(tSC) tSC
	
	
	#DIM xIO as %String = ""
	#Dim spValueList as %String = ""
	#DIM xcall as %String = ""
	
	set count = 1
	
	//set initial return value as parameter:
	/**/
	set pIOParameters(count,"IOType") = 4
	set pIOParameters(count,"SqlType") = 4
	set pIOParameters(count,"LOB") = 0
	set pIOParameters(count,"Bin") = 0
	
	set count = count + 1
	
	
	
    $$$TRACE("putting together the parameters")
	
	While (rs.Next()) {
		//get property definitions from result set:
		set propertyname = rs.Get("Name") 
		Set InitialExpression = rs.Get("InitialExpression")
		set propObject = ##class(%Dictionary.PropertyDefinition).%OpenId(rs.Get("ID"))
		//set parameters = propObject.Parameters
		set SqlType = propObject.Parameters.GetAt("EXTERNALSQLTYPE")
		set Precision = propObject.Parameters.GetAt("MAXLEN")
		set type = rs.Get("Type")

		set pIOParameters(count) = $PROPERTY(pRequest,propertyname)
		
		//Set tSC = ..GetParmProperties(pIOParameters(count), parameters, type, .SqlType, .Precision, .IsBlob,.IsBinary)
		set IsBlob = ..GetIsBlob(pIOParameters(count), type, .IsBinary)

		/* Set other parameter values */
		set pIOParameters(count,"SqlType") = SqlType
		if (Precision'=""){		
			set pIOParameters(count,"Prec") = Precision
		}
		set pIOParameters(count,"IOType") = 1
		if (IsBlob=1){
			set pIOParameters(count,"LOB") = IsBlob
			if (IsBinary=1) {
				set pIOParameters(count,"Bin") = IsBinary
			}
			set pIOParameters(count,"UseLOBLen")=1 
			s pIOParameters(count,"CType")=-2 
		}
		//QUIT:$$$ISERR(tSC)
		
		set xIO = xIO_"i"
			
		if pIOParameters(count) = "" { 
			if ( InitialExpression["$" ){
				// handle for expressions in the initial expression field.
				set ie = " " 
				set exp = "(out) set out = "_InitialExpression
				Xecute (exp, .ie)
				set pIOParameters(count) = ie	
			}
			else{
				set pIOParameters(count) = $E(InitialExpression,2,$L(InitialExpression)-1) 
			}
		}

		//set value list except ignore blobs
		if (IsBlob) {
			set value="[%Stream] "_$Length(pIOParameters(count))}
		else {
			set value= pIOParameters(count)}
		set spValueList = spValueList_value_","	
		
		  // $$$TRACE(propertyname_":"_pIOParameters(count)_" Prec:"_Precision_" SqlType: "_SqlType_" isBlob: "_IsBlob_" ItemNo: "_count)

		set count = count + 1
	
	}
	
	set $P(xcall,",?",count-1)=""
	set $P(xcall,"?",1)=""
	
	set xIO = "o"_xIO // _"*"
	//set xIO =""
	set tStoredProc = "{ ?= CALL "_..StoredProcName_"("_xcall_") }"
	
    $$$TRACE(tStoredProc_"/"_xIO)
    $$$TRACE("Values: "_spValueList)

	Set tSC = ..Adapter.ExecuteProcedureParmArray(.snap,.Output,tStoredProc,xIO,.pIOParameters) 
    $$$TRACE("Status after Exec: "_tSC)
	set tSC = ..Adapter.Connected
	// $$$TRACE("Connected status after Exec: "_tSC)
	// $$$TRACE("Output: "_Output)
	quit:$$$ISERR(tSC) tSC

	s pResponse = snap

	QUIT tSC
}

Method GetIsBlob(pPropertyValue As %DataType, pType As %String, Output pIsBinary As %Boolean) As %Boolean
{
	//Figure out if property pIsBlob and is it BinaryOrText blob.  Blob are extended by %Stream so let's figure that out...
	//check that cls extends %Stream.Object
   
   	// Do Binary (Blob) check first
    set pIsBinary =(pType = "%Stream.GlobalBinary")
    Try {
	    if (pIsBinary=0){
	   		Set pIsBinary=$classmethod($classname(pPropertyValue),"%Extends","%Stream.FileBinary")}
	   	if (pIsBinary=0){
	   		Set pIsBinary=$classmethod($classname(pPropertyValue),"%Extends","%Stream.GblBinCompress")}
	   	if (pIsBinary=0){
	   		Set pIsBinary=$classmethod($classname(pPropertyValue),"%Extends","%Stream.GlobalBinary")}
	  	if (pIsBinary=0){
	   		Set pIsBinary=$classmethod($classname(pPropertyValue),"%Extends","%Stream.NullBinary")}
	   	if (pIsBinary=0){
	   		Set pIsBinary=$classmethod($classname(pPropertyValue),"%Extends","%Stream.TmpBinary")}
    } Catch {
         Set pIsBinary=0
    }
    
    // Do Text blob check next       
    set isBlobText = (pType = "%Stream.GlobalCharacter")
    Try {
	   if (isBlobText=0){
       		Set isBlobText=$classmethod($classname(pPropertyValue),"%Extends","%Stream.FileCharacter")}
       if (isBlobText=0){
       		Set isBlobText=$classmethod($classname(pPropertyValue),"%Extends","%Stream.GblChrCompress")}
       if (isBlobText=0){
       		Set isBlobText=$classmethod($classname(pPropertyValue),"%Extends","%Stream.GlobalCharacter")}
       if (isBlobText=0){
       		Set isBlobText=$classmethod($classname(pPropertyValue),"%Extends","%Stream.NullCharacter")}
       if (isBlobText=0){
       		Set isBlobText=$classmethod($classname(pPropertyValue),"%Extends","%Stream.TmpCharacter")}
       } Catch {
           Set isBlobText=0
           }
    //if either were set then it is a blob       
   	set pIsBlob = (pIsBinary=1 || isBlobText=1)	
   	
   	quit pIsBlob
}

}
