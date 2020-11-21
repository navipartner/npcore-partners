codeunit 6150705 "NPR POS Sale"
{
    trigger OnRun()
    begin
        case OnRunType of
            // If somebody accidentally (or even intentionall) calls this codeunit without defining what kind of
            // run type is needed, then codeunit simply exits
            OnRunType::Undefined:
                exit;

            OnRunType::RunAfterEndSale:
                begin
                    InvokeOnFinishSaleWorkflow(Rec);
                    Commit;
                    OnAfterEndSale(OnRunXRec);
                    Commit;
                end;

            OnRunType::OnFinishSale:
                begin
                    OnFinishSale(OnRunPOSSalesWorkflowStep, Rec);
                    Commit;
                end;

        end;
    end;

    var
        Rec: Record "NPR Sale POS";
        Register: Record "NPR Register";
        RetailSetup: Record "NPR Retail Setup";
        This: Codeunit "NPR POS Sale";
        Setup: Codeunit "NPR POS Setup";
        FrontEnd: Codeunit "NPR POS Front End Management";
        SaleLine: Codeunit "NPR POS Sale Line";
        PaymentLine: Codeunit "NPR POS Payment Line";
        IsModified: Boolean;
        Initialized: Boolean;
        Ended: Boolean;
        "--- Last Sale Information ---": Integer;
        LastSaleRetrieved: Boolean;
        LastSaleTotal: Decimal;
        LastSalePayment: Decimal;
        LastSaleDateText: Text;
        LastSaleReturnAmount: Decimal;
        LastReceiptNo: Text;
        PaymentTypeNotFound: Label '%1 %2 for register %3 was not found.';
        Text10600003: Label 'Sale temporarily on hold';
        TaxFreePromptCaption: Label 'Issue tax free voucher for this sale?';
        SetDimension01: Label 'Dimension %1 does not exist';
        SetDimension02: Label 'Dimension Value %1 does not exist for dimension %2';
        "--- Ended Sale Information ---": Integer;
        EndedSalesAmount: Decimal;
        EndedPaidAmount: Decimal;
        EndedChangeAmount: Decimal;
        EndedRoundingAmount: Decimal;
        Text000: Label 'During End Sale, after Audit Roll Insert, before Audit Roll Posting';
        ERROR_AFTER_END_SALE: Label 'An error occurred after the sale ended: %1';
        IsMock: Boolean;

        // OnRun helper globals
        OnRunType: Option Undefined,RunAfterEndSale,OnFinishSale;
        OnRunPOSSalesWorkflowStep: Record "NPR POS Sales Workflow Step";
        OnRunXRec: Record "NPR Sale POS";

    procedure InitializeAtLogin(RegisterIn: Record "NPR Register"; SetupIn: Codeunit "NPR POS Setup")
    begin
        Register := RegisterIn;
        Setup := SetupIn;

        OnAfterInitializeAtLogin(Register);
    end;

    procedure InitializeNewSale(RegisterIn: Record "NPR Register"; FrontEndIn: Codeunit "NPR POS Front End Management"; SetupIn: Codeunit "NPR POS Setup"; ThisIn: Codeunit "NPR POS Sale")
    begin
        Initialized := true;

        FrontEnd := FrontEndIn;
        Register := RegisterIn;
        Setup := SetupIn;
        This := ThisIn;

        RetailSetup.Get();

        Clear(Rec);
        Clear(LastSaleRetrieved);

        OnBeforeInitSale(Rec, FrontEnd);
        InitSale();
        OnAfterInitSale(Rec, FrontEnd);

        if not IsMock then
            FrontEnd.StartTransaction(Rec);
    end;

    local procedure CheckInit(WithError: Boolean): Boolean
    begin
        if WithError and (not Initialized) then
            Error('Codeunit POS Sale was invoked in uninitialized state. This is a programming bug, not a user error');
        exit(Initialized);
    end;

    local procedure InitSale()
    var
        FormCode: Codeunit "NPR Retail Form Code";
        TouchScreenFunctions: Codeunit "NPR Touch Screen - Func.";
    begin
        with Rec do begin
            "Salesperson Code" := Setup.Salesperson();
            "Register No." := Register."Register No.";
            Register.TestField("Return Payment Type");
            "Sales Ticket No." := FormCode.FetchSalesTicketNumber("Register No.");
            Date := Today;
            "Start Time" := Time;
            "Sale type" := "Sale type"::Sale;
            "Saved Sale" := false;
            TouchScreen := true;

            TouchScreenFunctions.TestSalesDate;

            UpdateSaleDeviceID(Rec);
            Insert(true);

            Validate("Customer No.", '');

            SaleLine.Init("Register No.", "Sales Ticket No.", This, Setup, FrontEnd);
            PaymentLine.Init("Register No.", "Sales Ticket No.", This, Setup, FrontEnd);

            // RetailSalesDocMgt.Reset(); // TODO

            FilterGroup := 2;
            SetRange("Register No.", "Register No.");
            SetRange("Sales Ticket No.", "Sales Ticket No.");
            FilterGroup := 0;

            IsModified := true;
        end;

    end;

    procedure GetContext(var SaleLineOut: Codeunit "NPR POS Sale Line"; var PaymentLineOut: Codeunit "NPR POS Payment Line")
    begin
        SaleLineOut := SaleLine;
        PaymentLineOut := PaymentLine;
    end;

    procedure ToDataset(var CurrDataSet: Codeunit "NPR Data Set"; DataSource: Codeunit "NPR Data Source"; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management")
    var
        TempRec: Record "NPR Sale POS" temporary;
        DataMgt: Codeunit "NPR POS Data Management";
    begin
        if not Initialized then begin
            TempRec."Register No." := Register."Register No.";
            TempRec.Insert;
            DataMgt.RecordToDataSet(TempRec, CurrDataSet, DataSource, POSSession, FrontEnd);
            exit;
        end;

        DataMgt.RecordToDataSet(Rec, CurrDataSet, DataSource, POSSession, FrontEnd);
    end;

    procedure SetPosition(Position: Text): Boolean
    begin
        Rec.SetPosition(Position);
        exit(Rec.Find);
    end;

    procedure GetCurrentSale(var SalePOS: Record "NPR Sale POS")
    begin
        SalePOS.Copy(Rec);
    end;

    procedure GetLastSaleInfo(var LastSaleTotalOut: Decimal; var LastSalePaymentOut: Decimal; var LastSaleDateTextOut: Text; var LastSaleReturnAmountOut: Decimal; var LastReceiptNoOut: Text)
    var
        TouchScreenFunctions: Codeunit "NPR Touch Screen - Func.";
    begin
        if not LastSaleRetrieved then
            TouchScreenFunctions.GetLastSaleInfo(
              Register."Register No.",
              LastSaleTotal,
              LastSalePayment,
              LastSaleDateText,
              LastSaleReturnAmount,
              LastReceiptNo);
        LastSaleRetrieved := true;

        LastSaleTotalOut := LastSaleTotal;
        LastSalePaymentOut := LastSalePayment;
        LastSaleDateTextOut := LastSaleDateText;
        LastSaleReturnAmountOut := LastSaleReturnAmount;
        LastReceiptNoOut := LastReceiptNo;
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

    procedure Refresh(var SalePOS: Record "NPR Sale POS")
    begin
        Rec.Copy(SalePOS);
        OnRefresh(Rec);
    end;

    procedure RefreshCurrent()
    var
        LocalSaleLinePOS: Record "NPR Sale Line POS";
    begin
        Rec.Get(Rec."Register No.", Rec."Sales Ticket No.");
        OnRefresh(Rec);
    end;

    procedure SetDimension(DimCode: Code[20]; DimValue: Code[20])
    var
        Dim: Record Dimension;
        DimVal: Record "Dimension Value";
        DimSetEntryTmp: Record "Dimension Set Entry" temporary;
        DimMgt: Codeunit DimensionManagement;
        DimValues: Page "Dimension Values";
        OldDimSetID: Integer;
    begin
        if (not Dim.Get(DimCode)) then
            Error(SetDimension01, DimCode);

        if (not DimVal.Get(Dim.Code, DimValue)) then
            Error(SetDimension02, DimValue, DimCode);

        DimMgt.GetDimensionSet(DimSetEntryTmp, Rec."Dimension Set ID");

        DimSetEntryTmp.SetRange("Dimension Code", Dim.Code);
        if (DimSetEntryTmp.FindFirst()) then;
        DimSetEntryTmp."Dimension Code" := Dim.Code;
        DimSetEntryTmp."Dimension Value Code" := DimVal.Code;
        DimSetEntryTmp."Dimension Value ID" := DimVal."Dimension Value ID";

        if (not DimSetEntryTmp.Insert()) then
            DimSetEntryTmp.Modify();

        OldDimSetID := Rec."Dimension Set ID";
        Rec."Dimension Set ID" := DimSetEntryTmp.GetDimensionSetID(DimSetEntryTmp);
        DimMgt.UpdateGlobalDimFromDimSetID(Rec."Dimension Set ID", Rec."Shortcut Dimension 1 Code", Rec."Shortcut Dimension 2 Code");
        Rec.Modify();

        if (OldDimSetID <> Rec."Dimension Set ID") and Rec.SalesLinesExist then
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
        exit(TryEndSale2(POSSession, true));
    end;

    procedure TryEndSale2(POSSession: Codeunit "NPR POS Session"; StartNew: Boolean): Boolean
    var
        ReturnPaymentType: Record "NPR Payment Type POS";
        SalePOS: Record "NPR Sale POS";
        SalesAmount: Decimal;
        PaidAmount: Decimal;
        ReturnAmount: Decimal;
        SubTotal: Decimal;
        RetailFormCode: Codeunit "NPR Retail Form Code";
        TempSalesHeader: Record "Sales Header" temporary;
        EmptySelf: Codeunit "NPR POS Sale";
        POSStore: Record "NPR POS Store";
        POSEntry: Record "NPR POS Entry";
        RoundAmount: Decimal;
        ChangeAmount: Decimal;
        POSGiveChange: Codeunit "NPR POS Give Change";
        POSRounding: Codeunit "NPR POS Rounding";
    begin
        if not Initialized then
            exit(false);
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

    procedure TryEndSaleWithBalancing(POSSession: Codeunit "NPR POS Session"; PaymentType: Record "NPR Payment Type POS"; ReturnPaymentType: Record "NPR Payment Type POS"): Boolean
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
        //PaymentType: The payment type just used in sale, triggering this end attempt.
        //ReturnPaymentType: The payment type to use for round & change in case of overtender.

        if not Initialized then
            exit(false);
        RefreshCurrent();

        OnAttemptEndSale(Rec);

        PaymentLine.CalculateBalance(SalesAmount, PaidAmount, ReturnAmount, SubTotal);

        if not IsPaymentValidForEndingSale(PaymentType, ReturnPaymentType, SalesAmount, PaidAmount) then
            exit(false);

        ChangeAmount := POSGiveChange.InsertChange(Rec, ReturnPaymentType, PaidAmount - SalesAmount);
        RoundAmount := POSRounding.InsertRounding(Rec, ReturnPaymentType, PaidAmount - SalesAmount - ChangeAmount);

        EndSale(POSSession, true);
        EndedSalesAmount := SalesAmount;
        EndedPaidAmount := PaidAmount;
        EndedChangeAmount := ChangeAmount;
        EndedRoundingAmount := RoundAmount;

        exit(true);
    end;

    local procedure EndSale(POSSession: Codeunit "NPR POS Session"; StartNew: Boolean)
    var
        SalePOS: Record "NPR Sale POS";
        SalesAmount: Decimal;
        PaidAmount: Decimal;
        ReturnAmount: Decimal;
        SubTotal: Decimal;
        TempSalesHeader: Record "Sales Header" temporary;
        RetailFormCode: Codeunit "NPR Retail Form Code";
        StartTime: DateTime;
        RetailSalesDocMgt: Codeunit "NPR Sales Doc. Exp. Mgt.";
    begin

        PaymentLine.CalculateBalance(SalesAmount, PaidAmount, ReturnAmount, SubTotal);

        RetailSalesDocMgt.HandleLinkedDocuments(POSSession);

        OnBeforeEndSale(Rec);

        SalePOS := Rec;

        StartTime := CurrentDateTime;
        RetailFormCode.FinishSale(Rec, SubTotal, 0, true, TempSalesHeader, SalesAmount);
        Commit;
        Ended := true;

        LogStopwatch('FINISH_SALE', CurrentDateTime - StartTime);

        RunAfterEndSale(SalePOS);

        if StartNew then begin
            SelectViewForEndOfSale(POSSession);
        end;
    end;

    local procedure IsPaymentValidForEndingSale(PaymentType: Record "NPR Payment Type POS"; ReturnPaymentType: Record "NPR Payment Type POS"; SalesAmount: Decimal; PaidAmount: Decimal): Boolean
    var
        POSPaymentLine: Codeunit "NPR POS Payment Line";
    begin

        if not PaymentType."Auto End Sale" then
            exit(false);

        exit(POSPaymentLine.CalculateRemainingPaymentSuggestion(SalesAmount, PaidAmount, PaymentType, ReturnPaymentType, false) = 0);
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

    procedure LoadSavedSale(var SalePOS: Record "NPR Sale POS")
    var
        SaleLinePOS: Record "NPR Sale Line POS";
        SaleLinePOS1: Record "NPR Sale Line POS";
        GlobalSalePOS: Record "NPR Global Sale POS";
        PaymentTypePOS: Record "NPR Payment Type POS";
        LineIsGiftVoucher: Boolean;
        Value: Integer;
        SavedGiftVoucher: Record "NPR Gift Voucher";
        RetailFormCode: Codeunit "NPR Retail Form Code";
        Text0000001: Label 'Transferred to location receipt %1';
        POSInfoManagement: Codeunit "NPR POS Info Management";
        AmountExclVAT: Decimal;
        VATAmount: Decimal;
        TotalAmount: Decimal;
    begin
        OnBeforeLoadSavedSale(SalePOS."Sales Ticket No.", Rec."Sales Ticket No.");

        with Rec do begin
            "Customer No." := SalePOS."Customer No.";
            "Customer Type" := SalePOS."Customer Type";

            "Customer Name" := SalePOS."Customer Name";
            Name := SalePOS.Name;
            Address := SalePOS.Address;
            "Address 2" := SalePOS."Address 2";
            "Post Code" := SalePOS."Post Code";
            City := SalePOS.City;
            "Contact No." := SalePOS."Contact No.";
            Reference := SalePOS.Reference;

            Date := Today;
            "Start Time" := Time;
            "External Document No." := SalePOS."External Document No.";
            "Prices Including VAT" := SalePOS."Prices Including VAT";
            Modify(true);

            POSInfoManagement.RetrieveSavedLines(Rec, SalePOS);

            SaleLinePOS.SetRange("Register No.", SalePOS."Register No.");
            SaleLinePOS.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");
            if SaleLinePOS.FindSet then
                repeat
                    LineIsGiftVoucher := false;
                    if (Value <> SaleLinePOS."Sale Type"::Sale) and
                       (SaleLinePOS."Gift Voucher Ref." = '') then begin
                        if SaleLinePOS."Sale Type" = SaleLinePOS."Sale Type"::Payment then begin
                            PaymentTypePOS.SetRange("Processing Type", PaymentTypePOS."Processing Type"::"Gift Voucher");
                            PaymentTypePOS.SetRange("G/L Account No.", SaleLinePOS."No.");
                            if not PaymentTypePOS.Find('-') then
                                Value := SaleLinePOS."Sale Type"
                            else
                                LineIsGiftVoucher := true;
                        end else
                            Value := SaleLinePOS."Sale Type";
                    end;
                    SaleLinePOS1 := SaleLinePOS;
                    SaleLinePOS1."Register No." := "Register No.";
                    SaleLinePOS1."Sales Ticket No." := "Sales Ticket No.";
                    SaleLinePOS1.Date := Date;

                    Clear(SaleLinePOS1."Customer Location No.");

                    if SaleLinePOS1.Quantity < 0 then
                        SaleLinePOS1.Insert(false)
                    else
                        SaleLinePOS1.Insert(true);
                    if (SaleLinePOS."Gift Voucher Ref." <> '') or LineIsGiftVoucher then begin
                        SaleLinePOS1.Description := SaleLinePOS.Description;
                        if Value = -1 then
                            Value := SaleLinePOS."Sale Type"::Sale;
                        SaleLinePOS1.Modify;
                    end;
                    if SaleLinePOS1."Gift Voucher Ref." <> '' then begin
                        if SavedGiftVoucher.Get(SaleLinePOS1."Gift Voucher Ref.") then begin
                            SavedGiftVoucher."Sales Ticket No." := SaleLinePOS1."Sales Ticket No.";
                            SavedGiftVoucher."Issuing Sales Ticket No." := SaleLinePOS1."Sales Ticket No.";
                            SavedGiftVoucher.Modify(false);
                        end
                    end;
                until SaleLinePOS.Next = 0;

            GlobalSalePOS.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");
            GlobalSalePOS.ModifyAll("Sales Ticket No.", "Sales Ticket No.");

            SaleLinePOS.ModifyAll("From Selection", false);
            SaleLinePOS.DeleteAll;

            SalePOS.SetRange("Register No.", SalePOS."Register No.");
            SalePOS.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");
            SalePOS.Delete(true);

            SaleLine.Init("Register No.", "Sales Ticket No.", This, Setup, FrontEnd);
            SaleLine.RefreshCurrent();
            SaleLine.CalculateBalance(AmountExclVAT, VATAmount, TotalAmount);

            PaymentLine.Init("Register No.", "Sales Ticket No.", This, Setup, FrontEnd);
        end;

        OnAfterLoadSavedSale(SalePOS."Sales Ticket No.", Rec."Sales Ticket No.");
    end;

    procedure SaveSale()
    var
        FormCode: Codeunit "NPR Retail Form Code";
        TouchScreenFunctions: Codeunit "NPR Touch Screen - Func.";
        EmptySelf: Codeunit "NPR POS Sale";
    begin

        Rec."Saved Sale" := true;
        Rec.Modify;

        FormCode.AuditRollCancelSale(Rec, Text10600003);
        InitializeNewSale(Register, FrontEnd, Setup, EmptySelf);
    end;

    procedure ResumeExistingSale(SalePOS_ToResume: Record "NPR Sale POS"; RegisterIn: Record "NPR Register"; FrontEndIn: Codeunit "NPR POS Front End Management"; SetupIn: Codeunit "NPR POS Setup"; ThisIn: Codeunit "NPR POS Sale")
    var
        SalePOS: Record "NPR Sale POS";
    begin
        Initialized := true;

        FrontEnd := FrontEndIn;
        Register := RegisterIn;
        Setup := SetupIn;
        This := ThisIn;

        RetailSetup.Get();

        Clear(Rec);
        Clear(LastSaleRetrieved);

        OnBeforeResumeSale(Rec, FrontEnd);
        ResumeSale(SalePOS_ToResume);
        OnAfterResumeSale(Rec, FrontEnd);

        if not IsMock then
            FrontEnd.StartTransaction(Rec);
    end;

    local procedure ResumeSale(SalePOS_ToResume: Record "NPR Sale POS")
    var
        SaleLinePOS: Record "NPR Sale Line POS";
        POSResumeSale: Codeunit "NPR POS Resume Sale Mgt.";
        TouchScreenFunctions: Codeunit "NPR Touch Screen - Func.";
    begin
        Rec := SalePOS_ToResume;
        with Rec do begin
            Register.TestField("Return Payment Type");
            UpdateSaleDeviceID(Rec);

            "Salesperson Code" := Setup.Salesperson();
            if "Salesperson Code" <> SalePOS_ToResume."Salesperson Code" then
                CreateDim(
                  DATABASE::"NPR POS Unit", "Register No.",
                  DATABASE::"NPR POS Store", "POS Store Code",
                  DATABASE::Job, "Event No.",
                  DATABASE::Customer, "Customer No.",
                  DATABASE::"Salesperson/Purchaser", "Salesperson Code");

            Modify(true);

            SaleLine.Init("Register No.", "Sales Ticket No.", This, Setup, FrontEnd);
            SaleLinePOS.SetRange("Register No.", "Register No.");
            SaleLinePOS.SetRange("Sales Ticket No.", "Sales Ticket No.");
            SaleLinePOS.SetFilter(Type, '<>%1', SaleLinePOS.Type::Payment);
            if not SaleLinePOS.IsEmpty then
                SaleLine.SetLast();

            PaymentLine.Init("Register No.", "Sales Ticket No.", This, Setup, FrontEnd);

            FilterGroup := 2;
            SetRange("Register No.", "Register No.");
            SetRange("Sales Ticket No.", "Sales Ticket No.");
            FilterGroup := 0;

            IsModified := true;

            POSResumeSale.LogSaleResume(Rec, SalePOS_ToResume."Sales Ticket No.");
        end;
    end;

    procedure ResumeFromPOSQuote(POSQuoteNo: Integer): Boolean
    var
        SaleLinePOS: Record "NPR Sale Line POS";
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

    local procedure UpdateSaleDeviceID(var SalePOS: Record "NPR Sale POS")
    var
        POSUnitIdentity: Record "NPR POS Unit Identity";
    begin
        Setup.GetPOSUnitIdentity(POSUnitIdentity);
        with SalePOS do begin
            if POSUnitIdentity."Entry No." = 0 then
                "Device ID" := ''  //Configured using temporary pos unit identity
            else
                "Device ID" := POSUnitIdentity."Device ID";
            "Host Name" := POSUnitIdentity."Host Name";
            "User ID" := POSUnitIdentity."User ID";
        end;
    end;

    local procedure RunAfterEndSale_OnRun(xRec: Record "NPR Sale POS") Success: Boolean;
    begin
        OnRunType := OnRunType::RunAfterEndSale;
        OnRunXRec := xRec;
        Commit();
        Success := This.Run();
        OnRunType := OnRunType::Undefined;
    end;

    local procedure RunAfterEndSale(xRec: Record "NPR Sale POS")
    var
        Success: Boolean;
    begin
        //Any error at this time would leave the POS with inconsistent front-end state.
        ClearLastError;
        Success := RunAfterEndSale_OnRun(xRec);
        if not Success then
            Message(ERROR_AFTER_END_SALE, GetLastErrorText);

        ClearLastError;
        if not CODEUNIT.Run(CODEUNIT::"NPR POS End Sale Post Proc.", Rec) then
            Message(ERROR_AFTER_END_SALE, GetLastErrorText);
    end;

    local procedure LogStopwatch(Keyword: Text; Duration: Duration)
    var
        POSSession: Codeunit "NPR POS Session";
        FrontEnd: Codeunit "NPR POS Front End Management";
    begin
        if not POSSession.IsActiveSession(FrontEnd) then
            exit;
        FrontEnd.GetSession(POSSession);
        POSSession.AddServerStopwatch(Keyword, Duration);
    end;

    local procedure "---Events---"()
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterInitializeAtLogin(Register: Record "NPR Register")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeInitSale(SaleHeader: Record "NPR Sale POS"; FrontEnd: Codeunit "NPR POS Front End Management")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterInitSale(SaleHeader: Record "NPR Sale POS"; FrontEnd: Codeunit "NPR POS Front End Management")
    begin
    end;

    [IntegrationEvent(TRUE, false)]
    local procedure OnBeforeLoadSavedSale(OriginalSalesTicketNo: Code[20]; NewSalesTicketNo: Code[20])
    begin
    end;

    [IntegrationEvent(TRUE, false)]
    local procedure OnAfterLoadSavedSale(OriginalSalesTicketNo: Code[20]; NewSalesTicketNo: Code[20])
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeResumeSale(SalePOS: Record "NPR Sale POS"; FrontEnd: Codeunit "NPR POS Front End Management")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterResumeSale(SalePOS: Record "NPR Sale POS"; FrontEnd: Codeunit "NPR POS Front End Management")
    begin
    end;

    [IntegrationEvent(TRUE, false)]
    local procedure OnBeforeEndSale(SaleHeader: Record "NPR Sale POS")
    begin
    end;

    [IntegrationEvent(TRUE, false)]
    local procedure OnAfterEndSale(SalePOS: Record "NPR Sale POS")
    begin
    end;

    [IntegrationEvent(TRUE, false)]
    local procedure OnAttemptEndSale(SalePOS: Record "NPR Sale POS")
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnRefresh(var SalePOS: Record "NPR Sale POS")
    begin
    end;

    local procedure "--- OnFinishSale Workflow"()
    begin
    end;

    [EventSubscriber(ObjectType::Table, 6014400, 'OnAfterInsertEvent', '', true, true)]
    local procedure OnAfterInsertRetailSetup(var Rec: Record "NPR Retail Setup"; RunTrigger: Boolean)
    var
        POSSalesWorkflow: Record "NPR POS Sales Workflow";
    begin
        POSSalesWorkflow.OnDiscoverPOSSalesWorkflows();
        if POSSalesWorkflow.FindSet then
            repeat
                POSSalesWorkflow.InitPOSSalesWorkflowSteps();
            until POSSalesWorkflow.Next = 0;
    end;

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
    begin
        OnRunPOSSalesWorkflowStep := POSSalesWorkflowStep;
        OnRunType := OnRunType::OnFinishSale;
        if This.Run() then;
        OnRunType := OnRunType::Undefined;
    end;

    procedure InvokeOnFinishSaleWorkflow(SalePOS: Record "NPR Sale POS")
    var
        POSUnit: Record "NPR POS Unit";
        POSSalesWorkflowSetEntry: Record "NPR POS Sales WF Set Entry";
        POSSalesWorkflowStep: Record "NPR POS Sales Workflow Step";
        StartTime: DateTime;
    begin
        StartTime := CurrentDateTime;
        POSSalesWorkflowStep.SetCurrentKey("Sequence No.");
        POSSalesWorkflowStep.SetFilter("Set Code", '=%1', '');
        if POSUnit.Get(SalePOS."Register No.") and (POSUnit."POS Sales Workflow Set" <> '') and POSSalesWorkflowSetEntry.Get(POSUnit."POS Sales Workflow Set", OnFinishSaleCode()) then
            POSSalesWorkflowStep.SetRange("Set Code", POSSalesWorkflowSetEntry."Set Code");
        POSSalesWorkflowStep.SetRange("Workflow Code", OnFinishSaleCode());
        POSSalesWorkflowStep.SetRange(Enabled, true);
        if not POSSalesWorkflowStep.FindSet then
            exit;

        Refresh(SalePOS);
        repeat
            InvokeOnFinishSaleSubscribers_OnRun(POSSalesWorkflowStep);
        until POSSalesWorkflowStep.Next = 0;

        LogStopwatch('FINISH_SALE_WORKFLOWS', CurrentDateTime - StartTime);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnFinishSale(POSSalesWorkflowStep: Record "NPR POS Sales Workflow Step"; SalePOS: Record "NPR Sale POS")
    begin
    end;

    procedure SetMockMode()
    begin
        IsMock := true;
    end;
}
