codeunit 6014467 "NPR Retail Journal Code"
{
    // VRT1.00/JDH/20150305  CASE 201022 discontinue of price updates for variants
    // NPR4.21/MMV/20160215  CASE 232628 Added function CreateItemLines()
    // NPR5.23/JDH /20160513 CASE 240916 Removed old VariaX code
    // NPR5.31/JLK /20170331  CASE 268274 Changed ENU Caption
    // NPR5.46/JDH /20180926 CASE 294354 Function Export To Items Deleted, added new functions to structure Retail Journal line creation
    // NPR5.46.04/THRO/20181101 CASE 334681 Set "Quantity to Print" to Quantity in CopyTransferShipment2RetailJnlLines, CopyTransferReceipt2RetailJnlLines,
    //                                   CopyTransferOrder2RetailJnlLines and CopyPurchaseOrder2RetailJnlLines
    //                                   Also checking that the Item Cross Reference is of Type Barcode. Else its transferred blank
    // NPR5.49/MMV /20190314 CASE 347537 Marking object without modification to trigger re-release of 5.46.04
    // NPR5.49/ZESO/20190214 CASE 334538 Reworked Function for Sales Return
    // NPR5.50/ZESO/20190513 CASE 353996 Read Unit Price from Purchase Line instead of from Item Card.
    // NPR5.51/BHR /20190614 CASE 358287  Add retail print and Price label for Posted Purchase Invoice
    // NPR5.51/BHR /20190722 CASE 348731  Add selection for Purchase lines Quantity
    // NPR5.53/TJ  /20191118 CASE 375557 New function to print report from Retail Journal which is not part of the Report Selection Retail
    // NPR5.54/ALPO/20200310 CASE 385913 Do not overwrite "Unite Price" (field 29) in Retail Journal by field's "Unit Price (LCY)" value from Purchase Invoice Line
    //                                   Added publishers to alter this behaviour in customer specific solutions
    // NPR5.55/BHR /202020713 CASE 414268 Add retail print and Price label for warehouse activity line


    trigger OnRun()
    begin
    end;

    var
        Text002: Label 'Update of Variant prices not supported from here. Please update them from the item card';
        RetailJnlHeader: Record "NPR Retail Journal Header";
        LineNo: Integer;
        Text003: Label 'Filters - %1', Comment = '%1 = Table Name';
        Selection: Integer;
        Text004: Label '&Quantity,Quantity &to Receive,Quantity &Received';

    procedure ExportToRetailJournal(var RetailJournalLine: Record "NPR Retail Journal Line")
    var
        RetailJournalHeader: Record "NPR Retail Journal Header";
        RetailJournalLine2: Record "NPR Retail Journal Line";
        RetailJournalList: Page "NPR Retail Journal List";
        Dialog: Dialog;
        Counter: Integer;
        LineNo: Integer;
        LineCounter: Integer;
        TotalHeaders: Integer;
        Text001: Label 'Transferring...';
        Text002: Label '@1@@@@@@@@@@';
        Total: Integer;
    begin
        RetailJournalList.LookupMode(true);
        RetailJournalList.SetTableView(RetailJournalHeader);

        if not (RetailJournalList.RunModal = ACTION::LookupOK) then
            exit;

        RetailJournalList.GetSelectionFilter(RetailJournalHeader);

        Total := RetailJournalLine.Count;
        TotalHeaders := RetailJournalHeader.Count;

        Dialog.Open(Text001 + '\' + Text002);

        if RetailJournalHeader.FindFirst then
            repeat
                Clear(RetailJournalLine2);
                RetailJournalLine2.SetRange("No.", RetailJournalHeader."No.");

                if RetailJournalLine2.FindLast then
                    TotalHeaders := RetailJournalLine2."Line No." + 10000
                else
                    TotalHeaders := 10000;

                LineCounter := 0;
                if RetailJournalLine.Find('-') then
                    repeat
                        Counter += 1;
                        LineCounter += 1;
                        Dialog.Update(1, Round(Counter / (Total * TotalHeaders) * 10000, 1, '>'));
                        RetailJournalLine2.Init;
                        RetailJournalLine2 := RetailJournalLine;
                        RetailJournalLine2."No." := RetailJournalHeader."No.";
                        RetailJournalLine2."Line No." := LineNo + LineCounter * 10000;
                        RetailJournalLine2.Insert(true);
                    until RetailJournalLine.Next = 0;
            until RetailJournalHeader.Next = 0;
        Dialog.Close;
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

        if not (CampaignDiscountList.RunModal = ACTION::LookupOK) then
            exit;

        CampaignDiscountList.GetRecord(PeriodDiscount);

        Dialog.Open(Text0001);

        Total := RetailJournalLine.Count;

        PeriodDiscountLine.Reset;

        if RetailJournalLine.Find('-') then
            repeat
                Counter += 1;
                Dialog.Update(1, RetailJournalLine."Item No.");
                Dialog.Update(2, Round(Counter / Total * 10000, 10000, '='));
                if not PeriodDiscountLine.Get(PeriodDiscount.Code, RetailJournalLine."Item No.") then begin
                    PeriodDiscountLine.Init;
                    PeriodDiscountLine.Validate(Code, PeriodDiscount.Code);
                    PeriodDiscountLine.Validate("Item No.", RetailJournalLine."Item No.");
                    PeriodDiscountLine.Insert;
                    PeriodDiscountLine.CalcFields("Unit Price");
                    if PeriodDiscountLine."Unit Price" <> 0 then
                        PeriodDiscountLine.Validate("Campaign Unit Price", PeriodDiscountLine."Unit Price")
                    else
                        PeriodDiscountLine."Campaign Unit Price" := RetailJournalLine."Discount Price Incl. Vat";
                    PeriodDiscountLine.Modify;
                end else begin
                    PeriodDiscountLine.CalcFields("Unit Price");
                    if PeriodDiscountLine."Unit Price" <> 0 then
                        PeriodDiscountLine.Validate("Campaign Unit Price", RetailJournalLine."Discount Price Incl. Vat")
                    else
                        PeriodDiscountLine."Campaign Unit Price" := RetailJournalLine."Discount Price Incl. Vat";
                    PeriodDiscountLine.Modify;
                end;
            until RetailJournalLine.Next = 0;
        Dialog.Close;
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
            until ItemJournalTemplate.Next = 0;

        BatchFilter := DelStr(BatchFilter, 1, 1);

        ItemJournalBatch.SetFilter("Journal Template Name", BatchFilter);
        ItemJournalBatches.SetTableView(ItemJournalBatch);
        ItemJournalBatches.LookupMode(true);

        if not (ItemJournalBatches.RunModal = ACTION::LookupOK) then
            exit;

        ItemJournalBatches.GetRecord(ItemJournalBatch);

        ItemJournalLine.SetRange("Journal Template Name", ItemJournalBatch."Journal Template Name");
        ItemJournalLine.SetRange("Journal Batch Name", ItemJournalBatch.Name);

        if ItemJournalLine.Find('+') then
            NextItemJournalLineNo := ItemJournalLine."Line No." + 10000
        else
            NextItemJournalLineNo := 10000;

        ItemJournalLine.Reset;

        CurrentLine := 0;
        Total := RetailJournalLine.Count;
        Dialog.Open(Text002, RetailJournalLine.Description, CurrentLine, Total);

        if RetailJournalLine.Find('-') then
            repeat
                Dialog.Update;
                if RetailJournalLine."Item No." <> '' then begin
                    ItemJournalLine.Init;
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
                    ItemJournalLine.Insert;
                    NextItemJournalLineNo += 10000;
                end;
                CurrentLine += 1;
            until RetailJournalLine.Next = 0;

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
        LineNo: Integer;
    begin
        RetailJournalHeader.Get(RetailJournalLine."No.");

        ReqWkshTemplate.SetRange(Type, ReqWkshTemplate.Type::"Req.");

        if ReqWkshTemplate.Find('-') then
            repeat
                ReqFilter += '|' + ReqWkshTemplate.Name;
            until ReqWkshTemplate.Next = 0;

        ReqFilter := DelStr(ReqFilter, 1, 1);

        RequisitionWkshName.SetFilter("Worksheet Template Name", ReqFilter);

        if PAGE.RunModal(PAGE::"Req. Wksh. Names", RequisitionWkshName) = ACTION::LookupOK then begin
            RequisitionLine.SetRange("Worksheet Template Name", RequisitionWkshName."Worksheet Template Name");
            RequisitionLine.SetRange("Journal Batch Name", RequisitionWkshName.Name);
            if RequisitionLine.Find('+') then;
            LineNo := RequisitionLine."Line No." + 10000;

            if RetailJournalLine.Find('-') then
                repeat
                    if (RetailJournalLine."Item No." <> '') and (Item.Get(RetailJournalLine."Item No.")) then begin
                        RequisitionLine.Init;
                        RequisitionLine.Validate("Worksheet Template Name", RequisitionWkshName."Worksheet Template Name");
                        RequisitionLine.Validate("Journal Batch Name", RequisitionWkshName.Name);
                        RequisitionLine.Validate("Line No.", LineNo);
                        RequisitionLine.Validate(Type, RequisitionLine.Type::Item);
                        RequisitionLine.Validate("No.", RetailJournalLine."Item No.");
                        RequisitionLine.Validate(Quantity, RetailJournalLine."Quantity to Print");
                        RequisitionLine.Validate("Shortcut Dimension 1 Code", RetailJournalHeader."Shortcut Dimension 1 Code");
                        RequisitionLine.Validate("Shortcut Dimension 2 Code", RetailJournalHeader."Shortcut Dimension 2 Code");
                        RequisitionLine.Validate("Location Code", RetailJournalHeader."Location Code");
                        RequisitionLine.Insert(true);
                        LineNo += 10000;
                    end;
                until RetailJournalLine.Next = 0;
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
        //-NPR5.46 [294354]
        if not SetRetailJnl(RetailJnlCode) then
            exit;

        with PeriodDiscountLine do begin
            RetailJnlLine.SelectRetailJournal(RetailJnlHeader."No.");
            RetailJnlLine.UseGUI(Count);
            if FindSet then
                repeat
                    CalcFields("Unit Price Incl. VAT");
                    RetailJnlLine.InitLine;
                    RetailJnlLine.SetItem("Item No.", "Variant Code", "Cross-Reference No.");
                    RetailJnlLine.SetDiscountType(1, Code, "Campaign Unit Price", 1, "Unit Price Incl. VAT");
                    RetailJnlLine.Insert();
                until Next = 0;
        end;
        RetailJnlLine.CloseGUI;
        //+NPR5.46 [294354]
    end;

    procedure Mix2RetailJnl(MixCode: Code[20]; RetailJnlCode: Code[40])
    var
        MixedDiscount: Record "NPR Mixed Discount";
        MixedDiscountLine: Record "NPR Mixed Discount Line";
    begin
        //-NPR5.46 [294354]
        if MixCode = '' then begin
            if not (PAGE.RunModal(0, MixedDiscount) = ACTION::LookupOK) then
                exit;
        end else
            MixedDiscount.Get(MixCode);

        MixedDiscountLine.SetRange(Code, MixedDiscount.Code);
        CopyMix2RetailJnlLines(MixedDiscountLine, RetailJnlCode);
        //+NPR5.46 [294354]
    end;

    procedure CopyMix2RetailJnlLines(var MixedDiscountLine: Record "NPR Mixed Discount Line"; RetailJnlCode: Code[40])
    var
        RetailJnlLine: Record "NPR Retail Journal Line";
    begin
        //-NPR5.46 [294354]
        if not SetRetailJnl(RetailJnlCode) then
            exit;

        with MixedDiscountLine do begin
            RetailJnlLine.SelectRetailJournal(RetailJnlHeader."No.");
            RetailJnlLine.UseGUI(Count);
            if FindSet then
                repeat
                    CalcFields("Unit price incl. VAT");
                    RetailJnlLine.InitLine;
                    RetailJnlLine.SetItem("No.", "Variant Code", "Cross-Reference No.");
                    RetailJnlLine.SetDiscountType(2, Code, "Unit price", Quantity, "Unit price incl. VAT");
                    RetailJnlLine.Insert();
                until Next = 0;
        end;
        RetailJnlLine.CloseGUI;
        //+NPR5.46 [294354]
    end;

    procedure Quantity2RetailJnl(ItemNo: Code[20]; MainItemNo: Code[20]; RetailJnlCode: Code[40])
    var
        QuantityDiscountHeader: Record "NPR Quantity Discount Header";
        QuantityDiscountLine: Record "NPR Quantity Discount Line";
    begin
        //-NPR5.46 [294354]
        if ItemNo = '' then begin
            if not (PAGE.RunModal(0, QuantityDiscountHeader) = ACTION::LookupOK) then
                exit;
        end else
            QuantityDiscountHeader.Get(ItemNo, MainItemNo);

        QuantityDiscountLine.SetRange("Item No.", QuantityDiscountHeader."Item No.");
        QuantityDiscountLine.SetRange("Main no.", QuantityDiscountHeader."Main No.");
        CopyQuantity2RetailJnlLines(QuantityDiscountLine, RetailJnlCode);
        //+NPR5.46 [294354]
    end;

    procedure CopyQuantity2RetailJnlLines(var QuantityDiscountLine: Record "NPR Quantity Discount Line"; RetailJnlCode: Code[40])
    var
        RetailJnlLine: Record "NPR Retail Journal Line";
    begin
        //-NPR5.46 [294354]
        if not SetRetailJnl(RetailJnlCode) then
            exit;

        with QuantityDiscountLine do begin
            RetailJnlLine.SelectRetailJournal(RetailJnlHeader."No.");
            RetailJnlLine.UseGUI(Count);
            if FindSet then
                repeat
                    CalcFields("Price Includes VAT");
                    RetailJnlLine.InitLine;
                    RetailJnlLine.SetItem("Item No.", '', '');
                    RetailJnlLine.SetDiscountType(3, "Main no.", "Unit Price", Quantity, "Price Includes VAT");
                    RetailJnlLine.Insert();
                until Next = 0;
        end;
        RetailJnlLine.CloseGUI;
        //+NPR5.46 [294354]
    end;

    procedure TransferShipment2RetailJnl(TransferShipmentNo: Code[20]; RetailJnlCode: Code[40])
    var
        TransferShipmentHeader: Record "Transfer Shipment Header";
        TransferShipmentLine: Record "Transfer Shipment Line";
    begin
        //-NPR5.46 [294354]
        if TransferShipmentNo = '' then begin
            if not (PAGE.RunModal(0, TransferShipmentHeader) = ACTION::LookupOK) then
                exit;
        end else
            TransferShipmentHeader.Get(TransferShipmentNo);

        TransferShipmentLine.SetRange("Document No.", TransferShipmentHeader."No.");
        CopyTransferShipment2RetailJnlLines(TransferShipmentLine, RetailJnlCode);
        //+NPR5.46 [294354]
    end;

    procedure CopyTransferShipment2RetailJnlLines(var TransferShipmentLine: Record "Transfer Shipment Line"; RetailJnlCode: Code[40])
    var
        RetailJnlLine: Record "NPR Retail Journal Line";
    begin
        //-NPR5.46 [294354]
        if not SetRetailJnl(RetailJnlCode) then
            exit;

        with TransferShipmentLine do begin
            RetailJnlLine.SelectRetailJournal(RetailJnlHeader."No.");
            RetailJnlLine.UseGUI(Count);
            if FindSet then
                repeat
                    RetailJnlLine.InitLine;
                    RetailJnlLine.SetItem("Item No.", "Variant Code", '');
                    //-NPR5.46.04 [334681]
                    RetailJnlLine."Quantity to Print" := Quantity;
                    //+NPR5.46.04 [334681]

                    RetailJnlLine.Insert();
                until Next = 0;
        end;
        RetailJnlLine.CloseGUI;
        //+NPR5.46 [294354]
    end;

    procedure TransferReceipt2RetailJnl(TransferReceiptNo: Code[20]; RetailJnlCode: Code[40])
    var
        TransferReceiptHeader: Record "Transfer Receipt Header";
        TransferReceiptLine: Record "Transfer Receipt Line";
    begin
        //-NPR5.46 [294354]
        if TransferReceiptNo = '' then begin
            if not (PAGE.RunModal(0, TransferReceiptHeader) = ACTION::LookupOK) then
                exit;
        end else
            TransferReceiptHeader.Get(TransferReceiptNo);

        TransferReceiptLine.SetRange("Document No.", TransferReceiptHeader."No.");
        CopyTransferReceipt2RetailJnlLines(TransferReceiptLine, RetailJnlCode);
        //+NPR5.46 [294354]
    end;

    procedure CopyTransferReceipt2RetailJnlLines(var TransferReceiptLine: Record "Transfer Receipt Line"; RetailJnlCode: Code[40])
    var
        RetailJnlLine: Record "NPR Retail Journal Line";
    begin
        //-NPR5.46 [294354]
        if not SetRetailJnl(RetailJnlCode) then
            exit;

        with TransferReceiptLine do begin
            RetailJnlLine.SelectRetailJournal(RetailJnlHeader."No.");
            RetailJnlLine.UseGUI(Count);
            if FindSet then
                repeat
                    RetailJnlLine.InitLine;
                    RetailJnlLine.SetItem("Item No.", "Variant Code", '');
                    //-NPR5.46.04 [334681]
                    RetailJnlLine."Quantity to Print" := Quantity;
                    //+NPR5.46.04 [334681]

                    RetailJnlLine.Insert();
                until Next = 0;
        end;
        RetailJnlLine.CloseGUI;
        //+NPR5.46 [294354]
    end;

    procedure TransferOrder2RetailJnl(TransferOrderNo: Code[20]; RetailJnlCode: Code[40])
    var
        TransferHeader: Record "Transfer Header";
        TransferLine: Record "Transfer Line";
    begin
        //-NPR5.46 [294354]
        if TransferOrderNo = '' then begin
            if not (PAGE.RunModal(0, TransferHeader) = ACTION::LookupOK) then
                exit;
        end else
            TransferHeader.Get(TransferOrderNo);

        TransferLine.SetRange("Document No.", TransferHeader."No.");
        TransferLine.SetRange("Derived From Line No.", 0);
        CopyTransferOrder2RetailJnlLines(TransferLine, RetailJnlCode);
        //+NPR5.46 [294354]
    end;

    procedure CopyTransferOrder2RetailJnlLines(var TransferLine: Record "Transfer Line"; RetailJnlCode: Code[40])
    var
        RetailJnlLine: Record "NPR Retail Journal Line";
    begin
        //-NPR5.46 [294354]
        if not SetRetailJnl(RetailJnlCode) then
            exit;

        with TransferLine do begin
            RetailJnlLine.SelectRetailJournal(RetailJnlHeader."No.");
            RetailJnlLine.UseGUI(Count);
            if FindSet then
                repeat
                    RetailJnlLine.InitLine;
                    RetailJnlLine.SetItem("Item No.", "Variant Code", '');
                    //-NPR5.46.04 [334681]
                    RetailJnlLine."Quantity to Print" := Quantity;
                    //+NPR5.46.04 [334681]

                    RetailJnlLine.Insert();
                until Next = 0;
        end;
        RetailJnlLine.CloseGUI;
        //+NPR5.46 [294354]
    end;

    procedure PurchaseOrder2RetailJnl(DocumentType: Integer; PurchaseOrderNo: Code[20]; RetailJnlCode: Code[40])
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
    begin
        //-NPR5.46 [294354]
        if PurchaseOrderNo = '' then begin
            PurchaseHeader.SetRange("Document Type", DocumentType);
            if not (PAGE.RunModal(0, PurchaseHeader) = ACTION::LookupOK) then
                exit;
        end else
            PurchaseHeader.Get(DocumentType, PurchaseOrderNo);

        PurchaseLine.SetRange("Document Type", PurchaseHeader."Document Type");
        PurchaseLine.SetRange("Document No.", PurchaseHeader."No.");
        CopyPurchaseOrder2RetailJnlLines(PurchaseLine, RetailJnlCode);
        //+NPR5.46 [294354]
    end;

    procedure CopyPurchaseOrder2RetailJnlLines(var PurchaseLine: Record "Purchase Line"; RetailJnlCode: Code[40])
    var
        RetailJnlLine: Record "NPR Retail Journal Line";
    begin
        //-NPR5.46 [294354]
        if not SetRetailJnl(RetailJnlCode) then
            exit;
        //-NPR5.51 [348731]
        Selection := StrMenu(Text004, 1);
        if Selection = 0 then
            exit;
        //+NPR5.51 [348731]
        with PurchaseLine do begin
            SetRange(Type, Type::Item);
            RetailJnlLine.SelectRetailJournal(RetailJnlHeader."No.");
            RetailJnlLine.UseGUI(Count);
            if FindSet then
                repeat
                    RetailJnlLine.InitLine;
                    //-NPR5.46.04 [334681]
                    //RetailJnlLine.SetItem("No.", "Variant Code", "Cross-Reference No.");
                    if "Cross-Reference Type" = "Cross-Reference Type"::"Bar Code" then
                        RetailJnlLine.SetItem("No.", "Variant Code", "Cross-Reference No.")
                    else
                        RetailJnlLine.SetItem("No.", "Variant Code", '');
                    //-NPR5.51 [348731]
                    //RetailJnlLine."Quantity to Print" := Quantity;
                    case Selection of
                        1:
                            RetailJnlLine."Quantity to Print" := Quantity;
                        2:
                            RetailJnlLine."Quantity to Print" := "Qty. to Receive";
                        3:
                            RetailJnlLine."Quantity to Print" := "Quantity Received";
                    end;
                    //+NPR5.51 [348731]
                    //+NPR5.46.04 [334681]


                    //-NPR5.50 [353996]
                    //RetailJnlLine."Unit Price" := PurchaseLine."Unit Price (LCY)";  //NPR5.54 [385913]-revoked
                    RetailJnlLine."Last Direct Cost" := PurchaseLine."Direct Unit Cost";
                    //-NPR5.50 [353996]

                    OnBeforeRetJnlLineInsertFromPurchLine(PurchaseLine, RetailJnlLine);  //NPR5.54 [385913]
                    RetailJnlLine.Insert();
                until Next = 0;
        end;
        RetailJnlLine.CloseGUI;
        //+NPR5.46 [294354]
    end;

    procedure PostedPurchaseInvoice2RetailJnl(PurchaseInvoiceNo: Code[20]; RetailJnlCode: Code[40])
    var
        PurchInvHeader: Record "Purch. Inv. Header";
        PurchInvLine: Record "Purch. Inv. Line";
    begin
        //-NPR5.51 [358287]
        if PurchaseInvoiceNo = '' then begin
            if not (PAGE.RunModal(0, PurchInvHeader) = ACTION::LookupOK) then
                exit;
        end else
            PurchInvHeader.Get(PurchaseInvoiceNo);

        PurchInvLine.SetRange("Document No.", PurchInvHeader."No.");
        CopyPostedPurchaseInv2RetailJnlLines(PurchInvLine, RetailJnlCode);
        //+NPR5.51 [358287]
    end;

    procedure CopyPostedPurchaseInv2RetailJnlLines(var PurchInvLine: Record "Purch. Inv. Line"; RetailJnlCode: Code[40])
    var
        RetailJnlLine: Record "NPR Retail Journal Line";
    begin
        //-NPR5.51 [358287]
        if not SetRetailJnl(RetailJnlCode) then
            exit;

        with PurchInvLine do begin
            SetRange(Type, Type::Item);
            RetailJnlLine.SelectRetailJournal(RetailJnlHeader."No.");
            RetailJnlLine.UseGUI(Count);
            if FindSet then
                repeat
                    RetailJnlLine.InitLine;

                    if "Cross-Reference Type" = "Cross-Reference Type"::"Bar Code" then
                        RetailJnlLine.SetItem("No.", "Variant Code", "Cross-Reference No.")
                    else
                        RetailJnlLine.SetItem("No.", "Variant Code", '');
                    RetailJnlLine."Quantity to Print" := Quantity;

                    //RetailJnlLine."Unit Price" := PurchInvLine."Unit Price (LCY)";  //NPR5.54 [385913]-revoked
                    RetailJnlLine."Last Direct Cost" := PurchInvLine."Direct Unit Cost";

                    OnBeforeRetJnlLineInsertFromPurchInvLine(PurchInvLine, RetailJnlLine);  //NPR5.54 [385913]
                    RetailJnlLine.Insert();
                until Next = 0;
        end;
        RetailJnlLine.CloseGUI;
        //+NPR5.51 [358287]
    end;

    procedure InventoryPutAway2RetailJnl(DocumentType: Integer; DocumentNo: Code[20]; RetailJnlCode: Code[40])
    var
        WarehouseActivityHeader: Record "Warehouse Activity Header";
        WarehouseActivityLine: Record "Warehouse Activity Line";
    begin
        //-NPR5.55 [414268]
        if DocumentNo = '' then begin
            WarehouseActivityHeader.SetRange(Type, DocumentType);
            if not (PAGE.RunModal(0, WarehouseActivityHeader) = ACTION::LookupOK) then
                exit;
        end else
            WarehouseActivityHeader.Get(DocumentType, DocumentNo);

        WarehouseActivityLine.SetRange("Activity Type", DocumentType);
        WarehouseActivityLine.SetRange("No.", DocumentNo);
        CopyInventoryPutAway2RetailJnlLines(WarehouseActivityLine, RetailJnlCode);
        //+NPR5.55 [414268]
    end;

    procedure CopyInventoryPutAway2RetailJnlLines(var WarehouseActivityLine: Record "Warehouse Activity Line"; RetailJnlCode: Code[40])
    var
        RetailJnlLine: Record "NPR Retail Journal Line";
    begin
        //-NPR5.55 [414268]
        if not SetRetailJnl(RetailJnlCode) then
            exit;

        with WarehouseActivityLine do begin
            RetailJnlLine.SelectRetailJournal(RetailJnlHeader."No.");
            RetailJnlLine.UseGUI(Count);
            if FindSet then
                repeat
                    RetailJnlLine.InitLine;

                    RetailJnlLine.SetItem(WarehouseActivityLine."Item No.", "Variant Code", '');
                    RetailJnlLine."Quantity to Print" := Quantity;

                    RetailJnlLine.Insert();
                until Next = 0;
        end;
        RetailJnlLine.CloseGUI;
        //+NPR5.55 [414268]
    end;

    procedure SetRetailJnl(var RetailJnlCode: Code[40]) Selected: Boolean
    var
        RetailJnlLine: Record "NPR Retail Journal Line";
    begin
        //-NPR5.46 [294354]
        if RetailJnlCode <> '' then begin
            if RetailJnlHeader."No." <> RetailJnlCode then
                RetailJnlHeader.Get(RetailJnlCode)
        end else begin
            if PAGE.RunModal(PAGE::"NPR Retail Journal List", RetailJnlHeader) <> ACTION::LookupOK then
                exit(false);
            RetailJnlCode := RetailJnlHeader."No.";
        end;

        RetailJnlLine.SetRange("No.", RetailJnlHeader."No.");
        if RetailJnlLine.FindLast then
            LineNo := RetailJnlLine."Line No." + 10000
        else
            LineNo := 10000;
        exit(true);
        //+NPR5.46 [294354]
    end;

    procedure SetRetailJnlTemp(RetailJnlCode: Code[40])
    var
        RetailFormCode: Codeunit "NPR Retail Form Code";
    begin
        //-NPR5.46 [294354]
        RetailJnlHeader.Init;
        RetailJnlHeader."No." := RetailJnlCode;
        RetailJnlHeader."Register No." := RetailFormCode.FetchRegisterNumber;

        LineNo := 10000;
        //+NPR5.46 [294354]
    end;

    procedure SalesReturn2RetailJnl(RetailJnlCode: Code[40])
    var
        TransferHeader: Record "Transfer Header";
        TransferLine: Record "Transfer Line";
        Register: Record "NPR Register";
        AuditRoll: Record "NPR Audit Roll";
        PageAuditRoll: Page "NPR Audit Roll";
        Filters: Text;
        RecRef: RecordRef;
    begin
        //-NPR5.49 [334538]
        if not RunDynamicRequestPage(Filters, '') then
            exit;

        if not SetFiltersOnTable(Filters, RecRef) then
            exit;

        RecRef.SetTable(AuditRoll);

        AuditRoll.SetCurrentKey("Register No.", "Sale Type", Type, "No.", "Sale Date", "Discount Type", "Shortcut Dimension 1 Code", "Shortcut Dimension 2 Code");
        AuditRoll.SetRange("Sale Type", AuditRoll."Sale Type"::Sale);
        AuditRoll.SetRange(Type, AuditRoll.Type::Item);
        AuditRoll.SetFilter(Quantity, '<%1', 0);
        CopySalesReturn2RetailJnlLines(AuditRoll, RetailJnlCode);
        //+NPR5.49 [334538]
    end;

    procedure CopySalesReturn2RetailJnlLines(var AuditRoll: Record "NPR Audit Roll"; RetailJnlCode: Code[40])
    var
        RetailJnlLine: Record "NPR Retail Journal Line";
        Register: Record "NPR Register";
    begin
        //-NPR5.49 [334538]
        if not SetRetailJnl(RetailJnlCode) then
            exit;

        with AuditRoll do begin
            RetailJnlLine.SelectRetailJournal(RetailJnlHeader."No.");
            RetailJnlLine.UseGUI(Count);
            if FindSet then
                repeat
                    RetailJnlLine.InitLine;
                    RetailJnlLine.SetItem("No.", '', '');
                    RetailJnlLine."Quantity to Print" := Abs(Quantity);
                    RetailJnlLine.Validate("Calculation Date", "Sale Date");
                    if Register.Get("Register No.") then
                        RetailJnlLine.Validate("Location Filter", Register."Location Code");
                    RetailJnlLine.Insert();
                until Next = 0;
        end;
        RetailJnlLine.CloseGUI;
        //+NPR5.49 [334538]
    end;

    local procedure RunDynamicRequestPage(var ReturnFilters: Text; Filters: Text): Boolean
    var
        TableMetadata: Record "Table Metadata";
        RequestPageParametersHelper: Codeunit "Request Page Parameters Helper";
        FilterPageBuilder: FilterPageBuilder;
        FieldRec: Record "Field";
        RecRef: RecordRef;
        KyRef: KeyRef;
        FldRef: FieldRef;
        j: Integer;
        DynamicRequestPageField: Record "Dynamic Request Page Field";
        DynamicRequestPageField1: Record "Dynamic Request Page Field";
    begin
        //-NPR5.49 [334538]
        if not TableMetadata.Get(6014407) then
            exit(false);


        DynamicRequestPageField.SetRange("Table ID", 6014407);
        if not DynamicRequestPageField.FindSet then begin
            RecRef.Open(6014407);
            RecRef.CurrentKeyIndex(1);
            KyRef := RecRef.KeyIndex(1);
            for j := 1 to KyRef.FieldCount do begin
                if (j = 1) or (j = 6) then begin
                    Clear(FldRef);
                    FldRef := RecRef.FieldIndex(j);
                    DynamicRequestPageField1.Init;
                    DynamicRequestPageField1.Validate("Table ID", 6014407);
                    DynamicRequestPageField1.Validate("Field ID", FldRef.Number);
                    DynamicRequestPageField1.Insert(true);
                    Commit;
                end;
            end;
        end;

        if not RequestPageParametersHelper.BuildDynamicRequestPage(FilterPageBuilder, CopyStr('Audit Roll', 1, 20), 6014407) then
            exit(false);
        if Filters <> '' then
            if not RequestPageParametersHelper.SetViewOnDynamicRequestPage(
               FilterPageBuilder, Filters, CopyStr('Audit Roll', 1, 20), 6014407)
            then
                exit(false);

        FilterPageBuilder.PageCaption := StrSubstNo(Text003, 'Audit Roll');
        if not FilterPageBuilder.RunModal then
            exit(false);

        ReturnFilters :=
          RequestPageParametersHelper.GetViewFromDynamicRequestPage(FilterPageBuilder, CopyStr('Audit Roll', 1, 20), 6014407);


        exit(true);
        //-NPR5.49 [334538]
    end;

    local procedure SetFiltersOnTable(Filters: Text; var RecRef: RecordRef): Boolean
    var
        TempBlob: Codeunit "Temp Blob";
        RequestPageParametersHelper: Codeunit "Request Page Parameters Helper";
        OutStream: OutStream;
    begin
        //-NPR5.49 [334538]
        RecRef.Open(6014407);

        if Filters = '' then
            exit(RecRef.FindSet);

        Clear(TempBlob);
        TempBlob.CreateOutStream(OutStream);
        OutStream.WriteText(Filters);

        if not RequestPageParametersHelper.ConvertParametersToFilters(RecRef, TempBlob) then
            exit(false);

        exit(RecRef.FindSet);
        //-NPR5.49 [334538]
    end;

    [EventSubscriber(ObjectType::Codeunit, 6014413, 'OnBeforePrintRetailJournal', '', true, true)]
    local procedure PrintRetailJournalList(var JournalLine: Record "NPR Retail Journal Line"; ReportType: Integer; var Skip: Boolean)
    begin
        //-NPR5.53 [375557]
        if ReportType <> REPORT::"NPR Retail Journal List" then
            exit;
        REPORT.Run(ReportType, true, false, JournalLine);
        Skip := true;
        //+NPR5.53 [375557]
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeRetJnlLineInsertFromPurchLine(PurchaseLine: Record "Purchase Line"; var RetailJnlLine: Record "NPR Retail Journal Line")
    begin
        //NPR5.54 [385913]
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeRetJnlLineInsertFromPurchInvLine(PurchInvLine: Record "Purch. Inv. Line"; var RetailJnlLine: Record "NPR Retail Journal Line")
    begin
        //NPR5.54 [385913]
    end;
}

