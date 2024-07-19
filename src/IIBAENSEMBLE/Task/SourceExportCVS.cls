/// In order to use this class the following is required:<br>
/// <ul>
/// <li>System Environment Variable as CVSROOT=:pserver:&lt;username&gt;@&lt;servername&gt;:&lt;port&gt;/&lt;directory or module path&gt;</li>
/// <li>System Environment Variable as CVS_PASSFILE=&lt;local file path&gt;\.cvspass</li>
/// <li>Windows needs to be restarted after adding these variables</li>
/// <li>All CVS commands should be executed by the user account that will be the assigned user for the scheduled task - typically the domain service acount.</li>
/// <li>use ! shell from terminal to execute "cvs login".  Once logged in, it should stay logged in permanently.</li>
/// <li>Once logged in, create a sub folder at the NameSpace root to be the local copy of the repository</li>
/// <li>run a file export to get an initial copy of all class files into the subfolder, or just create a single blank text file</li>
/// <li>from within the subfolder, run "cvs import -m "initial import" &lt;subfolder name&gt; vendor start"</li>
/// <li>Then remove the subfolder and then check it out from the namespace root with "cvs checkout &lt;subfolder name&gt;"</li>
/// <li>Set the subfolder as the export path when scheduling this task.</li>
/// <li>a batch file named cvsbat.bat must exist in the root of the namespace and contain these two lines:<br>cd %1<br>%~2</li>
/// </ul>
Class IIBAENSEMBLE.Task.SourceExportCVS Extends IIBAENSEMBLE.Task.SourceExport [ CompileAfter = IIBAENSEMBLE.Task.SourceExport ]
{

Parameter TaskName = "SourceExporttoCVS";

Property RepositoryType As %String [ InitialExpression = "CVS" ];

Property VersionsToKeep As %Integer [ InitialExpression = 0 ];

Method ExportFile(InternalName As %String) As %String
{
	set filename = ..ExternalName(InternalName,0)
	
	set NewFile = ##class(%File).Exists(filename)
	
	Set tSC=$system.OBJ.Export(InternalName,filename,"-d")
	
	s FileNameOnly = ##class(%File).GetFilename(filename)
	s FileDirectory = ##class(%File).GetDirectoryPiece(..ExportPath,##class(%File).GetDirectoryLength(..ExportPath))
	
	if $$$ISERR(tSC) Quit $$$ERROR($$$GeneralError,"Error occured in exporting file")
	
	set tSC = 0
	
	if 'NewFile	set tSC = $ZF(-1,"cvsbat.bat "_FileDirectory_" ""cvs add "_FileNameOnly_"""")
	
	if tSC = 1 Quit $$$ERROR($$$GeneralError,"Error occured in adding file")
 	
 	Quit 1
}

Method FinalCommit() As %Status
{
	set tSC = $ZF(-1,"cvs commit -m ""commit "_##class(Ens.Util.Time).FormatDateTime("%Y%m%d%H%M")_"""")
	
	if tSC = 1 Quit $$$ERROR($$$GeneralError,"Error occured in committing file")
	
	Quit $$$OK
}

}
