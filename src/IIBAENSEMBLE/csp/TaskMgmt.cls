/// Copyright 2007 by Inland Imaging Business Associates
Class IIBAENSEMBLE.csp.TaskMgmt Extends %CSP.Page [ ProcedureBlock ]
{

ClassMethod CheckPermissions()
{
	set Allowed = 0
	//Req#5 - PHegel Tab Security Use for page name
	if ##class(%SYSTEM.Security).Check("TaskMgmt","USE"){ 
		set Allowed = 1 
	}
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
 // documentation:
 // The list of tasks is dynamically build from the Task Item Definitions table.
 // To add a task to the Tasks page follow these steps:
 //	1. Create a class for the task.  You may use this class as a template: IIBAENSEMBLE.cspTask.Template. The below functions are optional and may be deleted if they are not needed.
 //		a. CheckPermissions method - if you want to limit access to this task use this method to determine access. How to call this method is detailed below.
 //		b. jsfunction method - if there are any java script functions you need to have available include them here.
 //		c. html method - put in your title, button and any other html elements here.  These may inlcude drop down lists or anything else you may need.
 //		d. cosmethod method - This is one server side method you can call from a js function.  You can have as many server side methods as you need.
 //	2. Create entries in the Task Item Definitions class to add your task to to the tasks page.
 //		a. NameSpace - Enter the namespace in which you want the task to appear.  If you want it in multiple namespaces you will need to make these entries separately for each namespace.
 //		b. ItemType - "TaskMgmtMethods"
 //		c. ItemName - two components separated by ^
 //			1) A serial number indicating the order in which you would like the task to appear on the page.
 //			2) The name of the task.  This value is also displayed as the field set caption that surrounds the html for your task.
 //		d. ItemValue - three components separated by ^
 //			1) A serial number indicating the order in which you would like the methods to be called. See below for the recommended order.
 //			2) The name of the class created in step 1 above.
 //			3) The name of the method to call.  On the recommended order in which to call the methods see 2.d.1
 //				a) CheckPermissions - if you are going to control access to the task, you must call this method first.
 //				b) jsfunction - if needed, call the jsfunction before the html function so that any js functions or objects exist in the page before building the html.
 //				c) html - 
 //				d) other - typically you will call server side methods when events occur on the page so you don't need to enter them here.  However you may call any method you need to on page load.

 
 

 set ClassName="",TaskName="",MethodName="",NameSpace=$ZNSPACE
 set tItemName="",tItemValue=""
 w "<table width=900px><tr><td width=5%/><td width=90% >"
 
				
 set rsNames = ##class(%ResultSet).%New("IIBAENSEMBLE.Task.TaskItemDefinition:GetTaskItemNames")
 do rsNames.Execute(NameSpace)
 while rsNames.Next() { 
 
	set TaskName=$P(rsNames.Data("ItemName"),"^",2)
		
	set WriteFieldSet=1
	set Allowed = 1
		
		
	set rsValues = ##class(%ResultSet).%New("IIBAENSEMBLE.Task.TaskItemDefinition:GetTaskItemValues")
 	do rsValues.Execute(NameSpace,rsNames.Data("ItemName"))
 	while rsValues.Next() { 	
	
		set ClassName = $P(rsValues.Data("ItemValue"),"^",2)
		set MethodName = $P(rsValues.Data("ItemValue"),"^",3)
				
				If MethodName="CheckPermissions" {
					TRY {	
						set Allowed = $ZOBJCLASSMETHOD(ClassName,MethodName)
					} CATCH errobj {
						w "<font color=red>Error occured with: "_errobj.Data_"</font><br>"
					}
				}
				
				Quit:Allowed=0
				
				if Allowed && WriteFieldSet {
					w "<fieldset>"
					w "<legend>"_TaskName_"</legend>"
					set WriteFieldSet=0
				}
				
				If MethodName'="CheckPermissions" {
					TRY {	
						do $ZOBJCLASSMETHOD(ClassName,MethodName)
					} CATCH errobj {
						w "<font color=red>Error occured with: "_errobj.Data_"</font><br>"
					}
				}
			
 	}
			
		
 If Allowed { w "</fieldset><p>" }
 }
		
		

 w "<td width=5%/></tr></table>"
}

}
