codeunit 6150705 "POS Sale"
{
    // RecorNPR5.32/NPKNAV/20170526  CASE 270909 Transport NPR5.32 - 26 May 2017
    // NPR5.32.11/CLVA/20170623  CASE 279495 Added event OnBeforeEndSale, On
    // NPR5.34/TSA /20170705  CASE 283019 Added SetDimension, SetGlobalDimension1 and SetGlobalDimension2
    // NPR5.34/TSA /20170710  CASE 279495 Shifted OnBeforeEndSale to before sale is ended, and added OnAfterEndSales in EndSale
    // NPR5.34/TSA /20170710  CASE 279495 Shifted change view function to StartPOSSession when sale should navigate to login view.
    // NPR5.36/MHA /20170831  CASE 288988 Added SalePOS parameter to OnAfterEndSale()
    // NPR5.37/BR  /20171018  CASE 293711 Moved balancing calculation for registering Change Given
    // NPR5.37.03/MMV /20171122  CASE 296642 Renamed EndSale() to TryEndSaleWithoutPayment().
    //                                       Added TryEndSaleWithPayment().
    // NPR5.38/MMV /20171212  CASE 299509 Update line date when loading sale.
    // NPR5.38/MMV /20180108  CASE 300957 Rounding fix
    // NPR5.38/MHA /20180105  CASE 301053 Renamed parameter DataSet to CurrDataSet in function ToDataSet() as the word is reserved in V2
    // NPR5.38/MMV /20180111  CASE 298025 Added accessors for sale totals, both when active and ended.
    // NPR5.38/MHA /20180115  CASE 302221 Added Contact information to LoadSavedSale()
    // NPR5.39/MHA /20180202  CASE 302779 Added OnFinishSale POS Workflow
    // NPR5.39/BR  /20180215  CASE 305016 Added Fiscal No. determination
    // NPR5.40/MMV /20180115 CASE 293106 Refactored tax free module.
    // NPR5.40/MMV /20180316  CASE 308457 Moved fiscal no. pull inside pos entry create transaction.
    //                                    Wrapped all functions after end sale in asserterror to prevent inconsistency.
    // NPR5.43/MMV /20180531 CASE 315838 Added stopwatch functionality
    // NPR5.44/JDH /20180731  CASE 323499 Changed all functions to be External
    // NPR5.45/TSA /20180803 CASE 323780 Added function SetModified() to be able to force a data driver refresh without modifying the record.
    // NPR5.45/MMV /20180808 CASE 323975 Refresh Rec before end sale attempt.
    // NPR5.45/MHA /20180820 CASE 321266 Extended POS Sales Workflow with Set functionality
    // NPR5.46/MHA /20180928 CASE 329523 Added Publisher function OnRefresh()
    // NPR5.48/JDH /20181204 CASE 335967 Possible to call this object in Mock Mode, to allow the test framework to run without a Major Tom session
    // NPR5.50/MMV /20190328 CASE 300557 Added sales document handling
    //                                   Added init handling
    // NPR5.53/MMV /20191106 CASE 376362 Added explicit pos entry auto post invoke.
    // NPR5.53/MHA /20190114 CASE 384841 Signature updated for CalculateRemainingPaymentSuggestion()
    // NPR5.54/ALPO/20200203 CASE 364658 Resume POS Sale
    // NPR5.54/MMV /20200217 CASE 364658 Added configurable start of new sale to allow business logic first.
    // NPR5.55/TSA /20200527 CASE 406862 Refactored SelectViewForEndOfSale()
    // NPR5.55/ALPO/20200720 CASE 391678 Log sale resume to POS Entry


    trigger OnRun()
    begin
    end;

    var
        Rec: Record "Sale POS";
        Register: Record Register;
        RetailSetup: Record "Retail Setup";
        This: Codeunit "POS Sale";
        Setup: Codeunit "POS Setup";
        FrontEnd: Codeunit "POS Front End Management";
        SaleLine: Codeunit "POS Sale Line";
        PaymentLine: Codeunit "POS Payment Line";
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

        procedure InitializeAtLogin(RegisterIn: Record Register;SetupIn: Codeunit "POS Setup")
    begin
        Register := RegisterIn;
        Setup := SetupIn;

        OnAfterInitializeAtLogin(Register);
    end;

        procedure InitializeNewSale(RegisterIn: Record Register;FrontEndIn: Codeunit "POS Front End Management";SetupIn: Codeunit "POS Setup";ThisIn: Codeunit "POS Sale")
    var
        ViewType: DotNet npNetViewType0;
    begin
        Initialized := true;

        FrontEnd := FrontEndIn;
        Register := RegisterIn;
        Setup := SetupIn;
        This := ThisIn;

        RetailSetup.Get();

        Clear(Rec);
        Clear(LastSaleRetrieved);

        OnBeforeInitSale(Rec,FrontEnd);
        InitSale();
        OnAfterInitSale(Rec,FrontEnd);

        //-NPR5.48 [335967]
        if not IsMock then
        //+NPR5.48 [335967]

          FrontEnd.StartTransaction(Rec);

        //-NPR5.32 [266226]
        //FrontEnd.SetView(ViewType.Sale,Setup);
        //+NPR5.32 [266226]

        // TODO: perhaps these two blocks above should be switched: first to start the transaction from the Front End, which would then invoke a real workflow (with all necessary UI quirks if needed) and then the back-end start of transaction
    end;

    local procedure CheckInit(WithError: Boolean): Boolean
    begin
        //-NPR5.50 [300557]
        if WithError and (not Initialized) then
          Error('Codeunit POS Sale was invoked in uninitialized state. This is a programming bug, not a user error');
        exit(Initialized);
        //+NPR5.50 [300557]
    end;

    local procedure InitSale()
    var
        FormCode: Codeunit "Retail Form Code";
        TouchScreenFunctions: Codeunit "Touch Screen - Functions";
    begin
        with Rec do begin
        
          //-NPR5.55 [406862]
          // TODO: Assign the salesperson
          // IF Register."Touch Screen Login Type" <> Register."Touch Screen Login Type"::Automatic THEN BEGIN
          //   "Salesperson Code" := '';
          // END;
          //+NPR5.55 [406862]
          "Salesperson Code" := Setup.Salesperson();
        
          "Register No." := Register."Register No.";
          Register.TestField("Return Payment Type");
        
          "Sales Ticket No." := FormCode.FetchSalesTicketNumber("Register No.");
        
          Date := Today;
          "Start Time" := Time;
          "Sale type" := "Sale type"::Sale;
        
          "Saved Sale" := false;
          TouchScreen := true;
        
          /* tjek om der er ekspeditioner på rev.rullen efter d.d. */
          TouchScreenFunctions.TestSalesDate;
        
          UpdateSaleDeviceID(Rec);  //NPR5.54 [364658]
          Insert(true);
        
          //-NPR5.31 [271728]
        //  IF RetailSetup."Default Customer no." <> '' THEN BEGIN
        //    "Customer Type" := "Customer Type"::Ord;
        //    VALIDATE("Customer No.", RetailSetup."Default Customer no.");
        //  END ELSE
          //+NPR5.31 [271728]
          Validate("Customer No.", '');
        
          //MODIFY;
        
          SaleLine.Init("Register No.","Sales Ticket No.",This,Setup,FrontEnd);
          PaymentLine.Init("Register No.","Sales Ticket No.",This,Setup,FrontEnd);
        
          // RetailSalesDocMgt.Reset(); // TODO
        
          FilterGroup := 2;
          SetRange("Register No.","Register No.");
          SetRange("Sales Ticket No.","Sales Ticket No.");
          FilterGroup := 0;
        
          IsModified := true;
        end;

    end;

        procedure GetContext(var SaleLineOut: Codeunit "POS Sale Line";var PaymentLineOut: Codeunit "POS Payment Line")
    begin
        SaleLineOut := SaleLine;
        PaymentLineOut := PaymentLine;
    end;

        procedure ToDataset(var CurrDataSet: DotNet npNetDataSet;DataSource: DotNet npNetDataSource0;POSSession: Codeunit "POS Session";FrontEnd: Codeunit "POS Front End Management")
    var
        TempRec: Record "Sale POS" temporary;
        DataMgt: Codeunit "POS Data Management";
    begin
        if not Initialized then begin
          TempRec."Register No." := Register."Register No.";
          TempRec.Insert;
          //-NPR5.38 [301053]
          //DataMgt.RecordToDataSet(TempRec,DataSet,DataSource,POSSession,FrontEnd);
          DataMgt.RecordToDataSet(TempRec,CurrDataSet,DataSource,POSSession,FrontEnd);
          //+NPR5.38 [301053]
          exit;
        end;

        //-NPR5.38 [301053]
        //DataMgt.RecordToDataSet(Rec,DataSet,DataSource,POSSession,FrontEnd);
        DataMgt.RecordToDataSet(Rec,CurrDataSet,DataSource,POSSession,FrontEnd);
        //+NPR5.38 [301053]
    end;

        procedure SetPosition(Position: Text): Boolean
    begin
        Rec.SetPosition(Position);
        exit(Rec.Find);
    end;

        procedure GetCurrentSale(var SalePOS: Record "Sale POS")
    begin
        SalePOS.Copy (Rec);
    end;

        procedure GetLastSaleInfo(var LastSaleTotalOut: Decimal;var LastSalePaymentOut: Decimal;var LastSaleDateTextOut: Text;var LastSaleReturnAmountOut: Decimal;var LastReceiptNoOut: Text)
    var
        TouchScreenFunctions: Codeunit "Touch Screen - Functions";
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
        //-NPR5.45 [323780]
        IsModified := true;
        //+NPR5.45 [323780]
    end;

        procedure GetTotals(var SalesAmountOut: Decimal;var PaidAmountOut: Decimal;var ChangeAmountOut: Decimal;var RoundingAmountOut: Decimal)
    var
        ReturnAmount: Decimal;
        SubTotal: Decimal;
    begin
        //-NPR5.38 [298025]
        if Ended then begin
          SalesAmountOut := EndedSalesAmount;
          PaidAmountOut := EndedPaidAmount;
          ChangeAmountOut := EndedChangeAmount;
          RoundingAmountOut := EndedRoundingAmount;
        end else
          PaymentLine.CalculateBalance(SalesAmountOut, PaidAmountOut, ReturnAmount, SubTotal); //ReturnAmount & SubTotal are legacy. Cannot calculate true return without knowing payment type that ended sale.
        //+NPR5.38 [298025]
    end;

        procedure Modify(RunTriggers: Boolean;ReturnValue: Boolean) Result: Boolean
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

        procedure Refresh(var SalePOS: Record "Sale POS")
    begin
        Rec.Copy(SalePOS);

        //-NPR5.46 [329523]
        OnRefresh(Rec);
        //+NPR5.46 [329523]
    end;

        procedure RefreshCurrent()
    var
        LocalSaleLinePOS: Record "Sale Line POS";
    begin
        //-NPR5.46 [329523]
        // Rec.FINDFIRST ();
        // SaleLine.GetCurrentSaleLine (LocalSaleLinePOS);
        // IF (LocalSaleLinePOS.FINDFIRST ()) THEN
        //  SaleLine.SetPosition (LocalSaleLinePOS.GETPOSITION);
        Rec.Get(Rec."Register No.",Rec."Sales Ticket No.");
        OnRefresh(Rec);
        //+NPR5.46 [329523]
    end;

        procedure SetDimension(DimCode: Code[20];DimValue: Code[20])
    var
        Dim: Record Dimension;
        DimVal: Record "Dimension Value";
        DimSetEntryTmp: Record "Dimension Set Entry" temporary;
        DimMgt: Codeunit DimensionManagement;
        DimValues: Page "Dimension Values";
        OldDimSetID: Integer;
    begin

        //-NPR5.34 [283019]
        if (not Dim.Get(DimCode)) then
          Error(SetDimension01, DimCode);

        if (not DimVal.Get(Dim.Code, DimValue)) then
          Error(SetDimension02, DimValue, DimCode);

        DimMgt.GetDimensionSet (DimSetEntryTmp, Rec."Dimension Set ID");

        DimSetEntryTmp.SetRange ("Dimension Code", Dim.Code);
        if (DimSetEntryTmp.FindFirst()) then;
        DimSetEntryTmp."Dimension Code"       := Dim.Code;
        DimSetEntryTmp."Dimension Value Code" := DimVal.Code;
        DimSetEntryTmp."Dimension Value ID"   := DimVal."Dimension Value ID";

        if (not DimSetEntryTmp.Insert()) then
          DimSetEntryTmp.Modify();

        OldDimSetID := Rec."Dimension Set ID";
        Rec."Dimension Set ID" := DimSetEntryTmp.GetDimensionSetID(DimSetEntryTmp);
        DimMgt.UpdateGlobalDimFromDimSetID (Rec."Dimension Set ID", Rec."Shortcut Dimension 1 Code", Rec."Shortcut Dimension 2 Code");
        Rec.Modify();

        if (OldDimSetID <> Rec."Dimension Set ID") and Rec.SalesLinesExist then
          Rec.UpdateAllLineDim(Rec."Dimension Set ID", OldDimSetID);

        RefreshCurrent ();
        //+NPR5.34 [283019]
    end;

        procedure SetShortcutDimCode1(DimensionValue: Code[20])
    begin

        //-NPR5.34 [283019]
        Rec.Validate (Rec."Shortcut Dimension 1 Code", DimensionValue);
        //+NPR5.34 [283019]
    end;

        procedure SetShortcutDimCode2(DimensionValue: Code[20])
    begin
        Rec.Validate (Rec."Shortcut Dimension 2 Code", DimensionValue);
    end;

        procedure TryEndSale(POSSession: Codeunit "POS Session"): Boolean
    begin
        //-NPR5.54 [364658]
        exit(TryEndSale2(POSSession, true));
        //+NPR5.54 [364658]
    end;

    procedure TryEndSale2(POSSession: Codeunit "POS Session";StartNew: Boolean): Boolean
    var
        ReturnPaymentType: Record "Payment Type POS";
        SalePOS: Record "Sale POS";
        SalesAmount: Decimal;
        PaidAmount: Decimal;
        ReturnAmount: Decimal;
        SubTotal: Decimal;
        RetailFormCode: Codeunit "Retail Form Code";
        TempSalesHeader: Record "Sales Header" temporary;
        EmptySelf: Codeunit "POS Sale";
        POSStore: Record "POS Store";
        POSEntry: Record "POS Entry";
        RoundAmount: Decimal;
        ChangeAmount: Decimal;
        POSGiveChange: Codeunit "POS Give Change";
        POSRounding: Codeunit "POS Rounding";
    begin
        //-NPR5.54 [364658]
        if not Initialized then
          exit(false);
        RefreshCurrent();

        OnAttemptEndSale (Rec);

        PaymentLine.CalculateBalance (SalesAmount, PaidAmount, ReturnAmount, SubTotal);

        if SubTotal <> 0 then
          exit (false);

        EndSale(POSSession, StartNew);
        EndedSalesAmount := SalesAmount;
        EndedPaidAmount := PaidAmount;
        exit(true);
        //+NPR5.54 [364658]
    end;

        procedure TryEndSaleWithBalancing(POSSession: Codeunit "POS Session";PaymentType: Record "Payment Type POS";ReturnPaymentType: Record "Payment Type POS"): Boolean
    var
        SalesAmount: Decimal;
        PaidAmount: Decimal;
        ReturnAmount: Decimal;
        SubTotal: Decimal;
        POSRounding: Codeunit "POS Rounding";
        POSGiveChange: Codeunit "POS Give Change";
        ChangeAmount: Decimal;
        RoundAmount: Decimal;
    begin

        //PaymentType: The payment type just used in sale, triggering this end attempt.
        //ReturnPaymentType: The payment type to use for round & change in case of overtender.

        if not Initialized then
          exit(false);
        RefreshCurrent();

        OnAttemptEndSale (Rec);

        PaymentLine.CalculateBalance (SalesAmount, PaidAmount, ReturnAmount, SubTotal);

        if not IsPaymentValidForEndingSale(PaymentType, ReturnPaymentType, SalesAmount, PaidAmount) then
          exit(false);

        ChangeAmount := POSGiveChange.InsertChange(Rec, ReturnPaymentType, PaidAmount-SalesAmount);
        RoundAmount := POSRounding.InsertRounding(Rec, ReturnPaymentType, PaidAmount-SalesAmount-ChangeAmount);

        //-NPR5.54 [364658]
        EndSale(POSSession, true);
        EndedSalesAmount := SalesAmount;
        EndedPaidAmount := PaidAmount;
        EndedChangeAmount := ChangeAmount;
        EndedRoundingAmount := RoundAmount;

        exit(true);
        //-NPR5.54 [364658]
    end;

    local procedure EndSale(POSSession: Codeunit "POS Session";StartNew: Boolean)
    var
        SalePOS: Record "Sale POS";
        SalesAmount: Decimal;
        PaidAmount: Decimal;
        ReturnAmount: Decimal;
        SubTotal: Decimal;
        TempSalesHeader: Record "Sales Header" temporary;
        RetailFormCode: Codeunit "Retail Form Code";
        StartTime: DateTime;
        RetailSalesDocMgt: Codeunit "Retail Sales Doc. Mgt.";
    begin

        PaymentLine.CalculateBalance (SalesAmount, PaidAmount, ReturnAmount, SubTotal);

        RetailSalesDocMgt.HandleLinkedDocuments(POSSession);

        OnBeforeEndSale (Rec);

        SalePOS := Rec;

        StartTime := CurrentDateTime;
        RetailFormCode.FinishSale (Rec, SubTotal, 0, true, TempSalesHeader, SalesAmount);
        Commit;
        Ended := true;

        LogStopwatch('FINISH_SALE', CurrentDateTime-StartTime);

        RunAfterEndSale(SalePOS);

        //-NPR5.54 [364658]
        if StartNew then begin
          SelectViewForEndOfSale(POSSession);
        end;
        //+NPR5.54 [364658]
    end;

    local procedure IsPaymentValidForEndingSale(PaymentType: Record "Payment Type POS";ReturnPaymentType: Record "Payment Type POS";SalesAmount: Decimal;PaidAmount: Decimal): Boolean
    var
        POSPaymentLine: Codeunit "POS Payment Line";
    begin

        if not PaymentType."Auto End Sale" then
          exit (false);

        exit (POSPaymentLine.CalculateRemainingPaymentSuggestion(SalesAmount, PaidAmount, PaymentType, ReturnPaymentType, false) = 0);
    end;

        procedure SelectViewForEndOfSale(POSSession: Codeunit "POS Session")
    var
        POSViewProfile: Record "POS View Profile";
    begin

        //-NPR5.55 [406862]
        // IF (Register."Touch Screen Login Type" = Register."Touch Screen Login Type"::Automatic) THEN BEGIN
        //  POSSession.StartTransaction ();
        //  POSSession.ChangeViewSale ();
        // END ELSE BEGIN
        //  POSSession.StartPOSSession ();
        // END;

        POSViewProfile.Init ();
        Setup.GetPOSViewProfile (POSViewProfile);

        if (POSViewProfile."After End-of-Sale View" = POSViewProfile."After End-of-Sale View"::INITIAL_SALE_VIEW) then begin
          POSSession.StartTransaction ();

          case POSViewProfile."Initial Sales View" of
            POSViewProfile."Initial Sales View"::SALES_VIEW      : POSSession.ChangeViewSale ();
            POSViewProfile."Initial Sales View"::RESTAURANT_VIEW : POSSession.ChangeViewRestaurant ();
          end;

        end else begin
          POSSession.StartPOSSession ();
        end;

        //+NPR5.55 [406862]
    end;

        procedure LoadSavedSale(var SalePOS: Record "Sale POS")
    var
        SaleLinePOS: Record "Sale Line POS";
        SaleLinePOS1: Record "Sale Line POS";
        GlobalSalePOS: Record "Global Sale POS";
        PaymentTypePOS: Record "Payment Type POS";
        LineIsGiftVoucher: Boolean;
        Value: Integer;
        SavedGiftVoucher: Record "Gift Voucher";
        RetailFormCode: Codeunit "Retail Form Code";
        Text0000001: Label 'Transferred to location receipt %1';
        POSInfoManagement: Codeunit "POS Info Management";
        AmountExclVAT: Decimal;
        VATAmount: Decimal;
        TotalAmount: Decimal;
    begin
        OnBeforeLoadSavedSale (SalePOS."Sales Ticket No.", Rec."Sales Ticket No.");

        with Rec do begin
          "Customer No."          := SalePOS."Customer No.";
          "Customer Type"         := SalePOS."Customer Type";

          "Customer Name" := SalePOS."Customer Name";
          Name := SalePOS.Name;
          Address := SalePOS.Address;
          "Address 2" := SalePOS."Address 2";
          "Post Code" := SalePOS."Post Code";
          City := SalePOS.City;
          "Contact No.":= SalePOS."Contact No.";
          Reference := SalePOS.Reference;

          Date                    := Today;
          "Start Time"            := Time;
          "External Document No." := SalePOS."External Document No.";
          "Prices Including VAT"   := SalePOS."Prices Including VAT";
          Modify(true);

          POSInfoManagement.RetrieveSavedLines(Rec, SalePOS);

          SaleLinePOS.SetRange("Register No.",SalePOS."Register No.");
          SaleLinePOS.SetRange("Sales Ticket No.",SalePOS."Sales Ticket No.");
          if SaleLinePOS.FindSet then repeat
            LineIsGiftVoucher := false;
            if (Value <> SaleLinePOS."Sale Type"::Sale) and
               (SaleLinePOS."Gift Voucher Ref." = '') then begin
              if SaleLinePOS."Sale Type" = SaleLinePOS."Sale Type"::Payment then begin
                 PaymentTypePOS.SetRange("Processing Type",PaymentTypePOS."Processing Type"::"Gift Voucher");
                 PaymentTypePOS.SetRange("G/L Account No.", SaleLinePOS."No.");
                 if not PaymentTypePOS.Find('-') then
                   Value             := SaleLinePOS."Sale Type"
                 else
                   LineIsGiftVoucher := true;
              end else
                Value := SaleLinePOS."Sale Type";
            end;
            SaleLinePOS1 := SaleLinePOS;
            SaleLinePOS1."Register No." := "Register No.";
            SaleLinePOS1."Sales Ticket No." := "Sales Ticket No.";
            //-NPR5.38 [299509]
            SaleLinePOS1.Date := Date;
            //+NPR5.38 [299509]

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

          GlobalSalePOS.SetRange("Sales Ticket No.",  SalePOS."Sales Ticket No.");
          GlobalSalePOS.ModifyAll("Sales Ticket No.", "Sales Ticket No.");

          SaleLinePOS.ModifyAll("From Selection",false);
          SaleLinePOS.DeleteAll;

          SalePOS.SetRange("Register No.", SalePOS."Register No.");
          SalePOS.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");
          SalePOS.Delete(true);

          SaleLine.Init("Register No.","Sales Ticket No.",This,Setup,FrontEnd);
          SaleLine.RefreshCurrent();
          SaleLine.CalculateBalance (AmountExclVAT, VATAmount, TotalAmount);

          PaymentLine.Init("Register No.","Sales Ticket No.",This,Setup,FrontEnd);
        end;

        OnAfterLoadSavedSale (SalePOS."Sales Ticket No.", Rec."Sales Ticket No.");
    end;

        procedure SaveSale()
    var
        FormCode: Codeunit "Retail Form Code";
        TouchScreenFunctions: Codeunit "Touch Screen - Functions";
        EmptySelf: Codeunit "POS Sale";
    begin

        Rec."Saved Sale" := true;
        Rec.Modify;

        FormCode.AuditRollCancelSale (Rec, Text10600003);
        InitializeNewSale (Register, FrontEnd, Setup, EmptySelf);
    end;

    procedure ResumeExistingSale(SalePOS_ToResume: Record "Sale POS";RegisterIn: Record Register;FrontEndIn: Codeunit "POS Front End Management";SetupIn: Codeunit "POS Setup";ThisIn: Codeunit "POS Sale")
    var
        SalePOS: Record "Sale POS";
    begin
        //-NPR5.54 [364658]
        Initialized := true;

        FrontEnd := FrontEndIn;
        Register := RegisterIn;
        Setup := SetupIn;
        This := ThisIn;

        RetailSetup.Get();

        Clear(Rec);
        Clear(LastSaleRetrieved);

        OnBeforeResumeSale(Rec,FrontEnd);
        ResumeSale(SalePOS_ToResume);
        OnAfterResumeSale(Rec,FrontEnd);

        if not IsMock then
          FrontEnd.StartTransaction(Rec);
        //+NPR5.54 [364658]
    end;

    local procedure ResumeSale(SalePOS_ToResume: Record "Sale POS")
    var
        SaleLinePOS: Record "Sale Line POS";
        POSResumeSale: Codeunit "POS Resume Sale Mgt.";
        TouchScreenFunctions: Codeunit "Touch Screen - Functions";
    begin
        //-NPR5.54 [364658]
        Rec := SalePOS_ToResume;
        with Rec do begin
          Register.TestField("Return Payment Type");
          UpdateSaleDeviceID(Rec);

          "Salesperson Code" := Setup.Salesperson();
          if "Salesperson Code" <> SalePOS_ToResume."Salesperson Code" then
            CreateDim(
              DATABASE::"POS Unit","Register No.",
              DATABASE::"POS Store","POS Store Code",
              DATABASE::Job,"Event No.",
              DATABASE::Customer,"Customer No.",
              DATABASE::"Salesperson/Purchaser","Salesperson Code");

          Modify(true);

          SaleLine.Init("Register No.","Sales Ticket No.",This,Setup,FrontEnd);
          SaleLinePOS.SetRange("Register No.","Register No.");
          SaleLinePOS.SetRange("Sales Ticket No.","Sales Ticket No.");
          SaleLinePOS.SetFilter(Type,'<>%1',SaleLinePOS.Type::Payment);
          if not SaleLinePOS.IsEmpty then
            SaleLine.SetLast();

          PaymentLine.Init("Register No.","Sales Ticket No.",This,Setup,FrontEnd);

          FilterGroup := 2;
          SetRange("Register No.","Register No.");
          SetRange("Sales Ticket No.","Sales Ticket No.");
          FilterGroup := 0;

          IsModified := true;

          POSResumeSale.LogSaleResume(Rec, SalePOS_ToResume."Sales Ticket No.");  //NPR5.55 [391678]
        end;
        //+NPR5.54 [364658]
    end;

    procedure ResumeFromPOSQuote(POSQuoteNo: Integer): Boolean
    var
        SaleLinePOS: Record "Sale Line POS";
        POSResumeSale: Codeunit "POS Resume Sale Mgt.";
        Ok: Boolean;
    begin
        //-NPR5.54 [364658]
        Ok := POSResumeSale.LoadFromPOSQuote(Rec,POSQuoteNo);
        if Ok then begin
          SaleLinePOS.SetRange("Register No.",Rec."Register No.");
          SaleLinePOS.SetRange("Sales Ticket No.",Rec."Sales Ticket No.");
          SaleLinePOS.SetFilter(Type,'<>%1',SaleLinePOS.Type::Payment);
          if not SaleLinePOS.IsEmpty then
            SaleLine.SetLast();

          IsModified := true;
        end;

        exit(Ok);
        //+NPR5.54 [364658]
    end;

    local procedure UpdateSaleDeviceID(var SalePOS: Record "Sale POS")
    var
        POSUnitIdentity: Record "POS Unit Identity";
    begin
        //-NPR5.54 [364658]
        Setup.GetPOSUnitIdentity(POSUnitIdentity);
        with SalePOS do begin
          if POSUnitIdentity."Entry No." = 0 then
            "Device ID" := ''  //Configured using temporary pos unit identity
          else
            "Device ID" := POSUnitIdentity."Device ID";
          "Host Name" := POSUnitIdentity."Host Name";
          "User ID" := POSUnitIdentity."User ID";
        end;
        //+NPR5.54 [364658]
    end;

    local procedure RunAfterEndSale(xRec: Record "Sale POS")
    var
        Success: Boolean;
    begin
        //-NPR5.40 [308457]
        //Any error at this timing would leave the POS with inconsistent front-end state.
        ClearLastError;
        asserterror begin
          InvokeOnFinishSaleWorkflow(Rec);
          Commit;
        //-NPR5.53 [376362]
        //  CODEUNIT.RUN(CODEUNIT::"POS End Sale Post Processing",Rec);
        //  COMMIT;
        //+NPR5.53 [376362]
          OnAfterEndSale(xRec);
          Commit;

          Success := true;
          Error('');
        end;

        if not Success then
          Message(ERROR_AFTER_END_SALE, GetLastErrorText);
        //+NPR5.40 [308457]

        //-NPR5.53 [376362]
        ClearLastError;
        if not CODEUNIT.Run(CODEUNIT::"POS End Sale Post Processing", Rec) then
          Message(ERROR_AFTER_END_SALE, GetLastErrorText);
        //+NPR5.53 [376362]
    end;

    local procedure LogStopwatch(Keyword: Text;Duration: Duration)
    var
        POSSession: Codeunit "POS Session";
        FrontEnd: Codeunit "POS Front End Management";
    begin
        //-NPR5.43 [315838]
        if not POSSession.IsActiveSession(FrontEnd) then
          exit;
        FrontEnd.GetSession(POSSession);
        POSSession.AddServerStopwatch(Keyword, Duration);
        //+NPR5.43 [315838]
    end;

    local procedure "---Events---"()
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterInitializeAtLogin(Register: Record Register)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeInitSale(SaleHeader: Record "Sale POS";FrontEnd: Codeunit "POS Front End Management")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterInitSale(SaleHeader: Record "Sale POS";FrontEnd: Codeunit "POS Front End Management")
    begin
    end;

    [IntegrationEvent(TRUE, false)]
    local procedure OnBeforeLoadSavedSale(OriginalSalesTicketNo: Code[20];NewSalesTicketNo: Code[20])
    begin
    end;

    [IntegrationEvent(TRUE, false)]
    local procedure OnAfterLoadSavedSale(OriginalSalesTicketNo: Code[20];NewSalesTicketNo: Code[20])
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeResumeSale(SalePOS: Record "Sale POS";FrontEnd: Codeunit "POS Front End Management")
    begin
        //NPR5.54 [364658]
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterResumeSale(SalePOS: Record "Sale POS";FrontEnd: Codeunit "POS Front End Management")
    begin
        //NPR5.54 [364658]
    end;

    [IntegrationEvent(TRUE, false)]
    local procedure OnBeforeEndSale(SaleHeader: Record "Sale POS")
    begin
    end;

    [IntegrationEvent(TRUE, false)]
    local procedure OnAfterEndSale(SalePOS: Record "Sale POS")
    begin
    end;

    [IntegrationEvent(TRUE, false)]
    local procedure OnAttemptEndSale(SalePOS: Record "Sale POS")
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnRefresh(var SalePOS: Record "Sale POS")
    begin
        //-NPR5.46 [329523]
        //+NPR5.46 [329523]
    end;

    local procedure "--- OnFinishSale Workflow"()
    begin
    end;

    [EventSubscriber(ObjectType::Table, 6014400, 'OnAfterInsertEvent', '', true, true)]
    local procedure OnAfterInsertRetailSetup(var Rec: Record "Retail Setup";RunTrigger: Boolean)
    var
        POSSalesWorkflow: Record "POS Sales Workflow";
    begin
        //-NPR5.39 [302779]
        POSSalesWorkflow.OnDiscoverPOSSalesWorkflows();
        if POSSalesWorkflow.FindSet then
          repeat
            POSSalesWorkflow.InitPOSSalesWorkflowSteps();
          until POSSalesWorkflow.Next = 0;
        //+NPR5.39 [302779]
    end;

    local procedure OnFinishSaleCode(): Code[20]
    begin
        //-NPR5.39 [302779]
        exit('FINISH_SALE');
        //+NPR5.39 [302779]
    end;

    [EventSubscriber(ObjectType::Table, 6150729, 'OnDiscoverPOSSalesWorkflows', '', true, true)]
    local procedure OnDiscoverPOSWorkflows(var Sender: Record "POS Sales Workflow")
    begin
        //-NPR5.39 [302779]
        Sender.DiscoverPOSSalesWorkflow(OnFinishSaleCode(),Text000,CurrCodeunitId(),'OnFinishSale');
        //+NPR5.39 [302779]
    end;

    local procedure CurrCodeunitId(): Integer
    begin
        //-NPR5.39 [302779]
        exit(CODEUNIT::"POS Sale");
        //+NPR5.39 [302779]
    end;

        procedure InvokeOnFinishSaleWorkflow(SalePOS: Record "Sale POS")
    var
        POSUnit: Record "POS Unit";
        POSSalesWorkflowSetEntry: Record "POS Sales Workflow Set Entry";
        POSSalesWorkflowStep: Record "POS Sales Workflow Step";
        StartTime: DateTime;
    begin
        //-NPR5.43 [315838]
        StartTime := CurrentDateTime;
        //+NPR5.43 [315838]

        POSSalesWorkflowStep.SetCurrentKey("Sequence No.");
        //-NPR5.45 [321266]
        POSSalesWorkflowStep.SetFilter("Set Code",'=%1','');
        if POSUnit.Get(SalePOS."Register No.") and (POSUnit."POS Sales Workflow Set" <> '') and POSSalesWorkflowSetEntry.Get(POSUnit."POS Sales Workflow Set",OnFinishSaleCode()) then
          POSSalesWorkflowStep.SetRange("Set Code",POSSalesWorkflowSetEntry."Set Code");
        //+NPR5.45 [321266]
        POSSalesWorkflowStep.SetRange("Workflow Code",OnFinishSaleCode());
        POSSalesWorkflowStep.SetRange(Enabled,true);
        if not POSSalesWorkflowStep.FindSet then
          exit;

        Refresh(SalePOS);
        repeat
          asserterror begin
            OnFinishSale(POSSalesWorkflowStep,Rec);
            Commit;
            Error('');
          end;
        until POSSalesWorkflowStep.Next = 0;

        //-NPR5.43 [315838]
        LogStopwatch('FINISH_SALE_WORKFLOWS', CurrentDateTime-StartTime);
        //+NPR5.43 [315838]
    end;

    [IntegrationEvent(false, false)]
    local procedure OnFinishSale(POSSalesWorkflowStep: Record "POS Sales Workflow Step";SalePOS: Record "Sale POS")
    begin
        //-NPR5.39 [302779]
        //+NPR5.39 [302779]
    end;

    procedure SetMockMode()
    begin
        //-NPR5.48 [335967]
        IsMock := true;
        //+NPR5.48 [335967]
    end;
}

