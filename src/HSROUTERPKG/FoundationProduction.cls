Class HSROUTERPKG.FoundationProduction Extends Ens.Production
{

XData ProductionDefinition
{
<Production Name="HSROUTERPKG.FoundationProduction" TestingEnabled="true" LogGeneralTraceEvents="false">
  <Description></Description>
  <ActorPoolSize>2</ActorPoolSize>
  <Item Name="HS.Test.Service" Category="" ClassName="HS.Test.Service" PoolSize="0" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
  </Item>
  <Item Name="HS.Util.Trace.Operations" Category="" ClassName="HS.Util.Trace.Operations" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
  </Item>
  <Item Name="Ens.Activity.Operation.Local" Category="" ClassName="Ens.Activity.Operation.Local" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
  </Item>
  <Item Name="AIKEN.Adt.ToEdgeOperation" Category="Aiken" ClassName="EnsLib.HL7.Operation.TCPOperation" PoolSize="1" Enabled="false" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
    <Setting Target="Host" Name="InactivityTimeout">0</Setting>
  </Item>
  <Item Name="zzUAT.TCP.AIKEN_ADT" Category="Aiken" ClassName="EnsLib.HL7.Operation.TCPOperation" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
    <Setting Target="Host" Name="InactivityTimeout">0</Setting>
  </Item>
  <Item Name="AIKEN.Adt.HL7TcpService" Category="Aiken" ClassName="EnsLib.HL7.Service.TCPService" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
    <Setting Target="Host" Name="InactivityTimeout">0</Setting>
    <Setting Target="Host" Name="MessageSchemaCategory">2.5.1</Setting>
  </Item>
  <Item Name="STOP.Router" Category="" ClassName="EnsLib.HL7.MsgRouter.RoutingEngine" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
    <Setting Target="Host" Name="BusinessRuleName">BCBSSC.Router.HL7.STOP.Rule</Setting>
    <Setting Target="Host" Name="InactivityTimeout">0</Setting>
  </Item>
  <Item Name="HS.IHE.XDR.Source.Operations" Category="" ClassName="HS.IHE.XDR.Source.Operations" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
    <Setting Target="Host" Name="InactivityTimeout">0</Setting>
  </Item>
  <Item Name="BCBSSC.Router.IHE.Process.ProvideRouter" Category="" ClassName="BCBSSC.Router.IHE.Process.ProvideRouter" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
    <Setting Target="Host" Name="TargetOperation"></Setting>
    <Setting Target="Host" Name="InactivityTimeout">0</Setting>
    <Setting Target="Host" Name="TargetService"></Setting>
  </Item>
  <Item Name="HS.IHE.XDR.Recipient.Services" Category="" ClassName="HS.IHE.XDR.Recipient.Services" PoolSize="0" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
    <Setting Target="Host" Name="InactivityTimeout">0</Setting>
    <Setting Target="Host" Name="ProvideAndRegisterTarget">BCBSSC.Router.IHE.Process.ProvideRouter</Setting>
  </Item>
  <Item Name="Eligibility.CES.Cloud.FileService" Category="Eligibility,Cloud,CES" ClassName="BCBSSC.HL7.Service.HL7S3Inbound" PoolSize="1" Enabled="false" Foreground="false" Comment="" LogTraceEvents="true" Schedule="">
    <Setting Target="Adapter" Name="BlobNamePrefix">eligibility_employee_test/</Setting>
    <Setting Target="Host" Name="TargetConfigNames">Eligibility.File.PassthroughOperation</Setting>
    <Setting Target="Adapter" Name="BlobNamePattern">*.csv</Setting>
    <Setting Target="Adapter" Name="DeleteAfterDownload">1</Setting>
  </Item>
  <Item Name="MUSC.Adt.ToEdgeOperation" Category="MUSC" ClassName="EnsLib.HL7.Operation.TCPOperation" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
    <Setting Target="Host" Name="InactivityTimeout">0</Setting>
    <Setting Target="Adapter" Name="StayConnected">60</Setting>
    <Setting Target="Adapter" Name="IPAddress">awslqcomhsegvip.aws.bcbssc.com</Setting>
  </Item>
  <Item Name="MUSC.TMCSDischarge" Category="MUSC,TMCS" ClassName="BCBSSC.Router.TMCS.TMCSDischargeProcess" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
    <Setting Target="Host" Name="TargetConfigNames">TMCSHttpOut</Setting>
    <Setting Target="Host" Name="PatientIdLocation">ZEX:3</Setting>
    <Setting Target="Host" Name="AuthorizationNumberLocation">IN1:14</Setting>
    <Setting Target="Host" Name="InactivityTimeout">0</Setting>
  </Item>
  <Item Name="Eligibility.FEP.Cloud.FileService" Category="Eligibility,Cloud,FEP" ClassName="BCBSSC.HL7.Service.HL7S3Inbound" PoolSize="1" Enabled="false" Foreground="false" Comment="" LogTraceEvents="true" Schedule="">
    <Setting Target="Adapter" Name="BlobNamePrefix">eligibility_fep/</Setting>
    <Setting Target="Host" Name="TargetConfigNames">Eligibility.File.PassthroughOperation</Setting>
    <Setting Target="Adapter" Name="BlobNamePattern">*.csv</Setting>
  </Item>
  <Item Name="Eligibility.File.PassthroughOperation" Category="Eligibility,CES,FEP,PAI" ClassName="EnsLib.File.PassthroughOperation" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
    <Setting Target="Host" Name="Filename">%f</Setting>
    <Setting Target="Adapter" Name="FilePath">/hs-router/sys/mgr/Temp/EligibilityFiles/</Setting>
  </Item>
  <Item Name="Eligibility.File.PassthroughService" Category="Eligibility,CES,FEP,PAI" ClassName="EnsLib.File.PassthroughService" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
    <Setting Target="Adapter" Name="FileSpec">*</Setting>
    <Setting Target="Host" Name="TargetConfigNames">Eligibility.Passthrough.ToEdge</Setting>
  </Item>
  <Item Name="Eligibility.PAI.Cloud.FileService" Category="Eligibility,Cloud,PAI" ClassName="BCBSSC.HL7.Service.HL7S3Inbound" PoolSize="1" Enabled="false" Foreground="false" Comment="" LogTraceEvents="true" Schedule="">
    <Setting Target="Adapter" Name="BlobNamePrefix">eligibility_pai</Setting>
    <Setting Target="Host" Name="TargetConfigNames">Eligibility.File.PassthroughOperation</Setting>
    <Setting Target="Adapter" Name="BlobNamePattern">*.csv</Setting>
  </Item>
  <Item Name="Eligibility.Passthrough.ToEdge" Category="Eligibility,CES,FEP,PAI" ClassName="EnsLib.TCP.PassthroughOperation" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
  </Item>
  <Item Name="Member.SafetyCheck.Deterministic" Category="MUSC,MemberCheck" ClassName="BCBSSC.Member.DetSafetyCheck" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="true" Schedule="">
    <Setting Target="Host" Name="TraceOperations">*FULL*</Setting>
    <Setting Target="Host" Name="MinMatchPercentage">30</Setting>
  </Item>
  <Item Name="Member.SafetyCheck.Probabilistic" Category="MUSC,MemberCheck" ClassName="BCBSSC.Member.ProbSafetyCheck" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
  </Item>
  <Item Name="BadMessageHandler" Category="Avalon,BEAUFORT,CES,CPC,Liberty,TMCS,Tidelands" ClassName="EnsLib.HL7.Operation.FileOperation" PoolSize="1" Enabled="true" Foreground="false" Comment="Discarded Messages for non-Member data" LogTraceEvents="false" Schedule="">
    <Setting Target="Adapter" Name="FilePath">/tmp/purge</Setting>
  </Item>
  <Item Name="AVALON.LABCORP.Oru.HL7S3Service" Category="Avalon" ClassName="BCBSSC.HL7.Service.HL7S3Inbound" PoolSize="1" Enabled="false" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
    <Setting Target="Host" Name="MessageSchemaCategory">2.5.1</Setting>
    <Setting Target="Host" Name="TargetConfigNames">AVALON.LABCORP.Oru.MemberCheckHL7</Setting>
    <Setting Target="Adapter" Name="BlobNamePattern">*</Setting>
    <Setting Target="Adapter" Name="BlobNamePrefix">avalon</Setting>
    <Setting Target="Adapter" Name="BucketName">bcbssc-depintersystems-dev-curated</Setting>
    <Setting Target="Adapter" Name="StorageRegion">us-east-1</Setting>
    <Setting Target="Adapter" Name="DeleteAfterDownload">0</Setting>
    <Setting Target="Host" Name="InactivityTimeout">0</Setting>
  </Item>
  <Item Name="AVALON.LABCORP.Oru.MemberCheckHL7" Category="Avalon" ClassName="BCBSSC.Router.HL7.MemberEligibilityCheckProcess" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="true" Schedule="">
    <Setting Target="Host" Name="RecordSourceLocation">MSH:4</Setting>
    <Setting Target="Host" Name="TargetConfigNames">Member.SafetyCheck</Setting>
    <Setting Target="Host" Name="AssigningAuthorityLocation">MSH:5</Setting>
    <Setting Target="Host" Name="DiscardedMessageTarget">BadMessageHandler</Setting>
    <Setting Target="Host" Name="EligibleMessageTarget">AVALON.Adt.ToEdgeOperation</Setting>
    <Setting Target="Host" Name="DeterministicCheckTarget">Member.SafetyCheck.Deterministic</Setting>
    <Setting Target="Host" Name="ProbablisticCheckTarget">Member.SafetyCheck.Probabilistic</Setting>
    <Setting Target="Host" Name="DateOfServiceLocation">OBR:7</Setting>
    <Setting Target="Host" Name="SubscriberNumberLocation">PID:2.1</Setting>
    <Setting Target="Host" Name="TMCSAuthTarget"></Setting>
    <Setting Target="Host" Name="InactivityTimeout">0</Setting>
  </Item>
  <Item Name="AVALON.Adt.ToEdgeOperation" Category="Avalon" ClassName="EnsLib.HL7.Operation.TCPOperation" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
    <Setting Target="Host" Name="InactivityTimeout">0</Setting>
  </Item>
  <Item Name="MUSC.Adt.HL7S3Service" Category="MUSC" ClassName="BCBSSC.HL7.Service.HL7S3Inbound" PoolSize="1" Enabled="false" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
    <Setting Target="Host" Name="MessageSchemaCategory">2.5.1</Setting>
    <Setting Target="Host" Name="TargetConfigNames">MUSC.Adt.MemberCheckHL7</Setting>
    <Setting Target="Adapter" Name="BlobNamePattern">*testing*</Setting>
    <Setting Target="Adapter" Name="BlobNamePrefix">musc</Setting>
    <Setting Target="Adapter" Name="StorageRegion">us-east-1</Setting>
    <Setting Target="Adapter" Name="DeleteAfterDownload">1</Setting>
    <Setting Target="Adapter" Name="BucketName">bcbssc-depintersystems-stage-curated</Setting>
    <Setting Target="Host" Name="InactivityTimeout">0</Setting>
  </Item>
  <Item Name="MUSC.Adt.MemberCheckHL7" Category="MUSC,MemberCheck" ClassName="BCBSSC.Router.HL7.MemberEligibilityCheckProcess" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="true" Schedule="">
    <Setting Target="Host" Name="RecordSourceLocation">MSH:4</Setting>
    <Setting Target="Host" Name="AssigningAuthorityLocation">IN1:4</Setting>
    <Setting Target="Host" Name="DiscardedMessageTarget">MUSC.BadMessageHandler</Setting>
    <Setting Target="Host" Name="EligibleMessageTarget">MUSC.Adt.ToEdgeOperation</Setting>
    <Setting Target="Host" Name="DeterministicCheckTarget">Member.SafetyCheck.Deterministic</Setting>
    <Setting Target="Host" Name="ProbablisticCheckTarget">Member.SafetyCheck.Probabilistic</Setting>
    <Setting Target="Host" Name="TMCSAuthTarget">MUSC.TMCSDischarge</Setting>
    <Setting Target="Host" Name="InactivityTimeout">0</Setting>
    <Setting Target="Host" Name="ReportingTarget">Member.MemberReportHTTPOperation</Setting>
    <Setting Target="Host" Name="MessageSource">MUSC</Setting>
  </Item>
  <Item Name="MUSC.BadMessageHandler" Category="MUSC,TMCS" ClassName="EnsLib.HL7.Operation.FileOperation" PoolSize="1" Enabled="true" Foreground="false" Comment="Discarded Messages for non-Member data" LogTraceEvents="false" Schedule="">
    <Setting Target="Adapter" Name="FilePath">/tmp/purge/musc</Setting>
    <Setting Target="Host" Name="InactivityTimeout">0</Setting>
  </Item>
  <Item Name="SPARTANBURG.Adt.HL7S3Service" Category="SPARTANBURG" ClassName="BCBSSC.HL7.Service.HL7S3Inbound" PoolSize="1" Enabled="false" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
    <Setting Target="Host" Name="MessageSchemaCategory">2.5.1</Setting>
    <Setting Target="Host" Name="TargetConfigNames">SPARTANBURG.Adt.MemberCheckHL7</Setting>
    <Setting Target="Adapter" Name="BlobNamePattern">*</Setting>
    <Setting Target="Adapter" Name="BlobNamePrefix">DEP00004A/Inbound</Setting>
    <Setting Target="Adapter" Name="StorageRegion">us-east-1</Setting>
    <Setting Target="Adapter" Name="DeleteAfterDownload">1</Setting>
    <Setting Target="Host" Name="InactivityTimeout">0</Setting>
    <Setting Target="Adapter" Name="BucketName">bcbssc-depintersystems-stage-curated</Setting>
  </Item>
  <Item Name="SPARTANBURG.Adt.MemberCheckHL7" Category="SPARTANBURG" ClassName="BCBSSC.Router.HL7.MemberEligibilityCheckProcess" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="true" Schedule="">
    <Setting Target="Host" Name="RecordSourceLocation">MSH:4</Setting>
    <Setting Target="Host" Name="AssigningAuthorityLocation">IN1:4</Setting>
    <Setting Target="Host" Name="DiscardedMessageTarget">SPARTANBURG.BadMessageHandler</Setting>
    <Setting Target="Host" Name="EligibleMessageTarget">SPARTANBURG.Adt.ToEdgeOperation</Setting>
    <Setting Target="Host" Name="DeterministicCheckTarget">Member.SafetyCheck.Deterministic</Setting>
    <Setting Target="Host" Name="TMCSAuthTarget">SPARTANBURG.TMCSDischarge</Setting>
    <Setting Target="Host" Name="InactivityTimeout">0</Setting>
    <Setting Target="Host" Name="ProbablisticCheckTarget">Member.SafetyCheck.Probabilistic</Setting>
    <Setting Target="Host" Name="ReportingTarget">Member.MemberReportHTTPOperation</Setting>
    <Setting Target="Host" Name="MessageSource">SPARTANBURG</Setting>
  </Item>
  <Item Name="SPARTANBURG.BadMessageHandler" Category="SPARTANBURG" ClassName="EnsLib.HL7.Operation.FileOperation" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
    <Setting Target="Adapter" Name="FilePath">/tmp/purge/spartanburg</Setting>
    <Setting Target="Host" Name="Filename">%f_%Q%!+(_a)</Setting>
  </Item>
  <Item Name="SPARTANBURG.Adt.ToEdgeOperation" Category="SPARTANBURG" ClassName="EnsLib.HL7.Operation.TCPOperation" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
    <Setting Target="Adapter" Name="IPAddress">awslqcomhsegvip.aws.bcbssc.com</Setting>
  </Item>
  <Item Name="SPARTANBURG.TMCSDischarge" Category="SPARTANBURG" ClassName="BCBSSC.Router.TMCS.TMCSDischargeProcess" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
    <Setting Target="Host" Name="TargetConfigNames">TMCSHttpOut</Setting>
    <Setting Target="Host" Name="SubscriberId">ZEX:2</Setting>
    <Setting Target="Host" Name="PatientIdLocation">ZEX:3</Setting>
    <Setting Target="Host" Name="AuthorizationNumberLocation">IN1:14</Setting>
  </Item>
  <Item Name="PRISMA.BadMessageHandler" Category="PRISMA" ClassName="EnsLib.HL7.Operation.FileOperation" PoolSize="1" Enabled="true" Foreground="false" Comment="Discarded Messages for non-Member data" LogTraceEvents="false" Schedule="">
    <Setting Target="Adapter" Name="FilePath">/tmp/purge/prisma</Setting>
    <Setting Target="Host" Name="InactivityTimeout">0</Setting>
  </Item>
  <Item Name="PRISMA.Adt.MemberCheckHL7" Category="MemberCheck,PRISMA" ClassName="BCBSSC.Router.HL7.MemberEligibilityCheckProcess" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="true" Schedule="">
    <Setting Target="Host" Name="RecordSourceLocation">MSH:4</Setting>
    <Setting Target="Host" Name="AssigningAuthorityLocation">IN1:2.2</Setting>
    <Setting Target="Host" Name="DiscardedMessageTarget">PRISMA.BadMessageHandler</Setting>
    <Setting Target="Host" Name="EligibleMessageTarget">PRISMA.Adt.ToEdgeOperation</Setting>
    <Setting Target="Host" Name="DeterministicCheckTarget">Member.SafetyCheck.Deterministic</Setting>
    <Setting Target="Host" Name="TMCSAuthTarget">PRISMA.TMCSDischarge</Setting>
    <Setting Target="Host" Name="InactivityTimeout">0</Setting>
    <Setting Target="Host" Name="ProbablisticCheckTarget">Member.SafetyCheck.Probabilistic</Setting>
    <Setting Target="Host" Name="ReportingTarget">Member.MemberReportHTTPOperation</Setting>
    <Setting Target="Host" Name="MessageSource">PRISMA</Setting>
  </Item>
  <Item Name="PRISMA.Adt.ToEdgeOperation" Category="PRISMA" ClassName="EnsLib.HL7.Operation.TCPOperation" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
    <Setting Target="Host" Name="InactivityTimeout">0</Setting>
  </Item>
  <Item Name="PRISMA.Adt.HL7S3Service" Category="PRISMA" ClassName="BCBSSC.HL7.Service.HL7S3Inbound" PoolSize="1" Enabled="false" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
    <Setting Target="Adapter" Name="BlobNamePattern">*PrismaHealth_to_BCBSofSC_ADT_2023-10-02-16-00-50-850*</Setting>
    <Setting Target="Adapter" Name="BlobNamePrefix">prisma/adt</Setting>
    <Setting Target="Host" Name="TargetConfigNames">PRISMA.Adt.MemberCheckHL7</Setting>
    <Setting Target="Host" Name="MessageSchemaCategory">2.5.1</Setting>
    <Setting Target="Host" Name="InactivityTimeout">0</Setting>
    <Setting Target="Adapter" Name="DeleteAfterDownload">1</Setting>
  </Item>
  <Item Name="PRISMA.TMCSDischarge" Category="TMCS,PRISMA" ClassName="BCBSSC.Router.TMCS.TMCSDischargeProcess" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
    <Setting Target="Host" Name="TargetConfigNames">TMCSHttpOut</Setting>
    <Setting Target="Host" Name="PatientIdLocation">ZEX:3</Setting>
    <Setting Target="Host" Name="AuthorizationNumberLocation">IN1:14</Setting>
    <Setting Target="Host" Name="InactivityTimeout">0</Setting>
  </Item>
  <Item Name="Member.MemberReportHTTPOperation" Category="Liberty,MUSC,MemberCheck" ClassName="BCBSSC.Router.Member.MemberReportHTTPOperation" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="true" Schedule="">
    <Setting Target="Adapter" Name="HTTPPort">443</Setting>
    <Setting Target="Adapter" Name="SSLConfig">HS_Services_SSL</Setting>
    <Setting Target="Adapter" Name="URL">/eg/api/healthshare-rest/egmember/report</Setting>
    <Setting Target="Adapter" Name="SSLCheckServerIdentity">0</Setting>
    <Setting Target="Host" Name="InactivityTimeout">0</Setting>
  </Item>
  <Item Name="TMCSHttpOut" Category="TMCS,MUSC" ClassName="BCBSSC.Router.TMCS.TMCSHTTPOperation" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
    <Setting Target="Adapter" Name="HTTPPort">443</Setting>
    <Setting Target="Adapter" Name="SSLCheckServerIdentity">0</Setting>
    <Setting Target="Adapter" Name="SSLConfig">HS_Services_SSL</Setting>
    <Setting Target="Adapter" Name="URL">/eg/csp/healthshare/tmcs/rest/api/authorize/discharge</Setting>
    <Setting Target="Host" Name="InactivityTimeout">0</Setting>
  </Item>
  <Item Name="LIBERTY.CCDA.S3Inbound" Category="Liberty" ClassName="BCBSSC.HL7.Service.HL7S3Inbound" PoolSize="1" Enabled="false" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
    <Setting Target="Host" Name="TargetConfigNames">LIBERTY.AddHeader.Process</Setting>
    <Setting Target="Adapter" Name="BlobNamePattern">*</Setting>
    <Setting Target="Adapter" Name="BlobNamePrefix">libertydrs</Setting>
    <Setting Target="Adapter" Name="StorageRegion">us-east-1</Setting>
    <Setting Target="Adapter" Name="DeleteAfterDownload">1</Setting>
  </Item>
  <Item Name="LIBERTY.AddHeader.Process" Category="Liberty" ClassName="BCBSSC.IHE.XDSb.AddHeader.Process" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
    <Setting Target="Host" Name="FacilityID">LIBERTY</Setting>
    <Setting Target="Host" Name="ReplaceFacilityOID">0</Setting>
    <Setting Target="Host" Name="TargetConfigNames">LIBERTY.MemberCheckCCD.Process</Setting>
  </Item>
  <Item Name="LIBERTY.MemberCheckCCD.Process" Category="Liberty" ClassName="BCBSSC.Router.IHE.MemberEligibilityCheckProcessXML" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
    <Setting Target="Host" Name="TargetConfigNames">Member.SafetyCheck.Deterministic</Setting>
    <Setting Target="Host" Name="RecordSource">LIBERTY</Setting>
    <Setting Target="Host" Name="DateOfServiceLocation">/hl7:ClinicalDocument/hl7:component/hl7:structuredBody/hl7:component/hl7:section[hl7:templateId/@root='2.16.840.1.113883.10.20.22.2.22.1']/hl7:entry/hl7:encounter/hl7:effectiveTime/@value</Setting>
    <Setting Target="Host" Name="AssigningAuthorityLocation">/hl7:ClinicalDocument/hl7:component/hl7:structuredBody/hl7:component/hl7:section[hl7:templateId/@root='2.16.840.1.113883.10.20.22.2.18']/hl7:entry/hl7:act/hl7:entryRelationship/hl7:act/hl7:performer/hl7:assignedEntity/hl7:representedOrganization/hl7:name</Setting>
    <Setting Target="Host" Name="DiscardedMessageTarget">LIBERTY.BadMessageHandler</Setting>
    <Setting Target="Host" Name="EligibleMessageTarget">LIBERTY.DocumentSource.Operations</Setting>
    <Setting Target="Host" Name="DeterministicCheckTarget">Member.SafetyCheck.Deterministic</Setting>
    <Setting Target="Host" Name="ProbablisticCheckTarget">Member.SafetyCheck.Probabilistic</Setting>
    <Setting Target="Host" Name="ReportingTarget">Member.MemberReportHTTPOperation</Setting>
    <Setting Target="Host" Name="MessageSource">LIBERTY</Setting>
  </Item>
  <Item Name="LIBERTY.BadMessageHandler" Category="Liberty" ClassName="EnsLib.XML.Object.Operation.FileOperation" PoolSize="1" Enabled="true" Foreground="false" Comment="Discarded Messages for non-Member data" LogTraceEvents="false" Schedule="">
    <Setting Target="Adapter" Name="FilePath">/tmp/purge/liberty</Setting>
  </Item>
  <Item Name="LIBERTY.DocumentSource.Operations" Category="Liberty" ClassName="HS.IHE.XDSb.DocumentSource.Operations" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
    <Setting Target="Host" Name="XDSbRepositoryServiceName">BUS.XDSb.Repository</Setting>
  </Item>
  <Item Name="BCBSSC.Router.MACKEY.Recipient.Services" Category="" ClassName="BCBSSC.Router.MACKEY.Recipient.Services" PoolSize="0" Enabled="true" Foreground="true" Comment="" LogTraceEvents="true" Schedule="">
    <Setting Target="Host" Name="InactivityTimeout">0</Setting>
    <Setting Target="Host" Name="ProvideAndRegisterTarget">BCBSSC.Router.IHE.Process.ProvideRouter</Setting>
    <Setting Target="Host" Name="UseSAMLUserName">0</Setting>
    <Setting Target="Host" Name="TraceOperations">*FULL*</Setting>
    <Setting Target="Host" Name="ArchiveIO">1</Setting>
  </Item>
  <Item Name="AIKEN.Adt.ToEdgeDEVDPT" Category="Aiken" ClassName="EnsLib.HL7.Operation.TCPOperation" PoolSize="1" Enabled="false" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
    <Setting Target="Host" Name="InactivityTimeout">0</Setting>
  </Item>
  <Item Name="PRISMA.CCDA.S3Inbound" Category="PRISMA,Liberty" ClassName="BCBSSC.HL7.Service.HL7S3Inbound" PoolSize="1" Enabled="false" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
    <Setting Target="Host" Name="TargetConfigNames">PRISMA.AddHeader.Process</Setting>
    <Setting Target="Adapter" Name="BlobNamePattern">*.xml</Setting>
    <Setting Target="Adapter" Name="BlobNamePrefix">prisma</Setting>
    <Setting Target="Adapter" Name="StorageRegion">us-east-1</Setting>
    <Setting Target="Adapter" Name="DeleteAfterDownload">0</Setting>
  </Item>
  <Item Name="PRISMA.MemberCheckCCD.Process" Category="Liberty,PRISMA" ClassName="BCBSSC.Router.IHE.MemberEligibilityCheckProcessXML" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
    <Setting Target="Host" Name="TargetConfigNames">Member.SafetyCheck.Deterministic</Setting>
    <Setting Target="Host" Name="RecordSource">PRISMA</Setting>
    <Setting Target="Host" Name="DateOfServiceLocation">/hl7:ClinicalDocument/hl7:component/hl7:structuredBody/hl7:component/hl7:section[hl7:templateId/@root='2.16.840.1.113883.10.20.22.2.22.1']/hl7:entry/hl7:encounter/hl7:effectiveTime/hl7:high/@value</Setting>
    <Setting Target="Host" Name="AssigningAuthorityLocation">/hl7:ClinicalDocument/hl7:component/hl7:structuredBody/hl7:component/hl7:section[hl7:templateId/@root='2.16.840.1.113883.10.20.22.2.18']/hl7:entry/hl7:act/hl7:entryRelationship/hl7:act/hl7:performer/hl7:assignedEntity/hl7:representedOrganization/hl7:name</Setting>
    <Setting Target="Host" Name="DiscardedMessageTarget">PRISMA.BadMessageHandler</Setting>
    <Setting Target="Host" Name="EligibleMessageTarget">PRISMA.DocumentSource.Operations</Setting>
    <Setting Target="Host" Name="DeterministicCheckTarget">Member.SafetyCheck.Deterministic</Setting>
    <Setting Target="Host" Name="ProbablisticCheckTarget">Member.SafetyCheck.Probabilistic</Setting>
    <Setting Target="Host" Name="MessageSource">PRISMA</Setting>
  </Item>
  <Item Name="PRISMA.AddHeader.Process" Category="Liberty,PRISMA" ClassName="BCBSSC.IHE.XDSb.AddHeader.Process" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
    <Setting Target="Host" Name="FacilityID">PRISMA</Setting>
    <Setting Target="Host" Name="ReplaceFacilityOID">0</Setting>
    <Setting Target="Host" Name="TargetConfigNames">PRISMA.MemberCheckCCD.Process</Setting>
  </Item>
  <Item Name="PRISMA.DocumentSource.Operations" Category="Liberty,PRISMA" ClassName="HS.IHE.XDSb.DocumentSource.Operations" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
    <Setting Target="Host" Name="XDSbRepositoryServiceName">BUS.XDSb.Repository</Setting>
  </Item>
  <Item Name="BEAUFORT.Adt.MemberCheckHL7" Category="BEAUFORT" ClassName="BCBSSC.Router.HL7.MemberEligibilityCheckProcess" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="true" Schedule="">
    <Setting Target="Host" Name="RecordSourceLocation">MSH:4</Setting>
    <Setting Target="Host" Name="AssigningAuthorityLocation">IN1:2.1</Setting>
    <Setting Target="Host" Name="DiscardedMessageTarget">BEAUFORT.BadMessageHandler</Setting>
    <Setting Target="Host" Name="EligibleMessageTarget">BEAUFORT.Adt.ToEdgeOperation</Setting>
    <Setting Target="Host" Name="DeterministicCheckTarget">Member.SafetyCheck.Deterministic</Setting>
    <Setting Target="Host" Name="TMCSAuthTarget">BEAUFORT.TMCSDischarge</Setting>
    <Setting Target="Host" Name="MessageSource">BEAUFORT</Setting>
    <Setting Target="Host" Name="ProbablisticCheckTarget">Member.SafetyCheck.Probabilistic</Setting>
    <Setting Target="Host" Name="ReportingTarget">Member.MemberReportHTTPOperation</Setting>
  </Item>
  <Item Name="BEAUFORT.Adt.ToEdgeOperation" Category="BEAUFORT" ClassName="EnsLib.HL7.Operation.TCPOperation" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
  </Item>
  <Item Name="Beaufort.Adt.HL7S3Service" Category="BEAUFORT" ClassName="BCBSSC.HL7.Service.HL7S3Inbound" PoolSize="1" Enabled="false" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
    <Setting Target="Host" Name="MessageSchemaCategory">2.5.1</Setting>
    <Setting Target="Host" Name="TargetConfigNames">BEAUFORT.Adt.MemberCheckHL7</Setting>
    <Setting Target="Adapter" Name="BlobNamePattern">*</Setting>
    <Setting Target="Adapter" Name="BlobNamePrefix">beaufort</Setting>
    <Setting Target="Adapter" Name="DeleteAfterDownload">1</Setting>
    <Setting Target="Adapter" Name="StorageRegion">us-east-1</Setting>
  </Item>
  <Item Name="BEAUFORT.TMCSDischarge" Category="TMCS,BEAUFORT" ClassName="BCBSSC.Router.TMCS.TMCSDischargeProcess" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
    <Setting Target="Host" Name="TargetConfigNames">TMCSHttpOut</Setting>
    <Setting Target="Host" Name="PatientIdLocation">ZEX:3</Setting>
    <Setting Target="Host" Name="AuthorizationNumberLocation">IN1:14.1</Setting>
    <Setting Target="Host" Name="InactivityTimeout">0</Setting>
  </Item>
  <Item Name="BEAUFORT.BadMessageHandler" Category="BEAUFORT" ClassName="EnsLib.HL7.Operation.FileOperation" PoolSize="1" Enabled="true" Foreground="false" Comment="Discarded Messages for non-Member data" LogTraceEvents="false" Schedule="">
    <Setting Target="Adapter" Name="FilePath">/tmp/purge/beaufort</Setting>
  </Item>
  <Item Name="Tidelands.TMCSDischarge" Category="Tidelands" ClassName="BCBSSC.Router.TMCS.TMCSDischargeProcess" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
    <Setting Target="Host" Name="TargetConfigNames">TMCSHttpOut</Setting>
    <Setting Target="Host" Name="InactivityTimeout">0</Setting>
  </Item>
  <Item Name="Tidelands.BadMessageHandler" Category="Tidelands" ClassName="EnsLib.HL7.Operation.FileOperation" PoolSize="1" Enabled="true" Foreground="false" Comment="Discarded Messages for non-Member data" LogTraceEvents="false" Schedule="">
    <Setting Target="Adapter" Name="FilePath">/tmp/purge/tidelands</Setting>
    <Setting Target="Host" Name="InactivityTimeout">0</Setting>
  </Item>
  <Item Name="Tidelands.Adt.HL7S3Service" Category="Tidelands" ClassName="BCBSSC.HL7.Service.HL7S3Inbound" PoolSize="1" Enabled="false" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
    <Setting Target="Host" Name="MessageSchemaCategory">2.5.1</Setting>
    <Setting Target="Host" Name="TargetConfigNames">Tidelands.Adt.MemberCheckHL7</Setting>
    <Setting Target="Adapter" Name="BucketName">bcbssc-depintersystems-stage-curated</Setting>
    <Setting Target="Adapter" Name="BlobNamePattern">*</Setting>
    <Setting Target="Adapter" Name="BlobNamePrefix">DEP00006A/Inbound</Setting>
    <Setting Target="Adapter" Name="DeleteAfterDownload">1</Setting>
    <Setting Target="Adapter" Name="StorageRegion">us-east-1</Setting>
    <Setting Target="Host" Name="InactivityTimeout">0</Setting>
  </Item>
  <Item Name="Tidelands.Adt.MemberCheckHL7" Category="Tidelands" ClassName="BCBSSC.Router.HL7.MemberEligibilityCheckProcess" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
    <Setting Target="Host" Name="EligibleMessageTarget">Tidelands.Adt.ToEdgeOperation</Setting>
    <Setting Target="Host" Name="DiscardedMessageTarget">Tidelands.BadMessageHandler</Setting>
    <Setting Target="Host" Name="SubscriberNumberLocation">IN1:36</Setting>
    <Setting Target="Host" Name="AssigningAuthorityLocation">IN1:4</Setting>
    <Setting Target="Host" Name="ProbablisticCheckTarget">Member.SafetyCheck.Probabilistic</Setting>
    <Setting Target="Host" Name="MessageSource">TIDELANDS</Setting>
    <Setting Target="Host" Name="DeterministicCheckTarget">Member.SafetyCheck.Deterministic</Setting>
    <Setting Target="Host" Name="ReportingTarget">Member.MemberReportHTTPOperation</Setting>
    <Setting Target="Host" Name="TMCSAuthTarget">Tidelands.TMCSDischarge</Setting>
    <Setting Target="Host" Name="InactivityTimeout">0</Setting>
  </Item>
  <Item Name="Tidelands.Adt.ToEdgeOperation" Category="Tidelands" ClassName="EnsLib.HL7.Operation.TCPOperation" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
    <Setting Target="Adapter" Name="IPAddress">awslqcomhsegvip.aws.bcbssc.com</Setting>
    <Setting Target="Adapter" Name="Port">45002</Setting>
    <Setting Target="Host" Name="InactivityTimeout">0</Setting>
  </Item>
  <Item Name="MACKEY.DocumentSource.Operations" Category="Liberty" ClassName="HS.IHE.XDSb.DocumentSource.Operations" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
    <Setting Target="Host" Name="XDSbRepositoryServiceName">BUS.XDSb.Repository</Setting>
  </Item>
  <Item Name="HS.Util.SOAPClient.Operations" Category="" ClassName="HS.Util.SOAPClient.Operations" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
  </Item>
</Production>
}

}
