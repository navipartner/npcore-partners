codeunit 6014405 "NPR UPG Aux. Tables"
{
    Subtype = Upgrade;

    trigger OnUpgradePerCompany()
    begin
        Upgrade();
    end;

    local procedure Upgrade()
    var
        LogMessageStopwatch: Codeunit "NPR LogMessage Stopwatch";
        UpgradeTag: Codeunit "Upgrade Tag";
        UpgradeTagLbl: Label 'NPRPUGAuxTables_Upgrade-20210315-01', Locked = true;
    begin
        LogMessageStopwatch.LogStart(CompanyName(), 'NPR UPG Aux. Tables', 'Upgrade');

        if UpgradeTag.HasUpgradeTag(UpgradeTagLbl) then begin
            LogMessageStopwatch.LogFinish();
            exit;
        end;

        // "Aux. Value Entry" and "Aux. Item Ledger Entry" must be upgraded on sql side.
        //
        // UpgradeValueEntry();
        // UpgradeItemLedgerEntry();
        UpgradeGLAccount();

        UpgradeTag.SetUpgradeTag(UpgradeTagLbl);

        LogMessageStopwatch.LogFinish();
    end;

    local procedure UpgradeValueEntry()
    var
        ValueEntry: Record "Value Entry";
        AuxValueEntry: Record "NPR Aux. Value Entry";
    begin
        ValueEntry.Reset();
        if not ValueEntry.FindSet() then
            exit;

        repeat
            if not AuxValueEntry.Get(ValueEntry."Entry No.") then begin
                AuxValueEntry.Init();
                AuxValueEntry.TransferFields(ValueEntry);
                AuxValueEntry."Item Category Code" := ValueEntry."NPR Item Group No.";
                AuxValueEntry.Insert();
            end
        until ValueEntry.Next() = 0;
    end;

    local procedure UpgradeItemLedgerEntry()
    var
        ItemLedgEntry: Record "Item Ledger Entry";
        AuxItemLedgerEntry: Record "NPR Aux. Item Ledger Entry";
    begin
        ItemLedgEntry.Reset();
        if not ItemLedgEntry.FindSet() then
            exit;

        repeat
            if not AuxItemLedgerEntry.Get(ItemLedgEntry."Entry No.") then begin
                AuxItemLedgerEntry.Init();
                AuxItemLedgerEntry.TransferFields(ItemLedgEntry);
                AuxItemLedgerEntry."Item Category Code" := ItemLedgEntry."NPR Item Group No.";
                AuxItemLedgerEntry.Insert();
            end
        until ItemLedgEntry.Next() = 0;
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
