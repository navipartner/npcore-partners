#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22
codeunit 6248485 "NPR MembershipAttributesAgent"
{
    Access = Internal;

    #region Membership
    internal procedure ListMembershipAttributes(Request: Codeunit "NPR API Request") Response: Codeunit "NPR API Response"
    begin
        exit(Response.RespondOK(ListAttributes(DATABASE::"NPR MM Membership").BuildAsArray()));
    end;

    internal procedure GetMembershipAttributeValues(Request: Codeunit "NPR API Request") Response: Codeunit "NPR API Response"
    var
        Membership: Record "NPR MM Membership";
        ResponseJson: Codeunit "NPR JSON Builder";
        MembershipAgent: Codeunit "NPR MembershipApiAgent";
    begin
        if (not MembershipAgent.GetMembershipById(Request, 2, Membership)) then
            exit(Response.RespondBadRequest('Invalid Membership - Membership Id not valid.'));

        ResponseJson.StartObject()
            .AddProperty('membershipId', Format(Membership.SystemId, 0, 4).ToLower())
            .AddObject(MembershipAttributesDTO(ResponseJson, Membership."Entry No."))
            .EndObject();

        exit(Response.RespondOK(ResponseJson.Build()));
    end;

    internal procedure SetMembershipAttributeValues(Request: Codeunit "NPR API Request") Response: Codeunit "NPR API Response"
    var
        Membership: Record "NPR MM Membership";
        ResponseJson: Codeunit "NPR JSON Builder";
        MembershipAgent: Codeunit "NPR MembershipApiAgent";
    begin
        if (not MembershipAgent.GetMembershipById(Request, 2, Membership)) then
            exit(Response.RespondBadRequest('Invalid Membership - Membership Id not valid.'));

        if (not ApplyInboundAttributesToMembership(Request, Membership."Entry No.")) then
            exit(Response.RespondBadRequest('Invalid request, required parameter "attributes" not found or not an array.'));

        ResponseJson.StartObject()
            .AddProperty('membershipId', Format(Membership.SystemId, 0, 4).ToLower())
            .AddObject(MembershipAttributesDTO(ResponseJson, Membership."Entry No."))
            .EndObject();

        exit(Response.RespondOK(ResponseJson.Build()));
    end;

    internal procedure DeleteMembershipAttributeValues(Request: Codeunit "NPR API Request") Response: Codeunit "NPR API Response"
    var
        Membership: Record "NPR MM Membership";
        ResponseJson: Codeunit "NPR JSON Builder";
        MembershipAgent: Codeunit "NPR MembershipApiAgent";
    begin
        if (not MembershipAgent.GetMembershipById(Request, 2, Membership)) then
            exit(Response.RespondBadRequest('Invalid Membership - Membership Id not valid.'));

        if (not RemoveInboundAttributes(Request)) then
            exit(Response.RespondBadRequest('Invalid request, required parameter "attributeIds" not found or not an array.'));

        ResponseJson.StartObject()
            .AddProperty('membershipId', Format(Membership.SystemId, 0, 4).ToLower())
            .AddObject(MembershipAttributesDTO(ResponseJson, Membership."Entry No."))
            .EndObject();

        exit(Response.RespondOK(ResponseJson.Build()));
    end;

    internal procedure MembershipAttributesDTO(ResponseJson: Codeunit "NPR Json Builder"; MembershipEntryNo: Integer): Codeunit "NPR Json Builder"
    var
        Attribute: JsonToken;
    begin
        ResponseJson.StartArray('attributes');
        foreach attribute in GetMembershipAttributesWorker(MembershipEntryNo) do begin
            ResponseJson.AddProperty('', attribute.AsObject());
        end;

        ResponseJson.EndArray();
    end;

    internal procedure ApplyInboundAttributesToMembership(var Request: Codeunit "NPR API Request"; MembershipEntryNo: Integer): Boolean
    var
        Body: JsonObject;
        JToken: JsonToken;
    begin
        Body := Request.BodyJson().AsObject();
        if (not Body.Get('attributes', JToken)) then
            exit;
        exit(ApplyInboundAttributes(DATABASE::"NPR MM Membership", MembershipEntryNo, JToken));
    end;

    internal procedure GetMembershipAttributesWorker(MembershipEntryNo: Integer): JsonArray
    begin
        exit(GetAttributes(DATABASE::"NPR MM Membership", MembershipEntryNo));
    end;
    #endregion Membership Attributes


    #region Member
    internal procedure ListMemberAttributes(Request: Codeunit "NPR API Request") Response: Codeunit "NPR API Response"
    begin
        exit(Response.RespondOK(ListAttributes(DATABASE::"NPR MM Member").BuildAsArray()));
    end;

    internal procedure GetMemberAttributeValues(Request: Codeunit "NPR API Request") Response: Codeunit "NPR API Response"
    var
        Member: Record "NPR MM Member";
        ResponseJson: Codeunit "NPR JSON Builder";
        MemberAgent: Codeunit "NPR MemberApiAgent";
    begin
        if (not MemberAgent.GetMemberById(Request, 3, Member)) then
            exit(Response.RespondBadRequest('Invalid Member - Member Id not valid.'));

        ResponseJson.StartObject()
            .AddProperty('memberId', Format(Member.SystemId, 0, 4).ToLower())
            .AddObject(MemberAttributesDTO(ResponseJson, Member."Entry No."))
            .EndObject();

        exit(Response.RespondOK(ResponseJson.Build()));
    end;

    internal procedure SetMemberAttributeValues(Request: Codeunit "NPR API Request") Response: Codeunit "NPR API Response"
    var
        Member: Record "NPR MM Member";
        ResponseJson: Codeunit "NPR JSON Builder";
        MemberAgent: Codeunit "NPR MemberApiAgent";
    begin
        if (not MemberAgent.GetMemberById(Request, 3, Member)) then
            exit(Response.RespondBadRequest('Invalid Member - Member Id not valid.'));

        if (not ApplyInboundAttributesToMember(Request, Member."Entry No.")) then
            exit(Response.RespondBadRequest('Invalid request, required parameter "attributes" not found or not an array.'));

        ResponseJson.StartObject()
            .AddProperty('memberId', Format(Member.SystemId, 0, 4).ToLower())
            .AddObject(MemberAttributesDTO(ResponseJson, Member."Entry No."))
            .EndObject();

        exit(Response.RespondOK(ResponseJson.Build()));
    end;

    internal procedure DeleteMemberAttributeValues(Request: Codeunit "NPR API Request") Response: Codeunit "NPR API Response"
    var
        Member: Record "NPR MM Member";
        ResponseJson: Codeunit "NPR JSON Builder";
        MemberAgent: Codeunit "NPR MemberApiAgent";
    begin
        if (not MemberAgent.GetMemberById(Request, 3, Member)) then
            exit(Response.RespondBadRequest('Invalid Member - Member Id not valid.'));

        if (not RemoveInboundAttributes(Request)) then
            exit(Response.RespondBadRequest('Invalid request, required parameter "attributeIds" not found or not an array.'));

        ResponseJson.StartObject()
            .AddProperty('memberId', Format(Member.SystemId, 0, 4).ToLower())
            .AddObject(MemberAttributesDTO(ResponseJson, Member."Entry No."))
            .EndObject();

        exit(Response.RespondOK(ResponseJson.Build()));
    end;

    internal procedure MemberAttributesDTO(ResponseJson: Codeunit "NPR Json Builder"; MemberEntryNo: Integer): Codeunit "NPR Json Builder"
    var
        Attribute: JsonToken;
    begin
        ResponseJson.StartArray('attributes');
        foreach attribute in GetMemberAttributesWorker(MemberEntryNo) do begin
            ResponseJson.AddProperty('', attribute.AsObject());
        end;

        ResponseJson.EndArray();
    end;

    internal procedure ApplyInboundAttributesToMember(var Request: Codeunit "NPR API Request"; MemberEntryNo: Integer): Boolean
    var
        Body: JsonObject;
        JToken: JsonToken;
    begin
        Body := Request.BodyJson().AsObject();
        if (not Body.Get('attributes', JToken)) then
            exit;
        exit(ApplyInboundAttributes(DATABASE::"NPR MM Member", MemberEntryNo, JToken));
    end;

    internal procedure GetMemberAttributesWorker(MemberEntryNo: Integer): JsonArray
    begin
        exit(GetAttributes(DATABASE::"NPR MM Member", MemberEntryNo));
    end;
    #endregion Member Attributes

    #region Member Info Capture
    internal procedure ApplyInboundMemberAttributesToMemberInfoCapture(var Request: Codeunit "NPR API Request"; var MemberInfoCapture: Record "NPR MM Member Info Capture")
    var
        Body: JsonObject;
        JToken: JsonToken;
    begin
        Body := Request.BodyJson().AsObject();
        if (not Body.Get('member', JToken)) then
            exit;

        if (not JToken.IsObject()) then
            exit;

        if (not JToken.AsObject().Get('attributes', JToken)) then
            exit;

        if (not JToken.IsArray()) then
            exit;

        ApplyInboundAttributes(MemberInfoCapture, JToken);
    end;

    internal procedure ApplyInboundMembershipAttributesToMemberInfoCapture(var Request: Codeunit "NPR API Request"; var MemberInfoCapture: Record "NPR MM Member Info Capture")
    var
        Body: JsonObject;
        JToken: JsonToken;
    begin
        Body := Request.BodyJson().AsObject();
        if (not Body.Get('attributes', JToken)) then
            exit;

        ApplyInboundAttributes(MemberInfoCapture, JToken);
    end;
    #endregion Member Info Capture

    #region Generic
    local procedure ListAttributes(TableId: Integer) ResponseJson: Codeunit "NPR JSON Builder"
    var
        Attribute: Record "NPR Attribute";
        AttributeId: Record "NPR Attribute ID";
        AttributeIdForCreate: Record "NPR Attribute ID";
    begin
        ResponseJson.StartArray('');

        AttributeId.SetCurrentKey("Table ID", "Shortcut Attribute ID");
        AttributeId.SetFilter("Table ID", '=%1', TableId);
        if (AttributeID.FindSet()) then begin
            repeat
                // attributes needs to be available for the "member info capture" table for API creation
                if (AttributeIdForCreate.Get(Database::"NPR MM Member Info Capture", AttributeID."Attribute Code")) then
                    if (Attribute.Get(AttributeId."Attribute Code")) then begin
                        ResponseJson.StartObject()
                            .AddProperty('code', Attribute.Code)
                            .AddProperty('name', Attribute.Name)
                            // .AddProperty('presentationOrder', AttributeId."Shortcut Attribute ID")
                            .AddProperty('caption', Attribute."Code Caption")
                            .AddProperty('blocked', Attribute.Blocked)
                            .AddProperty('description', Attribute.Description)

                            .AddProperty('datatype', DatatypeOptionToText(Attribute."Value Datatype"))
                            .AddProperty('validateAs', OnValidateOptionToText(Attribute."On Validate"))
                            .AddProperty('formatAs', OnFormatOptionToText(Attribute."On Format"))
                            // .AddProperty('lookupTable', Attribute."LookUp Table")
                            // .AddProperty('lookupTableId ', Attribute."LookUp Table Id")
                            // .AddProperty('lookupFieldId', Attribute."LookUp Value Field Id")
                            .EndObject();
                    end;
            until (AttributeID.Next() = 0);
        end;
        ResponseJson.EndArray();
    end;

    local procedure GetAttributes(TableId: Integer; EntryNo: Integer) MembershipAttributes: JsonArray
    var
        AttributeKey: Record "NPR Attribute Key";
        Attribute: Record "NPR Attribute";
        AttributeValueSet: Record "NPR Attribute Value Set";
        JsonObject: JsonObject;
    begin

        AttributeKey.SetFilter("Table ID", '=%1', TableId);
        AttributeKey.SetFilter("MDR Code PK", '=%1', Format(EntryNo, 0, '<integer>'));
        if (AttributeKey.FindFirst()) then begin
            AttributeValueSet.SetFilter("Attribute Set ID", '=%1', AttributeKey."Attribute Set ID");
            if (AttributeValueSet.FindSet()) then begin
                repeat
                    Attribute.Get(AttributeValueSet."Attribute Code");
                    Clear(JsonObject);

                    JsonObject.Add('id', format(AttributeValueSet.SystemId, 0, 4).ToLower());
                    JsonObject.Add('code', AttributeValueSet."Attribute Code");
                    JsonObject.Add('caption', Attribute."Code Caption");
                    JsonObject.Add('type', DatatypeOptionToText(Attribute."Value Datatype"));
                    case Attribute."Value Datatype" of
                        Attribute."Value Datatype"::DT_INTEGER:
                            JsonObject.Add('value', format(AttributeValueSet."Numeric Value", 0, 9));
                        Attribute."Value Datatype"::DT_DECIMAL:
                            JsonObject.Add('value', format(AttributeValueSet."Numeric Value", 0, 9));
                        Attribute."Value Datatype"::DT_BOOLEAN:
                            JsonObject.Add('value', Format(AttributeValueSet."Boolean Value", 0, 9));
                        Attribute."Value Datatype"::DT_DATE:
                            JsonObject.Add('value', Format(DT2Date(AttributeValueSet."DateTime Value"), 0, 9));
                        Attribute."Value Datatype"::DT_DATETIME:
                            JsonObject.Add('value', Format(AttributeValueSet."DateTime Value", 0, 9));
                        else begin
                            JsonObject.Add('value', AttributeValueSet."Text Value");
                        end;
                    end;
                    MembershipAttributes.Add(JsonObject);

                until (AttributeValueSet.Next() = 0);
            end;
        end;
    end;


    local procedure ApplyInboundAttributes(TableId: Integer; EntryNo_TableIdPrimaryKey: Integer; AttributesToken: JsonToken): Boolean
    var
        Attributes: JsonArray;
        Attribute: JsonToken;
        AttributeKeyValuePair: JsonObject;
        AttributeKey: Code[20];
        AttributeValue: Text[250];
    begin
        if (not AttributesToken.IsArray()) then
            exit(false);

        Attributes := AttributesToken.AsArray();
        foreach Attribute in Attributes do begin
            if (Attribute.IsObject()) then begin
                AttributeKeyValuePair := Attribute.AsObject();

                AttributeKeyValuePair.Get('code', AttributesToken);
                AttributeKey := CopyStr(AttributesToken.AsValue().AsText().ToUpper(), 1, MaxStrLen(AttributeKey));

                AttributeKeyValuePair.Get('value', AttributesToken);
                AttributeValue := CopyStr(AttributesToken.AsValue().AsText(), 1, MaxStrLen(AttributeValue));

                ApplyAttributesToTableId(TableId, EntryNo_TableIdPrimaryKey, AttributeKey, AttributeValue);
            end;
        end;
        exit(true);
    end;

    local procedure ApplyInboundAttributes(var MemberInfoCapture: Record "NPR MM Member Info Capture"; AttributesToken: JsonToken): Boolean
    var
        MembershipEvents: Codeunit "NPR MM Membership Events";
        Attributes: JsonArray;
        Attribute: JsonToken;
        AttributeKeyValuePair: JsonObject;
        AttributeKey: Text;
        AttributeValue: Text;
        Handled: Boolean;
    begin
        if (not AttributesToken.IsArray()) then
            exit(false);

        Attributes := AttributesToken.AsArray();
        foreach Attribute in Attributes do begin
            if (Attribute.IsObject()) then begin
                AttributeKeyValuePair := Attribute.AsObject();

                AttributeKeyValuePair.Get('code', AttributesToken);
                AttributeKey := AttributesToken.AsValue().AsText();

                AttributeKeyValuePair.Get('value', AttributesToken);
                AttributeValue := AttributesToken.AsValue().AsText();
                Handled := false;
                MembershipEvents.OnBeforeApplyAttributeToMemberInfoCapture(MemberInfoCapture, AttributeKey, AttributeValue, Handled);
                if not Handled then
                    ApplyAttributesToTableId(Database::"NPR MM Member Info Capture", MemberInfoCapture."Entry No.", CopyStr(AttributeKey.ToUpper(), 1, 20), CopyStr(AttributeValue, 1, 250));
            end;
        end;
        exit(true);
    end;

    local procedure ApplyAttributesToTableId(TableId: Integer; EntryNo_TableIdPrimaryKey: Integer; AttributeCode: Code[20]; AttributeValue: Text[250])
    var
        Attribute: Record "NPR Attribute";
        AttributeID: Record "NPR Attribute ID";
        NPRAttributeManagement: Codeunit "NPR Attribute Management";
    begin

        if (not Attribute.Get(AttributeCode)) then
            Error('Attribute %1 is not valid.', AttributeCode);

        if (not AttributeID.Get(TableId, AttributeCode)) then
            Error('Attribute %1 is not defined for table with id %2.', AttributeCode, TableId);

        NPRAttributeManagement.SetEntryAttributeValue(TableId, AttributeID."Shortcut Attribute ID", EntryNo_TableIdPrimaryKey, AttributeValue);

    end;

    local procedure RemoveInboundAttributes(var Request: Codeunit "NPR API Request"): Boolean
    var
        Body: JsonObject;
        JToken: JsonToken;
        Attributes: JsonArray;
        Attribute: JsonToken;
        AttributeValueSet: Record "NPR Attribute Value Set";
        AttributeId: Guid;

    begin
        Body := Request.BodyJson().AsObject();
        if (not Body.Get('attributeIds', JToken)) then
            exit(false);

        if (not JToken.IsArray()) then
            exit(false);

        Attributes := JToken.AsArray();
        if (Attributes.Count() = 0) then
            exit(true);

        foreach Attribute in Attributes do begin
            if (Attribute.IsValue()) then begin
                Evaluate(AttributeId, Attribute.AsValue().AsText());
                AttributeValueSet.GetBySystemId(AttributeId);
                AttributeValueSet.Delete();
            end;
        end;
        exit(true);
    end;
    #endregion Generic

    #region Helper Functions
    local procedure DatatypeOptionToText(OptionValue: Option): Text
    var
        Attribute: Record "NPR Attribute";
    begin
        case OptionValue of
            Attribute."Value Datatype"::DT_TEXT:
                exit('text');
            Attribute."Value Datatype"::DT_CODE:
                exit('code');
            Attribute."Value Datatype"::DT_DATE:
                exit('date');
            Attribute."Value Datatype"::DT_DATETIME:
                exit('datetime');
            Attribute."Value Datatype"::DT_DECIMAL:
                exit('decimal');
            Attribute."Value Datatype"::DT_INTEGER:
                exit('integer');
            Attribute."Value Datatype"::DT_BOOLEAN:
                exit('boolean');
            else
                exit('unknown');
        end;
    end;

    local procedure OnValidateOptionToText(OptionValue: Option): Text
    var
        Attribute: Record "NPR Attribute";
    begin
        case OptionValue of
            Attribute."On Validate"::DATATYPE:
                exit('datatype');
            Attribute."On Validate"::VALUE_LOOKUP:
                exit('lookup');
            else
                exit('unknown');
        end;
    end;

    local procedure OnFormatOptionToText(OptionValue: Option): Text
    var
        Attribute: Record "NPR Attribute";
    begin
        case OptionValue of
            Attribute."On Format"::CUSTOM:
                exit('custom');
            Attribute."On Format"::NATIVE:
                exit('native');
            Attribute."On Format"::USER:
                exit('userCulture');
            else
                exit('unknown');
        end;
    end;
    #endregion Helper Functions
}
#endif // BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22