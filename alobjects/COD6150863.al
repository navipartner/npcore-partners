codeunit 6150863 "POS Action - Doc. Prepay"
{
    // NPR5.50/MMV /20181105 CASE 300557 Created object


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

    local procedure ActionCode(): Text
    begin
        exit ('SALES_DOC_PREPAY');
    end;

    local procedure ActionVersion(): Text
    begin
        exit ('1.0');
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
            Sender."Subscriber Instances Allowed"::Multiple) then
          begin
            RegisterWorkflowStep('prepaymentPct', 'param.PrepaymentPctDialog && numpad(labels.prepaymentPctTitle, labels.prepaymentPctLead, param.FixedPrepaymentPct).cancel (abort);');
            RegisterWorkflowStep('PrepayDocument','respond();');
            RegisterWorkflow(false);

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
        Captions.AddActionCaption (ActionCode, 'prepaymentPctTitle', TextPrepaymentPctTitle);
        Captions.AddActionCaption (ActionCode, 'prepaymentPctLead', TextPrepaymentPctLead);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150701, 'OnAction', '', false, false)]
    local procedure OnAction("Action": Record "POS Action";WorkflowStep: Text;Context: JsonObject;POSSession: Codeunit "POS Session";FrontEnd: Codeunit "POS Front End Management";var Handled: Boolean)
    var
        SalesHeader: Record "Sales Header";
        JSON: Codeunit "POS JSON Management";
        PrintPrepaymentDocument: Boolean;
        PrepaymentPct: Decimal;
        SelectCustomer: Boolean;
    begin
        if not Action.IsThisAction(ActionCode) then
          exit;
        Handled := true;

        JSON.InitializeJObjectParser(Context,FrontEnd);
        PrintPrepaymentDocument := JSON.GetBooleanParameter('PrintPrepaymentDocument', true);
        SelectCustomer := JSON.GetBooleanParameter('SelectCustomer', true);
        PrepaymentPct := GetPrepaymentPct(JSON);

        if not CheckCustomer(POSSession, SelectCustomer) then
          exit;

        if not SelectDocument(POSSession, SalesHeader) then
          exit;

        CreatePrepaymentLine(POSSession, SalesHeader, PrintPrepaymentDocument, PrepaymentPct);

        POSSession.RequestRefreshData();
    end;

    local procedure CheckCustomer(POSSession: Codeunit "POS Session";SelectCustomer: Boolean): Boolean
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

    local procedure SelectDocument(POSSession: Codeunit "POS Session";var SalesHeader: Record "Sales Header"): Boolean
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

    local procedure CreatePrepaymentLine(POSSession: Codeunit "POS Session";SalesHeader: Record "Sales Header";PrintPrepaymentDocument: Boolean;PrepaymentPct: Decimal)
    var
        RetailSalesDocMgt: Codeunit "Retail Sales Doc. Mgt.";
    begin
        RetailSalesDocMgt.CreatePrepaymentLine(POSSession, SalesHeader, PrepaymentPct, PrintPrepaymentDocument, true);
    end;

    local procedure GetPrepaymentPct(var JSON: Codeunit "POS JSON Management"): Decimal
    begin
        if JSON.GetBooleanParameter('PrepaymentPctDialog', true) then
          exit(GetNumpad(JSON, 'prepaymentPct'))
        else
          exit(JSON.GetDecimalParameter('FixedPrepaymentPct', true));
    end;

    local procedure GetNumpad(JSON: Codeunit "POS JSON Management";Path: Text): Decimal
    begin
        JSON.SetScope ('/', true);
        if (not JSON.SetScope ('$'+Path, false)) then
          exit (0);

        exit (JSON.GetDecimal ('numpad', true));
    end;

    [EventSubscriber(ObjectType::Table, 6150705, 'OnGetParameterNameCaption', '', false, false)]
    procedure OnGetParameterNameCaption(POSParameterValue: Record "POS Parameter Value";var Caption: Text)
    begin
        if POSParameterValue."Action Code" <> ActionCode then
          exit;

        case POSParameterValue.Name of
          'PrepaymentPctDialog' : Caption := CaptionPrepaymentDlg;
          'FixedPrepaymentPct' : Caption := CaptionFixedPrepaymentPct;
          'PrintPrepaymentDocument' : Caption := CaptionPrintDoc;
          'SelectCustomer' : Caption := CaptionSelectCustomer;
        end;
    end;

    [EventSubscriber(ObjectType::Table, 6150705, 'OnGetParameterDescriptionCaption', '', false, false)]
    procedure OnGetParameterDescriptionCaption(POSParameterValue: Record "POS Parameter Value";var Caption: Text)
    begin
        if POSParameterValue."Action Code" <> ActionCode then
          exit;

        case POSParameterValue.Name of
          'PrepaymentPctDialog' : Caption := DescPrepaymentDlg;
          'FixedPrepaymentPct' : Caption := DescFixedPrepaymentPct;
          'PrintPrepaymentDocument' : Caption := DescPrintDoc;
          'SelectCustomer' : Caption := DescSelectCustomer;
        end;
    end;

    [EventSubscriber(ObjectType::Table, 6150705, 'OnGetParameterOptionStringCaption', '', false, false)]
    procedure OnGetParameterOptionStringCaption(POSParameterValue: Record "POS Parameter Value";var Caption: Text)
    begin
        if POSParameterValue."Action Code" <> ActionCode then
          exit;

        case POSParameterValue.Name of
        end;
    end;
}

