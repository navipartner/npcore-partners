codeunit 6014440 "NPR Aux. Tables Mgt."
{
    procedure CopyValueEntryToAux(ValueEntry: Record "Value Entry"; ItemJournalLine: Record "Item Journal Line")
    var
        AuxValueEntry: Record "NPR Aux. Value Entry";
    begin
        if AuxValueEntry.IsTemporary() then
            exit;

        AuxValueEntry.Init();
        AuxValueEntry.TransferFields(ValueEntry);

        AuxValueEntry."Item Category Code" := ItemJournalLine."Item Category Code";
        AuxValueEntry."Vendor No." := ItemJournalLine."NPR Vendor No.";
        AuxValueEntry."Discount Type" := ItemJournalLine."NPR Discount Type";
        AuxValueEntry."Discount Code" := ItemJournalLine."NPR Discount Code";
        AuxValueEntry."POS Unit No." := ItemJournalLine."NPR Register Number";
        AuxValueEntry."Group Sale" := ItemJournalLine."NPR Group Sale";
        AuxValueEntry."Salespers./Purch. Code" := ItemJournalLine."Salespers./Purch. Code";
        AuxValueEntry."Document Date and Time" := CreateDateTime(ItemJournalLine."Posting Date", ItemJournalLine."NPR Document Time");

        AuxValueEntry.Insert();
    end;

    procedure CopyItemLedgerEntryToAux(ItemLedgerEntry: Record "Item Ledger Entry"; ItemJournalLine: Record "Item Journal Line")
    var
        AuxItemLedgerEntry: Record "NPR Aux. Item Ledger Entry";
        OldAuxItemLedgerEntry: Record "NPR Aux. Item Ledger Entry";
    begin
        if ItemLedgerEntry.IsTemporary() then
            exit;

        AuxItemLedgerEntry.Init();
        AuxItemLedgerEntry.TransferFields(ItemLedgerEntry);

        AuxItemLedgerEntry."Vendor No." := ItemJournalLine."NPR Vendor No.";
        AuxItemLedgerEntry."Discount Type" := ItemJournalLine."NPR Discount Type";
        AuxItemLedgerEntry."Discount Code" := ItemJournalLine."NPR Discount Code";
        AuxItemLedgerEntry."POS Unit No." := ItemJournalLine."NPR Register Number";
        AuxItemLedgerEntry."Group Sale" := ItemJournalLine."NPR Group Sale";
        AuxItemLedgerEntry."Salespers./Purch. Code" := ItemJournalLine."Salespers./Purch. Code";
        AuxItemLedgerEntry."Document Time" := ItemJournalLine."NPR Document Time";
        AuxItemLedgerEntry."Document Date and Time" := CreateDateTime(ItemJournalLine."Posting Date", AuxItemLedgerEntry."Document Time");

        if ItemLedgerEntry."Entry Type" = ItemLedgerEntry."Entry Type"::Transfer then begin
            OldAuxItemLedgerEntry.SetCurrentKey("New Entry No.");
            OldAuxItemLedgerEntry.SetRange("New Entry No.", ItemLedgerEntry."Entry No.");
            if OldAuxItemLedgerEntry.FindFirst() then begin
                AuxItemLedgerEntry."Vendor No." := OldAuxItemLedgerEntry."Vendor No.";
                AuxItemLedgerEntry."Item Category Code" := OldAuxItemLedgerEntry."Item Category Code";
                AuxItemLedgerEntry."POS Unit No." := OldAuxItemLedgerEntry."POS Unit No.";
                AuxItemLedgerEntry."Salespers./Purch. Code" := OldAuxItemLedgerEntry."Salespers./Purch. Code";

                OldAuxItemLedgerEntry."New Entry No." := 0;
                OldAuxItemLedgerEntry.Modify();
            end;
        end;

        AuxItemLedgerEntry.Insert();
    end;

    procedure UpdateAuxItemLedgerEntry(ItemLedgerEntry: Record "Item Ledger Entry")
    var
        AuxItemLedgerEntry: Record "NPR Aux. Item Ledger Entry";
    begin
        if ItemLedgerEntry.IsTemporary() then
            exit;

        if not AuxItemLedgerEntry.Get(ItemLedgerEntry."Entry No.") then
            exit;

        AuxItemLedgerEntry."Invoiced Quantity" := ItemLedgerEntry."Invoiced Quantity";
        AuxItemLedgerEntry.Modify();
    end;
}