codeunit 6150863 "POS Action - Doc. Prepay"
{
    // NPR5.50/MMV /20181105 CASE 300557 Created object
    // NPR5.51/ALST/20190705 CASE 357848 added possibility to choose amount instead of percentage


    trigger OnRun()
    begin
    end;

    var
        ActionDescription: Label 'Create a prepayment line for a sales order. Prepayment invoice will be posted & applied immediately upon sale end.';
        ERRDOCTYPE: Label 'Wrong Document Type. Document Type is set to %1. It must be one of %2, %3, %4 or %5';
        ERRPARSED: Label 'SalesDocumentToPOS and SalesDocumentAmountToPOS can not be used simultaneously. This is an error in parameter setting on menu button for action %1.';
        ERRPARSEDCOMB: Label 'Import of amount is only supported for Document Type Order. This is an error in parameter setting on menu button for action %1.';
        TextPrepaymentPctTitle: Label 'Prepayment';
        TextPrepaymentPctLead: Label 'Please specify prepayment % to be paid';
        CaptionOrderType: Label 'Order Type';
        CaptionPrepaymentDlg: Label 'Prompt Prepayment Percentage';
        CaptionFixedPrepaymentPct: Label 'Fixed Prepayment Percentage';
        CaptionPrintDoc: Label 'Print Prepayment Document';
        DescOrderType: Label 'Filter on Order Type';
        DescPrepaymentDlg: Label 'Ask user for prepayment percentage';
        DescFixedPrepaymentPct: Label 'Prepayment percentage to use either silently or as dialog default value';
        DescPrintDoc: Label 'Print standard prepayment document after posting.';
        OptionOrderType: Label 'Not Set,Order,Lending';
        CaptionSelectCustomer: Label 'Select Customer';
        DescSelectCustomer: Label 'Prompt for customer selection if none on sale';
        PrepaymentAmountCaption: Label 'Prompt Prepayment Amount';
        FixedPrepaymentAmountCaption: Label 'Fixed Prepayment Amount';
        DescPrepaymentAmountCaption: Label 'Ask user for prepayment amount';
        DescFixedPrepaymentAmountCaption: Label 'Prepayment amount to use either silently or as dialog default value';
        BooleanValue: Boolean;

    local procedure ActionCode(): Text
    begin
        exit('SALES_DOC_PREPAY');
    end;

    local procedure ActionVersion(): Text
    begin
        exit('1.0');
    end;

    [EventSubscriber(ObjectType::Table, 6150703, 'OnDiscoverActions', '', false, false)]
    local procedure OnDiscoverAction(var Sender: Record "POS Action")
    begin
        with Sender do begin
            if DiscoverAction(
              ActionCode(),
              ActionDescription,
              ActionVersion(),
              Sender.Type::Generic,
              Sender."Subscriber Instances Allowed"::Multiple) then begin
                //-NPR5.51
                // RegisterWorkflowStep('prepaymentPct','param.PrepaymentPctDialog && numpad(labels.prepaymentPctTitle, labels.prepaymentPctLead, param.FixedPrepaymentPct).cancel (abort);');
                RegisterWorkflowStep('prepaymentPct', 'if(!param.AmountPayment)' +
                                                      '{' +
                                                          'param.PrepaymentPctDialog && numpad(labels.prepaymentPctTitle, labels.prepaymentPctLead, param.FixedPrepaymentPct).cancel(abort);' +
                                                      '}' +
                                                      'else' +
                                                      '{' +
                                                          'param.PrepaymentPctDialog && numpad(labels.prepaymentAmtTitle, labels.prepaymentAmtLead, param.FixedPrepaymentPct).cancel(abort);' +
                                                      '};');
                //+NPR5.51
                RegisterWorkflowStep('PrepayDocument', 'respond();');
                RegisterWorkflow(false);

                //-NPR5.51
                //this parameter should be second to none (try to leave on top of stack)
                RegisterBooleanParameter('AmountPayment', false);
                //+NPR5.51
                RegisterBooleanParameter('PrepaymentPctDialog', true);
                RegisterDecimalParameter('FixedPrepaymentPct', 0);
                RegisterBooleanParameter('PrintPrepaymentDocument', false);
                RegisterBooleanParameter('SelectCustomer', true);
            end;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150702, 'OnInitializeCaptions', '', true, true)]
    local procedure OnInitializeCaptions(Captions: Codeunit "POS Caption Management")
    var
        UI: Codeunit "POS UI Management";
    begin
        Captions.AddActionCaption(ActionCode, 'prepaymentPctTitle', TextPrepaymentPctTitle);
        Captions.AddActionCaption(ActionCode, 'prepaymentPctLead', TextPrepaymentPctLead);
        //-NPR5.51
        Captions.AddActionCaption(ActionCode, 'prepaymentAmtTitle', PrepaymentAmountCaption);
        Captions.AddActionCaption(ActionCode, 'prepaymentAmtLead', FixedPrepaymentAmountCaption);
        //+NPR5.51
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150701, 'OnAction', '', false, false)]
    local procedure OnAction("Action": Record "POS Action"; WorkflowStep: Text; Context: JsonObject; POSSession: Codeunit "POS Session"; FrontEnd: Codeunit "POS Front End Management"; var Handled: Boolean)
    var
        SalesHeader: Record "Sales Header";
        JSON: Codeunit "POS JSON Management";
        PrintPrepaymentDocument: Boolean;
        PrepaymentVal: Decimal;
        SelectCustomer: Boolean;
    begin
        if not Action.IsThisAction(ActionCode) then
            exit;
        Handled := true;

        JSON.InitializeJObjectParser(Context, FrontEnd);
        PrintPrepaymentDocument := JSON.GetBooleanParameter('PrintPrepaymentDocument', true);
        SelectCustomer := JSON.GetBooleanParameter('SelectCustomer', true);
        //-NPR5.51
        // PrepaymentPct := GetPrepaymentPct(JSON);
        PrepaymentVal := GetPrepaymentVal(JSON);
        //+NPR5.51

        if not CheckCustomer(POSSession, SelectCustomer) then
            exit;

        if not SelectDocument(POSSession, SalesHeader) then
            exit;

        //-NPR5.51
        // CreatePrepaymentLine(POSSession, SalesHeader, PrintPrepaymentDocument, PrepaymentPrc);
        CreatePrepaymentLine(POSSession, SalesHeader, PrintPrepaymentDocument, PrepaymentVal, JSON.GetBooleanParameter('AmountPayment', true));
        //+NPR5.51

        POSSession.RequestRefreshData();
    end;

    local procedure CheckCustomer(POSSession: Codeunit "POS Session"; SelectCustomer: Boolean): Boolean
    var
        POSSale: Codeunit "POS Sale";
        SalePOS: Record "Sale POS";
        Customer: Record Customer;
    begin
        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);
        if SalePOS."Customer No." <> '' then begin
            SalePOS.TestField("Customer Type", SalePOS."Customer Type"::Ord);
            exit(true);
        end;

        if not SelectCustomer then
            exit(true);

        if PAGE.RunModal(0, Customer) <> ACTION::LookupOK then
            exit(false);

        SalePOS."Customer Type" := SalePOS."Customer Type"::Ord;
        SalePOS.Validate("Customer No.", Customer."No.");
        SalePOS.Modify(true);
        POSSale.RefreshCurrent();
        Commit;
        exit(true);
    end;

    local procedure SelectDocument(POSSession: Codeunit "POS Session"; var SalesHeader: Record "Sales Header"): Boolean
    var
        RetailSalesDocImpMgt: Codeunit "Retail Sales Doc. Imp. Mgt.";
        POSSale: Codeunit "POS Sale";
        SalePOS: Record "Sale POS";
    begin
        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);

        if SalePOS."Customer No." <> '' then
            SalesHeader.SetRange("Bill-to Customer No.", SalePOS."Customer No.");
        SalesHeader.SetRange("Document Type", SalesHeader."Document Type"::Order);
        exit(RetailSalesDocImpMgt.SelectSalesDocument(SalesHeader.GetView(false), SalesHeader));
    end;

    local procedure CreatePrepaymentLine(POSSession: Codeunit "POS Session"; SalesHeader: Record "Sales Header"; PrintPrepaymentDocument: Boolean; PrepaymentVal: Decimal; PayByAmount: Boolean)
    var
        RetailSalesDocMgt: Codeunit "Retail Sales Doc. Mgt.";
    begin
        //-NPR5.51
        // RetailSalesDocMgt.CreatePrepaymentLine(POSSession, SalesHeader, PrepaymentPct, PrintPrepaymentDocument, TRUE);
        RetailSalesDocMgt.CreatePrepaymentLine(POSSession, SalesHeader, PrepaymentVal, PrintPrepaymentDocument, true, PayByAmount);
        //+NPR5.51
    end;

    local procedure GetPrepaymentVal(var JSON: Codeunit "POS JSON Management"): Decimal
    begin
        if JSON.GetBooleanParameter('PrepaymentPctDialog', true) then
            exit(GetNumpad(JSON, 'prepaymentPct'))
        else
            exit(JSON.GetDecimalParameter('FixedPrepaymentPct', true));
    end;

    local procedure GetNumpad(JSON: Codeunit "POS JSON Management"; Path: Text): Decimal
    begin
        JSON.SetScope('/', true);
        if (not JSON.SetScope('$' + Path, false)) then
            exit(0);

        exit(JSON.GetDecimal('numpad', true));
    end;

    [EventSubscriber(ObjectType::Table, 6150705, 'OnGetParameterNameCaption', '', false, false)]
    procedure OnGetParameterNameCaption(POSParameterValue: Record "POS Parameter Value"; var Caption: Text)
    begin
        if POSParameterValue."Action Code" <> ActionCode then
            exit;

        //-NPR5.51
        if POSParameterValue.Name = 'AmountPayment' then
            if Evaluate(BooleanValue, POSParameterValue.Value) then;
        //+NPR5.51

        case POSParameterValue.Name of
            //-NPR5.51
            // 'PrepaymentPctDialog' : Caption := CaptionPrepaymentDlg;
            // 'FixedPrepaymentPct' : Caption := CaptionFixedPrepaymentPct;
            'PrepaymentPctDialog':
                begin
                    if BooleanValue then
                        Caption := PrepaymentAmountCaption
                    else
                        Caption := CaptionPrepaymentDlg;
                end;
            'FixedPrepaymentPct':
                begin
                    if BooleanValue then
                        Caption := FixedPrepaymentAmountCaption
                    else
                        Caption := CaptionFixedPrepaymentPct;
                end;
            //+NPR5.51
            'PrintPrepaymentDocument':
                Caption := CaptionPrintDoc;
            'SelectCustomer':
                Caption := CaptionSelectCustomer;
        end;
    end;

    [EventSubscriber(ObjectType::Table, 6150705, 'OnGetParameterDescriptionCaption', '', false, false)]
    procedure OnGetParameterDescriptionCaption(POSParameterValue: Record "POS Parameter Value"; var Caption: Text)
    begin
        if POSParameterValue."Action Code" <> ActionCode then
            exit;

        //-NPR5.51
        if POSParameterValue.Name = 'AmountPayment' then
            if Evaluate(BooleanValue, POSParameterValue.Value) then;
        //+NPR5.51

        case POSParameterValue.Name of
            //-NPR5.51
            // 'PrepaymentPctDialog' : Caption := DescPrepaymentDlg;
            // 'FixedPrepaymentPct' : Caption := DescFixedPrepaymentPct;
            'PrepaymentPctDialog':
                begin
                    if BooleanValue then
                        Caption := DescPrepaymentAmountCaption
                    else
                        Caption := DescPrepaymentDlg;
                end;
            'FixedPrepaymentPct':
                begin
                    if BooleanValue then
                        Caption := DescFixedPrepaymentAmountCaption
                    else
                        Caption := DescPrepaymentDlg;
                end;
            //+NPR5.51
            'PrintPrepaymentDocument':
                Caption := DescPrintDoc;
            'SelectCustomer':
                Caption := DescSelectCustomer;
        end;
    end;

    [EventSubscriber(ObjectType::Table, 6150705, 'OnGetParameterOptionStringCaption', '', false, false)]
    procedure OnGetParameterOptionStringCaption(POSParameterValue: Record "POS Parameter Value"; var Caption: Text)
    begin
        if POSParameterValue."Action Code" <> ActionCode then
            exit;

        case POSParameterValue.Name of
        end;
    end;
}

