codeunit 6150863 "NPR POS Action: Doc. Prepay"
{
    var
        ActionDescription: Label 'Create a prepayment line for a sales order. Prepayment invoice will be posted & applied immediately upon sale end.';
        TextPrepaymentTitle: Label 'Prepayment';
        TextPrepaymentPctLead: Label 'Please specify prepayment % to be paid after export';
        TextPrepaymentAmountLead: Label 'Please specify prepayment amount to be paid after export';
        CaptionPrepaymentDlg: Label 'Prompt Prepayment Value';
        CaptionFixedPrepaymentValue: Label 'Fixed Prepayment Value';
        CaptionPrintDoc: Label 'Print Prepayment Document';
        CaptionPrepaymentIsAmount: Label 'Prepayment Value Is Amount';
        DescPrepaymentDlg: Label 'Ask user for prepayment percentage';
        DescFixedPrepaymentValue: Label 'Prepayment value to use either silently or as dialog default value';
        DescPrintDoc: Label 'Print standard prepayment document after posting.';
        DescPrepaymentIsAmount: Label 'The prompt or silent prepayment value is interpreted as an amount instead of percent';
        CaptionSelectCustomer: Label 'Select Customer';
        DescSelectCustomer: Label 'Prompt for customer selection if none on sale';
        CaptionSendDocument: Label 'Send Document';
        CaptionPdf2NavDocument: Label 'Pdf2Nav Document';
        DescSendDocument: Label 'Handle output via document sending profiles';
        DescPdf2NavDocument: Label 'Handle output via PDF2NAV';

    local procedure ActionCode(): Code[20]
    begin
        exit('SALES_DOC_PREPAY');
    end;

    local procedure ActionVersion(): Text[30]
    begin
        exit('1.2');
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Action", 'OnDiscoverActions', '', false, false)]
    local procedure OnDiscoverAction(var Sender: Record "NPR POS Action")
    begin
        if Sender.DiscoverAction(
            ActionCode(),
            ActionDescription,
            ActionVersion(),
            Sender.Type::Generic,
            Sender."Subscriber Instances Allowed"::Multiple) then begin
            Sender.RegisterWorkflowStep('prepaymentPct', 'param.Dialog && !param.InputIsAmount && numpad(labels.prepaymentDialogTitle, labels.prepaymentPctLead, param.FixedValue).cancel(abort);');
            Sender.RegisterWorkflowStep('prepaymentAmount', 'param.Dialog && param.InputIsAmount && numpad(labels.prepaymentDialogTitle, labels.prepaymentAmountLead, param.FixedValue).cancel(abort);');
            Sender.RegisterWorkflowStep('PrepayDocument', 'respond();');
            Sender.RegisterWorkflow(false);

            Sender.RegisterBooleanParameter('InputIsAmount', false);
            Sender.RegisterBooleanParameter('Dialog', true);
            Sender.RegisterDecimalParameter('FixedValue', 0);
            Sender.RegisterBooleanParameter('SendDocument', false);
            Sender.RegisterBooleanParameter('Pdf2NavDocument', false);
            Sender.RegisterBooleanParameter('PrintDocument', false);
            Sender.RegisterBooleanParameter('SelectCustomer', true);
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS UI Management", 'OnInitializeCaptions', '', true, true)]
    local procedure OnInitializeCaptions(Captions: Codeunit "NPR POS Caption Management")
    begin
        Captions.AddActionCaption(ActionCode(), 'prepaymentDialogTitle', TextPrepaymentTitle);
        Captions.AddActionCaption(ActionCode(), 'prepaymentPctLead', TextPrepaymentPctLead);
        Captions.AddActionCaption(ActionCode(), 'prepaymentAmtLead', TextPrepaymentAmountLead);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS JavaScript Interface", 'OnAction', '', false, false)]
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
        if not Action.IsThisAction(ActionCode()) then
            exit;
        Handled := true;

        JSON.InitializeJObjectParser(Context, FrontEnd);
        PrintPrepaymentDocument := JSON.GetBooleanParameterOrFail('PrintDocument', ActionCode());
        SelectCustomer := JSON.GetBooleanParameterOrFail('SelectCustomer', ActionCode());
        PrepaymentValue := GetPrepaymentValue(JSON);
        Send := JSON.GetBooleanParameterOrFail('SendDocument', ActionCode());
        Pdf2Nav := JSON.GetBooleanParameterOrFail('Pdf2NavDocument', ActionCode());
        InputIsAmount := JSON.GetBooleanParameterOrFail('InputIsAmount', ActionCode());

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
        SalePOS: Record "NPR POS Sale";
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
        Commit();
        exit(true);
    end;

    local procedure SelectDocument(POSSession: Codeunit "NPR POS Session"; var SalesHeader: Record "Sales Header"): Boolean
    var
        RetailSalesDocImpMgt: Codeunit "NPR Sales Doc. Imp. Mgt.";
        POSSale: Codeunit "NPR POS Sale";
        SalePOS: Record "NPR POS Sale";
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
        RetailSalesDocMgt.CreatePrepaymentLine(POSSession, SalesHeader, PrepaymentValue, Print, Send, Pdf2Nav, true, ValueIsAmount);
    end;

    procedure GetPrepaymentValue(var JSON: Codeunit "NPR POS JSON Management"): Decimal
    begin
        if JSON.GetBooleanParameterOrFail('Dialog', ActionCode()) then begin
            if JSON.GetBooleanParameterOrFail('InputIsAmount', ActionCode()) then begin
                exit(GetNumpad(JSON, 'prepaymentAmount'));
            end else begin
                exit(GetNumpad(JSON, 'prepaymentPct'));
            end;
        end else
            exit(JSON.GetDecimalParameterOrFail('FixedValue', ActionCode()));
    end;

    local procedure GetNumpad(JSON: Codeunit "NPR POS JSON Management"; Path: Text): Decimal
    var
        ReadingErr: Label 'reading in %1';
    begin
        JSON.SetScopeRoot();
        if (not JSON.SetScope('$' + Path)) then
            exit(0);

        exit(JSON.GetDecimalOrFail('numpad', StrSubstNo(ReadingErr, ActionCode())));
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Parameter Value", 'OnGetParameterNameCaption', '', false, false)]
    local procedure OnGetParameterNameCaption(POSParameterValue: Record "NPR POS Parameter Value"; var Caption: Text)
    begin
        if POSParameterValue."Action Code" <> ActionCode() then
            exit;

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
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Parameter Value", 'OnGetParameterDescriptionCaption', '', false, false)]
    local procedure OnGetParameterDescriptionCaption(POSParameterValue: Record "NPR POS Parameter Value"; var Caption: Text)
    begin
        if POSParameterValue."Action Code" <> ActionCode() then
            exit;

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
    end;
}
