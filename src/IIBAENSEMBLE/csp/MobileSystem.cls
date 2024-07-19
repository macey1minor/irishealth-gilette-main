/// Copyright 2007 by Inland Imaging Business Associates
Class IIBAENSEMBLE.csp.MobileSystem Extends %CSP.Page [ ProcedureBlock ]
{

ClassMethod CheckPermissions()
{
	set Allowed = 0
	if ##class(%SYSTEM.Security).Check("%All") = "READ,WRITE,USE" { set Allowed = 1 }
	
	Quit Allowed
}

ClassMethod jsfunction()
{
  &html<
   <script language=javascript>
	<!--
	function Initialize()
	{

	}
  -->
   </script>
  >
}

ClassMethod html()
{
		Set ProductionName=""
	Set ProductionStatus=""
	set status = ##class(Ens.Director).GetProductionStatus(.ProductionName,.ProductionStatus)
	
	D ..GetStatus()

	W "<H3>"_ProductionName_""

	//Collect interface status information

	W "<BR><br>"
	
	W "Production Status: "
		IF (ProductionStatus '= 1) {
		W "<FONT Color=Red>"
	}
	W $P("Running,Stopped,Suspended,Troubled",",",ProductionStatus)
	IF (ProductionStatus '= 1) {
		W "</FONT>"
	}	
	W "</H3>",!
	

	
	SET IfCnt=0
	W "<Form Name=""FilterForm"" id=""FilterForm"" action=""IIBASupportDetail.csp?PageName=MobileSystem"" method=""post"">"
	W "Interface:&nbsp;"

	//w "<select Name=""Interface"" OnChange=#server(..GetInterfaceInfo())#>"
	//do ..GetInterfaceOptionList()
	//w "</select>"
	
	
	&html<
	<select Name="Interface" id="Interface" OnChange=#server(..GetInterfaceInfo())#>"
	#(..GetInterfaceOptionList())#
	</select>
	
	<br>
	<table><tr><td>
	<input type="submit" name="Status" id="Status" Value="Status">
	</td><td>&nbsp;&nbsp;&nbsp;</td><td>
	<input type="submit" name="toggle" id="toggle" Value="Toggle Enabled">
	</td></tr></table>	
	>
	W "</Form>"

	//W "<BR><BR>",%request.URL,"<BR><BR>"
	s ifn=%request.Get("Interface")
	s s=%request.Get("Status")
	s t=%request.Get("toggle")
	
	//w "<BR>t="_t
	//w "<BR>s="_s
	
	if ( s="Status") {
		w "<BR><B>Show Status</B><BR>"
	}
	
	W "<BR>"
	if ( t="Toggle Enabled") {
		w "<BR><i>Toggle Enabled</i><BR>"
		s cs=%session.Data("SysListArray",ifn,"Enabled")
		do ..ToggleInterface(ifn,cs)
		do ..GetStatus()
	}
	W "<BR>"
	W "<SPAN id=InterfaceStatus>"
		s ifn=%request.Get("Interface")
	if ( ifn '="") {
		w "Interface: ",ifn,"<BR>"
		if ( %session.Data("SysListArray",ifn,"Enabled")=1 ) {
			W "Enabled<BR>"
		} Else {
			W "<B>Disabled</B><BR>"
		}
		w "Status: ",%session.Data("HostStatusArray",ifn,"Status"),"<BR>"
		w "Adapter State: ",%session.Data("HostStatusArray",ifn,"AdapterState"),"<BR>"
		if (%session.Data("SysListArray",ifn,"Type")="1") {
			w "Count: ",%session.Data("HostStatusArray",ifn,"Count")+0,"<BR>"
		} else {
			w "Queue: ",%session.Data("HostStatusArray",ifn,"Queue")+0,"<BR>"
		}
		w "Last Action: ",%session.Data("HostStatusArray",ifn,"LastAction"),"<BR>"
	}

	
	W "</SPAN>"
	W "</CENTER>"
}

ClassMethod GetInterfaceInfo(vPackage As %String) As %String [ Language = objectscript ]
{
 	
 //set Interface=%session.Data("Interface")
 //W "<B>"_Interface_"</B>"
 //&js<alert('test')>
 //document.getElementById('InterfaceStatus').innerHTML='<B>Ben</B>'
 s ifn=%request.Get("Interface")
 S NewStatus=""
 if ( ifn '="") {
 	s NewStatus="Interface: "_ifn_"<BR>"
 	S NewStatus=NewStatus_"Status: "_%session.Data("HostStatusArray",ifn,"Status")_"<BR>"
 	S NewStatus=NewStatus_"Adapter State: "_%session.Data("HostStatusArray",ifn,"AdapterState")_"<BR>"
 	S NewStatus=NewStatus_"Queue: "_%session.Data("HostStatusArray",ifn,"Queue")+0_"<BR>"
 	S NewStatus=NewStatus_"Last Action: "_%session.Data("HostStatusArray",ifn,"LastAction")_"<BR>"
 }
 
 &js<document.getElementById('InterfaceStatus').innerHTML='#(NewStatus)#'>
 s %request.URL=%request.URL_"?Ben=1"
 
 //w "<B>Ben</B>"
 Q 1
}

ClassMethod GetInterfaceOptionList() As %String [ Language = objectscript ]
{
 
     s ifn=%request.Get("Interface")
 
 	S ol= "<Option Value="""">"
 	
 
 	Set item=""
 	For  {
 		
 		Set item=$O(%session.Data("SysListArray",item))
 		Q:item=""
 		s ol=ol_"<Option Value="""_item_""""
 		
 		if ( ifn = item ) {
 			s ol=ol_"selected=""selected"""
 		}
 		
 		s ol=ol_">"_item
 		
 		
 	
 	}
 	Q ol
}

ClassMethod GetStatus() [ Language = objectscript ]
{
 	Kill SysList
 	Set ProductionName=""
 	Set ProductionStatus=""
 	set status = ##class(Ens.Director).GetProductionStatus(.ProductionName,.ProductionStatus)
 	set production=##class(Ens.Config.Production).%OpenId(ProductionName)
 
 	for i=1:1:production.Items.Count() {
 		
 		// collect item settings
 		s item=production.Items.GetAt(i)
 
 		s name=item.Name
 		s category=$P(item.Category,",",1)
 		s class=item.ClassName
 		s Type=item.BusinessType()
 		
 		s nl=$ListFromString(name,".")
 		s l=$ListLength(nl)
 		s package=$ListToString($List(nl,1,l-2),".")
 		
 		
 	
 		if ( category '= "" ) {
 			s SysList(name,"Enabled")=item.Enabled+0
 			S SysList(name,"ID")=i
 			s SysList(name,"Category")=category
 			s SysList(name,"Type")=item.BusinessType()
 			S SysList(name,"Comment")=item.Comment
 
 		}
 	}
 
 	Kill HostStatus
 	set rs=##class(%ResultSet).%New("Ens.Util.Statistics:EnumerateHostStatus")
 	Set r=rs.Execute()
 	
 	while rs.Next() {
 		Set name=rs.Get("Name")
 		Set HostStatus(name,"Status")=rs.Get("Status")
 		Set HostStatus(name,"AdapterState")=rs.Get("AdapterState")
 		Set HostStatus(name,"LastAction")=rs.Get("LastActivity")
 		Set HostStatus(name,"ElapsedTime")=rs.Get("ElapsedTime")
 		set HostStatus(name,"Queue")=rs.Get("Queue")
 		Set HostStatus(name,"Count")=rs.Get("Count")
 	} 
 	
 	Kill %session.Data("SysListArray")	
	 merge %session.Data("SysListArray")=SysList
 
 	Kill %session.Data("HostStatusArray")
 	merge %session.Data("HostStatusArray")=HostStatus
 	
 	Q 1
}

ClassMethod ToggleInterface(InterfaceName As %String, CurrentStatus As %String) [ Language = objectscript ]
{
 		if ( CurrentStatus=1) {
 			set status = ##class(Ens.Director).EnableConfigItem(InterfaceName,0)
 		} else {
 			set status = ##class(Ens.Director).EnableConfigItem(InterfaceName,1)
 		}
 		
 		Q 1
}

}
