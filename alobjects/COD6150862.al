codeunit 6150862 "POS Action - Doc. Pay&Post"
{
    // NPR5.50/MMV /20181105 CASE 300557 New action, based on CU 6150815
    // NPR5.52/MMV /20191004 CASE 352473 Added send & pdf2nav support.


    trigger OnRun()
    begin
    end;

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
        exit ('SALES_DOC_PAY_POST');
    end;

    local procedure ActionVersion(): Text
    begin
        exit ('1.2'); //NPR5.52 [352473]
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
            RegisterWorkflowStep('PayAndPostDocument','respond();');
            RegisterWorkflow(false);

        //-NPR5.52 [352473]
            RegisterBooleanParameter('PrintDocument', false);
        //+NPR5.52 [352473]
            RegisterBooleanParameter('OpenDocument', false);
            RegisterBooleanParameter('SelectCustomer', true);
        //-NPR5.52 [352473]
            RegisterBooleanParameter('SendDocument', false);
            RegisterBooleanParameter('Pdf2NavDocument', false);
        //+NPR5.52 [352473]
          end;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150701, 'OnAction', '', false, false)]
    local procedure OnAction("Action": Record "POS Action";WorkflowStep: Text;Context: DotNet npNetJObject;POSSession: Codeunit "POS Session";FrontEnd: Codeunit "POS Front End Management";var Handled: Boolean)
    var
        SalesHeader: Record "Sales Header";
        JSON: Codeunit "POS JSON Management";
        SelectCustomer: Boolean;
        OpenDocument: Boolean;
        PrintDocument: Boolean;
        Send: Boolean;
        Pdf2Nav: Boolean;
    begin
        if not Action.IsThisAction(ActionCode) then
          exit;
        Handled := true;

        JSON.InitializeJObjectParser(Context,FrontEnd);
        SelectCustomer := JSON.GetBooleanParameter('SelectCustomer', true);
        OpenDocument := JSON.GetBooleanParameter('OpenDocument', true);
        //-NPR5.52 [352473]
        PrintDocument := JSON.GetBooleanParameter('PrintDocument', true);
        Send := JSON.GetBooleanParameter('SendDocument', true);
        Pdf2Nav := JSON.GetBooleanParameter('Pdf2NavDocument', true);
        //+NPR5.52 [352473]

        if not CheckCustomer(POSSession, SelectCustomer) then
          exit;

        if not SelectDocument(Context, POSSession, FrontEnd, SalesHeader) then
          exit;

        if not ConfirmDocument(SalesHeader, OpenDocument) then
          exit;

        //-NPR5.52 [352473]
        CreateDocumentPaymentLine(POSSession, SalesHeader, PrintDocument, Send, Pdf2Nav);
        //+NPR5.52 [352473]

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

    local procedure SelectDocument(Context: DotNet npNetJObject;POSSession: Codeunit "POS Session";FrontEnd: Codeunit "POS Front End Management";var SalesHeader: Record "Sales Header"): Boolean
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

    local procedure ConfirmDocument(SalesHeader: Record "Sales Header";OpenDoc: Boolean): Boolean
    begin
        if OpenDoc then
          exit(PAGE.RunModal(SalesHeader.GetCardpageID(), SalesHeader) = ACTION::LookupOK);

        exit(true);
    end;

    local procedure CreateDocumentPaymentLine(POSSession: Codeunit "POS Session";SalesHeader: Record "Sales Header";Print: Boolean;Send: Boolean;Pdf2Nav: Boolean)
    var
        JSON: Codeunit "POS JSON Management";
        RetailSalesDocImpMgt: Codeunit "Retail Sales Doc. Imp. Mgt.";
        SalePOS: Record "Sale POS";
        POSSale: Codeunit "POS Sale";
        DocumentType: Option Quote,"Order",Invoice,CreditMemo,BlanketOrder,ReturnOrder;
        OrderType: Option NotSet,"Order",Lending;
        POSSaleLine: Codeunit "POS Sale Line";
        POSApplyCustomerEntries: Codeunit "POS Apply Customer Entries";
        InvoiceNo: Text;
    begin
        //-NPR5.52 [352473]
        RetailSalesDocImpMgt.SalesDocumentAmountToPOS(POSSession, SalesHeader, true, true, true, Print, Pdf2Nav, Send, true);
        //+NPR5.52 [352473]
    end;

    [EventSubscriber(ObjectType::Table, 6150705, 'OnGetParameterNameCaption', '', false, false)]
    procedure OnGetParameterNameCaption(POSParameterValue: Record "POS Parameter Value";var Caption: Text)
    begin
        if POSParameterValue."Action Code" <> ActionCode then
          exit;

        case POSParameterValue.Name of
          'PrintDocument' : Caption := CaptionPrintDocument;
          'OpenDocument' : Caption := CaptionOpenDoc;
          'SelectCustomer' : Caption := CaptionSelectCustomer;
        //-NPR5.52 [352473]
          'SendDocument' : Caption := CaptionSendDoc;
          'Pdf2NavDocument' : Caption := CaptionPdf2NavDoc;
        //+NPR5.52 [352473]
        end;
    end;

    [EventSubscriber(ObjectType::Table, 6150705, 'OnGetParameterDescriptionCaption', '', false, false)]
    procedure OnGetParameterDescriptionCaption(POSParameterValue: Record "POS Parameter Value";var Caption: Text)
    begin
        if POSParameterValue."Action Code" <> ActionCode then
          exit;

        case POSParameterValue.Name of
          'PrintDocument' : Caption := DescPrintDocument;
          'OpenDocument' : Caption := DescOpenDoc;
          'SelectCustomer' : Caption := DescSelectCustomer;
        //-NPR5.52 [352473]
          'SendDocument' : Caption := DescSendDoc;
          'Pdf2NavDocument' : Caption := DescPdf2NavDoc;
        //+NPR5.52 [352473]
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

