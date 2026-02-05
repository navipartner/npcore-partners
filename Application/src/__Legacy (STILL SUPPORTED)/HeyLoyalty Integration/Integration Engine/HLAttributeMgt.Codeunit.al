codeunit 6059990 "NPR HL Attribute Mgt."
{
    ObsoleteState = Pending;
    ObsoleteTag = '2026-01-29';
    ObsoleteReason = 'This module is no longer being maintained';
    Access = Internal;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR Attribute Management", 'OnAfterClientAttributeNewValue', '', false, false)]
    local procedure UpdateHLMemberAttributeOnMemberAttributeChange(NPRAttributeKey: Record "NPR Attribute Key"; NPRAttributeValueSet: Record "NPR Attribute Value Set")
    var
        MembershipRole: Record "NPR MM Membership Role";
        HLMember: Record "NPR HL HeyLoyalty Member";
        Member: Record "NPR MM Member";
        DataLogMgt: Codeunit "NPR Data Log Management";
        MemberMgt: Codeunit "NPR HL Member Mgt. Impl.";
        RecRef: RecordRef;
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
        if not HLMemberAttributeUpdateIsRequired(HLMember, NPRAttributeValueSet) then
            exit;
        RecRef.GetTable(Member);
        DataLogMgt.DisableIgnoredFields(true);
        DataLogMgt.LogDatabaseModify(RecRef);
        DataLogMgt.DisableIgnoredFields(false);
    end;

    procedure UpdateHLMemberAttributesFromMember(HLMember: Record "NPR HL HeyLoyalty Member"): Boolean
    var
        HLMemberAttribute: Record "NPR HL Member Attribute";
        NPRAttributeKey: Record "NPR Attribute Key";
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

        NPRAttributeKey.SetCurrentKey("Table ID", "MDR Code PK");
        NPRAttributeKey.SetRange("Table ID", Database::"NPR MM Member");
        NPRAttributeKey.SetRange("MDR Code PK", Format(HLMember."Member Entry No.", 9));
        if NPRAttributeKey.FindSet() then
            repeat
                NPRAttributeValueSet.SetRange("Attribute Set ID", NPRAttributeKey."Attribute Set ID");
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
            until NPRAttributeKey.Next() = 0;

        HLMemberAttribute.MarkedOnly(true);
        if not HLMemberAttribute.IsEmpty() then begin
            HLMemberAttribute.DeleteAll();
            ChangesFound := true;
        end;

        exit(ChangesFound);
    end;

    local procedure HLMemberAttributeUpdateIsRequired(HLMember: Record "NPR HL HeyLoyalty Member"; NPRAttributeValueSet: Record "NPR Attribute Value Set"): Boolean
    begin
        exit(HLMemberAttributeUpdateIsRequired(HLMember, NPRAttributeValueSet."Attribute Code", CopyStr(UpperCase(NPRAttributeValueSet."Text Value"), 1, 20)));
    end;

    local procedure HLMemberAttributeUpdateIsRequired(HLMember: Record "NPR HL HeyLoyalty Member"; AttributeCode: Code[20]; AttributeValueCode: Code[20]): Boolean
    var
        NPRAttributeValue: Record "NPR Attribute Lookup Value";
        HLMemberAttribute: Record "NPR HL Member Attribute";
        xHLMemberAttribute: Record "NPR HL Member Attribute";
        HLMappedValueMgt: Codeunit "NPR HL Mapped Value Mgt.";
    begin
        HLMemberAttribute."HeyLoyalty Member Entry No." := HLMember."Entry No.";
        HLMemberAttribute."Attribute Code" := AttributeCode;
        if not HLMemberAttribute.Find() then
            exit(AttributeValueCode <> '');
        if AttributeValueCode = '' then
            exit(true);
        xHLMemberAttribute := HLMemberAttribute;

        if not NPRAttributeValue.Get(AttributeCode, AttributeValueCode) then begin
            NPRAttributeValue."Attribute Code" := AttributeCode;
            NPRAttributeValue."Attribute Value Code" := AttributeValueCode;
            HLMemberAttribute."HeyLoyalty Attribute Value" := AttributeValueCode;
        end else
            HLMemberAttribute."HeyLoyalty Attribute Value" :=
                HLMappedValueMgt.GetMappedValue(NPRAttributeValue.RecordId, NPRAttributeValue.FieldNo("Attribute Value Name"), false);
        HLMemberAttribute."Attribute Value Code" := NPRAttributeValue."Attribute Value Code";

        exit(Format(xHLMemberAttribute) <> Format(HLMemberAttribute));
    end;

    local procedure UpdateHLMemberAttribute(HLMember: Record "NPR HL HeyLoyalty Member"; NPRAttributeValueSet: Record "NPR Attribute Value Set"; var HLMemberAttribute: Record "NPR HL Member Attribute"): Boolean
    begin
        exit(UpdateHLMemberAttribute(HLMember, NPRAttributeValueSet."Attribute Code", CopyStr(UpperCase(NPRAttributeValueSet."Text Value"), 1, 20), HLMemberAttribute));
    end;

    local procedure UpdateHLMemberAttribute(HLMember: Record "NPR HL HeyLoyalty Member"; AttributeCode: Code[20]; AttributeValueCode: Code[20]; var HLMemberAttributeOut: Record "NPR HL Member Attribute"): Boolean
    var
        NPRAttributeValue: Record "NPR Attribute Lookup Value";
        HLMemberAttribute: Record "NPR HL Member Attribute";
        xHLMemberAttribute: Record "NPR HL Member Attribute";
        HLMappedValueMgt: Codeunit "NPR HL Mapped Value Mgt.";
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
            HLMemberAttribute."HeyLoyalty Attribute Value" := AttributeValueCode;
        end else
            HLMemberAttribute."HeyLoyalty Attribute Value" :=
                HLMappedValueMgt.GetMappedValue(NPRAttributeValue.RecordId, NPRAttributeValue.FieldNo("Attribute Value Name"), false);
        HLMemberAttribute."Attribute Value Code" := NPRAttributeValue."Attribute Value Code";

        Updated := Format(xHLMemberAttribute) <> Format(HLMemberAttribute);
        if Updated then
            HLMemberAttribute.Modify();
        HLMemberAttributeOut := HLMemberAttribute;
        exit(Updated);
    end;

    procedure UpdateHLMemberAttributeFromHL(HLMember: Record "NPR HL HeyLoyalty Member"; HeyLoyaltyFieldID: Text; HeyLoyaltyAttributeValue: Text; HeyLoyaltyAttributeValueDescription: Text): Boolean
    var
        HLMappedValue: Record "NPR HL Mapped Value";
        HLMemberAttribute: Record "NPR HL Member Attribute";
        xHLMemberAttribute: Record "NPR HL Member Attribute";
        NPRAttribute: Record "NPR Attribute";
        NPRAttributeValue: Record "NPR Attribute Lookup Value";
        HLMappedValueMgt: Codeunit "NPR HL Mapped Value Mgt.";
        RecRef: RecordRef;
        Found: Boolean;
    begin
        if HeyLoyaltyFieldID = '' then
            exit(false);

        if not HLMappedValueMgt.FindMappedValue(Database::"NPR Attribute", NPRAttribute.FieldNo(Code), CopyStr(HeyLoyaltyFieldID, 1, MaxStrLen(HLMappedValue.Value)), RecRef) then
            exit(false);
        RecRef.SetTable(NPRAttribute);
        if not IsSendAttributeToHL(NPRAttribute) then
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

        Found := false;
        HLMappedValueMgt.FilterWhereUsed(
            Database::"NPR Attribute Lookup Value", NPRAttributeValue.FieldNo("Attribute Value Name"), HLMemberAttribute."HeyLoyalty Attribute Value", false, HLMappedValue);
        if HLMappedValue.Find('-') then
            repeat
                if RecRef.Get(HLMappedValue."BC Record ID") then begin
                    RecRef.SetTable(NPRAttributeValue);
                    NPRAttributeValue.Mark(NPRAttributeValue."Attribute Code" = NPRAttribute.Code);
                    Found :=
                        (NPRAttributeValue."Attribute Code" = NPRAttribute.Code) and
                        (NPRAttributeValue."Attribute Value Code" = HLMemberAttribute."Attribute Value Code");
                end;
            until Found or (HLMappedValue.Next() = 0);
        if not Found then begin
            NPRAttributeValue.MarkedOnly(true);
            Found := NPRAttributeValue.FindFirst();
            if not Found and NPRAttribute."HL Auto Create New Values" then begin
                CreateAttributeValue(NPRAttribute.Code, HLMemberAttribute."HeyLoyalty Attribute Value", HeyLoyaltyAttributeValueDescription, NPRAttributeValue);
                Found := true;
            end;
        end;
        if Found then begin
            HLMemberAttribute."Attribute Value Code" := NPRAttributeValue."Attribute Value Code";
            HLMemberAttribute."HeyLoyalty Attribute Value" :=
                HLMappedValueMgt.GetMappedValue(NPRAttributeValue.RecordId, NPRAttributeValue.FieldNo("Attribute Value Name"), false);
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
        HLMappedValueMgt: Codeunit "NPR HL Mapped Value Mgt.";
    begin
        if HLMappedValueMgt.GetMappedValue(NPRAttribute.RecordId(), NPRAttribute.FieldNo(Code), false) = '' then
            exit(false);
        exit(NPRAttributeID.Get(Database::"NPR MM Member", NPRAttribute.Code));
    end;

    local procedure CreateAttributeValue(AttributeCode: Code[20]; HeyLoyaltyAttributeValue: Text[100]; HeyLoyaltyAttributeValueDescription: Text; var NPRAttributeValue: Record "NPR Attribute Lookup Value")
    var
        HLMappedValueMgt: Codeunit "NPR HL Mapped Value Mgt.";
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
        NPRAttributeValue.Insert();
        HLMappedValueMgt.SetMappedValue(NPRAttributeValue.RecordId, NPRAttributeValue.FieldNo("Attribute Value Name"), HeyLoyaltyAttributeValue, false);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCheckIfIsCascadeUpdate(var IsCascadeUpdate: Boolean)
    begin
    end;
}