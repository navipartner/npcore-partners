codeunit 6059882 "NPR UPG PaymentV2"
{
    Access = Internal;
    Subtype = Upgrade;


    trigger OnUpgradePerCompany()
    var
        LogMessageStopwatch: Codeunit "NPR LogMessage Stopwatch";
        UpgTagDef: Codeunit "NPR Upgrade Tag Definitions";
        UpgradeTagMgt: Codeunit "Upgrade Tag";
    begin
        LogMessageStopwatch.LogStart(CompanyName(), 'NPR UPG PaymentV2 Menu Buttons', 'OnUpgradePerCompany');

        if UpgradeTagMgt.HasUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR UPG PaymentV2")) then begin
            LogMessageStopwatch.LogFinish();
            exit;
        end;

        DiscoverNewActions();
        UpgradePOSMenuPaymentButtons();
        UpgradeNamedActionProfiles();
        UpgradePOSMenuOperationButtons();

        UpgradeTagMgt.SetUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR UPG PaymentV2"));
        LogMessageStopwatch.LogFinish();
    end;

    local procedure UpgradePOSMenuPaymentButtons()
    var
        POSMenuButton: Record "NPR POS Menu Button";
    begin
        POSMenuButton.SetRange("Action Type", POSMenuButton."Action Type"::Action);
        POSMenuButton.SetRange("Action Code", 'PAYMENT');
        if not POSMenuButton.FindSet(true) then
            exit;

        repeat
            POSMenuButton."Action Code" := Format(Enum::"NPR POS Workflow"::PAYMENT_2);
            POSMenuButton.Modify(true);
            POSMenuButton.RefreshParameters();
        until POSMenuButton.Next() = 0;
    end;

    local procedure UpgradePOSMenuOperationButtons()
    var
        POSMenuButton: Record "NPR POS Menu Button";
    begin
        POSMenuButton.SetRange("Action Type", POSMenuButton."Action Type"::Action);
        POSMenuButton.SetRange("Action Code", 'EFT_OPERATION');
        if not POSMenuButton.FindSet(true) then
            exit;

        repeat
            // switch action without validation because we want to reuse the existing action parameters 
            // and then refresh to add some new ones.
            POSMenuButton."Action Code" := Format(Enum::"NPR POS Workflow"::EFT_OPERATION_2);
            POSMenuButton.Modify(true);
            POSMenuButton.RefreshParameters();
        until POSMenuButton.Next() = 0;
    end;
    local procedure UpgradeNamedActionProfiles()
    var
        POSNamedActionProfile: Record "NPR POS Setup";
        ParamMgt: Codeunit "NPR POS Action Param. Mgt.";
    begin
        POSNamedActionProfile.SetRange("Payment Action Code", 'PAYMENT');
        if not POSNamedActionProfile.FindSet(true) then
            exit;

        repeat
            POSNamedActionProfile."Payment Action Code" := Format(Enum::"NPR POS Workflow"::PAYMENT_2);
            POSNamedActionProfile.Modify(true);
            ParamMgt.RefreshParameters(POSNamedActionProfile.RecordId, '', POSNamedActionProfile.FieldNo("Payment Action Code"), POSNamedActionProfile."Payment Action Code");
        until POSNamedActionProfile.Next() = 0;
    end;

    local procedure DiscoverNewActions()
    var
        POSAction: Record "NPR POS Action";
    begin
        POSAction.DiscoverActions();
    end;
}