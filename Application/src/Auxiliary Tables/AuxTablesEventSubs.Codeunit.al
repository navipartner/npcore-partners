codeunit 6014460 "NPR Aux. Tables Event Subs."
{

    #region Aux. Value Entry

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Item Jnl.-Post Line", 'OnAfterInsertValueEntry', '', false, false)]
    local procedure ItemJnlPostLineOnAfterInsertValueEntry(var ValueEntry: Record "Value Entry"; ItemJournalLine: Record "Item Journal Line"; var ItemLedgerEntry: Record "Item Ledger Entry")
    var
        AuxTablesMgt: Codeunit "NPR Aux. Tables Mgt.";
    begin
        AuxTablesMgt.CopyValueEntryToAux(ValueEntry, ItemJournalLine);
        AuxTablesMgt.UpdateAuxItemLedgerEntry(ItemLedgerEntry);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Item Jnl.-Post Line", 'OnAfterInsertCorrValueEntry', '', false, false)]
    local procedure ItemJnlPostLineOnAfterInsertCorrValueEntry(var NewValueEntry: Record "Value Entry"; var ItemJournalLine: Record "Item Journal Line")
    var
        AuxTablesMgt: Codeunit "NPR Aux. Tables Mgt.";
    begin
        AuxTablesMgt.CopyValueEntryToAux(NewValueEntry, ItemJournalLine);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Value Entry", 'OnAfterDeleteEvent', '', false, false)]
    local procedure ValueEntryOnAfterDelete(var Rec: Record "Value Entry")
    var
        AuxValueEntry: Record "NPR Aux. Value Entry";
    begin
        if Rec.IsTemporary() then
            exit;

        if AuxValueEntry.Get(Rec."Entry No.") then
            AuxValueEntry.Delete();
    end;

    #endregion

    #region Aux. Item Ledger Entry

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Item Jnl.-Post Line", 'OnBeforeInsertTransferEntry', '', true, false)]
    local procedure ItemJnlPostLineOnBeforeInsertTransferEntry(var NewItemLedgerEntry: Record "Item Ledger Entry"; var OldItemLedgerEntry: Record "Item Ledger Entry")
    var
        AuxItemLedgerEntry: Record "NPR Aux. Item Ledger Entry";
    begin
        if OldItemLedgerEntry."Entry No." = 0 then
            exit;

        if not AuxItemLedgerEntry.Get(OldItemLedgerEntry."Entry No.") then
            exit;

        AuxItemLedgerEntry."New Entry No." := NewItemLedgerEntry."Entry No.";
        AuxItemLedgerEntry.Modify();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Item Jnl.-Post Line", 'OnAfterInsertItemLedgEntry', '', false, false)]
    local procedure ItemJnlPostLineOnAfterInsertItemLedgEntry(var ItemLedgerEntry: Record "Item Ledger Entry"; ItemJournalLine: Record "Item Journal Line")
    var
        AuxTablesMgt: Codeunit "NPR Aux. Tables Mgt.";
    begin
        AuxTablesMgt.CopyItemLedgerEntryToAux(ItemLedgerEntry, ItemJournalLine);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Item Jnl.-Post Line", 'OnAfterInsertCorrItemLedgEntry', '', false, false)]
    local procedure ItemJnlPostLineOnAfterInsertCorrItemLedgEntry(var NewItemLedgerEntry: Record "Item Ledger Entry"; var ItemJournalLine: Record "Item Journal Line")
    var
        AuxTablesMgt: Codeunit "NPR Aux. Tables Mgt.";
    begin
        AuxTablesMgt.CopyItemLedgerEntryToAux(NewItemLedgerEntry, ItemJournalLine);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Item Ledger Entry", 'OnAfterDeleteEvent', '', false, false)]
    local procedure ItemLedgerEntryOnAfterDelete(var Rec: Record "Item Ledger Entry")
    var
        AuxItemLedgerEntry: Record "NPR Aux. Item Ledger Entry";
    begin
        if Rec.IsTemporary() then
            exit;

        if AuxItemLedgerEntry.Get(Rec."Entry No.") then
            AuxItemLedgerEntry.Delete();
    end;

    #endregion

    #region G/L Account

    [EventSubscriber(ObjectType::Table, Database::"G/L Account", 'OnAfterInsertEvent', '', false, false)]
    local procedure GLAccountOnAfterInsert(var Rec: Record "G/L Account")
    var
        AuxGLAccount: Record "NPR Aux. G/L Account";
    begin
        if Rec.IsTemporary() then
            exit;

        AuxGLAccount.Init();
        AuxGLAccount.TransferFields(Rec);
        AuxGLAccount.Insert();
    end;

    [EventSubscriber(ObjectType::Table, Database::"G/L Account", 'OnAfterDeleteEvent', '', false, false)]
    local procedure GLAccountOnAfterDelete(var Rec: Record "G/L Account")
    var
        AuxGLAccount: Record "NPR Aux. G/L Account";
    begin
        if Rec.IsTemporary() then
            exit;

        if AuxGLAccount.Get(Rec."No.") then
            AuxGLAccount.Delete();
    end;


    [EventSubscriber(ObjectType::Table, Database::"G/L Account", 'OnAfterRenameEvent', '', false, false)]
    local procedure GLAccountOnAfterRename(var Rec: Record "G/L Account"; var xRec: Record "G/L Account")
    var
        AuxGLAccount: Record "NPR Aux. G/L Account";
    begin
        if Rec.IsTemporary() then
            exit;

        if AuxGLAccount.Get(xRec."No.") then
            AuxGLAccount.Rename(Rec."No.");
    end;

    #endregion
}