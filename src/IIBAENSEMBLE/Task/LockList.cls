Class IIBAENSEMBLE.Task.LockList Extends %SYS.Task.Definition
{

Parameter TaskName = "LockList";

/// This method is used to create a text file of the lock table information named "LockList"
/// Specify desired file path. Leaving TargetFilePath blank will default to Install directory
Property TargetFilePath As %String;

Method OnTask() As %Status
{
	#Dim tSC As %Status = $$$OK
	#Dim file As %File
	
	s tSC = ..RemoveOldFiles() q:'tSC
	
	if ..TargetFilePath = ""
	{
		s ..TargetFilePath = ##class(%File).ParentDirectoryName(##class(%File).ManagerDirectory())
	}
	
	Set tCompletePath = ##class(%File).NormalizeFilename("LockList.txt",..TargetFilePath)
	
	Set Rset = ##class(%ResultSet).%New("%SYS.LockQuery:List")
	Do Rset.Execute()
	
	Set file = tCompletePath
	Open file:"WNS"
	Use file while Rset.%Next() {
		Do Rset.%Print()
	}
	Close file
	
	Quit tSC
}

Method RemoveOldFiles() As %Status
{
	#Dim tSC As %Status = $$$OK
	
	if ..TargetFilePath = "" {
		s ..TargetFilePath = ##class(%File).ParentDirectoryame(##class(%File).ManagerDirectory())
	}
	
	s ..TargetFilePath = ##class(%File).NormalizeDirectory(..TargetFilePath)
	
	Set rset = ##class(%ResultSet).%New()
	set rset.ClassName = "%File"
	set rset.QueryName = "FileSet"
	Do rset.Execute(..TargetFilePath,"LockList.txt","DateModified",0)
	While rset.Next() {
		s tSC = ##class(%File).Delete(rset.Data("Name")) q:'tSC
	}
	d rset.Close()
	
	Quit tSC
}

}
