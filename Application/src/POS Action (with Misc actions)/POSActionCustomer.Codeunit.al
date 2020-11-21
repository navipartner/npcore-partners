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
        exit('1.1');
    end;

    [EventSubscriber(ObjectType::Table, 6150703, 'OnDiscoverActions', '', false, false)]
    local procedure OnDiscoverAction(var Sender: Record "NPR POS Action")
    begin
        with Sender do
            if DiscoverAction(
              ActionCode,
              ActionDescription,
              ActionVersion,
              Type::Generic,
              "Subscriber Instances Allowed"::Multiple)
            then begin
                RegisterWorkflowStep('1', 'respond();');
                RegisterWorkflow(false);

                RegisterOptionParameter('CustomerType', 'CustomerSTD,CustomerInfo,DebitInfo,CustomerCRM,CustomerILE,CustomerRemove,RepairSend,NPOrderSend,NPOrderGet,CustomerPay,SamplingGet,SamplingSend', 'CustomerSTD');
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
            0:
                SetCustomer(SalePOS, POSSession, POSSale, View, FrontEnd);
            1:
                SetCustomerInfo(SalePOS);
            2:
                SetDebitInfo(SalePOS, TempSalesHeader);
            3:
                SetContact(SalePOS, POSSession, POSSale, View);
            4:
                SetCustomerILE(SalePOS);
            5:
                SetCustomerRemove(SalePOS, POSSale);
            6:
                SetRepairSend(SalePOS);
            7:
                SetNPOrderSend(SalePOS, POSSession, POSSale, FrontEnd);
            8:
                SetNPOrderGet(SalePOS, POSSession, POSSale, FrontEnd);
            9:
                DebitSale(SalePOS, POSSale, FrontEnd);
            10:
                SetSamplingGet(SalePOS, POSSession, POSSale, View, FrontEnd);
            11:
                SetSamplingSend(SalePOS, POSSession, POSSale, FrontEnd);
        end;

        POSSession.RequestRefreshData();

        Handled := true;
    end;

    local procedure "-- Locals --"()
    begin
    end;

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
        with SalePOS do begin

            Validate("Customer No.", '');
            Modify(true);
            POSSale.Refresh(SalePOS);
            POSSale.Modify(true, false);

            SaleLinePOS.SetRange("Register No.", "Register No.");
            SaleLinePOS.SetRange("Sales Ticket No.", "Sales Ticket No.");

            SaleLinePOS.SetRange(Type, SaleLinePOS.Type::Customer);
            if SaleLinePOS.FindSet then
                Error(CustDepositError);

            if not TouchScreenFunctions.SaleDebit(SalePOS, TempSalesHeader, Validering, false) then
                exit;

            Validate("Customer No.");
            Modify(true);
            POSSale.Refresh(SalePOS);
            POSSale.Modify(true, false);

            RetailSetup.Get;
            if (RetailSetup."Auto edit debit sale") and ("Customer No." <> '') then begin
                FormCode.CreateSalesHeader(SalePOS, TempSalesHeader);
                SetDebitInfo(SalePOS, TempSalesHeader);
            end;
            Register.Get("Register No.");
            if "Customer No." <> '' then begin
                if AutoDebit(SalePOS, POSSale, Register, FrontEnd) then
                    exit;
            end;

            PaymentLinePOSObject.SetTableView(SalePOS."Register No.", SalePOS."Sales Ticket No.");
            PaymentLinePOSObject.CalculateBalance(Amount);

            if (Amount < TouchScreenFunctions.CalcPaymentRounding("Register No.")) then
                IsCashSale := false
            else
                IsCashSale := true;

            if (View.Type = View.Type::Payment) and (not IsCashSale) then begin
                POSSession.ChangeViewPayment();
            end;
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
        with SalePOS do begin
            Register.Get("Register No.");

            TouchScreenFunctions.SaleCashCustomer(SalePOS, TempSalesHeader, Validering);
            POSSale.Refresh(SalePOS);
            POSSale.Modify(true, false);

            //Todo: MenuLines1."Filter No." := '';

            PaymentLinePOSObject.SetTableView(SalePOS."Register No.", SalePOS."Sales Ticket No.");
            PaymentLinePOSObject.CalculateBalance(Amount);

            if (Amount < TouchScreenFunctions.CalcPaymentRounding("Register No.")) then
                IsCashSale := false
            else
                IsCashSale := true;

            if (View.Type = View.Type::Payment) and (not IsCashSale) then begin
                POSSession.ChangeViewPayment();
            end;
        end;
    end;

    local procedure SetCustomerILE(var SalePOS: Record "NPR Sale POS")
    var
        TouchScreenFunctions: Codeunit "NPR Touch Screen - Func.";
        DummyText: Text;
        Buffer: Record "NPR TEMP Buffer" temporary;
    begin
        if SalePOS."Customer No." = '' then begin
            Error(CustNoMissing);
            exit;
        end;

        TouchScreenFunctions.ItemLedgerEntries(SalePOS."Customer Type", SalePOS."Customer No.");
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
        with SalePOS do begin
            Register.Get("Register No.");
            "Retail Document Type" := "Retail Document Type"::"Retail Order";
            if not RetailDocumentHandling.Sale2RetailDocument(SalePOS) then
                Error(SerialNumberError);

            Modify(true);
            POSSale.Refresh(SalePOS);
            POSSale.Modify(true, false);

            if Deposit > 0 then begin
                TouchScreenFunctions.TestRegisterRegistration(SalePOS);
                POSSession.ChangeViewPayment();
            end else begin
                POSSale.SelectViewForEndOfSale(POSSession);

            end;
        end;
    end;

    local procedure SetNPOrderGet(var SalePOS: Record "NPR Sale POS"; POSSession: Codeunit "NPR POS Session"; POSSale: Codeunit "NPR POS Sale"; FrontEnd: Codeunit "NPR POS Front End Management")
    var
        RetailDocumentHandling: Codeunit "NPR Retail Document Handling";
    begin
        with SalePOS do begin
            "Retail Document Type" := "Retail Document Type"::"Retail Order";
            RetailDocumentHandling.RetailDocument2Sale(SalePOS, "Salesperson Code");
        end;

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
        with SalePOS do begin
            Register.Get("Register No.");
            "Retail Document Type" := "Retail Document Type"::"Selection Contract";
            if not RetailDocumentHandling.Sale2RetailDocument(SalePOS) then
                Error(SerialNumberError);

            Modify(true);
            POSSale.Refresh(SalePOS);
            POSSale.Modify(true, false);

            if Deposit > 0 then begin
                TouchScreenFunctions.TestRegisterRegistration(SalePOS);
                POSSession.ChangeViewPayment();
            end else begin
                POSSale.SelectViewForEndOfSale(POSSession);
            end;
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
        with SalePOS do begin
            "Retail Document Type" := "Retail Document Type"::"Selection Contract";
            RetailDocumentHandling.RetailDocument2Sale(SalePOS, "Salesperson Code");

            POSSale.Refresh(SalePOS);
            POSSale.Modify(true, false);
            POSSession.GetSaleLine(POSSaleLine);
            if SalePOS.SalesLinesExist then
                POSSaleLine.SetLast();
        end;
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
        with SalePOS do begin
            SaleLinePOS.SetRange("Register No.", "Register No.");
            SaleLinePOS.SetRange("Sales Ticket No.", "Sales Ticket No.");
            SaleLinePOS.SetRange(Date, Today);
            SaleLinePOS.SetRange("Sale Type", SaleLinePOS."Sale Type"::Deposit);
            SaleLinePOS.SetRange(Type, SaleLinePOS.Type::Customer);
            SaleLinePOS.DeleteAll(true);
            if "Customer No." = '' then begin
                if not TouchScreenFunctions.SaleDebit(SalePOS, TempSalesHeader, Validering, false) then
                    Error('');
                if ("Customer Type" = "Customer Type"::Ord) and ("Customer No." <> '') then begin
                    if Confirm(ConfirmPosting, true) then begin
                        FormCode.CreateSalesHeader(SalePOS, TempSalesHeader);
                        if TransferToInvoice(SalePOS) then begin
                            Register.Get("Register No.");
                            POSSale.InitializeNewSale(Register, FrontEnd, POSSetup, POSSale);
                        end;
                        exit;
                    end else begin
                        "Customer No." := '';
                        Modify;
                        exit;
                    end;
                end;
                exit;
            end else begin
                if "Customer Type" = "Customer Type"::Ord then begin
                    if Confirm(ConfirmPosting, false) then begin
                        FormCode.CreateSalesHeader(SalePOS, TempSalesHeader);
                        if TransferToInvoice(SalePOS) then begin
                            Register.Get("Register No.");
                            POSSale.InitializeNewSale(Register, FrontEnd, POSSetup, POSSale);
                        end;
                        exit;
                    end else
                        exit;
                end;
            end;

            if ("Customer Type" <> "Customer Type"::Ord) then begin
                exit;
            end;
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
}
