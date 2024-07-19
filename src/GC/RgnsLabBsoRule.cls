/// 
Class GC.RgnsLabBsoRule Extends Ens.Rule.Definition
{

Parameter RuleAssistClass = "EnsLib.HL7.MsgRouter.RuleAssist";

XData RuleDefinition [ XMLNamespace = "http://www.intersystems.com/rule" ]
{
<ruleDefinition alias="" context="EnsLib.HL7.MsgRouter.RoutingEngine" production="PROD.PROD">
<ruleSet name="" effectiveBegin="" effectiveEnd="">
<rule name="Archive">
<when condition="1">
<send transform="" target="File.O.ArchiveInbound"></send>
</when>
</rule>
<rule name="Hold QCPR Nbrs" disabled="false">
<constraint name="docCategory" value="22.RegLab"></constraint>
<constraint name="docName" value="ORU_R01,ORM_O01,ORM_O02"></constraint>
<when condition="LENGTH(HL7.{OBR:2.1})=7">
<send transform="" target="Bso.P.RgnsHOLDORU"></send>
<return></return>
</when>
</rule>
<rule name="RemoveTestPatients" disabled="false">
<constraint name="source" value="Bs.P.RgnsLab"></constraint>
<when condition="(Substring(HL7.{PID:PatientIdentifierList(1).ID},2,7) In &quot;507424,515173,600000,600001&quot;)">
<return></return>
</when>
</rule>
<rule name="micro result" disabled="false">
<constraint name="docCategory" value="22.RegLab"></constraint>
<constraint name="docName" value="ORU_R01"></constraint>
<when condition="(Contains(HL7.{OBR:24},&quot;MB&quot;))">
<send transform="GC.RegLab2CernerORUmb" target="HL7.O.CrRgnsLabOrmOru"></send>
<return></return>
</when>
</rule>
<rule name="copath result" disabled="false">
<constraint name="docCategory" value="22.RegLab"></constraint>
<constraint name="docName" value="ORU_R01"></constraint>
<when condition="(Contains(HL7.{OBR:24},&quot;CoPath&quot;))">
<send transform="GC.RegLab2CernerORUCoPath" target="HL7.O.CrRgnsLabOrmOru"></send>
<return></return>
</when>
</rule>
<rule name="blood bank" disabled="false">
<constraint name="docCategory" value="22.RegLab"></constraint>
<constraint name="docName" value="ORU_R01"></constraint>
<when condition="(Contains(HL7.{OBR:24},&quot;BB&quot;))">
<send transform="GC.RegLab2CernerORUbb" target="HL7.O.CrRgnsLabOrmOru"></send>
<return></return>
</when>
</rule>
<rule name="" disabled="false">
<constraint name="docCategory" value="22.RegLab"></constraint>
<constraint name="docName" value="ORU_R01"></constraint>
<when condition="(Contains(HL7.{OBR:24},&quot;SO&quot;))">
<send transform="GC.RegLab2CernerORUSendOut" target="HL7.O.CrRgnsLabOrmOru"></send>
<return></return>
</when>
</rule>
<rule name="Specific Tests thru SendOut Logic" disabled="false">
<constraint name="docCategory" value="22.RegLab"></constraint>
<constraint name="docName" value="ORU_R01"></constraint>
<when condition="HL7.{OBR:4.2}=&quot;TBGLD&quot;">
<send transform="GC.RegLab2CernerORUSendOut" target="HL7.O.CrRgnsLabOrmOru"></send>
<return></return>
</when>
</rule>
<rule name="GenLab" disabled="false">
<constraint name="docCategory" value="22.RegLab"></constraint>
<constraint name="docName" value="ORU_R01"></constraint>
<when condition="1">
<send transform="GC.RegLab2CernerORUGenlab" target="HL7.O.CrRgnsLabOrmOru"></send>
<return></return>
</when>
</rule>
<rule name="PreReg from Cerner" disabled="false">
<constraint name="source" value="Bs.P.RgnsLab"></constraint>
<constraint name="docCategory" value="231.Cerner"></constraint>
<constraint name="docName" value="ADT_A01,ADT_A02,ADT_A03,ADT_A04,ADT_A06,ADT_A05,ADT_A07,ADT_A08,ADT_A09,ADT_A10,ADT_A11,ADT_A12,ADT_A13,ADT_A15,ADT_A14,ADT_A16,ADT_A17,ADT_A21,ADT_A22,ADT_A24,ADT_A23,ADT_A25,ADT_A26,ADT_A28,ADT_A29,ADT_A31,ADT_A34,ADT_A35,ADT_A38,ADT_A44,ADT_ADSC"></constraint>
<when condition="(Document.{PV1:PatientType} StartsWith &quot;Pre&quot;)">
<return></return>
</when>
</rule>
<rule name="ADTs from Cerner" disabled="false">
<constraint name="source" value="Bs.P.RgnsLab"></constraint>
<constraint name="docCategory" value="231.Cerner"></constraint>
<constraint name="docName" value="ADT_A01,ADT_A02,ADT_A03,ADT_A04,ADT_A05,ADT_A06,ADT_A07,ADT_A08,ADT_A09,ADT_A10,ADT_A11,ADT_A12,ADT_A13,ADT_A14,ADT_A15,ADT_A16,ADT_A17,ADT_A21,ADT_A22,ADT_A23,ADT_A24,ADT_A25,ADT_A26,ADT_A28,ADT_A29,ADT_A31,ADT_ADSC,ADT_A44,ADT_A38,ADT_A35,ADT_A34"></constraint>
<when condition="1">
<send transform="GC.Cerner2RegionsLabADT" target="HL7.O.RgnsLabAdtOrm"></send>
<return></return>
</when>
</rule>
<rule name="Pathology ORM TO Regions" disabled="false">
<constraint name="source" value="Bs.P.RgnsLab"></constraint>
<constraint name="docCategory" value="231.Cerner"></constraint>
<constraint name="docName" value="ORM_O01"></constraint>
<when condition="HL7.{ORCgrp(1).OBRgrp.OBR:24}=&quot;AP&quot;">
<send transform="GC.Cerner2RegLabORMpath" target="HL7.O.RgnsLabAdtOrm"></send>
<return></return>
</when>
</rule>
<rule name="Micro ORM TO Regions" disabled="false">
<constraint name="source" value="Bs.P.RgnsLab"></constraint>
<constraint name="docCategory" value="231.Cerner"></constraint>
<constraint name="docName" value="ORM_O01"></constraint>
<when condition="HL7.{ORCgrp(1).OBRgrp.OBR:24}=&quot;Micro&quot;">
<send transform="GC.Cerner2RegLabORMmicro" target="HL7.O.RgnsLabAdtOrm"></send>
<return></return>
</when>
</rule>
<rule name="Blood Bank ORM TO Regions" disabled="false">
<constraint name="source" value="Bs.P.RgnsLab"></constraint>
<constraint name="docCategory" value="231.Cerner"></constraint>
<constraint name="docName" value="ORM_O01"></constraint>
<when condition="HL7.{ORCgrp(1).OBRgrp.OBR:24}=&quot;BB&quot;">
<send transform="GC.Cerner2RegLabORMblood" target="HL7.O.RgnsLabAdtOrm"></send>
<return></return>
</when>
</rule>
<rule name="" disabled="false">
<constraint name="source" value="Bs.P.RgnsLab"></constraint>
<constraint name="docCategory" value="231.Cerner"></constraint>
<constraint name="docName" value="ORM_O01"></constraint>
<when condition="HL7.{ORCgrp(1).OBRgrp.OBR:4.2}=&quot;RMTST&quot;">
<send transform="GC.Cerner2RegLabORMProcRMTST" target="HL7.O.RgnsLabAdtOrm"></send>
<return></return>
</when>
</rule>
<rule name="GenLab ORM TO Regions" disabled="false">
<constraint name="source" value="Bs.P.RgnsLab"></constraint>
<when condition="1">
<send transform="GC.Cerner2RegLabORMgenlab" target="HL7.O.RgnsLabAdtOrm"></send>
</when>
</rule>
<rule name="LabInitialedORM or results FROM Regions" disabled="false">
<constraint name="source" value="HL7.S.RgnsLabOrmOru"></constraint>
<constraint name="docCategory" value="22.RegLab"></constraint>
<constraint name="docName" value="ORM_O01,ORM_O02"></constraint>
<when condition="(Document.{OBR:DiagnosticservicesectionID}!=&quot;Z&quot;)||(Document.{OBR:4.2} In &quot;BFT,CSFT&quot;)">
<send transform="GC.RegLab2CernerORM" target="HL7.O.CrRgnsLabOrmOru"></send>
</when>
</rule>
</ruleSet>
</ruleDefinition>
}

}
