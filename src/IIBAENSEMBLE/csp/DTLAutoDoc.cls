/// Copyright 2007 by Inland Imaging Business Associates
Class IIBAENSEMBLE.csp.DTLAutoDoc Extends %CSP.Page [ ProcedureBlock ]
{

ClassMethod CheckPermissions()
{
	set Allowed = 0
	if ##class(%SYSTEM.Security).Check("%All") = "READ,WRITE,USE" { set Allowed = 1 }
	
	Quit Allowed
}

ClassMethod jsfunction()
{
	&html<
   <script language=javascript>
   function Initialize()
	{

	}
	</script>
  >
}

ClassMethod html()
{
    
    
    &html<
    
	    <style type="text/css">
		#transformHdr, #transformDetail
		{
		font-family:"Trebuchet MS", Arial, Helvetica, sans-serif;
		width:100%;
		border-collapse:collapse;
		border: 1px solid #008Fff;
		}
		#transformHdr th, #transformHdr td, #transformDetail th, #transformDetail td
		{
		border: 1px solid #008Fff;
		padding-right:5px;
		padding-left:5px;
		}
		#transformHdr td, #transformDetail td
		{
		font-size:.8em;
		}
		#transformDetail td.if, #transformDetail td.true, #transformDetail td.false, #transformDetail td.foreach, #transformDetail td.code
		{
		background-color:#A8D3FF;

		}

		#transformHdr th, #transformDetail th
		{
		font-size:1.4em;
		text-align:left;
		padding-top:5px;
		padding-bottom:4px;
		background-color:#4DA6FF;
		color:#fff;
		}
		#transformDetail tr.alt
		{
		color:#000;
		background-color:#D5EAFF;
		}
		#transformHdr tr, #transformDetail tr
		{
		color:#000;
		background-color:#D5EAFF;
		}
	</style>   
    
    >
    
    
    
    Set DTL=%request.Get("DTL")
    
    w DTL,"<p>"
    
    s tSC = $System.OBJ.ExportToStream(DTL,.stream)
	
	set tSC = ##class(%XML.TextReader).ParseStream(.stream,.TR)
	d TR.Rewind()
	s tSC = TR.ReadStartElement("Data")
	
	s newstream = ##class(%GlobalCharacterStream).%New()
	
	While TR.Read() {
		if (TR.Name = "Data") && (TR.NodeType = "endelement") Quit
		//w tResult.Name_" - "_tResult.NodeType,!
		d newstream.Write(TR.Value)
	}
	
	d newstream.Rewind()
	
	set tSC = ##class(%XML.TextReader).ParseStream(.newstream,.tResult)
	
	set indent = 5
	s tHeaderRow = "", tTransformRow = ""
	
	
	While tResult.Read() {
	//	w tResult.Name_" - "_tResult.NodeType,!

		if tResult.NodeType = "element" {
			if tResult.Name = "transform" {
				//w "Transform:",!
				
				For j=1:1:tResult.AttributeCount
				{
					Do tResult.MoveToAttributeIndex(j)
					s tHeaderRow = $CASE(tResult.Name,
						"targetClass":tHeaderRow_"<th class='transformHdr'>"_tResult.Name_"</th>",
						"targetDocType":tHeaderRow_"<th class='transformHdr'>"_tResult.Name_"</th>",
						"sourceClass":tHeaderRow_"<th class='transformHdr'>"_tResult.Name_"</th>",
						"sourceDocType":tHeaderRow_"<th class='transformHdr'>"_tResult.Name_"</th>",
						"create":tHeaderRow_"<th class='transformHdr'>"_tResult.Name_"</th>",
						:tHeaderRow_""
					)
					s tTransformRow = $CASE(tResult.Name,
						"targetClass":tTransformRow_"<td class='transformSig'>"_tResult.Value_"</td>",
						"targetDocType":tTransformRow_"<td class='transformSig'>"_tResult.Value_"</td>",
						"sourceClass":tTransformRow_"<td class='transformSig'>"_tResult.Value_"</td>",
						"sourceDocType":tTransformRow_"<td class='transformSig'>"_tResult.Value_"</td>",
						"create":tTransformRow_"<td class='transformSig'>"_tResult.Value_"</td>",
						:tTransformRow_""
					)
				}
				w "<table class='transformHdr' id='transformHdr'>",!
				w "<tr>"
				w tHeaderRow
				w "</tr>",!
				w "<tr>"
				w tTransformRow
				w "</tr>",!
				w "</table><br>",!
				
				w "<table class='transformDetail' id='transformDetail'>",!
				w "<tr class='header'><th>Target</th><th>Source</th></tr>",!
			
			}
			
			if tResult.Name = "assign" {
				//w indent_"assign: "
				w "<tr class='assign'>"
				For j=1:1:tResult.AttributeCount
				{
					Do tResult.MoveToAttributeIndex(j)
					w $CASE(tResult.Name,
						"property":"<td class='assignT' style='padding-left:"_indent_"px;'>"_$TR($REPLACE($REPLACE(tResult.Value,"target.",""),"##class(IIBAENSEMBLE.Functions).",""),"{}")_"</td>",
						"value":"<td class='assignS'>"_$TR($REPLACE($REPLACE(tResult.Value,"source.",""),"##class(IIBAENSEMBLE.Functions).",""),"{}")_"</td>",
						:""
					)
				}
				w "</tr>",!
				
			}
			
			if tResult.Name = "code" {
				w "<tr class='code'>"
				w "<td class='code' style='padding-left:"_indent_"px;'>"_"CODE</td><td/>"
				w "</tr>",!
				set indent = indent+15
				w "<tr class='code'>"
				w "<td class='codeValue' colspan='2' style='padding-left:"_indent_"px;'>"
				While tResult.Read() {
					w $REPLACE($REPLACE(tResult.Value,$C(10),"<br>"),$C(9),"&nbsp;&nbsp"),!
					if (tResult.Name = "code") && (tResult.NodeType = "endelement") Quit
				}
				w "</td>"
				w "</tr>",!
			}

			if tResult.Name = "annotation" {
				set indent = indent+15
				w "<tr class='annotation'>"
				w "<td class='annotationValue' colspan='2' style='padding-left:"_indent_"px;'>"
				While tResult.Read() {
					w "//"_$REPLACE($REPLACE(tResult.Value,$C(10),"<br>//"),$C(9),"&nbsp;&nbsp"),!
					if (tResult.Name = "annotation") && (tResult.NodeType = "endelement") Quit
				}
				w "</td>"
				w "</tr>",!
			}
			
			if tResult.Name = "if" {
				//w indent_"if: "
				w "<tr class='if'>"
				For j=1:1:tResult.AttributeCount
				{
					Do tResult.MoveToAttributeIndex(j)
					w $CASE(tResult.Name,
						"condition":"<td class='if' colspan='2' style='padding-left:"_indent_"px;'>"_"IF: "_$TR($REPLACE($REPLACE(tResult.Value,"source.",""),"##class(IIBAENSEMBLE.Functions).",""),"{}")_"</td>",
						:""
					)
				}
				w "</tr>",!
			}
			if tResult.Name = "true" {
				w "<tr class='true'>"
				w "<td class='true' style='padding-left:"_indent_"px;'>"_"TRUE</td><td/>"
				w "</tr>",!
				set indent = indent+15
			}
			if tResult.Name = "false" {
				w "<tr class='false'>"
				w "<td class='false' style='padding-left:"_indent_"px;'>"_"FALSE</td><td/>"
				w "</tr>",!
				set indent = indent+15
			}
			if tResult.Name = "foreach" {
				//w indent_"for each: "
				w "<tr class='foreach'>"
				For j=1:1:tResult.AttributeCount
				{
					Do tResult.MoveToAttributeIndex(j)
					w $CASE(tResult.Name,
						"property":"<td class='foreach' colspan='2' style='padding-left:"_indent_"px;'>"_"FOREACH: "_$TR($REPLACE($REPLACE(tResult.Value,"source.",""),"##class(IIBAENSEMBLE.Functions).",""),"{}")_"</td>",
						:""
					)
				}
				w "</tr>",!
				set indent = indent+15
			}
			
			

		}
		if tResult.NodeType = "endelement" {
			if tResult.Name = "true" {
				set indent = indent - 15
			}
			if tResult.Name = "false" {
				set indent = indent - 15
			}
			if tResult.Name = "code" {
				set indent = indent - 15
			}
			if tResult.Name = "annotation" {
				set indent = indent - 15
			}
			if tResult.Name = "foreach" {
				set indent = indent - 15
			}
		}


		
		
	}
	
	w "</table>",!
	
	s TR = ""
	s newstream = ""
	s stream = ""
	s tResult = ""
}

}
