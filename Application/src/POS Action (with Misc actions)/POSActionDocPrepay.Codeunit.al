codeunit 6150863 "NPR POS Action: Doc. Prepay"
{
    // NPR5.50/MMV /20181105 CASE 300557 Created object
    // NPR5.51/ALST/20190705 CASE 357848 added possibility to choose amount instead of percentage
    // NPR5.52/MMV /20191004 CASE 352473 Added better pdf2nav & send support.
    //                                   Fixed prepayment VAT.


    trigger OnRun()
    begin
    end;

    var
        ActionDescription: Label 'Create a prepayment line for a sales order. Prepayment invoice will be posted & applied immediately upon sale end.';
        ERRDOCTYPE: Label 'Wrong Document Type. Document Type is set to %1. It must be one of %2, %3, %4 or %5';
        ERRPARSED: Label 'SalesDocumentToPOS and SalesDocumentAmountToPOS can not be used simultaneously. This is an error in parameter setting on menu button for action %1.';
        ERRPARSEDCOMB: Label 'Import of amount is only supported for Document Type Order. This is an error in parameter setting on menu button for action %1.';
        TextPrepaymentTitle: Label 'Prepayment';
        TextPrepaymentPctLead: Label 'Please specify prepayment % to be paid after export';
        TextPrepaymentAmountLead: Label 'Please specify prepayment amount to be paid after export';
        CaptionOrderType: Label 'Order Type';
        CaptionPrepaymentDlg: Label 'Prompt Prepayment Value';
        CaptionFixedPrepaymentValue: Label 'Fixed Prepayment Value';
        CaptionPrintDoc: Label 'Print Prepayment Document';
        CaptionPrepaymentIsAmount: Label 'Prepayment Value Is Amount';
        DescOrderType: Label 'Filter on Order Type';
        DescPrepaymentDlg: Label 'Ask user for prepayment percentage';
        DescFixedPrepaymentValue: Label 'Prepayment value to use either silently or as dialog default value';
        DescPrintDoc: Label 'Print standard prepayment document after posting.';
        DescPrepaymentIsAmount: Label 'The prompt or silent prepayment value is interpreted as an amount instead of percent';
        OptionOrderType: Label 'Not Set,Order,Lending';
        CaptionSelectCustomer: Label 'Select Customer';
        DescSelectCustomer: Label 'Prompt for customer selection if none on sale';
        CaptionSendDocument: Label 'Send Document';
        CaptionPdf2NavDocument: Label 'Pdf2Nav Document';
        DescSendDocument: Label 'Handle output via document sending profiles';
        DescPdf2NavDocument: Label 'Handle output via PDF2NAV';

    local procedure ActionCode(): Text
    begin
        exit('SALES_DOC_PREPAY');
    end;

    local procedure ActionVersion(): Text
    begin
        exit('1.2'); //NPR5.52 [352473]
    end;

    [EventSubscriber(ObjectType::Table, 6150703, 'OnDiscoverActions', '', false, false)]
    local procedure OnDiscoverAction(var Sender: Record "NPR POS Action")
    begin
        with Sender do begin
            if DiscoverAction(
              ActionCode(),
              ActionDescription,
              ActionVersion(),
              Sender.Type::Generic,
              Sender."Subscriber Instances Allowed"::Multiple) then begin
                //-NPR5.52 [352473]
                RegisterWorkflowStep('prepaymentPct', 'param.Dialog && !param.InputIsAmount && numpad(labels.prepaymentDialogTitle, labels.prepaymentPctLead, param.FixedValue).cancel(abort);');
                RegisterWorkflowStep('prepaymentAmount', 'param.Dialog && param.InputIsAmount && numpad(labels.prepaymentDialogTitle, labels.prepaymentAmountLead, param.FixedValue).cancel(abort);');
                //+NPR5.52 [352473]
                RegisterWorkflowStep('PrepayDocument', 'respond();');
                RegisterWorkflow(false);

                //-NPR5.52 [352473]
                RegisterBooleanParameter('InputIsAmount', false);
                RegisterBooleanParameter('Dialog', true);
                RegisterDecimalParameter('FixedValue', 0);
                RegisterBooleanParameter('SendDocument', false);
                RegisterBooleanParameter('Pdf2NavDocument', false);
                RegisterBooleanParameter('PrintDocument', false);
                //+NPR5.52 [352473]
                RegisterBooleanParameter('SelectCustomer', true);
            end;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150702, 'OnInitializeCaptions', '', true, true)]
    local procedure OnInitializeCaptions(Captions: Codeunit "NPR POS Caption Management")
    var
        UI: Codeunit "NPR POS UI Management";
    begin
        //+NPR5.52 [352473]
        Captions.AddActionCaption(ActionCode, 'prepaymentDialogTitle', TextPrepaymentTitle);
        Captions.AddActionCaption(ActionCode, 'prepaymentPctLead', TextPrepaymentPctLead);
        Captions.AddActionCaption(ActionCode, 'prepaymentAmtLead', TextPrepaymentAmountLead);
        //+NPR5.52 [352473]
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150701, 'OnAction', '', false, false)]
    local procedure OnAction("Action": Record "NPR POS Action"; WorkflowStep: Text; Context: JsonObject; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean)
    var
        SalesHeader: Record "Sales Header";
        JSON: Codeunit "NPR POS JSON Management";
        PrintPrepaymentDocument: Boolean;
        PrepaymentValue: Decimal;
        SelectCustomer: Boolean;
        InputIsAmount: Boolean;
        Send: Boolean;
        Pdf2Nav: Boolean;
    begin
        if not Action.IsThisAction(ActionCode) then
            exit;
        Handled := true;

        JSON.InitializeJObjectParser(Context, FrontEnd);
        PrintPrepaymentDocument := JSON.GetBooleanParameter('PrintDocument', true);
        SelectCustomer := JSON.GetBooleanParameter('SelectCustomer', true);
        PrepaymentValue := GetPrepaymentValue(JSON);
        Send := JSON.GetBooleanParameter('SendDocument', true);
        Pdf2Nav := JSON.GetBooleanParameter('Pdf2NavDocument', true);
        InputIsAmount := JSON.GetBooleanParameter('InputIsAmount', true);

        if not CheckCustomer(POSSession, SelectCustomer) then
            exit;

        if not SelectDocument(POSSession, SalesHeader) then
            exit;

        CreatePrepaymentLine(POSSession, SalesHeader, PrintPrepaymentDocument, PrepaymentValue, InputIsAmount, Send, Pdf2Nav);

        POSSession.RequestRefreshData();
    end;

    local procedure CheckCustomer(POSSession: Codeunit "NPR POS Session"; SelectCustomer: Boolean): Boolean
    var
        POSSale: Codeunit "NPR POS Sale";
        SalePOS: Record "NPR Sale POS";
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

    local procedure SelectDocument(POSSession: Codeunit "NPR POS Session"; var SalesHeader: Record "Sales Header"): Boolean
    var
        RetailSalesDocImpMgt: Codeunit "NPR Sales Doc. Imp. Mgt.";
        POSSale: Codeunit "NPR POS Sale";
        SalePOS: Record "NPR Sale POS";
    begin
        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);

        if SalePOS."Customer No." <> '' then
            SalesHeader.SetRange("Bill-to Customer No.", SalePOS."Customer No.");
        SalesHeader.SetRange("Document Type", SalesHeader."Document Type"::Order);
        exit(RetailSalesDocImpMgt.SelectSalesDocument(SalesHeader.GetView(false), SalesHeader));
    end;

    local procedure CreatePrepaymentLine(POSSession: Codeunit "NPR POS Session"; SalesHeader: Record "Sales Header"; Print: Boolean; PrepaymentValue: Decimal; ValueIsAmount: Boolean; Send: Boolean; Pdf2Nav: Boolean)
    var
        RetailSalesDocMgt: Codeunit "NPR Sales Doc. Exp. Mgt.";
    begin
        //-NPR5.52 [352473]
        RetailSalesDocMgt.CreatePrepaymentLine(POSSession, SalesHeader, PrepaymentValue, Print, Send, Pdf2Nav, true, ValueIsAmount);
        //+NPR5.52 [352473]
    end;

    procedure GetPrepaymentValue(var JSON: Codeunit "NPR POS JSON Management"): Decimal
    begin
        //-NPR5.52 [352473]
        if JSON.GetBooleanParameter('Dialog', true) then begin
            if JSON.GetBooleanParameter('InputIsAmount', true) then begin
                exit(GetNumpad(JSON, 'prepaymentAmount'));
            end else begin
                exit(GetNumpad(JSON, 'prepaymentPct'));
            end;
        end else
            exit(JSON.GetDecimalParameter('FixedValue', true));
        //+NPR5.52 [352473]
    end;

    local procedure GetNumpad(JSON: Codeunit "NPR POS JSON Management"; Path: Text): Decimal
    begin
        JSON.SetScope('/', true);
        if (not JSON.SetScope('$' + Path, false)) then
            exit(0);

        exit(JSON.GetDecimal('numpad', true));
    end;

    [EventSubscriber(ObjectType::Table, 6150705, 'OnGetParameterNameCaption', '', false, false)]
    procedure OnGetParameterNameCaption(POSParameterValue: Record "NPR POS Parameter Value"; var Caption: Text)
    begin
        if POSParameterValue."Action Code" <> ActionCode then
            exit;

        //-NPR5.52 [352473]
        case POSParameterValue.Name of
            'Dialog':
                Caption := CaptionPrepaymentDlg;
            'FixedValue':
                Caption := CaptionFixedPrepaymentValue;
            'InputIsAmount':
                Caption := CaptionPrepaymentIsAmount;
            'PrintDocument':
                Caption := CaptionPrintDoc;
            'SelectCustomer':
                Caption := CaptionSelectCustomer;
            'SendDocument':
                Caption := CaptionSendDocument;
            'Pdf2NavDocument':
                Caption := CaptionPdf2NavDocument;
        end;
        //+NPR5.52 [352473]
    end;

    [EventSubscriber(ObjectType::Table, 6150705, 'OnGetParameterDescriptionCaption', '', false, false)]
    procedure OnGetParameterDescriptionCaption(POSParameterValue: Record "NPR POS Parameter Value"; var Caption: Text)
    begin
        if POSParameterValue."Action Code" <> ActionCode then
            exit;

        //-NPR5.52 [352473]
        case POSParameterValue.Name of
            'Dialog':
                Caption := DescPrepaymentDlg;
            'FixedValue':
                Caption := DescFixedPrepaymentValue;
            'InputIsAmount':
                Caption := DescPrepaymentIsAmount;
            'PrintDocument':
                Caption := DescPrintDoc;
            'SelectCustomer':
                Caption := DescSelectCustomer;
            'SendDocument':
                Caption := DescSendDocument;
            'Pdf2NavDocument':
                Caption := DescPdf2NavDocument;
        end;
        //+NPR5.52 [352473]
    end;

    [EventSubscriber(ObjectType::Table, 6150705, 'OnGetParameterOptionStringCaption', '', false, false)]
    procedure OnGetParameterOptionStringCaption(POSParameterValue: Record "NPR POS Parameter Value"; var Caption: Text)
    begin
        if POSParameterValue."Action Code" <> ActionCode then
            exit;

        case POSParameterValue.Name of
        end;
    end;
}

