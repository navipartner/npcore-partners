codeunit 6014404 "NPR Event Subscriber"
{
    Access = Internal;
    SingleInstance = true; //For performance, not state sharing.

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Item Jnl.-Post Line", 'OnBeforeInsertTransferEntry', '', true, false)]
    local procedure ItemJnlPostLineOnBeforeInsertTransferEntry(var NewItemLedgerEntry: Record "Item Ledger Entry"; var OldItemLedgerEntry: Record "Item Ledger Entry"; var ItemJournalLine: Record "Item Journal Line")
    var
    begin
        NewItemLedgerEntry."Item Reference No." := OldItemLedgerEntry."Item Reference No.";
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Item Jnl.-Post Line", 'OnBeforePostItemJnlLine', '', false, false)]
    local procedure ItemJnlPostLineOnBeforePostItemJnlLine(var ItemJournalLine: Record "Item Journal Line")
    var
        Item: Record Item;
    begin
        if (ItemJournalLine."NPR Vendor No." <> '') and (ItemJournalLine."NPR Item Group No." <> '') then
            exit;
        if not Item.Get(ItemJournalLine."Item No.") then
            exit;

        if ItemJournalLine."NPR Vendor No." = '' then
            ItemJournalLine."NPR Vendor No." := Item."Vendor No.";
        if ItemJournalLine."NPR Document Time" = 0T then
            ItemJournalLine."NPR Document Time" := Time;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnBeforePostSalesDoc', '', true, false)]
    local procedure SalesPostOnBeforePostSalesDoc(var SalesHeader: Record "Sales Header")
    begin
        SalesHeader.TestField("Salesperson Code");
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnAfterPostSalesDoc', '', false, false)]
    local procedure SalesPostOnAfterPostSalesDoc(var SalesHeader: Record "Sales Header"; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; SalesShptHdrNo: Code[20]; RetRcpHdrNo: Code[20]; SalesInvHdrNo: Code[20]; SalesCrMemoHdrNo: Code[20])
    var
        ConsignorEntry: Record "NPR Consignor Entry";
        SalesShptHeader: Record "Sales Shipment Header";
        SalesSetup: Record "Sales & Receivables Setup";
        ShipmentDocument: Record "NPR Shipping Provider Document";
        PacsoftSetup: Record "NPR Shipping Provider Setup";
        RecRefShipment: RecordRef;
    begin
        SalesSetup.Get();
        if SalesHeader.Ship then
            if (SalesHeader."Document Type" = SalesHeader."Document Type"::Order) or
                ((SalesHeader."Document Type" = SalesHeader."Document Type"::Invoice) and SalesSetup."Shipment on Invoice") then
                if SalesShptHeader.Get(SalesShptHdrNo) then begin
                    if (PacsoftSetup.Get()) and (PacsoftSetup."Create Pacsoft Document") then begin
                        RecRefShipment.GetTable(SalesShptHeader);
                        ShipmentDocument.AddEntry(RecRefShipment, false);
                    end;
                    ConsignorEntry.InsertFromShipmentHeader(SalesShptHeader."No.");
                end;
    end;

    [EventSubscriber(ObjectType::Page, Page::"Feature Management", 'OnOpenFeatureMgtPage', '', false, false)]
    local procedure NPRFeatureManagementOnOpenFeatureMgtPage(var IgnoreFilter: Boolean)
    begin
        IgnoreFilter := true;
    end;

    #region Table - G/L Account
    [EventSubscriber(ObjectType::Table, Database::"G/L Account", 'OnBeforeValidateEvent', 'Blocked', false, false)]
    local procedure GLAccount_OnBeforeValidateEventBlocked(var Rec: Record "G/L Account"; var xRec: Record "G/L Account"; CurrFieldNo: Integer)
    var
        POSPostingSetup: Record "NPR POS Posting Setup";
        BlockGLAcc1Err: Label 'You can''t block GL Account %1 as there are one or more active %2 that post to it. ', Comment = '%1 = GL Account, %2 = POS Posting Setup';
    begin
        if Rec.Blocked then begin
            POSPostingSetup.SetRange("Account No.", Rec."No.");

            if not POSPostingSetup.IsEmpty() then
                Error(BlockGLAcc1Err, Rec."No.", POSPostingSetup.TableCaption());
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"G/L Account", 'OnBeforeDeleteEvent', '', false, false)]
    local procedure GLAccount_OnBeforeDeleteEvent(var Rec: Record "G/L Account"; RunTrigger: Boolean)
    var
        POSPostingSetup: Record "NPR POS Posting Setup";
        BlockGLAccErr: Label 'You cannot delete GL Account %1 as there are one or more active %2 that post to it. ', Comment = '%1 = "GL Account"."No.", %2 = "POS Posting Setup".TableCaption()';
    begin
        //In case Test Table Relation is skipped on POS Posting Setup, call this procedure before renaming G/L Account
        if Rec.Blocked then begin
            POSPostingSetup.SetRange("Account No.", Rec."No.");
            if not POSPostingSetup.IsEmpty() then
                Error(BlockGLAccErr, Rec."No.", POSPostingSetup.TableCaption());
        end;
    end;
    #endregion
}
