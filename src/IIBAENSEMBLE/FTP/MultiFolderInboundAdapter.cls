Class IIBAENSEMBLE.FTP.MultiFolderInboundAdapter Extends EnsLib.FTP.InboundAdapter
{

Property DirListTable As %String;

Property MinRetryInterval As %Integer [ InitialExpression = 2 ];

Parameter SETTINGS = "DirListTable,MinRetryInterval";

Method OnTask() As %Status
{
#define ErrorFileTable(%filename) $$$EnsRuntimeAppData(..BusinessHost.%ConfigName,"adapter.ftp",%filename)
#define DoneFileTable(%filename) $$$EnsStaticAppData(..BusinessHost.%ConfigName,"adapter.ftp",%filename)
	Set $ZT="Trap", tSC=$$$OK, tOneFilename="", tFilename=""
	Do {
		
		#;Check for files in each directory in the list
		
		s DirRs=##class(%ResultSet).%New()
		s DirQry="select LeftId1 as Source, LeftId2 as Comment, RightId as Archive from IIBAENSEMBLE.LookupTable "
		S DirQry=DirQry_"Where LookupID='"_..DirListTable_"'"
		$$$TRACE("Directory Query: "_DirQry)
		d DirRs.Prepare(DirQry)
		s tSC=DirRs.Execute()
		If $$$ISERR(tSC) { $$$LOGERROR('..Connected) Quit }
		#; Change directories
				
				
		While (DirRs.Next()) {
			If DirRs.GetDataByName("Comment")="IgnoreThisRow" Continue
			s NextFilePath=DirRs.GetDataByName("Source")
			S NextFileArchive=DirRs.GetDataByName("Archive")
			//s tFilename=""
			S:""'=..ArchivePath NextFileArchive=..ArchivePath_"\"_NextFileArchive
			S NextFileArchive=##class(Ens.Util.File).NormalizeDirectory(NextFileArchive_"\")
			$$$TRACE("Next directory: "_NextFilePath_", Archive: "_NextFileArchive)
		
			//If ""=..%NextLine && '..FileListStream.Size {
				Set tSC=..Connect(..ConnectTimeout,1)
				If $$$ISERR(tSC) { $$$ASSERT('..Connected) Quit }
				Else { $$$ASSERT(..Connected)
			
				
				
					
					$$$TRACE("Checking ftp directory "_NextFilePath_". Archive directory is: "_NextFileArchive)
					Set NextFilePath=..fixSvrPath(..FilePath_"\"_NextFilePath,0)
					$$$TRACE("Looking at folder: "_NextFilePath)
					if ..FTP.SetDirectory(NextFilePath) {
						$$$catTRACE("connwait","Set FTP working directory to "_NextFilePath)
					} else {
						set tSC=$$$ERROR($$$EnsErrFTPDirectoryChangeFailed,NextFilePath,..FTP.ReturnMessage,..FTP.ReturnCode)
						Quit
					}
				
					#; get file list
					Set tSC = $S(..FTP.List(..FileSpec,..FileListStream):$$$OK,
								 ..FTP.ReturnMessage["file not found":$$$OK, ; VMS
								 ..FTP.ReturnMessage["cannot find the file":$$$OK, ; IIS non-wildcard spec
								 1:$$$ERROR($$$EnsErrFTPListFailed,..FileSpec,..FTP.ReturnMessage,..FTP.ReturnCode))
					Quit:$$$ISERR(tSC)
					$$$catTRACE("connwait","got FileListStream("_..FileListStream.Size_")")
					Kill ^||Ens.FileInbound.Found
				  
				}
			//}
			For {
				If $L(..%NextLine) {
					Set tLine=..%NextLine, tLen=$L(..%NextLine), ..%NextLine=""
				} Else {
					Kill tLen  Set tLine=..FileListStream.ReadLine(.tLen)
				}
				If tLen=-1 {
					#; Done with this FileList now
					Do ..FileListStream.Clear()
					Do:'..StayConnected ..Disconnect(1)
					#; Remove errored files from the Error global if they no longer exist, and remove processed files from the Done global if they no longer exist
					Set f="" For  Set f=$O($$$DoneFileTable(f)) Quit:f=""   If '$G(^||Ens.FileInbound.Found(f)) $$$sysTRACE("Removed absent file '"_f_"' from processed list")  Kill $$$DoneFileTable(f)
					Set f="" For  Set f=$O($$$ErrorFileTable(f)) Quit:f=""  If '$G(^||Ens.FileInbound.Found(f)) If ""'=$G($$$ErrorFileTable(f)) { $$$sysTRACE("Removed absent file '"_f_"' from errored list") } If $D($$$DoneFileTable(f)) { Set $$$ErrorFileTable(f)="" } Else { Kill $$$ErrorFileTable(f) }
					Quit
				}
				#; If VMS server, check lookahead buffer for possible multi-line directory listing
				If ($E(..%Syst,1,$L("VMS "))="VMS ") {
					#; A line starting with a space denotes continuation of the previous line in the listing
					For {
						Kill tLen1 Set ..%NextLine=..FileListStream.ReadLine(.tLen1)
						Quit:$E(..%NextLine)'=" "
						Set tLine=tLine_..%NextLine, tLen=tLen+tLen1, ..%NextLine=""
					}				
			 		$$$sysTRACE("got full VMS List() line '"_tLine_"' and NextLine buffer = '"_..%NextLine_"'")
				}
				Continue:tLen<40||("VMS "=$E(..%Syst,1,$L("VMS "))&&("Directory "=$E(tLine,1,$L("Directory "))))
				Set tOneFilename=tLine, tStyle = $ZSTRIP($ZCVT(..ServerListStyle,"L"),"*W","-_,;:/")
				Set tOK=..ParseFilename(.tOneFilename,.tModified,.tSize)
				If 'tOK {
					If tStyle="as400" && ("*MEM"=$ZCVT(tSize,"U")) && ("*FILE"=$E(..%PrevMod,*+1-$L("*FILE"),*)) {
						Set tOneFilename=$P(tModified,tSize_"_",2), tSize=..%PrevSize, tModified=$Replace(..%PrevMod,"*FILE","*MEM"), ..%LastErr=$$$OK
						Continue:..%PrevFile_"."_..%PrevFile=tOneFilename ; if the member is the same as the file, then we already tried to get it
					} Else {
						Continue
					}
				} ElseIf tStyle="as400" {
					If $$$ISERR(..%LastErr) Set tSC=..%LastErr, ..%LastErr=$$$OK, ..%NextLine=tLine, ..BusinessHost.%WaitForNextCallInterval=0  Quit
					Set ..%PrevFile=tOneFilename, ..%PrevSize=tSize, ..%PrevMod=$ZCVT(tModified,"U")
				}
				Set ^||Ens.FileInbound.Found(tOneFilename)=1

				Lock +$$$ErrorFileTable(tOneFilename):0 Else  $$$LOGINFO("Skipping locked file '"_tOneFilename_"'") Continue
				#; Skip the files we have already processed except if they are modified
				If $G($$$DoneFileTable(tOneFilename))=tModified If '$G(^(tOneFilename,"done"_$E($G($$$ErrorFileTable(tOneFilename)),-1))) { Set ^("done")=1 $$$LOGINFO("Skipping previously processed file '"_tOneFilename_"'") } Lock -$$$ErrorFileTable(tOneFilename) Continue
				If $G($$$ErrorFileTable(tOneFilename))=tModified If $G(^(tOneFilename,"wrn")) { Kill ^("wrn") $$$LOGWARNING("Skipping previously errored file '"_tOneFilename_"'") } Lock -$$$ErrorFileTable(tOneFilename) Continue
				If ..VMSLatestVersionOnly && ("VMS "=$E(..%Syst,1,$L("VMS "))) && ('..IsVMSLatestVersion(.tOneFilename)) {
					If '..DeleteFromServer {
						If '$G(^(tOneFilename,"ver"_$E($G($$$ErrorFileTable(tOneFilename)),-1))) { set ^("ver")=1 $$$sysTRACE("Skipping not-latest version of file '"_tOneFilename_"'") } 
					} Else {
						If '..FTP.Delete(tOneFilename) {
							If '$G(^(tOneFilename,"ver"_$E($G($$$ErrorFileTable(tOneFilename)),-1))) { set ^("ver")=1 $$$LOGWARNING("Failed to delete not-latest version of file '"_tOneFilename_"' - "_..FTP.ReturnCode_":"_..FTP.ReturnMessage) }
						} Else {
							$$$LOGINFO("Deleted non-latest version of file "_tOneFilename)
							Kill $$$ErrorFileTable(tOneFilename)					
						}
					}
					Lock -$$$ErrorFileTable(tOneFilename) Continue
				}
				Set $$$ErrorFileTable(tOneFilename)=tModified, ^(tOneFilename,"wrn")=1
				Lock -$$$ErrorFileTable(tOneFilename)

				Set tFilename=tOneFilename, tOneFilename=""  $$$sysTRACE("About to process file '"_tFilename_"' (size '"_tSize_"') with ConfirmComplete="_..ConfirmComplete)
				Quit ; found a good one
			}
			//If tFilename="" Quit
			If tFilename="" Continue
		
		
			#; now process this file
			//Set tSaveAsFile=(""'=..ArchivePath||..BusinessHost.ArchiveIO)
			$$$TRACE("Processing file: "_tFilename_", in folder: "_NextFilePath)
			$$$TRACE("Archive is: "_..getArchiveFilename(tFilename,NextFileArchive))
			Set tSaveAsFile=(""'=NextFileArchive||..BusinessHost.ArchiveIO)
			If "binary"=$ZCVT(..Charset,"L") {
				If tSaveAsFile {
					Set tStream=##class(%FileBinaryStream).%New() $$$ASSERT($IsObject(tStream))
					Set:""'=NextFileArchive tStream.Filename=..getArchiveFilename(tFilename,NextFileArchive)
				
				} Else {
					Set tStream=##class(%GlobalBinaryStream).%New() $$$ASSERT($IsObject(tStream))
				}
			} Else {
				If tSaveAsFile {
					Set tStream=##class(%FileCharacterStream).%New() $$$ASSERT($IsObject(tStream))
					Set:""'=NextFileArchive tStream.Filename=..getArchiveFilename(tFilename,NextFileArchive)
				} Else {
					Set tStream=##class(%GlobalCharacterStream).%New() $$$ASSERT($IsObject(tStream))
				}
			}
			#; Get the file
			$$$TRACE("Get the file")
			Set tNewSize=tSize, tFirst=1, tDone=0, tEverSize=0, tSizeTargTime=""
			For { ; loop getting chunks
				$$$TRACE("start of for - loop getting chunks")
				Set:..ConfirmComplete&&(""=tSizeTargTime) tSizeTargTime = $ZH+..FileAccessTimeout
				If tFirst {
					Set tFirst =0
					$$$TRACE("if tFirst: "_tFilename_", "_NextFilePath)
					
					If '..retrieveFile(tFilename,tStream,NextFilePath,1) {
					
						$$$TRACE("After Get File and first retrieve")
						Set tSC=$$$ERROR($$$EnsErrFTPGetFailed,tFilename,..FTP.ReturnMessage,..FTP.ReturnCode)
						#; If it was an AS/400 *FILE, quit OK but save the error - we will only return it later if no *MEM members are found.
						#; Don't count it as a file error if it was a network error
						Set:tStyle="as400"&&("*FILE"=$E(tModified,*+1-$L("*FILE"),*))&&..FTP.Connected ..%LastErr=tSC, tSC=$$$OK, ..BusinessHost.%WaitForNextCallInterval=0
						Quit
					}
				} ElseIf tNewSize>tSize {
					If '..retrieveFile(tFilename,tStream,NextFilePath,1) {
						$$$TRACE("After Get File and retryretrieve")
						Set tSC=$$$ERROR($$$EnsErrFTPGetFailed,tFilename_"+"_tStream.Size,..FTP.ReturnMessage,..FTP.ReturnCode)
						Quit
					}
				}
				$$$TRACE("Get Size: "_tFilename_", "_NextFileArchive)
				Set tNewFilename=tFilename, tNewSize=$S(+tSize'=tSize||'(..ConfirmComplete#2):tSize,1:..getSize(tFilename,NextFilePath))
				If +tSize'=tSize && (..ConfirmComplete#2) {
					Set tSC=$$$ERROR($$$EnsErrGeneral,"Unable to verify ConfirmComplete=Size size because initial SizeExpression result = '"_tSize_"'")
					Quit
				} ElseIf tNewSize>tSize {
					Set tNow=$ZH
					$$$sysTRACE("Got partial "_tFilename_"("_tStream.Size_") that was listed as size "_tSize_" and now shows "_tNewSize)
				} ElseIf tNewSize<tSize && (tNewSize'="") {
					#; Assume we got the old file and this is a new copy of the file we should process later
					$$$sysTRACE("Accepting "_tFilename_"("_tStream.Size_") that was listed as size "_tSize_" and now shows "_tNewSize)
					Set tDone=1
					Quit
				} Else {
					#; Size is empty or same - if ConfirmComplete keep trying for a new size until ..MinRetryInterval
					Set tNow=$ZH
					If ..ConfirmComplete#2 {
 						If 'tEverSize {
	 						If tNewSize'="" {
		 						Set tEverSize=1
								$$$sysTRACE("Got same size "_tSize_" for "_tFilename_" with ConfirmComplete=Size; waiting for new size or MinRetryInterval("_..MinRetryInterval_")")
 							} Else {
								$$$sysTRACE("Unable to obtain ConfirmComplete=Size ; waiting for new size or MinRetryInterval("_..MinRetryInterval_")")
	 						}
 						}
					}
					If '(..ConfirmComplete#2) || (tNow>=tSizeTargTime) || (tNewSize=tSize) {
 						If ..ConfirmComplete#2 && (tNewSize="") && (tNow>=tSizeTargTime) {
							Set tSC=$$$ERROR($$$EnsErrGeneral,"Could not get "_$S(tEverSize:"",1:"any ")_"size for "_tFilename_" ConfirmComplete=Size verification within MinRetryInterval("_..MinRetryInterval_")")
							Quit
	 					}
						If '(..ConfirmComplete\2#2) {
							#; not trying rename
							Set tDone=1
							Quit
						} Else {
							#; try rename
							$$$TRACE("Try rename")
							Set tPartLen=$L($E($P(tFilename,"."),1,12))  Set:tPartLen<8 tPartLen=8
							Set tNewFilename=$E($TR("X"_$ZH_"000000","."),1,tPartLen)_"."_$P(tFilename,".",2,999)
							$$$TRACE("Trying to rename "_tFilename_" to "_tNewFilename)
							If ..FTP.Rename(tFilename,tNewFilename,NextFilePath) {
								$$$sysTRACE("Confirmed complete "_tFilename_" via rename to "_tNewFilename_"; renaming back again")
								Set:..FTP.Rename(tNewFilename,tFilename,NextFilePath) tNewFilename=tFilename
								Set tDone=1
								Quit
							} Else {
								If tNow>=tSizeTargTime {
									Set tSC=$$$ERROR($$$EnsErrGeneral,"Failed to confirm complete "_tFilename_"("_tStream.Size_") listed as size "_tSize_" by renaming to "_tNewFilename_" within MinRetryInterval("_..MinRetryInterval_") : FTP code "_..FTP.ReturnCode_" - "_..FTP.ReturnMessage)
									Quit
								} Else {
									$$$sysTRACE("Got "_tFilename_"("_tStream.Size_") but can't rename it yet : FTP code "_..FTP.ReturnCode_" - "_..FTP.ReturnMessage_"; trying for more data")
								}
							}
						}
					}
				}
				#; don't retry more often than every ..MinRetryInterval seconds
				Set tWaitTime=tSizeTargTime-tNow  Set:tWaitTime<0 tWaitTime=0
				Set tSC1=##class(Ens.Queue).DeQueue("SystemSignal:"_$Job,,tWaitTime,,0)  Quit:$$$ISERR(tSC1)
				If ##class(Ens.Job).ShouldBeQuiescent() || ##class(Ens.Job).ShouldTerminate() {
					$$$LOGWARNING("Abandoning partial download of "_tFilename_" because of shutdown request")
					Quit
				}
				Set tWaitTime=tSizeTargTime-$ZH  Hang:tWaitTime>0 tWaitTime ; finish the delay in case DeQueue() returned early
				Set:tNewSize>tSize tSizeTargTime="" ; restart the clock
				Set:""'=tNewSize tSize=tNewSize ; re-base the size
			}
			If tDone {
				Set tTxt="Retrieved file '"_tFilename_"' of size "_tStream.Size_$S(tSaveAsFile:", archived as file '"_tStream.Filename_"'",1:"")
				If ..%logTransfers { $$$LOGINFO(tTxt) } Else { $$$sysTRACE(tTxt) }
				Set tStream.Attributes("Filename")=tFilename
				If tSaveAsFile { Set tSC1=tStream.SaveStream() If $$$ISERR(tSC1) $$$LOGERROR("Failed to save retrieved file '"_tFilename_"' of size "_tStream.Size_" to archive file '"_tStream.Filename_"'; Status: "_$$$StatusDisplayString(tSC1)) }
				Set tSC = ..BusinessHost.ProcessInput(tStream) Quit:$$$ISERR(tSC)
				Kill tStream
				If ..DeleteFromServer {
					#; delete the file, and remove the file from do-not-process list if it is deleted
					If ..delete(tNewFilename,NextFilePath) {
						$$$sysTRACE("Deleted "_tFilename_$S(tFilename=tNewFilename:"",1:" / "_tNewFilename)_" from FTP server after successful processing")
						If ..VMSLatestVersionOnly { Set $$$ErrorFileTable(tFilename)="" } Else { Kill $$$ErrorFileTable(tFilename) }
					} Else {
						$$$LOGWARNING("failed to delete '"_tFilename_"' - "_..FTP.ReturnCode_":"_..FTP.ReturnMessage)
					}
				} Else {
					$$$sysTRACE("Not Deleting "_tFilename_$S(tFilename=tNewFilename:"",1:" / "_tNewFilename)_" from FTP server after successful processing")
				}
				#; mark the file as done if not deleted, whether or not we tried
				Kill $$$ErrorFileTable(tFilename)
				Set $$$DoneFileTable(tFilename)=tModified
			}
			#; End of While dir list
			#;    Only process one file in each iteration
			Quit
		
		} 
	} While 0
Exit
	If $$$ISERR(tSC) {
		Set tErrText=$$$StatusText(tSC)
		Set tNetErr=('$IsObject(..FTP)||'..FTP.Connected||(tErrText["<READ>")||(tErrText["<WRITE>")||(tErrText["<NOTOPEN>")||(tErrText["=425")||(tErrText["=529"))
		Do:tNetErr&&..Connected ..Disconnect(1)
		#; Don't count it as a file error if it was a network error or retryable
		If ""'=tFilename && (tNetErr || $$$StatusEquals(tSC,$$$EnsErrOutConnectExpired,$$$EnsErrOutConnectFailed)
		 					|| ($$$StatusDisplayString(tSC)["<Ens>ErrFTP" && (tErrText?.E1"="1(1"52"1N,1"4"2N)1PC.E))) { ; retry on timeouts also
			Kill $$$ErrorFileTable(tFilename)
		}
	}
	Quit tSC
Trap
 	Set $ZT="",tSC=$$$EnsSystemError
	Lock:""'=tOneFilename -$$$ErrorFileTable(tOneFilename)
	Goto Exit
}

Method getArchiveFilename(pFTPFilename As %String, pArchivePath As %String) As %String [ CodeMode = expression, Internal ]
{
##class(Ens.Util.File).CreateTimestamp(##class(%File).GetFilename(pFTPFilename),$Case(..AppendTimestamp,"":"%f",0:"%f",1:"%f_%Q",:..AppendTimestamp),,##class(Ens.Util.File).NormalizeDirectory(pArchivePath))
}

}
