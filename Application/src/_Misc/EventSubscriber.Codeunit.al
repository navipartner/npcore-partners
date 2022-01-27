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
}
