Class IIBAENSEMBLE.csp.TcpPortList Extends %CSP.Page [ ProcedureBlock ]
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
  
  <link rel="stylesheet" type="text/css" href="ext/resources/css/ext-all.css" />
  <script type="text/javascript" src="ext/adapter/ext/ext-base.js"></script>
  <script type="text/javascript" src="ext/ext-all.js"></script>
  <script type="text/javascript" src="ext/examples/grid-filtering/grid/GridFilters.js"></script>
  <script type="text/javascript" src="ext/examples/grid-filtering/grid/filter/Filter.js"></script>
  <script type="text/javascript" src="ext/examples/grid-filtering/grid/filter/StringFilter.js"></script>
  <script type="text/javascript" src="ext/examples/grid-filtering/grid/filter/DateFilter.js"></script>
  <script type="text/javascript" src="ext/examples/grid-filtering/grid/filter/ListFilter.js"></script>
  <script type="text/javascript" src="ext/examples/grid-filtering/grid/filter/NumericFilter.js"></script>
  <script type="text/javascript" src="ext/examples/grid-filtering/grid/filter/BooleanFilter.js"></script>
  <script type="text/javascript" src="ext/examples/grid-filtering/menu/EditableItem.js"></script>
  <script type="text/javascript" src="ext/examples/grid-filtering/menu/RangeMenu.js"></script>
	
	
   <script language=javascript>
	<!--
	
	
	var portData=[];
	
	function displayGrid(){
		
		
	
		#server(..LoadGridData())#
		
		var myData = [
			['IIBARIS','item 1','service','10001'],
			['IIBACLIN','item 2','service','10002']
		];
		
		var portList = new Ext.data.SimpleStore({
			fields: [
				{name: 'namespace'},
				{name: 'interfaceName'},
				{name: 'interfaceType'},
				{name: 'interfacePort'}
			]
		
		});
			
		
		portList.loadData(portData);
		
		
		Ext.menu.RangeMenu.prototype.icons = {
	  		gt: 'ext/examples/grid-filtering/img/greater_then.png', 
	  		lt: 'ext/examples/grid-filtering/img/less_then.png',
	  		eq: 'ext/examples/grid-filtering/img/equals.png'
		};
		Ext.grid.filter.StringFilter.prototype.icon = 'ext/examples/grid-filtering/img/find.png';
		
		var filters = new Ext.grid.GridFilters({ 
			local: true,
			filters:[
				{type: 'string', dataIndex: 'namespace'},
				{type: 'string', dataIndex: 'interfaceName'},
				{type: 'list', dataIndex: 'interfaceType', options: ['Operation','Service']},
				{type: 'numeric', dataIndex: 'interfacePort'}
			]
			
		});
		
		var portColumns = new Ext.grid.ColumnModel([
			{dataIndex: 'namespace', header: 'Namespace'},
			{dataIndex: 'interfaceName', header: 'Interface Name'},
			{dataIndex: 'interfaceType', header: 'Interface Type'},
			{dataIndex: 'interfacePort', header: 'Port'}
		]);
		portColumns.defaultSortable=true;
	
		var portGrid=new Ext.grid.GridPanel({
			store: portList,
			columns: [
				{id: 'Namespace', header: "Namespace", width: 100, sortable: true, dataIndex: 'namespace'},
				{header: "Interface", sortable: true, width: 350, dataIndex: 'interfaceName'},
				{header: "Type", width: 100, sortable: true, dataIndex: 'interfaceType'},
				{header: "Port", width: 100, sortable: true, align: 'right', dataIndex: 'interfacePort'}
			],
			stripeRows: true,
			
			plugins: filters,
			height:600,
       	 	width:675
			
		});
		
			
		
		portGrid.render('portUseDetails');
	}
	
	

	
	function Initialize()
	{
		
		displayGrid();
	}
	function changeScreenSize(w,h)  {   
		window.resizeTo( w,h )     
	}
	-->
	</script>
	>
}

ClassMethod html()
{
	k PortList
	
	set cNameSpace = $ZNSPACE
	W "<P>"
	W "<Div id='portUseDetails' >"
	W "</Div>"
	
	 
	ZN cNameSpace
}

ClassMethod LoadGridData()
{
	&js<portData=[];>
	
	K NamespaceList
	//Do List^%SYS.NAMESPACE(.NamespaceList,0)
	K SystemInfo
	d ##class(Ens.Director).GetSystemProductionSummary(.SystemInfo)
	
	
	
	s Namespace=""
	F  {
		s Namespace=$O(SystemInfo(Namespace))
		Q:Namespace=""
		Continue:$O(SystemInfo(Namespace,""))=""
		
		zn Namespace
		Set ProductionName=""
		Set ProductionStatus=""
		set status = ##class(Ens.Director).GetProductionStatus(.ProductionName,.ProductionStatus)
		Continue:ProductionName=""
		
		set production=##class(Ens.Config.Production).%OpenId(ProductionName)
		
		for i=1:1:production.Items.Count() {
		
			s item=production.Items.GetAt(i)
			s name=item.Name
		
			for j=1:1:item.Settings.Count() {
				
				 
				
				s st = item.Settings.GetAt(j)
				I (st.Name="Port") {
					//w item.Name,"  ",$P("Service,,Operation",",",item.BusinessType()),"  ",st.Name,"  ",st.Value,!
					//w "<TR><TD>",ProductionName,"</TD><TD>",item.Name,"</TD><TD>",$P("Service,,Operation",",",item.BusinessType()),"</TD><TD>",st.Value,"</TD></TR>"
					s portRow="['"_Namespace_"','"_item.Name_"','"_$P("Service,,Operation",",",item.BusinessType())_"',"_st.Value_"]"
					
					
					
					&js< portData.push(#(portRow)#); >
					
					
				}
			}
		
		
		
		}
	}
}

}
