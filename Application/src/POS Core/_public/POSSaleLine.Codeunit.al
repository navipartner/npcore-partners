codeunit 6150706 "NPR POS Sale Line"
{
    trigger OnRun()
    begin
    end;

    var
        Rec: Record "NPR POS Sale Line";
        xRec: Record "NPR POS Sale Line";
        Sale: Record "NPR POS Sale";
        POSSale: Codeunit "NPR POS Sale";
        Setup: Codeunit "NPR POS Setup";
        _FrontEnd: Codeunit "NPR POS Front End Management";
        ITEM_REQUIRES_VARIANT: Label 'Variant is required for item %1.';
        TEXTDEPOSIT: Label 'Deposit';
        AUTOSPLIT_ERROR: Label 'Autosplit key can''t insert the new line %1 as it already exists. Highlight a different line before selling next item.';
        Text000: Label 'Before Sale Line POS is inserted';
        Text001: Label 'After Sale Line POS is inserted';
        Initialized: Boolean;
        CannotCalcPriceInclVATErr: Label 'Prices including VAT cannot be calculated when %1 is %2.';
        _ItemCountWhenCalculatedBalance: Decimal;
        UseLinePriceVATParams: Boolean;
        InsertWithAutoSplitKeyForced: Boolean;
        IsAutoSplitKeyRecord: Boolean;
        UsePresetLineNo: Boolean;

    procedure Init(RegisterNo: Code[20]; SalesTicketNo: Code[20]; SaleIn: Codeunit "NPR POS Sale"; SetupIn: Codeunit "NPR POS Setup"; FrontEndIn: Codeunit "NPR POS Front End Management")
    var
        POSViewProfile: Record "NPR POS View Profile";
    begin
        Clear(Rec);
        Clear(Sale);

        Rec.FilterGroup(2);
        Rec.SetRange("Register No.", RegisterNo);
        Rec.SetRange("Sales Ticket No.", SalesTicketNo);
        Rec.SetFilter("Line Type", '<>%1', Rec."Line Type"::"POS Payment");
        Rec.FilterGroup(0);

        Sale.Get(RegisterNo, SalesTicketNo);

        POSSale := SaleIn;
        Setup := SetupIn;
        _FrontEnd := FrontEndIn;

        Setup.GetPOSViewProfile(POSViewProfile);

        Initialized := true;
    end;

    local procedure CheckInit(WithError: Boolean): Boolean
    begin
        if WithError and (not Initialized) then
            Error('Codeunit POS Sale Line was invoked in uninitialized state. This is a programming bug, not a user error');
        exit(Initialized);
    end;

    local procedure InitLine()
    var
        POSStore: Record "NPR POS Store";
    begin
        if not (UsePresetLineNo and (Rec."Line No." <> 0)) then
            Rec."Line No." := GetNextLineNo();

        Rec.Init();
        Rec."Register No." := Sale."Register No.";
        Rec."Sales Ticket No." := Sale."Sales Ticket No.";
        Rec.Date := Sale.Date;
        Rec."Line Type" := Rec."Line Type"::Item;
        Rec."Responsibility Center" := Sale."Responsibility Center";

        Setup.GetPOSStore(POSStore);
        Rec."Location Code" := POSStore."Location Code";
    end;

    procedure GetNextLineNo() NextLineNo: Integer
    var
        SaleLinePOS: Record "NPR POS Sale Line";
    begin
        IsAutoSplitKeyRecord := false;
        if InsertWithAutoSplitKeyForced and (Rec."Line No." <> 0) then begin
            SaleLinePOS.SetCurrentKey("Register No.", "Sales Ticket No.", "Line No.");
            SaleLinePOS.SetFilter("Register No.", '=%1', Sale."Register No.");
            SaleLinePOS.SetFilter("Sales Ticket No.", '=%1', Sale."Sales Ticket No.");
            SaleLinePOS.SetFilter("Line No.", '>%1', Rec."Line No.");
            if (SaleLinePOS.FindFirst()) then begin
                NextLineNo := Round((SaleLinePOS."Line No." - Rec."Line No.") / 2, 1) + Rec."Line No.";
                SaleLinePOS.SetFilter("Line No.", '=%1', NextLineNo);
                IsAutoSplitKeyRecord := SaleLinePOS.IsEmpty();
                if IsAutoSplitKeyRecord then
                    exit(NextLineNo);

                Error(AUTOSPLIT_ERROR, NextLineNo);
            end;
            SaleLinePOS.Reset();
        end;

        SaleLinePOS.SetCurrentKey("Register No.", "Sales Ticket No.", "Line No.");
        SaleLinePOS.SetRange("Register No.", Sale."Register No.");
        SaleLinePOS.SetRange("Sales Ticket No.", Sale."Sales Ticket No.");
        if SaleLinePOS.FindLast() then;

        NextLineNo := SaleLinePOS."Line No." + 10000;
        exit(NextLineNo);
    end;

    procedure GetNewSaleLine(var SaleLinePOS: Record "NPR POS Sale Line")
    begin
        InitLine();
        SaleLinePOS := Rec;
    end;

    procedure RefreshCurrent(): Boolean
    begin
        exit(Rec.Find());
    end;

    procedure SetFirst()
    begin
        Rec.FindFirst();
    end;

    procedure SetLast()
    begin
        Rec.FindLast();
    end;

    procedure SetPosition(Position: Text): Boolean
    begin
        Rec.SetPosition(Position);
        exit(Rec.Find());
    end;

    internal procedure SetBySystemId(Id: Guid): Boolean
    begin
        exit(Rec.GetBySystemId(Id));
    end;

    internal procedure GetPosition(UseNames: Boolean): Text
    begin
        exit(Rec.GetPosition(UseNames));
    end;

    internal procedure GetSystemId(): Guid
    begin
        exit(Rec.SystemId);
    end;

    procedure GetCurrentSaleLine(var SaleLinePOS: Record "NPR POS Sale Line")
    begin
        RefreshCurrent();
        SaleLinePOS.Copy(Rec);
    end;

    procedure InsertLine(var Line: Record "NPR POS Sale Line") Return: Boolean
    begin
        exit(InsertLine(Line, true));
    end;

    procedure InsertLine(var Line: Record "NPR POS Sale Line"; IncludeDiscountFields: Boolean) Return: Boolean
    var
        Item: Record Item;
        SentryScope: Codeunit "NPR Sentry Scope";
        SentryActiveSpan: Codeunit "NPR Sentry Span";
        SentryInsertLineSpan: Codeunit "NPR Sentry Span";
    begin
        if SentryScope.TryGetActiveSpan(SentryActiveSpan) then
            SentryActiveSpan.StartChildSpan('bc.insert_sale_line', 'bc.insert_sale_line', SentryInsertLineSpan);

        if UsePresetLineNo then
            Rec."Line No." := Line."Line No.";

        InitLine();

        Rec."Line Type" := Line."Line Type";

        Rec.SetSkipUpdateDependantQuantity(Line."Variant Code" <> '');

        if (Line."Line Type" = Line."Line Type"::Item) and (Line."Variant Code" = '') then begin
            if Line."Lot No." <> '' then
                Line."Variant Code" := FillVariantLotNoThroughLookUp(Line."No.", Rec."Location Code", Line."Lot No.")
            else
                Line."Variant Code" := FillVariantThroughLookUp(Line."No.", Rec."Location Code");
            Rec.SetSkipUpdateDependantQuantity(Line."Variant Code" <> '');
        end;

        Rec."Variant Code" := Line."Variant Code";
        Rec.Validate("No.", Line."No.");
        Rec."Voucher Category" := Line."Voucher Category";
        if Line."Unit of Measure Code" <> '' then
            Rec.Validate("Unit of Measure Code", Line."Unit of Measure Code");

        Rec.SetSkipUpdateDependantQuantity(false);

        if Line.Description <> '' then
            Rec.Description := Line.Description;

        if Line."Description 2" <> '' then
            Rec."Description 2" := Line."Description 2";

        Rec.Validate(Quantity, Line.Quantity);

        Rec.Validate("NPRE Seating Code", Line."NPRE Seating Code");

        if Rec."Line Type" in [Rec."Line Type"::"GL Payment", Rec."Line Type"::Rounding] then begin
            Rec."Unit Price" := Line."Unit Price";
            Rec.Amount := Line.Amount;
            Rec."Amount Including VAT" := Line."Amount Including VAT";
            Rec."Reason Code" := Line."Reason Code";
        end;

        Rec.SetSkipCalcDiscount(Line.GetSkipCalcDiscount());
        if IncludeDiscountFields then begin
            Rec.Validate("Discount Type", Line."Discount Type");
            Rec.Validate("Discount Code", Line."Discount Code");

            Rec.Validate("Allow Line Discount", Line."Allow Line Discount");
            if not Rec."Allow Line Discount" then
                Rec.Validate("Discount %", 0)
            else
                if Line."Discount %" > 0 then
                    Rec.Validate("Discount %", Line."Discount %");
        end;
        if (not Line."Benefit Item") and (not Line."Shipment Fee") then
            if (Line."Unit Price" <> 0) and UseLinePriceVATParams then
                ConvertPriceToVAT(Line."Price Includes VAT", Line."VAT Bus. Posting Group", Line."VAT Prod. Posting Group", Rec, Line."Unit Price")
            else
                if (Rec."Line Type" = Rec."Line Type"::Item) and (Rec."No." <> '') and (Line."Unit Price" <> 0) then begin
                    Item.Get(Rec."No.");
                    if Item."Price Includes VAT" then begin
                        Item.TestField("VAT Bus. Posting Gr. (Price)");
                        Item.TestField("VAT Prod. Posting Group");
                    end;
                    ConvertPriceToVAT(Item."Price Includes VAT", Item."VAT Bus. Posting Gr. (Price)", Item."VAT Prod. Posting Group", Rec, Line."Unit Price");
                end;
        if (Line."Unit Price" <> 0) or Line."Manual Item Sales Price" or Line."Benefit Item" or Line."Shipment Fee" then
            Rec.Validate("Unit Price", Line."Unit Price");

        if Line."Serial No." <> '' then
            Rec.Validate("Serial No.", Line."Serial No.");
        Rec.Validate("Serial No. not Created", Line."Serial No. not Created");

        If Line."Lot No." <> '' then
            Rec.Validate("Lot No.", Line."Lot No.");

        Rec."Benefit Item" := Line."Benefit Item";
        Rec."Total Discount Code" := Line."Total Discount Code";
        Rec."Total Discount Step" := Line."Total Discount Step";
        Rec."Benefit List Code" := Line."Benefit List Code";

        Rec."Shipment Fee" := Line."Shipment Fee";
        Rec."Store Ship Profile Code" := Line."Store Ship Profile Code";
        Rec."Store Ship Profile Line No." := Line."Store Ship Profile Line No.";
        Rec.Indentation := Line.Indentation;

        Return := InsertLineInternal(Rec, true);
        Line := Rec;

        SentryInsertLineSpan.Finish();
    end;

    procedure DeleteLine()
    var
        LocalxRec: Record "NPR POS Sale Line";
        POSSalesDiscountCalcMgt: Codeunit "NPR POS Sales Disc. Calc. Mgt.";
    begin
        if (not RefreshCurrent()) then
            exit;

        OnBeforeDeletePOSSaleLine(Rec, false);
        LocalxRec := Rec;
        Rec.Delete(true);

        POSSalesDiscountCalcMgt.OnAfterDeleteSaleLinePOS(LocalxRec);

        if (Rec.Find('><')) then begin
            Rec.UpdateAmounts(Rec);
            Rec.Modify();
        end;

        OnAfterDeletePOSSaleLineBeforeCommit(Rec, LocalxRec);
        OnAfterDeletePOSSaleLine(LocalxRec);
        Commit();

        OnAfterDeletePOSSaleLineAfterCommit(Rec, LocalxRec);
        POSSale.RefreshCurrent();
    end;

    procedure DeleteAll(Synchronization: Boolean)
    var
        LocalxRec: Record "NPR POS Sale Line";
    begin
        CheckInit(true);

        if Rec.FindSet(true) then
            repeat
                OnBeforeDeletePOSSaleLine(Rec, Synchronization);
                LocalxRec := Rec;
                Rec.Delete(true);
                OnAfterDeletePOSSaleLine(LocalxRec);
            until Rec.Next() = 0;

        POSSale.RefreshCurrent();
    end;

    procedure DeleteAll()
    begin
        DeleteAll(false);
    end;

    procedure DeleteWPadSupportedLinesOnly()
    var
        SupportedSaleLine: Record "NPR POS Sale Line";
        xSupportedSaleLine: Record "NPR POS Sale Line";
        WaiterPadPOSMgt: Codeunit "NPR NPRE Waiter Pad POS Mgt.";
    begin
        CheckInit(true);
        WaiterPadPOSMgt.FilterSupportedSaleLines(Sale, SupportedSaleLine);
        if SupportedSaleLine.IsEmpty() then
            exit;
        SupportedSaleLine.FindSet(true);
        repeat
            OnBeforeDeletePOSSaleLine(SupportedSaleLine, false);
            xSupportedSaleLine := SupportedSaleLine;
            SupportedSaleLine.Delete(true);
            OnAfterDeletePOSSaleLine(xSupportedSaleLine);
        until SupportedSaleLine.Next() = 0;

        If Rec.Find('=><') then;  //Refresh current
        POSSale.RefreshCurrent();
    end;

    procedure UpdateLine()
    begin
        OnUpdateLine(Rec);
    end;

    procedure IsEmpty(): Boolean
    begin
        CheckInit(true);
        exit(Rec.IsEmpty());
    end;

    procedure SetQuantity(Quantity: Decimal)
    var
        POSSalesDiscountCalcMgt: Codeunit "NPR POS Sales Disc. Calc. Mgt.";
    begin
        RefreshCurrent();
        OnBeforeSetQuantity(Rec, Quantity);

        xRec := Rec;
        Rec.Validate(Quantity, Quantity);
        Rec.Modify(true);

        POSSalesDiscountCalcMgt.OnAfterModifySaleLinePOS(Rec, xRec);

        OnAfterSetQuantityBeforeCommit(Rec, xRec);
        OnAfterSetQuantity(Rec);
        Commit();

        OnAfterSetQuantityAfterCommit(Rec, xRec);
        POSSale.RefreshCurrent();
    end;

    procedure SetUoM(UoMCode: Code[10])
    var
        POSSalesDiscountCalcMgt: Codeunit "NPR POS Sales Disc. Calc. Mgt.";
    begin
        RefreshCurrent();
        OnBeforeSetUoM(Rec, UoMCode);

        xRec := Rec;
        Rec.Validate("Unit of Measure Code", UoMCode);
        Rec.Modify(true);

        POSSalesDiscountCalcMgt.OnAfterModifySaleLinePOS(Rec, xRec);

        OnAfterSetUoMBeforeCommit(Rec, xRec);
        OnAfterSetUoM(Rec);
        Commit();

        OnAfterSetUoMAfterCommit(Rec, xRec);
        POSSale.RefreshCurrent();
    end;

    procedure SetUnitPrice(UnitPriceLCY: Decimal)
    begin
        RefreshCurrent();

        Rec.Validate("Unit Price", UnitPriceLCY);

        if (Rec."Line Type" = Rec."Line Type"::Item) then
            Rec."Initial Group Sale Price" := UnitPriceLCY;

        Rec.Modify(true);
        POSSale.RefreshCurrent();
    end;

    procedure SetLocation(LocationCode: Code[10])
    var
        POSSalesDiscountCalcMgt: Codeunit "NPR POS Sales Disc. Calc. Mgt.";
    begin
        RefreshCurrent();
        OnBeforeSetLocation(Rec, LocationCode);

        xRec := Rec;
        Rec.Validate("Location Code", LocationCode);
        Rec.Modify(true);

        POSSalesDiscountCalcMgt.OnAfterModifySaleLinePOS(Rec, xRec);

        OnAfterSetLocationBeforeCommit(Rec, xRec);
        OnAfterSetLocation(Rec);
        Commit();

        OnAfterSetLocationAfterCommit(Rec, xRec);
        POSSale.RefreshCurrent();
    end;

    procedure SetBin(BinCode: Code[20])
    begin
        RefreshCurrent();
        OnBeforeSetBin(Rec, BinCode);

        xRec := Rec;
        Rec.Validate("Bin Code", BinCode);
        Rec.Modify(true);

        OnAfterSetBin(Rec);

        POSSale.RefreshCurrent();
    end;

    procedure SetDescription(NewDescription: Text)
    begin
        RefreshCurrent();

        if NewDescription <> '' then
            Rec.Description := CopyStr(NewDescription, 1, MaxStrLen(Rec.Description));

        Rec.Modify(true);
        POSSale.RefreshCurrent();
    end;

    procedure CalculateBalance(var AmountExclVAT: Decimal; var VATAmount: Decimal; var TotalAmount: Decimal; var ItemCount: Decimal)
    var
        SaleLine: Record "NPR POS Sale Line";
        OutPaymentAmount: Decimal;
    begin
        AmountExclVAT := 0;
        VATAmount := 0;
        TotalAmount := 0;
        ItemCount := 0;

        if (Rec."Register No." <> '') and (Rec."Sales Ticket No." <> '') then begin
            SaleLine.SetRange("Register No.", Rec."Register No.");
            SaleLine.SetRange("Sales Ticket No.", Rec."Sales Ticket No.");
            SaleLine.SetFilter("Line Type", '<>%1', Rec."Line Type"::Comment);
            SaleLine.SetLoadFields("Line Type", Quantity, Amount, "Amount Including VAT");
            if SaleLine.FindSet() then begin
                repeat
                    if SaleLine."Line Type" = SaleLine."Line Type"::Item then
                        ItemCount += SaleLine.Quantity;
                    if SaleLine."Line Type" in [SaleLine."Line Type"::"BOM List", SaleLine."Line Type"::"Customer Deposit", SaleLine."Line Type"::"Issue Voucher", SaleLine."Line Type"::"Item Category", SaleLine."Line Type"::"Issue Voucher", SaleLine."Line Type"::Item, SaleLine."Line Type"::Rounding] then begin
                        AmountExclVAT += SaleLine.Amount;
                        TotalAmount += SaleLine."Amount Including VAT";
                    end else
                        if SaleLine."Line Type" = SaleLine."Line Type"::"GL Payment" then begin
                            OutPaymentAmount += SaleLine."Amount Including VAT";
                            AmountExclVAT += SaleLine.Amount;
                        end;
                until SaleLine.Next() = 0;
                TotalAmount += OutPaymentAmount;
                VATAmount := TotalAmount - AmountExclVAT;
            end;
        end;
    end;

    procedure CalculateBalance(var AmountExclVAT: Decimal; var VATAmount: Decimal; var TotalAmount: Decimal)
    begin
        CalculateBalance(AmountExclVAT, VATAmount, TotalAmount, _ItemCountWhenCalculatedBalance);
    end;

    internal procedure ToDataset(var CurrDataSet: Codeunit "NPR Data Set"; DataSource: Codeunit "NPR Data Source"; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management")
    var
        DataMgt: Codeunit "NPR POS Data Mgmt. Internal";
        AmountExclVAT: Decimal;
        VATAmount: Decimal;
        TotalAmount: Decimal;
    begin
        DataMgt.RecordToDataSet(Rec, CurrDataSet, DataSource, POSSession, FrontEnd);
        CalculateBalance(AmountExclVAT, VATAmount, TotalAmount);
        CurrDataSet.Totals().Add('AmountExclVAT', AmountExclVAT);
        CurrDataSet.Totals().Add('VATAmount', VATAmount);
        CurrDataSet.Totals().Add('TotalAmount', TotalAmount);
        CurrDataSet.Totals().Add('ItemCount', _ItemCountWhenCalculatedBalance);
    end;

    [Obsolete('Zero reference', '2023-06-28')]
    procedure GetDepositLine(var LinePOS: Record "NPR POS Sale Line")
    begin

    end;

    procedure InitPayoutPayInLine(var LinePOS: Record "NPR POS Sale Line")
    begin
        SetPayoutPayInLineType(LinePOS);
    end;


    local procedure SetPayoutPayInLineType(var LinePOS: Record "NPR POS Sale Line")
    begin
        LinePOS."Register No." := Sale."Register No.";
        LinePOS."Sales Ticket No." := Sale."Sales Ticket No.";
        LinePOS.Date := Sale.Date;
        LinePOS."Line Type" := LinePOS."Line Type"::"GL Payment";
        LinePOS.Quantity := 1;
    end;

    [Obsolete('Zero reference', '2023-06-28')]
    procedure InsertDepositLine(var Line: Record "NPR POS Sale Line"; ForeignCurrencyAmount: Decimal) Return: Boolean
    begin
        InitLine();

        Rec."Line Type" := Line."Line Type";
        Rec."No." := Line."No.";
        Rec.Description := Line.Description;
        Rec.Quantity := Line.Quantity;
        Rec.Amount := Line.Amount;
        Rec."Unit Price" := Line."Unit Price";
        Rec."Amount Including VAT" := Line."Amount Including VAT";
        Rec.UpdateAmounts(Rec);

        if Rec.Description = '' then
            Rec.Description := TEXTDEPOSIT;

        Return := InsertLineInternal(Rec, true);
        Line := Rec;
    end;

    procedure ResendAllOnAfterInsertPOSSaleLine()
    var
        SaleLinePOS: Record "NPR POS Sale Line";
        POSSalesDiscountCalcMgt: Codeunit "NPR POS Sales Disc. Calc. Mgt.";
    begin
        SaleLinePOS.CopyFilters(Rec);
        if (SaleLinePOS.FindSet()) then
            repeat
                InvokeOnAfterInsertSaleLineWorkflow(SaleLinePOS);
            until (SaleLinePOS.Next() = 0);

        Sale.Get(SaleLinePOS."Register No.", SaleLinePOS."Sales Ticket No.");
        POSSalesDiscountCalcMgt.RecalculateAllSaleLinePOS(Sale);

        POSSale.RefreshCurrent();
    end;

    procedure FillVariantThroughLookUp(ItemNo: Code[20]; LocationCode: Code[10]): Code[10]
    var
        ItemVariantBuffer: Record "NPR Item Variant Buffer";
        SentryScope: Codeunit "NPR Sentry Scope";
        SentryActiveSpan: Codeunit "NPR Sentry Span";
        SentryVariantLookupSpan: Codeunit "NPR Sentry Span";
    begin
        FillVariantBuffer(ItemNo, ItemVariantBuffer);
        if ItemVariantBuffer.IsEmpty() then
            exit('');

        if SentryScope.TryGetActiveSpan(SentryActiveSpan) then
            SentryActiveSpan.StartChildSpan('bc.item_variant_lookup', 'bc.item_variant_lookup', SentryVariantLookupSpan);
        ItemVariantBuffer.SetRange("Location Filter", LocationCode);
        if Page.RunModal(Page::"NPR Item Variants Lookup", ItemVariantBuffer) = ACTION::LookupOK then begin
            SentryVariantLookupSpan.Finish();
            exit(ItemVariantBuffer.Code);
        end else begin
            Error(ITEM_REQUIRES_VARIANT, ItemNo);
        end;
    end;

    procedure FillVariantLotNoThroughLookUp(ItemNo: Code[20]; LocationCode: Code[10]; LotNo: Code[50]): Code[10]
    var
        ItemVariantBuffer: Record "NPR Item Variant Buffer";
        SentryScope: Codeunit "NPR Sentry Scope";
        SentryActiveSpan: Codeunit "NPR Sentry Span";
        SentryVariantLookupSpan: Codeunit "NPR Sentry Span";
    begin
        FillVariantLotNoBuffer(ItemNo, ItemVariantBuffer, LotNo);
        if ItemVariantBuffer.IsEmpty() then
            exit('');

        if SentryScope.TryGetActiveSpan(SentryActiveSpan) then
            SentryActiveSpan.StartChildSpan('bc.item_variant_lookup', 'bc.item_variant_lookup', SentryVariantLookupSpan);
        ItemVariantBuffer.SetRange("Location Filter", LocationCode);
        if Page.RunModal(Page::"NPR Item Variants Lookup", ItemVariantBuffer) = ACTION::LookupOK then begin
            SentryVariantLookupSpan.Finish();
            exit(ItemVariantBuffer.Code);
        end else begin
            Error(ITEM_REQUIRES_VARIANT, ItemNo);
        end;
    end;


    local procedure FillVariantBuffer(ItemNo: Code[20]; var TempItemVariantBuffer: Record "NPR Item Variant Buffer")
    var
        ItemVariantsQuery: Query "NPR Item Variants";
    begin
        ItemVariantsQuery.SetRange(Item_No_, ItemNo);
        ItemVariantsQuery.Open();

        while ItemVariantsQuery.Read() do begin
            TempItemVariantBuffer.SetRange(Code, ItemVariantsQuery.Code);
            TempItemVariantBuffer.SetRange("Item No.", ItemNo);
            if TempItemVariantBuffer.IsEmpty() then begin
                TempItemVariantBuffer.Init();
                TempItemVariantBuffer.Code := ItemVariantsQuery.Code;
                TempItemVariantBuffer.Description := ItemVariantsQuery.Description;
                TempItemVariantBuffer."Description 2" := ItemVariantsQuery.Description_2;
                TempItemVariantBuffer."Item No." := ItemNo;
                TempItemVariantBuffer.Insert();
            end;
        end;
        TempItemVariantBuffer.Reset();
        ItemVariantsQuery.Close();
    end;

    local procedure FillVariantLotNoBuffer(ItemNo: Code[20]; var TempItemVariantBuffer: Record "NPR Item Variant Buffer"; LotNo: Code[50])
    var
        ItemVariantsQuery: Query "NPR Item Variants";
    begin
        ItemVariantsQuery.SetRange(Item_No_, ItemNo);
        ItemVariantsQuery.SetFilter(Open, '=%1', true);
        ItemVariantsQuery.SetFilter(Lot_No_, '=%1', LotNo);
        ItemVariantsQuery.SetFilter(Remaining_Quantity, '>%1', 0);
        ItemVariantsQuery.Open();

        TempItemVariantBuffer.Reset();
        if not TempItemVariantBuffer.IsEmpty() then
            TempItemVariantBuffer.DeleteAll();

        while ItemVariantsQuery.Read() do begin
            if not TempItemVariantBuffer.Get(ItemVariantsQuery.Code, ItemNo, ItemVariantsQuery.Lot_No_) then begin
                TempItemVariantBuffer.Init();
                TempItemVariantBuffer.Code := ItemVariantsQuery.Code;
                TempItemVariantBuffer.Description := ItemVariantsQuery.Description;
                TempItemVariantBuffer."Description 2" := ItemVariantsQuery.Description_2;
                TempItemVariantBuffer."Item No." := ItemNo;
                TempItemVariantBuffer."Lot No." := ItemVariantsQuery.Lot_No_;
                TempItemVariantBuffer.Insert();
            end;
        end;
        TempItemVariantBuffer.Reset();
        ItemVariantsQuery.Close();
    end;

    procedure InsertLineRaw(var Line: Record "NPR POS Sale Line"; HandleReturnValue: Boolean): Boolean
    begin
        Line.TestField("Register No.", Sale."Register No.");
        Line.TestField("Sales Ticket No.", Sale."Sales Ticket No.");
        Line.TestField(Date, Sale.Date);

        exit(InsertLineInternal(Line, HandleReturnValue));
    end;

#pragma warning disable AA0137
    internal procedure CheckMandatoryFields(var PosSaleLine: Record "NPR POS Sale Line")
    var
        Item: Record "Item";
    begin
#IF NOT (BC17 or BC18 or BC19 or BC20)        
        case PosSaleLine."Line Type" of
            PosSaleLine."Line Type"::Item:
                begin
                    if Item.Get(PosSaleLine."No.") then
                        if Item.IsVariantMandatory() then
                            PosSaleLine.TestField("Variant Code");
                end;
        end;
#ENDIF        
    end;
#pragma warning restore AA0137

    local procedure InsertLineInternal(var Line: Record "NPR POS Sale Line"; HandleReturnValue: Boolean) ReturnValue: Boolean
    var
        POSSalesDiscountCalcMgt: Codeunit "NPR POS Sales Disc. Calc. Mgt.";
        POSIssueOnSale: Codeunit "NPR POSAction Issue DC OnSaleB";
        HTMLDisplay: Codeunit "NPR POS HTML Disp. Prof.";
        POSProxyDisplay: Codeunit "NPR POS Proxy - Display";
        TicketRetailMgt: Codeunit "NPR TM Ticket Retail Mgt.";
        POSActMemberMgt: codeunit "NPR POS Action Member Mgt WF3";
        WalletCreate: Codeunit "NPR AttractionWalletCreate";
    begin
        Rec := Line;

        CheckMandatoryFields(Line);

        InvokeOnBeforeInsertSaleLineWorkflow(Rec);
        OnBeforeInsertPOSSaleLine(Rec);

        if HandleReturnValue then
            ReturnValue := Rec.Insert(true)
        else begin
            Rec.Insert(true);
            ReturnValue := true;
        end;

        Rec.UpdateAmounts(Rec);
        if (not (Rec.GetSkipCalcDiscount())) then
            POSSalesDiscountCalcMgt.OnAfterInsertSaleLinePOS(Rec);

        OnAfterInsertPOSSaleLineBeforeWorkflows(Rec);

        POSIssueOnSale.AddNewSaleCoupons(Rec);

        WalletCreate.CreateIntermediateWallet(Rec);
        TicketRetailMgt.UpdateTicketOnSaleLineInsert(Rec);
        POSActMemberMgt.UpdateMembershipOnSaleLineInsert(Rec);

        HTMLDisplay.UpdateHTMLDisplay();
        POSProxyDisplay.UpdateDisplay(Rec);
        InvokeOnAfterInsertSaleLineWorkflow(Rec);

        RefreshCurrent();
        OnAfterInsertPOSSaleLineBeforeCommit(Rec);
        OnAfterInsertPOSSaleLine(Rec);
        Commit();

        OnAfterInsertPOSSaleLineAfterCommit(Rec);
        POSSale.RefreshCurrent();

        Line := Rec;
    end;

    //--- Publishers ---
    [Obsolete('Not used. Use OnAfterDeletePOSSaleLineBeforeCommit or OnAfterDeletePOSSaleLineAfterCommit instead.', '2024-01-28')]
    [IntegrationEvent(true, false)]
    internal procedure OnAfterDeletePOSSaleLine(SaleLinePOS: Record "NPR POS Sale Line")
    begin
    end;

    [CommitBehavior(CommitBehavior::Error)]
    [IntegrationEvent(true, false)]
    local procedure OnAfterDeletePOSSaleLineBeforeCommit(var SaleLinePOS: Record "NPR POS Sale Line"; xSaleLinePOS: Record "NPR POS Sale Line")
    begin
    end;

    [IntegrationEvent(true, false)]
    local procedure OnAfterDeletePOSSaleLineAfterCommit(var SaleLinePOS: Record "NPR POS Sale Line"; xSaleLinePOS: Record "NPR POS Sale Line")
    begin
    end;

    [IntegrationEvent(true, false)]
    internal procedure OnBeforeDeletePOSSaleLine(SaleLinePOS: Record "NPR POS Sale Line"; Synchronization: Boolean)
    begin
    end;

    [IntegrationEvent(true, false)]
    internal procedure OnUpdateLine(var SaleLinePOS: Record "NPR POS Sale Line")
    begin
    end;

    [Obsolete('Not used. Use OnAfterSetQuantityBeforeCommit or OnAfterSetQuantityAfterCommit instead.', '2024-01-28')]
    [IntegrationEvent(true, false)]
    procedure OnAfterSetQuantity(var SaleLinePOS: Record "NPR POS Sale Line")
    begin
    end;

    [CommitBehavior(CommitBehavior::Error)]
    [IntegrationEvent(true, false)]
    procedure OnAfterSetQuantityBeforeCommit(var SaleLinePOS: Record "NPR POS Sale Line"; xSaleLinePOS: Record "NPR POS Sale Line")
    begin
    end;

    [IntegrationEvent(true, false)]
    procedure OnAfterSetQuantityAfterCommit(var SaleLinePOS: Record "NPR POS Sale Line"; xSaleLinePOS: Record "NPR POS Sale Line")
    begin
    end;

    [Obsolete('Not used. Use OnAfterSetUoMBeforeCommit or OnAfterSetUoMAfterCommit instead.', '2024-01-28')]
    [IntegrationEvent(true, false)]
    procedure OnAfterSetUoM(var SaleLinePOS: Record "NPR POS Sale Line")
    begin
    end;

    [CommitBehavior(CommitBehavior::Error)]
    [IntegrationEvent(true, false)]
    procedure OnAfterSetUoMBeforeCommit(var SaleLinePOS: Record "NPR POS Sale Line"; xSaleLinePOS: Record "NPR POS Sale Line")
    begin
    end;

    [IntegrationEvent(true, false)]
    procedure OnAfterSetUoMAfterCommit(var SaleLinePOS: Record "NPR POS Sale Line"; xSaleLinePOS: Record "NPR POS Sale Line")
    begin
    end;

    [Obsolete('Not used. Use OnAfterSetLocationBeforeCommit or OnAfterSetLocationAfterCommit instead.', '2024-01-28')]
    [IntegrationEvent(true, false)]
    procedure OnAfterSetLocation(var SaleLinePOS: Record "NPR POS Sale Line")
    begin
    end;

    [CommitBehavior(CommitBehavior::Error)]
    [IntegrationEvent(true, false)]
    procedure OnAfterSetLocationBeforeCommit(var SaleLinePOS: Record "NPR POS Sale Line"; xSaleLinePOS: Record "NPR POS Sale Line")
    begin
    end;

    [IntegrationEvent(true, false)]
    procedure OnAfterSetLocationAfterCommit(var SaleLinePOS: Record "NPR POS Sale Line"; xSaleLinePOS: Record "NPR POS Sale Line")
    begin
    end;

    [IntegrationEvent(true, false)]
    procedure OnAfterSetBin(var SaleLinePOS: Record "NPR POS Sale Line")
    begin
    end;

    [IntegrationEvent(true, false)]
    internal procedure OnBeforeSetQuantity(var SaleLinePOS: Record "NPR POS Sale Line"; var NewQuantity: Decimal)
    begin
    end;

    [IntegrationEvent(true, false)]
    internal procedure OnBeforeSetUoM(var SaleLinePOS: Record "NPR POS Sale Line"; var UoM: Code[10])
    begin
    end;

    [IntegrationEvent(true, false)]
    internal procedure OnBeforeSetLocation(var SaleLinePOS: Record "NPR POS Sale Line"; var Location: Code[10])
    begin
    end;

    [IntegrationEvent(true, false)]
    internal procedure OnBeforeSetBin(var SaleLinePOS: Record "NPR POS Sale Line"; var Bin: Code[20])
    begin
    end;
    //--- POS Sales Workflow ---
    [Obsolete('Remove after POS Scenario is removed', '2023-06-28')]
    local procedure OnBeforeInsertSaleLineCode(): Code[20]
    begin
        exit('BEFORE_INSERT_LINE');
    end;

    [Obsolete('Remove after POS Scenario is removed', '2023-06-28')]
    local procedure OnAfterInsertSaleLineCode(): Code[20]
    begin
        exit('AFTER_INSERT_LINE');
    end;

    [Obsolete('Remove after POS Scenario is removed', '2023-06-28')]
    [EventSubscriber(ObjectType::Table, Database::"NPR POS Sales Workflow", 'OnDiscoverPOSSalesWorkflows', '', true, true)]
    local procedure OnDiscoverPOSWorkflows(var Sender: Record "NPR POS Sales Workflow")
    begin
        Sender.DiscoverPOSSalesWorkflow(OnBeforeInsertSaleLineCode(), Text000, CurrCodeunitId(), 'OnBeforeInsertSaleLine');
        Sender.DiscoverPOSSalesWorkflow(OnAfterInsertSaleLineCode(), Text001, CurrCodeunitId(), 'OnAfterInsertSaleLine');
    end;

    local procedure CurrCodeunitId(): Integer
    begin
        exit(CODEUNIT::"NPR POS Sale Line");
    end;

    [Obsolete('Remove after POS Scenario is removed', '2023-06-28')]
    procedure InvokeOnBeforeInsertSaleLineWorkflow(var SaleLinePOS: Record "NPR POS Sale Line")
    var
        POSSalesWorkflowSetEntry: Record "NPR POS Sales WF Set Entry";
        POSSalesWorkflowStep: Record "NPR POS Sales Workflow Step";
        POSUnit: Record "NPR POS Unit";
    begin
        POSSalesWorkflowStep.SetCurrentKey("Sequence No.");
        POSSalesWorkflowStep.SetFilter("Set Code", '=%1', '');
        if POSUnit.Get(SaleLinePOS."Register No.") and (POSUnit."POS Sales Workflow Set" <> '') and POSSalesWorkflowSetEntry.Get(POSUnit."POS Sales Workflow Set", OnBeforeInsertSaleLineCode()) then
            POSSalesWorkflowStep.SetRange("Set Code", POSSalesWorkflowSetEntry."Set Code");
        POSSalesWorkflowStep.SetRange("Workflow Code", OnBeforeInsertSaleLineCode());
        POSSalesWorkflowStep.SetRange(Enabled, true);
        if not POSSalesWorkflowStep.FindSet() then
            exit;

        repeat
            OnBeforeInsertSaleLine(POSSalesWorkflowStep, SaleLinePOS);
        until POSSalesWorkflowStep.Next() = 0;
    end;

    [Obsolete('Remove after POS Scenario is removed', '2023-06-28')]
    procedure InvokeOnAfterInsertSaleLineWorkflow(var SaleLinePOS: Record "NPR POS Sale Line")
    var
        POSSalesWorkflowSetEntry: Record "NPR POS Sales WF Set Entry";
        POSSalesWorkflowStep: Record "NPR POS Sales Workflow Step";
        POSUnit: Record "NPR POS Unit";
    begin
        POSSalesWorkflowStep.SetCurrentKey("Sequence No.");
        POSSalesWorkflowStep.SetFilter("Set Code", '=%1', '');
        if POSUnit.Get(SaleLinePOS."Register No.") and (POSUnit."POS Sales Workflow Set" <> '') and POSSalesWorkflowSetEntry.Get(POSUnit."POS Sales Workflow Set", OnAfterInsertSaleLineCode()) then
            POSSalesWorkflowStep.SetRange("Set Code", POSSalesWorkflowSetEntry."Set Code");
        POSSalesWorkflowStep.SetRange("Workflow Code", OnAfterInsertSaleLineCode());
        POSSalesWorkflowStep.SetRange(Enabled, true);
        if not POSSalesWorkflowStep.FindSet() then
            exit;

        repeat
            OnAfterInsertSaleLine(POSSalesWorkflowStep, SaleLinePOS);
        until POSSalesWorkflowStep.Next() = 0;
    end;

    [Obsolete('Use OnBeforeInsertPOSSaleLine', '2023-06-28')]
    [IntegrationEvent(false, false)]
    local procedure OnBeforeInsertSaleLine(POSSalesWorkflowStep: Record "NPR POS Sales Workflow Step"; var SaleLinePOS: Record "NPR POS Sale Line")
    begin
    end;

    [Obsolete('Use OnAfterInsertPOSSaleLine', '2023-06-28')]
    [IntegrationEvent(false, false)]
    local procedure OnAfterInsertSaleLine(POSSalesWorkflowStep: Record "NPR POS Sales Workflow Step"; SaleLinePOS: Record "NPR POS Sale Line")
    begin
    end;

    [Obsolete('Not used. Use OnAfterInsertPOSSaleLineBeforeCommit or OnAfterInsertPOSSaleLineAfterCommit instead.', '2024-01-28')]
    [IntegrationEvent(false, false)]
    local procedure OnAfterInsertPOSSaleLine(SaleLinePOS: Record "NPR POS Sale Line")
    begin
    end;

    [CommitBehavior(CommitBehavior::Error)]
    [IntegrationEvent(true, false)]
    local procedure OnAfterInsertPOSSaleLineBeforeWorkflows(var SaleLinePOS: Record "NPR POS Sale Line")
    begin
    end;

    [CommitBehavior(CommitBehavior::Error)]
    [IntegrationEvent(true, false)]
    local procedure OnAfterInsertPOSSaleLineBeforeCommit(var SaleLinePOS: Record "NPR POS Sale Line")
    begin
    end;

    [IntegrationEvent(true, false)]
    local procedure OnAfterInsertPOSSaleLineAfterCommit(var SaleLinePOS: Record "NPR POS Sale Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeInsertPOSSaleLine(SaleLinePOS: Record "NPR POS Sale Line")
    begin
    end;

    procedure ConvertPriceToVAT(FromPricesInclVAT: Boolean; FromVATBusPostingGr: Code[20]; FromVATProdPostingGr: Code[20]; SaleLinePOS: Record "NPR POS Sale Line"; var UnitPrice: Decimal)
    begin
        DoConvertPriceToVAT(FromPricesInclVAT, FromVATBusPostingGr, FromVATProdPostingGr, SaleLinePOS, UnitPrice);
    end;

    procedure DoConvertPriceToVAT(FromPricesInclVAT: Boolean; FromVATBusPostingGr: Code[20]; FromVATProdPostingGr: Code[20]; SaleLinePOS: Record "NPR POS Sale Line"; var UnitPrice: Decimal) PriceRecalculated: Boolean
    var
        Currency: Record Currency;
        VATPostingSetup: Record "VAT Posting Setup";
    begin
        PriceRecalculated := false;
        if FromPricesInclVAT then begin
            VATPostingSetup.Get(FromVATBusPostingGr, FromVATProdPostingGr);

            case VATPostingSetup."VAT Calculation Type" of
                VATPostingSetup."VAT Calculation Type"::"Reverse Charge VAT":
                    VATPostingSetup."VAT %" := 0;
                VATPostingSetup."VAT Calculation Type"::"Sales Tax":
                    Error(
                      CannotCalcPriceInclVATErr,
                      VATPostingSetup.FieldCaption("VAT Calculation Type"),
                      VATPostingSetup."VAT Calculation Type");
            end;

            if SaleLinePOS."Price Includes VAT" then
                if (VATPostingSetup."VAT %" = SaleLinePOS."VAT %") and
                   (VATPostingSetup."VAT Calculation Type" = SaleLinePOS."VAT Calculation Type")
                then
                    exit;

            case SaleLinePOS."VAT Calculation Type" of
                SaleLinePOS."VAT Calculation Type"::"Normal VAT",
                SaleLinePOS."VAT Calculation Type"::"Full VAT",
                SaleLinePOS."VAT Calculation Type"::"Sales Tax":
                    begin
                        if SaleLinePOS."Price Includes VAT" then
                            UnitPrice := UnitPrice * (100 + SaleLinePOS."VAT %") / (100 + VATPostingSetup."VAT %")
                        else
                            UnitPrice := UnitPrice / (1 + VATPostingSetup."VAT %" / 100);
                    end;
                SaleLinePOS."VAT Calculation Type"::"Reverse Charge VAT":
                    UnitPrice := UnitPrice / (1 + VATPostingSetup."VAT %" / 100);
            end;
            PriceRecalculated := true;
        end else
            if SaleLinePOS."Price Includes VAT" then begin
                UnitPrice := UnitPrice * (1 + SaleLinePOS."VAT %" / 100);
                PriceRecalculated := true;
            end;

        if PriceRecalculated then begin
            if SaleLinePOS."Currency Code" <> '' then
                Currency.Get(SaleLinePOS."Currency Code")
            else
                Currency.InitRoundingPrecision();
            UnitPrice := Round(UnitPrice, Currency."Unit-Amount Rounding Precision");
        end;
    end;

    procedure RefreshxRec()
    begin
        xRec := Rec;
    end;

    procedure GetxRec(var xSaleLinePOS: Record "NPR POS Sale Line")
    begin
        xSaleLinePOS := xRec;
    end;

    procedure SetUseLinePriceVATParams(Use: Boolean)
    begin
        UseLinePriceVATParams := Use;
    end;

    procedure ForceInsertWithAutoSplitKey(Set: Boolean)
    begin
        InsertWithAutoSplitKeyForced := Set;
    end;

    procedure InsertedWithAutoSplitKey(): Boolean
    begin
        exit(IsAutoSplitKeyRecord);
    end;

    procedure SetUsePresetLineNo(Set: Boolean)
    begin
        UsePresetLineNo := Set;
    end;
}
