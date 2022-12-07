codeunit 6059990 "NPR HL Attribute Mgt."
{
    Access = Internal;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR Attribute Management", 'OnAfterClientAttributeNewValue', '', false, false)]
    local procedure UpdateHLMemberAttributeOnMemberAttributeChange(NPRAttributeKey: Record "NPR Attribute Key"; NPRAttributeValueSet: Record "NPR Attribute Value Set")
    var
        MembershipRole: Record "NPR MM Membership Role";
        HLMember: Record "NPR HL HeyLoyalty Member";
        Member: Record "NPR MM Member";
        MemberMgt: Codeunit "NPR HL Member Mgt.";
        SpfyScheduleSend: Codeunit "NPR HL Schedule Send Tasks";
        IsCascadeUpdate: Boolean;
    begin
        if NPRAttributeKey."Table ID" <> Database::"NPR MM Member" then
            exit;
        OnCheckIfIsCascadeUpdate(IsCascadeUpdate);
        if IsCascadeUpdate then
            exit;
        if not IsSendAttributeToHL(NPRAttributeValueSet."Attribute Code") then
            exit;
        if not Evaluate(Member."Entry No.", NPRAttributeKey."MDR Code PK", 9) or (Member."Entry No." = 0) then
            exit;
        Member.Find();
        MemberMgt.FindMembershipRole(Member, MembershipRole);
        if not MemberMgt.GetHLMember(Member, MembershipRole, HLMember, "NPR HL Auto Create HL Member"::Eligible) then
            exit;
        if UpdateHLMemberAttribute(HLMember, NPRAttributeValueSet) then begin
            MemberMgt.UpdateHLMember(Member, MembershipRole, HLMember);
            MemberMgt.ScheduleHLMemberProcessing(HLMember, SpfyScheduleSend.NowWithDelayInSeconds(10));
        end;
    end;

    procedure UpdateHLMemberAttributesFromMember(HLMember: Record "NPR HL HeyLoyalty Member"): Boolean
    var
        HLMemberAttribute: Record "NPR HL Member Attribute";
        NPRAttributeValueSet: Record "NPR Attribute Value Set";
        ChangesFound: Boolean;
    begin
        if (HLMember."Member Entry No." = 0) or HLMember.Deleted then
            exit(false);
        HLMemberAttribute.SetRange("HeyLoyalty Member Entry No.", HLMember."Entry No.");
        if HLMemberAttribute.FindSet(true) then
            repeat
                HLMemberAttribute.Mark(true);
            until HLMemberAttribute.Next() = 0;

        NPRAttributeValueSet.SetRange("Table ID", Database::"NPR MM Member");
        NPRAttributeValueSet.SetRange("MDR Code PK", Format(HLMember."Member Entry No.", 9));
        NPRAttributeValueSet.SetFilter("Attribute Code", '<>%1', '');
        if NPRAttributeValueSet.FindSet() then
            repeat
                if IsSendAttributeToHL(NPRAttributeValueSet."Attribute Code") then begin
                    if UpdateHLMemberAttribute(HLMember, NPRAttributeValueSet, HLMemberAttribute) then
                        ChangesFound := true;
                    if HLMemberAttribute."Attribute Code" <> '' then
                        HLMemberAttribute.Mark(false);
                end;
            until NPRAttributeValueSet.Next() = 0;

        HLMemberAttribute.MarkedOnly(true);
        if not HLMemberAttribute.IsEmpty() then begin
            HLMemberAttribute.DeleteAll();
            ChangesFound := true;
        end;

        exit(ChangesFound);
    end;

    local procedure UpdateHLMemberAttribute(HLMember: Record "NPR HL HeyLoyalty Member"; NPRAttributeValueSet: Record "NPR Attribute Value Set"): Boolean
    var
        HLMemberAttribute: Record "NPR HL Member Attribute";
    begin
        exit(UpdateHLMemberAttribute(HLMember, NPRAttributeValueSet, HLMemberAttribute));
    end;

    local procedure UpdateHLMemberAttribute(HLMember: Record "NPR HL HeyLoyalty Member"; NPRAttributeValueSet: Record "NPR Attribute Value Set"; var HLMemberAttribute: Record "NPR HL Member Attribute"): Boolean
    begin
        exit(UpdateHLMemberAttribute(HLMember, NPRAttributeValueSet."Attribute Code", UpperCase(CopyStr(NPRAttributeValueSet."Text Value", 1, 20)), HLMemberAttribute));
    end;

    local procedure UpdateHLMemberAttribute(HLMember: Record "NPR HL HeyLoyalty Member"; AttributeCode: Code[20]; AttributeValueCode: Code[20]; var HLMemberAttributeOut: Record "NPR HL Member Attribute"): Boolean
    var
        NPRAttributeValue: Record "NPR Attribute Lookup Value";
        HLMemberAttribute: Record "NPR HL Member Attribute";
        xHLMemberAttribute: Record "NPR HL Member Attribute";
        Updated: Boolean;
    begin
        HLMemberAttribute."HeyLoyalty Member Entry No." := HLMember."Entry No.";
        HLMemberAttribute."Attribute Code" := AttributeCode;
        if not HLMemberAttribute.Find() then begin
            if AttributeValueCode = '' then begin
                Clear(HLMemberAttribute);
                HLMemberAttributeOut := HLMemberAttribute;
                exit(false);
            end;
            HLMemberAttribute.Init();
            HLMemberAttribute.Insert();
        end else begin
            if AttributeValueCode = '' then begin
                HLMemberAttribute.Delete();
                Clear(HLMemberAttribute);
                HLMemberAttributeOut := HLMemberAttribute;
                exit(true);
            end;
            xHLMemberAttribute := HLMemberAttribute;
        end;

        if not NPRAttributeValue.Get(AttributeCode, AttributeValueCode) then begin
            NPRAttributeValue."Attribute Code" := AttributeCode;
            NPRAttributeValue."Attribute Value Code" := AttributeValueCode;
            NPRAttributeValue."HeyLoyalty Value" := AttributeValueCode;
        end;
        HLMemberAttribute."Attribute Value Code" := NPRAttributeValue."Attribute Value Code";
        HLMemberAttribute."HeyLoyalty Attribute Value" := NPRAttributeValue."HeyLoyalty Value";

        Updated := Format(xHLMemberAttribute) <> Format(HLMemberAttribute);
        if Updated then
            HLMemberAttribute.Modify();
        HLMemberAttributeOut := HLMemberAttribute;
        exit(Updated);
    end;

    procedure UpdateHLMemberAttributeFromHL(HLMember: Record "NPR HL HeyLoyalty Member"; HeyLoyaltyFieldID: Text; HeyLoyaltyAttributeValue: Text; HeyLoyaltyAttributeValueDescription: Text): Boolean
    var
        HLMemberAttribute: Record "NPR HL Member Attribute";
        xHLMemberAttribute: Record "NPR HL Member Attribute";
        NPRAttribute: Record "NPR Attribute";
        NPRAttributeValue: Record "NPR Attribute Lookup Value";
    begin
        if HeyLoyaltyFieldID = '' then
            exit(false);

        NPRAttribute.SetRange("HeyLoyalty Field ID", CopyStr(HeyLoyaltyFieldID, 1, MaxStrLen(NPRAttribute."HeyLoyalty Field ID")));
        if not (NPRAttribute.FindFirst() and IsSendAttributeToHL(NPRAttribute)) then
            exit(false);

        HLMemberAttribute."HeyLoyalty Member Entry No." := HLMember."Entry No.";
        HLMemberAttribute."Attribute Code" := NPRAttribute.Code;
        if not HLMemberAttribute.Find() then begin
            if HeyLoyaltyAttributeValue = '' then
                exit(false);
            HLMemberAttribute.Init();
            HLMemberAttribute.Insert();
        end else
            xHLMemberAttribute := HLMemberAttribute;
        HLMemberAttribute."HeyLoyalty Attribute Value" := CopyStr(HeyLoyaltyAttributeValue, 1, MaxStrLen(HLMemberAttribute."HeyLoyalty Attribute Value"));

        NPRAttributeValue.SetRange("Attribute Code", NPRAttribute.Code);
        NPRAttributeValue.SetRange("Attribute Value Code", HLMemberAttribute."Attribute Value Code");
        NPRAttributeValue.SetRange("HeyLoyalty Value", HLMemberAttribute."HeyLoyalty Attribute Value");
        if NPRAttributeValue.IsEmpty() then begin
            NPRAttributeValue.SetRange("Attribute Value Code");
            if NPRAttribute."HL Auto Create New Values" then
                if NPRAttributeValue.IsEmpty() then
                    CreateAttributeValue(NPRAttribute.Code, HLMemberAttribute."HeyLoyalty Attribute Value", HeyLoyaltyAttributeValueDescription);
        end;
        if NPRAttributeValue.FindFirst() then begin
            HLMemberAttribute."Attribute Value Code" := NPRAttributeValue."Attribute Value Code";
            HLMemberAttribute."HeyLoyalty Attribute Value" := NPRAttributeValue."HeyLoyalty Value";
        end else
            HLMemberAttribute."Attribute Value Code" := CopyStr(HLMemberAttribute."HeyLoyalty Attribute Value", 1, MaxStrLen(HLMemberAttribute."Attribute Value Code"));

        if Format(xHLMemberAttribute) = Format(HLMemberAttribute) then
            exit(false);
        HLMemberAttribute.Modify();
        exit(true);
    end;

    procedure UpdateMemberAttributesFromHLMember(HLMember: Record "NPR HL HeyLoyalty Member")
    var
        HLMemberAttribute: Record "NPR HL Member Attribute";
        NPRAttributeID: Record "NPR Attribute ID";
        NPRAttrManagement: Codeunit "NPR Attribute Management";
        SkipCascadeUpdate: Codeunit "NPR HL Skip Attribute Update";
        AttributeValue: Text[250];
    begin
        HLMemberAttribute.SetRange("HeyLoyalty Member Entry No.", HLMember."Entry No.");
        HLMemberAttribute.SetFilter("Attribute Code", '<>%1', '');
        if HLMemberAttribute.FindSet() then
            repeat
                if NPRAttributeID.Get(Database::"NPR MM Member", HLMemberAttribute."Attribute Code") then begin
                    AttributeValue := HLMemberAttribute."Attribute Value Code";
                    BindSubscription(SkipCascadeUpdate);
                    NPRAttrManagement.SetEntryAttributeValue(NPRAttributeID."Table ID", NPRAttributeID."Shortcut Attribute ID", HLMember."Member Entry No.", AttributeValue);
                    UnbindSubscription(SkipCascadeUpdate);
                end;
            until HLMemberAttribute.Next() = 0;
    end;

    local procedure IsSendAttributeToHL(AttributeCode: Code[20]): Boolean
    var
        NPRAttribute: Record "NPR Attribute";
    begin
        exit(NPRAttribute.Get(AttributeCode) and IsSendAttributeToHL(NPRAttribute));
    end;

    procedure IsSendAttributeToHL(NPRAttribute: Record "NPR Attribute"): Boolean
    var
        NPRAttributeID: Record "NPR Attribute ID";
    begin
        if NPRAttribute."HeyLoyalty Field ID" = '' then
            exit(false);
        exit(NPRAttributeID.Get(Database::"NPR MM Member", NPRAttribute.Code));
    end;

    local procedure CreateAttributeValue(AttributeCode: Code[20]; HeyLoyaltyAttributeValue: Text[50]; HeyLoyaltyAttributeValueDescription: Text)
    var
        NPRAttributeValue: Record "NPR Attribute Lookup Value";
    begin
        if (AttributeCode = '') or (HeyLoyaltyAttributeValue = '') then
            exit;

        NPRAttributeValue.Reset();
        NPRAttributeValue."Attribute Code" := AttributeCode;
        NPRAttributeValue."Attribute Value Code" := CopyStr(HeyLoyaltyAttributeValue, 1, MaxStrLen(NPRAttributeValue."Attribute Value Code"));
        if NPRAttributeValue.Find() then begin
            NPRAttributeValue."Attribute Value Code" := CopyStr(HeyLoyaltyAttributeValue, 1, MaxStrLen(NPRAttributeValue."Attribute Value Code") - 3) + '001';
            while NPRAttributeValue.Find() do
                NPRAttributeValue."Attribute Value Code" := IncStr(NPRAttributeValue."Attribute Value Code");
        end;
        NPRAttributeValue.Init();
        if HeyLoyaltyAttributeValueDescription <> '' then
            NPRAttributeValue."Attribute Value Name" := CopyStr(HeyLoyaltyAttributeValueDescription, 1, MaxStrLen(NPRAttributeValue."Attribute Value Name"))
        else
            NPRAttributeValue."Attribute Value Name" := HeyLoyaltyAttributeValue;
        NPRAttributeValue."Attribute Value Description" := NPRAttributeValue."Attribute Value Name";
        NPRAttributeValue."HeyLoyalty Value" := HeyLoyaltyAttributeValue;
        NPRAttributeValue.Insert();
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCheckIfIsCascadeUpdate(var IsCascadeUpdate: Boolean)
    begin
    end;
}