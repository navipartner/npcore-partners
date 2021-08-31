codeunit 6150705 "NPR POS Sale"
{
    var
        Rec: Record "NPR POS Sale";
        POSUnit: Record "NPR POS Unit";
        This: Codeunit "NPR POS Sale";
        Setup: Codeunit "NPR POS Setup";
        FrontEnd: Codeunit "NPR POS Front End Management";
        SaleLine: Codeunit "NPR POS Sale Line";
        PaymentLine: Codeunit "NPR POS Payment Line";
        OnRunType: Enum "NPR POS Sale OnRunType";
        IsModified: Boolean;
        Initialized: Boolean;
        Ended: Boolean;
        LastSaleRetrieved: Boolean;
        SetDimension01: Label 'Dimension %1 does not exist';
        SetDimension02: Label 'Dimension Value %1 does not exist for dimension %2';
        EndedSalesAmount: Decimal;
        EndedPaidAmount: Decimal;
        EndedChangeAmount: Decimal;
        EndedRoundingAmount: Decimal;
        Text000: Label 'During End Sale';
        ERROR_AFTER_END_SALE: Label 'An error occurred after the sale ended: %1';

    procedure InitializeAtLogin(POSUnitIn: Record "NPR POS Unit"; SetupIn: Codeunit "NPR POS Setup")
    begin
        POSUnit := POSUnitIn;
        Setup := SetupIn;

        OnAfterInitializeAtLogin(POSUnit);
    end;

    procedure InitializeNewSale(POSUnitIn: Record "NPR POS Unit"; FrontEndIn: Codeunit "NPR POS Front End Management"; SetupIn: Codeunit "NPR POS Setup"; ThisIn: Codeunit "NPR POS Sale")
    begin
        Initialized := true;

        FrontEnd := FrontEndIn;
        POSUnit := POSUnitIn;
        Setup := SetupIn;
        This := ThisIn;

        Clear(Rec);
        Clear(LastSaleRetrieved);

        OnBeforeInitSale(Rec, FrontEnd);
        InitSale();
        OnAfterInitSale(Rec, FrontEnd);

        FrontEnd.StartTransaction(Rec);
    end;


    local procedure InitSale()
    var
    begin
        Rec."Salesperson Code" := Setup.Salesperson();
        Rec."Register No." := POSUnit."No.";
        Rec."Sales Ticket No." := GetNextReceiptNo(Rec."Register No.");
        Rec.Date := Today();
        Rec."Start Time" := Time;
        Rec."Sale type" := Rec."Sale type"::Sale;

        if WorkDate() <> Today() then begin
            WorkDate := Today();
        end;

        Rec."User ID" := UserId;
        Rec.Insert(true);

        Rec.Validate("Customer No.", '');

        SaleLine.Init(Rec."Register No.", Rec."Sales Ticket No.", This, Setup, FrontEnd);
        PaymentLine.Init(Rec."Register No.", Rec."Sales Ticket No.", This, Setup, FrontEnd);

        Rec.FilterGroup := 2;
        Rec.SetRange("Register No.", Rec."Register No.");
        Rec.SetRange("Sales Ticket No.", Rec."Sales Ticket No.");
        Rec.FilterGroup := 0;

        IsModified := true;
    end;

    procedure GetNextReceiptNo(POSUnitNo: Text) ReceiptNo: Code[20]
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

    procedure GetContext(var SaleLineOut: Codeunit "NPR POS Sale Line"; var PaymentLineOut: Codeunit "NPR POS Payment Line")
    begin
        SaleLineOut := SaleLine;
        PaymentLineOut := PaymentLine;
    end;

    procedure ToDataset(var CurrDataSet: Codeunit "NPR Data Set"; DataSource: Codeunit "NPR Data Source"; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management")
    var
        TempRec: Record "NPR POS Sale" temporary;
        DataMgt: Codeunit "NPR POS Data Management";
    begin
        if not Initialized then begin
            TempRec."Register No." := POSUnit."No.";
            TempRec.Insert();
            DataMgt.RecordToDataSet(TempRec, CurrDataSet, DataSource, POSSession, FrontEnd);
            exit;
        end;

        DataMgt.RecordToDataSet(Rec, CurrDataSet, DataSource, POSSession, FrontEnd);
    end;

    procedure SetPosition(Position: Text): Boolean
    begin
        Rec.SetPosition(Position);
        exit(Rec.Find());
    end;

    procedure GetCurrentSale(var SalePOS: Record "NPR POS Sale")
    begin
        SalePOS.Copy(Rec);
    end;

    procedure GetLastSaleInfo(var LastSaleTotalOut: Decimal; var LastSalePaymentOut: Decimal; var LastSaleDateTextOut: Text; var LastSaleReturnAmountOut: Decimal; var LastReceiptNoOut: Text)
    var
        POSEntry: Record "NPR POS Entry";
        POSSalesLine: Record "NPR POS Entry Sales Line";
        POSPaymentLine: Record "NPR POS Entry Payment Line";
        NoMoreEntries: Boolean;
        LastSaleDateLbl: Label '%1 | %2', Locked = true;
    begin
        if not LastSaleRetrieved then begin
            POSEntry.SetCurrentKey("POS Store Code", "POS Unit No.");
            POSEntry.SetRange("POS Store Code", Rec."POS Store Code");
            POSEntry.SetRange("POS Unit No.", Rec."Register No.");
            if not POSEntry.Find('+') then
                exit;
            repeat
                LastSaleRetrieved := POSEntry."Entry Type" in [POSEntry."Entry Type"::"Direct Sale", POSEntry."Entry Type"::"Credit Sale"];
                if not LastSaleRetrieved then
                    NoMoreEntries := POSEntry.Next(-1) = 0;
            until NoMoreEntries or LastSaleRetrieved;
            if not LastSaleRetrieved then
                exit;

            LastReceiptNoOut := POSEntry."Fiscal No.";
            LastSaleDateTextOut := StrSubstNo(LastSaleDateLbl, POSEntry."Entry Date", POSEntry."Ending Time");

            POSSalesLine.SetRange("POS Entry No.", POSEntry."Entry No.");
            POSSalesLine.CalcSums("Amount Incl. VAT (LCY)");
            LastSaleTotalOut := POSSalesLine."Amount Incl. VAT (LCY)";

            LastSalePaymentOut := 0;
            LastSaleReturnAmountOut := 0;
            POSPaymentLine.SetRange("POS Entry No.", POSEntry."Entry No.");
            if POSPaymentLine.FindSet() then
                repeat
                    if POSPaymentLine."Amount (LCY)" > 0 then
                        LastSalePaymentOut += POSPaymentLine."Amount (LCY)"
                    else
                        LastSaleReturnAmountOut += POSPaymentLine."Amount (LCY)";
                until POSPaymentLine.Next() = 0;
        end;
    end;

    procedure GetModified() Result: Boolean
    begin
        Result := IsModified or (not Initialized);
        IsModified := false;
    end;

    procedure SetModified()
    begin
        IsModified := true;
    end;

    procedure GetTotals(var SalesAmountOut: Decimal; var PaidAmountOut: Decimal; var ChangeAmountOut: Decimal; var RoundingAmountOut: Decimal)
    var
        ReturnAmount: Decimal;
        SubTotal: Decimal;
    begin
        if Ended then begin
            SalesAmountOut := EndedSalesAmount;
            PaidAmountOut := EndedPaidAmount;
            ChangeAmountOut := EndedChangeAmount;
            RoundingAmountOut := EndedRoundingAmount;
        end else
            PaymentLine.CalculateBalance(SalesAmountOut, PaidAmountOut, ReturnAmount, SubTotal); //ReturnAmount & SubTotal are legacy. Cannot calculate true return without knowing payment type that ended sale.
    end;

    procedure Modify(RunTriggers: Boolean; ReturnValue: Boolean) Result: Boolean
    begin

        if ReturnValue then begin
            Result := Rec.Modify(RunTriggers);
            if Result then
                IsModified := true;
        end else begin
            Rec.Modify(RunTriggers);
            IsModified := true;
        end;
    end;

    procedure Refresh(var SalePOS: Record "NPR POS Sale")
    begin
        Rec.Copy(SalePOS);
        OnRefresh(Rec);
    end;

    procedure RefreshCurrent()
    begin
        Rec.Get(Rec."Register No.", Rec."Sales Ticket No.");
        OnRefresh(Rec);
    end;

    procedure SetDimension(DimCode: Code[20]; DimValue: Code[20])
    var
        Dim: Record Dimension;
        DimVal: Record "Dimension Value";
        TempDimSetEntry: Record "Dimension Set Entry" temporary;
        DimMgt: Codeunit DimensionManagement;
        OldDimSetID: Integer;
    begin
        if (not Dim.Get(DimCode)) then
            Error(SetDimension01, DimCode);

        if (not DimVal.Get(Dim.Code, DimValue)) then
            Error(SetDimension02, DimValue, DimCode);

        DimMgt.GetDimensionSet(TempDimSetEntry, Rec."Dimension Set ID");

        TempDimSetEntry.SetRange("Dimension Code", Dim.Code);
        if (TempDimSetEntry.FindFirst()) then;
        TempDimSetEntry."Dimension Code" := Dim.Code;
        TempDimSetEntry."Dimension Value Code" := DimVal.Code;
        TempDimSetEntry."Dimension Value ID" := DimVal."Dimension Value ID";

        if (not TempDimSetEntry.Insert()) then
            TempDimSetEntry.Modify();

        OldDimSetID := Rec."Dimension Set ID";
        Rec."Dimension Set ID" := TempDimSetEntry.GetDimensionSetID(TempDimSetEntry);
        DimMgt.UpdateGlobalDimFromDimSetID(Rec."Dimension Set ID", Rec."Shortcut Dimension 1 Code", Rec."Shortcut Dimension 2 Code");
        Rec.Modify();

        if (OldDimSetID <> Rec."Dimension Set ID") and Rec.SalesLinesExist() then
            Rec.UpdateAllLineDim(Rec."Dimension Set ID", OldDimSetID);

        RefreshCurrent();
    end;

    procedure SetShortcutDimCode1(DimensionValue: Code[20])
    begin
        Rec.Validate(Rec."Shortcut Dimension 1 Code", DimensionValue);
    end;

    procedure SetShortcutDimCode2(DimensionValue: Code[20])
    begin
        Rec.Validate(Rec."Shortcut Dimension 2 Code", DimensionValue);
    end;

    procedure TryEndSale(POSSession: Codeunit "NPR POS Session"): Boolean
    begin
        exit(TryEndSale(POSSession, true));
    end;

    procedure TryEndSale(POSSession: Codeunit "NPR POS Session"; StartNew: Boolean): Boolean
    var
        SalesAmount: Decimal;
        PaidAmount: Decimal;
        ReturnAmount: Decimal;
        SubTotal: Decimal;
    begin
        if not Initialized then
            Error('POS Sale codeunit not initialized. This is a programming bug, not a user error');
        RefreshCurrent();

        OnAttemptEndSale(Rec);

        PaymentLine.CalculateBalance(SalesAmount, PaidAmount, ReturnAmount, SubTotal);

        if SubTotal <> 0 then
            exit(false);

        EndSale(POSSession, StartNew);
        EndedSalesAmount := SalesAmount;
        EndedPaidAmount := PaidAmount;
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
    procedure TryEndDirectSaleWithBalancing(POSSession: Codeunit "NPR POS Session"; POSPaymentMethod: Record "NPR POS Payment Method"; ReturnPOSPaymentMethod: Record "NPR POS Payment Method"): Boolean
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
        if not Initialized then
            Error('POS Sale codeunit not initialized. This is a programming bug, not a user error');
        RefreshCurrent();

        OnAttemptEndSale(Rec);

        PaymentLine.CalculateBalance(SalesAmount, PaidAmount, ReturnAmount, SubTotal);

        if not IsPaymentValidForEndingSale(POSPaymentMethod, ReturnPOSPaymentMethod, SalesAmount, PaidAmount) then
            exit(false);

        ChangeAmount := POSGiveChange.InsertChange(Rec, ReturnPOSPaymentMethod, PaidAmount - SalesAmount);
        RoundAmount := POSRounding.InsertRounding(Rec, PaidAmount - SalesAmount - ChangeAmount);

        EndSale(POSSession, true);
        EndedSalesAmount := SalesAmount;
        EndedPaidAmount := PaidAmount;
        EndedChangeAmount := ChangeAmount;
        EndedRoundingAmount := RoundAmount;

        exit(true);
    end;

    local procedure EndSale(POSSession: Codeunit "NPR POS Session"; StartNew: Boolean)
    var
        SalePOS: Record "NPR POS Sale";
        SalesAmount: Decimal;
        PaidAmount: Decimal;
        ReturnAmount: Decimal;
        SubTotal: Decimal;
        StartTime: DateTime;
        RetailSalesDocMgt: Codeunit "NPR Sales Doc. Exp. Mgt.";
    begin
        PaymentLine.CalculateBalance(SalesAmount, PaidAmount, ReturnAmount, SubTotal);

        RetailSalesDocMgt.HandleLinkedDocuments(POSSession);

        OnBeforeEndSale(Rec);

        SalePOS := Rec;

        StartTime := CurrentDateTime;

        ValidateSaleBeforeEnd(Rec);

        EndSaleTransaction(SalePOS);
        Commit(); // Sale is now committed to POS entry

        Ended := true;

        LogStopwatch('FINISH_SALE', CurrentDateTime - StartTime);

        RunAfterEndSale(SalePOS); //Any error here would leave the front end with inconsistent state as view switch to new sale or login screen has not happened yet.

        if StartNew then begin
            SelectViewForEndOfSale(POSSession);
        end;
    end;

    [CommitBehavior(CommitBehavior::Error)]
    local procedure EndSaleTransaction(SalePOS: Record "NPR POS Sale")
    var
        POSCreateEntry: Codeunit "NPR POS Create Entry";
        SaleLinePOS: Record "NPR POS Sale Line";
    begin
        POSCreateEntry.Run(Rec);

        SaleLinePOS.SetRange("Register No.", SalePOS."Register No.");
        SaleLinePOS.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");
        SaleLinePOS.DeleteAll();
        Rec.Delete();
    end;

    local procedure IsPaymentValidForEndingSale(POSPaymentMethod: Record "NPR POS Payment Method"; ReturnPOSPaymentMethod: Record "NPR POS Payment Method"; SalesAmount: Decimal; PaidAmount: Decimal): Boolean
    var
        POSPaymentLine: Codeunit "NPR POS Payment Line";
    begin

        if not POSPaymentMethod."Auto End Sale" then
            exit(false);

        exit(POSPaymentLine.CalculateRemainingPaymentSuggestion(SalesAmount, PaidAmount, POSPaymentMethod, ReturnPOSPaymentMethod, false) = 0);
    end;

    procedure SelectViewForEndOfSale(POSSession: Codeunit "NPR POS Session")
    var
        POSViewProfile: Record "NPR POS View Profile";
    begin
        POSViewProfile.Init();
        Setup.GetPOSViewProfile(POSViewProfile);

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


    procedure ValidateSaleBeforeEnd(var Sale: Record "NPR POS Sale")
    var
        POSPaymentMethod: Record "NPR POS Payment Method";
        SaleLinePOS: Record "NPR POS Sale Line";
        Item: Record Item;
        SalespersonPurchaser: Record "Salesperson/Purchaser";
        ServiceItemGrp: Record "Service Item Group";
        ItemTrackingCode: Record "Item Tracking Code";
        ItemTrackingSetup: Record "Item Tracking Setup";
        SerialNoInfo: Record "Serial No. Information";
        ItemTrackingManagement: Codeunit "Item Tracking Management";
        ErrServiceNoCust: Label 'A Customer must be chosen, because the sale contains items which are to be transferred to service items.';
        saleNegCashSum: Decimal;
        POSInfoManagement: Codeunit "NPR POS Info Management";
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
        SaleLinePOS.SetCurrentKey("Register No.", "Sales Ticket No.", "Sale Type", Type);
        SaleLinePOS.SetRange("Register No.", Sale."Register No.");
        SaleLinePOS.SetRange("Sales Ticket No.", Sale."Sales Ticket No.");
        if SaleLinePOS.FindSet() then
            repeat
                SaleLinePOS.Validate("Shortcut Dimension 1 Code");
                SaleLinePOS.Validate("Shortcut Dimension 2 Code");
                if ((SaleLinePOS."Sale Type" = SaleLinePOS."Sale Type"::Sale) and (SaleLinePOS.Type = SaleLinePOS.Type::Item)) then begin
                    TotalItemAmountInclVat += SaleLinePOS."Amount Including VAT";
                end
            until SaleLinePOS.Next() = 0;

        if TotalItemAmountInclVat < 0 then begin
            saleNegCashSum := 0;
            Clear(SaleLinePOS);
            if SalespersonPurchaser.Get(Sale."Salesperson Code") then
                if SalespersonPurchaser."NPR Maximum Cash Returnsale" > 0 then begin
                    SaleLinePOS.SetCurrentKey("Register No.", "Sales Ticket No.", "Sale Type", Type);
                    SaleLinePOS.SetRange("Register No.", Sale."Register No.");
                    SaleLinePOS.SetRange("Sales Ticket No.", Sale."Sales Ticket No.");
                    SaleLinePOS.SetRange("Sale Type", SaleLinePOS."Sale Type"::Payment);
                    SaleLinePOS.SetRange(Type, SaleLinePOS.Type::Payment);
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
        SaleLinePOS.SetRange(Type, SaleLinePOS.Type::"BOM List");
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
            if (SaleLinePOS."Sale Type" = SaleLinePOS."Sale Type"::Sale) and
               (SaleLinePOS.Type = SaleLinePOS.Type::Item)
            then begin
                Item.Get(SaleLinePOS."No.");
                if Item."Service Item Group" <> '' then begin
                    ServiceItemGrp.Get(Item."Service Item Group");
                    if ServiceItemGrp."Create Service Item" and (Item."Costing Method" = Item."Costing Method"::Specific) and
                                                                (SaleLinePOS.Quantity > 0) then begin
                        if not ((Sale."Customer Type" = Sale."Customer Type"::Ord) and (Sale."Customer No." <> '')) then
                            Error(ErrServiceNoCust);
                        SaleLinePOS.TransferToService();
                    end;
                end;
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

            if (SaleLinePOS."Sale Type" = SaleLinePOS."Sale Type"::Sale)
                and not (SaleLinePOS.Type = SaleLinePOS.Type::"BOM List")
                and not (SaleLinePOS.Type = SaleLinePOS.Type::Comment) then begin
                SaleLinePOS.TestField("Gen. Bus. Posting Group");
                SaleLinePOS.TestField("Gen. Prod. Posting Group");
                SaleLinePOS.TestField("VAT Bus. Posting Group");
                SaleLinePOS.TestField("VAT Prod. Posting Group");
                Item.Get(SaleLinePOS."No.");
                if Item."Costing Method" = Item."Costing Method"::Specific then
                    SaleLinePOS.TestField("Serial No.");
            end;

            if (SaleLinePOS."Discount %" = 0) and
               (SaleLinePOS."Discount Type" = SaleLinePOS."Discount Type"::Manual) then begin
                SaleLinePOS."Discount Type" := SaleLinePOS."Discount Type"::" ";
                SaleLinePOS."Discount Code" := '';
            end;

            if SaleLinePOS."Location Code" = '' then begin
                SaleLinePOS."Location Code" := POSStore."Location Code";
            end;
            if SaleLinePOS."Shortcut Dimension 1 Code" = '' then
                SaleLinePOS.Validate("Shortcut Dimension 1 Code", NPRPOSUnit."Global Dimension 1 Code");

            if SaleLinePOS."Shortcut Dimension 2 Code" = '' then
                SaleLinePOS.Validate("Shortcut Dimension 2 Code", NPRPOSUnit."Global Dimension 2 Code");
        until SaleLinePOS.Next() = 0;

        POSInfoManagement.PostPOSInfo(Sale);
    end;

    procedure ResumeExistingSale(SalePOS_ToResume: Record "NPR POS Sale"; POSUnitIn: Record "NPR POS Unit"; FrontEndIn: Codeunit "NPR POS Front End Management"; SetupIn: Codeunit "NPR POS Setup"; ThisIn: Codeunit "NPR POS Sale")
    begin
        Initialized := true;

        FrontEnd := FrontEndIn;
        POSUnit := POSUnitIn;
        Setup := SetupIn;
        This := ThisIn;

        Clear(Rec);
        Clear(LastSaleRetrieved);

        OnBeforeResumeSale(Rec, FrontEnd);
        ResumeSale(SalePOS_ToResume);
        OnAfterResumeSale(Rec, FrontEnd);

        FrontEnd.StartTransaction(Rec);
    end;

    local procedure ResumeSale(SalePOS_ToResume: Record "NPR POS Sale")
    var
        SaleLinePOS: Record "NPR POS Sale Line";
        POSResumeSale: Codeunit "NPR POS Resume Sale Mgt.";
    begin
        Rec := SalePOS_ToResume;
        Rec."User ID" := UserId;

        Rec."Salesperson Code" := Setup.Salesperson();
        if Rec."Salesperson Code" <> SalePOS_ToResume."Salesperson Code" then
            Rec.CreateDim(
              DATABASE::"NPR POS Unit", Rec."Register No.",
              DATABASE::"NPR POS Store", Rec."POS Store Code",
              DATABASE::Job, Rec."Event No.",
              DATABASE::Customer, Rec."Customer No.",
              DATABASE::"Salesperson/Purchaser", Rec."Salesperson Code");

        Rec.Modify(true);

        SaleLine.Init(Rec."Register No.", Rec."Sales Ticket No.", This, Setup, FrontEnd);
        SaleLinePOS.SetRange("Register No.", Rec."Register No.");
        SaleLinePOS.SetRange("Sales Ticket No.", Rec."Sales Ticket No.");
        SaleLinePOS.SetFilter(Type, '<>%1', SaleLinePOS.Type::Payment);
        if not SaleLinePOS.IsEmpty then
            SaleLine.SetLast();

        PaymentLine.Init(Rec."Register No.", Rec."Sales Ticket No.", This, Setup, FrontEnd);

        Rec.FilterGroup := 2;
        Rec.SetRange("Register No.", Rec."Register No.");
        Rec.SetRange("Sales Ticket No.", Rec."Sales Ticket No.");
        Rec.FilterGroup := 0;

        IsModified := true;

        POSResumeSale.LogSaleResume(Rec, SalePOS_ToResume."Sales Ticket No.");
    end;

    procedure ResumeFromPOSQuote(POSQuoteNo: Integer): Boolean
    var
        SaleLinePOS: Record "NPR POS Sale Line";
        POSResumeSale: Codeunit "NPR POS Resume Sale Mgt.";
        Ok: Boolean;
    begin
        Ok := POSResumeSale.LoadFromPOSQuote(Rec, POSQuoteNo);
        if Ok then begin
            SaleLinePOS.SetRange("Register No.", Rec."Register No.");
            SaleLinePOS.SetRange("Sales Ticket No.", Rec."Sales Ticket No.");
            SaleLinePOS.SetFilter(Type, '<>%1', SaleLinePOS.Type::Payment);
            if not SaleLinePOS.IsEmpty then
                SaleLine.SetLast();

            IsModified := true;
        end;

        exit(Ok);
    end;

    local procedure RunAfterEndSale_OnRun(xRec: Record "NPR POS Sale") Success: Boolean;
    var
        POSAfterSaleExecution: Codeunit "NPR POS After Sale Execution";
    begin
        POSAfterSaleExecution.OnRunTypeSet(OnRunType::RunAfterEndSale);
        POSAfterSaleExecution.RecSet(Rec);
        POSAfterSaleExecution.PosSaleCodeunitSet(This);
        POSAfterSaleExecution.OnRunXRecSet(xRec);
        Commit();
        Success := POSAfterSaleExecution.Run();
        POSAfterSaleExecution.OnRunTypeSet(OnRunType::Undefined);
    end;

    local procedure RunAfterEndSale(xRec: Record "NPR POS Sale")
    var
        Success: Boolean;
    begin
        //Any error at this time would leave the POS with inconsistent front-end state.
        ClearLastError();
        Success := RunAfterEndSale_OnRun(xRec);
        if not Success then
            Message(ERROR_AFTER_END_SALE, GetLastErrorText);
    end;

    local procedure LogStopwatch(Keyword: Text; Duration: Duration)
    var
        POSSession: Codeunit "NPR POS Session";
        POSFrontEnd: Codeunit "NPR POS Front End Management";
    begin
        if not POSSession.IsActiveSession(POSFrontEnd) then
            exit;
        POSFrontEnd.GetSession(POSSession);
        POSSession.AddServerStopwatch(Keyword, Duration);
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
    procedure OnAfterEndSale(SalePOS: Record "NPR POS Sale")
    begin
    end;

    [IntegrationEvent(TRUE, false)]
    local procedure OnAttemptEndSale(SalePOS: Record "NPR POS Sale")
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnRefresh(var SalePOS: Record "NPR POS Sale")
    begin
    end;
    #endregion

    #region OnFinishSale Workflow


    local procedure OnFinishSaleCode(): Code[20]
    begin
        exit('FINISH_SALE');
    end;

    [EventSubscriber(ObjectType::Table, 6150729, 'OnDiscoverPOSSalesWorkflows', '', true, true)]
    local procedure OnDiscoverPOSWorkflows(var Sender: Record "NPR POS Sales Workflow")
    begin
        Sender.DiscoverPOSSalesWorkflow(OnFinishSaleCode(), Text000, CurrCodeunitId(), 'OnFinishSale');
    end;

    local procedure CurrCodeunitId(): Integer
    begin
        exit(CODEUNIT::"NPR POS Sale");
    end;

    local procedure InvokeOnFinishSaleSubscribers_OnRun(POSSalesWorkflowStep: Record "NPR POS Sales Workflow Step")
    var
        POSAfterSaleExecution: Codeunit "NPR POS After Sale Execution";
    begin
        POSAfterSaleExecution.OnRunTypeSet(OnRunType::OnFinishSale);
        POSAfterSaleExecution.OnRunPOSSalesWorkflowStepSet(POSSalesWorkflowStep);
        POSAfterSaleExecution.RecSet(Rec);
        POSAfterSaleExecution.PosSaleCodeunitSet(This);
        if POSAfterSaleExecution.Run() then;
        POSAfterSaleExecution.OnRunTypeSet(OnRunType::Undefined);
    end;

    procedure InvokeOnFinishSaleWorkflow(SalePOS: Record "NPR POS Sale")
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
    procedure OnFinishSale(POSSalesWorkflowStep: Record "NPR POS Sales Workflow Step"; SalePOS: Record "NPR POS Sale")
    begin
    end;

    #endregion
}
