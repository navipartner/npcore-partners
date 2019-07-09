codeunit 6150821 "POS Action - Sale Annullation"
{
    // NPR5.33/ANEN/20170620 CASE 259685 Refactor to use standard NAV functions, removing calls to old customized code
    // NPR5.43/JDH /20180704 CASE 321334 removed calls to incorrect update functions. They caused an incorrect update of the screen
    // NPR5.48/TSA /20190208 CASE 343578 Added Creation of the POS Entry on document reversal
    // NPR5.48/TSA /20190208 CASE 343578 Added support for creating entry lines in contexts of a debet sale (reversing an invoice from the POS)
    // NPR5.49/TSA /20190218 CASE 342244 Added DeObfucation of salesticket number - fraud protection


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
    local procedure OnDiscoverAction(var Sender: Record "POS Action")
    begin
        with Sender do
          if DiscoverAction(
            ActionCode,
            ActionDescription,
            ActionVersion,
            Sender.Type::Generic,
            Sender."Subscriber Instances Allowed"::Multiple)
          then begin
            RegisterWorkflowStep ('ReceiptNumber', 'input(labels.title, labels.receiptprompt).respond().cancel(abort);');
            RegisterWorkflow (true);
            RegisterOptionParameter('DocumentType', 'CreditMemo,ReturnOrder', 'ReturnOrder');

            //-NPR5.49 [342244]
            RegisterOptionParameter ('ObfucationMethod', 'None,MI', 'None');
            //+NPR5.49 [342244]

          end;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150701, 'OnBeforeWorkflow', '', true, true)]
    local procedure OnBeforeWorkflow("Action": Record "POS Action";Parameters: DotNet npNetJObject;POSSession: Codeunit "POS Session";FrontEnd: Codeunit "POS Front End Management";var Handled: Boolean)
    var
        Setup: Codeunit "POS Setup";
        RetailSetup: Record "Retail Setup";
        SalespersonPurchaser: Record "Salesperson/Purchaser";
        Context: Codeunit "POS JSON Management";
    begin
        if not Action.IsThisAction(ActionCode) then
          exit;

        //Check if user is allowed to do return
        POSSession.GetSetup (Setup);
        SalespersonPurchaser.Get (Setup.Salesperson);
        RetailSetup.Get ();
        case SalespersonPurchaser."Reverse Sales Ticket" of
          SalespersonPurchaser."Reverse Sales Ticket"::No : Error (NotAllowed, SalespersonPurchaser.Name);
        end;

        FrontEnd.SetActionContext (ActionCode, Context);
        Handled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150701, 'OnAction', '', false, false)]
    local procedure OnAction("Action": Record "POS Action";WorkflowStep: Text;Context: DotNet npNetJObject;POSSession: Codeunit "POS Session";FrontEnd: Codeunit "POS Front End Management";var Handled: Boolean)
    var
        JSON: Codeunit "POS JSON Management";
        ReturnReasonCode: Code[20];
    begin
        if not Action.IsThisAction(ActionCode) then
          exit;

        JSON.InitializeJObjectParser(Context,FrontEnd);


        case WorkflowStep of
          'ReceiptNumber' :
            begin
              VerifyReceiptNumber(Context, POSSession, FrontEnd);
            end;
        end;

        POSSession.ChangeViewSale ();
        POSSession.RequestRefreshData ();

        Handled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150702, 'OnInitializeCaptions', '', false, false)]
    local procedure OnInitializeCaptions(Captions: Codeunit "POS Caption Management")
    begin
        Captions.AddActionCaption (ActionCode, 'title', Title);
        Captions.AddActionCaption (ActionCode, 'receiptprompt', ReceiptPrompt);
    end;

    local procedure VerifyReceiptNumber(Context: DotNet npNetJObject;POSSession: Codeunit "POS Session";FrontEnd: Codeunit "POS Front End Management")
    var
        JSON: Codeunit "POS JSON Management";
        AuditRoll: Record "Audit Roll";
        SalesTicketNo: Code[20];
        TouchSalePOSWeb: Codeunit "Touch - Sale POS (Web)";
        RetailSalesCode: Codeunit "Retail Sales Code";
        ReturnReason: Record "Return Reason";
        SaleLinePOS: Record "Sale Line POS";
        POSSale: Codeunit "POS Sale";
        SalePOS: Record "Sale POS";
        t001: Label 'Receipt No.';
        t002: Label 'not found!';
        t022: Label 'No sales lines!';
        t031: Label 'You are about to return sales ticket number %1.\Are you sure you want to continue?';
        RetailFormCode: Codeunit "Retail Form Code";
        RetailSetup: Record "Retail Setup";
        DocumentType: Option Quote,"Order",Invoice,"Credit Memo","Blanket Order","Return Order";
        PostedSalesInvoice: Record "Sales Invoice Header";
        Customer: Record Customer;
        SalesDocNo: Code[20];
        POSSetup: Codeunit "POS Setup";
        SalesHeader: Record "Sales Header";
        SalesPost: Codeunit "Sales-Post";
        PostedSalesInvoicePage: Page "Posted Sales Invoice";
        RetailSalesDocMgt: Codeunit "Retail Sales Doc. Mgt.";
        POSCreateEntry: Codeunit "POS Create Entry";
    begin
        POSSession.GetSetup (POSSetup);

        JSON.InitializeJObjectParser(Context,FrontEnd);

        //Get ticket
        JSON.SetScope ('/', true);
        JSON.SetScope ('$ReceiptNumber', true);
        SalesTicketNo := JSON.GetString ('input', true);
        if (SalesTicketNo = '') then
          Error (NotValid);

        //Get document type
        JSON.SetScope ('/', true);
        JSON.SetScope ('parameters', true);
        case JSON.GetString ('DocumentType', true) of
         '0' : DocumentType := DocumentType::"Credit Memo";
         '1' : DocumentType := DocumentType::"Return Order";
          else
            Error('Document Type value %1 is not valid.', JSON.GetString ('DocumentType', true));
        end;

        //Check ticket
        AuditRoll.Reset;

        //-NPR5.49 [342244]
        // AuditRoll.SETRANGE ("Sales Ticket No.", SalesTicketNo);
        // AuditRoll.FINDFIRST ();
        DeObfuscateTicketNo (JSON.GetIntegerParameter ('ObfucationMethod', false), SalesTicketNo);
        AuditRoll.SetRange ("Sales Ticket No.", SalesTicketNo);
        if (not AuditRoll.FindFirst ()) then begin
          JSON.SetScope ('/', true);
          JSON.SetScope ('$ReceiptNumber', true);
          Error (NotFound, JSON.GetString ('input', true));
        end;
        //+NPR5.49 [342244]

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
        if not( PostedSalesInvoicePage.RunModal = ACTION::LookupOK ) then
          exit;

        //Create return document and add lines
        SalesDocNo := CreateReturnDocument(DocumentType, Customer."No.", PostedSalesInvoice."No.", POSSetup.Salesperson);
        if SalesDocNo = '' then
          Error(ERR_DocNotCreated);
        SalesHeader.Get(DocumentType, SalesDocNo);

        //Post documenty
        case DocumentType of
          DocumentType::"Credit Memo" :
            begin
              SalesHeader.Invoice := true;
            end;
          DocumentType::"Return Order" :
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

        if not RetailSalesCode.ReverseSalesTicket(SalePOS) then begin //Has commit in it so let i be before we actually post and stuff
          //Back it all
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
          RetailSalesDocMgt.CreateDocumentPostingAudit(SalesHeader,SalePOS,true);

          //-NPR5.48 [343578]
          SaleLinePOS.Reset;
          SaleLinePOS.SetFilter ("Register No.", '=%1', SalePOS."Register No.");
          SaleLinePOS.SetFilter ("Sales Ticket No.", '=%1', SalePOS."Sales Ticket No.");
          if (SaleLinePOS.FindSet ()) then begin
            repeat
              SaleLinePOS.UpdateAmounts (SaleLinePOS);
              SaleLinePOS.Modify ();
            until (SaleLinePOS.Next () = 0);
          end;

          POSCreateEntry.CreatePOSEntryForCreatedSalesDocument(SalePOS, SalesHeader, true);

          SaleLinePOS.Reset;
          SaleLinePOS.SetFilter ("Register No.", '=%1', SalePOS."Register No.");
          SaleLinePOS.SetFilter ("Sales Ticket No.", '=%1', SalePOS."Sales Ticket No.");
          if (SaleLinePOS.FindSet ()) then
            SaleLinePOS.DeleteAll (true);
          //+NPR5.48 [343578]

          Message(TDOCPOST);
        end;

        //-NPR5.43 [321334]
        //POSSession.ChangeViewSale ();
        //POSSession.GetSale(POSSale);
        //POSSale.GetCurrentSale(SalePOS);
        //POSSale.Refresh(SalePOS);
        //+NPR5.43 [321334]
        POSSale.RefreshCurrent();
        //-NPR5.43 [321334]
        //POSSession.RequestRefreshData();
        //+NPR5.43 [321334]
        POSSale.SelectViewForEndOfSale(POSSession);
    end;

    local procedure CreateReturnDocument(DocumentType: Option Quote,"Order",Invoice,"Credit Memo","Blanket Order","Return Order";SellToCustomerNo: Code[20];PostedInvoiceNo: Code[20];SalecPersonCode: Code[10]) DocumentNo: Code[20]
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
    begin
        Customer.Get(SellToCustomerNo);
        SalesInvoiceHeader.Get(PostedInvoiceNo);
        SalesInvoiceLine.Reset;
        SalesInvoiceLine.SetFilter("Document No.", SalesInvoiceHeader."No.");
        SalesInvoiceLine.FindSet;
        SalespersonPurchaser.Get (SalecPersonCode);

        //Create return doc
        SalesHeader.Init;
        SalesHeader.Validate("Document Type", DocumentType);
        SalesHeader.Validate("Sell-to Customer No.", Customer."No.");
        SalesHeader.Insert(true);
        SalesHeader.Validate("Salesperson Code", SalespersonPurchaser.Code);
        SalesHeader.Modify(true);

        //Lines to return
        Clear(CopyDocMgt);
        CopyDocMgt.SetProperties(false,false,false,false,true,true,true);
        CopyDocMgt.CopySalesInvLinesToDoc(
                SalesHeader,SalesInvoiceLine,LinesNotCopied,MissingExCostRevLink);

        Clear(CopyDocMgt);

        if LinesNotCopied <> 0 then
          Error(ERR_Lines, SalesInvoiceHeader."No.");

        //Line copied or else roolback
        SalesLine.Reset;
        SalesLine.SetFilter("Document Type", '=%1',SalesHeader."Document Type");
        SalesLine.SetFilter("Document No.", '=%1',SalesHeader."No.");
        if SalesLine.IsEmpty then
          Error(ERR_NotApplied, PostedInvoiceNo);

        exit(SalesHeader."No.");
    end;

    local procedure DeObfuscateTicketNo(ObfucationMethod: Integer;var SalesTicketNo: Code[20])
    var
        MyBigInt: BigInteger;
        RPAuxMiscLibrary: Codeunit "RP Aux - Misc. Library";
    begin

        //-NPR5.49 [342244]
        case ObfucationMethod of
          1: // Multiplicative Inverse
          begin
            if (StrLen (SalesTicketNo) > 2) then
              if (CopyStr (SalesTicketNo, 1,2) = 'MI') then
                SalesTicketNo := CopyStr (SalesTicketNo, 3);

            if (Evaluate (MyBigInt, SalesTicketNo)) then
              SalesTicketNo := Format (RPAuxMiscLibrary.MultiplicativeInverseDecode (MyBigInt), 0, 9);
          end;
        end;

        //+NPR5.49 [342244]
    end;
}

