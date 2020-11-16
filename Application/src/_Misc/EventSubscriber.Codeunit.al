codeunit 6014404 "NPR Event Subscriber"
{
    trigger OnRun()
    begin
    end;

    var
        RegisterCodeAlreadyUsed: Label 'Register Code %1 already exists.';
        SalesPersonDeleteError: Label 'you cannot delete Salesperson/purchaser %1 before the sale is posted in the Audit roll!';

    //--- Table 13 Salesperson/Purchaser ---

    [EventSubscriber(ObjectType::Table, 13, 'OnAfterDeleteEvent', '', true, false)]
    local procedure T13OnAfterDeleteEvent(var Rec: Record "Salesperson/Purchaser"; RunTrigger: Boolean)
    var
        AuditRoll: Record "NPR Audit Roll";
    begin
        if RunTrigger then begin
            with Rec do begin
                AuditRoll.SetRange(Posted, false);
                AuditRoll.SetRange("Salesperson Code", Code);
                if not AuditRoll.IsEmpty then
                    Error(SalesPersonDeleteError, Code);
            end;
        end;
    end;

    [EventSubscriber(ObjectType::Table, 13, 'OnAfterValidateEvent', 'NPR Register Password', true, false)]
    local procedure T13OnAfterValidateEventRegisterPassword(var Rec: Record "Salesperson/Purchaser"; var xRec: Record "Salesperson/Purchaser"; CurrFieldNo: Integer)
    begin
        with Rec do begin
            SetRange("NPR Register Password", "NPR Register Password");
            if not IsEmpty then
                Error(RegisterCodeAlreadyUsed, "NPR Register Password");
        end;
    end;

    //--- Table 83 Item Journal Line ---

    [EventSubscriber(ObjectType::Table, 83, 'OnAfterValidateEvent', 'Cross-Reference No.', false, false)]
    local procedure T83OnAfterValidateEventCrossReferenceNo(var Rec: Record "Item Journal Line"; var xRec: Record "Item Journal Line"; CurrFieldNo: Integer)
    var
        StdTableCode: Codeunit "NPR Std. Table Code";
    begin
        StdTableCode.ItemJnlLineCrossReferenceOV(Rec, xRec);
    end;

    //--- Table 352 Default Dimension ---

    [EventSubscriber(ObjectType::Table, 352, 'OnAfterInsertEvent', '', false, false)]
    local procedure T352OnAfterInsertEvent(var Rec: Record "Default Dimension"; RunTrigger: Boolean)
    var
        StdTableCode: Codeunit "NPR Std. Table Code";
        GLSetup: Record "General Ledger Setup";
    begin
        if RunTrigger then begin
            GLSetup.Get;
            if Rec."Dimension Code" = GLSetup."Global Dimension 1 Code" then
                StdTableCode.UpdateGlobalDimCode(1, Rec."Table ID", Rec."No.", Rec."Dimension Value Code");
            if Rec."Dimension Code" = GLSetup."Global Dimension 2 Code" then
                StdTableCode.UpdateGlobalDimCode(2, Rec."Table ID", Rec."No.", Rec."Dimension Value Code");
        end;
    end;

    [EventSubscriber(ObjectType::Table, 352, 'OnAfterModifyEvent', '', false, false)]
    local procedure T352OnAfterModifyEvent(var Rec: Record "Default Dimension"; var xRec: Record "Default Dimension"; RunTrigger: Boolean)
    var
        StdTableCode: Codeunit "NPR Std. Table Code";
        GLSetup: Record "General Ledger Setup";
    begin
        if RunTrigger then begin
            GLSetup.Get;
            if Rec."Dimension Code" = GLSetup."Global Dimension 1 Code" then
                StdTableCode.UpdateGlobalDimCode(1, Rec."Table ID", Rec."No.", Rec."Dimension Value Code");
            if Rec."Dimension Code" = GLSetup."Global Dimension 2 Code" then
                StdTableCode.UpdateGlobalDimCode(2, Rec."Table ID", Rec."No.", Rec."Dimension Value Code");
        end;
    end;

    [EventSubscriber(ObjectType::Table, 352, 'OnAfterDeleteEvent', '', false, false)]
    local procedure T352OnAfterDeleteEvent(var Rec: Record "Default Dimension"; RunTrigger: Boolean)
    var
        StdTableCode: Codeunit "NPR Std. Table Code";
        GLSetup: Record "General Ledger Setup";
    begin
        if RunTrigger then begin
            GLSetup.Get;
            if Rec."Dimension Code" = GLSetup."Global Dimension 1 Code" then
                StdTableCode.UpdateGlobalDimCode(1, Rec."Table ID", Rec."No.", '');
            if Rec."Dimension Code" = GLSetup."Global Dimension 2 Code" then
                StdTableCode.UpdateGlobalDimCode(2, Rec."Table ID", Rec."No.", '');
        end;
    end;

    //--- Codeunit 1 ApplicationManagement ---

    [EventSubscriber(ObjectType::Codeunit, Codeunit::LogInManagement, 'OnBeforeLogInStart', '', true, false)]
    local procedure OnBeforeLogInStart()
    var
        ServiceTierUserManagement: Codeunit "NPR Service Tier User Mgt.";
        NPRetailSetup: Record "NPR NP Retail Setup";
    begin
        if NavApp.IsInstalling() then
            exit;

        if not (CurrentClientType in [CLIENTTYPE::Windows, CLIENTTYPE::Web, CLIENTTYPE::Tablet, CLIENTTYPE::Phone, CLIENTTYPE::Desktop]) then
            exit;

        Commit();

        if ServiceTierUserManagement.Run() then;
    end;

    //--- Codeunit 22 Item Jnl.-Post Line ---

    [EventSubscriber(ObjectType::Codeunit, 22, 'OnBeforeInsertTransferEntry', '', true, false)]
    local procedure C22OnBeforeInsertTransferEntry(var NewItemLedgerEntry: Record "Item Ledger Entry"; var OldItemLedgerEntry: Record "Item Ledger Entry"; var ItemJournalLine: Record "Item Journal Line")
    var
        RetailCodeunitCode: Codeunit "NPR Std. Codeunit Code";
        RetailSetup: Record "NPR Retail Setup";
    begin
        RetailSetup.Get;
        NewItemLedgerEntry."NPR Vendor No." := OldItemLedgerEntry."NPR Vendor No.";
        NewItemLedgerEntry."NPR Item Group No." := OldItemLedgerEntry."NPR Item Group No.";
        NewItemLedgerEntry."NPR Register Number" := OldItemLedgerEntry."NPR Register Number";
        NewItemLedgerEntry."NPR Salesperson Code" := OldItemLedgerEntry."NPR Salesperson Code";
        if RetailSetup."Transfer SeO Item Entry" then
            NewItemLedgerEntry."Cross-Reference No." := OldItemLedgerEntry."Cross-Reference No.";
    end;

    [EventSubscriber(ObjectType::Codeunit, 22, 'OnBeforePostItemJnlLine', '', false, false)]
    local procedure C22OnBeforePostItemJnlLine(var ItemJournalLine: Record "Item Journal Line")
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

    [EventSubscriber(ObjectType::Codeunit, 22, 'OnAfterInitItemLedgEntry', '', true, false)]
    local procedure C22OnAfterInitItemLedgEntry(var NewItemLedgEntry: Record "Item Ledger Entry"; ItemJournalLine: Record "Item Journal Line"; var ItemLedgEntryNo: Integer)
    var
        Item: Record Item;
    begin
        with NewItemLedgEntry do begin
            "NPR Vendor No." := ItemJournalLine."NPR Vendor No.";
            "NPR Item Group No." := ItemJournalLine."NPR Item Group No.";
            "NPR Discount Type" := ItemJournalLine."NPR Discount Type";
            "NPR Discount Code" := ItemJournalLine."NPR Discount Code";
            "NPR Register Number" := ItemJournalLine."NPR Register Number";
            "NPR Group Sale" := ItemJournalLine."NPR Group Sale";
            "NPR Salesperson Code" := ItemJournalLine."Salespers./Purch. Code";
            "NPR Document Time" := ItemJournalLine."NPR Document Time";
            "NPR Document Date and Time" := CreateDateTime(ItemJournalLine."Posting Date", "NPR Document Time");
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, 22, 'OnBeforeInsertValueEntry', '', false, false)]
    local procedure C22OnBeforeInsertValueEntry(var ValueEntry: Record "Value Entry"; ItemJournalLine: Record "Item Journal Line")
    var
        Item: Record Item;
    begin
        with ValueEntry do begin
            "NPR Item Group No." := ItemJournalLine."NPR Item Group No.";
            "NPR Vendor No." := ItemJournalLine."NPR Vendor No.";
            "NPR Discount Type" := ItemJournalLine."NPR Discount Type";
            "NPR Discount Code" := ItemJournalLine."NPR Discount Code";
            "NPR Register No." := ItemJournalLine."NPR Register Number";
            "NPR Group Sale" := ItemJournalLine."NPR Group Sale";
            "NPR Salesperson Code" := ItemJournalLine."Salespers./Purch. Code";
            "NPR Document Date and Time" := CreateDateTime(ItemJournalLine."Posting Date", ItemJournalLine."NPR Document Time");
            "NPR Item Category Code" := ItemJournalLine."Item Category Code";
        end;
    end;

    //--- Codeunit 80 Sales-Post ---

    [EventSubscriber(ObjectType::Codeunit, 80, 'OnBeforePostSalesDoc', '', true, false)]
    local procedure C80OnBeforePostSalesDoc(var SalesHeader: Record "Sales Header")
    var
        RetailSetup: Record "NPR Retail Setup";
    begin
        if not RetailSetup.Get then
            RetailSetup.Init();
        if RetailSetup."Salespersoncode on Salesdoc." = RetailSetup."Salespersoncode on Salesdoc."::Forced then
            SalesHeader.TestField("Salesperson Code");
    end;

    [EventSubscriber(ObjectType::Codeunit, 80, 'OnAfterPostSalesDoc', '', false, false)]
    local procedure C80OnAfterPostSalesDoc(var SalesHeader: Record "Sales Header"; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; SalesShptHdrNo: Code[20]; RetRcpHdrNo: Code[20]; SalesInvHdrNo: Code[20]; SalesCrMemoHdrNo: Code[20])
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
        SalesSetup.Get;
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

    //--- Page 30 Item Card ---

    [EventSubscriber(ObjectType::Page, 30, 'OnAfterActionEvent', 'NPR AttributeValues', false, false)]
    local procedure P30OnAfterActionEventNPRAttributeValues(var Rec: Record Item)
    var
        NPRAttrManagement: Codeunit "NPR Attribute Management";
    begin
        NPRAttrManagement.ShowMasterDataAttributeValues(DATABASE::Item, Rec."No.");
    end;

    //--- Page42 Sales Order ---

    [EventSubscriber(ObjectType::Page, 42, 'OnAfterActionEvent', 'NPR Consignor Label', false, false)]
    local procedure P42OnAfterActionEventConsignorLabel(var Rec: Record "Sales Header")
    var
        ConsignorEntry: Record "NPR Consignor Entry";
    begin
        ConsignorEntry.InsertFromSalesHeader(Rec."No.");
    end;

    [EventSubscriber(ObjectType::Page, 42, 'OnAfterActionEvent', 'NPR Import From Scanner', false, false)]
    local procedure P42OnAferActionEventImportFromScanner(var Rec: Record "Sales Header")
    var
        ImportfromScannerFileSO: XMLport "NPR Import from ScannerFileSO";
    begin
        ImportfromScannerFileSO.SelectTable(Rec);
        ImportfromScannerFileSO.SetTableView(Rec);
        ImportfromScannerFileSO.Run;
    end;

    [EventSubscriber(ObjectType::Page, 42, 'OnAfterActionEvent', 'NPR InsertLineItem ', true, true)]
    local procedure P42OnAfterActionInsertLinewithItem(var Rec: Record "Sales Header")
    var
        RetailItemList: Page "NPR Retail Item List";
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
        RetailItemList.SetLocationCode(Rec."Location Code");
        RetailItemList.SetBlocked(2);
        RetailItemList.LookupMode := true;
        while RetailItemList.RunModal = ACTION::LookupOK do begin
            RetailItemList.GetRecord(Item);

            InputQuantity := 1;
            InputDialog.SetAutoCloseOnValidate(true);
            InputDialog.SetInput(1, InputQuantity, SalesLine.FieldCaption(Quantity));
            InputDialog.RunModal;
            InputDialog.InputDecimal(1, InputQuantity);
            Clear(InputDialog);

            LastSalesLine.Reset;
            LastSalesLine.SetRange("Document Type", Rec."Document Type");
            LastSalesLine.SetRange("Document No.", Rec."No.");
            if not LastSalesLine.FindLast then
                LastSalesLine.Init;

            SalesLine.Init;
            SalesLine.Validate("Document Type", Rec."Document Type");
            SalesLine.Validate("Document No.", Rec."No.");
            SalesLine.Validate("Line No.", LastSalesLine."Line No." + 10000);
            SalesLine.Insert(true);
            SalesLine.Validate(Type, SalesLine.Type::Item);
            SalesLine.Validate("No.", Item."No.");
            SalesLine.Validate(Quantity, InputQuantity);
            SalesLine.Modify(true);
            Commit;
            ViewText := RetailItemList.GetViewText;
            Clear(RetailItemList);
            RetailItemList.SetLocationCode(Rec."Location Code");
            RetailItemList.SetVendorNo(Rec."NPR Buy-From Vendor No.");
            Item.SetView(ViewText);
            RetailItemList.SetTableView(Item);
            RetailItemList.SetRecord(Item);
            RetailItemList.LookupMode := true;
        end;
    end;

    //--- Page 43 Sales Invoice ---

    [EventSubscriber(ObjectType::Page, 43, 'OnAfterActionEvent', 'NPR ImportFromScanner', false, false)]
    local procedure P43OnAfterActionEventImportFromScannerFile(var Rec: Record "Sales Header")
    var
        ImportfromScannerFileSO: XMLport "NPR Import from ScannerFileSO";
    begin
        ImportfromScannerFileSO.SelectTable(Rec);
        ImportfromScannerFileSO.SetTableView(Rec);
        ImportfromScannerFileSO.Run;
    end;

    //--- Page 44 Sales Credit Memo ---

    [EventSubscriber(ObjectType::Page, 44, 'OnAfterActionEvent', 'NPR ImportFromScanner', false, false)]
    local procedure P44OnAfterActionEventImportFromScannerFile(var Rec: Record "Sales Header")
    var
        ImportfromScannerFileSO: XMLport "NPR Import from ScannerFileSO";
    begin
        ImportfromScannerFileSO.SelectTable(Rec);
        ImportfromScannerFileSO.SetTableView(Rec);
        ImportfromScannerFileSO.Run;
    end;

    //--- Page 50 Purchase Order ---

    [EventSubscriber(ObjectType::Page, 50, 'OnAfterActionEvent', 'NPR InsertLineVendorItem', false, false)]
    local procedure P50OnAfterActionEventInsertLinewithVendorItem(var Rec: Record "Purchase Header")
    var
        RetailItemList: Page "NPR Retail Item List";
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
        RetailItemList.SetLocationCode(Rec."Location Code");
        RetailItemList.SetVendorNo(Rec."Buy-from Vendor No.");
        RetailItemList.LookupMode := true;
        while RetailItemList.RunModal = ACTION::LookupOK do begin
            RetailItemList.GetRecord(Item);
            InputQuantity := 1;
            InputDialog.SetAutoCloseOnValidate(true);
            InputDialog.SetInput(1, InputQuantity, PurchaseLine.FieldCaption(Quantity));
            InputDialog.RunModal;
            InputDialog.InputDecimal(1, InputQuantity);
            Clear(InputDialog);

            LastPurchaseLine.Reset;
            LastPurchaseLine.SetRange("Document Type", Rec."Document Type");
            LastPurchaseLine.SetRange("Document No.", Rec."No.");
            if not LastPurchaseLine.FindLast then
                LastPurchaseLine.Init;

            PurchaseLine.Init;
            PurchaseLine.Validate("Document Type", Rec."Document Type");
            PurchaseLine.Validate("Document No.", Rec."No.");
            PurchaseLine.Validate("Line No.", LastPurchaseLine."Line No." + 10000);
            PurchaseLine.Insert(true);
            PurchaseLine.Validate(Type, PurchaseLine.Type::Item);
            PurchaseLine.Validate("No.", Item."No.");
            PurchaseLine.Validate(Quantity, InputQuantity);
            PurchaseLine.Modify(true);
            Commit;
            ViewText := RetailItemList.GetViewText;
            Clear(RetailItemList);
            RetailItemList.SetLocationCode(Rec."Location Code");
            RetailItemList.SetVendorNo(Rec."Buy-from Vendor No.");
            Item.SetView(ViewText);
            RetailItemList.SetTableView(Item);
            RetailItemList.SetRecord(Item);
            RetailItemList.LookupMode := true;
        end;
    end;

    [EventSubscriber(ObjectType::Page, 50, 'OnAfterActionEvent', 'NPR ImportFromScanner', false, false)]
    local procedure P50OnAfterActionEventImportFromScannerFile(var Rec: Record "Purchase Header")
    var
        ImportfromScannerFilePO: XMLport "NPR Import from ScannerFilePO";
    begin
        ImportfromScannerFilePO.SelectTable(Rec);
        ImportfromScannerFilePO.SetTableView(Rec);
        ImportfromScannerFilePO.Run;
    end;

    //--- Page 49 Purchase Quote ---

    [EventSubscriber(ObjectType::Page, 49, 'OnAfterActionEvent', 'NPR ImportFromScanner', false, false)]
    local procedure P49OnAfterActionEventImportFromScannerFile(var Rec: Record "Purchase Header")
    var
        ImportfromScannerFilePO: XMLport "NPR Import from ScannerFilePO";
    begin
        ImportfromScannerFilePO.SelectTable(Rec);
        ImportfromScannerFilePO.SetTableView(Rec);
        ImportfromScannerFilePO.Run;
    end;

    //--- Page 52 Purchase Credit Memo ---

    [EventSubscriber(ObjectType::Page, 52, 'OnAfterActionEvent', 'NPR Import From Scanner File', false, false)]
    local procedure P52OnAfterActionEventImportFromScannerFile(var Rec: Record "Purchase Header")
    var
        ImportfromScannerFilePO: XMLport "NPR Import from ScannerFilePO";
    begin
        ImportfromScannerFilePO.SelectTable(Rec);
        ImportfromScannerFilePO.SetTableView(Rec);
        ImportfromScannerFilePO.Run;
    end;

    //--- Page 130 Posted Sales Shipment ---

    [EventSubscriber(ObjectType::Page, 130, 'OnAfterActionEvent', 'NPR CreatePacsoftDocument', false, false)]
    local procedure P130OnAfterActionEventCreatePacsoftDocument(var Rec: Record "Sales Shipment Header")
    var
        ShipmentDocument: Record "NPR Pacsoft Shipment Document";
        RecRef: RecordRef;
    begin
        RecRef.GetTable(Rec);
        ShipmentDocument.AddEntry(RecRef, true);
    end;

    [EventSubscriber(ObjectType::Page, 130, 'OnAfterActionEvent', 'NPR Consignor Label', false, false)]
    local procedure P130OnAfterActionEventConsignorLabel(var Rec: Record "Sales Shipment Header")
    var
        ConsignorEntry: Record "NPR Consignor Entry";
    begin
        ConsignorEntry.InsertFromShipmentHeader(Rec."No.");
    end;

    //--- Page132 Posted Sales Invoice ---

    [EventSubscriber(ObjectType::Page, 132, 'OnAfterActionEvent', 'NPR Consignor Label', false, false)]
    local procedure P132OnAfterActionEventConsignorLabel(var Rec: Record "Sales Invoice Header")
    var
        ConsignorEntry: Record "NPR Consignor Entry";
    begin
        ConsignorEntry.InsertFromPostedInvoiceHeader(Rec."No.");
    end;

    //--- Page 291 Req. Worksheet ---

    [EventSubscriber(ObjectType::Page, 291, 'OnAfterActionEvent', 'NPR &ReadFromScanner', false, false)]
    local procedure P291OnAfterActionEventReadFromScanner(var Rec: Record "Requisition Line")
    var
        ScannerFunctions: Codeunit "NPR Scanner - Functions";
    begin
        ScannerFunctions.initPurchJnl(Rec);
    end;

    //--- Page 5740 Transfer Order ---

    [EventSubscriber(ObjectType::Page, 5740, 'OnAfterActionEvent', 'NPR Import From Scanner File', false, false)]
    local procedure P5740OnAfterActionEventImportFromScannerFile(var Rec: Record "Transfer Header")
    var
        ImportfromScannerFileTO: XMLport "NPR ImportFromScannerFile TO";
    begin
        ImportfromScannerFileTO.SelectTable(Rec);
        ImportfromScannerFileTO.SetTableView(Rec);
        ImportfromScannerFileTO.Run;
    end;

    [EventSubscriber(ObjectType::Page, 5740, 'OnAfterActionEvent', 'NPR &Read from scanner', false, false)]
    local procedure P5740OnAfterActionEventReadFromScanner(var Rec: Record "Transfer Header")
    var
        ScannerFunctions: Codeunit "NPR Scanner - Functions";
    begin
        ScannerFunctions.initTransfer(Rec);
    end;

    //--- Page 9506 Session List ---

    [EventSubscriber(ObjectType::Page, Page::"Concurrent Session List", 'OnAfterActionEvent', 'NPR Kill Session', false, false)]
    local procedure P956OnAfterActionEventKillSession(var Rec: Record "Active Session")
    var
        Text6014400: Label 'Kill Session   ?';
    begin
        if Confirm(Text6014400, false) then
            StopSession(Rec."Session ID");
    end;

    //--- Page 6014453 Campaign Discount ---

    [EventSubscriber(ObjectType::Page, 6014453, 'OnAfterActionEvent', 'Transfer from Period Discount', false, false)]
    local procedure P6014453OnAfterActionEventTransferFromPeriodDiscount(var Rec: Record "NPR Period Discount")
    var
        FromPeriodDiscount: Record "NPR Period Discount";
        CampaignDiscounts: Page "NPR Campaign Discount List";
        FromPeriodDiscountLine: Record "NPR Period Discount Line";
        ToPeriodDiscountLine: Record "NPR Period Discount Line";
        ErrorNo1: Label 'There are no items to transfer';
        ErrorNo2: Label 'Item No. %1 already exists in the period';
        OkMsg: Label '%1 Items has been transferred to Period %2';
    begin
        FromPeriodDiscount.SetFilter(Code, '<>%1', Rec.Code);
        CampaignDiscounts.LookupMode := true;
        CampaignDiscounts.Editable := false;
        CampaignDiscounts.SetTableView(FromPeriodDiscount);
        if CampaignDiscounts.RunModal = ACTION::LookupOK then begin
            CampaignDiscounts.GetRecord(FromPeriodDiscount);
            FromPeriodDiscountLine.SetRange(Code, FromPeriodDiscount.Code);
            if not FromPeriodDiscountLine.FindSet then
                Error(ErrorNo1)
            else
                repeat
                    if ToPeriodDiscountLine.Get(Rec.Code, FromPeriodDiscountLine."Item No.", FromPeriodDiscountLine."Variant Code") then
                        Message(ErrorNo2, FromPeriodDiscountLine."Item No.")
                    else begin
                        ToPeriodDiscountLine.Init;
                        ToPeriodDiscountLine := FromPeriodDiscountLine;
                        ToPeriodDiscountLine.Code := Rec.Code;
                        ToPeriodDiscountLine.Insert(true);
                    end;
                until FromPeriodDiscountLine.Next = 0;
            Message(OkMsg, FromPeriodDiscountLine.Count, Rec.Code);
        end;
    end;
}