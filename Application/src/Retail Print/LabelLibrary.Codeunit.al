codeunit 6014413 "NPR Label Library"
{
    trigger OnRun()
    begin
    end;

    var
        Text00001: Label 'Please enter quantity.';
        TmpSelectionBuffer: RecordRef;
        SelectionBufferOpen: Boolean;
        Err_NoShippingLabelFound: Label 'No label setup for the selected shipping agent';
        Err_InvalidShippingLabel: Label 'The selected shipping label cannot be printed from table: %1 ';
        TmpRetailJnlCode: Code[40];

    procedure ResolveVariantAndPrintItem(var Item: Record Item; ReportType: Integer) PrintedQty: Decimal
    var
        RetailJournalHeader: Record "NPR Retail Journal Header";
        VRTWrapper: Codeunit "NPR Variety Wrapper";
        RetailJournalLine: Record "NPR Retail Journal Line";
    begin
        RetailJournalHeader.SetRange("No.", '_' + UserId + '_');
        RetailJournalHeader.DeleteAll();
        RetailJournalLine.SetRange("No.", '_' + UserId + '_');
        RetailJournalLine.DeleteAll();
        RetailJournalLine.Reset();
        RetailJournalHeader.Reset();

        Item.CalcFields("NPR Has Variants");
        if Item."NPR Has Variants" then begin
            RetailJournalLine.Init();
            RetailJournalLine."No." := '_' + UserId + '_';
            RetailJournalLine.Validate("Item No.", Item."No.");
            RetailJournalLine.Insert(true);
            VRTWrapper.RetailJournalLineShowVariety(RetailJournalLine, 0);

            Clear(RetailJournalLine);
            RetailJournalLine.SetRange("No.", '_' + UserId + '_');
            RetailJournalLine.SetFilter("Variant Code", '<>%1', '');

            if RetailJournalLine.FindSet() then begin
                PrintRetailJournal(RetailJournalLine, ReportType);
                RetailJournalLine.DeleteAll();
            end;
        end else
            PrintedQty := PrintItem(Item, true, 0, true, ReportType);
    end;

    procedure PrintItem(var Item: Record Item; PromptForQuantity: Boolean; Quantity: Integer; IsLastLine: Boolean; ReportType: Integer): Decimal
    var
        RetailJournalLine: Record "NPR Retail Journal Line";
        PrintQty: Integer;
    begin
        PrintQty := Quantity;
        if PrintQty < 1 then
            PrintQty := 1;

        if PromptForQuantity then begin
            Commit();
            if not QuantityPrompt(PrintQty) then
                exit(0);
        end;

        ItemToRetailJnlLine(Item."No.", '', PrintQty, Format(CreateGuid()), RetailJournalLine);
        RetailJournalLine.SetRecFilter();
        PrintRetailJournal(RetailJournalLine, ReportType);
        RetailJournalLine.Delete(true);

        exit(PrintQty);
    end;

    local procedure PrintBin(var Bin: Record Bin; ReportType: Integer)
    var
        RetailReportSelectionMgt: Codeunit "NPR Retail Report Select. Mgt.";
        RecRef: RecordRef;
        POSUnit: Record "NPR POS Unit";
    begin
        RetailReportSelectionMgt.SetRequestWindow(true);
        RetailReportSelectionMgt.SetRegisterNo(POSUnit.GetCurrentPOSUnit());
        RecRef.GetTable(Bin);
        RetailReportSelectionMgt.RunObjects(RecRef, ReportType);
    end;

    procedure PrintCustomShippingLabel(var RecRef: RecordRef; PrintLayoutID: Code[20])
    var
        ShippingAgent: Record "Shipping Agent";
        SalesHeader: Record "Sales Header";
        PrintSetupHeader: Record "NPR RP Template Header";
        DataItem: Record "NPR RP Data Items";
        tmpCustomer: Record Customer temporary;
        tmpCustRef: RecordRef;
        MatrixPrintMgt: Codeunit "NPR RP Matrix Print Mgt.";
        Customer: Record Customer;
    begin
        case RecRef.Number of
            DATABASE::"Sales Header":
                begin
                    RecRef.SetTable(SalesHeader);
                    ShippingAgent.Get(SalesHeader."Shipping Agent Code");
                    tmpCustomer.Init();
                    tmpCustomer.Name := SalesHeader."Ship-to Name";
                    tmpCustomer."Name 2" := SalesHeader."Ship-to Name 2";
                    tmpCustomer.Address := SalesHeader."Ship-to Address";
                    tmpCustomer."Address 2" := SalesHeader."Ship-to Address 2";
                    tmpCustomer.City := SalesHeader."Ship-to City";
                    tmpCustomer."Post Code" := SalesHeader."Ship-to Post Code";
                    tmpCustomer."Country/Region Code" := SalesHeader."Ship-to Country/Region Code";
                    tmpCustomer.County := SalesHeader."Ship-to County";
                    tmpCustomer.Insert();
                    tmpCustRef.GetTable(tmpCustomer);
                end;
            DATABASE::Customer:
                begin
                    RecRef.SetTable(Customer);
                    ShippingAgent.Get(Customer."Shipping Agent Code");
                end;
        end;

        if PrintLayoutID <> '' then
            PrintSetupHeader.Get(PrintLayoutID)
        else
            if ShippingAgent."NPR Custom Print Layout" <> '' then
                PrintSetupHeader.Get(ShippingAgent."NPR Custom Print Layout")
            else
                Error(Err_NoShippingLabelFound);

        DataItem.SetRange(Code, PrintSetupHeader.Code);
        DataItem.SetRange(Level, 0);
        DataItem.FindFirst();
        case DataItem."Table ID" of
            RecRef.Number:
                MatrixPrintMgt.ProcessTemplate(PrintSetupHeader.Code, RecRef);
            DATABASE::Customer:
                MatrixPrintMgt.ProcessTemplate(PrintSetupHeader.Code, tmpCustRef);
            else
                Error(Err_InvalidShippingLabel, RecRef.Caption);
        end
    end;

    procedure ToggleLine(var RecRefIn: RecordRef)
    begin
        if not SelectionBufferOpen then begin
            TmpSelectionBuffer.Open(RecRefIn.Number, true);
            SelectionBufferOpen := true;
        end;

        if TmpSelectionBuffer.Get(RecRefIn.RecordId) then
            TmpSelectionBuffer.Delete
        else
            TransferSelectionFields(RecRefIn);
    end;

    procedure InvertAllLines(var RecRefIn: RecordRef)
    var
        RecRef: RecordRef;
    begin
        if not SelectionBufferOpen then begin
            TmpSelectionBuffer.Open(RecRefIn.Number, true);
            SelectionBufferOpen := true;
        end;

        if RecRefIn.FindSet() then
            repeat
                RecRef := RecRefIn.Duplicate();
                RecRef.SetRecFilter();
                ToggleLine(RecRef);
                RecRef.Close();
            until RecRefIn.Next() = 0;
    end;

    procedure SelectionContains(var RecRefIn: RecordRef): Boolean
    begin
        if not SelectionBufferOpen then begin
            TmpSelectionBuffer.Open(RecRefIn.Number, true);
            SelectionBufferOpen := true;
        end;

        exit(TmpSelectionBuffer.Get(RecRefIn.RecordId));
    end;

    local procedure TransferSelectionFields(var RecRefIn: RecordRef)
    var
        "Field": Record "Field";
        FieldRefFrom: FieldRef;
        FieldRefTo: FieldRef;
    begin
        if RecRefIn.Number <> TmpSelectionBuffer.Number then
            exit;

        TmpSelectionBuffer.Init();

        Field.SetRange(TableNo, RecRefIn.Number);
        //-NPR5.51 [367416]
        Field.SetRange(Enabled, true);
        //+NPR5.51 [367416]
        if Field.FindSet() then
            repeat
                //-NPR5.51 [367416]
                if not FieldIsObsolete(Field.TableNo, Field."No.") then begin
                    //+NPR5.51 [367416]
                    FieldRefFrom := RecRefIn.Field(Field."No.");
                    FieldRefTo := TmpSelectionBuffer.Field(Field."No.");
                    FieldRefTo.Value(FieldRefFrom);
                end;
            until Field.Next() = 0;

        TmpSelectionBuffer.Insert();
    end;

    procedure SetSelectionBuffer(RecVariant: Variant)
    begin
        //-NPR5.53 [374290]
        TmpSelectionBuffer.GetTable(RecVariant);
        SelectionBufferOpen := true;
        //+NPR5.53 [374290]
    end;

    procedure PrintSelection(ReportType: Integer)
    var
        RetailJournalLine: Record "NPR Retail Journal Line";
        PurchaseLine: Record "Purchase Line";
        TransferLine: Record "Transfer Line";
        Bin: Record Bin;
        ItemJournalLine: Record "Item Journal Line";
        TransferShipmentLine: Record "Transfer Shipment Line";
        PeriodDiscountLine: Record "NPR Period Discount Line";
        TransferReceiptLine: Record "Transfer Receipt Line";
        PurchInvLine: Record "Purch. Inv. Line";
        ItemWorksheetLine: Record "NPR Item Worksheet Line";
        WarehouseActivityLine: Record "Warehouse Activity Line";
    begin
        if not SelectionBufferOpen then
            exit;

        if TmpSelectionBuffer.FindSet() then begin
            case TmpSelectionBuffer.Number of
                DATABASE::"NPR Retail Journal Line":
                    begin
                        repeat
                            if RetailJournalLine.Get(TmpSelectionBuffer.RecordId) then begin
                                RetailJournalLine.Mark(true);
                            end;
                        until TmpSelectionBuffer.Next() = 0;
                        RetailJournalLine.MarkedOnly(true);
                        if RetailJournalLine.FindSet() then
                            PrintRetailJournal(RetailJournalLine, ReportType);
                    end;
                DATABASE::"Purchase Line":
                    begin
                        repeat
                            if PurchaseLine.Get(TmpSelectionBuffer.RecordId) then begin
                                PurchaseLine.Mark(true);
                            end;
                        until TmpSelectionBuffer.Next() = 0;
                        PurchaseLine.MarkedOnly(true);
                        if PurchaseLine.FindSet() then
                            PrintPurchaseOrder(PurchaseLine, ReportType);
                    end;
                DATABASE::"Transfer Line":
                    begin
                        repeat
                            if TransferLine.Get(TmpSelectionBuffer.RecordId) then
                                TransferLine.Mark(true);
                        until TmpSelectionBuffer.Next() = 0;
                        TransferLine.MarkedOnly(true);
                        if TransferLine.FindSet() then
                            PrintTransferOrder(TransferLine, ReportType);
                    end;
                //-NPR5.29 [253966]
                DATABASE::Bin:
                    begin
                        repeat
                            if Bin.Get(TmpSelectionBuffer.RecordId) then
                                Bin.Mark(true);
                        until TmpSelectionBuffer.Next() = 0;
                        Bin.MarkedOnly(true);
                        if Bin.FindSet() then
                            PrintBin(Bin, ReportType);
                    end;
                //+NPR5.29 [253966]
                //-NPR5.43 [317852]
                DATABASE::"Item Journal Line":
                    begin
                        repeat
                            if ItemJournalLine.Get(TmpSelectionBuffer.RecordId) then
                                ItemJournalLine.Mark(true);
                        until TmpSelectionBuffer.Next() = 0;
                        ItemJournalLine.MarkedOnly(true);
                        if ItemJournalLine.FindSet() then
                            PrintItemJournal(ItemJournalLine, ReportType);
                    end;
                //+NPR5.43 [317852]
                //-NPR5.46 [294354]
                DATABASE::"Transfer Shipment Line":
                    begin
                        repeat
                            if TransferShipmentLine.Get(TmpSelectionBuffer.RecordId) then
                                TransferShipmentLine.Mark(true);
                        until TmpSelectionBuffer.Next() = 0;
                        TransferShipmentLine.MarkedOnly(true);
                        if TransferShipmentLine.IsEmpty then
                            exit;
                        PrintTransferShipment(TransferShipmentLine, ReportType);
                    end;
                DATABASE::"Transfer Receipt Line":
                    begin
                        repeat
                            if TransferReceiptLine.Get(TmpSelectionBuffer.RecordId) then
                                TransferReceiptLine.Mark(true);
                        until TmpSelectionBuffer.Next() = 0;
                        TransferReceiptLine.MarkedOnly(true);
                        if TransferReceiptLine.IsEmpty then
                            exit;
                        PrintTransferReceipt(TransferReceiptLine, ReportType);
                    end;
                DATABASE::"NPR Period Discount Line":
                    begin
                        repeat
                            if PeriodDiscountLine.Get(TmpSelectionBuffer.RecordId) then
                                PeriodDiscountLine.Mark(true);
                        until TmpSelectionBuffer.Next() = 0;
                        PeriodDiscountLine.MarkedOnly(true);
                        if PeriodDiscountLine.IsEmpty then
                            exit;
                        PrintPeriodDiscount(PeriodDiscountLine, ReportType);
                    end;
                //+NPR5.46 [294354]
                //-NPR5.51 [358287]
                DATABASE::"Purch. Inv. Line":
                    begin
                        repeat
                            if PurchInvLine.Get(TmpSelectionBuffer.RecordId) then begin
                                PurchInvLine.Mark(true);
                            end;
                        until TmpSelectionBuffer.Next() = 0;
                        PurchInvLine.MarkedOnly(true);
                        if PurchInvLine.FindSet() then
                            PrintPostedPurchaseInvoice(PurchInvLine, ReportType);
                    end;
                //-NPR5.51 [358287]
                //-NPR5.52 [366969]
                DATABASE::"NPR Item Worksheet Line":
                    begin
                        repeat
                            if ItemWorksheetLine.Get(TmpSelectionBuffer.RecordId) then
                                ItemWorksheetLine.Mark(true);
                        until TmpSelectionBuffer.Next() = 0;
                        ItemWorksheetLine.MarkedOnly(true);
                        if ItemWorksheetLine.FindSet() then
                            PrintItemWorksheetLine(ItemWorksheetLine, ReportType);
                    end;
                //+NPR5.52 [366969]
                //-NPR5.55 [414268]
                DATABASE::"Warehouse Activity Line":
                    begin
                        repeat
                            if WarehouseActivityLine.Get(TmpSelectionBuffer.RecordId) then
                                WarehouseActivityLine.Mark(true);
                        until TmpSelectionBuffer.Next() = 0;
                        WarehouseActivityLine.MarkedOnly(true);
                        if WarehouseActivityLine.FindSet() then
                            PrintWarehouseActivityLine(WarehouseActivityLine, ReportType);
                    end;
            //-NPR5.55 [414268]
            end;
        end;
    end;

    procedure RunPrintPage(var RecRef: RecordRef)
    var
        RetailJnlLine: Record "NPR Retail Journal Line";
        PurchaseLine: Record "Purchase Line";
        TransferLine: Record "Transfer Line";
        TransferShipmentLine: Record "Transfer Shipment Line";
        TransferReceiptLine: Record "Transfer Receipt Line";
        RetailJournalMgt: Codeunit "NPR Retail Journal Code";
        PeriodDiscountLine: Record "NPR Period Discount Line";
        PurchInvLine: Record "Purch. Inv. Line";
        WarehouseActivityLine: Record "Warehouse Activity Line";
    begin
        //-NPR5.46 [294354]
        TmpRetailJnlCode := Format(CreateGuid());
        RetailJournalMgt.SetRetailJnlTemp(TmpRetailJnlCode);
        //+NPR5.46 [294354]

        //-NPR5.30 [262533]
        case RecRef.Number of
            DATABASE::"Purchase Line":
                begin
                    RecRef.SetTable(PurchaseLine);
                    //-NPR5.46.05 [334681]
                    if PurchaseLine.FindFirst() then;
                    //+NPR5.46.05 [334681]

                    //-NPR5.46 [294354]
                    //PurchaseLineToRetailJnlLine(PurchaseLine, RetailJnlLine);
                    RetailJournalMgt.PurchaseOrder2RetailJnl(PurchaseLine."Document Type", PurchaseLine."Document No.", TmpRetailJnlCode);
                    //+NPR5.46 [294354]
                end;
            DATABASE::"Transfer Line":
                begin
                    RecRef.SetTable(TransferLine);
                    //-NPR5.46.05 [334681]
                    if TransferLine.FindFirst() then;
                    //+NPR5.46.05 [334681]

                    //-NPR5.46 [294354]
                    //TransferLineToRetailJnlLine(TransferLine, RetailJnlLine);
                    RetailJournalMgt.TransferOrder2RetailJnl(TransferLine."Document No.", TmpRetailJnlCode);
                    //+NPR5.46 [294354]

                end;
            //-NPR5.46 [294354]
            DATABASE::"Transfer Shipment Line":
                begin
                    RecRef.SetTable(TransferShipmentLine);
                    //-NPR5.46.05 [334681]
                    if TransferShipmentLine.FindFirst() then;
                    //+NPR5.46.05 [334681]

                    RetailJournalMgt.TransferShipment2RetailJnl(TransferShipmentLine."Document No.", TmpRetailJnlCode);
                end;
            DATABASE::"Transfer Receipt Line":
                begin
                    RecRef.SetTable(TransferReceiptLine);
                    //-NPR5.46.05 [334681]
                    if TransferReceiptLine.FindFirst() then;
                    //+NPR5.46.05 [334681]

                    RetailJournalMgt.TransferReceipt2RetailJnl(TransferReceiptLine."Document No.", TmpRetailJnlCode);
                end;
            DATABASE::"NPR Period Discount Line":
                begin
                    RecRef.SetTable(PeriodDiscountLine);
                    //-NPR5.46.05 [334681]
                    if PeriodDiscountLine.FindFirst() then;
                    //+NPR5.46.05 [334681]

                    RetailJournalMgt.Campaign2RetailJnl(PeriodDiscountLine.Code, TmpRetailJnlCode);
                end;
            //-NPR5.51 [358287]
            DATABASE::"Purch. Inv. Line":
                begin
                    RecRef.SetTable(PurchInvLine);
                    if PurchInvLine.FindFirst() then;
                    RetailJournalMgt.PostedPurchaseInvoice2RetailJnl(PurchInvLine."Document No.", TmpRetailJnlCode);
                end;
            //+NPR5.51 [358287]
            //-NPR5.55 [414268]
            DATABASE::"Warehouse Activity Line":
                begin
                    RecRef.SetTable(WarehouseActivityLine);
                    if WarehouseActivityLine.FindFirst() then;
                    RetailJournalMgt.InventoryPutAway2RetailJnl(WarehouseActivityLine."Activity Type", WarehouseActivityLine."No.", TmpRetailJnlCode);
                end;
            //+NPR5.55 [414268]
            else
                Error('table %1 is not supported for selected Printing', RecRef.Number);
        //+NPR5.46 [294354]

        end;

        Commit();

        if RetailJnlLine.IsEmpty then
            exit;

        PAGE.RunModal(PAGE::"NPR Retail Journal Print", RetailJnlLine);

        RetailJnlLine.DeleteAll();
        //+NPR5.30 [262533]
    end;

    local procedure FieldIsObsolete(TableNo: Integer; FieldNo: Integer): Boolean
    var
        FieldRecRef: RecordRef;
        FieldRef: FieldRef;
    begin
        //-NPR5.51 [367416]
        FieldRecRef.Open(DATABASE::Field);
        if not FieldRecRef.FieldExist(25) then
            exit(false);

        FieldRef := FieldRecRef.Field(1);
        FieldRef.SetRange(TableNo);

        FieldRef := FieldRecRef.Field(2);
        FieldRef.SetRange(FieldNo);

        FieldRef := FieldRecRef.Field(25); //ObsoleteState in NAV2018+
        FieldRef.SetFilter('<>%1', 2); //Option 2 = Removed

        exit(FieldRecRef.IsEmpty());
        //+NPR5.51 [367416]
    end;

    local procedure PurchaseLineToRetailJnlLine(var PurchaseLine: Record "Purchase Line"; var RetailJnlLine: Record "NPR Retail Journal Line")
    var
        Item: Record Item;
        ItemLedgerEntry: Record "Item Ledger Entry";
        PurchaseHeader: Record "Purchase Header";
        TempSalePOS: Record "NPR POS Sale" temporary;
        TempSaleLinePOS: Record "NPR POS Sale Line" temporary;
        POSSalesPriceCalcMgt: Codeunit "NPR POS Sales Price Calc. Mgt.";
        PurchaseUnit: Code[10];
        RegisterNo: Code[10];
        SalesUnit: Code[10];
        UnitPrice: Decimal;
        LineNo: Integer;
        GUID: Guid;
        POSUnit: Record "NPR POS Unit";
    begin
        RetailJnlLine.Reset();

        PurchaseLine.SetRange(Type, PurchaseLine.Type::Item);

        if not PurchaseLine.FindSet() then
            exit;

        PurchaseHeader.Get(PurchaseLine."Document Type", PurchaseLine."Document No.");

        RegisterNo := POSUnit.GetCurrentPOSUnit();
        GUID := CreateGuid();

        repeat
            Item.Get(PurchaseLine."No.");
            UnitPrice := Item."Unit Price";
            SalesUnit := Item."Sales Unit of Measure";
            PurchaseUnit := Item."Purch. Unit of Measure";

            if PurchaseLine."Variant Code" <> '' then begin
                TempSaleLinePOS.Type := TempSaleLinePOS.Type::Item;
                TempSaleLinePOS."No." := PurchaseLine."No.";
                TempSaleLinePOS."Variant Code" := PurchaseLine."Variant Code";
                TempSaleLinePOS."Unit of Measure Code" := Item."Base Unit of Measure";
                TempSaleLinePOS."Price Includes VAT" := Item."Price Includes VAT";

                POSSalesPriceCalcMgt.InitTempPOSItemSale(TempSaleLinePOS, TempSalePOS);
                POSSalesPriceCalcMgt.FindItemPrice(TempSalePOS, TempSaleLinePOS);
                if TempSaleLinePOS."Unit Price" <> 0 then
                    UnitPrice := TempSaleLinePOS."Unit Price";
            end;

            if Item."Costing Method" = Item."Costing Method"::Specific then begin
                ItemLedgerEntry.SetRange("Item No.", Item."No.");
                if ItemLedgerEntry.FindSet() then
                    repeat
                        LineNo += 10000;
                        RetailJnlLine.Init();
                        RetailJnlLine."Register No." := RegisterNo;
                        RetailJnlLine."No." := Format(GUID);
                        RetailJnlLine."Line No." := LineNo;
                        RetailJnlLine.Validate("Item No.", PurchaseLine."No.");
                        RetailJnlLine."Quantity to Print" := 1;
                        RetailJnlLine.Description := PurchaseLine.Description;
                        RetailJnlLine."Description 2" := PurchaseLine."Description 2";
                        RetailJnlLine."Vendor No." := PurchaseHeader."Buy-from Vendor No.";
                        RetailJnlLine."Vendor Item No." := PurchaseLine."Vendor Item No.";
                        RetailJnlLine."Discount Price Incl. Vat" := UnitPrice;
                        RetailJnlLine."Last Direct Cost" := PurchaseLine."Unit Cost";
                        RetailJnlLine."Sales Unit of measure" := SalesUnit;
                        RetailJnlLine."Purch. Unit of measure" := PurchaseUnit;
                        RetailJnlLine."Serial No." := ItemLedgerEntry."Serial No.";
                        RetailJnlLine."Item group" := Item."Item Category Code";
                        RetailJnlLine.Validate("Variant Code", PurchaseLine."Variant Code");
                        RetailJnlLine.Insert(true);
                    until ItemLedgerEntry.Next() = 0;
            end else begin
                LineNo += 10000;
                RetailJnlLine.Init();
                RetailJnlLine."Register No." := RegisterNo;
                RetailJnlLine."No." := Format(GUID);
                RetailJnlLine."Line No." := LineNo;
                RetailJnlLine.Validate("Item No.", PurchaseLine."No.");
                RetailJnlLine."Quantity to Print" := PurchaseLine.Quantity;
                RetailJnlLine.Description := PurchaseLine.Description;
                RetailJnlLine."Description 2" := PurchaseLine."Description 2";
                RetailJnlLine."Vendor No." := PurchaseHeader."Buy-from Vendor No.";
                RetailJnlLine."Vendor Item No." := PurchaseLine."Vendor Item No.";
                RetailJnlLine."Discount Price Incl. Vat" := UnitPrice;
                RetailJnlLine."Last Direct Cost" := PurchaseLine."Unit Cost";
                RetailJnlLine."Sales Unit of measure" := SalesUnit;
                RetailJnlLine."Purch. Unit of measure" := PurchaseUnit;
                RetailJnlLine."Item group" := Item."Item Category Code";
                RetailJnlLine.Validate("Variant Code", PurchaseLine."Variant Code");
                RetailJnlLine.Insert(true);
            end;
        until PurchaseLine.Next() = 0;

        RetailJnlLine.SetRange("No.", Format(GUID));
    end;

    local procedure TransferLineToRetailJnlLine(var TransferLine: Record "Transfer Line"; var RetailJnlLine: Record "NPR Retail Journal Line")
    var
        TransferHeader: Record "Transfer Header";
        GUID: Guid;
        Item: Record Item;
        RegisterNo: Code[10];
        ItemLedgerEntry: Record "Item Ledger Entry";
        POSUnit: Record "NPR POS Unit";
    begin
        RetailJnlLine.Reset();

        if not TransferLine.FindSet() then
            exit;

        TransferHeader.Get(TransferLine."Document No.");

        RegisterNo := POSUnit.GetCurrentPOSUnit();
        GUID := CreateGuid();

        repeat
            Item.Get(TransferLine."Item No.");
            if Item."Costing Method" = Item."Costing Method"::Specific then begin
                ItemLedgerEntry.SetRange("Item No.", Item."No.");
                if ItemLedgerEntry.FindSet() then
                    repeat
                        RetailJnlLine.Init();
                        RetailJnlLine."Register No." := RegisterNo;
                        RetailJnlLine."No." := Format(GUID);
                        RetailJnlLine."Line No." := TransferLine."Line No.";
                        RetailJnlLine.Validate("Item No.", TransferLine."Item No.");
                        RetailJnlLine."Quantity to Print" := 1;
                        RetailJnlLine.Description := TransferLine.Description;
                        RetailJnlLine."Description 2" := TransferLine."Description 2";
                        RetailJnlLine."Serial No." := ItemLedgerEntry."Serial No.";
                        RetailJnlLine.Validate("Variant Code", TransferLine."Variant Code");
                        RetailJnlLine.Insert(true);
                    until ItemLedgerEntry.Next() = 0;
            end else begin
                RetailJnlLine.Init();
                RetailJnlLine."Register No." := RegisterNo;
                RetailJnlLine."No." := Format(GUID);
                RetailJnlLine."Line No." := TransferLine."Line No.";
                RetailJnlLine.Validate("Item No.", TransferLine."Item No.");
                RetailJnlLine."Quantity to Print" := TransferLine.Quantity;
                RetailJnlLine.Description := TransferLine.Description;
                RetailJnlLine."Description 2" := TransferLine."Description 2";
                RetailJnlLine.Validate("Variant Code", TransferLine."Variant Code");
                RetailJnlLine.Insert(true);
            end;
        until TransferLine.Next() = 0;

        RetailJnlLine.SetRange("No.", Format(GUID));
    end;

    procedure ItemToRetailJnlLine(ItemNo: Code[20]; VariantCode: Code[10]; Quantity: Integer; PK: Code[40]; var RetailJournalLineOut: Record "NPR Retail Journal Line")
    var
        RetailJournalLine: Record "NPR Retail Journal Line";
        Item: Record Item;
        ItemLedgerEntry: Record "Item Ledger Entry";
        POSUnit: Record "NPR POS Unit";
    begin
        //-NPR5.37 [289725]
        Item.Get(ItemNo);

        RetailJournalLine.SetRange("No.", PK);
        if RetailJournalLine.FindLast() then;

        RetailJournalLineOut.Init();
        RetailJournalLineOut."No." := PK;
        RetailJournalLineOut."Line No." := RetailJournalLine."Line No." + 10000;
        RetailJournalLineOut."Register No." := POSUnit.GetCurrentPOSUnit();
        RetailJournalLineOut.Validate("Item No.", ItemNo);
        RetailJournalLineOut.Validate("Variant Code", VariantCode);
        RetailJournalLineOut."Quantity to Print" := Quantity;
        RetailJournalLineOut."Description 2" := Item."Description 2";

        if Item."Costing Method" = Item."Costing Method"::Specific then begin
            ItemLedgerEntry.SetRange("Item No.", ItemNo);
            ItemLedgerEntry.SetRange("Variant Code", VariantCode);
            Commit();
            if PAGE.RunModal(PAGE::"NPR Serial Numbers Lookup", ItemLedgerEntry) = ACTION::LookupOK then
                RetailJournalLineOut."Serial No." := ItemLedgerEntry."Serial No.";
        end;

        RetailJournalLineOut.Insert(true);
        //+NPR5.37 [289725]
    end;

    procedure PrintRetailJournal(var JournalLine: Record "NPR Retail Journal Line"; ReportType: Integer)
    var
        RecRef: RecordRef;
        RetailReportSelectionMgt: Codeunit "NPR Retail Report Select. Mgt.";
        Skip: Boolean;
        POSUnit: Record "NPR POS Unit";
    begin
        Commit(); //Will send data to external device.

        OnBeforePrintRetailJournal(JournalLine, ReportType, Skip);
        if Skip then
            exit;

        RetailReportSelectionMgt.SetMatrixPrintIterationFieldNo(JournalLine.FieldNo("Quantity to Print"));
        RetailReportSelectionMgt.SetRequestWindow(true);
        RetailReportSelectionMgt.SetRegisterNo(POSUnit.GetCurrentPOSUnit());
        RecRef.GetTable(JournalLine);
        RetailReportSelectionMgt.RunObjects(RecRef, ReportType);

        OnAfterPrintRetailJournal(JournalLine, ReportType);
    end;

    local procedure PrintPurchaseOrder(var PurchLine: Record "Purchase Line"; ReportType: Integer)
    var
        TempRetailJnlNo: Code[40];
        RetailJournalCode: Codeunit "NPR Retail Journal Code";
    begin
        //-NPR5.46 [294354]
        // PurchaseLineToRetailJnlLine(PurchLine, RetailJnlLine);
        // IF RetailJnlLine.FindSet() THEN BEGIN
        //  PrintRetailJournal(RetailJnlLine,ReportType);
        //  RetailJnlLine.DeleteAll();
        // END;
        Evaluate(TempRetailJnlNo, CreateGuid());
        RetailJournalCode.SetRetailJnlTemp(TempRetailJnlNo);
        RetailJournalCode.CopyPurchaseOrder2RetailJnlLines(PurchLine, TempRetailJnlNo);
        FlushJournalToPrinter(TempRetailJnlNo, ReportType);
        //+NPR5.46 [294354]
    end;

    local procedure PrintTransferOrder(var TransferLine: Record "Transfer Line"; ReportType: Integer)
    var
        TempRetailJnlNo: Code[40];
        RetailJournalCode: Codeunit "NPR Retail Journal Code";
    begin
        //-NPR5.46 [294354]
        Evaluate(TempRetailJnlNo, CreateGuid());
        RetailJournalCode.SetRetailJnlTemp(TempRetailJnlNo);
        RetailJournalCode.CopyTransferOrder2RetailJnlLines(TransferLine, TempRetailJnlNo);
        FlushJournalToPrinter(TempRetailJnlNo, ReportType);
        //+NPR5.46 [294354]
    end;

    local procedure QuantityPrompt(var QuantityOut: Integer): Boolean
    var
        InputDialog: Page "NPR Input Dialog";
        ID: Integer;
    begin
        //-NPR5.37 [289725]
        InputDialog.LookupMode := true;
        InputDialog.SetInput(1, QuantityOut, Text00001);
        repeat
            if InputDialog.RunModal() = ACTION::LookupOK then
                ID := InputDialog.InputInteger(1, QuantityOut);
        until (QuantityOut > 0) or (ID = 0);

        exit(ID <> 0);
        //+NPR5.37 [289725]
    end;

    local procedure PrintItemJournal(var ItemJournalLine: Record "Item Journal Line"; ReportType: Integer)
    var
        RetailJnlLine: Record "NPR Retail Journal Line";
    begin
        //-NPR5.43 [317852]
        ItemJournalLineToRetailJnlLine(ItemJournalLine, RetailJnlLine);
        if ItemJournalLine.FindSet() then begin
            PrintRetailJournal(RetailJnlLine, ReportType);
            RetailJnlLine.DeleteAll();
        end;
        //+NPR5.43 [317852]
    end;

    local procedure ItemJournalLineToRetailJnlLine(var ItemJournalLine: Record "Item Journal Line"; var RetailJnlLine: Record "NPR Retail Journal Line")
    var
        GUID: Guid;
        Item: Record Item;
        RegisterNo: Code[10];
        ItemLedgerEntry: Record "Item Ledger Entry";
        POSUnit: Record "NPR POS Unit";
    begin
        RetailJnlLine.Reset();
        if not ItemJournalLine.FindSet() then
            exit;
        RegisterNo := POSUnit.GetCurrentPOSUnit();
        GUID := CreateGuid();
        repeat
            Item.Get(ItemJournalLine."Item No.");
            if Item."Costing Method" = Item."Costing Method"::Specific then begin
                ItemLedgerEntry.SetRange("Item No.", Item."No.");
                if ItemLedgerEntry.FindSet() then
                    repeat
                        RetailJnlLine.Init();
                        RetailJnlLine."Register No." := RegisterNo;
                        RetailJnlLine."No." := Format(GUID);
                        RetailJnlLine."Line No." := ItemJournalLine."Line No.";
                        RetailJnlLine.Validate("Item No.", ItemJournalLine."Item No.");
                        RetailJnlLine."Quantity to Print" := 1;
                        RetailJnlLine.Description := ItemJournalLine.Description;
                        RetailJnlLine."Serial No." := ItemLedgerEntry."Serial No.";
                        RetailJnlLine.Validate("Variant Code", ItemJournalLine."Variant Code");
                        RetailJnlLine.Insert(true);
                    until ItemLedgerEntry.Next() = 0;
            end else begin
                RetailJnlLine.Init();
                RetailJnlLine."Register No." := RegisterNo;
                RetailJnlLine."No." := Format(GUID);
                RetailJnlLine."Line No." := ItemJournalLine."Line No.";
                RetailJnlLine.Validate("Item No.", ItemJournalLine."Item No.");
                RetailJnlLine."Quantity to Print" := ItemJournalLine.Quantity;
                RetailJnlLine.Description := ItemJournalLine.Description;
                RetailJnlLine.Validate("Variant Code", ItemJournalLine."Variant Code");
                RetailJnlLine.Insert(true);
            end;
        until ItemJournalLine.Next() = 0;
        RetailJnlLine.SetRange("No.", Format(GUID));
    end;

    local procedure PrintTransferShipment(var TransferShipmentLine: Record "Transfer Shipment Line"; ReportType: Integer)
    var
        TempRetailJnlNo: Code[40];
        RetailJournalCode: Codeunit "NPR Retail Journal Code";
    begin
        Evaluate(TempRetailJnlNo, CreateGuid());
        RetailJournalCode.SetRetailJnlTemp(TempRetailJnlNo);
        RetailJournalCode.CopyTransferShipment2RetailJnlLines(TransferShipmentLine, TempRetailJnlNo);
        FlushJournalToPrinter(TempRetailJnlNo, ReportType);
    end;

    local procedure PrintTransferReceipt(var TransferReceiptLine: Record "Transfer Receipt Line"; ReportType: Integer)
    var
        TempRetailJnlNo: Code[40];
        RetailJournalCode: Codeunit "NPR Retail Journal Code";
    begin
        Evaluate(TempRetailJnlNo, CreateGuid());
        RetailJournalCode.SetRetailJnlTemp(TempRetailJnlNo);
        RetailJournalCode.CopyTransferReceipt2RetailJnlLines(TransferReceiptLine, TempRetailJnlNo);
        FlushJournalToPrinter(TempRetailJnlNo, ReportType);
    end;

    local procedure PrintPeriodDiscount(var PeriodDiscountLine: Record "NPR Period Discount Line"; ReportType: Integer)
    var
        TempRetailJnlNo: Code[40];
        RetailJournalCode: Codeunit "NPR Retail Journal Code";
    begin
        Evaluate(TempRetailJnlNo, CreateGuid());
        RetailJournalCode.SetRetailJnlTemp(TempRetailJnlNo);
        RetailJournalCode.CopyCampaign2RetailJnlLines(PeriodDiscountLine, TempRetailJnlNo);
        FlushJournalToPrinter(TempRetailJnlNo, ReportType);
    end;

    local procedure FlushJournalToPrinter(RetailJournalCode: Code[40]; ReportType: Integer)
    var
        RetailJnlLine: Record "NPR Retail Journal Line";
    begin
        if RetailJournalCode = '' then
            exit;
        RetailJnlLine.SetRange("No.", RetailJournalCode);
        if RetailJnlLine.IsEmpty then
            exit;

        PrintRetailJournal(RetailJnlLine, ReportType);
        RetailJnlLine.DeleteAll();
    end;

    local procedure PrintPostedPurchaseInvoice(var PurchInvLine: Record "Purch. Inv. Line"; ReportType: Integer)
    var
        TempRetailJnlNo: Code[40];
        RetailJournalCode: Codeunit "NPR Retail Journal Code";
    begin

        Evaluate(TempRetailJnlNo, CreateGuid());
        RetailJournalCode.SetRetailJnlTemp(TempRetailJnlNo);
        RetailJournalCode.CopyPostedPurchaseInv2RetailJnlLines(PurchInvLine, TempRetailJnlNo);
        FlushJournalToPrinter(TempRetailJnlNo, ReportType);
    end;

    local procedure PrintItemWorksheetLine(var ItemWorksheetLine: Record "NPR Item Worksheet Line"; ReportType: Integer)
    var
        RetailJnlLine: Record "NPR Retail Journal Line";
    begin
        ItemWorksheetLineToRetailJnlLine(ItemWorksheetLine, RetailJnlLine);
        if ItemWorksheetLine.FindSet() then begin
            PrintRetailJournal(RetailJnlLine, ReportType);
            RetailJnlLine.DeleteAll();
        end;
    end;

    local procedure ItemWorksheetLineToRetailJnlLine(var ItemWorksheetLine: Record "NPR Item Worksheet Line"; var RetailJnlLine: Record "NPR Retail Journal Line")
    var
        GUID: Guid;
        Item: Record Item;
        RegisterNo: Code[10];
        ItemLedgerEntry: Record "Item Ledger Entry";
        POSUnit: Record "NPR POS Unit";
    begin
        RetailJnlLine.Reset();
        if not ItemWorksheetLine.FindSet() then
            exit;
        RegisterNo := POSUnit.GetCurrentPOSUnit();
        GUID := CreateGuid();
        repeat
            if not Item.Get(ItemWorksheetLine."Item No.") then
                Item.Get(ItemWorksheetLine."Existing Item No.");
            if Item."Costing Method" = Item."Costing Method"::Specific then begin
                ItemLedgerEntry.SetRange("Item No.", Item."No.");
                if ItemLedgerEntry.FindSet() then
                    repeat
                        RetailJnlLine.Init();
                        RetailJnlLine."Register No." := RegisterNo;
                        RetailJnlLine."No." := Format(GUID);
                        RetailJnlLine."Line No." := ItemWorksheetLine."Line No.";
                        RetailJnlLine.Validate("Item No.", ItemWorksheetLine."Item No.");
                        RetailJnlLine."Quantity to Print" := 1;
                        RetailJnlLine.Description := ItemWorksheetLine.Description;
                        RetailJnlLine."Serial No." := ItemLedgerEntry."Serial No.";
                        RetailJnlLine.Validate("Variant Code", ItemWorksheetLine."Variant Code");
                        RetailJnlLine.Insert(true);
                    until ItemLedgerEntry.Next() = 0;
            end else begin
                RetailJnlLine.Init();
                RetailJnlLine."Register No." := RegisterNo;
                RetailJnlLine."No." := Format(GUID);
                RetailJnlLine."Line No." := ItemWorksheetLine."Line No.";
                RetailJnlLine.Validate("Item No.", ItemWorksheetLine."Item No.");
                RetailJnlLine."Quantity to Print" := 1;
                RetailJnlLine.Description := ItemWorksheetLine.Description;
                RetailJnlLine.Validate("Variant Code", ItemWorksheetLine."Variant Code");
                RetailJnlLine.Insert(true);
            end;
        until ItemWorksheetLine.Next() = 0;
        RetailJnlLine.SetRange("No.", Format(GUID));
    end;

    local procedure PrintWarehouseActivityLine(var WarehouseActivityLine: Record "Warehouse Activity Line"; ReportType: Integer)
    var
        TempRetailJnlNo: Code[40];
        RetailJournalCode: Codeunit "NPR Retail Journal Code";
    begin
        Evaluate(TempRetailJnlNo, CreateGuid());
        RetailJournalCode.SetRetailJnlTemp(TempRetailJnlNo);
        RetailJournalCode.CopyInventoryPutAway2RetailJnlLines(WarehouseActivityLine, TempRetailJnlNo);
        FlushJournalToPrinter(TempRetailJnlNo, ReportType);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforePrintRetailJournal(var JournalLine: Record "NPR Retail Journal Line"; ReportType: Integer; var Skip: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterPrintRetailJournal(var JournalLine: Record "NPR Retail Journal Line"; ReportType: Integer)
    begin
    end;
}

