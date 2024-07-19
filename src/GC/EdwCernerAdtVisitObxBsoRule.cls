/// 
Class GC.EdwCernerAdtVisitObxBsoRule Extends Ens.Rule.Definition
{

Parameter RuleAssistClass = "EnsLib.HL7.MsgRouter.RuleAssist";

XData RuleDefinition [ XMLNamespace = "http://www.intersystems.com/rule" ]
{
<ruleDefinition alias="" context="EnsLib.HL7.MsgRouter.RoutingEngine" production="CERT.CERT">
<ruleSet name="" effectiveBegin="" effectiveEnd="">
<rule name="" disabled="true">
<constraint name="docCategory" value="231.Cerner"></constraint>
<constraint name="docName" value="ADT_A01,ADT_A03,ADT_A04,ADT_A05,ADT_A08,ADT_A13,ADT_A28,ADT_A31"></constraint>
<when condition="(Document.{MSH:SequenceNumber}&gt;0 )  ">
<send transform="EDW.dtl.Cerner2EdwADTVisitOBXLoop" target="Bso.P.EdwCernerAdtVisitObx"></send>
<send transform="EDW.dtl.Cerner2EdwADTVisitOBX" target="SQL.O.EdwVisitOBX"></send>
<return></return>
</when>
</rule>
</ruleSet>
</ruleDefinition>
}

}
