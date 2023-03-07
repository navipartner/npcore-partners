codeunit 6150638 "NPR HL Integration Events Mgt."
{
    Access = Public;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR HL Integration Events", 'OnAfterAddAttributeToUrlParameters', '', false, false)]
    local procedure OnAfterAddAttributeToUrlParameters(NewMember: Boolean; HLMemberAttribute: Record "NPR HL Member Attribute"; var UrlParametersJObject: JsonObject);
    var
        Proceed: Boolean;
        AttributeCode1: Code[20];
        AttributeCode2: Code[20];
        ValueAsInteger: Integer;
    begin
        Proceed := false;
        OnBeforeAddAttributeToUrlParameters(Proceed, AttributeCode1, AttributeCode2);
        if not Proceed then
            exit;

        case HLMemberAttribute."Attribute Code" of
            AttributeCode1:
                if Evaluate(ValueAsInteger, HLMemberAttribute."Attribute Value Code") then
                    UrlParametersJObject.Add('butikskode', ValueAsInteger);
            AttributeCode2:
                if NewMember then
                    UrlParametersJObject.Add('sign_up_source', HLMemberAttribute."HeyLoyalty Attribute Value");
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR HL Integration Events", 'OnAfterUpdateMemberFromHL', '', false, false)]
    local procedure BlockMemberOnUnsubscribe(HLMember: Record "NPR HL HeyLoyalty Member"; Member: Record "NPR MM Member")
    var
        Proceed: Boolean;
    begin
        Proceed := false;
        OnAfterUpdateMemberFromHL(Proceed);
        if not Proceed then
            exit;
        if not Member.Find() then
            exit;
        case true of
            (HLMember."Unsubscribed at" <> 0DT) and not Member.Blocked:
                begin
                    Member.Blocked := true;
                    Member."Block Reason" := Member."Block Reason"::USER_REQUEST;
                    Member."Blocked At" := CurrentDateTime();
                    Member."Blocked By" := UserId();
                    Member.Modify();
                    Member.Validate(Blocked);
                end;

            (HLMember."Unsubscribed at" = 0DT) and Member.Blocked:
                begin
                    Member.Blocked := false;
                    Member."Block Reason" := Member."Block Reason"::UNKNOWN;
                    Member."Blocked At" := 0DT;
                    Member."Blocked By" := '';
                    Member.Modify();
                    Member.Validate(Blocked);
                end;
        end;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeAddAttributeToUrlParameters(var Proceed: Boolean; var AttributeCode1: Code[20]; var AttributeCode2: Code[20])
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterUpdateMemberFromHL(var Proceed: Boolean)
    begin
    end;
}