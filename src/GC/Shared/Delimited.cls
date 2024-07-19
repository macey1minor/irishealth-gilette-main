/// Base class for user-defined delimited file handling classes<br>
/// 
/// v1.0 apc 08/2009 Birth of class, based on code from DRL<br><br>
/// 
/// TODO:<br>
/// - test output code<br>
/// removed  , %XML.Adaptor
Class GC.Shared.Delimited Extends Ens.Request
{

/// This specifies the default delimiter to be used in breaking apart each record
Parameter Delimiter As %String = "|";

ClassMethod ParseLine(pLine As %String) As %RegisteredObject [ CodeMode = objectgenerator ]
{
	//build an array of property names subscripted by COLNUM
	//if properties have the default parameter of COLNUM=0, they will go at the end.
   	
   	set tClassName=%class.Name
   	do %code.WriteLine(" set oref=##class("_tClassName_").%New()")
    do %code.WriteLine(" set tLine=pLine")

	set tError=$$$OK
   	For n = 1:1:%compiledclass.Properties.Count() {
        Set tProp = %compiledclass.Properties.GetAt(n)
        if (tProp.Type="GC.Shared.DelimitedColumn") //necessary?
        	{
	        	set tName=tProp.Name
        		set tColNum=tProp.Parameters.GetAt("COLNUM")
	        	if tColNum=0 
	        		{ set tError="No COLNUM value set for property '"_tName_"'" quit}    //you need a value for COLNUM!!
	        	if '$data(tCols(tColNum)) 
	        		{set tCols(tColNum)=""}
	        	else
	        		{set tError="Duplicate column number:"_tColNum quit}
	        	
	        	//set tArray(tColNum,"Name")=tName
	        	Do %code.WriteLine(" set oref."_tName_"=$p(tLine,"""_..#Delimiter_""","_tColNum_")")
        	}
	   	}
   	
	Do %code.WriteLine(" quit oref")	
	if $$$ISERR(tError) {set tError=$$$ERROR($$$GeneralError,tError)}
	quit tError
}

/// TO BE TESTED!!!<br>
/// For output to a file or stream
Method OutputLine() As %String [ CodeMode = objectgenerator ]
{
    do %code.WriteLine(" set tLine=""""")
    For n = 1:1:%compiledclass.Properties.Count() {
        Set tProp = %compiledclass.Properties.GetAt(n)

        if (tProp.Type="GC.Shared.DelimitedColumn")   //necessary?
        	{
	        	set tName=tProp.Name
	        	set tColNum=tProp.Parameters.GetAt("COLNUM")
	        		        	
	        	//Need to fix this line.			
	        	Do %code.WriteLine(" set $piece(tLine,"""_..#Delimiter_""","_tColNum_")=.."_tName)
	    	}
	   	}
        
	Do %code.WriteLine(" quit tLine")	
	quit $$$OK
}

Storage Default
{
<Type>%Storage.Persistent</Type>
}

}
