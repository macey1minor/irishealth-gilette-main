/// Copyright 2007 by Inland Imaging Business Associates
Class IIBAENSEMBLE.csp.MobileNmspSelect Extends %CSP.Page [ ProcedureBlock ]
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
	<!--
	function Initialize() {
	  

	}
	
	function NewPage() {
		
		
		newNMSP=document.getElementById("Namespace").value;
		
		if ( newNMSP != '' ) {
			namespaceurl='/csp/'+newNMSP+'/IIBASupport.csp?PageName=Mobile';
			self.document.location=namespaceurl;
		}
	}
  -->
   </script>
  >
}

ClassMethod html()
{
    //
    
    
    //W "<img src='customimages/IIBA_logo.jpg'>"

	W "<H2>ENSEMBLE</H2>"
	W "<p>"
	w "<form id='namespaceSelection'>"
	W "Select Namespace"
	W "<p>"

	Set tNS = $O(^%SYS("Ensemble","InstalledNamespace",""))
	W "<select name='Namespace' id='Namespace' ><option></option>"
	While (tNS '= "") {
		
		Set tURL = "/csp/"_tNS_"/IIBASupport.csp?PageName=Mobile"
		//if tNS="IIBAENSEMBLE" {Set tURL = "/csp/healthshare/IIBASupport/"_%request.PageName}  //This is a temporary exception until we turn off IIBAENSEMBLE
		if ##class(%SYSTEM.Security).Check("NS_"_tNS) = "READ,WRITE,USE" {
			//&html<<option value="#(tURL)#" >#($ZCVT(tNS,"O","HTML"))#>
			W "<option value='",$ZCVT(tNS,"O","HTML"),"' >",$ZCVT(tNS,"O","HTML"),"</option>"
			//W "<a href='",tURL,"'>",tNS,"</a><BR>"
		}
		Set tNS = $O(^%SYS("Ensemble","InstalledNamespace",tNS))
	}
	W "</select>"
	w "&nbsp;&nbsp;&nbsp;<input type='button' value='select' onclick='NewPage();'>"
	// w "<BR>",%request.URL,"<BR>"
	
	do ##class(IIBAENSEMBLE.csp.components).troubleditems(0)
}

}
