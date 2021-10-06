codeunit 6150621 "NPR POS Action: Doc. Ship&Post"
{
    var
        ActionDescriptionLbl: Label 'Post document as a shipment.';
        CaptionPrintDocumentLbl: Label 'Print Document';
        DescPrintDocumentLbl: Label 'Print the sales documents after posting';
        CaptionSelectCustomerLbl: Label 'Select Customer';
        DescSelectCustomerLbl: Label 'Prompt for customer selection if none on sale';
        CaptionOpenDocLbl: Label 'Open Document';
        DescOpenDocLbl: Label 'Open the selected order before remaining amount is imported';
        CaptionSendDocLbl: Label 'Send Document';
        DescSendDocLbl: Label 'Use Document Sending Profiles to send the posted document';
        CaptionPdf2NavDocLbl: Label 'Pdf2Nav Send Document';
        DescPdf2NavDocLbl: Label 'Use Pdf2Nav to send the posted document';

        CaptionShowPostedMessageLbl: Label 'Show Posted Message';
        DescShowPostedMessageLbl: Label 'Show message after shipping';

    local procedure ActionCode(): Code[20]
    begin
        exit('SALES_DOC_SHIP_POST');
    end;

    local procedure ActionVersion(): Text[30]
    begin
        exit('1.0');
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Action", 'OnDiscoverActions', '', false, false)]
    local procedure OnDiscoverAction(var Sender: Record "NPR POS Action")
    begin
        if Sender.DiscoverAction20(ActionCode(), ActionDescriptionLbl, CopyStr(ActionVersion(), 1, 20)) then begin
            Sender.RegisterWorkflow20('await workflow.respond("ShipAndPostDocument");');
            Sender.RegisterDataSourceBinding('BUILTIN_SALELINE');

            Sender.RegisterBooleanParameter('OpenDocument', false);
            Sender.RegisterBooleanParameter('SelectCustomer', true);
            Sender.RegisterBooleanParameter('SendDocument', false);
            Sender.RegisterBooleanParameter('Pdf2NavDocument', false);
            Sender.RegisterBooleanParameter('PrintDocument', false);
            Sender.RegisterBooleanParameter('ShowPostedMessage', true);
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Workflows 2.0", 'OnAction', '', true, true)]
    local procedure OnAction20(Action: Record "NPR POS Action"; WorkflowStep: Text; Context: Codeunit "NPR POS JSON Management"; POSSession: Codeunit "NPR POS Session"; State: Codeunit "NPR POS WF 2.0: State"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean);
    var
        SalesHeader: Record "Sales Header";
        SalesDocExpMgt: Codeunit "NPR Sales Doc. Exp. Mgt.";
        SelectCustomer, OpenDocument : Boolean;
    begin
        if not Action.IsThisAction(ActionCode()) then
            exit;
        Handled := true;

        SelectCustomer := Context.GetBooleanParameterOrFail('SelectCustomer', ActionCode());
        OpenDocument := Context.GetBooleanParameterOrFail('OpenDocument', ActionCode());

        if not CheckCustomer(POSSession, SelectCustomer) then
            exit;

        if not SelectDocument(POSSession, SalesHeader) then
            exit;

        if not ConfirmDocument(SalesHeader, OpenDocument) then
            exit;

        SetParameters(Context, SalesDocExpMgt);
        ShipSalesDocumentFromPOS(POSSession, SalesHeader, SalesDocExpMgt);

        POSSession.RequestRefreshData();
        POSSession.StartTransaction();
        POSSession.ChangeViewSale();
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

    local procedure SetParameters(var Context: Codeunit "NPR POS JSON Management"; var SalesDocExpMgt: Codeunit "NPR Sales Doc. Exp. Mgt.")
    var
        ShowPostedMessage, PrintDocument, Send, Pdf2Nav : Boolean;
    begin
        PrintDocument := Context.GetBooleanParameterOrFail('PrintDocument', ActionCode());
        Send := Context.GetBooleanParameterOrFail('SendDocument', ActionCode());
        Pdf2Nav := Context.GetBooleanParameterOrFail('Pdf2NavDocument', ActionCode());
        ShowPostedMessage := Context.GetBooleanParameterOrFail('ShowPostedMessage', ActionCode());

        SalesDocExpMgt.SetPrint(PrintDocument);
        SalesDocExpMgt.SetSendPostedPdf2Nav(Pdf2Nav);
        SalesDocExpMgt.SetSendDocument(Send);
        SalesDocExpMgt.SetShowPostedMessage(ShowPostedMessage);
    end;

    local procedure ShipSalesDocumentFromPOS(POSSession: Codeunit "NPR POS Session"; SalesHeader: Record "Sales Header"; var SalesDocExpMgt: Codeunit "NPR Sales Doc. Exp. Mgt.")
    var
        SalesDocImpMgt: Codeunit "NPR Sales Doc. Imp. Mgt.";
    begin
        SalesDocImpMgt.ShipSalesDocumentFromPOS(POSSession, SalesHeader, SalesDocExpMgt);
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Parameter Value", 'OnGetParameterNameCaption', '', false, false)]
    local procedure OnGetParameterNameCaption(POSParameterValue: Record "NPR POS Parameter Value"; var Caption: Text)
    begin
        if POSParameterValue."Action Code" <> ActionCode() then
            exit;

        case POSParameterValue.Name of
            'PrintDocument':
                Caption := CaptionPrintDocumentLbl;
            'OpenDocument':
                Caption := CaptionOpenDocLbl;
            'SelectCustomer':
                Caption := CaptionSelectCustomerLbl;
            'SendDocument':
                Caption := CaptionSendDocLbl;
            'Pdf2NavDocument':
                Caption := CaptionPdf2NavDocLbl;
            'ShowPostedMessage':
                Caption := CaptionShowPostedMessageLbl;
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Parameter Value", 'OnGetParameterDescriptionCaption', '', false, false)]
    local procedure OnGetParameterDescriptionCaption(POSParameterValue: Record "NPR POS Parameter Value"; var Caption: Text)
    begin
        if POSParameterValue."Action Code" <> ActionCode() then
            exit;

        case POSParameterValue.Name of
            'PrintDocument':
                Caption := DescPrintDocumentLbl;
            'OpenDocument':
                Caption := DescOpenDocLbl;
            'SelectCustomer':
                Caption := DescSelectCustomerLbl;
            'SendDocument':
                Caption := DescSendDocLbl;
            'Pdf2NavDocument':
                Caption := DescPdf2NavDocLbl;
            'ShowPostedMessage':
                Caption := DescShowPostedMessageLbl;
        end;
    end;
}
