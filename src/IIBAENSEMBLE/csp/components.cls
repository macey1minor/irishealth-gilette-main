/// Copyright 2007 by Inland Imaging Business Associates
Class IIBAENSEMBLE.csp.components Extends (%Persistent, %XML.Adaptor) [ Inheritance = right ]
{

ClassMethod navbar()
{

	w "<table><tr><td class=""LayoutContentCol"" width=""20%"" ><div class=""DetailCommand"">"
	//Req#5 - PHegel - Tab Security based on resource permisssion for each menu item using the page name as resource where not defined already.
	if ##class(%SYSTEM.Security).Check("SystemStatus","USE"){
		w "<a id=""linkSystemStatus"" class=""DetailCommand"" target=""_top"" href=""IIBASupport.csp?PageName=SystemStatus""><nobr>&nbsp;Home&nbsp;</nobr></A>"
		w "&nbsp;"
	}
	if ##class(%SYSTEM.Security).Check("SystemList","USE"){
		w "<a id=""linkSystemList"" class=""DetailCommand"" target=""_top"" href=""IIBASupport.csp?PageName=SystemList""><nobr>&nbsp;Interface List&nbsp;</nobr></A>"
		w "&nbsp;"
	}
	if ##class(%SYSTEM.Security).Check("SearchUtil","USE"){
		w "<a id=""linkSearchUtil"" class=""DetailCommand"" target=""_top"" href=""IIBASupport.csp?PageName=SearchUtil""><nobr>&nbsp;Message Search&nbsp;</nobr></A>"
		w "&nbsp;"
	}
	if ##class(%SYSTEM.Security).Check("LookUpTableAdmin","USE"){
		w "<a id=""linkLookUp"" class=""DetailCommand"" target=""_top"" href=""IIBASupport.csp?PageName=LookUp""><nobr>&nbsp;Lookup&nbsp;</nobr></A>"
		w "&nbsp;"
	}
	// Req#1 - PHegel - Change to just check Use permission.  Let the table resource define Read/Write permissions
	if ##class(%SYSTEM.Security).Check("Reference","USE") {
		w "<a id=""linkReference"" class=""DetailCommand"" target=""_top"" href=""IIBASupport.csp?PageName=Reference""><nobr>&nbsp;xRef&nbsp;</nobr></A>"
		w "&nbsp;"
	}
	if ##class(%SYSTEM.Security).Check("AlertAdmin","USE"){
		w "<a id=""linkAlertAdmin"" class=""DetailCommand"" target=""_top"" href=""IIBASupport.csp?PageName=AlertAdmin""><nobr>&nbsp;Alert Admin&nbsp;</nobr></A>"
		w "&nbsp;"
	}
	if ##class(%SYSTEM.Security).Check("TaskMgmt","USE"){
		w "<a id=""linkTaskMgmt"" class=""DetailCommand"" target=""_top"" href=""IIBASupport.csp?PageName=TaskMgmt""><nobr>&nbsp;Tasks&nbsp;</nobr></A>"
		w "&nbsp;"
	}
	if ##class(%SYSTEM.Security).Check("ErrorWorkflow","USE"){
		w "<a class=""DetailCommand"" target=""_blank"" href=""_DeepSee.UserPortal.Workflow.zen""><nobr>&nbsp;Error Workflow&nbsp;</nobr></A>"
		//w "&nbsp;"
		//w "<a class=""DetailCommand"" target=""_top"" href=""IIBASupportDetail.csp?PageName=Mobile""><nobr>&nbsp;Mobile&nbsp;</nobr></A>"
		
	 	w "&nbsp;"
	}
	if ##class(%SYSTEM.Security).Check("Manage","USE"){
		s tDefaultApp = $SYSTEM.CSP.GetDefaultApp($NAMESPACE)
		w "<a class=""DetailCommand"" target=""_blank"" href="""_tDefaultApp_"/%25CSP.Portal.Home.zen""><nobr>&nbsp;Manage&nbsp;</nobr></A>"

	 	w "&nbsp;"
	}
	// Updgrade - Phegel - logout method changed for upgrade to Version 2013.1.4
	//w "<a class='DetailCommand' target='_self' href='%25CSP.Login.cls?LOGOUT=1&Error:URL=IIBASupport.csp'><nobr>&nbsp;Logout&nbsp;</nobr></A>"
	w "<a class='DetailCommand' target='_self' href='?CacheLogout=end'><nobr>&nbsp;Logout&nbsp;</nobr></A>"
 	w "&nbsp;"
 	
	w "<a class=""DetailCommand""><nobr>&nbsp;NameSpace:&nbsp;</nobr></a>"
	&html<<select id="nscombo" style="font-size: 0.8em; color: darkblue; font-weight: bold;" onchange="self.document.location=this.value;">>
	Set tNS = $O(^%SYS("Ensemble","InstalledNamespace",""))
	While (tNS '= "") {
		Set tSel = $S(tNS=$ZNSPACE:"selected",1:"")
		s tDefaultApp = $SYSTEM.CSP.GetDefaultApp(tNS)
		Set tURL = tDefaultApp_"/"_$S(%request.Get("PageName")="":%request.PageName,1:"IIBASupport.csp?PageName="_%request.Get("PageName"))
		if (##class(%SYSTEM.Security).Check("NS_"_tNS) = "READ,WRITE,USE")&&(tNS'="IIBA") {
			&html<<option value="#(tURL)#" #(tSel)#>#($ZCVT(tNS,"O","HTML"))#>
		}
		Set tNS = $O(^%SYS("Ensemble","InstalledNamespace",tNS))
	}
	&html<</select>&nbsp;>
	
	//Do ##class(%CSP.Portal.Utils).%AddFavorite(pName,pLink)
	s tDefaultApp = $SYSTEM.CSP.GetDefaultApp($NAMESPACE)
	s pURL=tDefaultApp_"/"_$S(%request.Get("PageName")="":%request.PageName,1:"IIBASupport.csp?PageName="_%request.Get("PageName"))
	s pName="Nuvo "_$S(%request.Get("PageName")="":"Toolkit",1:$ZNSPACE_" / "_%request.Get("PageName"))
	w "&nbsp;"

	W "<img class='DetailCommand' target='_blank' title='add to Ensemble Favorites' src='CustomImages/star.png' alt='add to Favorites' onclick='addFavorite("""_pName_""","""_pURL_""")' />"

	w "</div></td></tr></table>"
}

ClassMethod troubleditems(linktopopup As %Boolean)
{
	set rs = ##class(%ResultSet).%New()
	do rs.Prepare("Select ItemName,Parameter,NameSpace,LastStatus,EmailText from IIBAENSEMBLE_Monitor.ItemStatus WHERE Troubled = 1 ORDER BY ItemName")
	do rs.Execute()
	
	set rowcount = 0
	
	While rs.Next() {
		
		set rowcount = rowcount + 1
		
		if rowcount = 1 {
			w "<H3><font color=red>Troubled Items:</font></H3>"
			//w "<TABLE Border=1 CellPadding=3><TR><TH>Name</TH><TH>Comment</TH><TH>Type</TH><TH>Alert Parameter</TH><TH>Current Status</TH><TH>Queue Size</TH></TR>"
			w "<TABLE Border=1 CellPadding=3><TR><TH>Name</TH><TH>Alert Parameter</TH><TH>Current Status</TH><TH>Queue Size</TH><TH>&nbsp;</TH></TR>"
		}
		
		set ItemID="", ItemName = rs.Data("ItemName"), QueueSize=0
	
		&sql(select ID into :ItemID from Ens_Config.Item where Name = :ItemName)
	
		set item = ##class(Ens.Config.Item).%OpenId(ItemID)
		
		set qrs=##class(%ResultSet).%New("Ens.Queue:Enumerate")
		do qrs.Execute()
	
		while qrs.Next() {
			if ( qrs.Get("Name") = ItemName ) {
				Set QueueSize=qrs.Get("Count")
			}
		} 
		
		
		w "<TR>"
		if linktopopup { w "<TD><A HREF='/csp/"_rs.Data("NameSpace")_"/IIBASupportDetail.csp?PageName=InterfaceStatus&InterfaceName="_ItemName_"&InterfaceId="_ItemID_"' Target='_blank'  Height=20 width=40  >"_rs.Data("ItemName")_"</A></TD>" }
		else { w "<TD>"_rs.Data("ItemName")_"</TD>" }
		//w "<TD>"_$SELECT(item.Comment="":"&nbsp",1:item.Comment)_"</TD>"
		//w "<TD>"_$P("Service,Process,Operation",",",item.BusinessType())_"</TD>"
		w "<TD>"_rs.Data("Parameter")_"</TD>"
		w "<TD>"_rs.Data("LastStatus")_"</TD>"
		w "<TD>"_QueueSize_"</TD>"
		W "<TD>"
		S EmailText=$G(rs.Data("EmailText"))
		if (EmailText'="") {
			
			W "<input type='image' src='customimages/question.gif' id='emailButton' onclick='alert("""_EmailText_""")'/>"
		} else {
			w "&nbsp;"
		}
		w "</TD></TR>"
		
				
	}
	
	if rowcount > 0 {w "</TABLE>"}
}

Storage Default
{
<Data name="componentsDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
</Data>
<DataLocation>^IIBAENSEMBLE.csp.componentsD</DataLocation>
<DefaultData>componentsDefaultData</DefaultData>
<ExtentSize>100000</ExtentSize>
<IdLocation>^IIBAENSEMBLE.csp.componentsD</IdLocation>
<IndexLocation>^IIBAENSEMBLE.csp.componentsI</IndexLocation>
<StreamLocation>^IIBAENSEMBLE.csp.componentsS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
