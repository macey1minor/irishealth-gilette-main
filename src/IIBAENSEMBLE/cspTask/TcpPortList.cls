/// Copyright 2007 by Inland Imaging Business Associates
Class IIBAENSEMBLE.cspTask.TcpPortList Extends %CSP.Page [ ProcedureBlock ]
{

ClassMethod html()
{
    w "<table width=800px><tr><td width=700px>"
    w "TCP Port List "
	w "</td><td>"
	//w "<Input Type='Button' Name='btnTcpPorList' Value='View' onclick='location.href=""/csp/"_$ZNSPACE_"/IIBASupport.csp?PageName=TcpPortList""'>"
	s tDefaultApp = $SYSTEM.CSP.GetDefaultApp($NAMESPACE)
	w "<Input Type='Button' Name='btnTcpPorList' id='btnTcpPorList' Value='View' onclick='window.open("""_tDefaultApp_"/IIBAENSEMBLE.Zen.TcpPortReport.cls"")'>"
	w "</td></tr></table>"
}

}
