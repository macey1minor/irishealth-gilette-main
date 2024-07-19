Class GC.eDOCS.TAGDelimitedFileNuance Extends GC.Shared.Delimited
{

// Description: Properties are used for the eDOCS Tag; zFindings has rtf for Word Doc

/// Last Updated: 07/28/2016 Al Johnson 
/// Moved to Prod: xx/xx/xxxx
/// Created: July 2016 Al Johnson
///        Properties starting with z and COLNUM =>400 are filtered out when creating the tag file
///        Use for the Word doc, file name and other uses
/// Note the inherited Delimiter parameter, defaults to "|". Override here to change this
/// Parameter Delimiter As %String = "|";
/// Define the names of the pieces in each record, specifying the 
/// piece using the COLNUM dataype parameter. Make sure they are unique and > 0
Property PatientMRN As GC.Shared.DelimitedColumn(COLNUM = 1, MAXLEN = 30);

Property PatientLastName As GC.Shared.DelimitedColumn(COLNUM = 2, MAXLEN = 200);

Property PatientFirstName As GC.Shared.DelimitedColumn(COLNUM = 3, MAXLEN = 200);

Property PatientMiddleInitial As GC.Shared.DelimitedColumn(COLNUM = 4);

Property PatientDOB As GC.Shared.DelimitedColumn(COLNUM = 5);

Property EncounterID As GC.Shared.DelimitedColumn(COLNUM = 6);

Property DateOfService As GC.Shared.DelimitedColumn(COLNUM = 7);

Property CernerDocumentID As GC.Shared.DelimitedColumn(COLNUM = 8, MAXLEN = 200);

Property SourceSystem As GC.Shared.DelimitedColumn(COLNUM = 9);

Property AuthorID As GC.Shared.DelimitedColumn(COLNUM = 10);

Property AuthorLastName As GC.Shared.DelimitedColumn(COLNUM = 11, MAXLEN = 200);

Property AuthorFirstName As GC.Shared.DelimitedColumn(COLNUM = 12, MAXLEN = 200);

Property DocumentType As GC.Shared.DelimitedColumn(COLNUM = 13);

Property TranscriptionistID As GC.Shared.DelimitedColumn(COLNUM = 14, MAXLEN = 200);

Property TranscriptionistLastName As GC.Shared.DelimitedColumn(COLNUM = 15, MAXLEN = 200);

Property TranscriptionistFirstName As GC.Shared.DelimitedColumn(COLNUM = 16, MAXLEN = 200);

Property ExtSourceDocumentID As GC.Shared.DelimitedColumn(COLNUM = 17, MAXLEN = 200);

Property RevisionCount As GC.Shared.DelimitedColumn(COLNUM = 18, MAXLEN = 200);

Property VersionComment As GC.Shared.DelimitedColumn(COLNUM = 19, MAXLEN = 200);

Property LastModifiedTime As GC.Shared.DelimitedColumn(COLNUM = 20);

Property zFindings As GC.Shared.DelimitedColumn(COLNUM = 401, MAXLEN = 2000000);

Property zTagfilename As GC.Shared.DelimitedColumn(COLNUM = 402, MAXLEN = 200);

Property zNTESign As GC.Shared.DelimitedColumn(COLNUM = 403, MAXLEN = 800);

Property zFindingsComb As GC.Shared.DelimitedColumn(COLNUM = 404, MAXLEN = 2000000);

Property zTroubleShooting As GC.Shared.DelimitedColumn(COLNUM = 405, MAXLEN = 200);

Property zMSH10andMSH7 As GC.Shared.DelimitedColumn(COLNUM = 406, MAXLEN = 200);

Method OutputLine() As %String [ CodeMode = objectgenerator ]
{
   
    set strEmpty = ""
    set NewlineChar = $char(13,10)
    do %code.WriteLine(" set tLine=""""")
    For n = 1:1:%compiledclass.Properties.Count() {
		 Set tProp = %compiledclass.Properties.GetAt(n)
         if (tProp.Type="GC.Shared.DelimitedColumn" )& (tProp.Parameters.GetAt("COLNUM") < 400 ) //necessary?
        	{
	        	set tName=tProp.Name  //value in the array or line
	        	set tColNum=tProp.Parameters.GetAt("COLNUM")
	        	// replace  the nth piece of TLine with the value in tName
	            Do %code.WriteLine(" set $piece(tLine,"""_..#Delimiter_""","_tColNum_")=.."_tName)
	    	}
	   	}
   //  finally replace the |
     Do %code.WriteLine(" set tLine = $Translate(tLine,""|"") ")  
    	Do %code.WriteLine(" quit tLine") //return tLine	
	    quit $$$OK
}

Storage Default
{
<Data name="TAGDelimitedFileNuanceDefaultData">
<Subscript>"TAGDelimitedFileNuance"</Subscript>
<Value name="1">
<Value>PatientMRN</Value>
</Value>
<Value name="2">
<Value>PatientLastName</Value>
</Value>
<Value name="3">
<Value>PatientFirstName</Value>
</Value>
<Value name="4">
<Value>PatientMiddleInitial</Value>
</Value>
<Value name="5">
<Value>PatientDOB</Value>
</Value>
<Value name="6">
<Value>EncounterID</Value>
</Value>
<Value name="7">
<Value>DateOfService</Value>
</Value>
<Value name="8">
<Value>CernerDocumentID</Value>
</Value>
<Value name="9">
<Value>SourceSystem</Value>
</Value>
<Value name="10">
<Value>AuthorID</Value>
</Value>
<Value name="11">
<Value>AuthorLastName</Value>
</Value>
<Value name="12">
<Value>AuthorFirstName</Value>
</Value>
<Value name="13">
<Value>DocumentType</Value>
</Value>
<Value name="14">
<Value>TranscriptionistID</Value>
</Value>
<Value name="15">
<Value>TranscriptionistLastName</Value>
</Value>
<Value name="16">
<Value>TranscriptionistFirstName</Value>
</Value>
<Value name="17">
<Value>ExtSourceDocumentID</Value>
</Value>
<Value name="18">
<Value>RevisionCount</Value>
</Value>
<Value name="19">
<Value>VersionComment</Value>
</Value>
<Value name="20">
<Value>LastModifiedTime</Value>
</Value>
<Value name="21">
<Value>zFindings</Value>
</Value>
<Value name="22">
<Value>zTagfilename</Value>
</Value>
<Value name="23">
<Value>zNTESign</Value>
</Value>
<Value name="24">
<Value>zFindingsComb</Value>
</Value>
<Value name="25">
<Value>zTroubleShooting</Value>
</Value>
<Value name="26">
<Value>zMSH10andMSH7</Value>
</Value>
</Data>
<DefaultData>TAGDelimitedFileNuanceDefaultData</DefaultData>
<Type>%Storage.Persistent</Type>
}

}
