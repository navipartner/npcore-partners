codeunit 6059997 "NPR HL Send Members"
{
    Access = Internal;
    TableNo = "NPR Nc Task";

    trigger OnRun()
    begin
        Rec.TestField("Table No.", Rec."Record ID".TableNo);
        case Rec."Table No." of
            Database::"NPR HL HeyLoyalty Member":
                SendMember(Rec);
        end;
    end;

    var
        HLIntegrationEvents: Codeunit "NPR HL Integration Events";

    local procedure SendMember(var NcTask: Record "NPR Nc Task")
    var
        HLMember: Record "NPR HL HeyLoyalty Member";
        HLIntegrationMgt: Codeunit "NPR HL Integration Mgt.";
        HLMemberMgt: Codeunit "NPR HL Member Mgt. Impl.";
        HeyLoyaltyMemberJToken: JsonToken;
        HeyLoyaltyResponse: JsonToken;
        UrlQueryString: Text;
        Success: Boolean;
    begin
        Clear(NcTask."Data Output");
        Clear(NcTask.Response);
        ClearLastError();
        Success := false;

        if PrepareMemberUpdateRequest(NcTask, HLMember, UrlQueryString) then
            case NcTask.Type of
                NcTask.Type::Insert:
                    Success := HLIntegrationMgt.InvokeMemberCreateRequest(NcTask, UrlQueryString, HeyLoyaltyResponse);
                NcTask.Type::Modify:
                    Success := HLIntegrationMgt.InvokeMemberUpdateRequest(NcTask, HLMember."HeyLoyalty Id", UrlQueryString, HeyLoyaltyResponse);
                NcTask.Type::Delete:
                    Success := HLIntegrationMgt.InvokeMemberDeleteRequest(NcTask, HLMember."HeyLoyalty Id");
            end;
        NcTask.Modify();
        Commit();

        if not Success then
            Error(GetLastErrorText());

        if HLIntegrationMgt.InvokeGetHLMemberByID(HLMemberMgt.GetHeyLoyaltyIDFromResponse(HeyLoyaltyResponse, HLMember."HeyLoyalty Id"), HeyLoyaltyMemberJToken) then
            HLMemberMgt.UpdateHLMemberWithDataFromHeyLoyalty(HLMember, HeyLoyaltyMemberJToken, NcTask.Type = NcTask.Type::Delete)
        else
            HLMemberMgt.UpdateHLMemberWithDataFromHeyLoyalty(HLMember, HeyLoyaltyResponse, true);
    end;

    [TryFunction]
    local procedure PrepareMemberUpdateRequest(var NcTask: Record "NPR Nc Task"; var HLMember: Record "NPR HL HeyLoyalty Member"; var UrlQueryString: Text)
    var
        RecRef: RecordRef;
        UrlParametersJObject: JsonObject;
        OStream: OutStream;
        HeyLoyaltyMemberIdEmptyErr: Label 'HeyLoyalty Id must be specified for %1', Comment = '%1 - Member record id';
    begin
        RecRef.Get(NcTask."Record ID");
        RecRef.SetTable(HLMember);

        if (HLMember."Unsubscribed at" <> 0DT) and (HLMember."E-Mail News Letter" = HLMember."E-Mail News Letter"::YES) then  //re-subscribe
            HLMember."HeyLoyalty Id" := '';
        if HLMember."HeyLoyalty Id" = '' then
            HLMember."HeyLoyalty Id" := GetHeyLoyaltyMemberID(HLMember, false);
        if HLMember."HeyLoyalty Id" = '' then begin
            case NcTask.Type of
                NcTask.Type::Modify:
                    NcTask.Type := NcTask.Type::Insert;
                NcTask.Type::Delete:
                    Error(HeyLoyaltyMemberIdEmptyErr, Format(HLMember.RecordId));
            end;
        end else
            if NcTask.Type = NcTask.Type::Insert then
                NcTask.Type := NcTask.Type::Modify;

        UrlQueryString := '';
        if NcTask.Type <> NcTask.Type::Delete then begin
            AddMemberInfo(HLMember, NcTask.Type = NcTask.Type::Insert, UrlParametersJObject);
            UrlQueryString := GenerateUrlQueryStringFromParameterJObject(UrlParametersJObject);
        end;

        NcTask."Data Output".CreateOutStream(OStream);
        OStream.WriteText(StrSubstNo('%1%2', HLMember."HeyLoyalty Id", UrlQueryString));
    end;

    local procedure AddMemberInfo(var HLMember: Record "NPR HL HeyLoyalty Member"; NewMember: Boolean; var UrlParametersJObject: JsonObject)
    var
        HLIntegrationMgt: Codeunit "NPR HL Integration Mgt.";
        HLFieldID: Text[50];
    begin
        HLMember.Validate("Country Code");  //throw an error, if there's no Country mapping setup
        HLMember.Validate("Store Code");  //throw an error, if there's no Cs Store mapping setup

        UrlParametersJObject.Add('firstname', HLMember."First Name");
        UrlParametersJObject.Add('lastname', HLMember."Last Name");
        UrlParametersJObject.Add('email', HLMember."E-Mail Address");
        UrlParametersJObject.Add('mobile', HLMember."Phone No.");
        if HLMember.Gender in [HLMember.Gender::MALE, HLMember.Gender::FEMALE] then
            UrlParametersJObject.Add('sex', Format(HLMember.Gender, 0, 9));
        UrlParametersJObject.Add('birthdate', HLIntegrationMgt.FormatAsHLDateTime(HLMember.Birthday));
        UrlParametersJObject.Add('address', HLMember.Address);
        UrlParametersJObject.Add('postalcode', HLMember."Post Code Code");
        UrlParametersJObject.Add('city', HLMember.City);
        UrlParametersJObject.Add('country', HLMember."HL Country ID");
        UrlParametersJObject.Add('shop', HLMember."HL Store Name");
        HLFieldID := HLIntegrationMgt.HLMembershipCodeFieldID();
        if HLFieldID <> '' then begin
            HLMember.Validate("Membership Code");  //refresh HL Membership Name
            UrlParametersJObject.Add(HLFieldID, HLMember."HL Membership Name");
        end;

        AddAttributes(HLMember, NewMember, UrlParametersJObject);
        AddMultiChoiceFields(HLMember, NewMember, UrlParametersJObject);

        HLIntegrationEvents.OnGenerateMemberUrlParameters(HLMember, NewMember, UrlParametersJObject);
    end;

    local procedure AddAttributes(HLMember: Record "NPR HL HeyLoyalty Member"; NewMember: Boolean; var UrlParametersJObject: JsonObject)
    var
        NPRAttribute: Record "NPR Attribute";
        HLMemberAttribute: Record "NPR HL Member Attribute";
        AttributeMgt: Codeunit "NPR HL Attribute Mgt.";
        HLMappedValueMgt: Codeunit "NPR HL Mapped Value Mgt.";
    begin
        if NPRAttribute.FindSet() then
            repeat
                if AttributeMgt.IsSendAttributeToHL(NPRAttribute) then begin
                    HLMemberAttribute."HeyLoyalty Member Entry No." := HLMember."Entry No.";
                    HLMemberAttribute."Attribute Code" := NPRAttribute.Code;
                    if not HLMemberAttribute.Find() then
                        HLMemberAttribute.Init();
                    HLMemberAttribute.Validate("Attribute Value Code");
                    if HLMemberAttribute."HeyLoyalty Attribute Value" = '' then
                        HLMemberAttribute."HeyLoyalty Attribute Value" := HLMappedValueMgt.GetMappedValue(NPRAttribute.RecordId(), 0, false);
                    UrlParametersJObject.Add(HLMappedValueMgt.GetMappedValue(NPRAttribute.RecordId(), NPRAttribute.FieldNo(Code), true), HLMemberAttribute."HeyLoyalty Attribute Value");
                    HLIntegrationEvents.OnAfterAddAttributeToUrlParameters(HLMember, NewMember, HLMemberAttribute, UrlParametersJObject);
                end;
            until NPRAttribute.Next() = 0;
    end;

    local procedure AddMultiChoiceFields(HLMember: Record "NPR HL HeyLoyalty Member"; NewMember: Boolean; var UrlParametersJObject: JsonObject)
    var
        HLMultiChoiceField: Record "NPR HL MultiChoice Field";
        HLMultiChoiceFldOption: Record "NPR HL MultiChoice Fld Option";
        HLSelectedMCFOption: Record "NPR HL Selected MCF Option";
        HLMappedValueMgt: Codeunit "NPR HL Mapped Value Mgt.";
        HLMultiChoiceFieldMgt: Codeunit "NPR HL MultiChoice Field Mgt.";
        HLFieldOptionValueJArray: JsonArray;
        HLFieldName: Text;
        HLFieldOptionValueName: Text;
    begin
        if HLMultiChoiceField.FindSet() then
            repeat
                HLFieldName := HLMappedValueMgt.GetMappedValue(HLMultiChoiceField.RecordId(), HLMultiChoiceField.FieldNo(Description), false);
                if HLFieldName <> '' then
                    if HLMultiChoiceFieldMgt.AssignedMCFOptionsExist(HLMember.RecordId(), HLMultiChoiceField.Code, HLSelectedMCFOption) then begin
                        HLMultiChoiceFieldMgt.MarkAssignedMCFOptions(HLSelectedMCFOption, HLMultiChoiceFldOption);
                        HLMultiChoiceFldOption.MarkedOnly(true);
                        HLMultiChoiceFldOption.SetRange("Field Code", HLMultiChoiceField.Code);
                        HLMultiChoiceFldOption.SetCurrentKey("Field Code", "Sort Order");
                        if HLMultiChoiceFldOption.FindSet() then begin
                            Clear(HLFieldOptionValueJArray);
                            repeat
                                HLFieldOptionValueName := HLMappedValueMgt.GetMappedValue(HLMultiChoiceFldOption.RecordId(), HLMultiChoiceFldOption.FieldNo(Description), false);
                                if HLFieldOptionValueName <> '' then begin
                                    HLFieldOptionValueJArray.Add(HLFieldOptionValueName);
                                    HLIntegrationEvents.OnAfterAddHLMCFOptionToUrlParameters(HLMember, NewMember, HLFieldName, HLFieldOptionValueName, UrlParametersJObject);
                                end;
                            until HLMultiChoiceFldOption.Next() = 0;
                            if HLFieldOptionValueJArray.Count() > 0 then
                                UrlParametersJObject.Add(HLFieldName, HLFieldOptionValueJArray);
                        end;
                    end;
            until HLMultiChoiceField.Next() = 0;
    end;

    local procedure GenerateUrlQueryStringFromParameterJObject(UrlParametersJObject: JsonObject): Text
    var
        ParameterJArray: JsonArray;
        ParameterJToken: JsonToken;
        UrlQueryString: TextBuilder;
        ParameterKeyList: List of [Text];
        ParameterKey: Text;
        Counter: Integer;
    begin
        ParameterKeyList := UrlParametersJObject.Keys();
        foreach ParameterKey in ParameterKeyList do begin
            UrlParametersJObject.Get(ParameterKey, ParameterJToken);
            case true of
                ParameterJToken.IsValue():
                    AddParameterToUrlUrlQueryString(ParameterKey, ParameterJToken.AsValue().AsText(), UrlQueryString);
                ParameterJToken.IsArray():
                    begin
                        ParameterJArray := ParameterJToken.AsArray();
                        for Counter := 1 to ParameterJArray.Count() do begin
                            ParameterJArray.Get(Counter - 1, ParameterJToken);
                            if ParameterJToken.IsValue() then
                                AddParameterToUrlUrlQueryString(StrSubstNo('%1[]', ParameterKey), ParameterJToken.AsValue().AsText(), UrlQueryString);
                        end;
                    end;
            end;
        end;
        exit(UrlQueryString.ToText());
    end;

    local procedure AddParameterToUrlUrlQueryString(ParameterName: Text; ParameterValue: Text; var UrlQueryString: TextBuilder)
    var
        TypeHelper: Codeunit "Type Helper";
        QueryParameterLbl: Label '%1=%2', Locked = true;
    begin
        if (ParameterName = '') or (ParameterValue = '') then
            exit;
        if UrlQueryString.Length() = 0 then
            UrlQueryString.Append('?')
        else
            UrlQueryString.Append('&');
        UrlQueryString.Append(StrSubstNo(QueryParameterLbl, TypeHelper.UrlEncode(ParameterName), TypeHelper.UrlEncode(ParameterValue)));
    end;

    procedure GetHeyLoyaltyMemberID(HLMember: Record "NPR HL HeyLoyalty Member"; WithError: Boolean): Text[50]
    var
        HLIntegrationMgt: Codeunit "NPR HL Integration Mgt.";
        HLMemberMgt: Codeunit "NPR HL Member Mgt. Impl.";
        JsonHelper: Codeunit "NPR Json Helper";
        ResponseJToken: JsonToken;
        HeyLoyaltyId: Text;
    begin
        if not HLIntegrationMgt.InvokeGetHLMemberByContactInfo(HLMember, ResponseJToken) then begin
            if WithError then
                Error(GetLastErrorText());
            exit('');
        end;
        HeyLoyaltyId := JsonHelper.GetJText(ResponseJToken, 'members[0].id', WithError);
        HLMemberMgt.CheckHeyLoyaltyIdMaxLength(HeyLoyaltyId);
        exit(CopyStr(HeyLoyaltyId, 1, 50));
    end;
}