codeunit 6060080 "NPR UPG POS Rcpt. Profile"
{
    Access = Internal;
    Subtype = Upgrade;

    trigger OnUpgradePerCompany()
    begin
        CreatePOSRcptProfileAndAssignToPOSUnits();
    end;

    local procedure CreatePOSRcptProfileAndAssignToPOSUnits()
    var
        LogMessageStopwatch: Codeunit "NPR LogMessage Stopwatch";
        UpgradeTag: Codeunit "Upgrade Tag";
        UpgradeTagsDef: Codeunit "NPR Upgrade Tag Definitions";
    begin
        LogMessageStopwatch.LogStart(CompanyName(), 'NPR UPG POS Rcpt. Profile', 'CreatePOSRcptProfileAssignToPOSUnits');

        if UpgradeTag.HasUpgradeTag(UpgradeTagsDef.GetUpgradeTag(CurrCodeunitId(), 'CreatePOSRcptProfileAssignToPOSUnits')) then begin
            LogMessageStopwatch.LogFinish();
            exit;
        end;

        CreatePOSRcptProfileAssignToPOSUnits();

        UpgradeTag.SetUpgradeTag(UpgradeTagsDef.GetUpgradeTag(CurrCodeunitId(), 'CreatePOSRcptProfileAssignToPOSUnits'));
        LogMessageStopwatch.LogFinish();
    end;

    local procedure CreatePOSRcptProfileAssignToPOSUnits()
    var
        POSReceiptProfile: Record "NPR POS Receipt Profile";
        POSUnit: Record "NPR POS Unit";
        DefaultCodeLbl: Label 'DEFAULT', Locked = true;
    begin
        if not POSReceiptProfile.Get(DefaultCodeLbl) then begin
            POSReceiptProfile.Init();
            POSReceiptProfile.Code := DefaultCodeLbl;
            POSReceiptProfile.Insert();
        end;

        POSUnit.Reset();
        POSUnit.SetRange("POS Receipt Profile", '');
        if not POSUnit.IsEmpty() then
            POSUnit.ModifyAll("POS Receipt Profile", POSReceiptProfile.Code);
    end;

    local procedure CurrCodeunitId(): Integer
    begin
        exit(Codeunit::"NPR UPG POS Rcpt. Profile");
    end;
}
