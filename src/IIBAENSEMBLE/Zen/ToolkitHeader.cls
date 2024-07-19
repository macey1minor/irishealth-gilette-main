Class IIBAENSEMBLE.Zen.ToolkitHeader Extends %ZEN.Component.component
{

/// XML namespace for this component.
Parameter NAMESPACE = "http://www.intersystems.com/toolkitheader";

Parameter DOMAIN = "ZENToolKIT";

/// Title displayed within this pane.
Property title As %ZEN.Datatype.caption;

/// defines style sheet used by this component
XData Style
{
}

/// Draw the HTML contents of this component.
Method %DrawHTML()
{
	
	&html<<table width="100%" cellspacing="0" cellpadding="0" border="0" style="font-size: 10pt;">
   <tbody><tr>
   <td width="210" valign="bottom" nowrap="" bgcolor="#FFFFFF" align="left" style="background-repeat: no-repeat; background-image: url(customimages/IIBA_logo.jpg);">
   </td>
   <td width="50" valign="top" nowrap="" bgcolor="#FFFFFF" align="left" style="margin-right: 0px; background-repeat: repeat-y; background-image: url(customimages/whitetoyellow.gif);"></td>
   <td valign="top" width="280" nowrap="" bgcolor="#fffae7" align="left">
   <div style="color: #004C8F; margin-top: 18px; font-weight: bold; font-size: 11pt;">Integration Support Toolkit</div>
   <div style="color: #004C8F; margin-top: 5px; font-weight: bold; font-size: 11pt;" id="PageTitle">#($ZCVT(..title,"O","HTML"))#</div>
   </td>
   <td width="50" valign="top" nowrap="" bgcolor="#FFFFFF" align="left" style="margin-right: 0px; background-repeat: repeat-y; background-image: url(customimages/yellowtoblue.gif);"></td>
   <td bgcolor="#004C8F" width="20"></td>
   <td valign="middle" bgcolor="#004C8F">
   <table border="0" bgcolor="#004C8F">

   		<tbody><tr><td nowrap="" style="text-align: left;" class="quote-name" title="Name of the machine this system is running on"><span style="color: rgb(255, 250, 231); font-size: 8pt; padding-right: 5px;">Server:</span><b>
   		<span style="color: #fffae7;">#($zu(110))#</span></b>
   		
   	
   	
   		
   		
   		
   		</td></tr>
   		
   		
   		<tr><td nowrap="" style="text-align: left;" class="quote-name" title="Configuration name of this system"><span style="color: rgb(255, 250, 231); font-size: 8pt; padding-right: 5px;">NameSpace:</span><b><span style="color: #fffae7;">#($ZNSPACE)#</span></b></td></tr>
		<tr><td style="text-align: left;" class="quote-name" title="Name of user logged into this session">
		<span style="color: rgb(255, 250, 231); font-size: 8pt; padding-right: 5px;">User:</span><b><span style="color: #fffae7;">#(%session.Username)#</span></b></td></tr>
			

   </tbody></table>
   </td>
   <td bgcolor="#004C8F"></td>
   <td width="50" valign="top" nowrap="" bgcolor="#FFFFFF" align="left" style="margin-right: 0px; background-repeat: repeat-y; background-image: url(customimages/bluetowhite.gif);"></td>
   <td bgcolor="#FFFFFF" width="20"></td>
   <td width="200" align="left" valign="middle" nowrap="" height="78" bgcolor="#FFFFFF" align="left" style="background-repeat: no-repeat; background-image: url(customimages/Client.jpg);"><p style="color: red;font-size: large;font-weight: bold">#(##class(IIBAENSEMBLE.Functions).TableLookup("text",,,"Clientimagetext"))#</p></td>
   </tr>
	
	</tbody></table>>
}

}
