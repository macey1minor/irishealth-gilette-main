/// Copyright 2007 by Inland Imaging Business Associates
Class IIBAENSEMBLE.csp.RefAddAttr Extends %CSP.Page [ ProcedureBlock ]
{

ClassMethod CheckPermissions()
{
	set Allowed = 0
	// Req#1 - Phegel Changed to use the Reference resource so you don't need to have %All permissions to use the Reference Attribute Definition page
	if ##class(%SYSTEM.Security).Check("Reference", "WRITE")
		{ 
			set Allowed = 1 
		}
	
	Quit Allowed
}

ClassMethod jsfunction()
{
  &html<
   <script language=javascript>
	<!--
	function Initialize()
	{

	}
	function Hello() {
		alert('Hello');
	}
	
	
	
	function loadrefparamters() {
		
			
		var xselected=document.getElementById("Name").selectedIndex;
		var xrefV=document.getElementById("Name").options[xselected].value;
		var xrefT=document.getElementById("Name").options[xselected].text;
		
		document.location="IIBASupport.csp?PageName=RefAddAttr&ID="+xrefV
		
		//alert('selected xref: '+xrefT+' ('+xrefV+')');
		
		document.getElementById("reftable").href='IIBASupport.csp?PageName=Reference&ID='+xrefV
		
		var principlesystem = #server(..GetPrincipleSystem(xrefV))#;
		document.getElementById("PrincipleName").value=principlesystem;
		
		var reflist = #server(..GetRefSystems(xrefV))#;
		
		// Remove all current related systems options
		var rel=document.getElementById("relatedsys");
		for (i=rel.length;i>-1;i--) {
			//alert('removing '+i);
			rel.remove(i);
		}
		
		// Add new related systems options
		rel.selected=0;
				
		var refarray=reflist.split("|");
		for (i=0;i<refarray.length;i++) {
			elementarray=refarray[i].split("^");
			option=document.createElement("option");
			option.text=elementarray[0];
			option.value="RS"+elementarray[1];
			rel.add(option);
		}
		
	}
	
	function loadattrclass() {
		
		
		var rselected=document.getElementById("relatedsys").selectedIndex;
		var rrefV=document.getElementById("relatedsys").options[rselected].value;
		var rrefT=document.getElementById("relatedsys").options[rselected].text;
		
		rrefV=rrefV.substr(2,rrefV.length);
		
		//alert("get attr class - value: "+rrefV+", text: "+rrefT)
		
		var attrclass = #server(..GetAttrClass(rrefV,rrefT))#;
		
		//alert("Attribute class: "+attrclass);
				
		document.getElementById("attrclass").value=attrclass;
		
		
	}
	
	function saveattr() {
		
				
		var xselected=document.getElementById("Name").selectedIndex;
		var xrefV=document.getElementById("Name").options[xselected].value;
		var xrefT=document.getElementById("Name").options[xselected].text;
		
		var refsysname=document.getElementById("relatedsys").options[document.getElementById("relatedsys").selectedIndex].text;
		var refsysid=document.getElementById("relatedsys").options[document.getElementById("relatedsys").selectedIndex].value;
		
		refsysid=refsysid.substr(2,refsysid.length);
		
		var newattrclass=document.getElementById("attrclass").value;
		
		if (xrefV=="") {
			alert('xRef table required');
			return(0);
		}
		
		if (refsysname=="") {
			alert('Related System required');
			return(0);
		}
		
		if (newattrclass=="") {
			alert('Attribute class is required');
			return(0);
		}
		
		if (#server(..ValidateAttrClass(newattrclass))# == 0 ) {
			alert('Attribute class does not exist!\nCSave aborted.');
			return(0);
		}
		
		// has the attribute class changed?
		var curattrclass = #server(..GetAttrClass(refsysid,refsysname))#;	
		//alert("current attr class: "+curattrclass+", new attr class: "+newattrclass);
			
		if ( (curattrclass!="") && (newattrclass != curattrclass)) {
			//alert("You are changing the attr class");
			
			var r=confirm("The attribute class is changing from '"+curattrclass+"' to '"+newattrclass+"'. \nAll attribute entries will be deleted. \nDo you want to continue?");
			
			if (r==true) {
				var rv=#server(..DeleteAttrEntries(refsysid,curattrclass))#;
				//alert("Delete attribute entries returned: "+rv);
				
			} else {
				alert('Attribute class defition save/update aborted');
				return(0);
			} 
				
		}
		
		
				
		//alert('xref: '+xrefV+', reference system: '+refsysid+', attribute class: '+newattrclass);
		
		var updatedef = #server(..SaveAttrClass(xrefV,refsysid,newattrclass))#;
		
		//alert('save return value: '+updatedef);
		
		if (updatedef==1) {
			alert('Attribute class definition save/update successfull');
		} else {
			alert('Attribute class definition save/update failed');
		}
		
	}
	
	function removeattr() {
		
		
		var xselected=document.getElementById("Name").selectedIndex;
		var xrefV=document.getElementById("Name").options[xselected].value;
		var xrefT=document.getElementById("Name").options[xselected].text;
		
		var refsysname=document.getElementById("relatedsys").options[document.getElementById("relatedsys").selectedIndex].text;
		var refsysid=document.getElementById("relatedsys").options[document.getElementById("relatedsys").selectedIndex].value;
		
		refsysid=refsysid.substr(2,refsysid.length);
		
		var curattrclass = #server(..GetAttrClass(refsysid,refsysname))#;
		
		var newattrclass=document.getElementById("attrclass").value;
		
		if ( (curattrclass !="" ) && (curattrclass != newattrclass) ) {
			alert('Current attribure class is: ' + curattrclass);
			document.getElementById("attrclass").value=curattrclass;
		}
		
		if (curattrclass != "" ) {
			var r=confirm("Remove Attribute Class. "+curattrclass+"\nAll Attribute entries will be deleted!! \nDo you want to continue?");
			var rv=#server(..DeleteAttrEntries(refsysid,curattrclass))#;
		
			var updatedef = #server(..SaveAttrClass(xrefV,refsysid,""))#;
		
			if (updatedef == 1) {
				document.getElementById("attrclass").value="";
			}
			
			alert("Attribute class '"+curattrclass+" and all attribute values removed successfully");
		} else {
			document.getElementById("attrclass").value="";
		}
	
	
	}
	
	
	
	function validateattr() {
		var attrclass=document.getElementById("attrclass").value;
		
		
		var validate=#server(..ValidateAttrClass(attrclass))#;
		//alert("Validate returned: "+validate);
		
		if (validate == 0 ) {
			alert('Attribute class "'+attrclass+'" does not exist!');
			
		} 
		
		return(validate);
	}

	function cancelattr() {
		document.location='IIBASupport.csp?PageName=Reference';
	}


	
  -->
   </script>
  >
}

ClassMethod html()
{
    
	set %session.Data("refID")=%request.Get("ID")
	
	w "<table><tr><td class=""LayoutContentCol"" width=""20%"" ><div class=""DetailCommand"">"
	w "&nbsp;"
        
    w "<select NAME='Name' ID='Name' onchange='loadrefparamters()'>"
	w "<option VALUE="""">Select Reference..."

	set rs = ##class(%ResultSet).%New()
	do rs.Prepare("select ID, Name, Resource from IIBAENSEMBLE_Reference.PrincipalType order by Name")
	do rs.Execute()
	While rs.Next() {
		if (rs.Data("Resource")="")||(##class(%SYSTEM.Security).Check(rs.Data("Resource")) = "READ,WRITE,USE") {
			if rs.Data("ID") = %request.Get("ID"){
				w "<option VALUE="""_rs.Data("ID")_""" selected>"_rs.Data("Name")
			} else {
				w "<option VALUE="""_rs.Data("ID")_""">"_rs.Data("Name")
			}
		}	
	}

	w "</select>"
	w "&nbsp;|&nbsp;"
	set HideMultiples = %request.Get("HideMultiples")
	set %session.Data("HideMultiples") = %request.Get("HideMultiples")
	
	if ##class(%SYSTEM.Security).Check("%All") = "READ,WRITE,USE" {
		w "|"
		w "<A class=""DetailCommand"" target=""_top"" id='linkRefAddAttr' href=""IIBASupport.csp?PageName=RefAddAttr""><nobr>&nbsp;Reference Attribute Def&nbsp;</nobr></A>"
		w "<A class=""DetailCommand"" target='_top' id='reftable' href='IIBASupport.csp?PageName=Reference&ID="_%request.Get("ID")_"' onclick='loadreftable();return false'><nobr>&nbsp;Ref Table</nobr></A>"
	}
	w "|"
	w "<a class=""DetailCommand"" target=""_top"" href="""" onclick=""importFormShow();return false""><nobr>&nbsp;Import&nbsp;</nobr></A>"
	
	w "</div>"
	w "</td></tr></table>"


	W "<Form Name=""xRefAttributeAdd"" id=""xRefAttributeAdd"">"
	W "<Table cellpadding=10><TR><TD>"
	W "<Table>"
	
	W "<TR><TD>Principle System</TD><TD><input type='text' id='PrincipleName' "
	
	if (%request.Get("ID")'="") {
		w "value='"_..GetPrincipleSystem(%request.Get("ID"))_"' />"
	} else {
		W "value='' />"
	}
	W "</TD></TR>"
	
	W "<TR><TD>Related System</TD>"
	//  ### one row per parameter / threshold
	W "<TD><Select name='relatedsys' id='relatedsys' onchange='loadattrclass()'>"
	if (%request.Get("ID")'="") {
		s rellist=..GetRefSystems(%request.Get("ID"))
		for i=1:1:$L(rellist,"|") {
			w "<OPTION value='RS"_$P($P(rellist,"|",i),"^",2)_"'>"_$P($P(rellist,"|",i),"^",1)_"</OPTION>"
		}
	} else {
		w "<OPTION value=''/>"
	}
	w "</SELECT></TD></TR>"
	
	W "<TR><TD>Attribute Class</TD><TD><input type='text' name='attrclass' id='attrclass' value='' onchange='validateattr()' /></TD></TR>"
	
	w "<TR>"
	W "<TD><Input type='button' name='attrsave' id='attrsave' value='Save' onclick='saveattr()' /></TD>"
	w "<TD><Input type='button' name='attrcancel' id='attrcancel' value='Cancel' onclick='cancelattr()' /></TD>"
	w "<TD><Input type='button' name='attrremove' id='attrremove' value='remove' onclick='removeattr()' /></TD>"
	W "</TR>"

	W "</Table>"
	W "</TR></TD>"
	W "</Table>"
	W "</Form>"
}

ClassMethod GetRefSystems(PrincipleId As %String) As %String
{
	S RefList=""
	
	s rs=##class(%ResultSet).%New()
	d rs.Prepare("select distinct ID,System from  IIBAENSEMBLE_Reference.RelatedType where PrincipalType='"_PrincipleId_"'")
	d rs.Execute()
	while rs.Next() {
		s RefList=RefList_"|"_rs.GetDataByName("System")_"^"_rs.GetDataByName("ID")
	}
	
	
	
	Quit RefList
}

ClassMethod GetPrincipleSystem(PrincipleId As %String) As %String
{
	S PrincipleSys=""
	
	s rs=##class(%ResultSet).%New()
	d rs.Prepare("select System from   IIBAENSEMBLE_Reference.PrincipalType where ID='"_PrincipleId_"'")
	d rs.Execute()
	while rs.Next() {
		s PrincipleSys=rs.GetDataByName("System")
	}
	
	
	Quit PrincipleSys
}

ClassMethod GetAttrClass(RelatedId As %String, System As %String) As %String
{
	S AttrClass=""
	
	s rs=##class(%ResultSet).%New()
	s qry="select AttrClass from IIBAENSEMBLE_Reference.RelatedType where ID='"_RelatedId_"' and System='"_System_"'"
		
	d rs.Prepare(qry)
	d rs.Execute()
	d rs.Next() 
	s AttrClass=rs.GetDataByName("attrClass")
	
	If AttrClass=$C(0) s AttrClass=""
	
	Quit AttrClass
}

ClassMethod SaveAttrClass(PrincipleId As %String, AttrSystemid As %String, AttrClass As %String) As %String
{
	
	set returnval=$$$OK
	
	if (AttrClass'="") {
		s count=..ValidateAttrClass(AttrClass)
		if (count=0) {
			Q "Class does not exist or does not have properties "_count
		}
	}
	
	
	
	Set rs = ##class(%ResultSet).%New()
	s qry="Update IIBAENSEMBLE_Reference.RelatedType set AttrClass='"_AttrClass_"' where ID="_AttrSystemid
	
	Do rs.Prepare(qry)
	set tSC = rs.Execute() Quit:$$$ISERR(tSC) tSC
	
	Quit returnval
}

ClassMethod ValidateAttrClass(AttrClass As %String)
{
	
	
	
	Set returnval=-1
	
	Set rs = ##class(%ResultSet).%New()
	s qry="Select count(*) as rowcount from %Dictionary.PropertyDefinition where parent = '"_AttrClass_"'"
		
	Do rs.Prepare(qry)
	set tSC = rs.Execute() Quit:$$$ISERR(tSC) tSC
	do rs.Next() 
	Set returnval=rs.GetDataByName("rowcount")
	
	
	Quit returnval
}

ClassMethod DeleteAttrEntries(RelatedId As %String, AttrClass As %String) As %String
{
	
	s rs=##class(%ResultSet).%New()
	s qry="Delete from "_AttrClass_" where ID in (select attrId from IIBAENSEMBLE_Reference.Relatedvalue where relatedtype="_RelatedId_" )"
	
	s tSC=rs.Prepare(qry) Quit:$$$ISERR(tSC) tSC
	s tSC=rs.Execute()  Quit:$$$ISERR(tSC) tSC
	
	d rs.Close()
	s rs=##class(%ResultSet).%New()
	/*
	s qry="update IIBAENSEMBLE_Reference.Relatedvalue set attrId='' where RelatedType="_RelatedId
	d rs.Prepare(qry)
	s tSC=rs.Execute() Quit:$$$ISERR(tSC) tSC
	*/
	
	s qry="select ID from IIBAENSEMBLE_Reference.Relatedvalue where RelatedType="_RelatedId
	d rs.Prepare()
	s tSC=rs.Execute() Quit:$$$ISERR(tSC) tSC
	
	while( rs.Next() ) {
		s id=rs.GetDataByName("ID")
		s obj=##class(IIBAENSEMBLE.Reference.RelatedValue).%OpenId(ID)
		s obj.attrId=""
		d obj.%Save()
		
	}
	
	Q $$$OK
}

}
