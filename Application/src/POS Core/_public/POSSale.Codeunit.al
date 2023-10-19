codeunit 6150705 "NPR POS Sale"
{
    var
        _LastSalePOSEntry: Record "NPR POS Entry";
        _Rec: Record "NPR POS Sale";
        _POSUnit: Record "NPR POS Unit";
        _This: Codeunit "NPR POS Sale";
        _Setup: Codeunit "NPR POS Setup";
        _FrontEnd: Codeunit "NPR POS Front End Management";
        _SaleLine: Codeunit "NPR POS Sale Line";
        _PaymentLine: Codeunit "NPR POS Payment Line";
        _IsModified: Boolean;
        _Initialized: Boolean;
        _Ended: Boolean;
        _LastSaleRetrieved: Boolean;
        _SkipItemAvailabilityCheck: Boolean;
        _EndedSalesAmount: Decimal;
        _EndedPaidAmount: Decimal;
        _EndedChangeAmount: Decimal;
        _EndedRoundingAmount: Decimal;
        _LastSaleTotal: Decimal;
        _LastSalePayment: Decimal;
        _LastSaleDateText: Text;
        _LastSaleReturnAmount: Decimal;
        _LastReceiptNo: Text;

    internal procedure InitializeAtLogin(POSUnitIn: Record "NPR POS Unit"; SetupIn: Codeunit "NPR POS Setup")
    begin
        _POSUnit := POSUnitIn;
        _Setup := SetupIn;

        OnAfterInitializeAtLogin(_POSUnit);
    end;

    internal procedure InitializeNewSale(POSUnitIn: Record "NPR POS Unit"; FrontEndIn: Codeunit "NPR POS Front End Management"; SetupIn: Codeunit "NPR POS Setup"; ThisIn: Codeunit "NPR POS Sale"; SystemId: Guid)
    begin
        _Initialized := true;

        _FrontEnd := FrontEndIn;
        _POSUnit := POSUnitIn;
        _Setup := SetupIn;
        _This := ThisIn;

        Clear(_Rec);
        Clear(_LastSaleRetrieved);

        OnBeforeInitSale(_Rec, _FrontEnd);
        InsertSale(SystemId);
        InitGlobalState();
        OnAfterInitSale(_Rec, _FrontEnd);

        _FrontEnd.StartTransaction(_Rec);
    end;

    internal procedure InitializeFromWebserviceSession(POSUnitIn: Record "NPR POS Unit"; FrontEndIn: Codeunit "NPR POS Front End Management"; SetupIn: Codeunit "NPR POS Setup"; ThisIn: Codeunit "NPR POS Sale"; SalesTicketNo: Text)
    begin
        _Initialized := true;

        _FrontEnd := FrontEndIn;
        _POSUnit := POSUnitIn;
        _Setup := SetupIn;
        _This := ThisIn;

        _Rec.Get(POSUnitIn."No.", SalesTicketNo);
        InitGlobalState();
    end;

    local procedure InsertSale(SystemId: Guid)
    var
    begin
        _Rec."Salesperson Code" := _Setup.Salesperson();
        _Rec."Register No." := _POSUnit."No.";
        _Rec."Sales Ticket No." := GetNextReceiptNo(_Rec."Register No.");
        _Rec.Date := Today();
        _Rec."Start Time" := Time;
        _Rec."Sales Channel" := _Setup.SalesChannel();

        if WorkDate() <> Today() then begin
            WorkDate := Today();
        end;

        if not IsNullGuid(SystemId) then begin
            _Rec.SystemId := SystemId;
            _Rec.Insert(true, true);
        end else begin
            _Rec.Insert(true);
        end;

        _Rec.Validate("Customer No.", '');
        _Rec.Modify(true);

        _IsModified := true;
        _Ended := false;
    end;

    local procedure InitGlobalState()
    begin
        _SaleLine.Init(_Rec."Register No.", _Rec."Sales Ticket No.", _This, _Setup, _FrontEnd);
        _PaymentLine.Init(_Rec."Register No.", _Rec."Sales Ticket No.", _This, _Setup, _FrontEnd);

        _Rec.FilterGroup := 2;
        _Rec.SetRange("Register No.", _Rec."Register No.");
        _Rec.SetRange("Sales Ticket No.", _Rec."Sales Ticket No.");
        _Rec.FilterGroup := 0;
    end;

    procedure IsInitialized(): Boolean
    begin
        exit(_Initialized);
    end;

    internal procedure GetNextReceiptNo(POSUnitNo: Text) ReceiptNo: Code[20]
    var
        NoSeriesManagement: Codeunit NoSeriesManagement;
        POSAuditProfile: Record "NPR POS Audit Profile";
        NPRPOSUnit: Record "NPR POS Unit";
        POSEntry: Record "NPR POS Entry";
        DuplicateReceiptNo: Label 'Duplicate Receipt Number %1';
    begin
        NPRPOSUnit.Get(POSUnitNo);
        NPRPOSUnit.TestField("POS Audit Profile");
        POSAuditProfile.Get(NPRPOSUnit."POS Audit Profile");
        POSAuditProfile.TestField("Sales Ticket No. Series");

        ReceiptNo := NoSeriesManagement.GetNextNo(POSAuditProfile."Sales Ticket No. Series", Today, true);

        POSEntry.SetRange("Document No.", ReceiptNo);
        if not POSEntry.IsEmpty() then
            Error(DuplicateReceiptNo, ReceiptNo);
    end;

    internal procedure GetContext(var SaleLineOut: Codeunit "NPR POS Sale Line"; var PaymentLineOut: Codeunit "NPR POS Payment Line")
    begin
        SaleLineOut := _SaleLine;
        PaymentLineOut := _PaymentLine;
    end;

    internal procedure ToDataset(var CurrDataSet: Codeunit "NPR Data Set"; DataSource: Codeunit "NPR Data Source"; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management")
    var
        TempRec: Record "NPR POS Sale" temporary;
        DataMgt: Codeunit "NPR POS Data Mgmt. Internal";
    begin
        if not _Initialized then begin
            TempRec."Register No." := _POSUnit."No.";
            TempRec.Insert();
            DataMgt.RecordToDataSet(TempRec, CurrDataSet, DataSource, POSSession, FrontEnd);
            exit;
        end;

        DataMgt.RecordToDataSet(_Rec, CurrDataSet, DataSource, POSSession, FrontEnd);
    end;

    internal procedure SetPosition(Position: Text): Boolean
    begin
        _Rec.SetPosition(Position);
        exit(_Rec.Find());
    end;

    internal procedure GetPosition(UseNames: Boolean): Text
    begin
        exit(_Rec.GetPosition(UseNames));
    end;

    procedure GetCurrentSale(var SalePOS: Record "NPR POS Sale")
    begin
        SalePOS.Copy(_Rec);
    end;

    internal procedure SetLastSalePOSEntry(POSEntryIn: Record "NPR POS Entry")
    begin
        _LastSalePOSEntry := POSEntryIn;
    end;

    internal procedure GetLastSalePOSEntry(var POSEntryOut: Record "NPR POS Entry")
    begin
        POSEntryOut := _LastSalePOSEntry;
    end;

    internal procedure GetLastSaleInfo(var LastSaleTotalOut: Decimal; var LastSalePaymentOut: Decimal; var LastSaleDateTextOut: Text; var LastSaleReturnAmountOut: Decimal; var LastReceiptNoOut: Text)
    var
        POSEntry: Record "NPR POS Entry";
        POSSalesLine: Record "NPR POS Entry Sales Line";
        POSPaymentLine: Record "NPR POS Entry Payment Line";
        LastSaleDateLbl: Label '%1 | %2', Locked = true;
    begin
        if not _LastSaleRetrieved then begin
            POSEntry := _LastSalePOSEntry;
            _LastSaleRetrieved :=
                (POSEntry."Entry No." <> 0) and POSEntry.IsSaleTransaction() and
                ((_Rec."Register No." = POSEntry."POS Unit No.") or ((_Rec."Register No." = '') and (_POSUnit."No." = POSEntry."POS Unit No.")));
            if not _LastSaleRetrieved and ((_Rec."Register No." <> '') or (_POSUnit."No." <> '')) then begin
                POSEntry.SetCurrentKey("POS Store Code", "POS Unit No.");
                if _Rec."Register No." <> '' then begin
                    POSEntry.SetRange("POS Store Code", _Rec."POS Store Code");
                    POSEntry.SetRange("POS Unit No.", _Rec."Register No.");
                end else begin
                    POSEntry.SetRange("POS Store Code", _POSUnit."POS Store Code");
                    POSEntry.SetRange("POS Unit No.", _POSUnit."No.");
                end;
                POSEntry.SetFilter("Entry Type", '%1|%2', POSEntry."Entry Type"::"Direct Sale", POSEntry."Entry Type"::"Credit Sale");
                _LastSaleRetrieved := POSEntry.FindLast();
                if _LastSaleRetrieved then
                    SetLastSalePOSEntry(POSEntry);
            end;

            LastSaleTotalOut := 0;
            LastSalePaymentOut := 0;
            LastSaleReturnAmountOut := 0;
            if _LastSaleRetrieved then begin
                LastReceiptNoOut := POSEntry."Fiscal No.";
                LastSaleDateTextOut := StrSubstNo(LastSaleDateLbl, POSEntry."Entry Date", POSEntry."Ending Time");

                POSSalesLine.SetRange("POS Entry No.", POSEntry."Entry No.");
                POSSalesLine.SetLoadFields("Amount Incl. VAT (LCY)");
                if POSSalesLine.FindSet() then
                    repeat
                        LastSaleTotalOut += POSSalesLine."Amount Incl. VAT (LCY)";
                    until POSSalesLine.Next() = 0;

                POSPaymentLine.SetRange("POS Entry No.", POSEntry."Entry No.");
                POSPaymentLine.SetLoadFields("Amount (LCY)");
                if POSPaymentLine.FindSet() then
                    repeat
                        if POSPaymentLine."Amount (LCY)" > 0 then
                            LastSalePaymentOut += POSPaymentLine."Amount (LCY)"
                        else
                            LastSaleReturnAmountOut += POSPaymentLine."Amount (LCY)";
                    until POSPaymentLine.Next() = 0;
            end else begin
                LastReceiptNoOut := '';
                LastSaleDateTextOut := '';
            end;
            _LastReceiptNo := LastReceiptNoOut;
            _LastSaleDateText := LastSaleDateTextOut;
            _LastSaleTotal := LastSaleTotalOut;
            _LastSalePayment := LastSalePaymentOut;
            _LastSaleReturnAmount := LastSaleReturnAmountOut;
        end else begin
            LastSaleTotalOut := _LastSaleTotal;
            LastSalePaymentOut := _LastSalePayment;
            LastSaleReturnAmountOut := _LastSaleReturnAmount;
            LastSaleDateTextOut := _LastSaleDateText;
            LastReceiptNoOut := _LastReceiptNo;
        end;
    end;

    [Obsolete('Automatic in workflow v3', 'NPR23.0')]
    internal procedure GetModified() Result: Boolean
    begin
        Result := _IsModified or (not _Initialized);
        _IsModified := false;
    end;

    [Obsolete('Automatic in workflow v3', 'NPR23.0')]
    procedure SetModified()
    begin
        _IsModified := true;
    end;

    internal procedure SetEnded(NewEnded: Boolean)
    begin
        _Ended := NewEnded;
    end;

    internal procedure PosSaleRecMustExit(): Boolean
    begin
        exit((_Rec."Sales Ticket No." <> '') and not _Ended);
    end;

    internal procedure GetTotals(var SalesAmountOut: Decimal; var PaidAmountOut: Decimal; var ChangeAmountOut: Decimal; var RoundingAmountOut: Decimal)
    var
        ReturnAmount: Decimal;
        SubTotal: Decimal;
    begin
        if _Ended then begin
            SalesAmountOut := _EndedSalesAmount;
            PaidAmountOut := _EndedPaidAmount;
            ChangeAmountOut := _EndedChangeAmount;
            RoundingAmountOut := _EndedRoundingAmount;
        end else
            _PaymentLine.CalculateBalance(SalesAmountOut, PaidAmountOut, ReturnAmount, SubTotal); //ReturnAmount & SubTotal are legacy. Cannot calculate true return without knowing payment type that ended sale.
    end;

    procedure Modify(RunTriggers: Boolean; ReturnValue: Boolean) Result: Boolean
    begin

        if ReturnValue then begin
            Result := _Rec.Modify(RunTriggers);
            if Result then
                _IsModified := true;
        end else begin
            _Rec.Modify(RunTriggers);
            _IsModified := true;
        end;
    end;

    procedure Refresh(var SalePOS: Record "NPR POS Sale")
    begin
        _Rec.Copy(SalePOS);
        OnRefresh(_Rec);
    end;

    procedure RefreshCurrent()
    begin
        if not _Rec.Get(_Rec."Register No.", _Rec."Sales Ticket No.") then
            ThrowNonExistentSaleErr(_Rec);
        OnRefresh(_Rec);
    end;

    local procedure ThrowNonExistentSaleErr(SalePOS: Record "NPR POS Sale")
    var
        SaleNotFoundErr: Label 'POS %1 "%2" for POS Unit No. "%3" does not exist anymore. Someone probably opened up a new session for this POS unit using the same BC user Id and deleted or finished your sale. Please contact system administrator to have system setups fixed, making sure there are no multiple POS sessions started with the same BC user Id at any time.',
                                Comment = '%1 - field "Sales Ticket No." caption, %2 - Sales Ticket No., %3 - POS Unit No.';
    begin
        Error(SaleNotFoundErr, SalePOS.FieldCaption("Sales Ticket No."), SalePOS."Sales Ticket No.", SalePOS."Register No.");
    end;

    internal procedure SetDimension(DimCode: Code[20]; DimValueCode: Code[20])
    var
        Dim: Record Dimension;
        TempDimSetEntry: Record "Dimension Set Entry" temporary;
        DimMgt: Codeunit DimensionManagement;
        OldDimSetID: Integer;
        SetDimension01: Label 'Dimension %1 does not exist';
    begin
        if DimCode = '' then
            exit;
        if (not Dim.Get(DimCode)) then
            Error(SetDimension01, DimCode);

        DimMgt.GetDimensionSet(TempDimSetEntry, _Rec."Dimension Set ID");
        if TempDimSetEntry.Get(TempDimSetEntry."Dimension Set ID", Dim.Code) then
            TempDimSetEntry.Delete();
        if DimValueCode <> '' then begin
            TempDimSetEntry."Dimension Code" := DimCode;
            TempDimSetEntry.Validate("Dimension Value Code", DimValueCode);
            if TempDimSetEntry.Insert() then;
        end;

        OldDimSetID := _Rec."Dimension Set ID";
        _Rec."Dimension Set ID" := TempDimSetEntry.GetDimensionSetID(TempDimSetEntry);
        DimMgt.UpdateGlobalDimFromDimSetID(_Rec."Dimension Set ID", _Rec."Shortcut Dimension 1 Code", _Rec."Shortcut Dimension 2 Code");
        _Rec.Modify();

        if (OldDimSetID <> _Rec."Dimension Set ID") and _Rec.SalesLinesExist() then
            _Rec.UpdateAllLineDim(_Rec."Dimension Set ID", OldDimSetID);

        RefreshCurrent();
    end;

    internal procedure SetShortcutDimCode1(DimensionValue: Code[20])
    begin
        _Rec.Validate(_Rec."Shortcut Dimension 1 Code", DimensionValue);
    end;

    internal procedure SetShortcutDimCode2(DimensionValue: Code[20])
    begin
        _Rec.Validate(_Rec."Shortcut Dimension 2 Code", DimensionValue);
    end;

    internal procedure TryEndSale(POSSession: Codeunit "NPR POS Session"): Boolean
    begin
        exit(TryEndSale(POSSession, true));
    end;

    internal procedure TryEndSale(POSSession: Codeunit "NPR POS Session"; StartNew: Boolean): Boolean
    var
        SalesAmount: Decimal;
        PaidAmount: Decimal;
        ReturnAmount: Decimal;
        SubTotal: Decimal;
    begin
        if not _Initialized then
            Error('POS Sale codeunit not initialized. This is a programming bug, not a user error');
        RefreshCurrent();

        OnAttemptEndSale(_Rec);

        _PaymentLine.CalculateBalance(SalesAmount, PaidAmount, ReturnAmount, SubTotal);

        if SubTotal <> 0 then
            exit(false);

        EndSale(POSSession, StartNew);
        _EndedSalesAmount := SalesAmount;
        _EndedPaidAmount := PaidAmount;
        exit(true);
    end;


    /// <summary>
    /// Ends a POS sale by paying for it directly
    /// </summary>
    /// <param name="POSPaymentMethod">
    /// The payment type just used in sale, triggering this end attempt.
    /// </param>    
    /// <param name="ReturnPOSPaymentMethod">
    /// The payment type to use for round and change in case of overtender.
    /// </param>
    /// <returns>
    /// True if sale ended
    /// </returns>
    internal procedure TryEndDirectSaleWithBalancing(POSSession: Codeunit "NPR POS Session"; POSPaymentMethod: Record "NPR POS Payment Method"; ReturnPOSPaymentMethod: Record "NPR POS Payment Method"): Boolean
    var
        SalesAmount: Decimal;
        PaidAmount: Decimal;
        ReturnAmount: Decimal;
        SubTotal: Decimal;
        POSRounding: Codeunit "NPR POS Rounding";
        POSGiveChange: Codeunit "NPR POS Give Change";
        ChangeAmount: Decimal;
        RoundAmount: Decimal;
    begin
        if not _Initialized then
            Error('POS Sale codeunit not initialized. This is a programming bug, not a user error');
        RefreshCurrent();

        OnAttemptEndSale(_Rec);

        _PaymentLine.CalculateBalance(SalesAmount, PaidAmount, ReturnAmount, SubTotal);

        if not IsPaymentValidForEndingSale(POSPaymentMethod, ReturnPOSPaymentMethod, SalesAmount, PaidAmount) then
            exit(false);

        ChangeAmount := POSGiveChange.InsertChange(_Rec, ReturnPOSPaymentMethod, PaidAmount - SalesAmount);
        RoundAmount := POSRounding.InsertRounding(_Rec, PaidAmount - SalesAmount - ChangeAmount);

        EndSale(POSSession, true);
        _EndedSalesAmount := SalesAmount;
        _EndedPaidAmount := PaidAmount;
        _EndedChangeAmount := ChangeAmount;
        _EndedRoundingAmount := RoundAmount;

        exit(true);
    end;

    local procedure EndSale(POSSession: Codeunit "NPR POS Session"; StartNew: Boolean)
    var
        SalePOS: Record "NPR POS Sale";
        RetailSalesDocMgt: Codeunit "NPR Sales Doc. Exp. Mgt.";
        SalesAmount: Decimal;
        PaidAmount: Decimal;
        ReturnAmount: Decimal;
        SubTotal: Decimal;
        SentryScope: Codeunit "NPR Sentry Scope";
        SentryActiveSpan: Codeunit "NPR Sentry Span";
        SentryEndSaleSpan: Codeunit "NPR Sentry Span";
        SentryPreEndSaleSpan: Codeunit "NPR Sentry Span";
        SentryPostEndSaleSpan: Codeunit "NPR Sentry Span";
    begin
        SentryScope.TryGetActiveSpan(SentryActiveSpan);
        SentryActiveSpan.StartChildSpan('bc.end_sale.pre_processing', 'bc.end_sale.pre_processing', SentryPreEndSaleSpan);

        CheckItemAvailability();
        _PaymentLine.CalculateBalance(SalesAmount, PaidAmount, ReturnAmount, SubTotal);
        RetailSalesDocMgt.HandleLinkedDocuments(POSSession);

        OnBeforeEndSale(_Rec);

        SalePOS := _Rec;

        SentryPreEndSaleSpan.Finish();
        SentryActiveSpan.StartChildSpan('bc.end_sale.pos_entry_write', 'bc.end_sale.pos_entry_write', SentryEndSaleSpan);

        ValidateSaleBeforeEnd(_Rec);

        EndSaleTransaction(SalePOS);
        Commit(); // Sale is now committed to POS entry

        _Ended := true;

        SentryEndSaleSpan.Finish();
        SentryActiveSpan.StartChildSpan('bc.end_sale.post_processing', 'bc.end_sale.post_processing', SentryPostEndSaleSpan);

        RunAfterEndSale(SalePOS); //Any error here would leave the front end with inconsistent state as view switch to new sale or login screen has not happened yet.

        if StartNew then
            if not SelectNextWaiterPadForEndOfSale() then
                SelectViewForEndOfSale();

        SentryPostEndSaleSpan.Finish();
    end;

    [CommitBehavior(CommitBehavior::Error)]
    local procedure EndSaleTransaction(SalePOS: Record "NPR POS Sale")
    var
        POSCreateEntry: Codeunit "NPR POS Create Entry";
        POSEntry: Record "NPR POS Entry";
        SaleLinePOS: Record "NPR POS Sale Line";
    begin
        POSCreateEntry.Run(_Rec);
        POSCreateEntry.GetCreatedPOSEntry(POSEntry);
        SetLastSalePOSEntry(POSEntry);

        SaleLinePOS.SetRange("Register No.", SalePOS."Register No.");
        SaleLinePOS.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");
        SaleLinePOS.DeleteAll();
        _Rec.Delete();
    end;

    local procedure IsPaymentValidForEndingSale(POSPaymentMethod: Record "NPR POS Payment Method"; ReturnPOSPaymentMethod: Record "NPR POS Payment Method"; SalesAmount: Decimal; PaidAmount: Decimal): Boolean
    var
        POSPaymentLine: Codeunit "NPR POS Payment Line";
    begin

        if not POSPaymentMethod."Auto End Sale" then
            exit(false);

        exit(POSPaymentLine.CalculateRemainingPaymentSuggestion(SalesAmount, PaidAmount, POSPaymentMethod, ReturnPOSPaymentMethod, false) = 0);
    end;

    internal procedure SelectViewForEndOfSale()
    var
        POSSession: Codeunit "NPR POS Session";
        POSViewProfile: Record "NPR POS View Profile";
    begin
        POSViewProfile.Init();
        _Setup.GetPOSViewProfile(POSViewProfile);

        if (POSViewProfile."After End-of-Sale View" = POSViewProfile."After End-of-Sale View"::INITIAL_SALE_VIEW) then begin
            POSSession.StartTransaction();

            case POSViewProfile."Initial Sales View" of
                POSViewProfile."Initial Sales View"::SALES_VIEW:
                    POSSession.ChangeViewSale();
                POSViewProfile."Initial Sales View"::RESTAURANT_VIEW:
                    POSSession.ChangeViewRestaurant();
            end;

        end else begin
            POSSession.StartPOSSession();
        end;
    end;

    internal procedure SelectNextWaiterPadForEndOfSale(): Boolean
    var
        POSSession: Codeunit "NPR POS Session";
        NPRELoadAfterEndSaleMgt: Codeunit "NPR NPRE Load AfterEndSale Mgt";
        Success: Boolean;
        LoadWaiterPadAfterEndSaleSuccess: Label 'The next open Waiter Pad has been loaded.';
        LoadWaiterPadAfterEndSaleErr: Label 'An error occurred after the sale ended and the next Waiter Pad could not be loaded: %1';
    begin
        if not HandleRestaurantAfterEndSale() then
            exit;

        if not NPRELoadAfterEndSaleMgt.NextWaiterPadSet(_LastSalePOSEntry."Entry No.") then
            exit;

        ClearLastError();
        Success := NPRELoadAfterEndSaleMgt.Run();
        if Success then begin
            POSSession.ChangeViewSale();
            Message(LoadWaiterPadAfterEndSaleSuccess);
        end else
            Message(LoadWaiterPadAfterEndSaleErr, GetLastErrorText);

        exit(Success);
    end;


    local procedure HandleRestaurantAfterEndSale(): Boolean
    var
        POSRestaurantProfile: Record "NPR POS NPRE Rest. Profile";
    begin
        POSRestaurantProfile.Init();
        _Setup.GetPOSRestProfile(POSRestaurantProfile);
        if POSRestaurantProfile."Restaurant Code" = '' then
            exit;
        exit(POSRestaurantProfile."After End-of-Sale" = POSRestaurantProfile."After End-of-Sale"::"Load Next Waiter Pad");

    end;

    internal procedure ValidateSaleBeforeEnd(var Sale: Record "NPR POS Sale")
    var
        POSPaymentMethod: Record "NPR POS Payment Method";
        SaleLinePOS: Record "NPR POS Sale Line";
        Item: Record Item;
        SalespersonPurchaser: Record "Salesperson/Purchaser";
        ItemTrackingCode: Record "Item Tracking Code";
        ItemTrackingSetup: Record "Item Tracking Setup";
        SerialNoInfo: Record "Serial No. Information";
        ItemTrackingManagement: Codeunit "Item Tracking Management";
        saleNegCashSum: Decimal;
        CreateServiceItem: codeunit "NPR Create Service Item";
        NPRPOSUnit: Record "NPR POS Unit";
        POSStore: Record "NPR POS Store";
        TotalItemAmountInclVat: Decimal;
        ErrReturnCashExceeded: Label 'Return cash exceeded. Create credit voucher instead.';
        ErrSerialNumberRequired: Label 'Serial Number must be supplied for Item %1 - %2';
        Level: Integer;
        ErrNoLines: Label 'Cannot end a sale with no lines';
    begin
        POSStore.Get(Sale."POS Store Code");

        SaleLinePOS.Reset();
        SaleLinePOS.SetCurrentKey("Register No.", "Sales Ticket No.", "Line Type");
        SaleLinePOS.SetRange("Register No.", Sale."Register No.");
        SaleLinePOS.SetRange("Sales Ticket No.", Sale."Sales Ticket No.");
        if SaleLinePOS.FindSet() then
            repeat
                SaleLinePOS.Validate("Shortcut Dimension 1 Code");
                SaleLinePOS.Validate("Shortcut Dimension 2 Code");
                if SaleLinePOS."Line Type" = SaleLinePOS."Line Type"::Item then begin
                    TotalItemAmountInclVat += SaleLinePOS."Amount Including VAT";
                end
            until SaleLinePOS.Next() = 0;

        if TotalItemAmountInclVat < 0 then begin
            saleNegCashSum := 0;
            Clear(SaleLinePOS);
            if SalespersonPurchaser.Get(Sale."Salesperson Code") then
                if SalespersonPurchaser."NPR Maximum Cash Returnsale" > 0 then begin
                    SaleLinePOS.SetCurrentKey("Register No.", "Sales Ticket No.", "Line Type");
                    SaleLinePOS.SetRange("Register No.", Sale."Register No.");
                    SaleLinePOS.SetRange("Sales Ticket No.", Sale."Sales Ticket No.");
                    SaleLinePOS.SetRange("Line Type", SaleLinePOS."Line Type"::"POS Payment");
                    if SaleLinePOS.FindSet() then
                        repeat
                            if POSPaymentMethod.Get(SaleLinePOS."No.") then
                                if (POSPaymentMethod."Processing Type" = POSPaymentMethod."Processing Type"::Cash) and
                                    (SaleLinePOS."Amount Including VAT" < 0) then begin
                                    saleNegCashSum := saleNegCashSum + SaleLinePOS."Amount Including VAT";
                                    if Abs(saleNegCashSum) > Abs(SalespersonPurchaser."NPR Maximum Cash Returnsale") then
                                        Error(ErrReturnCashExceeded);
                                end;
                        until SaleLinePOS.Next() = 0;
                end;
        end;

        SaleLinePOS.Reset();
        SaleLinePOS.SetRange("Register No.", Sale."Register No.");
        SaleLinePOS.SetRange("Sales Ticket No.", Sale."Sales Ticket No.");
        if SaleLinePOS.Find('+') then;
        SaleLinePOS.SetRange("Line Type", SaleLinePOS."Line Type"::"BOM List");
        if SaleLinePOS.Find('-') then
            repeat
                Item.Get(SaleLinePOS."No.");
                if not Item."NPR Explode BOM auto" then begin
                    SaleLinePOS.ExplodeBOM(SaleLinePOS."No.", 0, 0, Level, 0, 0);
                    SaleLinePOS.Amount := 0;
                    SaleLinePOS."Amount Including VAT" := 0;
                    SaleLinePOS."Unit Price" := 0;
                    SaleLinePOS.Quantity := 1;
                    SaleLinePOS.Modify();
                end;
            until SaleLinePOS.Next() = 0;

        Clear(SaleLinePOS);
        SaleLinePOS.SetCurrentKey("Register No.", "Sales Ticket No.", "Line No.");
        SaleLinePOS.SetRange("Register No.", Sale."Register No.");
        SaleLinePOS.SetRange("Sales Ticket No.", Sale."Sales Ticket No.");
        if not SaleLinePOS.FindSet() then
            Error(ErrNoLines);

        repeat
            if SaleLinePOS."Line Type" = SaleLinePOS."Line Type"::Item then begin
                Item.Get(SaleLinePOS."No.");
                if Item."Costing Method" = Item."Costing Method"::Specific then
                    SaleLinePOS.TestField("Serial No.");

                CreateServiceItem.Create(SaleLinePOS, Sale, Item);
                if Item."Item Tracking Code" <> '' then begin
                    ItemTrackingCode.Get(Item."Item Tracking Code");
#if BC17
                    ItemTrackingManagement.GetItemTrackingSetup(ItemTrackingCode, 1, false, ItemTrackingSetup);
#else
                    ItemTrackingManagement.GetItemTrackingSetup(ItemTrackingCode, "Item Ledger Entry Type"::Sale, false, ItemTrackingSetup);
#endif
                    if ItemTrackingSetup."Serial No. Required" then begin
                        if SaleLinePOS."Serial No." = '' then
                            Error(ErrSerialNumberRequired, SaleLinePOS."No.", SaleLinePOS.Description);
                    end;
                    if ItemTrackingSetup."Serial No. Info Required" then begin
                        SerialNoInfo.Get(SaleLinePOS."No.", SaleLinePOS."Variant Code", SaleLinePOS."Serial No.");
                        SerialNoInfo.TestField(Blocked, false);
                    end;
                end else begin
                    if SerialNoInfo.Get(SaleLinePOS."No.", SaleLinePOS."Variant Code", SaleLinePOS."Serial No.") then
                        SerialNoInfo.TestField(Blocked, false);
                end;
            end;

            case SaleLinePOS."Line Type" of
                SaleLinePOS."Line Type"::Item,
                SaleLinePOS."Line Type"::"Item Category":
                    begin
                        SaleLinePOS.TestField("Gen. Bus. Posting Group");
                        SaleLinePOS.TestField("Gen. Prod. Posting Group");
                        SaleLinePOS.TestField("VAT Bus. Posting Group");
                        SaleLinePOS.TestField("VAT Prod. Posting Group");
                    end;
                SaleLinePOS."Line Type"::Rounding,
                SaleLinePOS."Line Type"::"GL Payment",
                SaleLinePOS."Line Type"::"Issue Voucher":
                    begin
                        if SaleLinePOS."Gen. Posting Type" <> SaleLinePOS."Gen. Posting Type"::" " then begin
                            SaleLinePOS.TestField("Gen. Bus. Posting Group");
                            SaleLinePOS.TestField("Gen. Prod. Posting Group");
                            SaleLinePOS.TestField("VAT Bus. Posting Group");
                            SaleLinePOS.TestField("VAT Prod. Posting Group");
                        end;
                    end;
            end;

            if (SaleLinePOS."Discount %" = 0) and
               (SaleLinePOS."Discount Type" = SaleLinePOS."Discount Type"::Manual) then begin
                SaleLinePOS."Discount Type" := SaleLinePOS."Discount Type"::" ";
                SaleLinePOS."Discount Code" := '';
            end;

            if SaleLinePOS."Location Code" = '' then begin
                SaleLinePOS.Validate("Location Code", POSStore."Location Code");
            end;
            if (SaleLinePOS."Responsibility Center" = '') and (POSStore."Responsibility Center" <> '') then
                SaleLinePOS.Validate("Responsibility Center", POSStore."Responsibility Center");
            if SaleLinePOS."Shortcut Dimension 1 Code" = '' then
                SaleLinePOS.Validate("Shortcut Dimension 1 Code", NPRPOSUnit."Global Dimension 1 Code");
            if SaleLinePOS."Shortcut Dimension 2 Code" = '' then
                SaleLinePOS.Validate("Shortcut Dimension 2 Code", NPRPOSUnit."Global Dimension 2 Code");
        until SaleLinePOS.Next() = 0;
    end;

    internal procedure ResumeExistingSale(SalePOS_ToResume: Record "NPR POS Sale"; POSUnitIn: Record "NPR POS Unit"; FrontEndIn: Codeunit "NPR POS Front End Management"; SetupIn: Codeunit "NPR POS Setup"; ThisIn: Codeunit "NPR POS Sale")
    begin
        _Initialized := true;

        _FrontEnd := FrontEndIn;
        _POSUnit := POSUnitIn;
        _Setup := SetupIn;
        _This := ThisIn;

        Clear(_Rec);
        Clear(_LastSaleRetrieved);

        OnBeforeResumeSale(_Rec, _FrontEnd);
        ResumeSale(SalePOS_ToResume);
        OnAfterResumeSale(_Rec, _FrontEnd);

        _FrontEnd.StartTransaction(_Rec);
    end;

    local procedure ResumeSale(SalePOS_ToResume: Record "NPR POS Sale")
    var
        SaleLinePOS: Record "NPR POS Sale Line";
        POSResumeSale: Codeunit "NPR POS Resume Sale Mgt.";
        POSSession: Codeunit "NPR POS Session";
    begin
        _Rec := SalePOS_ToResume;
        _Rec."User ID" := CopyStr(UserId, 1, MaxStrLen(_Rec."User ID"));
        _Rec."Server Instance ID" := Database.ServiceInstanceId();
        _Rec."User Session ID" := Database.SessionId();

        _Rec."Salesperson Code" := _Setup.Salesperson();
        if _Rec."Salesperson Code" <> SalePOS_ToResume."Salesperson Code" then
            _Rec.CreateDimFromDefaultDim(_Rec.FieldNo("Salesperson Code"));

        _Rec.Modify(true);

        _SaleLine.Init(_Rec."Register No.", _Rec."Sales Ticket No.", _This, _Setup, _FrontEnd);
        SaleLinePOS.SetRange("Register No.", _Rec."Register No.");
        SaleLinePOS.SetRange("Sales Ticket No.", _Rec."Sales Ticket No.");
        SaleLinePOS.SetFilter("Line Type", '<>%1', SaleLinePOS."Line Type"::"POS Payment");
        if not SaleLinePOS.IsEmpty then
            _SaleLine.SetLast();

        _PaymentLine.Init(_Rec."Register No.", _Rec."Sales Ticket No.", _This, _Setup, _FrontEnd);

        _Rec.FilterGroup := 2;
        _Rec.SetRange("Register No.", _Rec."Register No.");
        _Rec.SetRange("Sales Ticket No.", _Rec."Sales Ticket No.");
        _Rec.FilterGroup := 0;

        _IsModified := true;

        //Because the lines are not modified no table subscribers are hit, so auto refresh doesn't work.
        POSSession.RequestFullRefresh();

        POSResumeSale.LogSaleResume(_Rec, SalePOS_ToResume."Sales Ticket No.");
    end;

    internal procedure ResumeFromPOSQuote(POSQuoteNo: Integer): Boolean
    var
        SaleLinePOS: Record "NPR POS Sale Line";
        POSResumeSale: Codeunit "NPR POS Resume Sale Mgt.";
        Ok: Boolean;
    begin
        Ok := POSResumeSale.LoadFromPOSQuote(_Rec, POSQuoteNo);
        if Ok then begin
            SaleLinePOS.SetRange("Register No.", _Rec."Register No.");
            SaleLinePOS.SetRange("Sales Ticket No.", _Rec."Sales Ticket No.");
            SaleLinePOS.SetFilter("Line Type", '<>%1', SaleLinePOS."Line Type"::"POS Payment");
            if not SaleLinePOS.IsEmpty then
                _SaleLine.SetLast();

            _IsModified := true;
        end;

        exit(Ok);
    end;

    local procedure RunAfterEndSale_OnRun(xRec: Record "NPR POS Sale") Success: Boolean;
    var
        POSAfterSaleExecution: Codeunit "NPR POS After Sale Execution";
    begin
        POSAfterSaleExecution.OnRunTypeSet(Enum::"NPR POS Sale OnRunType"::RunAfterEndSale);
        POSAfterSaleExecution.RecSet(_Rec);
        POSAfterSaleExecution.PosSaleCodeunitSet(_This);
        POSAfterSaleExecution.OnRunXRecSet(xRec);
        Commit();
        Success := POSAfterSaleExecution.Run();
        POSAfterSaleExecution.OnRunTypeSet(Enum::"NPR POS Sale OnRunType"::Undefined);
    end;

    local procedure RunAfterEndSale(xRec: Record "NPR POS Sale")
    var
        CreateDeFiskalyonSale: Codeunit "NPR Create De Fiskaly on Sale";
        Success: Boolean;
        AfterEndSaleErr: Label 'An error occurred after the sale ended: %1';
        FiskalyError: Label 'The error occurred during the fiskaly process: %1';
    begin
        //Any error at this time would leave the POS with inconsistent front-end state.
        if not CreateDeFiskalyOnSale.Run(xRec) then
            Message(FiskalyError, GetLastErrorText);

        ClearLastError();
        Success := RunAfterEndSale_OnRun(xRec);
        if not Success then
            Message(AfterEndSaleErr, GetLastErrorText);
    end;

    local procedure LogStopwatch(Keyword: Text; Duration: Duration)
    var
        POSSession: Codeunit "NPR POS Session";
    begin
        if not POSSession.IsInitialized() then
            exit;
        POSSession.AddServerStopwatch(Keyword, Duration);
        LogFinishTelem(Duration);
    end;

    local procedure LogFinishTelem(EndSaleDuration: Duration)
    var
        FinishEventIdTok: Label 'NPR_POSEndSale', Locked = true;
        LogDict: Dictionary of [Text, Text];
        MsgTok: Label 'Company:%1, Tenant: %2, Instance: %3, Server: %4, Duration: %5';
        Msg: Text;
        ActiveSession: Record "Active Session";
        DurationMs: Integer;
    begin
        if not ActiveSession.Get(Database.ServiceInstanceId(), Database.SessionId()) then
            Clear(ActiveSession);

        DurationMs := EndSaleDuration;
        LogDict.Add('NPR_Server', ActiveSession."Server Computer Name");
        LogDict.Add('NPR_Instance', ActiveSession."Server Instance Name");
        LogDict.Add('NPR_TenantId', Database.TenantId());
        LogDict.Add('NPR_CompanyName', CompanyName());
        LogDict.Add('NPR_UserID', ActiveSession."User ID");
        LogDict.Add('NPR_POSEndSaleDurationMs', Format(DurationMs, 0, 9));
        Msg := StrSubstNo(MsgTok, CompanyName(), Database.TenantId(), ActiveSession."Server Instance Name", ActiveSession."Server Computer Name", Format(DurationMs, 0, 9));
        Session.LogMessage(FinishEventIdTok, 'POS End Sale: ' + Msg, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::All, LogDict);
    end;

    procedure CheckItemAvailability()
    var
        ItemCheckAvail: Codeunit "Item-Check Avail.";
        PosCreateEntry: Codeunit "NPR POS Create Entry";
        PosItemCheckAvail: Codeunit "NPR POS Item-Check Avail.";
        Success: Boolean;
    begin
        if _SkipItemAvailabilityCheck then
            exit;
        if POSCreateEntry.IsCancelledSale(_Rec) then
            exit;

        Clear(PosItemCheckAvail);
        if BindSubscription(PosItemCheckAvail) then;
        Success := PosItemCheckAvail.CheckAvailability_PosSale(_Rec, true);
        UnbindSubscription(PosItemCheckAvail);
        if not Success then
            ItemCheckAvail.RaiseUpdateInterruptedError();
    end;

    internal procedure SetSkipItemAvailabilityCheck(Set: Boolean)
    begin
        _SkipItemAvailabilityCheck := Set;
    end;

    #region Events

    [IntegrationEvent(false, false)]
    local procedure OnAfterInitializeAtLogin(POSUnit: Record "NPR POS Unit")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeInitSale(SaleHeader: Record "NPR POS Sale"; FrontEnd: Codeunit "NPR POS Front End Management")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterInitSale(SaleHeader: Record "NPR POS Sale"; FrontEnd: Codeunit "NPR POS Front End Management")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeResumeSale(SalePOS: Record "NPR POS Sale"; FrontEnd: Codeunit "NPR POS Front End Management")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterResumeSale(SalePOS: Record "NPR POS Sale"; FrontEnd: Codeunit "NPR POS Front End Management")
    begin
    end;

    [IntegrationEvent(TRUE, false)]
    local procedure OnBeforeEndSale(SaleHeader: Record "NPR POS Sale")
    begin
    end;

    [IntegrationEvent(TRUE, false)]
    internal procedure OnAfterEndSale(SalePOS: Record "NPR POS Sale")
    begin
    end;

    [IntegrationEvent(TRUE, false)]
    local procedure OnAttemptEndSale(SalePOS: Record "NPR POS Sale")
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnRefresh(var SalePOS: Record "NPR POS Sale")
    begin
    end;
    #endregion

    #region OnFinishSale Workflow


    local procedure OnFinishSaleCode(): Code[20]
    begin
        exit('FINISH_SALE');
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Sales Workflow", 'OnDiscoverPOSSalesWorkflows', '', true, true)]
    local procedure OnDiscoverPOSWorkflows(var Sender: Record "NPR POS Sales Workflow")
    var
        DuringEndSaleLbl: Label 'During End Sale';
    begin
        Sender.DiscoverPOSSalesWorkflow(OnFinishSaleCode(), DuringEndSaleLbl, CurrCodeunitId(), 'OnFinishSale');
    end;

    local procedure CurrCodeunitId(): Integer
    begin
        exit(CODEUNIT::"NPR POS Sale");
    end;

    local procedure InvokeOnFinishSaleSubscribers_OnRun(POSSalesWorkflowStep: Record "NPR POS Sales Workflow Step")
    var
        POSAfterSaleExecution: Codeunit "NPR POS After Sale Execution";
        FinishSaleWorkflowErr: Label 'Sale successfully completed, but an error in the post processing occurred:\\%1\\%2';
    begin
        POSAfterSaleExecution.OnRunTypeSet(Enum::"NPR POS Sale OnRunType"::OnFinishSale);
        POSAfterSaleExecution.OnRunPOSSalesWorkflowStepSet(POSSalesWorkflowStep);
        POSAfterSaleExecution.RecSet(_Rec);
        POSAfterSaleExecution.PosSaleCodeunitSet(_This);
        ClearLastError();
        if not POSAfterSaleExecution.Run() then
            Message(FinishSaleWorkflowErr, POSSalesWorkflowStep.Description, GetLastErrorText());
        POSAfterSaleExecution.OnRunTypeSet(Enum::"NPR POS Sale OnRunType"::Undefined);
    end;

    internal procedure InvokeOnFinishSaleWorkflow(SalePOS: Record "NPR POS Sale")
    var
        NPRPOSUnit: Record "NPR POS Unit";
        POSSalesWorkflowSetEntry: Record "NPR POS Sales WF Set Entry";
        POSSalesWorkflowStep: Record "NPR POS Sales Workflow Step";
        StartTime: DateTime;
    begin
        StartTime := CurrentDateTime;
        POSSalesWorkflowStep.SetCurrentKey("Sequence No.");
        POSSalesWorkflowStep.SetFilter("Set Code", '=%1', '');
        if NPRPOSUnit.Get(SalePOS."Register No.") and (NPRPOSUnit."POS Sales Workflow Set" <> '') and POSSalesWorkflowSetEntry.Get(NPRPOSUnit."POS Sales Workflow Set", OnFinishSaleCode()) then
            POSSalesWorkflowStep.SetRange("Set Code", POSSalesWorkflowSetEntry."Set Code");
        POSSalesWorkflowStep.SetRange("Workflow Code", OnFinishSaleCode());
        POSSalesWorkflowStep.SetRange(Enabled, true);
        if not POSSalesWorkflowStep.FindSet() then
            exit;

        Refresh(SalePOS);
        repeat
            InvokeOnFinishSaleSubscribers_OnRun(POSSalesWorkflowStep);
        until POSSalesWorkflowStep.Next() = 0;

        LogStopwatch('FINISH_SALE_WORKFLOWS', CurrentDateTime - StartTime);
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnFinishSale(POSSalesWorkflowStep: Record "NPR POS Sales Workflow Step"; SalePOS: Record "NPR POS Sale")
    begin
    end;

    #endregion
}
