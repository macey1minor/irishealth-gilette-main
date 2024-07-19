/// Copyright 2007 by Inland Imaging Business Associates
Class IIBAENSEMBLE.Task.GetProductionItems Extends %SYS.Task.Definition
{

Parameter TaskName = "GetProductionItems";

Method OnTask() As %Status
{
	set NameSpace = $ZNSPACE
	
	&sql(DELETE FROM IIBAENSEMBLE_Task.TaskItemDefinition
		WHERE NameSpace = :NameSpace AND ItemType = 'ProdItems')
	
	Set ProductionName=""
	Set ProductionStatus=""
	set status = ##class(Ens.Director).GetProductionStatus(.ProductionName,.ProductionStatus)

	set production=##class(Ens.Config.Production).%OpenId(ProductionName)

	for i=1:1:production.Items.Count() {
		
		// collect item names
		s item=production.Items.GetAt(i)
		s name=item.Name
		&sql(INSERT INTO IIBAENSEMBLE_Task.TaskItemDefinition
			(NameSpace, ItemType, ItemName)
			VALUES
			(:NameSpace, 'ProdItems', :name))
	}
	
	Quit $$$OK
}

}
