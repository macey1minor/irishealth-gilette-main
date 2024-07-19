Class IIBAENSEMBLE.Task.FileZip Extends %SYS.Task.Definition
{

Parameter TaskName = "ZipFiles";

/// This method is used to create compressed files and place them in an archive folder. pUseDateRange defaults to 0. If a specified date range is desired change to 1 and enter StartDate and EndDate. 
/// The default date range is for the current day.
/// pUseDateRange enter a 0 to use default (current day) or 1 to specify date range
Property UseDateRange As %Boolean [ InitialExpression = 0 ];

/// pStartDate = Zip2.32 will compress all files in tziplist after this date (mmddyyyy or yyyy-mm-dd)
Property StartDate As %String;

/// pEndDate = Zip2.32 will compress all files in tziplist prior to and including this date (mmddyyyy or yyyy-mm-dd)
Property EndDate As %String;

/// pArchiveDir = file path of the archive directory.
Property ArchiveDirectory As %String;

/// pFileName = file name of compressed records. Default is ZippedFile, pStartDate will be appended to filename
Property FileName As %String;

/// pFileType = type of files to be processed Ex: *.txt, *.csv. Default is all files (*).
Property FileType As %String;

/// pZiplist = file path of directory to be compressed.
Property ZipList As %String;

Method OnTask() As %Status
{
	#dim tSC As %Status = $$$OK
	
	s tSC = ##class(IIBAENSEMBLE.Utilities).ZipArchived(..UseDateRange,..StartDate,..EndDate,..ArchiveDirectory,..FileName,..FileType,..ZipList)
	
	Quit tSC
}

}
