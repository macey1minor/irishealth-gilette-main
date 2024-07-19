Class IIBAENSEMBLE.Task.CycleInterface Extends %SYS.Task.Definition
{

Parameter TaskName = "CycleInterface";

Property InterfaceName As %String;

/// Inactivity time before cycle the interface (Minutes)
Property InactivityThreshold As %String [ InitialExpression = "60" ];

Method OnTask() As %Status
{
	
	D ##class(IIBAENSEMBLE.Utilities).CycleInterface(..InterfaceName,..InactivityThreshold)
	
	
	
	Quit $$$OK
}

}
