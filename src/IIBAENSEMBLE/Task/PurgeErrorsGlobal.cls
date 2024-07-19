Class IIBAENSEMBLE.Task.PurgeErrorsGlobal Extends %SYS.Task.Definition
{

Property tNumberOfDaysToKeep As %String;

Method OnTask() As %Status
{
	Try {
		//Set tNumberOfDaysToKeep = 3
		Set tH = $H - ..tNumberOfDaysToKeep
		For  Set tH = $O(^ERRORS(tH),-1) Quit:tH=""  Kill ^ERRORS(tH)
	} Catch errobj {
		Throw errobj
	}
	Quit $$$OK
}

}
