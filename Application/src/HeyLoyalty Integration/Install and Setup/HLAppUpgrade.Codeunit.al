codeunit 6059988 "NPR HL App Upgrade"
{
    Access = Internal;
    Subtype = Upgrade;

    trigger OnUpgradePerCompany()
    begin
        MoveHeyLoyaltyValueMappings();
        SetHLSetupDefaultValues();
        RemoveDeletedCheckmark();
        UpdateHeyLoyaltyDataLogSubscribers();
    end;

    var
        LogMessageStopwatch: Codeunit "NPR LogMessage Stopwatch";
        UpgradeTag: Codeunit "Upgrade Tag";
        UpgTagDef: Codeunit "NPR Upgrade Tag Definitions";

    local procedure MoveHeyLoyaltyValueMappings()
    var
        CountryRegion: Record "Country/Region";
        CountryRegion2: Record "Country/Region";
        NPRAttribute: Record "NPR Attribute";
        NPRAttribute2: Record "NPR Attribute";
        NPRAttributeValue: Record "NPR Attribute Lookup Value";
        NPRAttributeValue2: Record "NPR Attribute Lookup Value";
        MMMembershipSetup: Record "NPR MM Membership Setup";
        MMMembershipSetup2: Record "NPR MM Membership Setup";
        HLMappedValueMgt: Codeunit "NPR HL Mapped Value Mgt.";
    begin
        if UpgradeTag.HasUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR HL App Upgrade", 'MoveHeyLoyaltyValueMappings')) then
            exit;
        LogMessageStopwatch.LogStart(CompanyName(), 'NPR HL App Upgrade', 'MoveHeyLoyaltyValueMappings');

        NPRAttributeValue.SetFilter("HeyLoyalty Value", '<>%1', '');
        if NPRAttributeValue.FindSet(true) then
            repeat
                HLMappedValueMgt.SetMappedValue(
                    NPRAttributeValue.RecordId(), NPRAttributeValue.FieldNo("Attribute Value Name"), NPRAttributeValue."HeyLoyalty Value", false);
                NPRAttributeValue2 := NPRAttributeValue;
                NPRAttributeValue2."HeyLoyalty Value" := '';
                NPRAttributeValue2.Modify();
            until NPRAttributeValue.Next() = 0;

        MMMembershipSetup.SetFilter("HeyLoyalty Name", '<>%1', '');
        if MMMembershipSetup.FindSet(true) then
            repeat
                HLMappedValueMgt.SetMappedValue(
                    MMMembershipSetup.RecordId(), MMMembershipSetup.FieldNo(Description), MMMembershipSetup."HeyLoyalty Name", false);
                MMMembershipSetup2 := MMMembershipSetup;
                MMMembershipSetup2."HeyLoyalty Name" := '';
                MMMembershipSetup2.Modify();
            until MMMembershipSetup.Next() = 0;

        if NPRAttribute.FindSet(true) then
            repeat
                if (NPRAttribute."HeyLoyalty Field ID" <> '') or (NPRAttribute."HeyLoyalty Default Value" <> '') then begin
                    if NPRAttribute."HeyLoyalty Field ID" <> '' then
                        HLMappedValueMgt.SetMappedValue(NPRAttribute.RecordId(), NPRAttribute.FieldNo(Code), NPRAttribute."HeyLoyalty Field ID", false);
                    if NPRAttribute."HeyLoyalty Default Value" <> '' then
                        HLMappedValueMgt.SetMappedValue(NPRAttribute.RecordId(), 0, NPRAttribute."HeyLoyalty Default Value", false);
                    NPRAttribute2 := NPRAttribute;
                    NPRAttribute2."HeyLoyalty Field ID" := '';
                    NPRAttribute2."HeyLoyalty Default Value" := '';
                    NPRAttribute2.Modify();
                end;
            until NPRAttribute.Next() = 0;

        CountryRegion.SetFilter("NPR HL Country ID", '<>%1', '');
        if CountryRegion.FindSet(true) then
            repeat
                HLMappedValueMgt.SetMappedValue(
                    CountryRegion.RecordId(), CountryRegion.FieldNo(Code), CountryRegion."NPR HL Country ID", false);
                CountryRegion2 := CountryRegion;
                CountryRegion2."NPR HL Country ID" := '';
                CountryRegion2.Modify();
            until CountryRegion.Next() = 0;

        UpgradeTag.SetUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR HL App Upgrade", 'MoveHeyLoyaltyValueMappings'));
        LogMessageStopwatch.LogFinish();
    end;

    local procedure SetHLSetupDefaultValues()
    var
        HLSetup: Record "NPR HL Integration Setup";
    begin
        if UpgradeTag.HasUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR HL App Upgrade", 'SetHLSetupDefaultValues')) then
            exit;
        LogMessageStopwatch.LogStart(CompanyName(), 'NPR HL App Upgrade', 'SetHLSetupDefaultValues');

        if HLSetup.Get() then begin
            HLSetup."Require GDPR Approval" := true;
            HLSetup."Require Newsletter Subscrip." := true;
            HLSetup.Modify();
        end;

        UpgradeTag.SetUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR HL App Upgrade", 'SetHLSetupDefaultValues'));
        LogMessageStopwatch.LogFinish();
    end;

    local procedure RemoveDeletedCheckmark()
    var
        Member: Record "NPR MM Member";
        HLMember: Record "NPR HL HeyLoyalty Member";
        HLMember2: Record "NPR HL HeyLoyalty Member";
    begin
        if UpgradeTag.HasUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR HL App Upgrade", 'RemoveDeletedCheckmark')) then
            exit;
        LogMessageStopwatch.LogStart(CompanyName(), 'NPR HL App Upgrade', 'RemoveDeletedCheckmark');

        HLMember.SetRange(Deleted, true);
        HLMember.SetFilter("Member Entry No.", '<>%1', 0);
        if HLMember.FindSet(true) then
            repeat
                if Member.Get(HLMember."Member Entry No.") then begin
                    HLMember2 := HLMember;
                    HLMember2.Deleted := false;
                    HLMember2.Modify();
                end;
            until HLMember.Next() = 0;

        UpgradeTag.SetUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR HL App Upgrade", 'RemoveDeletedCheckmark'));
        LogMessageStopwatch.LogFinish();
    end;

    local procedure UpdateHeyLoyaltyDataLogSubscribers()
    var
        DataLogSubscriber: Record "NPR Data Log Subscriber";
        HLIntegrationMgt: Codeunit "NPR HL Integration Mgt.";
    begin
        if UpgradeTag.HasUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR HL App Upgrade", 'UpdateHeyLoyaltyDataLogSubscribers')) then
            exit;
        LogMessageStopwatch.LogStart(CompanyName(), 'NPR HL App Upgrade', 'UpdateHeyLoyaltyDataLogSubscribers');

        DataLogSubscriber.SetRange(Code, HLIntegrationMgt.HeyLoyaltyCode());
        if not DataLogSubscriber.IsEmpty() then
            DataLogSubscriber.ModifyAll("Delayed Data Processing (sec)", 20);

        UpgradeTag.SetUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR HL App Upgrade", 'UpdateHeyLoyaltyDataLogSubscribers'));
        LogMessageStopwatch.LogFinish();
    end;
}