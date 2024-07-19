/// Copyright 2007 by Inland Imaging Business Associates
/// <h2>Nuvodia Toolkit Class</h2>
/// <CLASS>%Persistent</CLASS> data class that renders the dynamic support pages 
Class IIBAENSEMBLE.csp.SupportPageDefinition Extends %Persistent
{

/// PageName is used as the Query Parameter &PageName=[value] to render this page.
Property PageName As %String(MAXLEN = 256);

/// Page Display Title
Property PageTitle As %String(MAXLEN = 256);

/// Page Class that is used to render the page
Property PageClass As %String(MAXLEN = 256);

/// When there are multiple Methods for a page this give the order to execute them in.
Property MethodOrder As %String(MAXLEN = 256);

/// MethodName called to render the page
Property MethodName As %String(MAXLEN = 256);

/// Gets the Methods for this <PROPERTY>PageName</PROPERTY> in execute order.
Query GetPageMethods(PageName As %String = "SystemStatus") As %SQLQuery
{
SELECT PageClass,MethodName FROM SupportPageDefinition
 WHERE (PageName = :PageName)
 ORDER BY MethodOrder
}

/// Get the Title for this <PROPERTY>PageName</PROPERTY> 
Query GetPageTitle(PageName As %String = "SystemStatus") As %SQLQuery
{
SELECT top 1 PageTitle FROM SupportPageDefinition
 WHERE (PageName = :PageName)
}

Storage Default
{
<Data name="SupportPageDefinitionDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>MethodName</Value>
</Value>
<Value name="3">
<Value>MethodOrder</Value>
</Value>
<Value name="4">
<Value>PageClass</Value>
</Value>
<Value name="5">
<Value>PageName</Value>
</Value>
<Value name="6">
<Value>PageTitle</Value>
</Value>
</Data>
<DataLocation>^IIBAENSEMBL4D4.SupportPageD883D</DataLocation>
<DefaultData>SupportPageDefinitionDefaultData</DefaultData>
<ExtentSize>100000</ExtentSize>
<IdLocation>^IIBAENSEMBL4D4.SupportPageD883D</IdLocation>
<IndexLocation>^IIBAENSEMBL4D4.SupportPageD883I</IndexLocation>
<StreamLocation>^IIBAENSEMBL4D4.SupportPageD883S</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
