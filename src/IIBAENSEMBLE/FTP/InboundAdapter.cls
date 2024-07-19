/// Copyright 2007 by Inland Imaging Business Associates
Class IIBAENSEMBLE.FTP.InboundAdapter Extends EnsLib.FTP.InboundAdapter [ ProcedureBlock ]
{

Property FileModifyWaitTime As %Integer [ InitialExpression = 300 ];

Property MinRetryInterval As %Integer [ InitialExpression = 2 ];

Parameter SETTINGS = "FileModifyWaitTime,MinRetryInterval";

Method OnTask() As %Status
{
#define ErrorFileTable(%filename) $$$EnsRuntimeAppData(..BusinessHost.%ConfigName,"adapter.ftp",%filename)
#define DoneFileTable(%filename) $$$EnsStaticAppData(..BusinessHost.%ConfigName,"adapter.ftp",%filename)
	Set $ZT="Trap", tSC=$$$OK, tOneFilename=""
	Do {
		If ""=..%NextLine && '..FileListStream.Size {
			Set tSC=..Connect(..ConnectTimeout,1)
			If $$$ISERR(tSC) { $$$ASSERT('..Connected) Quit }
			Else { $$$ASSERT(..Connected)
				#; get file list
				Set tSC = $S(..FTP.List(..FileSpec,..FileListStream):$$$OK,
							 ..FTP.ReturnMessage["file not found":$$$OK, ; VMS
							 ..FTP.ReturnMessage["cannot find the file":$$$OK, ; IIS non-wildcard spec
							 1:$$$ERROR($$$EnsErrFTPListFailed,..FileSpec,..FTP.ReturnMessage,..FTP.ReturnCode))
				Quit:$$$ISERR(tSC)
				$$$catTRACE("connwait","got FileListStream("_..FileListStream.Size_")")
				Kill ^||Ens.FileInbound.Found
			}
		}
		Set tFilename="" For {
			If $L(..%NextLine) {
				Set tOneFilename=..%NextLine, tLen=$L(..%NextLine), ..%NextLine=""
			} Else {
				Kill tLen  Set tOneFilename=..FileListStream.ReadLine(.tLen)
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
					Set tOneFilename=tOneFilename_..%NextLine, tLen=tLen+tLen1, ..%NextLine=""
				}				
		 		$$$sysTRACE("got full VMS List() line '"_tOneFilename_"' and NextLine buffer = '"_..%NextLine_"'")
			}
			Continue:tLen<40||("VMS "=$E(..%Syst,1,$L("VMS "))&&("Directory "=$E(tOneFilename,1,$L("Directory "))))
			Continue:'..ParseFilename(.tOneFilename,.tModified,.tSize)

			$$$TRACE("File: "_tOneFilename_" Modified: "_tModified)
			
			// skip if modified within the last 5 minutes
			s zbgdate=##class(IIBAENSEMBLE.Functions).date2digitexpr($TR($P(tModified,"_",1),"-","/"))
			s zbgtime=$P(tModified,"_",2)
			s zbgdh=$ZDTH(zbgdate_" "_zbgtime,1,3)
			s zbgh=$H
			s zbgModified=($P(zbgh,",",1)-$P(zbgdh,",",1))*86400+$P(zbgh,",",2)-$P(zbgdh,",",2)
			$$$TRACE(tOneFilename_" Modified "_zbgModified_" Seconds ago")
			
			if ( zbgModified > ..FileModifyWaitTime ) {
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

				Set tFilename=tOneFilename, tOneFilename=""  $$$sysTRACE("About to process file '"_tFilename_"'")
				Quit ; found a good one
			}
		}
		If tFilename="" Quit

		#; now process this file
		Set tSaveAsFile=(""'=..ArchivePath||..BusinessHost.ArchiveIO)
		If "binary"=$ZCVT(..Charset,"L") {
			If tSaveAsFile {
				Set tStream=##class(%FileBinaryStream).%New() $$$ASSERT($IsObject(tStream))
				Set:""'=..ArchivePath tStream.Filename=..getArchiveFilename(tFilename)
			} Else {
				Set tStream=##class(%GlobalBinaryStream).%New() $$$ASSERT($IsObject(tStream))
			}
		} Else {
			If tSaveAsFile {
				Set tStream=##class(%FileCharacterStream).%New() $$$ASSERT($IsObject(tStream))
				Set:""'=..ArchivePath tStream.Filename=..getArchiveFilename(tFilename)
			} Else {
				Set tStream=##class(%GlobalCharacterStream).%New() $$$ASSERT($IsObject(tStream))
			}
		}
		#; Get the file
		Set tDone=0, tFirst=1, tWarned=0
		For { ; loop getting chunks
			Set tStart=$ZH
			If tFirst {
				Set tFirst =0
				If '..FTP.Retrieve(tFilename,tStream) {
					Set tSC=$$$ERROR($$$EnsErrFTPGetFailed,tFilename,..FTP.ReturnMessage,..FTP.ReturnCode)
					Quit
				}
			} Else {
				If '..FTP.RetryRetrieve(tFilename,tStream) {
					Set tSC=$$$ERROR($$$EnsErrFTPGetFailed,tFilename_"+"_tStream.Size,..FTP.ReturnMessage,..FTP.ReturnCode)
					Quit
				}
			}
			Set tNewFilename=tFilename, tNewSize=$S(+tSize'=tSize||'(..ConfirmComplete#2):tSize,1:..getSize(tFilename))
			If +tSize'=tSize && (..ConfirmComplete#2) { $$$LOGWARNING("Unable to verify ConfirmComplete=1 size because initial SizeExpression result = '"_tSize_"'") }
			If tNewSize=tSize {
				Set tPartLen=$L($E($P(tFilename,"."),1,12))  Set:tPartLen<8 tPartLen=8
				If ..ConfirmComplete\2#2 {
					Set tNewFilename=$E($TR("X"_$ZH_"000000","."),1,tPartLen)_"."_$P(tFilename,".",2,999)
					If ..FTP.Rename(tFilename,tNewFilename) {
						$$$sysTRACE("Confirmed complete "_tFilename_" via rename to "_tNewFilename_"; renaming back again")
						Set:..FTP.Rename(tNewFilename,tFilename) tNewFilename=tFilename
						Set tDone=1
					} Else {
						If +tSize'=tSize {
							$$$sysTRACE("Got "_tFilename_"("_tStream.Size_") but can't rename it yet; trying for more data")
						} Else {
							$$$LOGWARNING("Failed to confirm complete "_tFilename_"("_tStream.Size_") listed as size "_tSize_" by renaming to "_tNewFilename_": FTP code "_..FTP.ReturnCode_" - "_..FTP.ReturnMessage)
							Set tWarned=1
						}
					}
				} Else {
					Set tDone=1
				}
			} ElseIf tNewSize<tSize {
				#; Assume we got the old file and this is a new copy of the file we should process later
				$$$sysTRACE("Accepting "_tFilename_"("_tStream.Size_") that was listed as size "_tSize_" and now shows "_tNewSize)
				Set tDone=1
			} Else {
				$$$sysTRACE("Got partial "_tFilename_"("_tStream.Size_") that was listed as size "_tSize_" and now shows "_tNewSize)
			}
			If tDone {
				Set tTxt="Retrieved file '"_tFilename_"' of size "_tStream.Size_$S(tSaveAsFile:", archived as file '"_tStream.Filename_"'",1:"")
				If ..%logTransfers||tWarned { $$$LOGINFO(tTxt) } Else { $$$sysTRACE(tTxt) }
				Set tStream.Attributes("Filename")=tFilename
				If tSaveAsFile { Set tSC1=tStream.SaveStream() If $$$ISERR(tSC1) $$$LOGERROR("Failed to save retrieved file '"_tFilename_"' of size "_tStream.Size_" to archive file '"_tStream.Filename_"'; Status: "_$$$StatusDisplayString(tSC1)) }
				Set tSC = ..BusinessHost.ProcessInput(tStream) Quit:$$$ISERR(tSC)
				Kill tStream
				If ..DeleteFromServer {
					#; delete the file, and remove the file from do-not-process list if it is deleted
					If ..FTP.Delete(tNewFilename) {
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
				Quit
			}
			#; don't retry more often than every ..#MinRetryInterval seconds
			Set tWaitTime=tStart+..MinRetryInterval-$ZH  Set:tWaitTime<0 tWaitTime=0
			Set tSC1=##class(Ens.Queue).DeQueue("SystemSignal:"_$Job,,tWaitTime,,0)  Quit:$$$ISERR(tSC1)
			If ##class(Ens.Job).ShouldBeQuiescent() || ##class(Ens.Job).ShouldTerminate() {
				$$$LOGWARNING("Abandoning partial download of "_tFilename_" because of shutdown request")
				Quit
			}
			Set tWaitTime=tStart+..MinRetryInterval-$ZH  Hang:tWaitTime>0 tWaitTime
			Set tSize=tNewSize
		}
		#; Don't count it as a file error if it was a network error
		Kill:$$$ISERR(tSC)&&'..FTP.Connected&&(""'=tFilename) $$$ErrorFileTable(tFilename)
	} while (0)
Exit

	Quit tSC
Trap
 	Set $ZT="",tSC=$$$EnsSystemError
	Lock:""'=tOneFilename -$$$ErrorFileTable(tOneFilename)
	Goto Exit
}

}
