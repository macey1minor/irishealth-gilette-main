Class IIBAENSEMBLE.cls.ScrollableResultSet Extends %Library.ScrollableResultSet
{

ClassMethod OpenIdFiltered(id As %String, arrFilter As %ArrayOfDataTypes = "", ByRef sc As %Status = {$$$OK}) As %ObjectHandle
{
	If '$ISOBJECT(arrFilter) Quit ""
	Set oref=..%New()
	Set sc=oref.LoadFiltered(id, arrFilter)
	If $$$ISERR(sc) Quit ""
	Quit oref
}

Method LoadFiltered(id As %String, arrFilter As %ArrayOfDataTypes) As %Status
{
	If '$data(^CacheTempRSet(id)) Quit $$$ERROR($$$LoadObjectNotFound)
	Set ..TempIndex=id,..IsSaved=0
		
	//Build multi-dimensional string from filter array prior to determining index of filter fields
	set Field=""
	set filtercount = 0
	for { set Field = $O(arrFilter.Data(Field))  Q:Field="" 
		set filtercount = filtercount + 1
		set filter(filtercount,"Field") = Field
		set filter(filtercount,"Value") = arrFilter.Data(Field)
		
	}
	
	//For each filter field, find the index for that field and add it as a node to the filter m-d string
	for i=1:1:filtercount {
		for j=1:1:^CacheTempRSet(..TempIndex,"Index") {
			if filter(i,"Field")=^CacheTempRSet(..TempIndex,"Index",j) set filter(i,"Index")=j
		}
	}
	
	//Build a TempData multi-dimensional string that holds only those rows that match the set of filters
	set RowCount = +$order(^CacheTempRSet(..TempIndex,"Data",""),-1)
	set FilteredRowCount = 0
	
	//Loop through every row in the record set looking for rows that match the set of filters and add them to the TempData m-d string
	for i=1:1:RowCount {
		
		set RowList = ^CacheTempRSet(..TempIndex,"Data",i)
		
		set filtermatch = 0
		for j=1:1:filtercount {
			if $FIND($ZCVT($LG(RowList,filter(j,"Index")),"U"),$ZCVT(filter(j,"Value"),"U"))>0 {
				set filtermatch = 1
			}
		}
		if filtermatch {
			set FilteredRowCount = FilteredRowCount + 1
			set TempData(FilteredRowCount)=^CacheTempRSet(..TempIndex,"Data",i)
		}
	}
	
	
	Merge i%ColIndex=^CacheTempRSet(..TempIndex,"Index"),i%QHandle=^CacheTempRSet(..TempIndex,"QHandle"),i%Data=TempData
	Set data=^CacheTempRSet(..TempIndex,"Info")
	Set ..ClassName=$listget(data),..QueryName=$listget(data,2),..RuntimeMode=$listget(data,3),..HasInfo=$listget(data,4),..ParamInfo=$listget(data,5)
	Set ..ColInfo=$listget(data,6),..IdInfo=$listget(data,7),..AtEnd=$listget(data,8),..IsOpened=$listget(data,9),i%CurrRow=$listget(data,10)
	Set ..Row=^CacheTempRSet(..TempIndex,"Row")
	Quit $$$OK
}

Method %Save() As %Status
{
	If ..TempIndex="" Set sc=..PopulateData() If $$$ISERR(sc) Quit sc
	Set ..IsSaved=1
	Merge ^CacheTempRSet(..TempIndex,"Index")=i%ColIndex,^CacheTempRSet(..TempIndex,"QHandle")=i%QHandle
	//This line commented out so that the current filtered data does not replace the original data
	//,^CacheTempRSet(..TempIndex,"RowData")=i%Data
	Set ^CacheTempRSet(..TempIndex,"Info")=$listbuild(..ClassName,..QueryName,..RuntimeMode,..HasInfo,..ParamInfo,..ColInfo,..IdInfo,..AtEnd,..IsOpened,..CurrRow)
	Set ^CacheTempRSet(..TempIndex,"Row")=..Row,^CacheTempRSet(..TempIndex)=$listbuild($zdt($horolog,3),$job)
	Quit $$$OK
}

/// Returns the number of rows contained in this ResultSet.
Method Count() As %Integer
{
	If ..TempIndex="" Set sc=..PopulateData() If $$$ISERR(sc) Quit 0
	//This line is changed to use the current Data property rather than the original rset to get the count
	Quit $select(..TempIndex="":0,1:+$order(i%Data(""),-1))
}

Method CurrRowSet(val As %String) As %Status
{
	If ..TempIndex="" Set sc=..PopulateData() If $$$ISERR(sc) Quit sc
	Set Row = $get(i%Data(+val))
	If (Row = "") {
		Quit $$$OK
	}
	
	Set i%CurrRow=+val

	#; move data into row buffer
	For i=1:1:..ColIndex Set i%Data(i%ColIndex(i))=$listget(Row,i)
	Set ..Row=Row,..AtEnd=1
	Quit $$$OK
}

}
