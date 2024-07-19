Include EnsHL7

/// Copyright 2008 by Inland Imaging Business Associates
Class IIBAENSEMBLE.csp.MessageEdit Extends %CSP.Page [ ProcedureBlock ]
{

/*
Message Edit CSP Page

bsg - 5/2/2008 -  Initial development, display the message, prompt by field.
      6/10/2008 - Edit Message Body
      7/17/2008 - Add send, highlight changes, IIBAMsgEdit role/resource
      7/20/1008 - Added trace button

Still to be done
- Add onClick action to original message that will compare old to new...


*/
ClassMethod CheckPermissions()
{
	set Allowed = 0
	set:##class(%SYSTEM.Security).Check("IIBAMsgEdit","USE") Allowed=1
	
	Quit Allowed
}

ClassMethod jsfunction()
{
	&html<
	
	<script type="text/javascript" src="modalbox/modalbox.js"></script>
	<link rel="stylesheet" href="modalbox/modalbox.css" type="text/css" />
	>
  &html<
   <script language=javascript>
	<!--
	
	window.onbeforeunload = confirmExit;
	
	function confirmExit() {
		
		if ( document.getElementById("messageSent").value != 'True') {
			return 'This new message was not sent. \nYou will lose your changes if you navigate away from this window.'
		} 
		 
	}
	
	function Initialize()
	{
		
		document.title='Message Edit';
	}
	
	function getNewValue(event,field,orignalValue,fieldTitle,msgObjId)
	{
		document.title='Message Edit';
		
		sm('modalNewValue',300,100,event.clientY + document.body.scrollTop,event.clientX + document.body.scrollLeft)
		
		var tags
		tags = document.getElementsByTagName('div');
		for (var i = 0; i < tags.length; i++) {
			if (tags[i].id == 'newValueFieldName') {
				tags[i].innerHTML = field;
			}
		}

		tags = document.getElementsByTagName('input');
		for (var i = 0; i < tags.length; i++) {
			if (tags[i].id == 'newValueField') {
				tags[i].value = orignalValue;
				
			}
		}
		tags = document.getElementsByTagName('input');
		for (var i = 0; i < tags.length; i++) {
			if (tags[i].id == 'newValueFieldId') {
				tags[i].value = field;
				
			}
		}
		tags = document.getElementsByTagName('input');
		for (var i = 0; i < tags.length; i++) {
			if (tags[i].id == 'newValueFieldTitle') {
				tags[i].value = fieldTitle;
				
			}
		}
		tags = document.getElementsByTagName('input');
		for (var i = 0; i < tags.length; i++) {
			if (tags[i].id == 'newValuemsgObjId') {
				tags[i].value = msgObjId;
				
			}
		}
	}
	function newValueSave()
	{
		var newValue = $('newValueField').value;
		var field = $('newValueFieldId').value;
		var fieldTitle = $('newValueFieldTitle').value;
		var msgObjId = $('newValuemsgObjId').value;
		
		if (newValue == "" ) {
			var displayValue="&nbsp;&middot;";
		} else {
			var displayValue=newValue.replace(/\s/g,"&nbsp;");
		}
		
		document.getElementById(field).innerHTML='<a title="'+fieldTitle+'" style="color:red; background-Color:yellow; cursor: pointer;"  onclick=\'getNewValue(event,"'+field+'","'+newValue+'","'+fieldTitle+'","'+msgObjId+'")\'>'+displayValue+'</a>';
		var rv=#server(..FieldUpdate(msgObjId,newValue,field))#;
		document.getElementById("messageSent").value='False';

	}

	
	function sendNewMsg(origMsgHeader,newMsgBodyId) {
		
		var selectObj=document.getElementById("newTarget");
		var newTarget=selectObj.options[selectObj.selectedIndex].text;
		//alert(origMsgHeader+", "+newMsgBodyId+", "+newTarget);
			
		var x=#server(..SendMessage(origMsgHeader,newMsgBodyId,newTarget))#;
		
		//alert('New Message Header Id: '+x);
		alert('Message id '+newMsgBodyId+' sent to '+newTarget);
		document.getElementById("messageSent").value='True';
		
	}


  -->
   </script>
  >
}

ClassMethod html()
{

	if ( '##class(%SYSTEM.Security).Check("IIBAMsgEdit","USE")) {
		W "<P><P><B>Access Denied !!!</B>"
		Q
	}
	//// build hidden modal form for acquring new field values
 	w ..buildmodalNewValue()
 	
 	
 	
 	S MsgHeaderId=%request.Get("MsgHeaderID")
	s SessionId=%request.Get("SessionId")
	s MessageSent="False"
	
	W "<BR><HR><FONT color=""Blue""><B>&nbsp;&nbsp;ORIGINAL MESSAGE</B></FONT><BR>"
	
	If (MsgHeaderId="") {
		W "<P><P><B>&nbsp;&nbsp;Message Edit - No Message found !!! </B><P>"
		Q
	} 
	
	S %session.Data("MessageEdits")="Message Edits (format: path{new value}): "
	
	S MsgHeaderObj=##class(Ens.MessageHeader).%OpenId(MsgHeaderId)
	S MsgBodyObj=##class(EnsLib.HL7.Message).%OpenId(MsgHeaderObj.MessageBodyId)
	
	S tSC=..MsgOutputHTML(MsgBodyObj,"Compare")
	
	
	s newMsgBodyObj=MsgBodyObj.%ConstructClone()
	d newMsgBodyObj.BuildMap(1)
	s hSC=newMsgBodyObj.%Save()
	s newMsgBodyId=newMsgBodyObj.%Id()
	

	w "<BR><HR>"
	
	//Send Button
	W "<Table cellSpacing='15'><TR>"
	W "<TD><FONT color=""Blue""><B>&nbsp;&nbsp;NEW MESSAGE. </B><I>( Select a field and update )</I></FONT></TD>"
	W "<TD>Target:&nbsp;<Select ID='newTarget'>"
	
	s rset=##Class(%ResultSet).%New()
	s rset.ClassName="Ens.Util.Statistics"
	s rset.QueryName="EnumerateHostStatus"
	D rset.Execute()
	
	while (rset.Next()) {
		if ( (rset.Data("Type")="BusinessProcess") || (rset.Data("Type")="BusinessOperation")) {
			w "<option Value='"_rset.Data("Name")_"'"
			if ( rset.Data("Name") = MsgHeaderObj.TargetConfigName ) W " selected='selected' "
			W " >"_rset.Data("Name")_"</option>"
		}
	}
	W "</TD>"
	W "<TD><input type='button' value='send' onclick='sendNewMsg("""_MsgHeaderId_""","""_newMsgBodyId_""")'>"
	W "</TD>"
	if (SessionId '= "" ) {
		//W "<TD>&nbsp;&nbsp;<A href='IIBAUtilEnsMsgTrace.csp?$ID1="_SessionId_"' target='_blank'>Trace</A></TD>"
		W "<TD>&nbsp;&nbsp;<A href='EnsPortal.VisualTrace.zen?$ZEN_POPUP=1&SESSIONID="_SessionId_"' target='_blank'>Trace</A></TD>"
	}
	W "</TR></Table>"
	S tSC=..MsgOutputHTML(newMsgBodyObj,"Edit")
	W "<BR><HR>"
	W "<Input type='hidden' id='messageSent' value='True' />"
	Q $$$OK
}

ClassMethod MsgOutputHTML(MsgBodyObj As EnsLib.HL7.Message, Action As %String = "") As %Status [ Language = objectscript ]
{
	
	
	s msgBodyObjId=MsgBodyObj.%Id()
	
    Set tSC=$$$OK
    &html<
    <table border="0" cellspacing="0" cellpadding="0" cols="2" width="100%"><tr><td align="center"><div class="Text" style="margin: 3px;">>
    If ""'=MsgBodyObj.DocType {
    	Do:""=MsgBodyObj.BuildMapStatus||'$D(MsgBodyObj.%maps("runtimePath")) MsgBodyObj.BuildMap()
    	Set tDesc=##class(EnsLib.HL7.Schema).GetDescription("MT:"_MsgBodyObj.MessageTypeCategory_":"_MsgBodyObj.Name)
    	Set:""=tDesc tDesc=##class(EnsLib.HL7.Schema).GetDescription("MS:"_MsgBodyObj.DocType)
        //&html<HL7 <b>#($ZCVT(MsgBodyObj.Name,"O","HTML"))#</b> Message - Id = <b>#(MsgBodyObj.%Id())#</b>, DocType = '<a#($S(""=tDesc:"",1:" title='"_$ZCVT(tDesc,"O","HTML")_"'")_MsgBodyObj.getLink(MsgBodyObj.DocType))#><b>#($ZCVT(MsgBodyObj.DocType,"O","HTML"))#</b></a>'
        &html<HL7 <b>#($ZCVT(MsgBodyObj.Name,"O","HTML"))#</b> Message - Id = <b>#(MsgBodyObj.%Id())#</b>, DocType = '<a#($S(""=tDesc:"",1:" title='"_$ZCVT(tDesc,"O","HTML")_"'"))#><b>#($ZCVT(MsgBodyObj.DocType,"O","HTML"))#</b></a>'
        	,MessageTypeCategory = '#($ZCVT(MsgBodyObj.MessageTypeCategory,"O","HTML"))#'
        	<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;#($S(""=tDesc:"", 1:"'<b><i>"_$ZCVT(tDesc,"O","HTML")_"</i></b>', "))#<b>#(MsgBodyObj.SegCount)#</b> Segments#(..linkParents(MsgBodyObj))#>
        
	    If $$$ISERR(MsgBodyObj.BuildMapStatus) {
        	Set tErr=$ZCVT($$GetOneErrorText^%apiOBJ(MsgBodyObj.BuildMapStatus),"O","HTML")
        	&html<<br>&nbsp;&nbsp;&nbsp;BuildMapStatus = '<b>#(tErr)#</b>'>
        	For i=2:1 { Set tErr=$$GetOneErrorText^%apiOBJ(MsgBodyObj.BuildMapStatus,i) Quit:""=tErr
        		&html<<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;'#($ZCVT(tErr,"O","HTML"))#'>
            }
        }
        
    } Else {
            &html<HL7 <b>#($ZCVT(MsgBodyObj.Name,"O","HTML"))#</b> Message - Id = <b>#(MsgBodyObj.%Id())#</b>, DocType = <b>''</b>, MessageTypeCategory = '#($ZCVT(MsgBodyObj.MessageTypeCategory,"O","HTML"))#', <b>#(HL7Msg.SegCount)#</b> Segments#(..linkParents(HL7Msg))#>
    }
    &html<</div></td></tr></table>>
    Do:'$D(MsgBodyObj.%maps("runtimeIndex"))&&$D(MsgBodyObj.%maps("runtimePath")) HL7Msg.buildRuntimeIndexFromPath()
    Set tCnt=$G(MsgBodyObj.%maps("runtimeIndex"))
    If tCnt<=0 { &html<<center>No Segments</center>> }
                
    Else {
    	&html<<table class="EDIDocumentTable" BORDER="0" CELLSPACING="0" CELLPADDING="0">>
        For i=1:1:tCnt {
        	If i>300&&(i<=(tCnt-100)) {
            	If i=301 { &html<<TR CLASS="EDIDocumentTableRow"><TD CLASS="EDIDocumentTableExpandor">&nbsp;</TD>>
                    		&html<<td class='EDIDocumentTableSegnum'>...&nbsp;</td><td class='EDIDocumentTableSegid' SegID='...'> </td>>
                        	&html<<td class='EDIDocumentTableSegname'>&nbsp;</td>>
                        	&html<<td>Segments 301 to #(tCnt-100)# not shown ...</td></TR>> 
                }
                Continue
            }
            Set tPath=$G(MsgBodyObj.%maps("bidirectionalLink",i),i)
            Set seg=MsgBodyObj.getSegmentByIndex(i)
            &html<<TR CLASS="EDIDocumentTableRow"><TD CLASS="EDIDocumentTableExpandor">&nbsp;</TD>>
            //Set tSC=seg.OutputHTML(MsgBodyObj.Separators,i,tPath,MsgBodyObj) Quit:$$$ISERR(tSC)
            S tSC=..SegOutputHTML(MsgBodyObj.Separators,i,tPath,MsgBodyObj,seg,Action) Quit:$$$ISERR(tSC)
            //&html<<TR><TD>tCnt=#(tCnt)#, i=#(i)#</TD></TR>>
            &html<</TR>>
            Do MsgBodyObj.commitSegmentByIndex(i)
        }
        &html<</table>>
    }
                
    //Write:$$$ISERR(tSC) $ZCVT($$$StatusDisplayString(tSC),"O","HTML")
    Quit tSC
}

ClassMethod SegOutputHTML(pSeparators As %String, pSegNum As %String, pSegPath As %String, pDocument As EnsLib.EDI.Document, segment As EnsLib.HL7.Segment, Action As %String) As %Status [ Language = objectscript ]
{
	
	
	s msgBodyObjId=pDocument.%Id()
    Set:""=$G(pSeparators) pSeparators=segment.Separators
    Set tFullLen=segment.FullSize
    Do segment.decompose()
    Set tName=segment.Name, tFS=$ZCVT($E(pSeparators,1),"O","HTML"), tCS=$ZCVT($E(pSeparators,2),"O","HTML"), tRS=$ZCVT($E(pSeparators,3),"O","HTML"), tSS=$ZCVT($E(pSeparators,5),"O","HTML")
    Set:""=tName tName="x"
    Set tSegType=segment.SegType
    Do ..outputHTMLStart(pSegNum, pSegPath,segment.ID,tName,tSegType,tFullLen,$S($IsObject(pDocument):pDocument.DocType,1:""))
    Set tReplaceSpec(" ")="&nbsp;"
    Set tReplaceSpec($C(9))="\t"
    Set tReplaceSpec($C(13))="\r"
    Set tReplaceSpec($C(10))="\n"
    Set iCat=$P(tSegType,":"), iSeg=$P(tSegType,":",2)
    If ""=iCat||(""=iSeg) {
    	Set iList=""
    } Else {
        Set iList=$G($$$vaSchemaGbl(iCat,"SS",iSeg))
        Set tSC=##class(EnsLib.HL7.Schema).getFieldsContentArray(.tContents,"source",iCat,iSeg,0)
    }
                
    Set iCnt=segment.GetValueAt("*",pSeparators)
    If iCnt<1 { &html<<td class='EDISegmentsTableEmptyfield'>&nbsp</td>> }
    Else { For i=1:1:iCnt {
    			Set iN=$ZCVT($P($E($G(tContents(i,"name"),":"_i),2,*),"("),"O","HTML")
            	Set iAttrs=$LG(iList,i), iDT=$LG(iAttrs,1), iSym=$LG(iAttrs,2), iRep=$LG(iAttrs,3), iLen=$LG(iAttrs,4), isRep=$LG(iAttrs,6)
            	Set:'iRep&&isRep iRep=1
            	Set tAttr=$S(iRep>1:iRep,1:"")_iSym_$S(iLen:"("_iLen_")",1:"")
            	If ""'=iDT {
            		Set cCat=$P(iDT,":"),cTyp=$P(iDT,":",2)
                	Set cList=$G($$$vaSchemaGbl(cCat,"DS",cTyp))
            	}                              
            	If $Case(tName,"MSH":1,"FHS":1,"BHS":1,:0) && (i<=2) {
	        		s fPath=pSegPath_":"_i
	            	s fieldTitle=##class(%CSP.Page).EscapeHTML(i_" / "_iN_$S(""=tAttr:"",1:" / "_tAttr))
	            	if (Action="Edit") {
	            		&html<<td nowrap class='EDISegmentsTableValue' id='#(fPath)#'><a title='#(fieldTitle)#' style='cursor: pointer;' onclick='getNewValue(event,"#(fPath)#","#($ZCVT(segment.GetValueAt(i,pSeparators),"O","HTML"))#","#(fieldTitle)#","#(msgBodyObjId)#")'>#($ZCVT(segment.GetValueAt(i,pSeparators),"O","HTML"))#</a></td>>
	            	} else {
		            	&html<<td nowrap class='EDISegmentsTableValue' id='#(Action)#.#(fPath)#'><a title='#(fieldTitle)#' style='cursor: pointer;' >#($ZCVT(segment.GetValueAt(i,pSeparators),"O","HTML"))#</a></td>>
	            	}
                	//&html<<td nowrap class='EDISegmentsTableValue'><a title='#(i)# / #(iN)##($S(""=tAttr:"",1:" / "_tAttr))#' onclick='menuOptions(event,"#(fPath)#","#($ZCVT(segment.GetValueAt(i,pSeparators),"O","HTML"))#")'>#($ZCVT(segment.GetValueAt(i,pSeparators),"O","HTML"))#</a></td>>
                	Continue
            	} Else { &html<<td class='EDISegmentsTableSeparator'>#(tFS)#</td>> }
                                
            	If (""=segment.GetValueAt(i)) {
	        		s fPath=pSegPath_":"_i 
	           	    s fieldTitle=##class(%CSP.Page).EscapeHTML(i_" / "_iN_$S(""=tAttr:"",1:" / "_tAttr))
	           	    if (Action="Edit") {
	            		&html<<td class='EDISegmentsTableEmptyfield' id='#(fPath)#'><a title='#(fieldTitle)#' style='cursor: pointer;' onclick='getNewValue(event,"#(fPath)#","","#(fieldTitle)#","#(msgBodyObjId)#")'>&nbsp;&middot;</a></td>> 
	           	    } else {
		           	    &html<<td class='EDISegmentsTableEmptyfield' id='#(Action)#.#(fPath)#'><a title='#(fieldTitle)#' style='cursor: pointer;' >&nbsp;&middot;</a></td>> 
	           	    }
	           	 	//&html<<td class='EDISegmentsTableEmptyfield'><a title='#(i)# / #(iN)##($S(""=tAttr:"",1:" / "_tAttr))#' onclick='menuOptions(event,"#(fPath)#","")'>&nbsp;&middot;</a></td>> 
	            	Continue
           		}
           		Set rCnt=segment.GetValueAt(i_"(*)")
          		Set rF=1 
          		For r=1:1:rCnt {
          			Set rN=iN,rAlias=i
          			If rCnt>1||iRep { 
          				Set rp=r_$S(rCnt>iRep&&(iRep'=1):"*",1:"")
          		 		Set rN=rN_"("_rp_")"
          		 		Set rAlias=rAlias_"("_rp_")"
    				}
    				If rF { Set rF=0 } Else { &html<<td class='EDISegmentsTableSeparator'>#(tRS)#</td>> }
                                                
   					Set cCnt=segment.GetValueAt(i_"("_r_").*")
    				Set cF=1 
    				For c=1:1:cCnt {
    					Set sCnt=segment.GetValueAt(i_"("_r_")."_c_".*",pSeparators)
    					Set cN=rN,cAlias=rAlias 
    					If ""'=iDT||(cCnt>1)||(sCnt>1) {
    						Set cN=cN_"."_$ZCVT($P($G(tContents(i,c,"name"),c),"("),"O","HTML")
        					Set cAlias=cAlias_"."_c
    					}
    					Set cDT=$S(""=iDT:"",1:$LG(cList,i))
    					If cF { Set cF=0 } Else { &html<<td class='EDISegmentsTableSeparator'>#(tCS)#</td>> }
                                                                
                                                                
    					If (""=segment.GetValueAt(cAlias,pSeparators)) {
							s fPath=pSegPath_":"_i_"("_r_")"
	   						s fieldTitle=##class(%CSP.Page).EscapeHTML(cAlias_" / "_cN_$S(""=tAttr:"",1:" / "_tAttr))
	   						s zPath=pSegPath_":"_cAlias
	   						If (Action="Edit") {
	    						&html<<td class='EDISegmentsTableEmptyfield' id='#(zPath)#'><a title='#(fieldTitle)#' style='cursor: pointer;' onclick='getNewValue(event,"#(zPath)#","","#(fieldTitle)#","#(msgBodyObjId)#")'>&nbsp;&middot;</a></td>>
	   						} else {
		   						&html<<td class='EDISegmentsTableEmptyfield' id='#(Action)#.#(zPath)#'><a title='#(fieldTitle)#' style='cursor: pointer;' >&nbsp;&middot;</a></td>>
	   						}
	    					//&html<<td class='EDISegmentsTableEmptyfield' id='#(fPath)#'><a title='#(fieldTitle)#' onclick='getNewValue(event,"#(fPath)#","","#(fieldTitle)#","#(msgBodyObjId)#")'>&nbsp;&middot;</a></td>>
	   	 					//&html<<td class='EDISegmentsTableEmptyfield'><a title='#(cAlias)# / #(cN_$S(""=tAttr:"",1:" / "_tAttr))#' onclick='menuOptions(event,"#(fPath)#","")'>&nbsp;&middot;</a></td>> 
	    					Continue
    					}
    					
    					Set sF=1 For s=1:1:sCnt {
    					Set sN=cN,sAlias=cAlias 
    					If ""'=cDT||(sCnt>1) {
        					Set sN=cN_"."_$ZCVT($P($G(tContents(i,c,s,"name"),s),"("),"O","HTML")
            				Set sAlias=cAlias_"."_s
        				}
        				If sF { Set sF=0 } Else { &html<<td class='EDISegmentsTableSeparator'>#(tSS)#</td>> }
                                                                                
        			Set tVal=segment.GetValueAt(sAlias,pSeparators)
        			Set fPath=pSegPath_":"_sAlias
        			s fieldTitle=sAlias_" / "_sN_$S(""=tAttr:"",1:" / "_tAttr)
        			If (tVal="") {
        				if (Action="Edit") {
        					&html<<td class='EDISegmentsTableEmptyfield'><a title='fieldTitle' style='cursor: pointer;' onclick='getNewValue(event,"#(fPath)#","","#(fieldTitle)#","#(msgBodyObjId)#")'>&nbsp;&middot;</a></td>> 
        				} else {
	        				&html<<td class='EDISegmentsTableEmptyfield'><a title='fieldTitle' style='cursor: pointer;' >&nbsp;&middot;</a></td>> 
        				}
        				Continue
        			}
        			//If ""=tVal &html<<td class='EDISegmentsTableEmptyfield'><a title='#(sAlias)# / #(sN_$S(""=tAttr:"",1:" / "_tAttr))#' onclick='menuOptions(event,"#(fPath)#","")'>&nbsp;&middot;</a></td>> Continue
        			if (Action="Edit") {
        				&html<<td nowrap class='EDISegmentsTableValue' id='#(fPath)#'><a title='#(fieldTitle)#' style='cursor: pointer;' onclick='getNewValue(event,"#(fPath)#","#($ZCVT($E(tVal,1,2000),"O","JS"))#","#(fieldTitle)#","#(msgBodyObjId)#")'>>
        			} else {
	        			&html<<td nowrap class='EDISegmentsTableValue' id='#(Action)#.#(fPath)#'><a title='#(fieldTitle)#' style='cursor: pointer;' >>
        			}
        			//&html<<td nowrap class='EDISegmentsTableValue'><a title='#(sAlias)# / #(sN_$S(""=tAttr:"",1:" / "_tAttr))#' onclick='menuOptions(event,"#(fPath)#","#($E(tVal,1,2000))#")'>>
       				Set:$L(tVal)>2000 tVal=$E(tVal,1,2000)_" segment.."
        			While ""'=tVal { Set tPiece=$E(tVal,1,1000), tVal=$E(tVal,1001,*) Write $$replaceArray^EnsUtil($ZCVT(tPiece,"O","HTML"),.tReplaceSpec) }
        			&html<</a></td>>
   				}
   			}
   		}
   }}
                
   If $IsObject(pDocument)&&("DocsRef"=$E(tName,*-$L("DocsRef")+1,*)) {
   		Do segment.outputChildLinks(pDocument,$E(tName,1,*-$L("DocsRef")))
   }
                
   Do ..outputHTMLEnd()
   Quit msgBodyObjId
}

ClassMethod outputHTMLStart(pSegNum, pSegPath, pID, pName, pSegType, pFullLen, pMsgStructure)
{
	Set tDesc=$S(""=pSegType:"", 1:##class(EnsLib.HL7.Schema).GetDescription("SS:"_pSegType))
	Set len=$S(pFullLen<=2000:"",1:" (len="_pFullLen_")")
	&html<
	<td class='EDIDocumentTableSegnum'>#(pSegNum)#&nbsp;</td><td class='EDIDocumentTableSegid' SegID='#(pID)#'>#($S(""=pID:"*",1:"&nbsp;"))#</td>
	<td class='EDIDocumentTableSegname'>
		<a title='#($S(pSegNum=pSegPath&&(""'=pSegType):"SS:"_pSegType, 1:$ZCVT(pSegPath_$S(""=tDesc:"", 1:" - "_tDesc),"O","HTML"))_len)#' >#(pName)#
	</a></td><td><table class='EDISegmentsTable'><tr>>
}

ClassMethod FieldUpdate(msgObjId As %Integer, pValue As %String, pPath As %String) As %Status [ Language = objectscript ]
{
	
	s MsgBodyObj=##class(EnsLib.HL7.Message).%OpenId(msgObjId)
	
	//Get path and repeat value
	s key=""
	s rPath=$Reverse(pPath)
	if ( $E(rPath)=")" ) {
		s lenPath=$Length(pPath)
		S startRep=lenPath-$F(rPath,"(")+2
		s newPath=$E(pPath,1,startRep-1)
		s key=$E(pPath,startRep+1,lenPath-1)
	} else {
		s newPath=pPath
	}
	
	
	
	s tSC=MsgBodyObj.SetValueAt(pValue,newPath,"set",key)
	S %session.Data("MessageEdits")=$G(%session.Data("MessageEdits"))_newPath_"{"_pValue_"} "
	//S ^CacheTempBenTest("FieldUpdate")="s pValue="""_pValue_""" s pPath="""_pPath_""" s tSC=MsgBodyObj.SetValueAt(pValue,pPath,""set"","""")"
	s tSC=MsgBodyObj.%Save()
	Q tSC
}

ClassMethod SendMessage(OrigMsgHdrId As %Integer, NewMsgBodyId, NewTarget As %String) As %String [ Language = objectscript ]
{
	
	s NewMsgBody=##class(EnsLib.HL7.Message).%OpenId(NewMsgBodyId)
	s tSC=##class(Ens.MessageHeader).NewDuplicatedMessage(.tNewHeader,OrigMsgHdrId,NewTarget,NewMsgBody)
	if (tSC=1) {
		s tSC=##class(Ens.Queue).EnQueue(tNewHeader)
		d $SYSTEM.Security.Audit("IIBAENSEMBLE.csp.MessageEdit","MessageEdit","Message Edit",$G(%session.Data("MessageEdits")),"Original Message Header Id: "_OrigMsgHdrId_", New Message Header Id: "_tNewHeader.%Id()_", New Target: "_NewTarget)
		S %session.Data("MessageEdits")="Message Edits (format: path{new value}): "
		S MessageSent="True"
	}
	
	Set tOut=$S($$$ISERR(tSC):msgid_":"_$TR($$$StatusDisplayString(tSC),",",";"), 1:tNewHeader.%Id())
	
	
	Q tOut
}

ClassMethod buildmodalNewValue() As %String
{
	set sHTML = ""
	set sHTML=sHTML_"<div class='dialog' id=""modalNewValue"" >"
	
		//set sHTML=sHTML_"<div style=""margin-bottom: 10px;text-align:center""><h3>Edit Field Value</h3></div>"
		set sHTML=sHTML_"<div style=""margin-left: 20px;margin-right: 20px;"">"
		set sHTML=sHTML_"<table>"
		set sHTML=sHTML_"<tr><td width=""100px"">Field: </td>"
		set sHTML=sHTML_"<td><div id=""newValueFieldName""></div></td></tr>"
		set sHTML=sHTML_"<tr><td width=""100px"">Value: </td>"
		set sHTML=sHTML_"<td><input type=""text"" id=""newValueField"" value=""""></td></tr>"
		set sHTML=sHTML_"</table>"
		set sHTML=sHTML_"</div>"
		set sHTML=sHTML_"<input type=""hidden"" id=""newValueFieldId"" value="""">"
		set sHTML=sHTML_"<input type=""hidden"" id=""newValueFieldTitle"" value="""">"
		set sHTML=sHTML_"<input type=""hidden"" id=""newValuemsgObjId"" value="""">"
		set sHTML=sHTML_"<div style=""margin-left: 20px;margin-top: 10px""><button onclick=""hm('modalNewValue');newValueSave()"">Save</button><button onclick=""hm('modalNewValue')"">Cancel</button></div>"
	
 	set sHTML=sHTML_"</div>"
 	Quit sHTML
}

ClassMethod linkParents(pDocObj) As %String [ Internal ]
{
	Set tOutStr=""
	Set tChildCount=pDocObj.ChildCount
	Set:tChildCount tOutStr=tOutStr_", <b>"_tChildCount_"</b> "_$S(tChildCount>1:"child documents", 1:"child document")
	Set tNumParents=$LL(pDocObj.ParentIds)
	If tNumParents {
		Set tOutStr=tOutStr_", "_$S(tNumParents>1:"parent documents ", 1:"parent document ")
		Set tParent=pDocObj.Parent
		While $IsObject(tParent) {
			Set tOutStr=tOutStr_": <a target='_blank' title='HL7 Document Database Id = "_tParent.%Id()_"', Type Name = '"_tParent.Name_"' method=get href="_##class(%CSP.Page).Link("EDIDocumentView.csp?CLASS="_tParent.%ClassName(1)_"&NAME="_$ZCVT("HL7 Document","O","URL")_"&ORIGIN=EDIDoc&EDIDOCID="_tParent.%Id()_"&DOCSPEC=Stored#doc_content")_">&lt;"_tParent.%Id()_"&gt;</a>"
			Set tParent=tParent.Parent
		}
	}
	Quit tOutStr
}

ClassMethod outputHTMLEnd() [ Internal ]
{
	&html<</tr></table></td>>
}

}
