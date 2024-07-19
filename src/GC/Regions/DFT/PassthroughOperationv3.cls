/// Accepts objects of type Ens.StreamContainer and saves the encapsulated stream data to a file using the File OutboundAdapter.
Class GC.Regions.DFT.PassthroughOperationv3 Extends Ens.BusinessOperation [ ProcedureBlock, System = 4 ]
{

Parameter ADAPTER = "GC.Shared.FileOutboundAdapter";

// "EnsLib.OutboundFileAdapter";

Parameter INVOCATION = "Queue";

// Configurable properties

Property TargetFilePath As %String(MAXLEN = 256);

Property TargetFileName As %String(MAXLEN = 256);

Parameter SETTINGS = "TargetFilePath,TargetFileName";

Method OnMessage(pRequest As GC.Regions.DFT.ChargeDFTv3, Output pResponse As Ens.Response) As %Status
{
	//Quit:'$IsObject(pRequest.Stream) $$$ERROR($$$EnsErrGeneral,"No Stream contained in StreamContainer Request")
	//Set tFilename=..Adapter.CreateTimestamp(##class(%File).GetFilename(pRequest.OriginalFilename),..Filename)
	//Set tSC=..Adapter.PutStream(tFilename, pRequest.Stream)
	//Do pRequest.%Save() ; re-save in case PutStream() optimization changed the Stream filename
	//Quit tSC
   set tSC = $$$OK
                                                                                                                                                                                    set writer=##class(%XML.Writer).%New()
   set writer.Indent=0 // for flattened file
   set writer.ReferencesInline = 1
   
   //if $$$ISERR(status) do $System.Status.DisplayError(status) quit $$$ERROR() 
   //Do writer.OutputToString()
   //Do writer.RootObject(pRequest)
   
   //set xmlmsgOrig = writer.GetXMLString()
    
   Do writer.OutputToString()
   Do writer.RootObject(pRequest)
   
   set xmlmsgOrig = writer.GetXMLString()
   // added to flatten out file remove if you want it the other way.
   //set xmlmsg = $Translate(xmlmsgOrig,$char(13,10),"") // take out nl
   //set xmlmsg = xmlmsg_$char(10) // add back in the last nl
   // set tabchar
   set ztabchar=$char(09)
   
   set xmlmsg = $Translate(xmlmsgOrig,$char(13),"") // take out nl
   set xmlmsg = $Translate(xmlmsgOrig,$char(10),"") // take out nl
   set xmlmsg = xmlmsg_$char(13) // add back in the last nl   
   
   set tmpqte=$char(34)
   set tmpqtecomma=$char(34)_$char(44)
   //remove xml header and trailer - output is appended
   set xmlmsga=$REPLACE(xmlmsg,"</ChargeDFTv3>","")
   set xmlmsgb=$REPLACE(xmlmsga,"<ChargeDFTv3>","")
   set xmlmsga=$REPLACE(xmlmsgb,"<MRN>",tmpqte)
   set xmlmsgb=$REPLACE(xmlmsga,"</MRN>",tmpqtecomma)
   set xmlmsga=$REPLACE(xmlmsgb,"<Name>",tmpqte)
   set xmlmsgb=$REPLACE(xmlmsga,"</Name>",tmpqtecomma)
   set xmlmsga=$REPLACE(xmlmsgb,"<Fin>",tmpqte)
   set xmlmsgb=$REPLACE(xmlmsga,"</Fin>",tmpqtecomma)
   set xmlmsga=$REPLACE(xmlmsgb,"<MSHMRNFind>",tmpqte)
   set xmlmsgb=$REPLACE(xmlmsga,"</MSHMRNFind>",tmpqtecomma)
   set xmlmsga=$REPLACE(xmlmsgb,"<TransactionID>",tmpqte_ztabchar)
   set xmlmsgb=$REPLACE(xmlmsga,"</TransactionID>",tmpqtecomma)
   set xmlmsga=$REPLACE(xmlmsgb,"<TransactionDate>",tmpqte)
   set xmlmsgb=$REPLACE(xmlmsga,"</TransactionDate>",tmpqtecomma)   
   set xmlmsga=$REPLACE(xmlmsgb,"<PostingDate>",tmpqte)
   set xmlmsgb=$REPLACE(xmlmsga,"</PostingDate>",tmpqtecomma)
   set xmlmsga=$REPLACE(xmlmsgb,"<TransactionType>",tmpqte)
   set xmlmsgb=$REPLACE(xmlmsga,"</TransactionType>",tmpqtecomma) 
   set xmlmsga=$REPLACE(xmlmsgb,"<CDM>",tmpqte)
   set xmlmsgb=$REPLACE(xmlmsga,"</CDM>",tmpqtecomma)
   set xmlmsga=$REPLACE(xmlmsgb,"<Quantity>",tmpqte)
   set xmlmsgb=$REPLACE(xmlmsga,"</Quantity>",tmpqtecomma)
   set xmlmsga=$REPLACE(xmlmsgb,"<AmountExtended>",tmpqte)
   set xmlmsgb=$REPLACE(xmlmsga,"</AmountExtended>",tmpqtecomma)
   set xmlmsga=$REPLACE(xmlmsgb,"<AmountUnit>",tmpqte)
   set xmlmsgb=$REPLACE(xmlmsga,"</AmountUnit>",tmpqtecomma)
   set xmlmsga=$REPLACE(xmlmsgb,"<DeptCode>",tmpqte)
   set xmlmsgb=$REPLACE(xmlmsga,"</DeptCode>",tmpqtecomma)
   set xmlmsga=$REPLACE(xmlmsgb,"<PerformingDoc>",tmpqte)
   set xmlmsgb=$REPLACE(xmlmsga,"</PerformingDoc>",tmpqtecomma)
   set xmlmsga=$REPLACE(xmlmsgb,"<OrderedByDoc>",tmpqte)
   set xmlmsgb=$REPLACE(xmlmsga,"</OrderedByDoc>",tmpqtecomma)
   set xmlmsga=$REPLACE(xmlmsgb,"<CPT>",tmpqte)
   set xmlmsgb=$REPLACE(xmlmsga,"</CPT>",tmpqtecomma)
   set xmlmsga=$REPLACE(xmlmsgb,"<CPTModifiers>",tmpqte)
   set xmlmsgb=$REPLACE(xmlmsga,"</CPTModifiers>",tmpqtecomma)
   set xmlmsga=$REPLACE(xmlmsgb,"<HL7MessageDate>",tmpqte)
   set xmlmsgb=$REPLACE(xmlmsga,"</HL7MessageDate>",tmpqtecomma)
   set xmlmsga=$REPLACE(xmlmsgb,"<RegionsCDMDesc>",tmpqte)
   set xmlmsgb=$REPLACE(xmlmsga,"</RegionsCDMDesc>",tmpqtecomma)
   set xmlmsga=$REPLACE(xmlmsgb,"<RegionsCDMDept>",tmpqte)
   set xmlmsgb=$REPLACE(xmlmsga,"</RegionsCDMDept>",tmpqtecomma)
   set xmlmsga=$REPLACE(xmlmsgb,"<RegionsCDMRevCode>",tmpqte)
   set xmlmsgb=$REPLACE(xmlmsga,"</RegionsCDMRevCode>",tmpqtecomma)
   set xmlmsga=$REPLACE(xmlmsgb,"<RegionsCDMStatus>",tmpqte)
   set xmlmsgb=$REPLACE(xmlmsga,"</RegionsCDMStatus>",tmpqtecomma)
   set xmlmsga=$REPLACE(xmlmsgb,"<RegionsSentCPT>",tmpqte)
   set xmlmsgb=$REPLACE(xmlmsga,"</RegionsSentCPT>",tmpqtecomma)
   set xmlmsga=$REPLACE(xmlmsgb,"<RegionsSentCPTMod>",tmpqte)
   set xmlmsgb=$REPLACE(xmlmsga,"</RegionsSentCPTMod>",tmpqtecomma)
   
   set xmlmsga=$REPLACE(xmlmsgb,"<MSHFINFind>",tmpqte)
   set xmlmsgb=$REPLACE(xmlmsga,"</MSHFINFind>",tmpqtecomma)
   set xmlmsga=$REPLACE(xmlmsgb,"<FINFindCount>",tmpqte)
   set xmlmsgb=$REPLACE(xmlmsga,"</FINFindCount>",tmpqtecomma)
   set xmlmsga=$REPLACE(xmlmsgb,"<PrimInsName>",tmpqte)
   set xmlmsgb=$REPLACE(xmlmsga,"</PrimInsName>",tmpqtecomma)
   set xmlmsga=$REPLACE(xmlmsgb,"<PrimInsType>",tmpqte)
   set xmlmsgb=$REPLACE(xmlmsga,"</PrimInsType>",tmpqtecomma)
   
   set xmlmsga=$REPLACE(xmlmsgb,"<FinDifference>",tmpqte)
   set xmlmsgb=$REPLACE(xmlmsga,"</FinDifference>",tmpqtecomma)
   set xmlmsga=$REPLACE(xmlmsgb,"<OriginalFinSent>",tmpqte)
   set xmlmsgb=$REPLACE(xmlmsga,"</OriginalFinSent>",tmpqtecomma)
   set xmlmsga=$REPLACE(xmlmsgb,"<FinDiffLookup>",tmpqte)
   set xmlmsgb=$REPLACE(xmlmsga,"</FinDiffLookup>",tmpqte)
   
   set hdg1=("MRN,Name,Fin,EnsembleMRNSearch,Transaction ID,Tran Date,Posting Date,Type,CDM,Qty,Extended Amount,Unit Price,Dept,")
   set hdg2=("Performed By,Ordered By,CPT,Modifier,HL7 Date,Regions Desc,Regions Dept,Regions Rev Code,CDM Status,Sent CPT,Sent Modifier,")
   set hdg3=("EnsembleFINSearch,FIN Count,Primary Insurance,Insurance Type,Fin Difference,Original Fin SentFin Diff Lookup")
   set hdg4=(hdg1_hdg2_hdg3)

   // write header if file does not exist
   set tSCx=..Adapter.ExistsCustom(..TargetFilePath_..TargetFileName)
   // if file does not exist - returns 0, if exists returns 1
   if tSCx=0 {
       set tSC=..Adapter.PutLineCustom(..TargetFilePath_..TargetFileName,hdg4)
   }

   //append file
   set tSC=..Adapter.PutLineCustom(..TargetFilePath_..TargetFileName,xmlmsgb)

   Quit tSC
}

XData MessageMap
{
<MapItems>
  <MapItem MessageType="GC.Regions.DFT.ChargeDFTv3">
    <Method>OnMessage</Method>
  </MapItem>
</MapItems>
}

}
