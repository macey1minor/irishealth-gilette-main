/// Copyright 2007 by Inland Imaging Business Associates
Class IIBAENSEMBLE.Operation.TCPOperation Extends EnsLib.HL7.Operation.TCPOperation
{

/// Log a Warning if the reply MSA:1 ControlId does not match the original message's control ID
Parameter WarnACKControlId As %Boolean = 0;

}
