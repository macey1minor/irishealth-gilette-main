Class IIBAENSEMBLE.bp.PreProcessDEBUG Extends Ens.BusinessProcess [ ClassType = persistent, ProcedureBlock ]
{

/// Name of the lookup table with fields on which to route
Property RoutableFieldsTable As %String;

/// Name of the lookup table to map routing field values to targets
Property RoutingTargetsTable As %String;

Parameter SETTINGS As %String = "RoutableFieldsTable,RoutingTargetsTable";

Method OnInit() As %Status
{
    #DIM tSC as %Status

	//Set up lookups for routing
	s ^||RoutableFields = ""
	s ^||RoutingTargets = ""
	
	//s tSC = ..getTableValues("INCYTE RESULTS ROUTABLE FIELDS", "^||RoutableFields", 0)
	s tSC = ..getTableValues(..RoutableFieldsTable, "^||RoutableFields", 0)
	If $SYSTEM.Status.IsError(tSC) // if there was an error, process that
     {
     	$$$LOGERROR("Error for Routable Fields Table '"_..RoutableFieldsTable_"' during process initialization") // perform error processing
     }
     
    //s tSC = ..getTableValues("INCYTE RESULTS ROUTING", "^||RoutingTargets", 1)
	s tSC = ..getTableValues(..RoutingTargetsTable, "^||RoutingTargets", 1)
	If $SYSTEM.Status.IsError(tSC) // if there was an error, process that
     {
     	$$$LOGERROR("Error for Routing Targets Table '"_..RoutingTargetsTable_"' during process initialization") // perform error processing
     }
     
     Quit tSC
}

Method OnRequest(pRequest As Ens.Request, Output pResponse As Ens.Response) As %Status
{
    #Dim tSC as %Status
    #Dim alreadyRoutedTo as %String
    #Dim segmentSpec as %String
    #Dim fieldSpec as %String
    
    // Array for already-routed values to avoid duplicates
    Kill alreadyRoutedTo
	Set alreadyRoutedTo = ""

	//Iterate over all the routable fields
	Set currentFieldSubscript = $Order(^||RoutableFields(""))
	While (currentFieldSubscript '= "") {
		Set pathToField = ^||RoutableFields(currentFieldSubscript)
		$$$TRACE("Processing value from "_pathToField)
		
		//See if this field should process repeats
		set fieldSpec = $p(pathToField, ":",2)	//Get just the field part of the path
		if $f(fieldSpec, "()") '= 0
		{
			set segmentSpec = $p(pathToField, ":",1)_":"	//Get just the segment part of the path
			set splitField = $ListFromString(fieldSpec, "()")  //Split the field spec around the "()"
			
			//Create virtual path to retrieve repeat value count
			set sTemp = segmentSpec_$P(fieldSpec, "()", 1)_"(*)"
			$$$TRACE("Count retrieved by "_sTemp_" = '"_pRequest.GetValueAt(sTemp)_"'")
			
			// Iterate over the repeat values for this field
			for k1=1:1:pRequest.GetValueAt(sTemp) 
			{
				// Build virtual path to current value
				set sTemp = segmentSpec_$ListToString(splitField, "("_k1_")")
				
				//We can finally attempt to route it
				set tSC = ..doRouting(pRequest, sTemp, .alreadyRoutedTo)
			}
		} 
		else
		{
			set tSC = ..doRouting(pRequest, pathToField, .alreadyRoutedTo)
		}
		
		// get subscript for next field specification
		Set currentFieldSubscript = $Order(^||RoutableFields(currentFieldSubscript))
	}
	
	set tSC = $$$OK
	Quit tSC
}

/// Handles routing to all specified targets of the specified value.
/// If supplied, will first check current target against the array in alreadyRoutedTo
/// If the current target exists as a subscript in this array, will not route an additional copy
Method doRouting(pRequest As Ens.Request, pathToField As %String, Output alreadyRoutedTo) As %Status
{
	#Dim tSC as %Status
	#Dim routableValue As %String
	
	set tSC = $$$OK
	//get the field value
	Set routableValue = pRequest.GetValueAt(pathToField)
	if routableValue '= "" 
	{
		$$$TRACE("Retrieved value: '"_routableValue_"'")
		
		set routingTarget = $Order(^||RoutingTargets(routableValue, ""))
		$$$TRACE("Initial target : '"_routingTarget_"'")
		while routingTarget '= ""
		{
			if $Data(alreadyRoutedTo($ZCONVERT(routingTarget,"U"))) = 0 
			{
				$$$TRACE("Routing message to "_routingTarget)
				// Set tSC = ..SendRequestAsync(routingTarget,pRequest,0)
				// if $$$ISERR(tSC) $$$LOGERROR(tSC)
  			
    			// Add to array of already-routed values
				Set alreadyRoutedTo($ZCONVERT(routingTarget,"U")) = "1"
			} 
			else 
			{
				$$$TRACE("Already routed to "_routingTarget)
			}

			set routingTarget = $Order(^||RoutingTargets(routableValue, routingTarget))
		}		
		
		// Add to array of already-routed values
		Set alreadyRoutedTo($ZCONVERT(routableValue,"U")) = "1"
	}
	else 
	{
		$$$TRACE("No value gotten at "_pathToField)
	}
	
	Quit tSC
}

ClassMethod getTableValues(tableName As %String = "", returnValue, isMultiValue) As %Status
{
	// k returnValue
	
	Set rset = ##class(%ResultSet).%New()
	Do rset.Prepare("SELECT LeftID1, LeftID2, RightID FROM IIBAENSEMBLE.LookupTable WHERE LeftID1 NOT LIKE '.%' AND LookupID = '"_tableName_"'")
	
	set sc = rset.Execute()
 	While (rset.Next(.sc)) {
		If ($SYSTEM.Status.IsOK(sc)) // check if this succeeded without errors
            {
	            if isMultiValue {
	            	set @returnValue@($get(rset.Data("LeftID1")),$get(rset.Data("RightID"))) = ""
	            } else {
		            set @returnValue@($get(rset.Data("LeftID1"))) = $get(rset.Data("RightID"))
	            }
            }
        Else // if there was an error, break out of the While loop
            {
                Quit
            }		
	}
	
	If $SYSTEM.Status.IsError(sc) // if there was an error, process that
     {
     $$$LOGERROR("Table Lookup Error in getTableValues()") // perform error processing
     }
     
	Quit sc
}

ClassMethod dumpArray(toDump) As %Status
{
	set a = ""
	for {
		set a = $Order(@toDump@(a))
		q:a=""
		w a," data is ", $d(@toDump@(a)),!
		if ($d(@toDump@(a))=1) {
			w toDump,"(",a,")=",@toDump@(a),!
		} else {
			set b = ""
			for {
				set b = $Order(@toDump@(a,b))
				q:b=""
				w "A=",a,!,"B=","'",b,"'",!," data is ", $d(@toDump@(a,b)),!
				w b,"=",@toDump@(a,b),!
			}
		}
	}
	quit 1
}

ClassMethod fakeInit() As %Status
{
	#DIM tSC as %Status
	
	//Set up lookups for routing
	k ^||RoutableFields
	s ^||RoutableFields = ""
	k ^||RoutingTargets
	s ^||RoutingTargets = ""
	
	s tSC = ..getTableValues("INCYTE RESULTS ROUTABLE FIELDS", "^||RoutableFields", 0)
	w "RoutableFields Finished",!
	s tSC = ..dumpArray("^||RoutableFields")

	s tSC = ..getTableValues("INCYTE RESULTS ROUTING", "^||RoutingTargets", 1)
	w "RoutingTargets Finished",!
	s tSC = ..dumpArray("^||RoutingTargets")
}

Storage Default
{
<Data name="PreProcessDEBUGDefaultData">
<Subscript>"PreProcessDEBUG"</Subscript>
<Value name="1">
<Value>RoutableFieldsTable</Value>
</Value>
<Value name="2">
<Value>RoutingTargetsTable</Value>
</Value>
</Data>
<DefaultData>PreProcessDEBUGDefaultData</DefaultData>
<Type>%Storage.Persistent</Type>
}

}
