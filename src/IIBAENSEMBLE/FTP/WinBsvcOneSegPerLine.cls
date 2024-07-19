/// Copyright 2007 by Inland Imaging Business Associates
Class IIBAENSEMBLE.FTP.WinBsvcOneSegPerLine Extends IIBAENSEMBLE.FTP.WindowsFTPService
{

Parameter ADAPTER = "IIBAENSEMBLE.FTP.InboundAdapter";

/// End-Segment marker character(s)
Property SegTerminator As %String [ InitialExpression = {$C(10)} ];

//Property SegTerminator As %String [ InitialExpression = {$C(13,10)} ];

}
