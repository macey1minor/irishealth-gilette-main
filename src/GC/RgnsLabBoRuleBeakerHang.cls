/// 
Class GC.RgnsLabBoRuleBeakerHang Extends Ens.Rule.Definition
{

Parameter RuleAssistClass = "EnsLib.HL7.MsgRouter.RuleAssist";

XData RuleDefinition [ XMLNamespace = "http://www.intersystems.com/rule" ]
{
<ruleDefinition alias="" context="EnsLib.HL7.MsgRouter.RoutingEngine" production="">
<ruleSet name="" effectiveBegin="" effectiveEnd="">
<rule name="SC Inprocess for LIO" disabled="false">
<constraint name="docCategory" value="251.Regions"></constraint>
<constraint name="docName" value="ORM_O01"></constraint>
<when condition="((HL7.{ORCgrp(1).ORC:1}=&quot;SC&quot;)&amp;&amp;(HL7.{ORCgrp(1).OBRuniongrp.OBRunion.OBR:2.1}=HL7.{ORCgrp(1).OBRuniongrp.OBRunion.OBR:3.1}))">
<send transform="GC.RegLab2CernerBkrORMLIOsc" target="HL7.O.CrRgnsLabBeakerOru"></send>
<return></return>
</when>
</rule>
</ruleSet>
</ruleDefinition>
}

}
