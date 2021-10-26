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
        CaptionAutoQtyToInvoice: Label 'Auto. Qty. to Invoice';
        CaptionAutoQtyToShip: Label 'Auto. Qty. to Ship';
        DescAutoQtyToInvoice: Label 'Configure if the document lines quantity to invoice should be handled automatically ';
        DescAutoQtyToShip: Label 'Configure if the document lines quantity to ship should be handled automatically ';
        ContinueWithInvoicing: Label 'One or more lines is set to be invoiced, not just shipped. Do you want to continue?';

    local procedure ActionCode(): Code[20]
    begin
        exit('SALES_DOC_PAY_POST');
    end;

    local procedure ActionVersion(): Text[30]
    begin
        exit('1.4');
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
            Sender.RegisterWorkflowStep('PayAndPostDocument', 'respond();');
            Sender.RegisterWorkflow(false);

            Sender.RegisterBooleanParameter('PrintDocument', false);
            Sender.RegisterBooleanParameter('OpenDocument', false);
            Sender.RegisterBooleanParameter('SelectCustomer', true);
            Sender.RegisterBooleanParameter('SendDocument', false);
            Sender.RegisterBooleanParameter('Pdf2NavDocument', false);
            Sender.RegisterBooleanParameter('ConfirmInvDiscAmt', false);
            Sender.RegisterOptionParameter('AutoQtyToInvoice', 'Disabled,None,All', 'Disabled');
            Sender.RegisterOptionParameter('AutoQtyToShip', 'Disabled,None,All', 'Disabled');

        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS JavaScript Interface", 'OnAction', '', false, false)]
    local procedure OnAction("Action": Record "NPR POS Action"; WorkflowStep: Text; Context: JsonObject; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean)
    var
        SalesHeader: Record "Sales Header";
        JSON: Codeunit "NPR POS JSON Management";
        SelectCustomer, OpenDocument, PrintDocument, Send, Pdf2Nav, ConfirmInvDiscAmt : Boolean;
        AutoQtyToInvoice: Integer;
        AutoQtyToShip: Integer;
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
        ConfirmInvDiscAmt := JSON.GetBooleanParameterOrFail('ConfirmInvDiscAmt', ActionCode());
        AutoQtyToInvoice := JSON.GetIntegerParameterOrFail('AutoQtyToInvoice', ActionCode());
        AutoQtyToShip := JSON.GetIntegerParameterOrFail('AutoQtyToShip', ActionCode());

        if not CheckCustomer(POSSession, SelectCustomer) then
            exit;

        if not SelectDocument(POSSession, SalesHeader) then
            exit;

        SetLinesToShipAndInvoice(SalesHeader, AutoQtyToInvoice, AutoQtyToShip); //Commits

        if not ConfirmDocument(SalesHeader, OpenDocument) then
            exit;

        if not ConfirmIfInvoiceQuantityIncreased(SalesHeader, AutoQtyToInvoice) then
            exit;

        if not ConfirmImportInvDiscAmt(SalesHeader, ConfirmInvDiscAmt) then
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

    local procedure SetLinesToShipAndInvoice(SalesHeader: Record "Sales Header"; AutoQtyToInvoice: Option Disabled,None,All; AutoQtyToShip: Option Disabled,None,All)
    var
        SalesLine: Record "Sales Line";
    begin
        if (AutoQtyToInvoice = AutoQtyToInvoice::Disabled) and (AutoQtyToShip = AutoQtyToShip::Disabled) then
            exit;

        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        if not SalesLine.FindSet(true) then
            exit;

        repeat
            case AutoQtyToInvoice of
                AutoQtyToInvoice::Disabled:
                    ;
                AutoQtyToInvoice::All:
                    begin
                        SalesLine.Validate("Qty. to Invoice", SalesLine.Quantity - SalesLine."Quantity Invoiced");
                    end;
                AutoQtyToInvoice::None:
                    begin
                        SalesLine.Validate("Qty. to Invoice", 0);
                    end;
            end;

            case AutoQtyToShip of
                AutoQtyToShip::Disabled:
                    ;
                AutoQtyToShip::All:
                    begin
                        SalesLine.Validate("Qty. to Ship", SalesLine.Quantity - SalesLine."Quantity Shipped");
                    end;
                AutoQtyToShip::None:
                    begin
                        SalesLine.Validate("Qty. to Ship", 0);
                    end;
            end;

            SalesLine.Modify();
        until SalesLine.Next() = 0;
        Commit();
    end;

    local procedure ConfirmDocument(SalesHeader: Record "Sales Header"; OpenDoc: Boolean): Boolean
    var
        PageMgt: Codeunit "Page Management";
    begin
        if OpenDoc then
            exit(Page.RunModal(PageMgt.GetPageID(SalesHeader), SalesHeader) = Action::LookupOK);

        exit(true);
    end;

    local procedure ConfirmIfInvoiceQuantityIncreased(SalesHeader: Record "Sales Header"; AutoQtyToInvoice: Option Disabled,None,All): Boolean
    var
        SalesLine: Record "Sales Line";
    begin
        if AutoQtyToInvoice <> AutoQtyToInvoice::None then
            exit(true);

        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        SalesLine.SetFilter("Qty. to Invoice", '>%1', 0);
        if SalesLine.IsEmpty() then
            exit(true);

        exit(Confirm(ContinueWithInvoicing, false));
    end;

    local procedure ConfirmImportInvDiscAmt(SalesHeader: Record "Sales Header"; ConfirmInvDiscAmt: Boolean): Boolean
    var
        SalesLine: Record "Sales Line";
        SalesDocImpMgt: codeunit "NPR Sales Doc. Imp. Mgt.";
    begin
        if ConfirmInvDiscAmt then begin
            SalesLine.SetRange("Document Type", SalesHeader."Document Type");
            SalesLine.SetRange("Document No.", SalesHeader."No.");
            SalesLine.SetFilter("Inv. Discount Amount", '>%1', 0);
            SalesLine.CalcSums("Inv. Discount Amount");
            if SalesLine."Inv. Discount Amount" > 0 then begin
                if not Confirm(SalesDocImpMgt.GetImportInvDiscAmtQst()) then
                    exit;
            end;
        end;
        exit(true);
    end;

    local procedure CreateDocumentPaymentLine(POSSession: Codeunit "NPR POS Session"; SalesHeader: Record "Sales Header"; Print: Boolean; Send: Boolean; Pdf2Nav: Boolean)
    var
        RetailSalesDocImpMgt: Codeunit "NPR Sales Doc. Imp. Mgt.";
    begin
        RetailSalesDocImpMgt.SalesDocumentAmountToPOS(POSSession, SalesHeader, true, true, true, Print, Pdf2Nav, Send, true);
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Parameter Value", 'OnGetParameterNameCaption', '', false, false)]
    local procedure OnGetParameterNameCaption(POSParameterValue: Record "NPR POS Parameter Value"; var Caption: Text)
    var
        SalesDocImpMgt: codeunit "NPR Sales Doc. Imp. Mgt.";
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
            'ConfirmInvDiscAmt':
                Caption := SalesDocImpMgt.GetConfirmInvDiscAmtLbl();
            'AutoQtyToInvoice':
                Caption := CaptionAutoQtyToInvoice;
            'AutoQtyToShip':
                Caption := CaptionAutoQtyToShip;
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Parameter Value", 'OnGetParameterDescriptionCaption', '', false, false)]
    local procedure OnGetParameterDescriptionCaption(POSParameterValue: Record "NPR POS Parameter Value"; var Caption: Text)
    var
        SalesDocImpMgt: codeunit "NPR Sales Doc. Imp. Mgt.";
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
            'ConfirmInvDiscAmt':
                Caption := SalesDocImpMgt.GetConfirmInvDiscAmtDescLbl();
            'AutoQtyToInvoice':
                Caption := DescAutoQtyToInvoice;
            'AutoQtyToShip':
                Caption := DescAutoQtyToShip;
        end;
    end;
}