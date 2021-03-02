codeunit 6014404 "NPR Event Subscriber"
{
    SingleInstance = true; //For performance, not state sharing. - TODO: Split up into smaller codeunits instead of one big and move page subscribers to pageextensions.

    var
        RegisterCodeAlreadyUsedErr: Label 'Register Code %1 already exists.', Comment = '%1 = Register Code';
        SalesPersonDeleteErr: Label 'you cannot delete Salesperson/purchaser %1 before the sale is posted in the Audit roll!', Comment = '%1 = Salesperson/purchaser';


    [EventSubscriber(ObjectType::Table, Database::"Salesperson/Purchaser", 'OnAfterDeleteEvent', '', true, false)]
    local procedure SalespersonPurchaserOnAfterDeleteEvent(var Rec: Record "Salesperson/Purchaser"; RunTrigger: Boolean)
    var
        POSEntry: Record "NPR POS Entry";
    begin
        if RunTrigger then begin
            POSEntry.SetRange("Salesperson Code", Rec.Code);
            POSEntry.SetFilter("Post Entry Status", '%1|%2', POSEntry."Post Entry Status"::Unposted,
                POSEntry."Post Entry Status"::"Error while Posting");
            if not POSEntry.IsEmpty then
                Error(SalesPersonDeleteErr, Rec.Code);
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Salesperson/Purchaser", 'OnAfterValidateEvent', 'NPR Register Password', true, false)]
    local procedure SalespersonPurchaserOnAfterValidateEventRegisterPassword(var Rec: Record "Salesperson/Purchaser"; var xRec: Record "Salesperson/Purchaser"; CurrFieldNo: Integer)
    begin
        Rec.SetRange("NPR Register Password", Rec."NPR Register Password");
        if not Rec.IsEmpty() then
            Error(RegisterCodeAlreadyUsedErr, Rec."NPR Register Password");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Default Dimension", 'OnAfterInsertEvent', '', false, false)]
    local procedure DefaultDimensionOnAfterInsertEvent(var Rec: Record "Default Dimension"; RunTrigger: Boolean)
    var
        GLSetup: Record "General Ledger Setup";
        DefaultDimensionMgt: Codeunit "NPR Default Dimension Mgt.";
    begin
        if RunTrigger then begin
            GLSetup.Get();
            if Rec."Dimension Code" = GLSetup."Global Dimension 1 Code" then
                DefaultDimensionMgt.UpdateGlobalDimCode(1, Rec."Table ID", Rec."No.", Rec."Dimension Value Code");
            if Rec."Dimension Code" = GLSetup."Global Dimension 2 Code" then
                DefaultDimensionMgt.UpdateGlobalDimCode(2, Rec."Table ID", Rec."No.", Rec."Dimension Value Code");
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Default Dimension", 'OnAfterModifyEvent', '', false, false)]
    local procedure DefaultDimensionOnAfterModifyEvent(var Rec: Record "Default Dimension"; var xRec: Record "Default Dimension"; RunTrigger: Boolean)
    var
        GLSetup: Record "General Ledger Setup";
        DefaultDimensionMgt: Codeunit "NPR Default Dimension Mgt.";
    begin
        if RunTrigger then begin
            GLSetup.Get();
            if Rec."Dimension Code" = GLSetup."Global Dimension 1 Code" then
                DefaultDimensionMgt.UpdateGlobalDimCode(1, Rec."Table ID", Rec."No.", Rec."Dimension Value Code");
            if Rec."Dimension Code" = GLSetup."Global Dimension 2 Code" then
                DefaultDimensionMgt.UpdateGlobalDimCode(2, Rec."Table ID", Rec."No.", Rec."Dimension Value Code");
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Default Dimension", 'OnAfterDeleteEvent', '', false, false)]
    local procedure DefaultDimensionOnAfterDeleteEvent(var Rec: Record "Default Dimension"; RunTrigger: Boolean)
    var
        GLSetup: Record "General Ledger Setup";
        DefaultDimensionMgt: Codeunit "NPR Default Dimension Mgt.";
    begin
        if RunTrigger then begin
            GLSetup.Get();
            if Rec."Dimension Code" = GLSetup."Global Dimension 1 Code" then
                DefaultDimensionMgt.UpdateGlobalDimCode(1, Rec."Table ID", Rec."No.", '');
            if Rec."Dimension Code" = GLSetup."Global Dimension 2 Code" then
                DefaultDimensionMgt.UpdateGlobalDimCode(2, Rec."Table ID", Rec."No.", '');
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Item Jnl.-Post Line", 'OnBeforeInsertTransferEntry', '', true, false)]
    local procedure ItemJnlPostLineOnBeforeInsertTransferEntry(var NewItemLedgerEntry: Record "Item Ledger Entry"; var OldItemLedgerEntry: Record "Item Ledger Entry"; var ItemJournalLine: Record "Item Journal Line")
    var
        RetailItemSetup: Record "NPR Retail Item Setup";
    begin
        RetailItemSetup.Get();
        NewItemLedgerEntry."NPR Vendor No." := OldItemLedgerEntry."NPR Vendor No.";
        NewItemLedgerEntry."NPR Item Group No." := OldItemLedgerEntry."NPR Item Group No.";
        NewItemLedgerEntry."NPR Register Number" := OldItemLedgerEntry."NPR Register Number";
        NewItemLedgerEntry."NPR Salesperson Code" := OldItemLedgerEntry."NPR Salesperson Code";
        if RetailItemSetup."Transfer SeO Item Entry" then
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
        if ItemJournalLine."NPR Item Group No." = '' then
            ItemJournalLine."NPR Item Group No." := Item."NPR Item Group";
        if ItemJournalLine."NPR Document Time" = 0T then
            ItemJournalLine."NPR Document Time" := Time;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Item Jnl.-Post Line", 'OnAfterInitItemLedgEntry', '', true, false)]
    local procedure ItemJnlPostLineOnAfterInitItemLedgEntry(var NewItemLedgEntry: Record "Item Ledger Entry"; ItemJournalLine: Record "Item Journal Line"; var ItemLedgEntryNo: Integer)
    var
        Item: Record Item;
    begin
        NewItemLedgEntry."NPR Vendor No." := ItemJournalLine."NPR Vendor No.";
        NewItemLedgEntry."NPR Item Group No." := ItemJournalLine."NPR Item Group No.";
        NewItemLedgEntry."NPR Discount Type" := ItemJournalLine."NPR Discount Type";
        NewItemLedgEntry."NPR Discount Code" := ItemJournalLine."NPR Discount Code";
        NewItemLedgEntry."NPR Register Number" := ItemJournalLine."NPR Register Number";
        NewItemLedgEntry."NPR Group Sale" := ItemJournalLine."NPR Group Sale";
        NewItemLedgEntry."NPR Salesperson Code" := ItemJournalLine."Salespers./Purch. Code";
        NewItemLedgEntry."NPR Document Time" := ItemJournalLine."NPR Document Time";
        NewItemLedgEntry."NPR Document Date and Time" := CreateDateTime(ItemJournalLine."Posting Date", NewItemLedgEntry."NPR Document Time");
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Item Jnl.-Post Line", 'OnBeforeInsertValueEntry', '', false, false)]
    local procedure ItemJnlPostLineOnBeforeInsertValueEntry(var ValueEntry: Record "Value Entry"; ItemJournalLine: Record "Item Journal Line")
    var
        Item: Record Item;
    begin
        ValueEntry."NPR Item Group No." := ItemJournalLine."NPR Item Group No.";
        ValueEntry."NPR Vendor No." := ItemJournalLine."NPR Vendor No.";
        ValueEntry."NPR Discount Type" := ItemJournalLine."NPR Discount Type";
        ValueEntry."NPR Discount Code" := ItemJournalLine."NPR Discount Code";
        ValueEntry."NPR Register No." := ItemJournalLine."NPR Register Number";
        ValueEntry."NPR Group Sale" := ItemJournalLine."NPR Group Sale";
        ValueEntry."NPR Salesperson Code" := ItemJournalLine."Salespers./Purch. Code";
        ValueEntry."NPR Document Date and Time" := CreateDateTime(ItemJournalLine."Posting Date", ItemJournalLine."NPR Document Time");
        ValueEntry."NPR Item Category Code" := ItemJournalLine."Item Category Code";
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnBeforePostSalesDoc', '', true, false)]
    local procedure SalesPostOnBeforePostSalesDoc(var SalesHeader: Record "Sales Header")
    var
        RetailSetup: Record "NPR NP Retail Setup";
    begin
        if not RetailSetup.Get() then
            RetailSetup.Init();
        if RetailSetup."Salespersoncode on Salesdoc." = RetailSetup."Salespersoncode on Salesdoc."::Forced then
            SalesHeader.TestField("Salesperson Code");
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnAfterPostSalesDoc', '', false, false)]
    local procedure SalesPostOnAfterPostSalesDoc(var SalesHeader: Record "Sales Header"; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; SalesShptHdrNo: Code[20]; RetRcpHdrNo: Code[20]; SalesInvHdrNo: Code[20]; SalesCrMemoHdrNo: Code[20])
    var
        RecRef: RecordRef;
        SalesInvHeader: Record "Sales Invoice Header";
        "NaviDocs Management": Codeunit "NPR NaviDocs Management";
        SalesShptHeader: Record "Sales Shipment Header";
        SalesSetup: Record "Sales & Receivables Setup";
        ShipmentDocument: Record "NPR Pacsoft Shipment Document";
        RecRefShipment: RecordRef;
        PacsoftSetup: Record "NPR Pacsoft Setup";
        ConsignorEntry: Record "NPR Consignor Entry";
    begin
        SalesSetup.Get();
        if SalesHeader.Ship then
            if (SalesHeader."Document Type" = SalesHeader."Document Type"::Order) or
                ((SalesHeader."Document Type" = SalesHeader."Document Type"::Invoice) and SalesSetup."Shipment on Invoice") then
                if SalesShptHeader.Get(SalesShptHdrNo) then begin
                    if (PacsoftSetup.Get) and (PacsoftSetup."Create Pacsoft Document") then begin
                        RecRefShipment.GetTable(SalesShptHeader);
                        ShipmentDocument.AddEntry(RecRefShipment, false);
                    end;
                    ConsignorEntry.InsertFromShipmentHeader(SalesShptHeader."No.");
                end;
    end;

    [EventSubscriber(ObjectType::Page, Page::"Item Card", 'OnAfterActionEvent', 'NPR AttributeValues', false, false)]
    local procedure ItemCardOnAfterActionEventNPRAttributeValues(var Rec: Record Item)
    var
        NPRAttrManagement: Codeunit "NPR Attribute Management";
    begin
        NPRAttrManagement.ShowMasterDataAttributeValues(DATABASE::Item, Rec."No.");
    end;

    [EventSubscriber(ObjectType::Page, Page::"Sales Order", 'OnAfterActionEvent', 'NPR Consignor Label', false, false)]
    local procedure SalesOrderOnAfterActionEventConsignorLabel(var Rec: Record "Sales Header")
    var
        ConsignorEntry: Record "NPR Consignor Entry";
    begin
        ConsignorEntry.InsertFromSalesHeader(Rec."No.");
    end;

    [EventSubscriber(ObjectType::Page, Page::"Sales Order", 'OnAfterActionEvent', 'NPR Import From Scanner', false, false)]
    local procedure SalesOrderOnAferActionEventImportFromScanner(var Rec: Record "Sales Header")
    var
        ImportfromScannerFileSO: XMLport "NPR Import from ScannerFileSO";
    begin
        ImportfromScannerFileSO.SelectTable(Rec);
        ImportfromScannerFileSO.SetTableView(Rec);
        ImportfromScannerFileSO.Run();
    end;

    [EventSubscriber(ObjectType::Page, Page::"Sales Order", 'OnAfterActionEvent', 'NPR InsertLineItem ', true, true)]
    local procedure SalesOrderOnAfterActionInsertLinewithItem(var Rec: Record "Sales Header")
    var
        RetailItemList: Page "Item List";
        Item: Record Item;
        SalesLine: Record "Sales Line";
        LastSalesLine: Record "Sales Line";
        ReturntoSO: Boolean;
        ViewText: Text;
        InputQuantity: Decimal;
        InputDialog: Page "NPR Input Dialog";
    begin
        Rec.TestField(Status, Rec.Status::Open);
        Rec.TestField("Sell-to Customer No.");
        RetailItemList.NPR_SetLocationCode(Rec."Location Code");
        RetailItemList.NPR_SetBlocked(2);
        RetailItemList.LookupMode := true;
        while RetailItemList.RunModal = ACTION::LookupOK do begin
            RetailItemList.GetRecord(Item);

            InputQuantity := 1;
            InputDialog.SetAutoCloseOnValidate(true);
            InputDialog.SetInput(1, InputQuantity, SalesLine.FieldCaption(Quantity));
            InputDialog.RunModal();
            InputDialog.InputDecimal(1, InputQuantity);
            Clear(InputDialog);

            LastSalesLine.Reset();
            LastSalesLine.SetRange("Document Type", Rec."Document Type");
            LastSalesLine.SetRange("Document No.", Rec."No.");
            if not LastSalesLine.FindLast() then
                LastSalesLine.Init();

            SalesLine.Init();
            SalesLine.Validate("Document Type", Rec."Document Type");
            SalesLine.Validate("Document No.", Rec."No.");
            SalesLine.Validate("Line No.", LastSalesLine."Line No." + 10000);
            SalesLine.Insert(true);
            SalesLine.Validate(Type, SalesLine.Type::Item);
            SalesLine.Validate("No.", Item."No.");
            SalesLine.Validate(Quantity, InputQuantity);
            SalesLine.Modify(true);
            Commit();
            ViewText := RetailItemList.NPR_GetViewText;
            Clear(RetailItemList);
            RetailItemList.NPR_SetLocationCode(Rec."Location Code");
            RetailItemList.NPR_SetVendorNo(Rec."NPR Buy-From Vendor No.");
            Item.SetView(ViewText);
            RetailItemList.SetTableView(Item);
            RetailItemList.SetRecord(Item);
            RetailItemList.LookupMode := true;
        end;
    end;

    [EventSubscriber(ObjectType::Page, Page::"Sales Invoice", 'OnAfterActionEvent', 'NPR ImportFromScanner', false, false)]
    local procedure SalesInvoiceOnAfterActionEventImportFromScannerFile(var Rec: Record "Sales Header")
    var
        ImportfromScannerFileSO: XMLport "NPR Import from ScannerFileSO";
    begin
        ImportfromScannerFileSO.SelectTable(Rec);
        ImportfromScannerFileSO.SetTableView(Rec);
        ImportfromScannerFileSO.Run();
    end;

    [EventSubscriber(ObjectType::Page, Page::"Sales Credit Memo", 'OnAfterActionEvent', 'NPR ImportFromScanner', false, false)]
    local procedure SalesCrMemoOnAfterActionEventImportFromScannerFile(var Rec: Record "Sales Header")
    var
        ImportfromScannerFileSO: XMLport "NPR Import from ScannerFileSO";
    begin
        ImportfromScannerFileSO.SelectTable(Rec);
        ImportfromScannerFileSO.SetTableView(Rec);
        ImportfromScannerFileSO.Run();
    end;

    [EventSubscriber(ObjectType::Page, Page::"Purchase Order", 'OnAfterActionEvent', 'NPR InsertLineVendorItem', false, false)]
    local procedure PurchaseOrderOnAfterActionEventInsertLinewithVendorItem(var Rec: Record "Purchase Header")
    var
        RetailItemList: Page "Item List";
        Item: Record Item;
        PurchaseLine: Record "Purchase Line";
        LastPurchaseLine: Record "Purchase Line";
        ReturntoPO: Boolean;
        ViewText: Text;
        InputQuantity: Decimal;
        InputDialog: Page "NPR Input Dialog";
    begin
        Rec.TestField(Status, Rec.Status::Open);
        Rec.TestField("Buy-from Vendor No.");
        RetailItemList.NPR_SetLocationCode(Rec."Location Code");
        RetailItemList.NPR_SetVendorNo(Rec."Buy-from Vendor No.");
        RetailItemList.LookupMode := true;
        while RetailItemList.RunModal = ACTION::LookupOK do begin
            RetailItemList.GetRecord(Item);
            InputQuantity := 1;
            InputDialog.SetAutoCloseOnValidate(true);
            InputDialog.SetInput(1, InputQuantity, PurchaseLine.FieldCaption(Quantity));
            InputDialog.RunModal();
            InputDialog.InputDecimal(1, InputQuantity);
            Clear(InputDialog);

            LastPurchaseLine.Reset();
            LastPurchaseLine.SetRange("Document Type", Rec."Document Type");
            LastPurchaseLine.SetRange("Document No.", Rec."No.");
            if not LastPurchaseLine.FindLast() then
                LastPurchaseLine.Init();

            PurchaseLine.Init();
            PurchaseLine.Validate("Document Type", Rec."Document Type");
            PurchaseLine.Validate("Document No.", Rec."No.");
            PurchaseLine.Validate("Line No.", LastPurchaseLine."Line No." + 10000);
            PurchaseLine.Insert(true);
            PurchaseLine.Validate(Type, PurchaseLine.Type::Item);
            PurchaseLine.Validate("No.", Item."No.");
            PurchaseLine.Validate(Quantity, InputQuantity);
            PurchaseLine.Modify(true);
            Commit();
            ViewText := RetailItemList.NPR_GetViewText;
            Clear(RetailItemList);
            RetailItemList.NPR_SetLocationCode(Rec."Location Code");
            RetailItemList.NPR_SetVendorNo(Rec."Buy-from Vendor No.");
            Item.SetView(ViewText);
            RetailItemList.SetTableView(Item);
            RetailItemList.SetRecord(Item);
            RetailItemList.LookupMode := true;
        end;
    end;

    [EventSubscriber(ObjectType::Page, Page::"Purchase Order", 'OnAfterActionEvent', 'NPR ImportFromScanner', false, false)]
    local procedure PurchaseOrderOnAfterActionEventImportFromScannerFile(var Rec: Record "Purchase Header")
    var
        ImportfromScannerFilePO: XMLport "NPR Import from ScannerFilePO";
        c: page 130;
    begin
        ImportfromScannerFilePO.SelectTable(Rec);
        ImportfromScannerFilePO.SetTableView(Rec);
        ImportfromScannerFilePO.Run();
    end;

    [EventSubscriber(ObjectType::Page, Page::"Purchase Quote", 'OnAfterActionEvent', 'NPR ImportFromScanner', false, false)]
    local procedure PurchaseQuoteOnAfterActionEventImportFromScannerFile(var Rec: Record "Purchase Header")
    var
        ImportfromScannerFilePO: XMLport "NPR Import from ScannerFilePO";
    begin
        ImportfromScannerFilePO.SelectTable(Rec);
        ImportfromScannerFilePO.SetTableView(Rec);
        ImportfromScannerFilePO.Run();
    end;

    [EventSubscriber(ObjectType::Page, Page::"Purchase Credit Memo", 'OnAfterActionEvent', 'NPR Import From Scanner File', false, false)]
    local procedure PurchaseCrMemoOnAfterActionEventImportFromScannerFile(var Rec: Record "Purchase Header")
    var
        ImportfromScannerFilePO: XMLport "NPR Import from ScannerFilePO";
    begin
        ImportfromScannerFilePO.SelectTable(Rec);
        ImportfromScannerFilePO.SetTableView(Rec);
        ImportfromScannerFilePO.Run();
    end;

    [EventSubscriber(ObjectType::Page, Page::"Posted Sales Shipment", 'OnAfterActionEvent', 'NPR CreatePacsoftDocument', false, false)]
    local procedure PostedSalesShipmentOnAfterActionEventCreatePacsoftDocument(var Rec: Record "Sales Shipment Header")
    var
        ShipmentDocument: Record "NPR Pacsoft Shipment Document";
        RecRef: RecordRef;
    begin
        RecRef.GetTable(Rec);
        ShipmentDocument.AddEntry(RecRef, true);
    end;

    [EventSubscriber(ObjectType::Page, Page::"Posted Sales Shipment", 'OnAfterActionEvent', 'NPR Consignor Label', false, false)]
    local procedure PostedSalesShipmentOnAfterActionEventConsignorLabel(var Rec: Record "Sales Shipment Header")
    var
        ConsignorEntry: Record "NPR Consignor Entry";
    begin
        ConsignorEntry.InsertFromShipmentHeader(Rec."No.");
    end;

    [EventSubscriber(ObjectType::Page, Page::"Posted Sales Invoice", 'OnAfterActionEvent', 'NPR Consignor Label', false, false)]
    local procedure PostedSalesInvoiceOnAfterActionEventConsignorLabel(var Rec: Record "Sales Invoice Header")
    var
        ConsignorEntry: Record "NPR Consignor Entry";
    begin
        ConsignorEntry.InsertFromPostedInvoiceHeader(Rec."No.");
    end;

    [EventSubscriber(ObjectType::Page, Page::"Transfer Order", 'OnAfterActionEvent', 'NPR Import From Scanner File', false, false)]
    local procedure TransferOrderOnAfterActionEventImportFromScannerFile(var Rec: Record "Transfer Header")
    var
        ImportfromScannerFileTO: XMLport "NPR ImportFromScannerFile TO";
    begin
        ImportfromScannerFileTO.SelectTable(Rec);
        ImportfromScannerFileTO.SetTableView(Rec);
        ImportfromScannerFileTO.Run();
    end;

    [EventSubscriber(ObjectType::Page, Page::"Concurrent Session List", 'OnAfterActionEvent', 'NPR Kill Session', false, false)]
    local procedure ConcurrentSessionListOnAfterActionEventKillSession(var Rec: Record "Active Session")
    var
        KillSessionQst: Label 'Kill Session   ?';
    begin
        if Confirm(KillSessionQst, false) then
            StopSession(Rec."Session ID");
    end;

    [EventSubscriber(ObjectType::Page, Page::"NPR Campaign Discount", 'OnAfterActionEvent', 'Transfer from Period Discount', false, false)]
    local procedure CampaignDiscountOnAfterActionEventTransferFromPeriodDiscount(var Rec: Record "NPR Period Discount")
    var
        FromPeriodDiscount: Record "NPR Period Discount";
        CampaignDiscounts: Page "NPR Campaign Discount List";
        FromPeriodDiscountLine: Record "NPR Period Discount Line";
        ToPeriodDiscountLine: Record "NPR Period Discount Line";
        NoTransferedItemErr: Label 'There are no items to transfer';
        ItemAlreadyExistErr: Label 'Item No. %1 already exists in the period', Comment = '%1 = Item No.';
        OkMsg: Label '%1 Items has been transferred to Period %2', Comment = '%1 = Number of Items, %2 = Period';
    begin
        FromPeriodDiscount.SetFilter(Code, '<>%1', Rec.Code);
        CampaignDiscounts.LookupMode := true;
        CampaignDiscounts.Editable := false;
        CampaignDiscounts.SetTableView(FromPeriodDiscount);
        if CampaignDiscounts.RunModal = ACTION::LookupOK then begin
            CampaignDiscounts.GetRecord(FromPeriodDiscount);
            FromPeriodDiscountLine.SetRange(Code, FromPeriodDiscount.Code);
            if not FromPeriodDiscountLine.FindSet() then
                Error(NoTransferedItemErr)
            else
                repeat
                    if ToPeriodDiscountLine.Get(Rec.Code, FromPeriodDiscountLine."Item No.", FromPeriodDiscountLine."Variant Code") then
                        Message(ItemAlreadyExistErr, FromPeriodDiscountLine."Item No.")
                    else begin
                        ToPeriodDiscountLine.Init();
                        ToPeriodDiscountLine := FromPeriodDiscountLine;
                        ToPeriodDiscountLine.Code := Rec.Code;
                        ToPeriodDiscountLine.Insert(true);
                    end;
                until FromPeriodDiscountLine.Next() = 0;
            Message(OkMsg, FromPeriodDiscountLine.Count, Rec.Code);
        end;
    end;
}