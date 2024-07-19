Class IIBAENSEMBLE.Task.FolderPurge Extends %SYS.Task.Definition
{

Parameter TaskName = "FolderPurge";

Method OnTask() As %Status
{
		
	Set FolderName="",PurgeDays="",ItemValue="",tSC=$$$OK
	
	&sql(DECLARE C1 CURSOR FOR 
		 SELECT ItemName,ItemValue INTO :FolderName,:ItemValue
		 FROM IIBAENSEMBLE_Task.TaskItemDefinition 
		 WHERE NameSpace = 'All' AND ItemType='FolderPurge')
	&sql(OPEN C1)
		For { &sql(FETCH C1)  Quit:SQLCODE'=0 
			//W !,FolderName,", ",ItemValue,!
			s FileSpec=$P(ItemValue,"^",1)
			s PurgeDays=$P(ItemValue,"^",2)+0
			If ((FileSpec="") || (FolderName="") || (PurgeDays<1)) Continue
			// Clean out Archive files older than 'PurgeDays' days
			
			Set MgrDir=##class(%File).ManagerDirectory(),FolderIsMgr=""
			s MgrDirRoot=##class(%File).GetDirectoryPiece(MgrDir,1)
			For {
				s:##class(%File).NormalizeDirectory(MgrDir)=##class(%File).NormalizeDirectory(FolderName) FolderIsMgr=1
				s MgrDir=##class(%File).ParentDirectoryName(MgrDir)
				Q:MgrDir=""||(MgrDir=##class(%File).ParentDirectoryName(MgrDir))
			}
			Continue:FolderIsMgr||'##class(%File).DirectoryExists(FolderName)
			
			W !,"Purge files from '",FolderName,"' Folder",!
			
			Set rset = ##class(%ResultSet).%New()
			set rset.ClassName = "%File"
			set rset.QueryName = "FileSet"
			Do rset.Execute(FolderName,FileSpec)
			Set FileDelete = 1
			While (rset.Next()) {
				
				if ($ZB(##class(%File).Attributes(rset.Data("Name")),16,1)=0) {
					// only delete files - skip directories
					If $PIECE($HOROLOG,",") - $PIECE($ZDATETIMEH(rset.Data("DateModified"),3,1),",") > PurgeDays {
						w rset.Data("Name"),!
						s FileDelete=""
						Set FileDelete = ##class(%File).Delete(rset.Data("Name"))
						If FileDelete = 0 {
							//W "File delete Failed: "_rset.Data("Name")
							s tSC=0
						}
					}
				}
			}
		
		}
	&sql(CLOSE C1)
	
	Q $$$OK
}

}
