codeunit 6014405 "NPR UPG Aux. Tables"
{
    Access = Internal;
    Subtype = Upgrade;

    trigger OnUpgradePerCompany()
    begin
        Upgrade();
    end;

    local procedure Upgrade()
    var
        LogMessageStopwatch: Codeunit "NPR LogMessage Stopwatch";
        UpgradeTag: Codeunit "Upgrade Tag";
        UpgTagDef: Codeunit "NPR Upgrade Tag Definitions";
    begin
        LogMessageStopwatch.LogStart(CompanyName(), 'NPR UPG Aux. Tables', 'Upgrade');

        if UpgradeTag.HasUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR UPG Aux. Tables")) then begin
            LogMessageStopwatch.LogFinish();
            exit;
        end;

        // "Aux. Value Entry" and "Aux. Item Ledger Entry" must be upgraded on sql side.
        //
        // UpgradeValueEntry();
        // UpgradeItemLedgerEntry();
        UpgradeGLAccount();

        UpgradeTag.SetUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR UPG Aux. Tables"));

        LogMessageStopwatch.LogFinish();
    end;

    local procedure UpgradeGLAccount()
    var
        GLAccount: Record "G/L Account";
        AuxGLAccount: Record "NPR Aux. G/L Account";
    begin
        GLAccount.Reset();
        if not GLAccount.FindSet() then
            exit;

        repeat
            if not AuxGLAccount.Get(GLAccount."No.") then begin
                AuxGLAccount.Init();
                AuxGLAccount.TransferFields(GLAccount);
                AuxGLAccount."Retail Payment" := GLAccount."NPR Retail Payment";
                AuxGLAccount.Insert();
            end;
        until GLAccount.Next() = 0;
    end;
}
