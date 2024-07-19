/// Copyright 2007 by Inland Imaging Business Associates
Class IIBAENSEMBLE.WorkflowFunctions Extends Ens.Rule.FunctionSet
{

// Perform an action an a workflow task, or on all workflow tasks for a role.

ClassMethod TaskActionExpr(RoleName As %String = "", Action As %String = "", TaskId As %String = "") As %String [ CodeMode = expression, Final ]
{
..TaskActionFunct(.RoleName,.Action,.TaskId)
}

ClassMethod TaskActionFunct(RoleName As %String = "", Action As %String = "", TaskId As %String = "") As %String [ Final ]
{
	
	if ( Action = ""  ) {
		Q "Not Action Provided"
	}
	
	if (TaskId="") {
	
		s rs=##CLASS(%ResultSet).%New("EnsLib.Workflow.Engine:Worklist")
		d rs.Execute()
	
		while (rs.Next(.sc) ) {
			If ($SYSTEM.Status.IsOK(sc) && (rs.Data("RoleName")=RoleName) ) {
				s TaskId= rs.Get("TaskId")
				d ..SubmitTaskAction(TaskId,Action)
			}
		}
	} else {
		
		d ..SubmitTaskAction(TaskId,Action)
	}
	
	Q $$$OK
}

/// [Previously private]
ClassMethod SubmitTaskAction(TaskId As %String, Action As %String) As %String
{
	s TaskRec=##class(EnsLib.Workflow.TaskResponse).%OpenId(TaskId)
	If ( TaskRec && 'TaskRec.%TaskStatus.IsComplete ) {
		s TaskRec.%Action=Action
		s tsc=##class(EnsLib.Workflow.Engine).CompleteTask(TaskRec,Action)
	}
}

ClassMethod TaskActionByFromValueExpr(RoleName As %String = "", Action As %String = "", FormField As %String = "", FormValue As %String = "") As %String [ CodeMode = expression, Final ]
{
..TaskActionByFromValueFunct(.RoleName,.Action,.FormField,.FormValue)
}

ClassMethod TaskActionByFromValueFunct(RoleName As %String = "", Action As %String = "", FormField As %String = "", FormValue As %String = "") As %String [ Final ]
{
	If ( ( RoleName="" ) || (FormField="") ) {
		Q "Missing Data"
	}
	
	s rs=##CLASS(%ResultSet).%New("EnsLib.Workflow.Engine:Worklist")
	d rs.Execute()
	
	while (rs.Next(.sc) ) {
		If ($SYSTEM.Status.IsOK(sc) && (rs.Data("RoleName")=RoleName) ) {
			s TaskId= rs.Get("TaskId")
			s TaskRec=##class(EnsLib.Workflow.TaskResponse).%OpenId(TaskId)
			Set Value=TaskRec.%FormValues.GetAt(FormField)
			If ( FormValue = Value ) {
				d ..SubmitTaskAction(TaskId,Action)
			}
			
		}
		
	}

	
	Q $$$OK
}

ClassMethod WFCreateOutputFile(filename As %String) As %String
{
	set parentDir = "wfhtml"
	s EnsSysDir = ##class(%File).ParentDirectoryName(##class(%File).ManagerDirectory())
	if '##class(%File).DirectoryExists(EnsSysDir_parentDir) { 
		d ##class(%File).CreateDirectory(EnsSysDir_parentDir) 
	}
	set fullfilename = EnsSysDir_parentDir_"\"_filename
	Quit fullfilename
}

ClassMethod WFReadOutputFile(fullfilename As %String) As %String
{
	set html = ""
	set file = ##class(%File).%New()
	set file.Name = fullfilename
	set tSC = file.Open("R", 5)
	if tSC {
		while 'file.AtEnd {
			set html = html_file.ReadLine()
		}
	}
	
	d file.Close()
	set file = ""
	d ##class(%File).Delete(fullfilename)	
	
	Quit html
}

ClassMethod WFDrawHTMLForm(pTask As EnsLib.Workflow.TaskResponse) As %String
{
	
	set filename = pTask.%Id()_".txt"
	set fullfilename = ##class(IIBAENSEMBLE.WorkflowFunctions).WFCreateOutputFile(filename)
	
	OPEN fullfilename:("NRW"):5
	USE fullfilename
	
	set tSC = ##class(EnsLib.Workflow.FormEngine).DrawHTMLForm(pTask)
	
	CLOSE fullfilename
	
	set html = ##class(IIBAENSEMBLE.WorkflowFunctions).WFReadOutputFile(fullfilename)
	
	set html = $REPLACE(html,"<table","<table id=""fieldvalues""")
	
	Quit html
}

ClassMethod WFDrawActionButtons(worklist As EnsLib.Workflow.Worklist) As %String
{
	// loop over items defined for this task
	Set tActions = worklist.Task.%Actions
	set html=""
	set html=html_"<input type='button' onclick='TakeAction(this.id)' value='Relinquish' ID='$Relinquish'/>"
	set html=html_"<input type='button' onclick='TakeAction(this.id)' value='Save' ID='$Save'/>"
	
	For i = 1:1:$L(tActions,",") {
		Set tAction = $P(tActions,",",i)
		set html=html_"<input type='button' onclick='TakeAction(this.id)' value='"_tAction_"' ID='"_tAction_"'/>"
	}
	Quit html
}

ClassMethod WFSaveFields(worklist As EnsLib.Workflow.Worklist, Fields As %ArrayOfDataTypes) As %Status
{
	set tSC = 1
	
	set ArrayKey = ""
	set ArrayValue = ""
	for  { Set ArrayValue=Fields.GetNext(.ArrayKey) Q:ArrayKey=""
		if $A(ArrayValue) = 0 set ArrayValue = ""
		set tSC = worklist.Task.%FormValues.SetAt(ArrayValue, ArrayKey)
		If $$$ISERR(tSC) Quit
	}
	
	set tSC = worklist.Task.%Save()
	
	Quit tSC
}

ClassMethod WFCreateArray() As %ArrayOfDataTypes
{
	
	Quit ##class(%ArrayOfDataTypes).%New()
}

ClassMethod WFGetTemplate(worklist As EnsLib.Workflow.Worklist, method As %String) As %String
{
	Quit $ZOBJCLASSMETHOD(worklist.Task.%FormTemplate,method,worklist)
}

/// This method is intended to be called from the web client in a .Net application.<br>
/// In order to call a cache method from a client in a .Net app, the following items are required:<br>
/// A json string must be built on the client in the format:<br>
/// {"#ServerCall":{"class":"cache_class_name","method":"cache_method_name"},"Args":{}}<br>
/// if the string "#ServerCall" is detected in the string that is passed from the .Net client to the .Net server<br>
/// the .Net server calls the cache WFCallServerStatus method and passes the whole json string as the only argument.<br>
/// Once this method receives the json string, it decodes it to an ArrayOfDataTypes.<br>
/// The #ServerCall node is used to populate the class and method arguments of the $ZOBJCLASSMETHOD function<br>
/// The Args ArrayOfDataTypes object is also passed, via the $ZOBJCLASSMETHOD, to the method that is being called.<br>
/// Therefore the method that is being called must be a Class method and must accept 1 argument of type ArrayOfDataTypes<br>
/// This method expects a %Status in return and will pass that %Status back to the .Net server<br>
ClassMethod WFCallServerStatus(json As %String) As %Status
{
	set arr = ##class(IIBAENSEMBLE.cls.JSON).JsonDecode(json)
	Quit $ZOBJCLASSMETHOD(arr.GetAt("#ServerCall").GetAt("class"),arr.GetAt("#ServerCall").GetAt("method"),arr.GetAt("Args"))
}

}
