/// 
Class IIBAENSEMBLE.csp.RefData Extends %CSP.Page
{

ClassMethod OnPreHTTP() As %Boolean
{
	set %response.ContentType = "text/html; charset=UTF-8"
	//d %response.SetHeader("Content-disposition", "attachment; filename="_%request.Get("filename"))
	Quit 1
}

/// Event handler for <b>PAGE</b> event: this is invoked in order to  
/// generate the content of a csp page.
ClassMethod OnPage() As %Status
{
	//If the SRSId value in the session is empty, create and save a new SRS and save the ID in the session
	if $G(%session.Data("SRSId"))="" {
		set oPT = ##class(IIBAENSEMBLE.Reference.PrincipalType).%OpenId(%session.Data("sPTID"))
		set SRS = oPT.getScrollableResultSet()
		d SRS.%Save()
		set %session.Data("SRSId") = SRS.%Id()
		d SRS.Close()
	}
	
	set ^CacheTempTraceSRS = %session.Data("SRSId")
	
	//Loop through the parameters in the request object and find any that start with "filter"
	//The filter parameters are a string representation of js array of objects:  filter[0][field] or filter[0][data][value]
	//if filter parameters are found, build an ArrayOfDataTypes object from them for passing to the SRS OpenIdFiltered method
	set name="", filter=""
	For { set name = $O(%request.Data(name)) Q:name="" 
		if $E(name,1,6)="filter" {
			set filter($E(name,8,$FIND(name,"]")-2)) = $E(name,10,$L(name))
		}
	}
	
	set arrFilter = ""
	if $D(filter)>1 {
		Set arrFilter=##class(%ArrayOfDataTypes).%New()
		set filterNum=""
		For { set filterNum = $O(filter(filterNum)) Q:filterNum=""
			set field = %request.Get("filter["_filterNum_"][field]")
			set value = %request.Get("filter["_filterNum_"][data][value]")
			d arrFilter.SetAt(value,field)
		}
	} 
	
	//If filter parameters were found and a arrayofdataobjects created, use the custom SRS to filter the data as it is loaded - else use the standard SRS
	if $ISOBJECT(arrFilter) {
		set SRS = ##class(IIBAENSEMBLE.cls.ScrollableResultSet).OpenIdFiltered(%session.Data("SRSId"),arrFilter)
	} else {
		set SRS = ##class(%ScrollableResultSet).%OpenId(%session.Data("SRSId"))
	}
	
	if '$ISOBJECT(SRS) {
		w %session.Data("SRSId")
	} else {	
	
		if %request.Get("start")'="" { set start = %request.Get("start")+1 } else { set start = 1 }
	
		if %request.Get("limit")'="" { set limit = %request.Get("limit") } else { set limit = 25 }
		
		if SRS.Count() < 25 set limit = SRS.Count()
		
		w "{'total':"_SRS.Count()_",'data':["
	
		if SRS.Count() > 0 {
			set countColumns = SRS.GetColumnCount()
			for i=start:1:start+limit-1 {
				set tSC = SRS.CurrRowSet(i)
				if tSC {
					if i>start w ","
					w "{'PTId':'"_SRS.Data("PTId")_"'"
					w ",'PVId':'"_SRS.Data("PVId")_"'"
					w ",'PValue':'"_SRS.Data("PValue")_"'"
					for j=3:1:countColumns {
						w ",'"_SRS.GetColumnName(j)_"':"

 							if $A(SRS.GetData(j))'=0{
	 							w "'"_SRS.GetData(j)_"'"
 							} else {
	 							w "''"
 							}
				
					}	
					w "}"
			
				}
			}
		}
	 
		w "]}"
	
		d SRS.%Save()
		
	 
	}
	 
	Quit $$$OK
}

}
