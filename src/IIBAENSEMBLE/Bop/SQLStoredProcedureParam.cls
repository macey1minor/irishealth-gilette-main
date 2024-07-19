/// Copyright 2014 Nuvodia, LLC
/// Outbound for SQL Stored Procedure indentified in the <PROPERTY>StoredProcName</PROPERTY>.
/// It Maps the parameters to a Cache' Object defined by  <PROPERTY>SpMessageClass</PROPERTY>.
/// In this class the Properties parameters must define the the <PARAMETER>EXTERNALSQLTYPE</PARAMETER> and <PARAMETER>MAX_LEN</PARAMETER> if necessary.
/// See the EnsSQLTypes.INC to find definitions, but here are the commonly used  <PARAMETER>EXTERNALSQLTYPE</PARAMETER>s:
/// #; *** SQL.H ***
/// #; SQL data type codes 
/// #define SqlUnknownType     0 /* SqlTypeNull */
/// #define SqlChar            1
/// #define SqlNumeric         2
/// #define SqlDecimal         3
/// #define SqlInteger         4
/// #define SqlSmallint        5
/// #define SqlFloat           6
/// #define SqlReal            7
/// #define SqlDouble          8
/// #define SqlDateTime        9
/// #define SqlVarchar         12
/// #; One-parameter shortcuts for date/time data types 
/// #define SqlTypeDate        91
/// #define SqlTypeTime        92
/// #define SqlTypeTimestamp   93
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
Class IIBAENSEMBLE.Bop.SQLStoredProcedureParam Extends Ens.BusinessOperation [ ProcedureBlock ]
{

Parameter ADAPTER = "EnsLib.SQL.OutboundAdapter";

Parameter INVOCATION = "Queue";

/// The request Message Class Name.  It must extend form <CLASS>%Persistent</CLASS> class
Property SpMessageClass As %String;

/// The name of the Stored Procedure to execute on the DSN data source.
Property StoredProcName As %String;

/// Multidimensional Array populated by this process.
Property IOParameters As %String [ MultiDimensional ];

Parameter SETTINGS As %String = "SpMessageClass,StoredProcName";

Method OnMessage(pRequest As %Persistent, Output pResponse As Ens.Response) As %Status
{
	$$$TRACE("Processing a message.../"_..SpMessageClass_"/"_..StoredProcName)
	#dim tSC = $$$OK
	
	// used in inline &sql statement as parameter.
	set msgClass = ..SpMessageClass
	set ParmCount = 0
	
	&sql(
		Select Count(*) into:ParmCount 
		from %Dictionary.PropertyDefinition 
		where parent =:msgClass
	)
	
	set pIOParameters = ParmCount
	
	$$$TRACE("Getting sp/message class parameters: "_"Select Name, InitialExpression, Parameters, Type from %Dictionary.PropertyDefinition where parent = '"_..SpMessageClass_"' Order by SequenceNumber")
	Set rs = ##class(%ResultSet).%New()
	Do rs.Prepare("Select Name, InitialExpression, Parameters, Type from %Dictionary.PropertyDefinition where parent = '"_..SpMessageClass_"' Order by SequenceNumber")
	set tSC = rs.Execute() 
	Quit:$$$ISERR(tSC) tSC
	
	set count = 1
	
	#DIM xIO as %String = ""
	#Dim spValueList as %String = ""
	#DIM xcall as %String = ""
	
	/*
	//set initial return value as parameter:
	set pIOParameters = pIOParameters + 1
	set pIOParameters(count,"SqlType") = 4
	set pIOParameters(count,"IOType") = 4
	set pIOParameters(count,"LOB") = 0
	set pIOParameters(count,"Bin") = 0
	set count = count + 1
	*/
	
	$$$TRACE("putting together the parameters")
	
	While (rs.Next()) {
		//get property definitions from result set:
		set propertyname = rs.Get("Name") 
		Set InitialExpression = rs.Get("InitialExpression")
		set parameters = rs.Get("Parameters")
		set type = rs.Get("Type")
		
		set pIOParameters(count) = $PROPERTY(pRequest,propertyname)
		
		Set tSC = ..GetParmProperties(pIOParameters(count), parameters, type, .SqlType, .Precision, .IsBlob,.IsBinary)
		quit:$$$ISERR(tSC)
		
		/* Set other parameter values */
		set pIOParameters(count,"SqlType") = SqlType
		if (Precision'=""){		
			set pIOParameters(count,"Prec") = Precision
		}
		set pIOParameters(count,"IOType") = 1
		set pIOParameters(count,"LOB") = IsBlob
		set pIOParameters(count,"Bin") = IsBinary
		if (IsBlob){
			set pIOParameters(count,"UseLOBLen")=1 
		}
		//QUIT:$$$ISERR(tSC)
		
		set xIO = xIO_"i"
		//set xcall = xcall_",@"_propertyname_"=?"
			
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
		
		$$$TRACE(propertyname_":"_pIOParameters(count)_" Prec:"_Precision_" SqlType: "_SqlType_" isBlob: "_IsBlob_" ItemNo: "_count)

		set count = count + 1
	
	}
	
	set $P(xcall,",?",count)=""
	set $P(xcall,"?",1)=""
	
	//set xIO = "o"_xIO
	//set tStoredProc = "{ ? = call "_..StoredProcName_"("_xcall_")}"
	set tStoredProc = "{ call "_..StoredProcName_"("_xcall_")}"
	
	$$$TRACE(tStoredProc_"/"_xIO)
	$$$TRACE("Values: "_spValueList)
	Set tSC = ..Adapter.ExecuteProcedureParmArray(.snap,.Output,tStoredProc,xIO,.pIOParameters) 
	$$$TRACE("Status: "_tSC)
	$$$TRACE("Output: "_Output)
	QUIT tSC
}

Method GetParmProperties(pPropertyValue As %DataType, pParameters As %String, pType As %String, Output pSqlType As %Integer, Output pPrecision As %Integer, Output pIsBlob As %Boolean, Output pIsBinary As %Boolean) As %Status
{
	set tSC = $$$OK
	// Piece out Parameters
	// example:  	",EXTERNALSQLTYPE = 12,MAXLEN = 20"
	//$$$TRACE("pParameters: "_pParameters)
	set pSqlType = "12"
	set pPrecision = ""
	
	Try
	{
	set paramList = $LFS(pParameters,",")
	
	for count=1:1:$LL(paramList)
	{
		set param = $LI(paramList,count)
		// pSqlType
		if ($P(param,"=",1)="EXTERNALSQLTYPE"){
			set pSqlType = $P(param,"=",2)
			if (pSqlType = 93){
				set pPrecision = 1
			}
		}
		// pPrecision (Max Length)
		if ($P(param,"=",1)="MAXLEN"){
			set pPrecision = $P(param,"=",2)
		}
	}
	
	} Catch errVar {
		set tSC = "0: CODE:"_errVar.Code_" Name:"_errVar.Name	
	}
	QUIT:$$$ISERR(tSC) tSC
	
	set pIsBlob = ..GetIsBlob(pPropertyValue, pType, .pIsBinary)
   	
   	quit tSC
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
