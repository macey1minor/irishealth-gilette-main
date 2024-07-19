Class IIBAENSEMBLE.Bsvc.SQLInbound Extends Ens.BusinessService [ ProcedureBlock ]
{

Parameter ADAPTER = "EnsLib.SQL.InboundAdapter";

Property MessageClass As %String;

Property TargetConfigNames As %String;

Property MessageCount As %String;

Parameter SETTINGS As %String = "MessageClass,MessageCount,TargetConfigNames";

Method OnProcessInput(pInput As EnsLib.SQL.Snapshot, pOutput As %RegisteredObject) As %Status
{

	$$$TRACE("Processing message.../"_..MessageClass)
	#dim propertyDef as %String
	
	Set tSC  = ..GetClassProperties(..MessageClass, .propertyDef)                                                              
	Quit:$$$ISERR(tSC) tSC
	
	$$$TRACE("Transform results into Message Class")
	
	
	//Create class from MessageClass Property
	set reg = $CLASSMETHOD(..MessageClass,"%New")
	
	#Dim propertyName as %String = ""
	#dim propertyTrace as %String = ""
	

	//iterate through the Message class properties and set to the value we get from the pInput/SnapShot using $PROPERTY
	For count = 1:1:propertyDef {
		//get the property information
		set propertyName = propertyDef("propertyName",count)
		Set InitialExpression = propertyDef("InitialExpression",count)
		
		if (propertyName '="") 
		{
			set propertyValue = pInput.Get(propertyName)
			
			/**/
			s propertyTrace = propertyTrace_"|"_propertyName_"^"_propertyValue_"^"_count		
			
			//IF the value from the pInput is NULL then use the initial expression
			if ($a(propertyValue) '= -1)
			{
				s $PROPERTY(reg,propertyName) = propertyValue
			}
			elseif (1=0) 
			{
				s $PROPERTY(reg,propertyName) = InitialExpression
			}
	
			//capture the key value based on the Adapter's KeyFieldName
			if (propertyName = ..Adapter.KeyFieldName)
			{
				set regKey = propertyValue
				
			}	
						
						
		}
		
	}
	$$$TRACE("Properties: " _ propertyName)
						
	s reg.OriginalFilename =  ..%ConfigName _"."_..Adapter.KeyFieldName _ ".xml"
	
	s tSC = ..WriteClassToStream(reg,.tStream)
	s reg.Stream = tStream

	// Send to each Target Configuration Name
	For i=1:1:$L(..TargetConfigNames,",") {
		//get the target cofiguration name using $PIECE
		S target=$PIECE(..TargetConfigNames,",",i)
		$$$TRACE("Sending KeyFieldName: '"_..Adapter.KeyFieldName_" with KeyValue: "_regKey_"' To '"_target_"'.")

		//send to target syncrhonously
		set tSC=..SendRequestSync(target,reg,.pOutput)
		
		
		Q:$$$ISERR(tSC) 
		
	}	
	//Create Delete method to override current 
	//Call new delete method to allow transactions while still processing current message. 	
	QUIT tSC
}

ClassMethod OnGetConnections(Output pArray As %String, item As Ens.Config.Item)
{
	Set (tValue,tIndex)="" 
	For { 
		Set tIndex = item.Settings.Next(tIndex) Quit:tIndex=""
		Set tSetting = item.Settings.GetAt(tIndex)
		If tSetting.Name="TargetConfigNames" {
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

Method OnInit() As %Status
{
   #; initialize persistent last key value
   Do ..Adapter.InitializePersistentValue(..%ConfigName,,0)

   Quit $$$OK
}

/// Use to get the Message Class <b>pClassName</b> properties into a MulitDimensional Array <b>pPropertyDefinition</b>
Method GetClassProperties(pClassName As %String, Output pPropertyDefinition As %String) As %Status
{
	
	$$$TRACE("Getting message class properties: "_"Select Name, InitialExpression from %Dictionary.PropertyDefinition where parent = "_pClassName_" Order by SequenceNumber")
	Set rs = ##class(%ResultSet).%New()
	Do rs.Prepare("Select Name, InitialExpression from %Dictionary.PropertyDefinition where parent = '"_pClassName_"' Order by SequenceNumber")
	set tSC = rs.Execute() Quit:$$$ISERR(tSC) tSC
	

	set count = 1
		
	
	While (rs.Next()) {
		//get the property information
		set pPropertyDefinition("propertyName",count) = rs.Get("Name") 
		Set pPropertyDefinition("InitialExpression",count) = rs.Get("InitialExpression")
		set count = count + 1	
	}
	
	set pPropertyDefinition = rs.%ROWCOUNT
		
	QUIT tSC
}

Method OnResponse() As %Status
{
	$$$TRACE("In OnResponse")
	QUIT $$$OK
}

Method WriteClassToStream(cls As %XML.Adaptor, Output pStream As %FileCharacterStream) As %Status
{
    //check that cls extends %XML.Adaptor
    Set check=1
    set tSC = $$$OK
    
    Try {
       Set check=$classmethod($classname(cls),"%Extends","%XML.Adaptor")
       } Catch {
           Set check=0
           }

    If (check'=1) {
        $$$TRACE("Class does not extend %XML.Adaptor or is not compiled")
        quit tSC
        }
	
    Set filename=..%ConfigName _"."_..Adapter.KeyFieldName _ ".xml"
        
    Set writer=##class(%XML.Writer).%New()
    Set writer.Indent=1
    Set tSC=writer.OutputToStream(.pStream)
    Q:$$$ISERR(tSC) tSC
    
    Set tSC=writer.RootElement(..%ConfigName)
    Q:$$$ISERR(tSC) tSC
	
    Set tSC=writer.Object(cls)
    Q:$$$ISERR(tSC) tSC
        
    Do writer.EndRootElement()
    Do writer.EndDocument()
    
    q tSC
}

/*
Method ExecuteUpdate(Output pNumRowsAffected As %Integer, pUpdateStatement As %String, pParms...) As %Status
{
	Quit $$$OK
}
*/
}
