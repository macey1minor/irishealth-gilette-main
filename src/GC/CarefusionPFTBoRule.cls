/// 
Class GC.CarefusionPFTBoRule Extends Ens.Rule.Definition
{

Parameter RuleAssistClass = "EnsLib.HL7.MsgRouter.RuleAssist";

XData RuleDefinition [ XMLNamespace = "http://www.intersystems.com/rule" ]
{
<ruleDefinition alias="" context="EnsLib.HL7.MsgRouter.RoutingEngine" production="PROD.PROD">
<ruleSet name="" effectiveBegin="" effectiveEnd="">
<rule name="block specific order status" disabled="false">
<constraint name="docCategory" value="231.Cerner"></constraint>
<constraint name="docName" value="ORM_O01"></constraint>
<when condition="HL7.{ORCgrp(1).ORC:1}=&quot;SC&quot;||HL7.{ORCgrp(1).ORC:1}=&quot;CM&quot;">
<return></return>
</when>
</rule>
<rule name="Orders To Carefusion" disabled="false">
<constraint name="docCategory" value="231.Cerner"></constraint>
<constraint name="docName" value="ORM_O01"></constraint>
<when condition="1">
<send transform="GC.Cerner2CarefusionPFTOrm" target="HL7.O.CarefusionPFTOrm"></send>
<return></return>
</when>
</rule>
<rule name="Report Only-NO Return" disabled="false">
<constraint name="docCategory" value="231.Cerner"></constraint>
<constraint name="docName" value="ORU_R01"></constraint>
<when condition="1">
<send transform="GC.Carefusion2CernerBase64" target="HL7.O.CrCarefusionPFTOru"></send>
</when>
</rule>
<rule name="Discrete Results Only" disabled="false">
<constraint name="docCategory" value="231.Cerner"></constraint>
<constraint name="docName" value="ORU_R01"></constraint>
<when condition="1">
<send transform="GC.Carefusion2CernerDicrete" target="HL7.O.CrCarefusionPFTOru"></send>
<return></return>
</when>
</rule>
</ruleSet>
</ruleDefinition>
}

}
