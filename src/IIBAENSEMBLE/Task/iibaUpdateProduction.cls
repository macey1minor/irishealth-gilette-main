Class IIBAENSEMBLE.Task.iibaUpdateProduction Extends %SYS.Task.Definition
{

Parameter TaskName = "iibaUpdateProduction";

Method OnTask() As %Status
{
	#dim tSC As %Status = $$$OK
	
	d ##class(Ens.Director).UpdateProduction()
	
	Quit tSC
}

}
