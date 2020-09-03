codeunit 6150806 "NPR POS Action: Receivables"
{
    // NPR5.28/TJ  /20161128  CASE 258079 Storing external doc. no value in External Document No. rather than in Reference field
    // NPR5.30/JDH /20161210  CASE 256289 Changed reference to new credit limit check CU - Zero footprint
    // NPR5.32/TJ  /20170324  CASE 269610 Fixed a problem with customer application process in Transcendence
    // NPR5.32/NPKNAV/20170526  CASE 268218 Transport NPR5.32 - 26 May 2017
    // NPR5.32.10/TSA/20170616  CASE 279495 The ClearCustomer function now resets customer prices
    // NPR5.32.10/TSA/20170616  CASE 279495 External Doc. No is stored in Reference
    // NPR5.36/ANEN/20170006  CASE 288579 Correcting  DepositText from [Deposit to: %1] to [Deposit from: %1]
    // NPR5.36/ANEN/20170919  CASE 285536 Add action parameter customerNo
    // NPR5.37/ANEN/20171007  CASE 292011 Adding search func for customer
    // NPR5.38/BR  /20171107  CASE 295074 Adding parameter for customer lookup page
    // NPR5.38/BR  /20171117  CASE 296843 Adding possibility to set a tableview
    // NPR5.39/TSA /20180130  CASE 303462 Added parameters AskExtDocNo and AskAttention
    // NPR5.40/VB  /20180306  CASE 306347 Refactored InvokeWorkflow call.
    // NPR5.40/JC  /20180313  CASE 306876 Add lookup on invoice field on open customer ledger entries
    // NPR5.42/BHR /20180214  CASE 312836 Added Security functionality
    // NPR5.43/THRO/20180604  CASE 313966 Added parameter CustLedgerEntryView - used in selection of Cust Ledger Entries with Type=ApplyPaymentToInvoices
    // NPR5.43/THRO/20180606  CASE 318038 Added OnLookupValue and OnValidateValue subscribers for parameter customerview and CustLedgerEntryView
    // NPR5.43/JC  /20180619  CASE 313664 Added new parameter InvoiceLookup
    // NPR5.45/MHA /20180817  CASE 319706 Added Ean Box Event Handler functions
    // NPR5.45/MHA /20180828  CASE 326055 Restructured Workflow so that Workflow steps reflects the actual flow of the action
    // NPR5.46/TSA /20180914  CASE 314603 Refactored the security functionality to use secure methods
    // NPR5.46/TSA /20180914  CASE 314603 Removed green code
    // NPR5.48/THRO/20181108  CASE 330780 Don't set References when skipReference is set
    // NPR5.48/TSA /20190207  CASE 344901 UpdateAmounts needs to be invoked after lines are injected.
    // NPR5.48/MHA /20190213  CASE 345847 Return value should be TRUE when only 1 customer is found in GetCustomerFromCustomerSearch()
    // NPR5.49/MHA /20190328  CASE 350374 Added MaxStrLen to EanBox.Description in DiscoverEanBoxEvents()
    // NPR5.51/ANPA/20190723  CASE 350674 Updates sale line, if customer information changes
    // NPR5.52/ALPO/20190920  CASE 364291 Stop execution if customer selection is cancelled


    trigger OnRun()
    begin
    end;

    var
        ActionDescription: Label 'This built in function handles customer receivables from the POS.';
        UNKNOWN_TYPE: Label 'Type %1 is unknown.';
        TextExtDocNoLabel: Label 'Enter External Document No.:';
        TextAttentionLabel: Label 'Enter Attention:';
        TextInvoiceNoLabel: Label 'Enter Invoice No.:';
        NothingToInvoice: Label 'There is nothing to invoice.';
        InvoiceNotSpecified: Label 'Invoice must be specfied.';
        TextAmountLabel: Label 'Enter Amount:';
        TextDeposit: Label 'Deposit from: %1';
        BalanceIsZero: Label 'Customer balance is 0, there is nothing to add.';

    [EventSubscriber(ObjectType::Table, 6150703, 'OnDiscoverActions', '', false, false)]
    local procedure OnDiscoverAction(var Sender: Record "NPR POS Action")
    begin
        with Sender do
            if DiscoverAction(
              ActionCode,
              ActionDescription,
              ActionVersion,
              Sender.Type::Generic,
              Sender."Subscriber Instances Allowed"::Multiple)
            then begin

                RegisterWorkflowStep('SelectCustomer', 'respond();');
                RegisterWorkflowStep('ExtDocNo', '(!context.skipReference) && (param.AskExtDocNo) && input(labels.ExtDocNo);');
                RegisterWorkflowStep('Attention', '(!context.skipReference) && (param.AskAttention) && input(labels.Attention);');
                //-NPR5.48 [330780]
                //RegisterWorkflowStep('SetReference','respond();if ((context.extdocno) || (context.attention)) { alert("1"); respond(); }');
                RegisterWorkflowStep('SetReference', 'if (!context.skipReference) { respond(); }');
                //-NPR5.48 [330780]
                RegisterWorkflowStep('InvoiceNo',
                  'if (param.Type == 4) {' +
                  '  if (param.InvoiceLookup == 0) {' +
                  '    input(labels.InvoiceNo).respond("InvoiceNo");' +
                  '  } else {' +
                  '    respond();' +
                  '  }' +
                  '}');
                RegisterWorkflowStep('Deposit', '(param.Type == 5) && numpad(labels.Amount).cancel(abort);');
                RegisterWorkflowStep('ProcessSalesDoc', 'respond();');

                RegisterWorkflow(false);
                //-NPR5.42 [312836]
                RegisterOptionParameter('Security', 'None,SalespersonPassword,CurrentSalespersonPassword,SupervisorPassword', 'None');
                //+NPR5.42 [312836]
                RegisterOptionParameter('Type', 'SelectCustomer,ClearCustomer,InvoiceCustomer,ApplyPaymentToInvoices,BalanceInvoice,DepositAmount,DepositCurrentSubtotal,SearchCustomerName', 'SelectCustomer');
                RegisterTextParameter('customerNo', '');

                RegisterIntegerParameter('customerlookuppageno', 0);
                RegisterTextParameter('customerview', '');
                RegisterTextParameter('CustLedgerEntryView', '');

                RegisterBooleanParameter('AskExtDocNo', true);
                RegisterBooleanParameter('AskAttention', true);

                RegisterOptionParameter('InvoiceLookup', 'Text,List', 'Text');

            end;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150702, 'OnInitializeCaptions', '', true, true)]
    local procedure OnInitializeCaptions(Captions: Codeunit "NPR POS Caption Management")
    var
        UI: Codeunit "NPR POS UI Management";
    begin
        Captions.AddActionCaption(ActionCode, 'ExtDocNo', TextExtDocNoLabel);
        Captions.AddActionCaption(ActionCode, 'Attention', TextAttentionLabel);
        Captions.AddActionCaption(ActionCode, 'InvoiceNo', TextInvoiceNoLabel);
        Captions.AddActionCaption(ActionCode, 'Amount', TextAmountLabel);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150701, 'OnAction', '', false, false)]
    local procedure OnAction("Action": Record "NPR POS Action"; WorkflowStep: Text; Context: JsonObject; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean)
    var
        JSON: Codeunit "NPR POS JSON Management";
        SaleLine: Codeunit "NPR POS Sale Line";
    begin
        if not Action.IsThisAction(ActionCode) then
            exit;

        JSON.InitializeJObjectParser(Context, FrontEnd);

        case WorkflowStep of
            //-NPR5.45 [326055]
            'SelectCustomer':
                begin
                    Handled := true;
                    OnActionSelectCustomer(JSON, POSSession, FrontEnd);
                    exit;
                end;
            'SetReference':
                begin
                    Handled := true;
                    OnActionSetReference(JSON, POSSession);
                    exit;
                end;
            'InvoiceNo':
                begin
                    Handled := true;
                    OnActionInvoiceNo(JSON, POSSession, FrontEnd);
                    exit;
                end;
            'ProcessSalesDoc':
                begin
                    Handled := true;
                    OnActionProcessSalesDoc(JSON, POSSession);
                    //-NPR5.51 [350674]
                    POSSession.GetSaleLine(SaleLine);
                    SaleLine.UpdateLine();

                    //+NPR5.51 [350674]
                    POSSession.RequestRefreshData();
                    exit;
                end;
        //+NPR5.45 [326055]
        end;
        //  ERROR (UNKNOWN_TYPE, Type);
        // END;
        // Handled := TRUE;
        // POSSession.RequestRefreshData();
        //+NPR5.45 [326055]
    end;

    local procedure ActionCode(): Text
    begin
        exit('RECEIVABLES');
    end;

    local procedure ActionVersion(): Text
    begin

        exit('1.9'); //-+NPR5.46 [314603]
    end;

    local procedure SelectCustomerUI(var CustomerNo: Code[20]; CustomerLookupPageNo: Integer; CustomerView: Text): Boolean
    var
        Customer: Record Customer;
    begin

        if CustomerView <> '' then
            Customer.SetView(CustomerView);

        if (ACTION::LookupOK <> PAGE.RunModal(CustomerLookupPageNo, Customer)) then
            exit(false);

        CustomerNo := Customer."No.";
        exit(CustomerNo <> '');
    end;

    local procedure AssignCustomer(var SalePOS: Record "NPR Sale POS"; CustomerNo: Code[20]; CustomerLookupPageNo: Integer; CustomerView: Text): Boolean
    begin
        if (CustomerNo = '') then
            if (not SelectCustomerUI(CustomerNo, CustomerLookupPageNo, CustomerView)) then
                Error('');  //NPR5.52 [364291]
                            //EXIT (FALSE);  //NPR5.52 [364291]-revoked

        SalePOS."Customer Type" := SalePOS."Customer Type"::Ord;
        SalePOS."Customer No." := '';
        SalePOS.Validate("Customer No.", CustomerNo);
        exit(true);
    end;

    local procedure GetInput(JSON: Codeunit "NPR POS JSON Management"; Path: Text): Text
    begin
        JSON.SetScope('/', true);
        if (not JSON.SetScope('$' + Path, false)) then
            exit('');

        exit(JSON.GetString('input', true));
    end;

    local procedure GetDecimal(JSON: Codeunit "NPR POS JSON Management"; Path: Text): Decimal
    begin
        JSON.SetScope('/', true);
        if (not JSON.SetScope('$' + Path, false)) then
            exit(0);

        exit(JSON.GetDecimal('numpad', true));
    end;

    local procedure SelectFromOpenEntries(var SalePOS: Record "NPR Sale POS"; POSSession: Codeunit "NPR POS Session"; CustLedgerEntryView: Text)
    var
        POSSalesLine: Codeunit "NPR POS Sale Line";
        LinePOS: Record "NPR Sale Line POS";
        ApplyCustomerEntries: Codeunit "NPR POS Apply Customer Entries";
    begin
        POSSession.GetSaleLine(POSSalesLine);

        Clear(LinePOS);

        LinePOS.Type := LinePOS.Type::Customer;

        LinePOS."No." := SalePOS."Customer No.";
        LinePOS.Validate("Buffer ID", LinePOS."Register No." + '-' + LinePOS."Sales Ticket No.");

        POSSalesLine.InsertDepositLine(LinePOS, 0);

        ApplyCustomerEntries.SetCustLedgerEntryView(CustLedgerEntryView);
        ApplyCustomerEntries.Run(LinePOS);
    end;

    local procedure BalanceInvoice(var SalePOS: Record "NPR Sale POS"; POSSession: Codeunit "NPR POS Session"; InvoiceNo: Code[20])
    var
        POSSalesLine: Codeunit "NPR POS Sale Line";
        LinePOS: Record "NPR Sale Line POS";
        TouchScreenFunctions: Codeunit "NPR Touch Screen - Func.";
    begin
        if (InvoiceNo = '') then
            Error(InvoiceNotSpecified);

        POSSession.GetSaleLine(POSSalesLine);

        Clear(LinePOS);
        POSSalesLine.InsertDepositLine(LinePOS, 0);
        LinePOS.Type := LinePOS.Type::Customer;

        InvoiceNo := TouchScreenFunctions.BalanceInvoice(SalePOS, LinePOS, InvoiceNo);
        if (InvoiceNo = '') then begin
            POSSalesLine.DeleteLine();
            exit;
        end;

        LinePOS."No." := SalePOS."Customer No.";
        //-NPR5.48 [344901]
        LinePOS.UpdateAmounts(LinePOS);
        //+NPR5.48 [344901]
        LinePOS.Modify();
        SalePOS.Modify();
        ;
    end;

    local procedure CreateAndPostInvoice(var SalePOS: Record "NPR Sale POS")
    var
        SaleLinePOS: Record "NPR Sale Line POS";
        RetailSalesDocMgt: Codeunit "NPR Sales Doc. Exp. Mgt.";
    begin
        with SalePOS do begin
            SaleLinePOS.SetRange("Register No.", "Register No.");
            SaleLinePOS.SetRange("Sales Ticket No.", "Sales Ticket No.");
            SaleLinePOS.SetRange(Date, Today);
            SaleLinePOS.SetRange("Sale Type", SaleLinePOS."Sale Type"::Deposit);
            SaleLinePOS.SetRange(Type, SaleLinePOS.Type::Customer);
            SaleLinePOS.DeleteAll(true);

            CheckCustCredit(SalePOS);
            RetailSalesDocMgt.ProcessPOSSale(SalePOS);
        end;
    end;

    local procedure DepositAmount(var SalePOS: Record "NPR Sale POS"; POSSession: Codeunit "NPR POS Session"; AmountToDeposit: Decimal)
    var
        POSSalesLine: Codeunit "NPR POS Sale Line";
        LinePOS: Record "NPR Sale Line POS";
    begin
        POSSession.GetSaleLine(POSSalesLine);

        POSSalesLine.GetDepositLine(LinePOS);
        LinePOS.Type := LinePOS.Type::Customer;
        LinePOS."No." := SalePOS."Customer No.";
        LinePOS.Amount := AmountToDeposit;
        LinePOS."Amount Including VAT" := AmountToDeposit;
        LinePOS."Unit Price" := AmountToDeposit;
        LinePOS.Description := StrSubstNo(TextDeposit, SalePOS.Name);
        POSSalesLine.InsertDepositLine(LinePOS, 0);
    end;

    local procedure CheckCustCredit(SalePos: Record "NPR Sale POS")
    var
        RetailSetup: Record "NPR Retail Setup";
        TempSalesHeader: Record "Sales Header" temporary;
        FormCode: Codeunit "NPR Retail Form Code";
        POSCheckCrLimit: Codeunit "NPR POS-Check Cr. Limit";
    begin
        RetailSetup.Get();

        FormCode.CreateSalesHeader(SalePos, TempSalesHeader);
        if RetailSetup."Customer Credit Level Warning" then
            if not POSCheckCrLimit.SalesHeaderPOSCheck(TempSalesHeader) then
                Error('');
    end;

    local procedure OnActionSelectCustomer(JSON: Codeunit "NPR POS JSON Management"; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management")
    var
        Customer: Record Customer;
        SalePOS: Record "NPR Sale POS";
        POSSale: Codeunit "NPR POS Sale";
        CustomerNo: Code[20];
        CustomerLookupPageNo: Integer;
        Type: Integer;
        CustomerSearchString: Text;
        CustomerView: Text;
        PrevRec: Text;
    begin
        //-NPR5.45 [326055]
        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);
        SalePOS.Find;

        JSON.SetScope('parameters', true);
        CustomerSearchString := JSON.GetString('customerNo', false);
        CustomerNo := CopyStr(CustomerSearchString, 1, MaxStrLen(CustomerNo));
        CustomerLookupPageNo := JSON.GetInteger('customerlookuppageno', false);
        CustomerView := JSON.GetString('customerview', false);

        Type := JSON.GetInteger('Type', true);
        case Type of
            0:  //SelectCustomer
                begin
                    PrevRec := Format(SalePOS);

                    AssignCustomer(SalePOS, CustomerNo, CustomerLookupPageNo, CustomerView);

                    if PrevRec <> Format(SalePOS) then begin
                        POSSale.Refresh(SalePOS);
                        POSSale.Modify(false, false);
                    end;
                end;
            1:  //ClearCustomer
                begin
                    PrevRec := Format(SalePOS);
                    SalePOS.Validate("Customer No.", '');
                    SalePOS."Customer Type" := SalePOS."Customer Type"::Cash;
                    SalePOS.Reference := '';
                    SalePOS."Contact No." := '';
                    if PrevRec <> Format(SalePOS) then begin
                        POSSale.Refresh(SalePOS);
                        POSSale.Modify(false, false);
                    end;

                    SetSkipReference(JSON, FrontEnd);
                end;
            2, 3, 5, 6:  //InvoiceCustomer,ApplyPaymentToInvoices,DepositAmount,DepositCurrentSubtotal
                begin
                    if (SalePOS."Customer Type" = SalePOS."Customer Type"::Ord) and (SalePOS."Customer No." <> '') then begin
                        //-NPR5.48 [330780]
                        if (SalePOS.Reference <> '') and (SalePOS."Contact No." <> '') then
                            //+NPR5.48 [330780]
                            SetSkipReference(JSON, FrontEnd);
                        exit;
                    end;

                    AssignCustomer(SalePOS, CustomerNo, CustomerLookupPageNo, CustomerView);
                end;
            4:  //BalanceInvoice
                begin
                    SetSkipReference(JSON, FrontEnd);
                    exit;
                end;
            7:  //SearchCustomerName
                begin
                    if not GetCustomerFromCustomerSearch(CustomerSearchString) then
                        Error('');

                    CustomerNo := CustomerSearchString;
                    AssignCustomer(SalePOS, CustomerNo, CustomerLookupPageNo, CustomerView);
                    POSSale.Refresh(SalePOS);
                    POSSale.Modify(false, false);
                end;
        end;
        //+NPR5.45 [326055]
    end;

    local procedure OnActionSetReference(JSON: Codeunit "NPR POS JSON Management"; POSSession: Codeunit "NPR POS Session")
    var
        SalePOS: Record "NPR Sale POS";
        POSSale: Codeunit "NPR POS Sale";
        Attention: Text;
        ExtDocNo: Text;
        PrevRec: Text;
    begin
        //-NPR5.45 [326055]
        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);
        SalePOS.Find;

        PrevRec := Format(SalePOS);
        //-NPR5.48 [330780]
        //ExtDocNo := GetInput(JSON,'ExtDocNo');
        //Attention := GetInput(JSON,'Attention');
        //SalePOS.VALIDATE(Reference,COPYSTR (ExtDocNo,1,MAXSTRLEN (SalePOS.Reference)));
        //SalePOS.VALIDATE("Contact No.",COPYSTR (Attention,1,MAXSTRLEN (SalePOS."Contact No.")));
        if JSON.GetBooleanParameter('AskExtDocNo', true) then begin
            ExtDocNo := GetInput(JSON, 'ExtDocNo');
            SalePOS.Validate(Reference, CopyStr(ExtDocNo, 1, MaxStrLen(SalePOS.Reference)));
        end;
        if JSON.GetBooleanParameter('AskAttention', true) then begin
            Attention := GetInput(JSON, 'Attention');
            SalePOS.Validate("Contact No.", CopyStr(Attention, 1, MaxStrLen(SalePOS."Contact No.")));
        end;
        //+NPR5.48 [330780]

        if PrevRec <> Format(SalePOS) then begin
            POSSale.Refresh(SalePOS);
            POSSale.Modify(false, false);
        end;
        //+NPR5.45 [326055]
    end;

    local procedure OnActionInvoiceNo(JSON: Codeunit "NPR POS JSON Management"; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management")
    var
        CustLedgerEntry: Record "Cust. Ledger Entry";
        SalePOS: Record "NPR Sale POS";
        SalesInvHeader: Record "Sales Invoice Header";
        POSSale: Codeunit "NPR POS Sale";
        InvoiceNo: Code[20];
        InvoiceLookup: Integer;
        LookupPage: Integer;
    begin
        //-NPR5.45 [326055]
        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);
        SalePOS.Find;

        JSON.SetScope('parameters', true);
        InvoiceLookup := JSON.GetInteger('InvoiceLookup', true);
        case InvoiceLookup of
            0:  //Text
                begin
                    JSON.SetScope('/', true);
                    InvoiceNo := CopyStr(UpperCase(JSON.GetString('InvoiceNo', true)), 1, MaxStrLen(InvoiceNo));
                end;
            1:  //List
                begin
                    CustLedgerEntry.SetRange(Open, true);
                    CustLedgerEntry.SetRange("Document Type", CustLedgerEntry."Document Type"::Invoice);
                    CustLedgerEntry.SetFilter("Document No.", '<>%1', '');
                    if SalePOS."Customer Type" = SalePOS."Customer Type"::Ord then
                        CustLedgerEntry.SetFilter("Customer No.", SalePOS."Customer No.");
                    if PAGE.RunModal(0, CustLedgerEntry) = ACTION::LookupOK then
                        InvoiceNo := CustLedgerEntry."Document No.";
                end;
        end;

        if InvoiceNo = '' then
            exit;

        SalesInvHeader.Get(InvoiceNo);
        JSON.SetScope('/', true);
        JSON.SetContext('InvoiceNo', InvoiceNo);
        FrontEnd.SetActionContext(ActionCode(), JSON);
        //+NPR5.45 [326055]
    end;

    local procedure OnActionProcessSalesDoc(JSON: Codeunit "NPR POS JSON Management"; POSSession: Codeunit "NPR POS Session")
    var
        Customer: Record Customer;
        SalePOS: Record "NPR Sale POS";
        POSPaymentLine: Codeunit "NPR POS Payment Line";
        POSSale: Codeunit "NPR POS Sale";
        Deposit: Decimal;
        PaidAmount: Decimal;
        ReturnAmount: Decimal;
        SalesAmount: Decimal;
        SubTotal: Decimal;
        Type: Integer;
        CustLedgerEntryView: Text;
        InvoiceNo: Code[20];
    begin
        //-NPR5.45 [326055]
        JSON.SetScope('parameters', true);
        Type := JSON.GetInteger('Type', true);

        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);
        SalePOS.Find;

        case Type of
            0, 1, 7:  //SelectCustomer,ClearCustomer,SearchCustomerName
                begin
                    exit;
                end;
            2:  //InvoiceCustomer
                begin
                    POSSession.GetPaymentLine(POSPaymentLine);
                    POSPaymentLine.CalculateBalance(SalesAmount, PaidAmount, ReturnAmount, SubTotal);
                    if SubTotal <= 0 then
                        Error(NothingToInvoice);
                    CreateAndPostInvoice(SalePOS);
                    POSSale.SelectViewForEndOfSale(POSSession);
                end;
            3:  //ApplyPaymentToInvoices
                begin
                    CustLedgerEntryView := JSON.GetStringParameter('CustLedgerEntryView', true);
                    SelectFromOpenEntries(SalePOS, POSSession, CustLedgerEntryView);
                    POSSession.ChangeViewSale();
                end;
            4:  //BalanceInvoice
                begin
                    JSON.SetScope('/', true);
                    InvoiceNo := JSON.GetString('InvoiceNo', false);
                    BalanceInvoice(SalePOS, POSSession, InvoiceNo);

                    POSSale.Refresh(SalePOS);
                    POSSale.Modify(false, false);
                    POSSession.ChangeViewSale();
                end;
            5:  //DepositAmount
                begin
                    JSON.SetScope('/', true);
                    JSON.SetScope('$Deposit', true);
                    Deposit := JSON.GetDecimal('numpad', true);
                    DepositAmount(SalePOS, POSSession, Deposit)
                end;
            6:  //DepositCurrentSubtotal
                begin
                    Customer.Get(SalePOS."Customer No.");
                    Customer.CalcFields("Balance (LCY)");
                    if Customer."Balance (LCY)" = 0 then
                        Error(BalanceIsZero);
                    DepositAmount(SalePOS, POSSession, Customer."Balance (LCY)");
                end;
        end;
        //HERE

        POSSession.RequestRefreshData();
        //+NPR5.45 [326055]
    end;

    [EventSubscriber(ObjectType::Table, 6150705, 'OnLookupValue', '', true, true)]
    local procedure OnLookupCustomerView(var POSParameterValue: Record "NPR POS Parameter Value"; Handled: Boolean)
    begin
        //-NPR5.43 [318038]
        if (POSParameterValue."Action Code" <> ActionCode) or (POSParameterValue.Name <> 'customerview') or (POSParameterValue."Data Type" <> POSParameterValue."Data Type"::Text) then
            exit;
        POSParameterValue.Value := POSParameterValue.GetTableViewString(18, POSParameterValue.Value);
        Handled := true;
        //+NPR5.43 [318038]
    end;

    [EventSubscriber(ObjectType::Table, 6150705, 'OnValidateValue', '', true, true)]
    local procedure OnValidateCustomerView(var POSParameterValue: Record "NPR POS Parameter Value")
    var
        RecRef: RecordRef;
    begin
        //-NPR5.43 [318038]
        if (POSParameterValue."Action Code" <> ActionCode) or (POSParameterValue.Name <> 'customerview') or (POSParameterValue."Data Type" <> POSParameterValue."Data Type"::Text) then
            exit;
        if POSParameterValue.Value <> '' then begin
            RecRef.Open(18);
            RecRef.SetView(POSParameterValue.Value);
            POSParameterValue.Value := RecRef.GetView(false);
        end;
        //+NPR5.43 [318038]
    end;

    [EventSubscriber(ObjectType::Table, 6150705, 'OnValidateValue', '', true, true)]
    local procedure OnValidateCustLedgerEntryView(var POSParameterValue: Record "NPR POS Parameter Value")
    var
        RecRef: RecordRef;
        PageBuilder: FilterPageBuilder;
    begin
        //-NPR5.43 [318038]
        if (POSParameterValue."Action Code" <> ActionCode) or (POSParameterValue.Name <> 'CustLedgerEntryView') or (POSParameterValue."Data Type" <> POSParameterValue."Data Type"::Text) then
            exit;
        if POSParameterValue.Value <> '' then begin
            RecRef.Open(21);
            RecRef.SetView(POSParameterValue.Value);
            POSParameterValue.Value := RecRef.GetView(false);
        end;
        //+NPR5.43 [318038]
    end;

    local procedure SetSkipReference(JSON: Codeunit "NPR POS JSON Management"; FrontEnd: Codeunit "NPR POS Front End Management")
    begin
        //-NPR5.45 [326055]
        JSON.SetScope('/', true);
        JSON.SetContext('skipReference', true);
        FrontEnd.SetActionContext(ActionCode(), JSON);
        //+NPR5.45 [326055]
    end;

    local procedure "--Ext WF"()
    begin
    end;

    procedure SelectCustomerWorkFlow(Context: DotNet JObject; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management")
    var
        POSAction: Record "NPR POS Action";
    begin

        if not POSSession.RetrieveSessionAction(ActionCode, POSAction) then
            POSAction.Get(ActionCode);

        POSAction.SetWorkflowInvocationParameter('Type', 0, FrontEnd);
        FrontEnd.InvokeWorkflow(POSAction);
    end;

    local procedure "--- Ean Box Event Handling"()
    begin
    end;

    [EventSubscriber(ObjectType::Codeunit, 6060105, 'DiscoverEanBoxEvents', '', true, true)]
    local procedure DiscoverEanBoxEvents(var EanBoxEvent: Record "NPR Ean Box Event")
    var
        Customer: Record Customer;
        CustLedgerEntry: Record "Cust. Ledger Entry";
    begin
        //-NPR5.45 [319706]
        if not EanBoxEvent.Get(EventCodeCustNo()) then begin
            EanBoxEvent.Init;
            EanBoxEvent.Code := EventCodeCustNo();
            EanBoxEvent."Module Name" := Customer.TableCaption;
            //-NPR5.49 [350374]
            //EanBoxEvent.Description := CustLedgerEntry.FIELDCAPTION("Customer No.");
            EanBoxEvent.Description := CopyStr(CustLedgerEntry.FieldCaption("Customer No."), 1, MaxStrLen(EanBoxEvent.Description));
            //+NPR5.49 [350374]
            EanBoxEvent."Action Code" := ActionCode();
            EanBoxEvent."POS View" := EanBoxEvent."POS View"::Sale;
            EanBoxEvent."Event Codeunit" := CurrCodeunitId();
            EanBoxEvent.Insert(true);
        end;

        if not EanBoxEvent.Get(EventCodeCustSearch()) then begin
            EanBoxEvent.Init;
            EanBoxEvent.Code := EventCodeCustSearch();
            EanBoxEvent."Module Name" := Customer.TableCaption;
            //-NPR5.49 [350374]
            //EanBoxEvent.Description := Customer.FIELDCAPTION("Search Name");
            EanBoxEvent.Description := CopyStr(Customer.FieldCaption("Search Name"), 1, MaxStrLen(EanBoxEvent.Description));
            //+NPR5.49 [350374]
            EanBoxEvent."Action Code" := ActionCode();
            EanBoxEvent."POS View" := EanBoxEvent."POS View"::Sale;
            EanBoxEvent."Event Codeunit" := CurrCodeunitId();
            EanBoxEvent.Insert(true);
        end;
        //+NPR5.45 [319706]
    end;

    [EventSubscriber(ObjectType::Codeunit, 6060105, 'OnInitEanBoxParameters', '', true, true)]
    local procedure OnInitEanBoxParameters(var Sender: Codeunit "NPR Ean Box Setup Mgt."; EanBoxEvent: Record "NPR Ean Box Event")
    begin
        //-NPR5.45 [319706]
        case EanBoxEvent.Code of
            EventCodeCustNo():
                begin
                    Sender.SetNonEditableParameterValues(EanBoxEvent, 'customerNo', true, '');
                    Sender.SetNonEditableParameterValues(EanBoxEvent, 'Type', false, 'SelectCustomer');
                end;
            EventCodeCustSearch():
                begin
                    Sender.SetNonEditableParameterValues(EanBoxEvent, 'customerNo', true, '');
                    Sender.SetNonEditableParameterValues(EanBoxEvent, 'Type', false, 'SearchCustomerName');
                end;
        end;
        //+NPR5.45 [319706]
    end;

    [EventSubscriber(ObjectType::Codeunit, 6060107, 'SetEanBoxEventInScope', '', true, true)]
    local procedure SetEanBoxEventInScopeCustNo(EanBoxSetupEvent: Record "NPR Ean Box Setup Event"; EanBoxValue: Text; var InScope: Boolean)
    var
        Customer: Record Customer;
    begin
        //-NPR5.45 [319706]
        if EanBoxSetupEvent."Event Code" <> EventCodeCustNo() then
            exit;
        if StrLen(EanBoxValue) > MaxStrLen(Customer."No.") then
            exit;

        if Customer.Get(UpperCase(EanBoxValue)) then
            InScope := true;
        //+NPR5.45 [319706]
    end;

    [EventSubscriber(ObjectType::Codeunit, 6060107, 'SetEanBoxEventInScope', '', true, true)]
    local procedure SetEanBoxEventInScopeCustSearch(EanBoxSetupEvent: Record "NPR Ean Box Setup Event"; EanBoxValue: Text; var InScope: Boolean)
    var
        Customer: Record Customer;
    begin
        //-NPR5.45 [319706]
        if EanBoxSetupEvent."Event Code" <> EventCodeCustSearch() then
            exit;
        if StrLen(EanBoxValue) > MaxStrLen(Customer."Search Name") then
            exit;

        SetCustomerSearchFilter(EanBoxValue, Customer);
        if Customer.FindFirst then
            InScope := true;
        //+NPR5.45 [319706]
    end;

    local procedure EventCodeCustNo(): Code[20]
    begin
        //-NPR5.45 [319706]
        exit('CUSTOMERNO');
        //+NPR5.45 [319706]
    end;

    local procedure EventCodeCustSearch(): Code[20]
    begin
        //-NPR5.45 [319706]
        exit('CUSTOMERSEARCH');
        //+NPR5.45 [319706]
    end;

    local procedure CurrCodeunitId(): Integer
    begin
        //-NPR5.45 [319706]
        exit(CODEUNIT::"NPR POS Action: Receivables");
        //+NPR5.45 [319706]
    end;

    local procedure "--- Item Search"()
    begin
    end;

    local procedure GetCustomerFromCustomerSearch(var CustomerIdentifyerString: Text) CustomerFound: Boolean
    var
        Customer: Record Customer;
        SearchFilter: Text;
        SearchString: Text;
        CustomerList: Page "Customer List";
        CustomerNo: Code[20];
    begin
        //-NPR5.45 [319706]
        // SearchString := COPYSTR (CustomerIdentifyerString, 1, MAXSTRLEN (Customer."Search Name"));
        // SearchString := UPPERCASE(SearchString);
        // SearchFilter := '*'+SearchString+'*';
        //
        // Customer.SETFILTER(Blocked, '=%1', Customer.Blocked::" ");
        // Customer.SETFILTER("Search Name", SearchFilter);
        //
        // IF Customer.ISEMPTY THEN BEGIN
        //  EXIT(FALSE);
        // END;
        //
        // IF Customer.COUNT = 1 THEN BEGIN
        //  Customer.FINDFIRST;
        //
        //  CustomerIdentifyerString := Customer."No.";
        //  EXIT(TRUE);
        // END;
        SetCustomerSearchFilter(CustomerIdentifyerString, Customer);
        if not Customer.FindFirst then
            exit(false);

        CustomerIdentifyerString := Customer."No.";
        Customer.FindLast;
        if CustomerIdentifyerString = Customer."No." then
            //-NPR5.48 [345847]
            //EXIT;
            exit(true);
        //+NPR5.48 [345847]
        //+NPR5.45 [319706]

        CustomerList.Editable(false);
        CustomerList.LookupMode(true);
        CustomerList.SetTableView(Customer);
        if CustomerList.RunModal = ACTION::LookupOK then begin
            CustomerList.GetRecord(Customer);
            CustomerIdentifyerString := Customer."No.";
            exit(true);
        end else begin
            exit(false);
        end;
    end;

    local procedure SetCustomerSearchFilter(CustomerIdentifierString: Text; var Customer: Record Customer)
    var
        SearchFilter: Text;
        SearchString: Text;
    begin
        //-NPR5.45 [319706]
        Clear(Customer);

        SearchString := CopyStr(CustomerIdentifierString, 1, MaxStrLen(Customer."Search Name"));
        SearchString := UpperCase(SearchString);
        SearchFilter := '*' + SearchString + '*';
        if CustomerIdentifierString = '' then
            SearchFilter := StrSubstNo('=%1', '');

        Customer.SetCurrentKey("Search Name");
        Customer.SetFilter("Search Name", SearchFilter);
        Customer.SetRange(Blocked, Customer.Blocked::" ");
        //+NPR5.45 [319706]
    end;
}

