codeunit 6150801 "NPR POS Action - Customer"
{
    var
        ActionDescription: Label 'This is a built-in action for handling Customer Info';
        ErrorDescription: Label 'Error';
        CustNoMissing: Label 'Customer number not chosen.';
        CustDepositError: Label 'You cannot change customer when doing customer deposits.';
        DebitSaleChangeCancelled: Label 'Debit sale change is cancelled by sales person.';
        ConfirmPosting: Label 'Do you want to post ?';
        POSSetup: Codeunit "NPR POS Setup";
        SerialNumberError: Label 'You have not set a Serial Number from the item. \ \Sales line deleted if the item requires a serial number!';

    local procedure ActionCode(): Text
    begin
        exit('CUSTOMERINFO');
    end;

    local procedure ActionVersion(): Text
    begin
        exit('1.2');
    end;

    [EventSubscriber(ObjectType::Table, 6150703, 'OnDiscoverActions', '', false, false)]
    local procedure OnDiscoverAction(var Sender: Record "NPR POS Action")
    begin
        if Sender.DiscoverAction(
          ActionCode,
          ActionDescription,
          ActionVersion,
          Sender.Type::Generic,
          Sender."Subscriber Instances Allowed"::Multiple)
        then begin
            Sender.RegisterWorkflowStep('1', 'respond();');
            Sender.RegisterWorkflow(false);

            Sender.RegisterOptionParameter('CustomerType', 'CustomerSTD,CustomerInfo,DebitInfo,CustomerCRM,CustomerILE,CustomerRemove,RepairSend,NPOrderSend,NPOrderGet,CustomerPay,SamplingGet,SamplingSend,CustomerLedger', 'CustomerSTD');
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150701, 'OnBeforeWorkflow', '', false, false)]
    local procedure OnBeforeWorkflow("Action": Record "NPR POS Action"; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean)
    var
        Context: Codeunit "NPR POS JSON Management";
    begin
        if not Action.IsThisAction(ActionCode) then
            exit;

        Handled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150702, 'OnInitializeCaptions', '', false, false)]
    local procedure OnInitializeCaptions(Captions: Codeunit "NPR POS Caption Management")
    begin
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150701, 'OnAction', '', false, false)]
    local procedure OnAction("Action": Record "NPR POS Action"; WorkflowStep: Text; Context: JsonObject; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean)
    var
        JSON: Codeunit "NPR POS JSON Management";
        POSSale: Codeunit "NPR POS Sale";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        CustomerType: Integer;
        RegisterNo: Code[10];
        SalePOS: Record "NPR Sale POS";
        SaleLinePOS: Record "NPR Sale Line POS";
        POSPaymentLine: Codeunit "NPR POS Payment Line";
        SalesAmount: Decimal;
        ReturnAmount: Decimal;
        PaidAmount: Decimal;
        SubTotal: Decimal;
        View: Codeunit "NPR POS View";
        TempSalesHeader: Record "Sales Header" temporary;
    begin
        if not Action.IsThisAction(ActionCode) then
            exit;

        JSON.InitializeJObjectParser(Context, FrontEnd);
        JSON.SetScope('parameters', true);
        CustomerType := JSON.GetInteger('CustomerType', true);

        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);
        POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);
        POSSession.GetCurrentView(View);

        case CustomerType of
            0:  //CustomerSTD
                SetCustomer(SalePOS, POSSession, POSSale, View, FrontEnd);
            1:  //CustomerInfo
                SetCustomerInfo(SalePOS);
            2:  //DebitInfo
                SetDebitInfo(SalePOS, TempSalesHeader);
            3:  //CustomerCRM
                SetContact(SalePOS, POSSession, POSSale, View);
            4:  //CustomerILE
                SetCustomerILE(SalePOS);
            5:  //CustomerRemove
                SetCustomerRemove(SalePOS, POSSale);
            6:  //RepairSend
                SetRepairSend(SalePOS);
            7:  //NPOrderSend
                SetNPOrderSend(SalePOS, POSSession, POSSale, FrontEnd);
            8:  //NPOrderGet
                SetNPOrderGet(SalePOS, POSSession, POSSale, FrontEnd);
            9:  //CustomerPay
                DebitSale(SalePOS, POSSale, FrontEnd);
            10:  //SamplingGet
                SetSamplingGet(SalePOS, POSSession, POSSale, View, FrontEnd);
            11:  //SamplingSend
                SetSamplingSend(SalePOS, POSSession, POSSale, FrontEnd);
            12:  //CustomerLedger
                ViewCustomerLedger(SalePOS);
        end;

        POSSession.RequestRefreshData();

        Handled := true;
    end;

    #region Locals

    procedure SetCustomer(var SalePOS: Record "NPR Sale POS"; POSSession: Codeunit "NPR POS Session"; POSSale: Codeunit "NPR POS Sale"; View: Codeunit "NPR POS View"; FrontEnd: Codeunit "NPR POS Front End Management")
    var
        SaleLinePOS: Record "NPR Sale Line POS";
        FormCode: Codeunit "NPR Retail Form Code";
        RetailSetup: Record "NPR Retail Setup";
        TempSalesHeader: Record "Sales Header" temporary;
        Register: Record "NPR Register";
        IsCashSale: Boolean;
        Amount: Decimal;
        PaymentLinePOSObject: Codeunit "NPR Touch: Payment Line POS";
        TouchScreenFunctions: Codeunit "NPR Touch Screen - Func.";
        Validering: Code[10];
    begin
        SalePOS.Validate("Customer No.", '');
        SalePOS.Modify(true);
        POSSale.Refresh(SalePOS);
        POSSale.Modify(true, false);

        SaleLinePOS.SetRange("Register No.", SalePOS."Register No.");
        SaleLinePOS.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");

        SaleLinePOS.SetRange(Type, SaleLinePOS.Type::Customer);
        if SaleLinePOS.FindSet then
            Error(CustDepositError);

        if not TouchScreenFunctions.SaleDebit(SalePOS, TempSalesHeader, Validering, false) then
            exit;

        SalePOS.Validate("Customer No.");
        SalePOS.Modify(true);
        POSSale.Refresh(SalePOS);
        POSSale.Modify(true, false);

        RetailSetup.Get;
        if (RetailSetup."Auto edit debit sale") and (SalePOS."Customer No." <> '') then begin
            FormCode.CreateSalesHeader(SalePOS, TempSalesHeader);
            SetDebitInfo(SalePOS, TempSalesHeader);
        end;
        Register.Get(SalePOS."Register No.");
        if SalePOS."Customer No." <> '' then begin
            if AutoDebit(SalePOS, POSSale, Register, FrontEnd) then
                exit;
        end;

        PaymentLinePOSObject.SetTableView(SalePOS."Register No.", SalePOS."Sales Ticket No.");
        PaymentLinePOSObject.CalculateBalance(SalePOS.Amount);

        if (SalePOS.Amount < TouchScreenFunctions.CalcPaymentRounding(SalePOS."Register No.")) then
            IsCashSale := false
        else
            IsCashSale := true;

        if (View.Type = View.Type::Payment) and (not IsCashSale) then begin
            POSSession.ChangeViewPayment();
        end;
    end;

    local procedure SetCustomerInfo(var SalePOS: Record "NPR Sale POS")
    var
        TouchScreenFunctions: Codeunit "NPR Touch Screen - Func.";
        DummyText: Text;
        Buffer: Record "NPR TEMP Buffer" temporary;
    begin
        if SalePOS."Customer No." = '' then begin
            Error(CustNoMissing);
            exit;
        end;

        TouchScreenFunctions.InfoCustomer(SalePOS, DummyText, Buffer);
        PAGE.RunModal(PAGE::"NPR Touch Screen - Info", Buffer);
    end;

    local procedure SetDebitInfo(var SalePOS: Record "NPR Sale POS"; CurrTempSalesHeader: Record "Sales Header" temporary)
    var
        TempSalesHeader: Record "Sales Header" temporary;
    begin
        if SalePOS."Customer No." = '' then begin
            Error(CustNoMissing);
            exit;
        end;

        TempSalesHeader.FilterGroup := 2;
        TempSalesHeader.SetRange("Document Type", CurrTempSalesHeader."Document Type");
        TempSalesHeader.SetRange("No.", CurrTempSalesHeader."No.");
        TempSalesHeader.FilterGroup := 0;

        if PAGE.RunModal(PAGE::"NPR Debit sale info", TempSalesHeader) <> ACTION::LookupOK then
            Error(DebitSaleChangeCancelled);
    end;

    procedure SetContact(var SalePOS: Record "NPR Sale POS"; POSSession: Codeunit "NPR POS Session"; POSSale: Codeunit "NPR POS Sale"; View: Codeunit "NPR POS View")
    var
        Register: Record "NPR Register";
        IsCashSale: Boolean;
        Amount: Decimal;
        PaymentLinePOSObject: Codeunit "NPR Touch: Payment Line POS";
        TouchScreenFunctions: Codeunit "NPR Touch Screen - Func.";
        TempSalesHeader: Record "Sales Header" temporary;
        Validering: Code[10];
    begin
        Register.Get(SalePOS."Register No.");

        TouchScreenFunctions.SaleCashCustomer(SalePOS, TempSalesHeader, Validering);
        POSSale.Refresh(SalePOS);
        POSSale.Modify(true, false);

        //Todo: MenuLines1."Filter No." := '';

        PaymentLinePOSObject.SetTableView(SalePOS."Register No.", SalePOS."Sales Ticket No.");
        PaymentLinePOSObject.CalculateBalance(SalePOS.Amount);

        if (SalePOS.Amount < TouchScreenFunctions.CalcPaymentRounding(SalePOS."Register No.")) then
            IsCashSale := false
        else
            IsCashSale := true;

        if (View.Type = View.Type::Payment) and (not IsCashSale) then begin
            POSSession.ChangeViewPayment();
        end;
    end;

    local procedure SetCustomerILE(var SalePOS: Record "NPR Sale POS")
    var
        TouchScreenFunctions: Codeunit "NPR Touch Screen - Func.";
        CustomerNo: Code[20];
        Handled: Boolean;
    begin
        OnIdentifyCustomer(SalePOS, CustomerNo, Handled);
        if not Handled then
            CustomerNo := SalePOS."Customer No.";

        if CustomerNo = '' then begin
            Error(CustNoMissing);
            exit;
        end;

        TouchScreenFunctions.ItemLedgerEntries(SalePOS."Customer Type", CustomerNo);
    end;

    local procedure ViewCustomerLedger(var SalePOS: Record "NPR Sale POS")
    var
        CustLedgerEntry: Record "Cust. Ledger Entry";
        CustomerNo: Code[20];
        Handled: Boolean;
    begin
        OnIdentifyCustomer(SalePOS, CustomerNo, Handled);
        if not Handled then
            CustomerNo := SalePOS."Customer No.";

        if CustomerNo = '' then begin
            Error(CustNoMissing);
            exit;
        end;

        CustLedgerEntry.FilterGroup(2);
        CustLedgerEntry.SetRange("Customer No.", CustomerNo);
        CustLedgerEntry.FilterGroup(0);
        Page.Run(0, CustLedgerEntry);
    end;

    local procedure SetCustomerRemove(var SalePOS: Record "NPR Sale POS"; POSSale: Codeunit "NPR POS Sale")
    var
        TouchScreenFunctions: Codeunit "NPR Touch Screen - Func.";
        DummyText: Text;
        Buffer: Record "NPR TEMP Buffer" temporary;
    begin
        if SalePOS."Customer No." = '' then
            exit;

        SalePOS.Validate("Customer No.", '');
        SalePOS.Modify(true);
        POSSale.Refresh(SalePOS);
        POSSale.Modify(true, false);
    end;

    local procedure SetRepairSend(var SalePOS: Record "NPR Sale POS")
    begin
        PAGE.Run(PAGE::"NPR Customer Repair List");
    end;

    local procedure SetNPOrderSend(var SalePOS: Record "NPR Sale POS"; POSSession: Codeunit "NPR POS Session"; POSSale: Codeunit "NPR POS Sale"; FrontEnd: Codeunit "NPR POS Front End Management")
    var
        RetailDocumentHandling: Codeunit "NPR Retail Document Handling";
        TouchScreenFunctions: Codeunit "NPR Touch Screen - Func.";
        Register: Record "NPR Register";
    begin
        Register.Get(SalePOS."Register No.");
        SalePOS."Retail Document Type" := SalePOS."Retail Document Type"::"Retail Order";
        if not RetailDocumentHandling.Sale2RetailDocument(SalePOS) then
            Error(SerialNumberError);

        SalePOS.Modify(true);
        POSSale.Refresh(SalePOS);
        POSSale.Modify(true, false);

        if SalePOS.Deposit > 0 then begin
            TouchScreenFunctions.TestRegisterRegistration(SalePOS);
            POSSession.ChangeViewPayment();
        end else begin
            POSSale.SelectViewForEndOfSale(POSSession);

        end;
    end;

    local procedure SetNPOrderGet(var SalePOS: Record "NPR Sale POS"; POSSession: Codeunit "NPR POS Session"; POSSale: Codeunit "NPR POS Sale"; FrontEnd: Codeunit "NPR POS Front End Management")
    var
        RetailDocumentHandling: Codeunit "NPR Retail Document Handling";
    begin
        SalePOS."Retail Document Type" := SalePOS."Retail Document Type"::"Retail Order";
        RetailDocumentHandling.RetailDocument2Sale(SalePOS, SalePOS."Salesperson Code");

        POSSale.Refresh(SalePOS);
        POSSale.Modify(true, false);
        POSSale.RefreshCurrent();
    end;

    local procedure SetSamplingSend(var SalePOS: Record "NPR Sale POS"; POSSession: Codeunit "NPR POS Session"; POSSale: Codeunit "NPR POS Sale"; FrontEnd: Codeunit "NPR POS Front End Management")
    var
        RetailDocumentHandling: Codeunit "NPR Retail Document Handling";
        TouchScreenFunctions: Codeunit "NPR Touch Screen - Func.";
        Register: Record "NPR Register";
    begin
        Register.Get(SalePOS."Register No.");
        SalePOS."Retail Document Type" := SalePOS."Retail Document Type"::"Selection Contract";
        if not RetailDocumentHandling.Sale2RetailDocument(SalePOS) then
            Error(SerialNumberError);

        SalePOS.Modify(true);
        POSSale.Refresh(SalePOS);
        POSSale.Modify(true, false);

        if SalePOS.Deposit > 0 then begin
            TouchScreenFunctions.TestRegisterRegistration(SalePOS);
            POSSession.ChangeViewPayment();
        end else begin
            POSSale.SelectViewForEndOfSale(POSSession);
        end;
    end;

    local procedure SetSamplingGet(var SalePOS: Record "NPR Sale POS"; POSSession: Codeunit "NPR POS Session"; POSSale: Codeunit "NPR POS Sale"; View: Codeunit "NPR POS View"; FrontEnd: Codeunit "NPR POS Front End Management")
    var
        RetailDocumentHandling: Codeunit "NPR Retail Document Handling";
        POSSaleLine: Codeunit "NPR POS Sale Line";
    begin
        //Reload salePOS to avoid Runtime error when Modify record
        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);
        SalePOS.Find;
        SalePOS."Retail Document Type" := SalePOS."Retail Document Type"::"Selection Contract";
        RetailDocumentHandling.RetailDocument2Sale(SalePOS, SalePOS."Salesperson Code");

        POSSale.Refresh(SalePOS);
        POSSale.Modify(true, false);
        POSSession.GetSaleLine(POSSaleLine);
        if SalePOS.SalesLinesExist then
            POSSaleLine.SetLast();
    end;

    local procedure AutoDebit(var SalePOS: Record "NPR Sale POS"; POSSale: Codeunit "NPR POS Sale"; Register: Record "NPR Register"; FrontEnd: Codeunit "NPR POS Front End Management"): Boolean
    begin
        case Register."Customer No. auto debit sale" of
            Register."Customer No. auto debit sale"::Auto:
                begin
                    DebitSale(SalePOS, POSSale, FrontEnd);
                    exit(true);
                end;
            Register."Customer No. auto debit sale"::AskPayment:
                begin
                end;
            Register."Customer No. auto debit sale"::AskDebit:
                begin
                end;
        end;
    end;

    local procedure DebitSale(var SalePOS: Record "NPR Sale POS"; POSSale: Codeunit "NPR POS Sale"; FrontEnd: Codeunit "NPR POS Front End Management")
    var
        FormCode: Codeunit "NPR Retail Form Code";
        TouchScreenFunctions: Codeunit "NPR Touch Screen - Func.";
        SaleLinePOS: Record "NPR Sale Line POS";
        TempSalesHeader: Record "Sales Header" temporary;
        Validering: Code[10];
        Register: Record "NPR Register";
    begin
        SaleLinePOS.SetRange("Register No.", SalePOS."Register No.");
        SaleLinePOS.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");
        SaleLinePOS.SetRange(Date, Today);
        SaleLinePOS.SetRange("Sale Type", SaleLinePOS."Sale Type"::Deposit);
        SaleLinePOS.SetRange(Type, SaleLinePOS.Type::Customer);
        SaleLinePOS.DeleteAll(true);
        if SalePOS."Customer No." = '' then begin
            if not TouchScreenFunctions.SaleDebit(SalePOS, TempSalesHeader, Validering, false) then
                Error('');
            if (SalePOS."Customer Type" = SalePOS."Customer Type"::Ord) and (SalePOS."Customer No." <> '') then begin
                if Confirm(ConfirmPosting, true) then begin
                    FormCode.CreateSalesHeader(SalePOS, TempSalesHeader);
                    if TransferToInvoice(SalePOS) then begin
                        Register.Get(SalePOS."Register No.");
                        POSSale.InitializeNewSale(Register, FrontEnd, POSSetup, POSSale);
                    end;
                    exit;
                end else begin
                    SalePOS."Customer No." := '';
                    SalePOS.Modify;
                    exit;
                end;
            end;
            exit;
        end else begin
            if SalePOS."Customer Type" = SalePOS."Customer Type"::Ord then begin
                if Confirm(ConfirmPosting, false) then begin
                    FormCode.CreateSalesHeader(SalePOS, TempSalesHeader);
                    if TransferToInvoice(SalePOS) then begin
                        Register.Get(SalePOS."Register No.");
                        POSSale.InitializeNewSale(Register, FrontEnd, POSSetup, POSSale);
                    end;
                    exit;
                end else
                    exit;
            end;
        end;

        if (SalePOS."Customer Type" <> SalePOS."Customer Type"::Ord) then begin
            exit;
        end;
    end;

    local procedure TransferToInvoice(var SalePOS: Record "NPR Sale POS"): Boolean
    var
        RetailSalesDocMgt: Codeunit "NPR Sales Doc. Exp. Mgt.";
    begin
        if not RetailSalesDocMgt.ProcessPOSSale(SalePOS) then
            exit(false);
        exit(true);
    end;

    #endregion

    [IntegrationEvent(false, false)]
    local procedure OnIdentifyCustomer(SalePOS: Record "NPR Sale POS"; var CustomerNo: Code[20]; var Handled: Boolean)
    begin
    end;
}