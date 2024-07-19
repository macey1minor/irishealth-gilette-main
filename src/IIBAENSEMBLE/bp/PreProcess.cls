Class IIBAENSEMBLE.bp.PreProcess Extends Ens.BusinessProcess [ ClassType = persistent, ProcedureBlock ]
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
	
	If ..RoutableFieldsTable="" 
    {
    	$$$LOGERROR("No value specified for Routable Fields Table. Initialization failed.'")
    	return -1
    }
	s tSC = ..getRoutableFields()
	If $SYSTEM.Status.IsError(tSC) // if there was an error, process that
     {
     	$$$LOGERROR("Error for Routable Fields Table '"_..RoutableFieldsTable_"' during process initialization") // perform error processing
     }
    
    If ..RoutingTargetsTable="" 
    {
    	$$$LOGERROR("No value specified for Routable Targets Table. Initialization failed.'")
    }
	s tSC = ..getRoutingTargets()
	If $SYSTEM.Status.IsError(tSC) // if there was an error, process that
     {
     	$$$LOGERROR("Error for Routing Targets Table '"_..RoutingTargetsTable_"' during process initialization") // perform error processing
     	return -1
     }
     
     s tSC = ..dumpRoutingTable()
     $$$LOGERROR("Initialization complete.")
     Quit tSC
}

Method OnRequest(pRequest As Ens.Request, Output pResponse As Ens.Response) As %Status
{
    #Dim tSC as %Status
    #Dim alreadyRoutedTo as %String = ""
    #Dim segmentSpec as %String
    #Dim fieldSpec as %String
    
    set tSC = $$$OK
    
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
		
		q:$$$ISERR(tSC)
		// get subscript for next field specification
		Set currentFieldSubscript = $Order(^||RoutableFields(currentFieldSubscript))
	}
	
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
				Set tSC = ..SendRequestAsync(routingTarget,pRequest,0)
				q:$$$ISERR(tSC)
  			
    			// Add to array of already-routed values
				Set alreadyRoutedTo($ZCONVERT(routingTarget,"U")) = "1"
			} 
			else 
			{
				$$$TRACE("Already routed to "_routingTarget)
			}
			
			q:$$$ISERR(tSC)
			set routingTarget = $Order(^||RoutingTargets(routableValue, routingTarget))
		}
		
		q:$$$ISERR(tSC)
		// Add to array of already-routed values
		Set alreadyRoutedTo($ZCONVERT(routableValue,"U")) = "1"
	}
	else 
	{
		$$$TRACE("No value gotten at "_pathToField)
	}
	
	Quit tSC
}

Method getRoutableFields() As %Status
{
	Set rset = ##class(%ResultSet).%New()
	Do rset.Prepare("SELECT LeftID1, LeftID2, RightID FROM IIBAENSEMBLE.LookupTable WHERE LeftID1 NOT LIKE '.%' AND LookupID = '"_..RoutableFieldsTable_"'")
	
	set sc = rset.Execute()
 	While (rset.Next(.sc)) {
		If ($SYSTEM.Status.IsOK(sc)) // check if this succeeded without errors
            {
	        set ^||RoutableFields($get(rset.Data("LeftID1"))) = $get(rset.Data("RightID"))
	        }
        Else // if there was an error, break out of the While loop
            {
            Quit
            }		
	}
	
	If $SYSTEM.Status.IsError(sc) // if there was an error, process that
    	{
     	$$$LOGERROR("Table Lookup Error in getRoutableFields()") // perform error processing
     	}
     
	Quit sc
}

Method getRoutingTargets() As %Status
{
	Set rset = ##class(%ResultSet).%New()
	Do rset.Prepare("SELECT LeftID1, LeftID2, RightID FROM IIBAENSEMBLE.LookupTable WHERE LeftID1 NOT LIKE '.%' AND LookupID = '"_..RoutingTargetsTable_"'")
	
	set sc = rset.Execute()
	While (rset.Next(.sc)) {
		If ($SYSTEM.Status.IsOK(sc)) // check if this succeeded without errors
		{
			s RoutingTarget = $get(rset.Data("LeftID1"))
			s refType = $get(rset.Data("LeftID2"))
			s value = $get(rset.Data("RightID"))
			
			// See what sort of value we have in the LeftID2 value
			if refType = "CLIENT" {
				// Processs directly as comma separated values
				set lenValList = $L(value,",")
				for i=1:1:lenValList {
					set nextKey = $p(value,",",i)
					if nextKey="" {
						$$$LOGERROR("Attempted to create routing target for an empty ID<br>RoutingTarget: "_RoutingTarget_"<br>value: "_value)
					} else {
						set ^||RoutingTargets(nextKey, RoutingTarget) = ""
					}
				}
			} elseif refType = "TABLE" {
				// go read the values from the indicated table
				set sc = ..LoadFromTable(value, RoutingTarget)
				If $SYSTEM.Status.IsError(sc) // if there was an error, log it and exit
    				{
     				$$$LOGERROR("Table Lookup Error in getRoutingTargets()") // perform error processing
     				Quit
			     	}
			} elseif refType = "XREF" {
				// go read the values from the indicated table
				set sc = ..LoadFromXref($p(value,"^",1),$p(value,"^",2),RoutingTarget)
				If $SYSTEM.Status.IsError(sc) // if there was an error, log it and exit
    				{
     				$$$LOGERROR("Cross reference table error in getRoutingTargets()") // perform error processing
     				Quit
			     	}
			}
			else {
				w "INVALID VALUE FOR REFERENCE TYPE: "_refType
			}
		}
		Else // if there was an error, break out of the While loop 
		{	
			$$$LOGERROR("Table Lookup Error in getRoutingTargets()") // perform error processing
			Quit
		}		
	}
	q sc
}

Method LoadFromTable(tableName, RoutingTarget) As %Status
{
	Set rset = ##class(%ResultSet).%New()
	Do rset.Prepare("SELECT LeftID1 FROM IIBAENSEMBLE.LookupTable WHERE LeftID1 NOT LIKE '.%' AND LookupID = '"_tableName_"'")
	
	set sc = rset.Execute()
	While (rset.Next(.sc)) {
		If ($SYSTEM.Status.IsOK(sc)) // check if this succeeded without errors
			{
				s clientID = $get(rset.Data("LeftID1"))
				s ^||RoutingTargets(clientID,RoutingTarget) = ""
			}
		Else // if there was an error, break out of the While loop
			{
				$$$LOGERROR("Table Lookup Error in LoadFromTable()") // perform error processing
				Quit
			}		
	}
	q sc
}

Method LoadFromXref(tableName, columnName, RoutingTarget) As %Status
{
	// Make sure we have clean input
	if (tableName="")||(columnName="") {
		$$$LOGERROR("LoadFromXref called with invalid values;Table Name:"_tableName_"Column Name:"_columnName) // perform error processing
		return 0
	}
	
	Set rset = ##class(%ResultSet).%New()
	set queryString = "SELECT RValue FROM IIBAENSEMBLE_Reference.RelatedValue "
	set queryString = queryString_"WHERE PrincipalValue->PrincipalType->Name='"_tableName_"' AND "
	set queryString = queryString_"RelatedType->System='"_columnName_"'"
	Do rset.Prepare(queryString)
	
	set sc = rset.Execute()
	While (rset.Next(.sc)) {
		If ($SYSTEM.Status.IsOK(sc)) // check if this succeeded without errors
			{
				s clientID = $get(rset.Data("RValue"))
				s ^||RoutingTargets(clientID,RoutingTarget) = ""
			}
		Else // if there was an error, break out of the While loop
			{
				$$$LOGERROR("Table Lookup Error in LoadFromXref()") // perform error processing
				Quit
			}		
	}
	q sc
}

Method dumpRoutingTable() As %Status
{
	#Dim tSC as %Status
	#Dim routableValue As %String
	
	set tSC = $$$OK
	//get the field value
	Set routableValue = $Order(^||RoutingTargets(""))
	if routableValue = "" 
	{
		$$$TRACE("Top level of RoutingTargets was empty")
	} 
	while routableValue '= ""
	{
		$$$TRACE("Routable value: '"_routableValue_"'")
		
		set routingTarget = $Order(^||RoutingTargets(routableValue, ""))
		while routingTarget '= ""
		{
			$$$TRACE("Routing target: '"_routingTarget_"'")
			set routingTarget = $Order(^||RoutingTargets(routableValue, routingTarget))
		}
		
		Set routableValue = $Order(^||RoutingTargets(routableValue))
	
	}
	
	Quit tSC
}

Storage Default
{
<Data name="PreProcessDefaultData">
<Subscript>"PreProcess"</Subscript>
<Value name="1">
<Value>RoutableFieldsTable</Value>
</Value>
<Value name="2">
<Value>RoutingTargetsTable</Value>
</Value>
<Value name="3">
<Value>RoutableFields</Value>
</Value>
<Value name="4">
<Value>RoutingTargets</Value>
</Value>
</Data>
<Data name="alreadyRoutedTo">
<Attribute>alreadyRoutedTo</Attribute>
<Structure>subnode</Structure>
<Subscript>"IIBAENSEMBLE.bp.PreProcess.alreadyRoutedTo"</Subscript>
</Data>
<DefaultData>PreProcessDefaultData</DefaultData>
<Type>%Storage.Persistent</Type>
}

}
