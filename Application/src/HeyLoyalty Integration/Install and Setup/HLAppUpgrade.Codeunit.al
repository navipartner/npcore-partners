codeunit 6059988 "NPR HL App Upgrade"
{
    Access = Internal;
    Subtype = Upgrade;

    trigger OnUpgradePerCompany()
    begin
        MoveHeyLoyaltyValueMappings();
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
        if not UpgradeTag.HasUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR HL App Upgrade", 'MoveHeyLoyaltyValueMappings')) then begin
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
    end;
}