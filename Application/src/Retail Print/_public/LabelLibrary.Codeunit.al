codeunit 6014413 "NPR Label Library"
{
    var
        _TmpSelectionBuffer: RecordRef;
        _SelectionBufferOpen: Boolean;
        _TmpRetailJnlCode: Code[40];

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

    internal procedure PrintItem(var Item: Record Item; PromptForQuantity: Boolean; Quantity: Integer; IsLastLine: Boolean; ReportType: Integer): Decimal
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

    internal procedure PrintCustomShippingLabel(var RecRef: RecordRef; PrintLayoutID: Code[20])
    var
        ShippingAgent: Record "Shipping Agent";
        SalesHeader: Record "Sales Header";
        PrintSetupHeader: Record "NPR RP Template Header";
        DataItem: Record "NPR RP Data Items";
        TempCustomer: Record Customer temporary;
        tmpCustRef: RecordRef;
        MatrixPrintMgt: Codeunit "NPR RP Matrix Print Mgt.";
        Customer: Record Customer;
        Err_NoShippingLabelFound: Label 'No label setup for the selected shipping agent';
        Err_InvalidShippingLabel: Label 'The selected shipping label cannot be printed from table: %1 ';
    begin
        case RecRef.Number of
            DATABASE::"Sales Header":
                begin
                    RecRef.SetTable(SalesHeader);
                    ShippingAgent.Get(SalesHeader."Shipping Agent Code");
                    TempCustomer.Init();
                    TempCustomer.Name := SalesHeader."Ship-to Name";
                    TempCustomer."Name 2" := SalesHeader."Ship-to Name 2";
                    TempCustomer.Address := SalesHeader."Ship-to Address";
                    TempCustomer."Address 2" := SalesHeader."Ship-to Address 2";
                    TempCustomer.City := SalesHeader."Ship-to City";
                    TempCustomer."Post Code" := SalesHeader."Ship-to Post Code";
                    TempCustomer."Country/Region Code" := SalesHeader."Ship-to Country/Region Code";
                    TempCustomer.County := SalesHeader."Ship-to County";
                    TempCustomer.Insert();
                    tmpCustRef.GetTable(TempCustomer);
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

    internal procedure ToggleLine(var RecRefIn: RecordRef)
    begin
        if not _SelectionBufferOpen then begin
            _TmpSelectionBuffer.Open(RecRefIn.Number, true);
            _SelectionBufferOpen := true;
        end;

        if _TmpSelectionBuffer.Get(RecRefIn.RecordId) then
            _TmpSelectionBuffer.Delete()
        else
            TransferSelectionFields(RecRefIn);
    end;

    internal procedure InvertAllLines(var RecRefIn: RecordRef)
    var
        RecRef: RecordRef;
    begin
        if not _SelectionBufferOpen then begin
            _TmpSelectionBuffer.Open(RecRefIn.Number, true);
            _SelectionBufferOpen := true;
        end;

        if RecRefIn.FindSet() then
            repeat
                RecRef := RecRefIn.Duplicate();
                RecRef.SetRecFilter();
                ToggleLine(RecRef);
                RecRef.Close();
            until RecRefIn.Next() = 0;
    end;

    internal procedure SelectionContains(var RecRefIn: RecordRef): Boolean
    begin
        if not _SelectionBufferOpen then begin
            _TmpSelectionBuffer.Open(RecRefIn.Number, true);
            _SelectionBufferOpen := true;
        end;

        exit(_TmpSelectionBuffer.Get(RecRefIn.RecordId));
    end;

    local procedure TransferSelectionFields(var RecRefIn: RecordRef)
    var
        "Field": Record "Field";
        FieldRefFrom: FieldRef;
        FieldRefTo: FieldRef;
    begin
        if RecRefIn.Number <> _TmpSelectionBuffer.Number then
            exit;

        _TmpSelectionBuffer.Init();

        Field.SetRange(TableNo, RecRefIn.Number);
        Field.SetRange(Enabled, true);
        if Field.FindSet() then
            repeat
                if not FieldIsObsolete(Field.TableNo, Field."No.") then begin
                    FieldRefFrom := RecRefIn.Field(Field."No.");
                    FieldRefTo := _TmpSelectionBuffer.Field(Field."No.");
                    FieldRefTo.Value(FieldRefFrom);
                end;
            until Field.Next() = 0;

        _TmpSelectionBuffer.Insert();
    end;

    internal procedure PrintSelection(ReportType: Integer)
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
        if not _SelectionBufferOpen then
            exit;

        if _TmpSelectionBuffer.FindSet() then begin
            case _TmpSelectionBuffer.Number of
                DATABASE::"NPR Retail Journal Line":
                    begin
                        repeat
                            if RetailJournalLine.Get(_TmpSelectionBuffer.RecordId) then begin
                                RetailJournalLine.Mark(true);
                            end;
                        until _TmpSelectionBuffer.Next() = 0;
                        RetailJournalLine.MarkedOnly(true);
                        if RetailJournalLine.FindSet() then
                            PrintRetailJournal(RetailJournalLine, ReportType);
                    end;
                DATABASE::"Purchase Line":
                    begin
                        repeat
                            if PurchaseLine.Get(_TmpSelectionBuffer.RecordId) then begin
                                PurchaseLine.Mark(true);
                            end;
                        until _TmpSelectionBuffer.Next() = 0;
                        PurchaseLine.MarkedOnly(true);
                        if PurchaseLine.FindSet() then
                            PrintPurchaseOrder(PurchaseLine, ReportType);
                    end;
                DATABASE::"Transfer Line":
                    begin
                        repeat
                            if TransferLine.Get(_TmpSelectionBuffer.RecordId) then
                                TransferLine.Mark(true);
                        until _TmpSelectionBuffer.Next() = 0;
                        TransferLine.MarkedOnly(true);
                        if TransferLine.FindSet() then
                            PrintTransferOrder(TransferLine, ReportType);
                    end;
                DATABASE::Bin:
                    begin
                        repeat
                            if Bin.Get(_TmpSelectionBuffer.RecordId) then
                                Bin.Mark(true);
                        until _TmpSelectionBuffer.Next() = 0;
                        Bin.MarkedOnly(true);
                        if Bin.FindSet() then
                            PrintBin(Bin, ReportType);
                    end;
                DATABASE::"Item Journal Line":
                    begin
                        repeat
                            if ItemJournalLine.Get(_TmpSelectionBuffer.RecordId) then
                                ItemJournalLine.Mark(true);
                        until _TmpSelectionBuffer.Next() = 0;
                        ItemJournalLine.MarkedOnly(true);
                        if ItemJournalLine.FindSet() then
                            PrintItemJournal(ItemJournalLine, ReportType);
                    end;
                DATABASE::"Transfer Shipment Line":
                    begin
                        repeat
                            if TransferShipmentLine.Get(_TmpSelectionBuffer.RecordId) then
                                TransferShipmentLine.Mark(true);
                        until _TmpSelectionBuffer.Next() = 0;
                        TransferShipmentLine.MarkedOnly(true);
                        if TransferShipmentLine.IsEmpty then
                            exit;
                        PrintTransferShipment(TransferShipmentLine, ReportType);
                    end;
                DATABASE::"Transfer Receipt Line":
                    begin
                        repeat
                            if TransferReceiptLine.Get(_TmpSelectionBuffer.RecordId) then
                                TransferReceiptLine.Mark(true);
                        until _TmpSelectionBuffer.Next() = 0;
                        TransferReceiptLine.MarkedOnly(true);
                        if TransferReceiptLine.IsEmpty then
                            exit;
                        PrintTransferReceipt(TransferReceiptLine, ReportType);
                    end;
                DATABASE::"NPR Period Discount Line":
                    begin
                        repeat
                            if PeriodDiscountLine.Get(_TmpSelectionBuffer.RecordId) then
                                PeriodDiscountLine.Mark(true);
                        until _TmpSelectionBuffer.Next() = 0;
                        PeriodDiscountLine.MarkedOnly(true);
                        if PeriodDiscountLine.IsEmpty then
                            exit;
                        PrintPeriodDiscount(PeriodDiscountLine, ReportType);
                    end;
                DATABASE::"Purch. Inv. Line":
                    begin
                        repeat
                            if PurchInvLine.Get(_TmpSelectionBuffer.RecordId) then begin
                                PurchInvLine.Mark(true);
                            end;
                        until _TmpSelectionBuffer.Next() = 0;
                        PurchInvLine.MarkedOnly(true);
                        if PurchInvLine.FindSet() then
                            PrintPostedPurchaseInvoice(PurchInvLine, ReportType);
                    end;
                DATABASE::"NPR Item Worksheet Line":
                    begin
                        repeat
                            if ItemWorksheetLine.Get(_TmpSelectionBuffer.RecordId) then
                                ItemWorksheetLine.Mark(true);
                        until _TmpSelectionBuffer.Next() = 0;
                        ItemWorksheetLine.MarkedOnly(true);
                        if ItemWorksheetLine.FindSet() then
                            PrintItemWorksheetLine(ItemWorksheetLine, ReportType);
                    end;
                DATABASE::"Warehouse Activity Line":
                    begin
                        repeat
                            if WarehouseActivityLine.Get(_TmpSelectionBuffer.RecordId) then
                                WarehouseActivityLine.Mark(true);
                        until _TmpSelectionBuffer.Next() = 0;
                        WarehouseActivityLine.MarkedOnly(true);
                        if WarehouseActivityLine.FindSet() then
                            PrintWarehouseActivityLine(WarehouseActivityLine, ReportType);
                    end;
            end;
        end;
    end;

    internal procedure RunPrintPage(var RecRef: RecordRef)
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
        _TmpRetailJnlCode := Format(CreateGuid());
        RetailJournalMgt.SetRetailJnlTemp(_TmpRetailJnlCode);

        case RecRef.Number of
            DATABASE::"Purchase Line":
                begin
                    RecRef.SetTable(PurchaseLine);
                    if PurchaseLine.FindFirst() then;

                    RetailJournalMgt.PurchaseOrder2RetailJnl(PurchaseLine."Document Type", PurchaseLine."Document No.", _TmpRetailJnlCode);
                end;
            DATABASE::"Transfer Line":
                begin
                    RecRef.SetTable(TransferLine);
                    if TransferLine.FindFirst() then;

                    RetailJournalMgt.TransferOrder2RetailJnl(TransferLine."Document No.", _TmpRetailJnlCode);
                end;
            DATABASE::"Transfer Shipment Line":
                begin
                    RecRef.SetTable(TransferShipmentLine);
                    if TransferShipmentLine.FindFirst() then;
                    RetailJournalMgt.TransferShipment2RetailJnl(TransferShipmentLine."Document No.", _TmpRetailJnlCode);
                end;
            DATABASE::"Transfer Receipt Line":
                begin
                    RecRef.SetTable(TransferReceiptLine);
                    if TransferReceiptLine.FindFirst() then;
                    RetailJournalMgt.TransferReceipt2RetailJnl(TransferReceiptLine."Document No.", _TmpRetailJnlCode);
                end;
            DATABASE::"NPR Period Discount Line":
                begin
                    RecRef.SetTable(PeriodDiscountLine);
                    if PeriodDiscountLine.FindFirst() then;
                    RetailJournalMgt.Campaign2RetailJnl(PeriodDiscountLine.Code, _TmpRetailJnlCode);
                end;
            DATABASE::"Purch. Inv. Line":
                begin
                    RecRef.SetTable(PurchInvLine);
                    if PurchInvLine.FindFirst() then;
                    RetailJournalMgt.PostedPurchaseInvoice2RetailJnl(PurchInvLine."Document No.", _TmpRetailJnlCode);
                end;
            DATABASE::"Warehouse Activity Line":
                begin
                    RecRef.SetTable(WarehouseActivityLine);
                    if WarehouseActivityLine.FindFirst() then;
#if (BC17 or BC18)
                    RetailJournalMgt.InventoryPutAway2RetailJnl(WarehouseActivityLine."Activity Type", WarehouseActivityLine."No.", _TmpRetailJnlCode);
#else
                    RetailJournalMgt.InventoryPutAway2RetailJnl(WarehouseActivityLine."Activity Type".AsInteger(), WarehouseActivityLine."No.", _TmpRetailJnlCode);
#endif
                end;
            else
                Error('table %1 is not supported for selected Printing', RecRef.Number);
        end;

        Commit();

        if RetailJnlLine.IsEmpty then
            exit;

        PAGE.RunModal(PAGE::"NPR Retail Journal Print", RetailJnlLine);

        RetailJnlLine.DeleteAll();
    end;

    local procedure FieldIsObsolete(TableNo: Integer; FieldNo: Integer): Boolean
    var
        FieldRecRef: RecordRef;
        FieldRef: FieldRef;
    begin
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
    end;

    internal procedure ItemToRetailJnlLine(ItemNo: Code[20]; VariantCode: Code[10]; Quantity: Integer; PK: Code[40]; var RetailJournalLineOut: Record "NPR Retail Journal Line")
    var
        RetailJournalLine: Record "NPR Retail Journal Line";
        Item: Record Item;
        ItemLedgerEntry: Record "Item Ledger Entry";
        POSUnit: Record "NPR POS Unit";
    begin
        Item.Get(ItemNo);

        RetailJournalLine.SetRange("No.", PK);
        if RetailJournalLine.FindLast() then;

        RetailJournalLineOut.Init();
        RetailJournalLineOut."No." := PK;
        RetailJournalLineOut."Line No." := RetailJournalLine."Line No." + 10000;
        RetailJournalLineOut."Register No." := POSUnit.GetCurrentPOSUnit();
        RetailJournalLineOut.Validate("Item No.", ItemNo);
        RetailJournalLineOut.Validate("Variant Code", VariantCode);
        RetailJournalLineOut.Validate("Quantity to Print", Quantity);
        RetailJournalLineOut."Description 2" := Item."Description 2";

        if Item."Costing Method" = Item."Costing Method"::Specific then begin
            ItemLedgerEntry.SetRange("Item No.", ItemNo);
            ItemLedgerEntry.SetRange("Variant Code", VariantCode);
            Commit();
            if PAGE.RunModal(PAGE::"NPR Serial Numbers Lookup", ItemLedgerEntry) = ACTION::LookupOK then
                RetailJournalLineOut."Serial No." := ItemLedgerEntry."Serial No.";
        end;

        RetailJournalLineOut.Insert(true);
    end;

    internal procedure PrintRetailJournal(var JournalLine: Record "NPR Retail Journal Line"; ReportType: Integer)
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
        Evaluate(TempRetailJnlNo, CreateGuid());
        RetailJournalCode.SetRetailJnlTemp(TempRetailJnlNo);
        RetailJournalCode.CopyPurchaseOrder2RetailJnlLines(PurchLine, TempRetailJnlNo);
        FlushJournalToPrinter(TempRetailJnlNo, ReportType);
    end;

    local procedure PrintTransferOrder(var TransferLine: Record "Transfer Line"; ReportType: Integer)
    var
        TempRetailJnlNo: Code[40];
        RetailJournalCode: Codeunit "NPR Retail Journal Code";
    begin
        Evaluate(TempRetailJnlNo, CreateGuid());
        RetailJournalCode.SetRetailJnlTemp(TempRetailJnlNo);
        RetailJournalCode.CopyTransferOrder2RetailJnlLines(TransferLine, TempRetailJnlNo);
        FlushJournalToPrinter(TempRetailJnlNo, ReportType);
    end;

    local procedure QuantityPrompt(var QuantityOut: Integer): Boolean
    var
        InputDialog: Page "NPR Input Dialog";
        ID: Integer;
        QuantityLbl: Label 'Please enter quantity.';
    begin
        InputDialog.LookupMode := true;
        InputDialog.SetInput(1, QuantityOut, QuantityLbl);
        repeat
            if InputDialog.RunModal() = ACTION::LookupOK then
                ID := InputDialog.InputInteger(1, QuantityOut);
        until (QuantityOut > 0) or (ID = 0);

        exit(ID <> 0);
    end;

    local procedure PrintItemJournal(var ItemJournalLine: Record "Item Journal Line"; ReportType: Integer)
    var
        RetailJnlLine: Record "NPR Retail Journal Line";
    begin
        ItemJournalLineToRetailJnlLine(ItemJournalLine, RetailJnlLine);
        if ItemJournalLine.FindSet() then begin
            PrintRetailJournal(RetailJnlLine, ReportType);
            RetailJnlLine.DeleteAll();
        end;
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
                RetailJnlLine.Validate("Quantity to Print", ItemJournalLine.Quantity);
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

    internal procedure ChooseLabel(VarRec: Variant)
    var
        LabelLibrary: Codeunit "NPR Label Library";
        RecRef: RecordRef;
    begin
        ApplyFilter(VarRec, RecRef);
        LabelLibrary.RunPrintPage(RecRef);
    end;

    procedure PrintLabel(VarRec: Variant; ReportType: Option)
    var
        RecRef: RecordRef;
    begin
        ApplyFilter(VarRec, RecRef);
        InvertAllLines(RecRef);
        PrintSelection(ReportType);
    end;

    local procedure ApplyFilter(VarRec: Variant; var FilteredLineRecRef: RecordRef)
    var
        RecRef2: RecordRef;
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        TransferHeader: Record "Transfer Header";
        TransferLine: Record "Transfer Line";
        TransferShipmentHeader: Record "Transfer Shipment Header";
        TransferShipmentLine: Record "Transfer Shipment Line";
        PeriodDiscount: Record "NPR Period Discount";
        PeriodDiscountLine: Record "NPR Period Discount Line";
        TransferReceiptHeader: Record "Transfer Receipt Header";
        TransferReceiptLine: Record "Transfer Receipt Line";
        PurchInvHeader: Record "Purch. Inv. Header";
        PurchInvLine: Record "Purch. Inv. Line";
        WarehouseActivityHeader: Record "Warehouse Activity Header";
        WarehouseActivityLine: Record "Warehouse Activity Line";
        IsHandled: Boolean;
    begin
        RecRef2.GetTable(VarRec);
        case RecRef2.Number of
            DATABASE::"Purchase Header":
                begin
                    RecRef2.SetTable(PurchaseHeader);
                    PurchaseLine.SetRange("Document Type", PurchaseHeader."Document Type");
                    PurchaseLine.SetRange("Document No.", PurchaseHeader."No.");
                    FilteredLineRecRef.GetTable(PurchaseLine);

                end;
            DATABASE::"Transfer Header":
                begin
                    RecRef2.SetTable(TransferHeader);
                    TransferLine.SetRange("Document No.", TransferHeader."No.");
                    TransferLine.SetRange("Derived From Line No.", 0);
                    FilteredLineRecRef.GetTable(TransferLine);
                end;
            DATABASE::"Transfer Shipment Header":
                begin
                    RecRef2.SetTable(TransferShipmentHeader);
                    TransferShipmentLine.SetRange("Document No.", TransferShipmentHeader."No.");
                    FilteredLineRecRef.GetTable(TransferShipmentLine);
                end;
            DATABASE::"Transfer Receipt Header":
                begin
                    RecRef2.SetTable(TransferReceiptHeader);
                    TransferReceiptLine.SetRange("Document No.", TransferReceiptHeader."No.");
                    FilteredLineRecRef.GetTable(TransferReceiptLine);
                end;
            DATABASE::"NPR Period Discount":
                begin
                    RecRef2.SetTable(PeriodDiscount);
                    PeriodDiscountLine.SetRange(Code, PeriodDiscount.Code);
                    FilteredLineRecRef.GetTable(PeriodDiscountLine);
                end;

            DATABASE::"Purch. Inv. Header":
                begin
                    RecRef2.SetTable(PurchInvHeader);
                    PurchInvLine.SetRange("Document No.", PurchInvHeader."No.");
                    FilteredLineRecRef.GetTable(PurchInvLine);
                end;
            DATABASE::"Warehouse Activity Header":
                begin
                    RecRef2.SetTable(WarehouseActivityHeader);
                    WarehouseActivityLine.SetRange("Activity Type", WarehouseActivityHeader.Type);
                    WarehouseActivityLine.SetRange("No.", WarehouseActivityHeader."No.");
                    FilteredLineRecRef.GetTable(WarehouseActivityLine);
                end;
            else begin
                OnApplyFilter(FilteredLineRecRef, VarRec, IsHandled);
                if not IsHandled then begin
                    FilteredLineRecRef := RecRef2;
                    FilteredLineRecRef.SetRecFilter();
                end;
            end;
        end;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnApplyFilter(var FilteredLineRecRef: RecordRef; Rec: Variant; var IsHandled: Boolean)
    begin
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


