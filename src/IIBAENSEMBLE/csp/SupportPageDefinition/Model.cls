/// Copyright 2007 by Inland Imaging Business Associates
Class IIBAENSEMBLE.csp.SupportPageDefinition.Model Extends %ZEN.DataModel.ObjectDataModel
{

Property PageName As %String;

Property PageTitle As %String;

Property PageClass As %String;

Property MethodOrder As %String;

Property MethodName As %String;

Method %OnOpenSource(pID As %String) As %RegisteredObject
{
  Quit ##class(IIBAENSEMBLE.csp.SupportPageDefinition).%OpenId(pID)
}

Method %OnSaveSource(pSource As IIBAENSEMBLE.csp.SupportPageDefinition) As %Status
{
   Set tSC = pSource.%Save()
   Set ..%id = pSource.%Id()
   Quit tSC
}

Method %OnNewSource(Output pSC As %Status = {$$$OK}) As %RegisteredObject
{
  Quit ##class(IIBAENSEMBLE.csp.SupportPageDefinition).%New()
}

ClassMethod %OnDeleteSource(pID As %String) As %Status
{
  Quit ##class(IIBAENSEMBLE.csp.SupportPageDefinition).%DeleteId(pID)
}

Method %OnLoadModel(pSource As IIBAENSEMBLE.csp.SupportPageDefinition) As %Status
{
    Set ..PageName = pSource.PageName
    Set ..PageTitle = pSource.PageTitle
    Set ..PageClass = pSource.PageClass
    Set ..MethodOrder = pSource.MethodOrder
    Set ..MethodName = pSource.MethodName
    Quit $$$OK
}

Method %OnStoreModel(pSource As IIBAENSEMBLE.csp.SupportPageDefinition) As %Status
{
    Set pSource.PageName = ..PageName
    Set pSource.PageTitle = ..PageTitle
    Set pSource.PageClass = ..PageClass
    Set pSource.MethodOrder = ..MethodOrder
    Set pSource.MethodName = ..MethodName
    Quit pSource.%Save()
}

}
