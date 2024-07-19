/// Copyright 2007 by Inland Imaging Business Associates
Class IIBAENSEMBLE.csp.InterfaceStatus Extends %CSP.Page [ ProcedureBlock ]
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
		
		window.focus();
	}
	function changeScreenSize(w,h)  {   
		window.resizeTo( w,h )     
	}
	
	function jClearQueue(interfaceName) {
		var c=confirm('Clear message Queue for interfce: '+interfaceName+'?');
		if ( c == true) {
			var x=#server(..cClearQueue(interfaceName))#;
		}
	}
	
	function eventLogView(namespace,interfaceName) {
		
		var d=#server(..cEventLogView(interfaceName))#;
		
		window.open('EnsPortal.EventLog.zen?$NAMESPACE='+namespace);
	}
	
  -->
   </script>
  >
}

ClassMethod html()
{
    Set Mode=%request.Get("Mode")
	If (Mode="ToggleStatus") {
		/**/
		Set InterfaceName=%request.Get("InterfaceName")
		
		If ( %request.Get("Istatus")="Enabled") {
			
			Job ##class(Ens.Director).EnableConfigItem(InterfaceName,0)::10
			// Wait up to 30 seconds until the item has stopped.
			For i=1:1:10 {
				Q:'##class(Ens.Director).IsItemEnabled(InterfaceName)
				Hang 3
				
			}
			/*
			set status = ##class(Ens.Director).EnableConfigItem(%request.Get("InterfaceName"),0)
			if (status=$$$OK) {
				&js<'status: OK'>
			} else {
				&js<'status: #(status)#'>
			}
			*/
			
			
		} else {
			Job ##class(Ens.Director).EnableConfigItem(InterfaceName,1)::10
			// Wait up to 30 seconds until the item has started.
			For i=1:1:10 {
				Q:##class(Ens.Director).IsItemEnabled(InterfaceName)
				Hang 3
				
			}
			/*
			set status = ##class(Ens.Director).EnableConfigItem(%request.Get("InterfaceName"),1)
			if (status=$$$OK) {
				&js<'status: OK'>
			} else {
				&js<'status: #(status)#'>
			}
			*/
		}
		
		//set curRoles=$ROLES
		//set $ROLES=$ROLES_",IIBA_UpdateProduction"
		//set upstatus = ##class(Ens.Director).UpdateProduction()
		//set $ROLES=curRoles
		
	}
	
	Set Mode="ViewStatus"
	
	Set ProductionName=""
	Set ProductionStatus=""
	set status = ##class(Ens.Director).GetProductionStatus(.ProductionName,.ProductionStatus)

	Set Name=%request.Get("InterfaceName")
	Set InterfaceId=%request.Get("InterfaceId")
	
	Write "<CENTER><H1>"_Name_"</H1></CENTER>"
	Write "<BR><HR><BR>"
	
	Set Category=""
	Set ClassName=""
	Set Comment=""
	Set Enabled=""
	Set QueueSize=0
	&sql(Select Category, ClassName, Comment, Enabled
			into :Category, :ClassName, :Comment, :Enabled
			from Ens_config.Item
			where Name=:Name)
			
	set rs=##class(%ResultSet).%New("Ens.Queue:Enumerate")
	Set r=rs.Execute()
	
	while rs.Next() {
		if ( rs.Get("Name") = Name ) {
			Set QueueSize=rs.Get("Count")
		}
	} 

	W "<Form name='InterfaceStatusForm' id='InterfaceStatusForm'><TABLE  CellPadding=3>"
	W "<TR><TD>Name: </TD>"
	W "<TD><INPUT Type='Text' Name=Iname id=Iname size=50 readonly value='"_Name_"'></TD></TR>"
	W "<TR><TD>Production:</TD>"
	W "<TD>"
	IF ( ProductionStatus '= 1 ) {
		W "<Font Color=RED>"
	}
	W ProductionName_" ("_$P("Running,Stopped,Suspended,Troubled",",",ProductionStatus)_")"
	IF ( ProductionStatus '= 1 ) {
		W "</Font>"
	}
	W "</TD>"
	W "<TR><TD>Category: </TD>"
	W "<TD><INPUT Type='Text' size=50 readonly value='"_Category_"'></TD></TR>"
	W "<TR><TD>ClassName: </TD>"
	W "<TD><INPUT Type='Text' size=50 readonly value='"_ClassName_"'></TD></TR>"
	W "<TR><TD>Comment</TD>"
	W "<TD><INPUT Type='Text' size=50 readonly value='"_Comment_"'></TD></TR>"
	W "<TR><TD>Status</TD>"
	W "<TD><INPUT Type='Text' Name=Ienabled id=Ienabled size=50 readonly value='"
	If ( Enabled=1) {
		W "Enabled"
		S NewStatus="Disable"
	} Else {
		W "Disabled"
		S NewStatus="Enable"
	}
	W "'/INPUT></TD></TR>"
	W "<TR><TD>"
		If ( QueueSize > 0 ) {
		//W "<A HREF='IIBAUtilEnsQlist.csp?$ID1="_Name_"&$NAMESPACE=.Production' target='_blank'>"
		W "<A HREF='EnsPortal.QList.cls?QUEUE="_Name_"' target='_blank'>"
	}
	W "Queue Size"
		If ( QueueSize > 0 ) {
		W "</A>"
	}
	W "</TD><TD>"
	W "<INPUT Type='Text' size=50 readonly value='"_QueueSize_"'></TD>"
	if ( (QueueSize > 0) && (##class(%SYSTEM.Security).Check("%All") = "READ,WRITE,USE")) {
		W "<TD><Input Type='Button' Name='btnClearQ' id='btnClearQ' Value='Clear Queue' onclick='jClearQueue("""_%request.Get("InterfaceName")_""")' ></TD>"
	}
	W "</TR>"
	
	//w "<tr><td>InterfaceId:"_InterfaceId_"</td></tr>"
	if ( InterfaceId '= "" ) {
		set item = ##class(Ens.Config.Item).%OpenId(InterfaceId)
		for i=1:1:item.Settings.Count() {
			s st = item.Settings.GetAt(i)
			If ( st.Value '="" ) { 
				W "<TR><TD>"_st.Name,"</TD>"
				W "<TD><INPUT Type='Text' size=50 readonly value='"_##class(%CSP.Page).EscapeHTML(st.Value)_"'</TD>"
				if (st.Name="BusinessRuleName"){
					
					s RulePackage=""
					S RulePackage=$P(st.Value,".",1,$L(st.Value,".")-1)
					W "<TD><Input Type='Button' Name='ViewRule' id='ViewRule' Value='View Rules' onclick='window.open(""EnsPortal.RuleEditor.zen?RULE="_st.Value_""")' ></TD>"
					
				}
				W "</TR>",!
			}
		}
	}
	
	Set DocumentationRoot=##class(IIBAENSEMBLE.Functions).TableLookup(".Root Directories","Document Path","","INTERFACEMAPS")
	
	Set DocumentationPath=##class(IIBAENSEMBLE.Functions).TableLookup(%request.Get("InterfaceName"),"Document Path",,"InterfaceMaps")
	Set FullDocumentPath=""
	
	If (DocumentationPath="") {
		S DocDisabled="disabled"
	} else {
		s DocDisabled=""
		If ( DocumentationRoot="" ) {
			S FullDocumentPath=..QuoteJS(DocumentationPath)
		} else {
			S FullDocumentPath=..QuoteJS(DocumentationRoot_"\"_DocumentationPath)
		}
	}
	
	Set DiagramRoot=##class(IIBAENSEMBLE.Functions).TableLookup(".Root Directories","Diagram Path","","INTERFACEMAPS")
	
	
	Set DiagramPath=##class(IIBAENSEMBLE.Functions).TableLookup(%request.Get("InterfaceName"),"Diagram Path",,"InterfaceMaps")
	Set FullDiagramPath=""
	
	if ( DiagramPath="" ) {
		s DiagramDisabled="disabled"
	} else {
		S DiagramDisabled=""
		If ( DiagramRoot="") {
			S FullDiagramPath=..QuoteJS(DiagramPath)
		} else {
			S FullDiagramPath=..QuoteJS(DiagramRoot_"\"_DiagramPath)
		}
	}

	Set VisioPath=DocumentationPath_"\EnsInterfaceMap.vsd"
	
	 if ##class(%SYSTEM.Security).Check("IIBAcycleinterface","READ") {
		 s disabled=""
	 } else {
		 s disabled="disabled='disabled'"
	 }
	
	
	
	&html<
	<TR><TD></TD>
	<TD>
	<Input Type="Button" Name="btnStatus" id="btnStatus" #(disabled)# Value=#(NewStatus)# onclick='self.document.location="IIBASupportDetail.csp?PageName=InterfaceStatus&InterfaceName=#(Name)#&InterfaceId=#(InterfaceId)#&Mode=ToggleStatus&Istatus="+document.InterfaceStatusForm.Ienabled.value' >
	<Input Type="Button" Name="btnDoc" id="btnDoc" #($G(DocDisabled))# Value="Documentation" onclick="window.open(#(FullDocumentPath)#)" > 
	<Input Type="Button" Name="btnImg" id="btnImg" #($G(DiagramDisabled))# Value="Diagram" onclick="window.open(#(FullDiagramPath)#)" >
	<Input Type="Button" Name="BtnEvenLog" id="BtnEvenLog" Value="Event Log" onclick='eventLogView("#(ProductionName)#","#(Name)#")'>
	</TD>
	</TR>
	<TR><TD>
	>
	
	
	&html<
	</TABLE>
	
	>
}

ClassMethod cClearQueue(InterfaceName As %String)
{
	//&js<alert('in cClearQueue'+#(InterfaceName)#);>
	d ##class(IIBAENSEMBLE.Utilities).ClearQueue(InterfaceName)
	
	Quit 1
}

ClassMethod cEventLogView(InterfaceName As %String)
{
	// Set default sort criteria for Even Log Pane
	s ^CacheTemp.EnsPortal($username,"EventLog","SearchCriteria")="Newest First^999^"_InterfaceName_",,,,,,,,,,^0,0,0,0,0,0^500^0,0,1,0^None"
	
	Quit 1
}

ClassMethod cosmethod(param As %String)
{
	
	&js<alert('Hello');>
	Quit 1
}

}
