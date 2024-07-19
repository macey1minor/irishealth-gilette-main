/// Copyright 2007 by Inland Imaging Business Associates<p>
/// 	For creating Ensemble messages from delimited text files located at an FTP location
/// 	with each field separated by a delimiter and each message on a new line.<P>
/// 	Usage:<br>
/// 	<UL>
/// 	<LI>Create a Message Class in Studio containing properties that match the fields in the text file.</LI>
/// 		<UL>
/// 	<LI>File -&gt; New</LI>
/// 		<li>Cache Class Definition</li>
/// 		<li>Extends Ens.Request</li>
/// 		<li>Add a new property for each delimited field.</li>
/// 		</ul>
/// 	<LI>Add a Service to the production and select "Other" or "All Services" and select the Service Class as "IIBAENEMBLE.Bsvc.DelimitedFile".</li>
/// <LI>Specify the delimiter, the message class, and the target item in the settings as well as the file path and spec.</li>
/// <LI>Add a business process of class EnsLib.MsgRouter.RoutingEngine or a custom class to the production to transform the message class to HL7 or other format as needed.</li>
/// 	</ul>
Class IIBAENSEMBLE.Bsvc.DelimitedFTPFile Extends Ens.BusinessService [ ProcedureBlock ]
{

Parameter ADAPTER = "EnsLib.FTP.InboundAdapter";

/// Use "\t" for tab, "csv" for csv, and "%20" for space, otherwise, use the actual character that is the delimiter.
Property Delimiter As %String [ InitialExpression = "," ];

/// Use the name of the message class that has been created with properties that match the fields in the delimited file.
Property MessageClass As %String;

Property TargetConfigName As %String;

Parameter SETTINGS = "Delimiter,MessageClass,TargetConfigName";

Method OnProcessInput(pInput As %RegisteredObject, pOutput As %RegisteredObject) As %Status
{
	
	$$$TRACE("Input: "_pInput)
		
	#DIM FieldDelimiter as %String
	#DIM tMessageList as %List
	#DIM tMessage as %String
	
	Set FieldDelimiter=..Delimiter
	
	if (FieldDelimiter="\t") {
		s FieldDelimiter=$C(9)
	} elseif ($E(FieldDelimiter,1,2)="\x") {
		s FieldDelimiter=$C($ZH($E(FieldDelimiter,3,$L(FieldDelimiter))_"H"))
	} elseif FieldDelimiter = "%20" {
		s FieldDelimiter = $C(32)
	} elseif ( $ZCONVERT(FieldDelimiter,"L")="csv") {
		s FieldDelimiter="csv"
	}
	
	$$$TRACE("The Field Delimiter is: "_FieldDelimiter_" ("_$A(FieldDelimiter)_")")
	
	while 'pInput.AtEnd {
		
		Set tMessage=pInput.ReadLine()
		$$$TRACE(tMessage)
		if tMessage '= "" {
			$$$TRACE("Split the line into a list")
			if (FieldDelimiter="csv") {
				s tMessageList=##class(IIBAENSEMBLE.Functions).ParseCSV(tMessage)
			} else {
				s tMessageList=$LFS(tMessage,FieldDelimiter)
			}
			$$$TRACE("Field Count: "_$LL(tMessageList))
			$$$TRACE("Create a instance of the message class")
			s pRequest=$ZOBJCLASSMETHOD(..MessageClass,"%New")
			
			Set rs = ##class(%ResultSet).%New()
			Do rs.Prepare("Select Name, InitialExpression from %Dictionary.PropertyDefinition where parent = '"_..MessageClass_"' Order by SequenceNumber")
			set tSC = rs.Execute()
			//Quit:$$$ISERR(tSC) tSC
			
			Set FieldNum=0
			While (rs.Next()) {
				s FieldNum=FieldNum+1
				$$$TRACE("Field Number "_FieldNum_"Property: "_rs.Get("Name")_", Value: "_$LIST(tMessageList,FieldNum))
				set propertyname = rs.Get("Name")
				Set $ZOBJPROPERTY(pRequest,propertyname)=$LIST(tMessageList,FieldNum)
			}
		
			
		}


		Set tSC=..SendRequestAsync(..TargetConfigName,pRequest)
		
		// individual session per line
		Set ..%SessionId=""  
		Kill $$$JobSessionId
	}

	
	Quit $$$OK
}

ClassMethod OnGetConnections(Output pArray As %String, item As Ens.Config.Item)
{
	Set (tValue,tIndex)="" 
	For { 
		Set tIndex = item.Settings.Next(tIndex) Quit:tIndex=""
		Set tSetting = item.Settings.GetAt(tIndex)
		If tSetting.Name="TargetConfigName" {
			Set tValue=tSetting.Value
		}
	}
	
	For i=1:1:$L(tValue,",") { 
		Set tOne=$P(tValue,",",i)
		If (tOne '= "" ) {
			Set pArray(tOne)=""
		}
	}
	Quit
}

}
