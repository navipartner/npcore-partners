codeunit 6014467 "NPR Retail Journal Code"
{
    Access = Internal;
    var
        RetailJnlHeader: Record "NPR Retail Journal Header";

        Selection: Integer;
        Text004: Label '&Quantity,Quantity &to Receive,Quantity &Received';

    procedure ExportToRetailJournal(var RetailJournalLine: Record "NPR Retail Journal Line")
    var
        RetailJournalHeader: Record "NPR Retail Journal Header";
        RetailJournalLine2: Record "NPR Retail Journal Line";
        RetailJournalList: Page "NPR Retail Journal List";
        Dialog: Dialog;
        Counter: Integer;
        RetailJournalLineNo: Integer;
        LineCounter: Integer;
        TotalHeaders: Integer;
        Text001: Label 'Transferring...';
        Text002: Label '@1@@@@@@@@@@';
        Total: Integer;
    begin
        RetailJournalList.LookupMode(true);
        RetailJournalList.SetTableView(RetailJournalHeader);

        if not (RetailJournalList.RunModal() = ACTION::LookupOK) then
            exit;

        RetailJournalList.GetSelectionFilter(RetailJournalHeader);

        Total := RetailJournalLine.Count();
        TotalHeaders := RetailJournalHeader.Count();

        Dialog.Open(Text001 + '\' + Text002);

        if RetailJournalHeader.FindSet() then
            repeat
                Clear(RetailJournalLine2);
                RetailJournalLine2.SetRange("No.", RetailJournalHeader."No.");

                if RetailJournalLine2.FindLast() then
                    TotalHeaders := RetailJournalLine2."Line No." + 10000
                else
                    TotalHeaders := 10000;

                LineCounter := 0;
                if RetailJournalLine.Find('-') then
                    repeat
                        Counter += 1;
                        LineCounter += 1;
                        Dialog.Update(1, Round(Counter / (Total * TotalHeaders) * 10000, 1, '>'));
                        RetailJournalLine2.Init();
                        RetailJournalLine2 := RetailJournalLine;
                        RetailJournalLine2."No." := RetailJournalHeader."No.";
                        RetailJournalLine2."Line No." := RetailJournalLineNo + LineCounter * 10000;
                        RetailJournalLine2.Insert(true);
                    until RetailJournalLine.Next() = 0;
            until RetailJournalHeader.Next() = 0;
        Dialog.Close();
    end;

    procedure ExportToPeriodDiscount(var RetailJournalLine: Record "NPR Retail Journal Line")
    var
        PeriodDiscount: Record "NPR Period Discount";
        PeriodDiscountLine: Record "NPR Period Discount Line";
        CampaignDiscountList: Page "NPR Campaign Discount List";
        Dialog: Dialog;
        Counter: Integer;
        Total: Integer;
        Text0001: Label 'Processing Item No. #1######## @2@@@@@@@@';
    begin
        CampaignDiscountList.LookupMode(true);

        if not (CampaignDiscountList.RunModal() = ACTION::LookupOK) then
            exit;

        CampaignDiscountList.GetRecord(PeriodDiscount);

        Dialog.Open(Text0001);

        Total := RetailJournalLine.Count();

        PeriodDiscountLine.Reset();

        if RetailJournalLine.Find('-') then
            repeat
                Counter += 1;
                Dialog.Update(1, RetailJournalLine."Item No.");
                Dialog.Update(2, Round(Counter / Total * 10000, 10000, '='));
                if not PeriodDiscountLine.Get(PeriodDiscount.Code, RetailJournalLine."Item No.") then begin
                    PeriodDiscountLine.Init();
                    PeriodDiscountLine.Validate(Code, PeriodDiscount.Code);
                    PeriodDiscountLine.Validate("Item No.", RetailJournalLine."Item No.");
                    PeriodDiscountLine.Insert();
                    PeriodDiscountLine.CalcFields("Unit Price");
                    if PeriodDiscountLine."Unit Price" <> 0 then
                        PeriodDiscountLine.Validate("Campaign Unit Price", PeriodDiscountLine."Unit Price")
                    else
                        PeriodDiscountLine."Campaign Unit Price" := RetailJournalLine."Discount Price Incl. Vat";
                    PeriodDiscountLine.Modify();
                end else begin
                    PeriodDiscountLine.CalcFields("Unit Price");
                    if PeriodDiscountLine."Unit Price" <> 0 then
                        PeriodDiscountLine.Validate("Campaign Unit Price", RetailJournalLine."Discount Price Incl. Vat")
                    else
                        PeriodDiscountLine."Campaign Unit Price" := RetailJournalLine."Discount Price Incl. Vat";
                    PeriodDiscountLine.Modify();
                end;
            until RetailJournalLine.Next() = 0;
        Dialog.Close();
    end;

    procedure ExportToItemJournal(var RetailJournalLine: Record "NPR Retail Journal Line")
    var
        RetailJournalHeader: Record "NPR Retail Journal Header";
        ItemJournalBatch: Record "Item Journal Batch";
        ItemJournalLine: Record "Item Journal Line";
        ItemJournalTemplate: Record "Item Journal Template";
        ItemJournalBatches: Page "Item Journal Batches";
        Dialog: Dialog;
        NextItemJournalLineNo: Integer;
        Total: Integer;
        CurrentLine: Integer;
        BatchFilter: Text[250];
        Text002: Label 'Item #1############### ( #2##### of #3#####)';
        Text001: Label 'The retail journal %1 is sent to item journal %2';
    begin
        RetailJournalHeader.Get(RetailJournalLine."No.");

        ItemJournalTemplate.SetRange(Type, ItemJournalTemplate.Type::Item);
        ItemJournalTemplate.SetRange(Recurring, false);
        if ItemJournalTemplate.Find('-') then
            repeat
                BatchFilter += '|' + ItemJournalTemplate.Name;
            until ItemJournalTemplate.Next() = 0;

        BatchFilter := DelStr(BatchFilter, 1, 1);

        ItemJournalBatch.SetFilter("Journal Template Name", BatchFilter);
        ItemJournalBatches.SetTableView(ItemJournalBatch);
        ItemJournalBatches.LookupMode(true);

        if not (ItemJournalBatches.RunModal() = ACTION::LookupOK) then
            exit;

        ItemJournalBatches.GetRecord(ItemJournalBatch);

        ItemJournalLine.SetRange("Journal Template Name", ItemJournalBatch."Journal Template Name");
        ItemJournalLine.SetRange("Journal Batch Name", ItemJournalBatch.Name);

        if ItemJournalLine.Find('+') then
            NextItemJournalLineNo := ItemJournalLine."Line No." + 10000
        else
            NextItemJournalLineNo := 10000;

        ItemJournalLine.Reset();

        CurrentLine := 0;
        Total := RetailJournalLine.Count();
        Dialog.Open(Text002, RetailJournalLine.Description, CurrentLine, Total);

        if RetailJournalLine.Find('-') then
            repeat
                Dialog.Update();
                if RetailJournalLine."Item No." <> '' then begin
                    ItemJournalLine.Init();
                    ItemJournalLine.Validate("Journal Template Name", ItemJournalBatch."Journal Template Name");
                    ItemJournalLine.Validate("Journal Batch Name", ItemJournalBatch.Name);
                    ItemJournalLine."Line No." := NextItemJournalLineNo;
                    ItemJournalLine.Validate("Entry Type", ItemJournalLine."Entry Type"::"Positive Adjmt.");
                    ItemJournalLine.Validate("Posting Date", Today);
                    ItemJournalLine.Validate("Document No.", 'RETAILKLD');
                    ItemJournalLine.Validate("Item No.", RetailJournalLine."Item No.");
                    ItemJournalLine.Validate(Quantity, RetailJournalLine."Quantity to Print");
                    if RetailJournalLine."Variant Code" <> '' then begin
                        ItemJournalLine.Validate("Variant Code", RetailJournalLine."Variant Code");
                        ItemJournalLine.Validate(Description, RetailJournalLine.Description);
                    end;

                    ItemJournalLine."Shortcut Dimension 1 Code" := RetailJournalHeader."Shortcut Dimension 1 Code";
                    ItemJournalLine."Shortcut Dimension 2 Code" := RetailJournalHeader."Shortcut Dimension 2 Code";
                    ItemJournalLine."Location Code" := RetailJournalHeader."Location Code";
                    ItemJournalLine.Insert();
                    NextItemJournalLineNo += 10000;
                end;
                CurrentLine += 1;
            until RetailJournalLine.Next() = 0;

        Message(Text001, '"' + RetailJournalHeader."No." + ' ' + RetailJournalHeader.Description + '"', ItemJournalBatch.Name);
    end;

    procedure ExportToPurchaseJournal(var RetailJournalLine: Record "NPR Retail Journal Line")
    var
        Item: Record Item;
        RetailJournalHeader: Record "NPR Retail Journal Header";
        RequisitionLine: Record "Requisition Line";
        RequisitionWkshName: Record "Requisition Wksh. Name";
        ReqWkshTemplate: Record "Req. Wksh. Template";
        ReqFilter: Text[250];
        RequisitionLineNo: Integer;
    begin
        RetailJournalHeader.Get(RetailJournalLine."No.");

        ReqWkshTemplate.SetRange(Type, ReqWkshTemplate.Type::"Req.");

        if ReqWkshTemplate.Find('-') then
            repeat
                ReqFilter += '|' + ReqWkshTemplate.Name;
            until ReqWkshTemplate.Next() = 0;

        ReqFilter := DelStr(ReqFilter, 1, 1);

        RequisitionWkshName.SetFilter("Worksheet Template Name", ReqFilter);

        if PAGE.RunModal(PAGE::"Req. Wksh. Names", RequisitionWkshName) = ACTION::LookupOK then begin
            RequisitionLine.SetRange("Worksheet Template Name", RequisitionWkshName."Worksheet Template Name");
            RequisitionLine.SetRange("Journal Batch Name", RequisitionWkshName.Name);
            if RequisitionLine.Find('+') then;
            RequisitionLineNo := RequisitionLine."Line No." + 10000;

            if RetailJournalLine.Find('-') then
                repeat
                    if (RetailJournalLine."Item No." <> '') and (Item.Get(RetailJournalLine."Item No.")) then begin
                        RequisitionLine.Init();
                        RequisitionLine.Validate("Worksheet Template Name", RequisitionWkshName."Worksheet Template Name");
                        RequisitionLine.Validate("Journal Batch Name", RequisitionWkshName.Name);
                        RequisitionLine.Validate("Line No.", RequisitionLineNo);
                        RequisitionLine.Validate(Type, RequisitionLine.Type::Item);
                        RequisitionLine.Validate("No.", RetailJournalLine."Item No.");
                        RequisitionLine.Validate(Quantity, RetailJournalLine."Quantity to Print");
                        RequisitionLine.Validate("Shortcut Dimension 1 Code", RetailJournalHeader."Shortcut Dimension 1 Code");
                        RequisitionLine.Validate("Shortcut Dimension 2 Code", RetailJournalHeader."Shortcut Dimension 2 Code");
                        RequisitionLine.Validate("Location Code", RetailJournalHeader."Location Code");
                        RequisitionLine.Insert(true);
                        RequisitionLineNo += 10000;
                    end;
                until RetailJournalLine.Next() = 0;
        end;
    end;

    procedure ExportToFile(var RetailJournalLine: Record "NPR Retail Journal Line")
    begin
        XMLPORT.Run(XMLPORT::"NPR Retail Journal Imp/Exp", true, false, RetailJournalLine);
    end;

    procedure Campaign2RetailJnl(CampaignCode: Code[20]; RetailJnlCode: Code[40])
    var
        PeriodDiscount: Record "NPR Period Discount";
        PeriodDiscountLine: Record "NPR Period Discount Line";
    begin
        //-NPR5.46 [294354]
        if CampaignCode = '' then begin
            if not (PAGE.RunModal(0, PeriodDiscount) = ACTION::LookupOK) then
                exit;
        end else
            PeriodDiscount.Get(CampaignCode);

        PeriodDiscountLine.SetRange(Code, PeriodDiscount.Code);
        CopyCampaign2RetailJnlLines(PeriodDiscountLine, RetailJnlCode);
        //+NPR5.46 [294354]
    end;

    procedure CopyCampaign2RetailJnlLines(var PeriodDiscountLine: Record "NPR Period Discount Line"; RetailJnlCode: Code[40])
    var
        RetailJnlLine: Record "NPR Retail Journal Line";
    begin
        if not SetRetailJnl(RetailJnlCode) then
            exit;

        RetailJnlLine.SelectRetailJournal(RetailJnlHeader."No.");
        RetailJnlLine.UseGUI(PeriodDiscountLine.Count());
        if PeriodDiscountLine.FindSet() then
            repeat
                PeriodDiscountLine.CalcFields("Unit Price Incl. VAT");
                RetailJnlLine.InitLine();
                RetailJnlLine.SetItem(PeriodDiscountLine."Item No.", PeriodDiscountLine."Variant Code", PeriodDiscountLine."Cross-Reference No.");
                RetailJnlLine.SetDiscountType(1, PeriodDiscountLine.Code, PeriodDiscountLine."Campaign Unit Price", 1, PeriodDiscountLine."Unit Price Incl. VAT");
                RetailJnlLine.Insert();
            until PeriodDiscountLine.Next() = 0;
        RetailJnlLine.CloseGUI();
    end;

    procedure Mix2RetailJnl(MixCode: Code[20]; RetailJnlCode: Code[40])
    var
        MixedDiscount: Record "NPR Mixed Discount";
        MixedDiscountLine: Record "NPR Mixed Discount Line";
    begin
        if MixCode = '' then begin
            if not (PAGE.RunModal(0, MixedDiscount) = ACTION::LookupOK) then
                exit;
        end else
            MixedDiscount.Get(MixCode);

        MixedDiscountLine.SetRange(Code, MixedDiscount.Code);
        CopyMix2RetailJnlLines(MixedDiscountLine, RetailJnlCode);
    end;

    procedure CopyMix2RetailJnlLines(var MixedDiscountLine: Record "NPR Mixed Discount Line"; RetailJnlCode: Code[40])
    var
        RetailJnlLine: Record "NPR Retail Journal Line";
    begin
        if not SetRetailJnl(RetailJnlCode) then
            exit;

        RetailJnlLine.SelectRetailJournal(RetailJnlHeader."No.");
        RetailJnlLine.UseGUI(MixedDiscountLine.Count());
        if MixedDiscountLine.FindSet() then
            repeat
                MixedDiscountLine.CalcFields("Unit price incl. VAT");
                RetailJnlLine.InitLine();
                RetailJnlLine.SetItem(MixedDiscountLine."No.", MixedDiscountLine."Variant Code", MixedDiscountLine."Cross-Reference No.");
                RetailJnlLine.SetDiscountType(2, MixedDiscountLine.Code, MixedDiscountLine."Unit price", MixedDiscountLine.Quantity, MixedDiscountLine."Unit price incl. VAT");
                RetailJnlLine.Insert();
            until MixedDiscountLine.Next() = 0;
        RetailJnlLine.CloseGUI();
    end;

    procedure Quantity2RetailJnl(ItemNo: Code[20]; MainItemNo: Code[20]; RetailJnlCode: Code[40])
    var
        QuantityDiscountHeader: Record "NPR Quantity Discount Header";
        QuantityDiscountLine: Record "NPR Quantity Discount Line";
    begin
        if ItemNo = '' then begin
            if not (PAGE.RunModal(0, QuantityDiscountHeader) = ACTION::LookupOK) then
                exit;
        end else
            QuantityDiscountHeader.Get(ItemNo, MainItemNo);

        QuantityDiscountLine.SetRange("Item No.", QuantityDiscountHeader."Item No.");
        QuantityDiscountLine.SetRange("Main no.", QuantityDiscountHeader."Main No.");
        CopyQuantity2RetailJnlLines(QuantityDiscountLine, RetailJnlCode);
    end;

    procedure CopyQuantity2RetailJnlLines(var QuantityDiscountLine: Record "NPR Quantity Discount Line"; RetailJnlCode: Code[40])
    var
        RetailJnlLine: Record "NPR Retail Journal Line";
    begin
        if not SetRetailJnl(RetailJnlCode) then
            exit;

        RetailJnlLine.SelectRetailJournal(RetailJnlHeader."No.");
        RetailJnlLine.UseGUI(QuantityDiscountLine.Count());
        if QuantityDiscountLine.FindSet() then
            repeat
                QuantityDiscountLine.CalcFields("Price Includes VAT");
                RetailJnlLine.InitLine();
                RetailJnlLine.SetItem(QuantityDiscountLine."Item No.", '', '');
                RetailJnlLine.SetDiscountType(3, QuantityDiscountLine."Main no.", QuantityDiscountLine."Unit Price", QuantityDiscountLine.Quantity, QuantityDiscountLine."Price Includes VAT");
                RetailJnlLine.Insert();
            until QuantityDiscountLine.Next() = 0;
        RetailJnlLine.CloseGUI();
    end;

    procedure TransferShipment2RetailJnl(TransferShipmentNo: Code[20]; RetailJnlCode: Code[40])
    var
        TransferShipmentHeader: Record "Transfer Shipment Header";
        TransferShipmentLine: Record "Transfer Shipment Line";
    begin
        if TransferShipmentNo = '' then begin
            if not (PAGE.RunModal(0, TransferShipmentHeader) = ACTION::LookupOK) then
                exit;
        end else
            TransferShipmentHeader.Get(TransferShipmentNo);

        TransferShipmentLine.SetRange("Document No.", TransferShipmentHeader."No.");
        CopyTransferShipment2RetailJnlLines(TransferShipmentLine, RetailJnlCode);
    end;

    procedure CopyTransferShipment2RetailJnlLines(var TransferShipmentLine: Record "Transfer Shipment Line"; RetailJnlCode: Code[40])
    var
        RetailJnlLine: Record "NPR Retail Journal Line";
    begin
        if not SetRetailJnl(RetailJnlCode) then
            exit;

        RetailJnlLine.SelectRetailJournal(RetailJnlHeader."No.");
        RetailJnlLine.UseGUI(TransferShipmentLine.Count());
        if TransferShipmentLine.FindSet() then
            repeat
                RetailJnlLine.InitLine();
                RetailJnlLine.SetItem(TransferShipmentLine."Item No.", TransferShipmentLine."Variant Code", '');
                RetailJnlLine."Quantity to Print" := TransferShipmentLine.Quantity;

                RetailJnlLine.Insert();
            until TransferShipmentLine.Next() = 0;
        RetailJnlLine.CloseGUI();
    end;

    procedure TransferReceipt2RetailJnl(TransferReceiptNo: Code[20]; RetailJnlCode: Code[40])
    var
        TransferReceiptHeader: Record "Transfer Receipt Header";
        TransferReceiptLine: Record "Transfer Receipt Line";
    begin
        if TransferReceiptNo = '' then begin
            if not (PAGE.RunModal(0, TransferReceiptHeader) = ACTION::LookupOK) then
                exit;
        end else
            TransferReceiptHeader.Get(TransferReceiptNo);

        TransferReceiptLine.SetRange("Document No.", TransferReceiptHeader."No.");
        CopyTransferReceipt2RetailJnlLines(TransferReceiptLine, RetailJnlCode);
    end;

    procedure CopyTransferReceipt2RetailJnlLines(var TransferReceiptLine: Record "Transfer Receipt Line"; RetailJnlCode: Code[40])
    var
        RetailJnlLine: Record "NPR Retail Journal Line";
    begin
        if not SetRetailJnl(RetailJnlCode) then
            exit;

        RetailJnlLine.SelectRetailJournal(RetailJnlHeader."No.");
        RetailJnlLine.UseGUI(TransferReceiptLine.Count());
        if TransferReceiptLine.FindSet() then
            repeat
                RetailJnlLine.InitLine();
                RetailJnlLine.SetItem(TransferReceiptLine."Item No.", TransferReceiptLine."Variant Code", '');
                RetailJnlLine."Quantity to Print" := TransferReceiptLine.Quantity;

                RetailJnlLine.Insert();
            until TransferReceiptLine.Next() = 0;
        RetailJnlLine.CloseGUI();
    end;

    procedure TransferOrder2RetailJnl(TransferOrderNo: Code[20]; RetailJnlCode: Code[40])
    var
        TransferHeader: Record "Transfer Header";
        TransferLine: Record "Transfer Line";
    begin
        if TransferOrderNo = '' then begin
            if not (PAGE.RunModal(0, TransferHeader) = ACTION::LookupOK) then
                exit;
        end else
            TransferHeader.Get(TransferOrderNo);

        TransferLine.SetRange("Document No.", TransferHeader."No.");
        TransferLine.SetRange("Derived From Line No.", 0);
        CopyTransferOrder2RetailJnlLines(TransferLine, RetailJnlCode);
    end;

    procedure CopyTransferOrder2RetailJnlLines(var TransferLine: Record "Transfer Line"; RetailJnlCode: Code[40])
    var
        RetailJnlLine: Record "NPR Retail Journal Line";
    begin
        if not SetRetailJnl(RetailJnlCode) then
            exit;

        RetailJnlLine.SelectRetailJournal(RetailJnlHeader."No.");
        RetailJnlLine.UseGUI(TransferLine.Count());
        if TransferLine.FindSet() then
            repeat
                RetailJnlLine.InitLine();
                RetailJnlLine.SetItem(TransferLine."Item No.", TransferLine."Variant Code", '');
                RetailJnlLine."Quantity to Print" := TransferLine.Quantity;

                RetailJnlLine.Insert();
            until TransferLine.Next() = 0;
        RetailJnlLine.CloseGUI();
    end;

    procedure PurchaseOrder2RetailJnl(DocumentType: Enum "Purchase Document Type"; PurchaseOrderNo: Code[20]; RetailJnlCode: Code[40])
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
    begin
        if PurchaseOrderNo = '' then begin
            PurchaseHeader.SetRange("Document Type", DocumentType);
            if not (PAGE.RunModal(0, PurchaseHeader) = ACTION::LookupOK) then
                exit;
        end else
            PurchaseHeader.Get(DocumentType, PurchaseOrderNo);

        PurchaseLine.SetRange("Document Type", PurchaseHeader."Document Type");
        PurchaseLine.SetRange("Document No.", PurchaseHeader."No.");
        CopyPurchaseOrder2RetailJnlLines(PurchaseLine, RetailJnlCode);
    end;

    procedure CopyPurchaseOrder2RetailJnlLines(var PurchaseLine: Record "Purchase Line"; RetailJnlCode: Code[40])
    var
        RetailJnlLine: Record "NPR Retail Journal Line";
    begin
        if not SetRetailJnl(RetailJnlCode) then
            exit;
        Selection := StrMenu(Text004, 1);
        if Selection = 0 then
            exit;
        PurchaseLine.SetRange(Type, PurchaseLine.Type::Item);
        RetailJnlLine.SelectRetailJournal(RetailJnlHeader."No.");
        RetailJnlLine.UseGUI(PurchaseLine.Count());
        if PurchaseLine.FindSet() then
            repeat
                RetailJnlLine.InitLine();
                if PurchaseLine."Item Reference Type" = PurchaseLine."Item Reference Type"::"Bar Code" then
                    RetailJnlLine.SetItem(PurchaseLine."No.", PurchaseLine."Variant Code", PurchaseLine."Item Reference No.")
                else
                    RetailJnlLine.SetItem(PurchaseLine."No.", PurchaseLine."Variant Code", '');
                case Selection of
                    1:
                        RetailJnlLine."Quantity to Print" := PurchaseLine.Quantity;
                    2:
                        RetailJnlLine."Quantity to Print" := PurchaseLine."Qty. to Receive";
                    3:
                        RetailJnlLine."Quantity to Print" := PurchaseLine."Quantity Received";
                end;
                RetailJnlLine."Last Direct Cost" := PurchaseLine."Direct Unit Cost";

                OnBeforeRetJnlLineInsertFromPurchLine(PurchaseLine, RetailJnlLine);
                RetailJnlLine.Insert();
            until PurchaseLine.Next() = 0;
        RetailJnlLine.CloseGUI();
    end;

    procedure PostedPurchaseInvoice2RetailJnl(PurchaseInvoiceNo: Code[20]; RetailJnlCode: Code[40])
    var
        PurchInvHeader: Record "Purch. Inv. Header";
        PurchInvLine: Record "Purch. Inv. Line";
    begin
        if PurchaseInvoiceNo = '' then begin
            if not (PAGE.RunModal(0, PurchInvHeader) = ACTION::LookupOK) then
                exit;
        end else
            PurchInvHeader.Get(PurchaseInvoiceNo);

        PurchInvLine.SetRange("Document No.", PurchInvHeader."No.");
        CopyPostedPurchaseInv2RetailJnlLines(PurchInvLine, RetailJnlCode);
    end;

    procedure CopyPostedPurchaseInv2RetailJnlLines(var PurchInvLine: Record "Purch. Inv. Line"; RetailJnlCode: Code[40])
    var
        RetailJnlLine: Record "NPR Retail Journal Line";
    begin
        if not SetRetailJnl(RetailJnlCode) then
            exit;

        PurchInvLine.SetRange(Type, PurchInvLine.Type::Item);
        RetailJnlLine.SelectRetailJournal(RetailJnlHeader."No.");
        RetailJnlLine.UseGUI(PurchInvLine.Count());
        if PurchInvLine.FindSet() then
            repeat
                RetailJnlLine.InitLine();

                if PurchInvLine."Item Reference Type" = PurchInvLine."Item Reference Type"::"Bar Code" then
                    RetailJnlLine.SetItem(PurchInvLine."No.", PurchInvLine."Variant Code", PurchInvLine."Item Reference No.")
                else
                    RetailJnlLine.SetItem(PurchInvLine."No.", PurchInvLine."Variant Code", '');
                RetailJnlLine."Quantity to Print" := PurchInvLine.Quantity;

                RetailJnlLine."Last Direct Cost" := PurchInvLine."Direct Unit Cost";

                OnBeforeRetJnlLineInsertFromPurchInvLine(PurchInvLine, RetailJnlLine);
                RetailJnlLine.Insert();
            until PurchInvLine.Next() = 0;
        RetailJnlLine.CloseGUI();
    end;

    procedure InventoryPutAway2RetailJnl(DocumentType: Integer; DocumentNo: Code[20]; RetailJnlCode: Code[40])
    var
        WarehouseActivityHeader: Record "Warehouse Activity Header";
        WarehouseActivityLine: Record "Warehouse Activity Line";
    begin
        if DocumentNo = '' then begin
            WarehouseActivityHeader.SetRange(Type, DocumentType);
            if not (PAGE.RunModal(0, WarehouseActivityHeader) = ACTION::LookupOK) then
                exit;
        end else
            WarehouseActivityHeader.Get(DocumentType, DocumentNo);

        WarehouseActivityLine.SetRange("Activity Type", DocumentType);
        WarehouseActivityLine.SetRange("No.", DocumentNo);
        CopyInventoryPutAway2RetailJnlLines(WarehouseActivityLine, RetailJnlCode);
    end;

    procedure CopyInventoryPutAway2RetailJnlLines(var WarehouseActivityLine: Record "Warehouse Activity Line"; RetailJnlCode: Code[40])
    var
        RetailJnlLine: Record "NPR Retail Journal Line";
    begin
        if not SetRetailJnl(RetailJnlCode) then
            exit;

        RetailJnlLine.SelectRetailJournal(RetailJnlHeader."No.");
        RetailJnlLine.UseGUI(WarehouseActivityLine.Count());
        if WarehouseActivityLine.FindSet() then
            repeat
                RetailJnlLine.InitLine();

                RetailJnlLine.SetItem(WarehouseActivityLine."Item No.", WarehouseActivityLine."Variant Code", '');
                RetailJnlLine."Quantity to Print" := WarehouseActivityLine.Quantity;

                RetailJnlLine.Insert();
            until WarehouseActivityLine.Next() = 0;
        RetailJnlLine.CloseGUI();
    end;

    procedure SetRetailJnl(var RetailJnlCode: Code[40]) Selected: Boolean
    begin
        if RetailJnlCode <> '' then begin
            if RetailJnlHeader."No." <> RetailJnlCode then
                RetailJnlHeader.Get(RetailJnlCode)
        end else begin
            if PAGE.RunModal(PAGE::"NPR Retail Journal List", RetailJnlHeader) <> ACTION::LookupOK then
                exit(false);
            RetailJnlCode := RetailJnlHeader."No.";
        end;

        exit(true);
    end;

    procedure SetRetailJnlTemp(RetailJnlCode: Code[40])
    var
        POSUnit: Record "NPR POS Unit";
    begin
        RetailJnlHeader.Init();
        RetailJnlHeader."No." := RetailJnlCode;
        RetailJnlHeader."Register No." := POSUnit.GetCurrentPOSUnit();

    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR Label Library", 'OnBeforePrintRetailJournal', '', true, true)]
    local procedure PrintRetailJournalList(var JournalLine: Record "NPR Retail Journal Line"; ReportType: Integer; var Skip: Boolean)
    begin
        if ReportType <> REPORT::"NPR Retail Journal List" then
            exit;
        REPORT.Run(ReportType, true, false, JournalLine);
        Skip := true;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeRetJnlLineInsertFromPurchLine(PurchaseLine: Record "Purchase Line"; var RetailJnlLine: Record "NPR Retail Journal Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeRetJnlLineInsertFromPurchInvLine(PurchInvLine: Record "Purch. Inv. Line"; var RetailJnlLine: Record "NPR Retail Journal Line")
    begin
    end;
}

