/// Copyright 2007 by Inland Imaging Business Associates
Class IIBAENSEMBLE.csp.TEST Extends %CSP.Page [ ProcedureBlock ]
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
  	function testCall(){
		#call(..testCall())#;
		alert('Hello')
	}
	alert('Hello')
   </script>
  >
}

ClassMethod html()
{
    //
    
    &html<
    <input type="button" Value="Click" onclick="testCall()"/>
   
	>
}

ClassMethod testCall() As %String
{
 h 5
 s f = ##class(%File).%New("c:\hl7\out\outext.txt")
 d f.Open("WSN")
 d f.WriteLine("newline")
 d f.Close()
 s f = ""
 Quit "ok"
}

}
