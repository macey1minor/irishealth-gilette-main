/// Copyright 2007 by Inland Imaging Business Associates
Class IIBAENSEMBLE.csp.Mobile Extends %CSP.Page [ ProcedureBlock ]
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
	function Initialize()
	{

	}
  -->
   </script>
  >
}

ClassMethod html()
{
    //
    
    &html<
    <img src="customimages/IIBA_logo.jpg">

	<H2>ENSEMBLE</H2>
	<p>
	<a
	 href="IIBASupportDetail.csp?PageName=MobileSystem"
	 target="_parent">Mobile Interface Status</a>
	<p>
	<a
	 href="IIBASupportDetail.csp?PageName=MobileAlert"
	 target="_parent">Mobile Alert Management</a>
	
	<p>
	>
	do ##class(IIBAENSEMBLE.csp.components).troubleditems(0)
}

}
