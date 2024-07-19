/// Copyright 2007 by Inland Imaging Business Associates
Class IIBAENSEMBLE.Task.TaskItemDefinitionAdmin.Model Extends %ZEN.DataModel.ObjectDataModel
{

Property NameSpace As %String;

Property ItemType As %String;

Property ItemName As %String;

Property ItemValue As %String;

Method %OnOpenSource(pID As %String) As %RegisteredObject
{
  Quit ##class(IIBAENSEMBLE.Task.TaskItemDefinition).%OpenId(pID)
}

Method %OnSaveSource(pSource As IIBAENSEMBLE.Task.TaskItemDefinition) As %Status
{
   Set tSC = pSource.%Save()
   Set ..%id = pSource.%Id()
   Quit tSC
}

Method %OnNewSource(Output pSC As %Status = {$$$OK}) As %RegisteredObject
{
  Quit ##class(IIBAENSEMBLE.Task.TaskItemDefinition).%New()
}

ClassMethod %OnDeleteSource(pID As %String) As %Status
{
  Quit ##class(IIBAENSEMBLE.Task.TaskItemDefinition).%DeleteId(pID)
}

Method %OnLoadModel(pSource As IIBAENSEMBLE.Task.TaskItemDefinition) As %Status
{
    Set ..NameSpace = pSource.NameSpace
    Set ..ItemType = pSource.ItemType
    Set ..ItemName = pSource.ItemName
    Set ..ItemValue = pSource.ItemValue
    Quit $$$OK
}

Method %OnStoreModel(pSource As IIBAENSEMBLE.Task.TaskItemDefinition) As %Status
{
    Set pSource.NameSpace = ..NameSpace
    Set pSource.ItemType = ..ItemType
    Set pSource.ItemName = ..ItemName
    Set pSource.ItemValue = ..ItemValue
    Quit pSource.%Save()
}

}
