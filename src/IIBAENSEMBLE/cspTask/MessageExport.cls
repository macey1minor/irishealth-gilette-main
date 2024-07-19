/// Copyright 2007 by Inland Imaging Business Associates
Class IIBAENSEMBLE.cspTask.MessageExport Extends %CSP.Page
{

ClassMethod CheckPermissions()
{
	set Allowed = 0
	if ##class(%SYSTEM.Security).Check("%All") = "READ,WRITE,USE" { set Allowed = 1 }
	
	if ##class(%SYSTEM.Security).Check("IIBAMsgDef") = "READ,WRITE,USE" { set Allowed = 1 }
	
	Quit Allowed
}

ClassMethod jsfunction()
{
  &html<
	<script language=javascript>
	
	function ExportMsg() {
		
		var messageId = document.getElementById('MessageId').value;
		//alert('Export ' + messageId);
		var filename = #server(..messageExport(this.MessageId.value))#;
		
		if (filename!="")
		{
			window.location = 'IIBAENSEMBLE.csp.FileDownload.cls?filename='+filename;		
		}
	}  
  </script>
  >
}

ClassMethod html()
{
    w "<table width=800px><tr><td width=700px>"
    w "HL7 Message Search - Export Large Message "
	w "</td>"
	W "<TD nowrap >"
	w "<input type='Text' id='MessageId' value='Message Id' "" >&nbsp;"
	W "</TD>"
	W "<td>"
	w "<Input Type=""Button"" id='btnExport' Value='Export' onclick='ExportMsg()' >"

	w "</td></tr></table>"
}

ClassMethod messageExport(MessageId As %String) As %String
{
	if ($NUMBER(MessageId,"I")="")
	{
		&js<alert('No valid integer specified.');>
		Q ""
	}
	s EnsSysDir = ##class(%File).ParentDirectoryName(##class(%File).ManagerDirectory())
	s filetimestamp = ##class(Ens.Util.Time).FormatDateTime("%Y%m%d%H%M%S")
	
	if '##class(%File).DirectoryExists(EnsSysDir_"IIBAExports") { 
		d ##class(%File).CreateDirectory(EnsSysDir_"IIBAExports") 
	}
	s path = EnsSysDir_"IIBAExports\"
	s filename = "MsgExport_"_%session.SessionId_".txt"
	//&js<alert('File Name : ' + #(filename)#);>
	s message = ##class(EnsLib.HL7.Message).%OpenId(MessageId)
	if ($ISOBJECT(message))
	{
		s tSC = message.OutputToFile(path_filename)
		Q filename
	}
	&js<alert('No HL7 message found with ID: ' + #(MessageId)#);>
	Q ""
}

}
