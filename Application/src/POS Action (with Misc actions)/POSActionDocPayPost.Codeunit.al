codeunit 6150862 "NPR POS Action: Doc. Pay&Post"
{
    var
        ActionDescription: Label 'Create a payment line to balance an open sales order and post the order upon POS sale end.';
        CaptionPrintDocument: Label 'Print Document';
        DescPrintDocument: Label 'Print the sales documents after posting';
        CaptionSelectCustomer: Label 'Select Customer';
        DescSelectCustomer: Label 'Prompt for customer selection if none on sale';
        CaptionOpenDoc: Label 'Open Document';
        DescOpenDoc: Label 'Open the selected order before remaining amount is imported';
        CaptionSendDoc: Label 'Send Document';
        DescSendDoc: Label 'Use Document Sending Profiles to send the posted document';
        CaptionPdf2NavDoc: Label 'Pdf2Nav Send Document';
        DescPdf2NavDoc: Label 'Use Pdf2Nav to send the posted document';

    local procedure ActionCode(): Text
    begin
        exit('SALES_DOC_PAY_POST');
    end;

    local procedure ActionVersion(): Text
    begin
        exit('1.2');
    end;

    [EventSubscriber(ObjectType::Table, 6150703, 'OnDiscoverActions', '', false, false)]
    local procedure OnDiscoverAction(var Sender: Record "NPR POS Action")
    begin
        if Sender.DiscoverAction(
  ActionCode(),
  ActionDescription,
  ActionVersion(),
  Sender.Type::Generic,
  Sender."Subscriber Instances Allowed"::Multiple) then begin
            Sender.RegisterWorkflowStep('PayAndPostDocument', 'respond();');
            Sender.RegisterWorkflow(false);

            Sender.RegisterBooleanParameter('PrintDocument', false);
            Sender.RegisterBooleanParameter('OpenDocument', false);
            Sender.RegisterBooleanParameter('SelectCustomer', true);
            Sender.RegisterBooleanParameter('SendDocument', false);
            Sender.RegisterBooleanParameter('Pdf2NavDocument', false);
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150701, 'OnAction', '', false, false)]
    local procedure OnAction("Action": Record "NPR POS Action"; WorkflowStep: Text; Context: JsonObject; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean)
    var
        SalesHeader: Record "Sales Header";
        JSON: Codeunit "NPR POS JSON Management";
        SelectCustomer: Boolean;
        OpenDocument: Boolean;
        PrintDocument: Boolean;
        Send: Boolean;
        Pdf2Nav: Boolean;
    begin
        if not Action.IsThisAction(ActionCode()) then
            exit;
        Handled := true;

        JSON.InitializeJObjectParser(Context, FrontEnd);
        SelectCustomer := JSON.GetBooleanParameterOrFail('SelectCustomer', ActionCode());
        OpenDocument := JSON.GetBooleanParameterOrFail('OpenDocument', ActionCode());
        PrintDocument := JSON.GetBooleanParameterOrFail('PrintDocument', ActionCode());
        Send := JSON.GetBooleanParameterOrFail('SendDocument', ActionCode());
        Pdf2Nav := JSON.GetBooleanParameterOrFail('Pdf2NavDocument', ActionCode());

        if not CheckCustomer(POSSession, SelectCustomer) then
            exit;

        if not SelectDocument(POSSession, SalesHeader) then
            exit;

        if not ConfirmDocument(SalesHeader, OpenDocument) then
            exit;

        CreateDocumentPaymentLine(POSSession, SalesHeader, PrintDocument, Send, Pdf2Nav);

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

    local procedure ConfirmDocument(SalesHeader: Record "Sales Header"; OpenDoc: Boolean): Boolean
    begin
        if OpenDoc then
            exit(PAGE.RunModal(SalesHeader.GetCardpageID(), SalesHeader) = ACTION::LookupOK);

        exit(true);
    end;

    local procedure CreateDocumentPaymentLine(POSSession: Codeunit "NPR POS Session"; SalesHeader: Record "Sales Header"; Print: Boolean; Send: Boolean; Pdf2Nav: Boolean)
    var
        RetailSalesDocImpMgt: Codeunit "NPR Sales Doc. Imp. Mgt.";
    begin
        RetailSalesDocImpMgt.SalesDocumentAmountToPOS(POSSession, SalesHeader, true, true, true, Print, Pdf2Nav, Send, true);
    end;

    [EventSubscriber(ObjectType::Table, 6150705, 'OnGetParameterNameCaption', '', false, false)]
    procedure OnGetParameterNameCaption(POSParameterValue: Record "NPR POS Parameter Value"; var Caption: Text)
    begin
        if POSParameterValue."Action Code" <> ActionCode() then
            exit;

        case POSParameterValue.Name of
            'PrintDocument':
                Caption := CaptionPrintDocument;
            'OpenDocument':
                Caption := CaptionOpenDoc;
            'SelectCustomer':
                Caption := CaptionSelectCustomer;
            'SendDocument':
                Caption := CaptionSendDoc;
            'Pdf2NavDocument':
                Caption := CaptionPdf2NavDoc;
        end;
    end;

    [EventSubscriber(ObjectType::Table, 6150705, 'OnGetParameterDescriptionCaption', '', false, false)]
    procedure OnGetParameterDescriptionCaption(POSParameterValue: Record "NPR POS Parameter Value"; var Caption: Text)
    begin
        if POSParameterValue."Action Code" <> ActionCode() then
            exit;

        case POSParameterValue.Name of
            'PrintDocument':
                Caption := DescPrintDocument;
            'OpenDocument':
                Caption := DescOpenDoc;
            'SelectCustomer':
                Caption := DescSelectCustomer;
            'SendDocument':
                Caption := DescSendDoc;
            'Pdf2NavDocument':
                Caption := DescPdf2NavDoc;
        end;
    end;

    [EventSubscriber(ObjectType::Table, 6150705, 'OnGetParameterOptionStringCaption', '', false, false)]
    procedure OnGetParameterOptionStringCaption(POSParameterValue: Record "NPR POS Parameter Value"; var Caption: Text)
    begin
        if POSParameterValue."Action Code" <> ActionCode() then
            exit;

        case POSParameterValue.Name of
        end;
    end;
}
