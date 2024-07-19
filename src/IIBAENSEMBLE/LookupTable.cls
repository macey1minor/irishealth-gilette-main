/// Copyright 2007 by Inland Imaging Business Associates
/// Updated Paul Hegel - Med Fusion Req#1 - Phegel: related to new LookupTableHeader for Permissions
/// 
Class IIBAENSEMBLE.LookupTable Extends %Persistent [ SqlTableName = LookupTable ]
{

Property LookupID As %String(MAXLEN = 255);

Index LookupIDIDX On LookupID [ Type = bitmap ];

Property LeftID1 As %String(MAXLEN = 255);

Property LeftID2 As %String(MAXLEN = 255);

Property LeftID3 As %String(MAXLEN = 255);

Index SourceIDX On (LeftID1, LeftID2, LeftID3) [ Type = bitmap ];

Property RightID As %String(MAXLEN = 4000);

Index RightIDIDX On RightID [ Type = bitmap ];

// Req#1 - Phegel: Add relationship to new LookupTableHeader 

/// NOTE: Cardinality refers to the related table. So there will only be one LookupTableHeader for this record.
Relationship LookupTableHeader As IIBAENSEMBLE.LookupTableHeader [ Cardinality = one, Inverse = LookupTable ];

Index LookupTableHeaderIndex On LookupTableHeader;

/// Req#2 - PHegel - Moved the Check existing to here so it's reusable across other methods. Move to using inline sql
ClassMethod CheckExisting(Table As %String, ItemID As %String, LeftID1 As %String, LeftID2 As %String, LeftID3 As %String, RightID As %String, Output Exists As %Boolean, Output FoundId As %String) As %String
{
	set FoundId = ""
	set Exists = 0
	#DIM tResult as %SQL.StatementResult
	
	Q:RightID="" "RightID cannot be <EMPTY>"
	
	set tSQL = 3
	SET tSQL(1) = "select ID from IIBAENSEMBLE.LookupTable "
	set tSQL(2) = "WHERE LeftID1= '"_LeftID1_"' AND RightID= '"_RightID_"' "
	set tSQL(3) = "AND LookupID= '"_Table_"' "
	
	if LeftID2 '= "" {
		set tSQL = 4
		set tSQL(4) = "AND LeftID2= '"_LeftID2_"' "
	}	
	If (LeftID3 '= "") {
		set tSQL = 5
		set tSQL(5) = "AND LeftID3= '"_LeftID3_"' "
	}
	set tStatement = ##class(%SQL.Statement).%New()
	set tSC = tStatement.%Prepare(.tSQL)
	q:$$$ISERR(tSC) tSC

	set tResult = tStatement.%Execute()
	while(tResult.%Next())
	{
		set FoundId = tResult.%Get("ID")	
	}
	
	if (FoundId="" )||(ItemID=FoundId){
		Set Exists=0
		set quitvalue= "Ok"} 
	else {
		set Exists=1
		set quitvalue= "Item already exists with these lookup values"	}
	
	QUIT quitvalue
}

/// Req#2 - PHegel - create an insert method to make it easier to audit and to Add the Header Value.  
/// 	Checks for Existing match and skips if exists.
/// 		Returns ItemID of inserted row.
ClassMethod Insert(Table As %String, LeftID1 As %String, LeftID2 As %String, LeftID3 As %String, RightID As %String, Output Exists As %Boolean, Output ItemID As %String) As %String
{
	set foundID = ""
	set ItemID = ""
	s tSC = ..CheckExisting(Table,0,LeftID1,LeftID2,LeftID3,RightID, .Exists, .foundID)
	
	If (Exists) {
		set tSC = "exists"
		set ItemID = foundID
	} Else {
	
		set obj = ##class(IIBAENSEMBLE.LookupTable).%New()
		set header = ##class(IIBAENSEMBLE.LookupTableHeader).GetObjectByName(Table)	
		if ('$DATA(header))
			set obj.LookupTableHeader = header
			
		set obj.LookupID = Table
		set obj.LeftID1 = LeftID1
		set obj.LeftID2 = LeftID2
		set obj.LeftID3 = LeftID3
		set obj.RightID = RightID
		
		set tSC = obj.%Save(1)
		set ItemID = obj.%Id()
	}
			
	Quit tSC
}

/// Req#2 - PHegel - create an insert method to make it easier to audit and to Add the Header Value.
/// 	ItemID can be sent in or it can be output as well.
///  	Since ItemID hs a value
ClassMethod Update(Table As %String, LeftID1 As %String, LeftID2 As %String, LeftID3 As %String, RightID As %String, ByRef ItemID As %String = 0) As %String
{
	#Dim obj as IIBAENSEMBLE.LookupTable
	
	set exists = 1
	set:ItemID="" ItemID=0
	
	s tSC = ..CheckExisting(Table,ItemID,LeftID1,LeftID2,LeftID3,RightID,.exists,.foundID)
	If ((exists) && (ItemID'=0))
	{
		set tSC = "AlreadyExists"	
	}	
	else
	{
		set ItemID = foundID
		set obj = ##class(IIBAENSEMBLE.LookupTable).%OpenId(ItemID)
		
		set obj.LookupID = Table
		set obj.LeftID1 = LeftID1
		set obj.LeftID2 = LeftID2
		set obj.LeftID3 = LeftID3
		set obj.RightID = RightID
		
		set tSC = obj.%Save()
	}
			
	Quit tSC
}

ClassMethod SetRow(Table As %String, LeftID1 As %String, LeftID2 As %String, LeftID3 As %String, RightID As %String, Output Exists As %Boolean, Output ItemID As %String) As %String
{
	set foundID = ""
	
	s tSC = ..CheckExisting(Table,0,LeftID1,LeftID2,LeftID3,RightID,.Exists, .foundID)
	
	if (Exists)
	{
		set ItemID = foundID
		set tSC = ..Update(Table,LeftID1,LeftID2,LeftID3,RightID,.ItemID)
		Q:$$$ISERR(tSC)
		set tSC = "Updated"
	}
	else
	{
		set tSC = ..Insert(Table,LeftID1,LeftID2,LeftID3,RightID,.ItemID)	
		Q:$$$ISERR(tSC)
		set tSC = "Inserted"
	}
	quit tSC
}

Storage Default
{
<Data name="LookupTableDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>LeftID1</Value>
</Value>
<Value name="3">
<Value>LeftID2</Value>
</Value>
<Value name="4">
<Value>LeftID3</Value>
</Value>
<Value name="5">
<Value>LookupID</Value>
</Value>
<Value name="6">
<Value>RightID</Value>
</Value>
<Value name="7">
<Value>LookupTableHeader</Value>
</Value>
</Data>
<DataLocation>^IIBAENSEMBLE.LookupTableD</DataLocation>
<DefaultData>LookupTableDefaultData</DefaultData>
<ExtentSize>100000</ExtentSize>
<IdLocation>^IIBAENSEMBLE.LookupTableD</IdLocation>
<IndexLocation>^IIBAENSEMBLE.LookupTableI</IndexLocation>
<Property name="%%CLASSNAME">
<Selectivity>1</Selectivity>
</Property>
<Property name="%%ID">
<Selectivity>1</Selectivity>
</Property>
<Property name="LeftID1">
<Selectivity>1</Selectivity>
</Property>
<Property name="LeftID2">
<Selectivity>1</Selectivity>
</Property>
<Property name="LeftID3">
<Selectivity>1</Selectivity>
</Property>
<Property name="LookupID">
<Selectivity>1</Selectivity>
</Property>
<Property name="RightID">
<Selectivity>1</Selectivity>
</Property>
<StreamLocation>^IIBAENSEMBLE.LookupTableS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
