/// 
Class IIBAENSEMBLE.File.InboundAdapter Extends EnsLib.File.InboundAdapter [ ProcedureBlock ]
{

Property FileModifyWaitTime As %Integer [ InitialExpression = 300 ];

Parameter SETTINGS = "FileModifyWaitTime";

Method OnTask() As %Status
{
#define FileTable(%filename) $$$EnsRuntimeAppData(..BusinessHost.%ConfigName,"adapter.file",%filename)

	Set $ZT="Trap",tSC=$$$OK,tFilename="" 
	do {
		Quit:(""=..FilePath)||(""=..FileSpec)
		If '$D(..%CurrResultSet.Data) {
			#; get file list
			$$$catTRACE("connwait","Looking for files '"_..FileSpec_"' in path '"_..FilePath_"'")
			Set tSC=..%CurrResultSet.Execute(..FilePath,..FileSpec,"DateModified",0)  Quit:$$$ISERR(tSC)
			Kill ^||Ens.FileInbound.Found
		}
		#; find the next one that can be processed
		While 1 {
			If 0=..%CurrResultSet.Next() {
				#; Done iterating the ResultSet for the current query execution - clean it up
				Do ..%CurrResultSet.Close()
				Kill ..%CurrResultSet.Data ; clean it out so next loop iteration will re-Execute the query
				#; Remove errored files from global if they no longer exist
				Set f="" For  Set f=$Order($$$FileTable(f)) Quit:f=""  if '$Get(^||Ens.FileInbound.Found(f),0) Kill $$$FileTable(f) $$$sysTRACE("Removed absent file '"_f_"' from errored list")
				Quit
			}
			Continue:"D"=..%CurrResultSet.Data("Type") ; skip directories
			Set tOneFilename = ..%CurrResultSet.Data("Name"), tModified = ..%CurrResultSet.Data("DateModified")  $$$ASSERT(""'=tOneFilename)
			
			/// Skip if modified within last ??? minutes
			s zbgdate=##class(IIBAENSEMBLE.Functions).date2digitexpr($TR($P(tModified,"_",1),"-","/"))
			s zbgtime=$P(tModified,"_",2)
			s zbgdh=$ZDTH(zbgdate_" "_zbgtime,1,3)
			s zbgh=$H
			s zbgModified=($P(zbgh,",",1)-$P(zbgdh,",",1))*86400+$P(zbgh,",",2)-$P(zbgdh,",",2)
			$$$TRACE(tOneFilename_" Modified "_zbgModified_" Seconds ago")
			
			if ( zbgModified > ..FileModifyWaitTime ) {
				Set ^||Ens.FileInbound.Found(tOneFilename)=1
				if ""=tFilename {
					Lock +$$$FileTable(tOneFilename):0 Else  $$$LOGINFO("Skipping locked file '"_tOneFilename_"'") Continue
					If $get($$$FileTable(tOneFilename))=tModified if $get(^(tOneFilename,"wrn")) { Kill ^("wrn") $$$LOGWARNING("Skipping previously errored file '"_tOneFilename_"' with timestamp '"_tModified_"'") } Lock -$$$FileTable(tOneFilename) Continue
					Set $$$FileTable(tOneFilename) = tModified, ^(tOneFilename,"wrn") = 1
					Set tFilename=tOneFilename
					Quit ; found a good one
				}
			}
		}
		If tFilename="" Quit
		
		
		
 		$$$LOGINFO("Processing file '"_tFilename_"' with timestamp '"_tModified_"'")
	
		Set tTimeoutStart = $ZH, tTimeElapsed=0
		if (""'=..WorkPath)&&(..WorkPath'=..FilePath) {
			// Rename file with date etc. (loop waiting for it to become accessible)
			Set tWorkFilename = ..getWorkFilename(tFilename)
			Do {
				Set tOK = ##class(%File).Rename(tFilename,tWorkFilename)
				if 'tOK Hang 0.1  Set tTimeElapsed = $ZH - tTimeoutStart
			} while 'tOK && (tTimeElapsed < ..FileAccessTimeout)
			If 'tOK {
				$$$LOGERROR("Could not move '"_tFilename_"' to '"_tWorkFilename_"' within "_..FileAccessTimeout_" seconds")
				Quit
			}
			#; Release the file right away now that we've moved it
			Kill $$$FileTable(tFilename)
			Lock -$$$FileTable(tFilename)
			Set tFilename=""
		}
		else {
			// Open the file (loop waiting for it to become accessible)
			Set tWorkFilename = tFilename
			Do {
				Set tF = ##class(%File).%New(tWorkFilename) $$$ASSERT($IsObject(tF))
				Set tSC = tF.Open("R")
				if $$$ISERR(tSC) Hang 0.1  Set tTimeElapsed = $ZH - tTimeoutStart
			} while $$$ISERR(tSC) && (tTimeElapsed < ..FileAccessTimeout)
			If $$$ISERR(tSC) $$$LOGERROR("Could not open '"_tWorkFilename_"' within "_..FileAccessTimeout_" seconds") Set tSC = $$$OK Quit
			Kill tF ; We were just testing...
		}
		Set tSC=..processFile(tWorkFilename)  Quit:$$$ISERR(tSC)
		
		#; archive or delete the file, and remove the file from do-not-process list if successful
		Set tOK=1
		If ##class(%File).Exists(tWorkFilename) {
			if ""'=..ArchivePath {
				Set tArchiveFilename = ..getArchiveFilename(tWorkFilename,tFilename)
				if tWorkFilename '= tArchiveFilename {
					Set tOK = ##class(%File).Rename(tWorkFilename,tArchiveFilename)
					if 'tOK $$$LOGERROR("Failed to move '"_tWorkFilename_"' to Archive file '"_tArchiveFilename_"'")
					else  $$$sysTRACE("Moved '"_tWorkFilename_"' to Archive file '"_tArchiveFilename_"'")
				}
				Set:tFilename=tArchiveFilename tOK=0
			} else {
				Set tOK = ##Class(%File).Delete(tWorkFilename)
				if 'tOK $$$LOGERROR("Failed to delete '"_tWorkFilename_"'")
			}
		}
		Kill:""'=tFilename&&tOK $$$FileTable(tFilename)
	} while (0)
Exit
	Lock:""'=tFilename -$$$FileTable(tFilename)
	Quit tSC
Trap
 	Set $ZT="",tSC=$$$EnsSystemError
	Goto Exit
}

}
