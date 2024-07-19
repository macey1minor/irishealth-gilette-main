Include Ensemble
///docs
Class XF.Base.Helper [ Abstract ]
{

ClassMethod GenerateLogMessage(revert As %Boolean = 0, type As %String = "", code As %String = "", originalMessage As %String = "") As %String
{
    set error = {}
    set error.revert = revert
    set error.type = type 
    set error.code = code 
    set error.originalMessage = originalMessage
    return error.%ToJSON()
}

ClassMethod GenerateLogMessageFromStatus(revert As %Boolean = 0, type As %String = "", sc As %Status = "") As %String [ CodeMode = expression ]
{
..GenerateLogMessage(revert,type,$System.Status.GetErrorCodes(sc),$System.Status.GetErrorText(sc))
}

ClassMethod ValidateCodes(source As HS.SDA3.Container, ByRef pWarnings) As %Status
{
    set status = $$$OK
    set site=$G(^||ZLookup("ActiveSite"))
    set patientValidationLevel = ##class(Ens.Util.FunctionSet).Lookup(site,"PatientCodesValidationLevel","None")
    set encounterValidationLevel = ##class(Ens.Util.FunctionSet).Lookup(site,"EncounterCodesValidationLevel","None")
    set diagnosisValidationLevel = ##class(Ens.Util.FunctionSet).Lookup(site,"DiagnosisCodesValidationLevel","None")
    set (sdaTypeArr,sdaType,sdaObj,tSC) = ""
    while source.GetNextSDA(.sdaType, .sdaObj, .tSC) {
        set sdaTypeArr(sdaType)=""
        if ((sdaType="Patient") && (patientValidationLevel'="None")){
            set status = $System.Status.AppendStatus(status,..ValidatePatientCodes(sdaObj,site))
        }elseif ((sdaType="Encounter") && (encounterValidationLevel'="None")){
            set status = $System.Status.AppendStatus(status,..ValidateEncounterCodes(sdaObj,site))
        }elseif ((sdaType="Diagnosis") && (diagnosisValidationLevel'="None")){
            set status = $System.Status.AppendStatus(status,..ValidateDiagnosisCodes(sdaObj,site))
        }
    }
    // SDA won't have Encounter section if Encounter Number is missing
    If ('$d(sdaTypeArr("Encounter"))) && (encounterValidationLevel'="None") && (##class(Ens.Util.FunctionSet).Lookup(site,"EncounterNumber",0)){
        set status = $System.Status.AppendStatus(status,$$$ERROR($$$GeneralError, "Encounter: No encounter number (sda - EncounterNumber )"))
    }

    quit ..ConvertErrorsToWarnings(status, site, patientValidationLevel, encounterValidationLevel, diagnosisValidationLevel, .pWarnings)
}

ClassMethod ConvertErrorsToWarnings(status As %Status, site As %String, patientValidationLevel As %String, encounterValidationLevel As %String, diagnosisValidationLevel As %String, ByRef pWarnings) As %Status
{
    set finalStatus = $$$OK
    set pWarnings = 0
    if ($$$ISERR(status)) {
        set errors = $System.Status.GetErrorCodes(status)
        for i=1:1:$L(errors,","){
            set statusText = $System.Status.GetOneStatusText(status,i)
            if ((statusText["Diagnosis:")&&(diagnosisValidationLevel="Alert")){
                //Set the warning
                set pWarnings=pWarnings+1
                set pWarnings(pWarnings)=site _ ": "_statusText
            } elseif ((statusText["Encounter:")&&(encounterValidationLevel="Alert")){
                set pWarnings=pWarnings+1
                set pWarnings(pWarnings)=site _ ": "_statusText
            } elseif ((statusText["Patient:")&&(patientValidationLevel="Alert")){
                set pWarnings=pWarnings+1
                set pWarnings(pWarnings)=site _ ": "_statusText
            } else {
                //add error to final status
                set finalStatus = $System.Status.AppendStatus(finalStatus,$$$ERROR($P(errors,",",i),site _ ": "_ statusText))
            }
        }
    }
    for k=1:1:pWarnings {
        $$$LOGALERT(pWarnings(k))
    }
    quit finalStatus
}

ClassMethod ValidateDiagnosisCodes(source As HS.SDA3.SuperClass, site As %String) As %Status
{
    set status = $$$OK
    if ((source.Diagnosis'="")&&(source.Diagnosis.SDACodingStandard'="")){
        if (##class(HS.FHIR.DTL.Util.Lookup).Code("SDA3", "vR4", "HS.SDA3.Diagnosis", "diagnosis-code-system",source.Diagnosis)=""
        && ##class(Ens.Util.FunctionSet).Lookup(site,"DiagnosisConditionSystem",0)){
            set status = $System.Status.AppendStatus(status,$$$ERROR($$$GeneralError, "Diagnosis: No diagnosis/condition coding system (sda - SDACodingStandard) mapping found for provided value: " _ source.Diagnosis.SDACodingStandard))
        }
    }
    quit status
}

ClassMethod ValidateEncounterCodes(source As HS.SDA3.SuperClass, site As %String) As %Status
{
    set status = $$$OK
    if (source.AdmissionType'=""){
        if (##class(HS.FHIR.DTL.Util.Lookup).Code("SDA3", "vR4", "HS.SDA3.CodeTableDetail.AdmissionType", "fhir",source.AdmissionType)=""
        && ##class(Ens.Util.FunctionSet).Lookup(site,"EncounterType",0)){
            set status = $System.Status.AppendStatus(status,$$$ERROR($$$GeneralError, "Encounter: No encounter type (sda - AdmissionType) mapping found for provided value: " _ source.AdmissionType.Code))
        }
    }
    if (source.EncounterType'=""){
        if (##class(HS.FHIR.DTL.Util.Lookup).Code("SDA3", "vR4", "HS.SDA3.CodeTableDetail.EncounterType", "v3-ActEncounterCode",source.EncounterType)=""
        && ##class(Ens.Util.FunctionSet).Lookup(site,"EncounterClass",0)){
            set status = $System.Status.AppendStatus(status,$$$ERROR($$$GeneralError, "Encounter: No encounter class (sda - EncounterType ) mapping found for provided value: " _ source.EncounterType))
        }
    }
    quit status
}

ClassMethod ValidatePatientCodes(source As HS.SDA3.SuperClass, site As %String) As %Status
{
    set status = $$$OK
    if ((source.Race'="")&&(source.Race.Code'="")){
        if (##class(HS.FHIR.DTL.Util.Lookup).Code("SDA3", "vR4", "HS.SDA3.CodeTableDetail.Race", "fhir",source.Race)="" 
        && ##class(Ens.Util.FunctionSet).Lookup(site,"PatientRace",0)){
            set status = $System.Status.AppendStatus(status,$$$ERROR($$$GeneralError, "Patient: No race mapping found for provided value: " _ source.Race.Code))
        }
    }
    if ((source.EthnicGroup'="")&&(source.EthnicGroup.Code'="")){
        if (##class(HS.FHIR.DTL.Util.Lookup).Code("SDA3", "vR4", "HS.SDA3.CodeTableDetail.EthnicGroup", "fhir",source.EthnicGroup)=""
        && ##class(Ens.Util.FunctionSet).Lookup(site,"PatientEthnicGroup",0)){
            set status = $System.Status.AppendStatus(status,$$$ERROR($$$GeneralError, "Patient: No ethnic group mapping found for provided value: " _ source.EthnicGroup.Code))
        }
    }
    if ((source.EthnicGroup'="")&&(source.BirthGender.Code'="")){
        if (##class(HS.FHIR.DTL.Util.Lookup).Code("SDA3", "vR4", "HS.SDA3.CodeTableDetail.Gender", "administrative-gender|4.0.1",source.BirthGender)=""
        && ##class(Ens.Util.FunctionSet).Lookup(site,"PatientBirthGender",0)){
            set status = $System.Status.AppendStatus(status,$$$ERROR($$$GeneralError, "Patient: No patient gender/birth sex mapping found for provided value: " _ source.BirthGender.Code))
        }
    }
    if ((source.SupportContacts.Count()>0)){
        for i=1:1:source.SupportContacts.Count() {
            set supportContact = source.SupportContacts.GetAt(i)
            if ((supportContact.Gender'="")&&(supportContact.Gender.Code'="")){ 
                if (##class(HS.FHIR.DTL.Util.Lookup).Code("SDA3", "vR4", "HS.SDA3.CodeTableDetail.Gender", "administrative-gender|4.0.1",supportContact.Gender)=""
                && ##class(Ens.Util.FunctionSet).Lookup(site,"PatientSupportContactBirthGender",0)){
                    set status = $System.Status.AppendStatus(status,$$$ERROR($$$GeneralError, "Patient: No support contact gender/birth sex mapping found for provided value: " _ supportContact.Gender.Code))
                }
            }
        }
    }
    Quit status
}

/// Perform a code lookup to see if the value in the source value set has a
/// match in the target value set. If so, return that value.
/// from - The source schema, eg. "SDA3"
/// to - The target schema, eg. "vSTU3"
/// sourceValueSet - The value set for the source coded field. For FHIR, it will be the valueset. For SDA,
/// it will be the CodeTable name if it is a CodeTable object. If it's a string, it will be the element
/// name. Eg. FHIR - "allergy-clinical-status" and for SDA3 "HS.SDA3.CodeTableDetail.AllergyCategory"
/// or "HS.SDA3.CarePlan:Status"
/// targetValueSet - same as above for the target
/// value - The coded element to be looked up. It can either be a primitive string or a coded object in
/// either schema. If it's a list, the first value to return something will be used. Both code and description
/// values will be used for the lookup as SDA3 documentation differs between which one is used.
/// MDL - custom implementation of HS.FHIR.DTL.Util.Lookup.Code() to provide set defaults if a
/// mapping is not found in the look up table
ClassMethod Code(from As %String, to As %String, sourceValueSet As %String, targetValueSet As %String, value = "") As %String
{
#dim pair As %String = ##class(HS.FHIR.DTL.Util.Lookup).Code(from, to, sourceValueSet, targetValueSet, value)
    if (pair = ""){
        set pair = ##class(HS.FHIR.DTL.Util.Lookup).Code(from, to, sourceValueSet, targetValueSet, "DefaultUnknown")
    }
   
    quit pair
}

}
