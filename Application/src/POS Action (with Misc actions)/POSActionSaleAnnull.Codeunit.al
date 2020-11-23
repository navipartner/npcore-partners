codeunit 6150821 "NPR POS Action - Sale Annull."
{
    trigger OnRun()
    begin
    end;

    var
        ActionDescription: Label ' This action will prompt for a receipt no and annul the sale.';
        Title: Label 'Credit Sales Return';
        ReceiptPrompt: Label 'Receipt Number';
        ResellablePrompt: Label 'Are the returned items resellable?';
        NotAllowed: Label '%1 does not have the rights to return sales ticket. Make a return sale instead.';
        ReasonRequired: Label 'You must choose a return reason.';
        ReasonPrompt: Label 'Return Reason';
        NotValid: Label 'A valid receipt number must be used.';
        t031: Label 'You are about to return sales ticket number %1.\Are you sure you want to continue?';
        ERR_Lines: Label 'The posted invoice %1 have lines that have a G/L account that does not allow direct posting have not been copied to the new document.';
        ERR_NotApplied: Label 'The posted invoice %1 could not be applied to return document.';
        ERR_DocNotCreated: Label 'Return Document could not be created.';
        Text00001: Label 'There allready exists lines in the sales. Please delete the lines to fetch and customize the return sale.';
        TDOCPOST: Label 'Document posted.';
        NotFound: Label 'Return receipt reference number %1 not found.';

    local procedure ActionCode(): Text
    begin
        exit('SALEANNULL');
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
              Sender.Type::Generic,
              Sender."Subscriber Instances Allowed"::Multiple)
            then begin
                RegisterWorkflowStep('ReceiptNumber', 'input(labels.title, labels.receiptprompt).respond().cancel(abort);');
                RegisterWorkflowStep('reason', 'context.PromptForReason && respond();');
                RegisterWorkflowStep('handle', 'respond();');
                RegisterWorkflow(true);

                RegisterOptionParameter('DocumentType', 'CreditMemo,ReturnOrder', 'ReturnOrder');
                RegisterOptionParameter('ObfucationMethod', 'None,MI', 'None');
            end;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150701, 'OnBeforeWorkflow', '', true, true)]
    local procedure OnBeforeWorkflow("Action": Record "NPR POS Action"; Parameters: JsonObject; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean)
    var
        Setup: Codeunit "NPR POS Setup";
        RetailSetup: Record "NPR Retail Setup";
        SalespersonPurchaser: Record "Salesperson/Purchaser";
        Context: Codeunit "NPR POS JSON Management";
    begin
        if not Action.IsThisAction(ActionCode) then
            exit;

        //Check if user is allowed to do return
        POSSession.GetSetup(Setup);
        SalespersonPurchaser.Get(Setup.Salesperson);
        RetailSetup.Get();
        Context.SetContext('PromptForReason', RetailSetup."Reason for Return Mandatory");
        case SalespersonPurchaser."NPR Reverse Sales Ticket" of
            SalespersonPurchaser."NPR Reverse Sales Ticket"::No:
                Error(NotAllowed, SalespersonPurchaser.Name);
        end;

        FrontEnd.SetActionContext(ActionCode, Context);
        Handled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150701, 'OnAction', '', false, false)]
    local procedure OnAction("Action": Record "NPR POS Action"; WorkflowStep: Text; Context: JsonObject; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean)
    var
        JSON: Codeunit "NPR POS JSON Management";
    begin
        if not Action.IsThisAction(ActionCode) then
            exit;

        JSON.InitializeJObjectParser(Context, FrontEnd);

        case WorkflowStep of
            'reason':
                begin
                    JSON.SetContext('ReturnReasonCode', SelectReturnReason());
                    FrontEnd.SetActionContext(ActionCode, JSON);
                end;
            'handle':
                begin
                    VerifyReceiptNumber(Context, POSSession, FrontEnd);
                    POSSession.RequestRefreshData();
                end;
        end;

        Handled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150702, 'OnInitializeCaptions', '', false, false)]
    local procedure OnInitializeCaptions(Captions: Codeunit "NPR POS Caption Management")
    begin
        Captions.AddActionCaption(ActionCode, 'title', Title);
        Captions.AddActionCaption(ActionCode, 'receiptprompt', ReceiptPrompt);
    end;

    local procedure VerifyReceiptNumber(Context: JsonObject; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management")
    var
        JSON: Codeunit "NPR POS JSON Management";
        AuditRoll: Record "NPR Audit Roll";
        SalesTicketNo: Code[20];
        RetailSalesCode: Codeunit "NPR Retail Sales Code";
        ReturnReason: Record "Return Reason";
        SaleLinePOS: Record "NPR Sale Line POS";
        NPRetailSetup: Record "NPR NP Retail Setup";
        POSSale: Codeunit "NPR POS Sale";
        SalePOS: Record "NPR Sale POS";
        t001: Label 'Receipt No.';
        t002: Label 'not found!';
        t022: Label 'No sales lines!';
        t031: Label 'You are about to return sales ticket number %1.\Are you sure you want to continue?';
        RetailFormCode: Codeunit "NPR Retail Form Code";
        RetailSetup: Record "NPR Retail Setup";
        DocumentType: Option Quote,"Order",Invoice,"Credit Memo","Blanket Order","Return Order";
        PostedSalesInvoice: Record "Sales Invoice Header";
        Customer: Record Customer;
        SalesDocNo: Code[20];
        POSSetup: Codeunit "NPR POS Setup";
        SalesHeader: Record "Sales Header";
        SalesPost: Codeunit "Sales-Post";
        PostedSalesInvoicePage: Page "Posted Sales Invoice";
        RetailSalesDocMgt: Codeunit "NPR Sales Doc. Exp. Mgt.";
        POSCreateEntry: Codeunit "NPR POS Create Entry";
        POSEntryMgt: Codeunit "NPR POS Entry Management";
        ReturnReasonCode: Code[10];
    begin
        POSSession.GetSetup(POSSetup);
        NPRetailSetup.Get;
        JSON.InitializeJObjectParser(Context, FrontEnd);

        //Get ticket
        JSON.SetScope('/', true);
        JSON.SetScope('$ReceiptNumber', true);
        SalesTicketNo := JSON.GetString('input', true);
        if (SalesTicketNo = '') then
            Error(NotValid);

        //Get document type
        JSON.SetScope('/', true);
        JSON.SetScope('parameters', true);
        case JSON.GetString('DocumentType', true) of
            '0':
                DocumentType := DocumentType::"Credit Memo";
            '1':
                DocumentType := DocumentType::"Return Order";
            else
                Error('Document Type value %1 is not valid.', JSON.GetString('DocumentType', true));
        end;

        RetailSetup.Get();
        if RetailSetup."Reason for Return Mandatory" then begin
            JSON.SetScope('/', true);
            ReturnReasonCode := JSON.GetString('ReturnReasonCode', true);
        end;

        //Check ticket
        AuditRoll.Reset;

        POSEntryMgt.DeObfuscateTicketNo(JSON.GetIntegerParameter('ObfucationMethod', false), SalesTicketNo);
        AuditRoll.SetRange("Sales Ticket No.", SalesTicketNo);
        if (not AuditRoll.FindFirst()) then begin
            JSON.SetScope('/', true);
            JSON.SetScope('$ReceiptNumber', true);
            Error(NotFound, JSON.GetString('input', true));
        end;

        AuditRoll.TestField("Sale Type", AuditRoll."Sale Type"::"Debit Sale");
        AuditRoll.TestField(Posted, true);
        AuditRoll.TestField("Document Type", AuditRoll."Document Type"::Invoice);

        AuditRoll.TestField("Customer No.");
        AuditRoll.TestField("Posted Doc. No.");

        Customer.Get(AuditRoll."Customer No.");
        PostedSalesInvoice.Get(AuditRoll."Posted Doc. No.");

        //Show document
        Clear(PostedSalesInvoicePage);
        PostedSalesInvoicePage.SetRecord(PostedSalesInvoice);
        PostedSalesInvoicePage.LookupMode(true);
        if not (PostedSalesInvoicePage.RunModal = ACTION::LookupOK) then
            exit;

        //Create return document and add lines
        SalesDocNo := CreateReturnDocument(DocumentType, Customer."No.", PostedSalesInvoice."No.", POSSetup.Salesperson, ReturnReasonCode);
        if SalesDocNo = '' then
            Error(ERR_DocNotCreated);
        SalesHeader.Get(DocumentType, SalesDocNo);

        //Post documenty
        case DocumentType of
            DocumentType::"Credit Memo":
                begin
                    SalesHeader.Invoice := true;
                end;
            DocumentType::"Return Order":
                begin
                    SalesHeader.Receive := true;
                    SalesHeader.Invoice := true;
                end;
        end;

        //Now we have a sales doc to post lets just do the POS lines too

        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);

        SalePOS."Retursalg Bonnummer" := SalesTicketNo;
        SalePOS.Modify;

        SalesHeader."Shortcut Dimension 1 Code" := SalePOS."Shortcut Dimension 1 Code";
        SalesHeader."Shortcut Dimension 2 Code" := SalePOS."Shortcut Dimension 2 Code";
        SalesHeader."Dimension Set ID" := SalePOS."Dimension Set ID";
        SalesHeader.Modify(true);

        if not RetailSalesCode.ReverseSalesTicket(SalePOS, ReturnReasonCode) then begin //Has commit in it so let i be before we actually post and stuff
            SalePOS."Retursalg Bonnummer" := '';
            SalePOS.Modify;
            SalesHeader.Delete(true);

            SaleLinePOS.Reset;
            SaleLinePOS.SetFilter("Register No.", '=%1', SalePOS."Register No.");
            SaleLinePOS.SetFilter("Sales Ticket No.", '=%1', SalePOS."Sales Ticket No.");
            if SaleLinePOS.FindSet then
                SaleLinePOS.DeleteAll(true);
        end else begin
            SalesPost.Run(SalesHeader);
            RetailSalesDocMgt.CreateDocumentPostingAudit(SalesHeader, SalePOS, true);

            SaleLinePOS.Reset;
            SaleLinePOS.SetFilter("Register No.", '=%1', SalePOS."Register No.");
            SaleLinePOS.SetFilter("Sales Ticket No.", '=%1', SalePOS."Sales Ticket No.");
            if (SaleLinePOS.FindSet()) then begin
                repeat
                    SaleLinePOS.UpdateAmounts(SaleLinePOS);
                    SaleLinePOS.Modify();
                until (SaleLinePOS.Next() = 0);
            end;
            if NPRetailSetup."Advanced Posting Activated" then
                POSCreateEntry.CreatePOSEntryForCreatedSalesDocument(SalePOS, SalesHeader, true);

            SaleLinePOS.Reset;
            SaleLinePOS.SetFilter("Register No.", '=%1', SalePOS."Register No.");
            SaleLinePOS.SetFilter("Sales Ticket No.", '=%1', SalePOS."Sales Ticket No.");
            if (SaleLinePOS.FindSet()) then
                SaleLinePOS.DeleteAll(true);

            Message(TDOCPOST);
        end;

        POSSale.RefreshCurrent();
        POSSale.SelectViewForEndOfSale(POSSession);
    end;

    local procedure CreateReturnDocument(DocumentType: Option Quote,"Order",Invoice,"Credit Memo","Blanket Order","Return Order"; SellToCustomerNo: Code[20]; PostedInvoiceNo: Code[20]; SalecPersonCode: Code[10]; ReturnReasonCode: Code[10]) DocumentNo: Code[20]
    var
        SalesHeader: Record "Sales Header";
        Customer: Record Customer;
        SalesPostedDocLines: Page "Posted Sales Document Lines";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        CopyDocMgt: Codeunit "Copy Document Mgt.";
        LinesNotCopied: Integer;
        SalesInvoiceLine: Record "Sales Invoice Line";
        MissingExCostRevLink: Boolean;
        SalespersonPurchaser: Record "Salesperson/Purchaser";
        SalesLine: Record "Sales Line";
        ReturnReason: Record "Return Reason";
        UpdateLocation: Boolean;
    begin
        Customer.Get(SellToCustomerNo);
        SalesInvoiceHeader.Get(PostedInvoiceNo);
        SalesInvoiceLine.Reset;
        SalesInvoiceLine.SetFilter("Document No.", SalesInvoiceHeader."No.");
        SalesInvoiceLine.FindSet;
        SalespersonPurchaser.Get(SalecPersonCode);

        if ReturnReasonCode <> '' then begin
            ReturnReason.Get(ReturnReasonCode);
            UpdateLocation := ReturnReason."Default Location Code" <> '';
        end else
            UpdateLocation := false;

        //Create return doc
        SalesHeader.Init;
        SalesHeader.Validate("Document Type", DocumentType);
        SalesHeader.Validate("Sell-to Customer No.", Customer."No.");
        SalesHeader.Insert(true);
        SalesHeader.Validate("Salesperson Code", SalespersonPurchaser.Code);
        if UpdateLocation then
            SalesHeader.Validate("Location Code", ReturnReason."Default Location Code");
        SalesHeader.Modify(true);

        //Lines to return
        Clear(CopyDocMgt);
        CopyDocMgt.SetProperties(false, false, false, false, true, true, true);
        CopyDocMgt.CopySalesInvLinesToDoc(
                SalesHeader, SalesInvoiceLine, LinesNotCopied, MissingExCostRevLink);

        Clear(CopyDocMgt);

        if LinesNotCopied <> 0 then
            Error(ERR_Lines, SalesInvoiceHeader."No.");

        //Line copied or else roolback
        SalesLine.Reset;
        SalesLine.SetFilter("Document Type", '=%1', SalesHeader."Document Type");
        SalesLine.SetFilter("Document No.", '=%1', SalesHeader."No.");
        if SalesLine.IsEmpty then
            Error(ERR_NotApplied, PostedInvoiceNo);

        if ReturnReasonCode <> '' then
            if SalesLine.FindSet() then
                repeat
                    if UpdateLocation and
                       ((SalesLine."Location Code" <> '') or (SalesLine.Type = SalesLine.Type::Item)) and
                       (SalesLine."Location Code" <> ReturnReason."Default Location Code")
                    then
                        SalesLine.Validate("Location Code", ReturnReason."Default Location Code");
                    if (SalesLine.Type <> SalesLine.Type::" ") and (SalesLine."No." <> '') then
                        SalesLine."Return Reason Code" := ReturnReasonCode;
                    if ReturnReason."Inventory Value Zero" then
                        SalesLine.Validate("Unit Cost (LCY)", 0);
                    SalesLine.Modify();
                until SalesLine.Next() = 0;

        exit(SalesHeader."No.");
    end;

    local procedure SelectReturnReason(): Code[10];
    var
        ReturnReason: Record "Return Reason";
        ReasonRequiredErr: Label 'You must choose a return reason.';
    begin
        if Page.RunModal(Page::"NPR TouchScreen: Ret. Reasons", ReturnReason) = Action::LookupOK then
            exit(ReturnReason.Code);

        Error(ReasonRequiredErr);
    end;
}