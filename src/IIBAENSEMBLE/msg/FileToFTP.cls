/// Copyright 2007 by Inland Imaging Business Associates
Class IIBAENSEMBLE.msg.FileToFTP Extends %Persistent
{

Property FilePath As %String;

Property FileSpec As %String(MAXLEN = 512);

Property ArchivePath As %String;

Property ArchiveDays As %String;

Storage Default
{
<Data name="FileToFTPDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>ArchiveDays</Value>
</Value>
<Value name="3">
<Value>ArchivePath</Value>
</Value>
<Value name="4">
<Value>FilePath</Value>
</Value>
<Value name="5">
<Value>FileSpec</Value>
</Value>
</Data>
<DataLocation>^IIBAENSEMBLE.msg.FileToFTPD</DataLocation>
<DefaultData>FileToFTPDefaultData</DefaultData>
<ExtentSize>100000</ExtentSize>
<IdLocation>^IIBAENSEMBLE.msg.FileToFTPD</IdLocation>
<IndexLocation>^IIBAENSEMBLE.msg.FileToFTPI</IndexLocation>
<StreamLocation>^IIBAENSEMBLE.msg.FileToFTPS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
