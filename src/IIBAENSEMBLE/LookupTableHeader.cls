/// Copyright 2014 by Nuvodia, LLC
/// Req#1 - Phegel - Requirement #1 - Table Security for Med Fusion 
/// created by Paul Hegel 2/11/2014
/// Lookup Table Header will maintain the resource and the Headers for the Column Names as well as the reference to the lookup values.
Class IIBAENSEMBLE.LookupTableHeader Extends %Persistent [ SqlTableName = LookupTableHeader ]
{

Property LookupTableName As %String(MAXLEN = 255);

Index LookupTableNameIDX On LookupTableName [ Type = bitmap ];

Property LookupTableDescription As %String(MAXLEN = 255);

Property ColumnNameLeftID1 As %String(MAXLEN = 255) [ InitialExpression = "Left ID 1" ];

Property ColumnNameLeftID2 As %String(MAXLEN = 255) [ InitialExpression = "Left ID 2" ];

Property ColumnNameLeftID3 As %String(MAXLEN = 255) [ InitialExpression = "Left ID 3" ];

Property ColumnNameRightID As %String(MAXLEN = 255) [ InitialExpression = "Right ID" ];

// TODO: find where this is currently stored.  Guessing it's a Global.

Property DefaultValue As %String(MAXLEN = 4000);

/// User needs to have read,write or Use permisions on this resource in order to see it in the drop down list (%All can see all).
Property Resource As %String(MAXLEN = 255) [ InitialExpression = "LookUpTableAdmin" ];

/// NOTE: Cardinality refers to the related table. So there will be many LookupTable rows for this record. 
/// Relationsip of LookupTable is a Collection and has Collection Functions.
Relationship LookupTable As IIBAENSEMBLE.LookupTable [ Cardinality = many, Inverse = LookupTableHeader ];

ClassMethod GetIdByName(pLookupTableName As %String) As %Integer
{
   set ID = ""
   
   &sql(SELECT ID
        INTO :ID
        FROM IIBAENSEMBLE.LookupTableHeader where LookupTableName = :pLookupTableName)
        
   q ID
}

/// Gets LookupTableObject By the Name of the Table
ClassMethod GetObjectByName(pLookupTableName As %String, Output tSC As %Status) As IIBAENSEMBLE.LookupTableHeader
{
	
	set tSC = $$$OK
	set ID = ..GetIdByName(pLookupTableName)
	
 	if (ID=""){
		s tSC = $$$ERROR("LookupTableName not found: "_ pLookupTableName)
	}
	
	set header = ##class(IIBAENSEMBLE.LookupTableHeader).%OpenId(ID)
	
	QUIT header
}

/// Creates LookupTableHeader from pLookupTableName and Looks for matching LookupTable->LookupID
/// 	If it finds matching records it adds them to the LookupTableHeader
/// 		If there is a row where leftID starts with "." then it replaces Column Names from this row removing leading period.
ClassMethod CreateLookupTableHeader(pLookupTableName As %String, Output pID As %String) As %Status
{
	set tSC = $$$OK
	
	set pID = ..GetIdByName(pLookupTableName)
	if (pID="")
	{
		//Create record in LookupTableHeader
		set header = ##class(IIBAENSEMBLE.LookupTableHeader).%New()
		set header.LookupTableName = pLookupTableName
		set tSC = header.%Save()
		set pID = header.%Id()
		d header.%UnlockId(pID)
		set header = ""
	}
	set tSC = ..RelateToLookupTable(pID)
	
	QUIT tSC
}

/// Use to setup new LookupTableHeader from import based on the SessionId of the Imported tables.
ClassMethod CreateLookupTableHeaderFromImport(pSessionId As %String, Output HeaderIDs As %ListOfDataTypes) As %Status
{
	set tSC = $$$OK
	 
	Set rsHeader = ##class(%ResultSet).%New()
	Do rsHeader.Prepare("SELECT DISTINCT LookupID from IIBAENSEMBLE.LookupTableImport where SessionID = '"_pSessionId_"'")
	Do rsHeader.Execute()
	set count = 1
	
	set HeaderIDs = ##class(%ListOfDataTypes).%New()
	set HeaderIDs.ElementType = "%String"
	
	While (rsHeader.Next(.tSC)){
		set tableName = rsHeader.Get("LookupID")
		set tSC = ..CreateLookupTableHeader(tableName, .id)
		do HeaderIDs.Insert(id)
		q:$$$ISERR(tSC)
	}
	
	quit tSC
}

/// This method is used to relate the LookupTable records to the Header based on the
/// LookupTableHeader->LookupTableName matching the LookupTable->LookupID
ClassMethod RelateToLookupTable(pID As %String) As %Status
{
	set tSC = $$$OK
	set header = ##class(IIBAENSEMBLE.LookupTableHeader).%OpenId(pID)
	// Relate to LookupTable
	set rsDetail = ##class(%ResultSet).%New()
	Do rsDetail.Prepare("SELECT ID FROM IIBAENSEMBLE.LookupTable where lookupID = '"_header.LookupTableName_"'")
	Do rsDetail.Execute()
	While(rsDetail.Next(.tSC)){
		QUIT:$$$ISERR(tSC)
		set id = rsDetail.Get("ID")
		set detail = ##class(IIBAENSEMBLE.LookupTable).%OpenId(id)
		set tSC = header.LookupTable.Insert(detail)
		//if leftid1 starts with "." then this is the title row.  set the column names.
		if ($E(detail.LeftID1,1,1)=".")
		{ 
			set header.ColumnNameLeftID1 = $E(detail.LeftID1,2,$L(detail.LeftID1))
			
			if ($E(detail.LeftID2,1,1)=".")
				{ set header.ColumnNameLeftID2 = $E(detail.LeftID2,2,$L(detail.LeftID2)) }
			
			if ($E(detail.LeftID3,1,1)=".")
				{ set header.ColumnNameLeftID3 = $E(detail.LeftID3,2,$L(detail.LeftID3)) } 
			
			if ($E(detail.RightID,1,1)=".")
				{ set header.ColumnNameRightID = $E(detail.RightID,2,$L(detail.RightID)) } 
		}
		
		QUIT:$$$ISERR(tSC)
		//w detail.LookupTableHeader.LookupTableName, ":", detail.%Id(),"  status: ", sc,!
	}
	//Get default value from lookup table Set DefaultValue on Header
	set tSC = ..GetDefaultValueFromLookup(header.LookupTableName, .defaultValue)
	QUIT:$$$ISERR(tSC) tSC
	set header.DefaultValue = defaultValue
	set tSC = header.%Save()
	QUIT tSC
}

// Req#4 - PHegel - used by the delete table method.

/// Used to delete table headers for testing and to later delete the whole table by pLookupTableName
ClassMethod DeleteLookupTableHeaderByName(pLookupTableName As %String, pDeleteRelated As %Boolean = 0) As %Status
{
	set tSC = $$$OK
	
	set ID = ..GetIdByName(pLookupTableName)
	QUIT:ID="" $$$ERROR("LookupTableName not found: "_ pLookupTableName)
	
	set tSC = ..DeleteLookupTableHeaderByID(ID, pDeleteRelated)
	Quit tSC
}

ClassMethod GetDefaultValueFromLookup(pLookupTableName As %String, Output pDefaultValue As %String) As %Status [ SqlProc ]
{
	set pDefaultValue = ""
	
	#DIM tResult as %SQL.StatementResult

	set tSQL = 3
	SET tSQL(1) = "select RightID from IIBAENSEMBLE.LookupTable "
	set tSQL(2) = "WHERE LeftID1= 'DefaultValue' AND LeftID2= 'DefaultValue' AND LeftID3= 'DefaultValue' "
	set tSQL(3) = "AND LookupID= '"_pLookupTableName_"' "

	set tStatement = ##class(%SQL.Statement).%New()
	set tSC = tStatement.%Prepare(.tSQL)
	q:$$$ISERR(tSC) tSC

	set tResult = tStatement.%Execute()
	while(tResult.%Next())
	{
		set pDefaultValue = tResult.%Get("RightID")	
	}
	s:'$DATA(pDefaultValue) pDefaultValue=""
	
	QUIT $$$OK
}

ClassMethod SetDefaultValue(Table As %String, DefValue As %String) As %Status [ SqlProc ]
{
	#dim tSC as %Status = $$$OK
	// Set the Default value based on Table Name
	set defaultValue = ##class(IIBAENSEMBLE.Functions).StringReplace(DefValue,"'","''")
	
	#dim obj as IIBAENSEMBLE.LookupTableHeader = ..GetObjectByName(Table)
	set obj.DefaultValue = DefValue
	set tSC = obj.%Save()
	
	quit tSC
}

/// Used to delete table headers for testing and to later delete the whole table by pID (OID)
ClassMethod DeleteLookupTableHeaderByID(pID As %String, pDeleteRelated As %Boolean = 0) As %Status
{
	set tSC = $$$OK
	
	//first remove relatioships or Delete records related to Table Header
	set header = ##class(IIBAENSEMBLE.LookupTableHeader).%OpenId(pID)

	// iterate over the details and print their data
	Set key = ""
	#dim detail as IIBAENSEMBLE.LookupTable
	
	do {
		set detail = header.LookupTable.GetNext(.key)
		quit:detail="" 
		set rowID = detail.%Id()
		// Always - Remove relationship only (don't delete object if pDeleted=0)
		s id = header.LookupTable.Remove(detail)	
		//Are we Deleting related?
		If (pDeleteRelated=1) {
			set tSC = ##class(IIBAENSEMBLE.LookupTable).%UnlockId(rowID)
			set detail = ""
			// YES - Delete related detail row
			set tSC = ##class(IIBAENSEMBLE.LookupTable).%DeleteId(rowID, 1)
			QUIT:$$$ISERR(tSC)
		}
		set tSC = header.%Save()
		QUIT:$$$ISERR(tSC)
	} While (key'="")
	QUIT:$$$ISERR(tSC) tSC
	
	//second - Delete Header 
	set header = ""
	s tSC = ##class(IIBAENSEMBLE.LookupTableHeader).%DeleteId(pID)
	
	Quit tSC
}

/// Gets list of LookupTableHeaders where User has R,W,U persmission on the table Resource
/// To give users access.
/// 1. Resource needs to be created in System->System Management->Resources
/// 2. Resource needs to be added to an existing or new Role in System->System Management->Roles with Use permissions
/// 3. Add New Role to User, otherwise the use may already have access to existing Role, if not Add the Role to user.
/// 4. User also needs access to the Resource: LookUpTableAdmin with Read access only in order to see this list can be added 
///    to above role or create a new role that can be added to users that use table. The default resource for a 
///    LookupTable is LookUpTableAdmin, so they will need Read and Use access to see it.
/// Note: This list controls the users ability to see the table. They will need to have W permissions on the table to modify it.
ClassMethod GetListByPermissions(Output pListOfHeaders As %ListOfObjects) As %Status
{
	set pListOfHeaders = ##class(%ListOfObjects).%New()
	set tSC = $$$OK
	
	//select list of names
	set rsHeader = ##class(%ResultSet).%New()
	Do rsHeader.Prepare("SELECT ID, Resource FROM IIBAENSEMBLE.LookupTableHeader Order BY LookupTableName")
	Do rsHeader.Execute()
	While(rsHeader.Next(.tSC)){
		QUIT:$$$ISERR(tSC)
		set resource = rsHeader.Get("Resource")
		
		// User must have Use access to the resource in order to see it in this list
		if ##class(%SYSTEM.Security).Check(resource, "Use")
		{
			set id = rsHeader.Get("ID")
			set header = ##class(IIBAENSEMBLE.LookupTableHeader).%OpenId(id)
			set tSC = pListOfHeaders.Insert(header)
			QUIT:$$$ISERR(tSC)
		}
		QUIT:$$$ISERR(tSC)
	}
	QUIT tSC
}

Storage Default
{
<Data name="LookupTableHeaderDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>LookupTableName</Value>
</Value>
<Value name="3">
<Value>LookupTableDescription</Value>
</Value>
<Value name="4">
<Value>ColumnNameLeftID1</Value>
</Value>
<Value name="5">
<Value>ColumnNameLeftID2</Value>
</Value>
<Value name="6">
<Value>ColumnNameLeftID3</Value>
</Value>
<Value name="7">
<Value>ColumnNameRightID</Value>
</Value>
<Value name="8">
<Value>TableResource</Value>
</Value>
<Value name="9">
<Value>LookupTable</Value>
</Value>
<Value name="10">
<Value>Resource</Value>
</Value>
<Value name="11">
<Value>DefaultValue</Value>
</Value>
</Data>
<DataLocation>^IIBAENSEMBLE.LookupTable435CD</DataLocation>
<DefaultData>LookupTableHeaderDefaultData</DefaultData>
<ExtentSize>100000</ExtentSize>
<IdLocation>^IIBAENSEMBLE.LookupTable435CD</IdLocation>
<IndexLocation>^IIBAENSEMBLE.LookupTable435CI</IndexLocation>
<StreamLocation>^IIBAENSEMBLE.LookupTable435CS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
