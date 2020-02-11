codeunit 6014407 "Retail Sales Doc. Mgt."
{
    //  Retail Sales Doc Mgt.
    //  Work started by Nicolai Esbensen.
    //  The purpose of the module is to provide functionality for exporting
    //  sales from the register to the std. sales module. The exported documents
    //  can on request be posted and printed.
    // 
    //  The Codeunit can be invoked solely from the POS system the an active
    //  Sale POS record. All functionality can be invoked through the codeunit
    //  run method. The Parameters field of the Sale POS record functions as the
    //  function identifier.
    // 
    //  Current function identifiers and their purpose are listed below.
    // --------------------------------------------------------
    //  'SALESDOC_ASK_ON'
    //   If the Post variable has been set true, the system will show a posting dialog accordingly to
    //   the sales document type being posted.
    // 
    //  'SALESDOC_ASK_OFF'
    //   Will turn off all posting dialogs. Invoice, Ship and Receive will decide the posting behavior in this case.
    // 
    //  'SALESDOC_PRINT_ON'
    //   Will enable printing of any posted document.
    // 
    //  'SALESDOC_PRINT_OFF'
    //   Will disable all prints.
    // 
    //  'SALESDOC_INVOICE_ON'
    //   Will enable invoicing, can be overruled i dialog is enabled.
    // 
    //  'SALESDOC_INVOICE_OFF'
    //   Will disable invoicing, can be overruled i dialog is enabled.
    // 
    //  'SALESDOC_POST_ON'
    //   Will enable posting on the sales document.
    // 
    //  'SALESDOC_POST_OFF'
    //   Will Disable posting on the sales document.
    // 
    //  'SALESDOC_RECEIVE_ON'
    //   Will enable receival on posting, can be overruled i dialog is enabled.
    // 
    //  'SALESDOC_RECEIVE_OFF'
    //   Will disable receival on posting, can be overruled i dialog is enabled.
    // 
    //  'SALESDOC_SHIP_ON'
    //   Will enable shipping on posting, can be overruled i dialog is enabled.
    // 
    //  'SALESDOC_SHIP_OFF'
    //   Will disable shipping on posting, can be overruled i dialog is enabled.
    // 
    //  'SALESDOC_TYPE_ORD'
    //   Sets the document type to "Sales Order"
    // 
    //  'SALESDOC_TYPE_INV'
    //   Sets the document type to "Sales Invoice"
    // 
    //  'SALESDOC_TYPE_RET'
    //   Sets the document type to "Return Order"
    // 
    //  'SALESDOC_TYPE_CRED'
    //   Sets the document type to "Credit Memo"
    // 
    //  'SALESDOC_WRITE_AUDIT'
    //   Sets if a trace should be written to Audit on Sales document processing.
    // 
    //  'SALESDOC_PROCESS'
    //   Will transfer the pos sale to a sales document of the chosen type. Will post, print, show dialog
    //   and so forth according to the paramaters set by other function identifiers. If not parameters have
    //   been overruled, the function will use the default parameters set in the "Retail Setup" table.
    // 
    //  'SALESDOC_CR_MSG'
    //   When set it will show a message with the number of the sales document created
    // 
    //  'SALESDOC_RET_AMT?xx'
    //   When set it will return the sales document amount to the POS where xx is the percentage of the amount to return
    // 
    //  'SALESDOC_OUTPUT_DOCUMENT?xx'
    //   Will send Sales Doc. lines to CU xx for printing or other output handling when created, independently of usual post/print settings of the doc.
    // 
    //  'SALESDOC_FINISH_SALE'
    //   Will finish the sale after document creation if the total price is 0.
    // 
    //  'SALESDOC_OPEN_PAGE'
    //   Will open the page corresponding to the document type on the sale line POS.
    // 
    //  'SALESDOC_TEST_SALE'
    //   Will test the sale lines for any errors using TestSaleLinePOS()
    // 
    //  'SALESDOC_ORD_TYPE?xx'
    //  Set the "Order Type" for the sales header. Available values:
    //    - 00: blank
    //    - 01: Order (bestilling)
    //    - 02: Lending (udl�n)
    // 
    // NPR4.14/RMT /20150608  CASE 216519 New meta trigger 'SALESDOC_CR_MSG'
    // NPR4.14/RMT /20150625  CASE 216519 New meta trigger 'SALESDOC_RET_AMT'
    //                                    Redefine CASE for parameter to include a parameter for return amount percentage
    // NPR4.14/MMV /20150723  CASE 216519 New meta trigger 'SALESDOC_OUTPUT_DOCUMENT'
    //                                    New meta trigger 'SALESDOC_FINISH_SALE'
    //                                    Removed SaleLinePOS.DELETEALL on ProcessPOSSale() unless WriteInAuditRoll trigger is used.
    //                                    New function ConvertSaleLinePOSToComments()
    //                                    WriteInAuditRoll changed to FALSE as default in Reset()
    // NPR4.14/MMV /20150727  CASE 216519 Added block if SaleLinePOS contains payment lines to TestSaleLinePOS()
    //                                    Added find on last line no. when inserting deposit line in SaleLinePOS
    // NPR4.14/MMV /20150728  CASE 216519 New meta triggers 'SALESDOC_OPEN_PAGE', 'SALESDOC_TEST_SALE'
    //                                    Added block if SaleLinePOS contains a "Sales Document No." to TestSaleLinePOS()
    //                                    Comments made by ConvertSaleLinePOSToComments() now get "Sales Document No." and "Sales Document Type" filled out.
    // NPR4.14/MMV /20150825  CASE 221045 Call TransferLinesToAuditRoll 'Bilag' with last document no.
    //                                    TransferLinesToAuditRoll parameter 'Bilag' changed from Code10 to Code20, and named translated to DocumentNo.
    //                                    Added boolean parameter 'Posted' to CreateDocumentPostingAudit().
    //                                    Refactored how 'Document Type', 'Document No.' and description line are written to AuditRoll in CreateDocumentPostingAudit()
    // NPR4.18/RMT /20160203  CASE 233094 Adding serial number information from the POS to the sales document
    // NPR4.21/JC  /20160309  CASE 233876 to skip Customer check limit form, use Retail setup to display check before
    // NPR4.21/BHR /20160107  CASE 229736 Flow dimension from POS sale to Std Table
    // NPR5.22/VB  /20160105  CASE 230373 Refactoring due to client-side formatting of decimal and date/time values
    // NPR5.00/NPKNAV/20160113  CASE 230373 NP Retail 2016
    // NPR5.22/TJ  /20160408  CASE 238601 Commented out as requested by Mark to keep zero footprint
    // NPR5.23/JC  /20160510  CASE 240063 Ship and invoice, posting not working
    // NPR5.27/JDH /20161018  CASE 255575 Removed call to function that didnt do anything
    // NPR5.28/VB  /20161122  CASE 259086 Removed reference to old unused codeunit
    // NPR5.28/MHA /20161129  CASE 257831 Updated SalesPost to include Ask-parameter - note that Pdf2Nav will not trigger when not Ask and Print
    // NPR5.29/MHA /20170125  CASE 262318 Added event publisher to Audit Roll Insert: OnBeforeAuditRollDebitSaleLineInsertEvent()
    // NPR5.32/ANEN/20170314  CASE 268218 Changed functions to global (called from POS Action - Cust. Sales. Doc.) - OpenSalesDoc, SetOrderType, SetShowCreationMessage, SetFinishSale, SetShowDepositDialog,SetReturnAmount, SetOutput
    // NPR5.31/BHR /20170327  CASE 270554 Clear currency Code .
    // NPR5.31/BR  /20170412  CASE 270593 Also copy reversed Debitsale lines to Audit Roll
    // NPR5.32/TSA /20170504  CASE 274389 Added event publisher when debit sales completes: OnAfterDebitSalePostEvent ()
    // NPR5.32/BR  /20170523  CASE 277092 Added Parameters and functions to overwrite data from POS Sale Line
    // NPR5.32/BHR /20170510  CASE 274999 Fill in sell to contact
    // NPR5.33/BR  /20170523  CASE 277092 Added Parameters and functions to overwrite data from POS Sale Line
    // NPR5.33/JLK /20170622  CASE 280556 Gift Voucher to be printed using Gift Voucher Ref No. instead of Sales Ticket No. on GV table
    // NPR5.33/BHR /20170621  CASE 279702 Allow Creation of  order/invoice when amount=0
    // NPR5.33/ANEN/20170628  CASE 259685 Chaning fcn. [CreateDocumentPostingAudit] to global
    // NPR5.34/ANEN/20170713  CASE 283669 Added fcn. SetAutoReserveSalesLine and support for it.
    // NPR5.37/BR  /20171024  CASE 294362 Added integration to Advanced Posting
    // NPR5.38/BR  /20180118  CASE 302761 Added functionality to skip Audit Roll creation if "Create POS Entries Only"
    // NPR5.39/MMV /20180209  CASE 304639 Skip audit roll print if POS Entry posting is used. Deleted old version comments.
    // NPR5.39/TS  /20180221  CASE 294224 Document Processing should be inherited from Customer upon DebitSale
    // NPR5.39/THRO/20171222  CASE 299380 Replaced codeunit 82 with 6014463 Sales-Post and Pdf2Nav in ProcessPOSSale
    // NPR5.40/THRO/20180302  CASE 302617 Added parameter SendPostedPdf2Nav. Parameter Print is now for Print only
    //                                    Moved print/sending to after COMMIT
    // NPR5.40/MMV /20180319  CASE 304639 Support for POS Entry print.
    //                                    Added parameter RetailPrint.
    // NPR5.40/MMV /20180323  CASE 300557 Added retrieval of created sales document.
    // NPR5.41/JDH /20180426  CASE 312644  Added indirect permissions to table Audit roll
    // NPR5.42/THRO/20180404  CASE 299973 Simplified Unit Price and Discount % logic in CopySalesLines in order to handle custom prices
    // NPR5.43/JDH /20180604  CASE 317971 Changed captions to ENU
    // NPR5.45/THRO/20180823  CASE 325216 Added Document Type::Quote
    // NPR5.47/THRO/20181024  CASE 333671 Added COMMIT in end of ProcessPOSSale to commit changes made in publisher
    // NPR5.48/THRO/20181221  CASE 339049 Assign Line No. to Sales Line before validating data into Sales Line in CopySalesLines
    // NPR5.50/MMV /20190320  CASE 300557 Refactored prepayment & posting flows.
    // NPR5.50/MMV /20190606  CASE 352473 Improved error message when posting fails. Only transfer posted document fields when posted.
    // NPR5.51/MMV /20190605  CASE 357277 Added support for skipping line transfer to POS entry.
    // NPR5.51/MHA /20190614  CASE 358582 Removed function OnBeforeAuditRollDebitSaleLineInsertEvent() and added corresponding invokes to codeunit 6014435
    // NPR5.51/ALST/20190705  CASE 357848 added possibility to prepay by amount not just percentage
    // NPR5.52/MMV /20191002  CASE 352473 Fixed prepayment VAT & amount dialog bugs.
    //                                    Added send & pdf2nav support to pre-sale end posting subscriber.
    // NPR5.53/MMV /20191024 CASE 349793 Added Output Type handling
    // NPR5.53/ALPO/20191216 CASE 378985 Finish credit sale workflow
    // NPR5.53/MMV /20191219 CASE 377510 Rolled back #357277, replaced with a silent re-import into active sale before ending to keep order & POS sale contents in sync.

    Permissions = TableData "Audit Roll"=rimd;
    TableNo = "Sale POS";

    trigger OnRun()
    begin
        case true of
          StrPos(Parameters,'SALESDOC_ASK_ON')>0             : SetAsk(true);
          StrPos(Parameters,'SALESDOC_ASK_OFF')>0            : SetAsk(false);
          StrPos(Parameters,'SALESDOC_PRINT_ON')>0           : SetPrint(true);
          StrPos(Parameters,'SALESDOC_PRINT_OFF')>0          : SetPrint(false);
          StrPos(Parameters,'SALESDOC_INVOICE_ON')>0         : SetInvoice(true);
          StrPos(Parameters,'SALESDOC_INVOICE_OFF')>0        : SetInvoice(false);
          StrPos(Parameters,'SALESDOC_POST_ON')>0            : SetPost(true);
          StrPos(Parameters,'SALESDOC_POST_OFF')>0           : SetPost(false);
          StrPos(Parameters,'SALESDOC_RECEIVE_ON')>0         : SetReceive(true);
          StrPos(Parameters,'SALESDOC_RECEIVE_OFF')>0        : SetReceive(false);
          StrPos(Parameters,'SALESDOC_SHIP_ON')>0            : SetShip(true);
          StrPos(Parameters,'SALESDOC_SHIP_OFF')>0           : SetShip(false);
          StrPos(Parameters,'SALESDOC_TYPE_ORD')>0           : SetDocumentTypeOrder();
          StrPos(Parameters,'SALESDOC_TYPE_INV')>0           : SetDocumentTypeInvoice();
          StrPos(Parameters,'SALESDOC_TYPE_RET')>0           : SetDocumentTypeReturnOrder();
          StrPos(Parameters,'SALESDOC_TYPE_CRED')>0          : SetDocumentTypeCreditMemo();
          StrPos(Parameters,'SALESDOC_WRITE_AUDIT')>0        : SetWriteInAuditRoll(true);
          StrPos(Parameters,'SALESDOC_CR_MSG')>0             : SetShowCreationMessage;
          StrPos(Parameters,'SALESDOC_RET_AMT')>0            : SetReturnAmount(Parameters);
          StrPos(Parameters,'SALESDOC_OUTPUT_DOCUMENT')>0    : SetOutput(Parameters);
          StrPos(Parameters,'SALESDOC_FINISH_SALE')>0        : SetFinishSale;
          StrPos(Parameters,'SALESDOC_DEPOSIT_DLG')>0        : SetShowDepositDialog;
          StrPos(Parameters,'SALESDOC_TEST_SALE')>0          : TestSalePOS(Rec);
          StrPos(Parameters,'SALESDOC_PROCESS')>0            : ProcessPOSSale(Rec);
          StrPos(Parameters,'SALESDOC_OPEN_PAGE')>0          : OpenSalesDoc(Rec);
          StrPos(Parameters,'SALESDOC_ORD_TYPE')>0           : SetOrderType(Parameters);
          StrPos(Parameters,'SALESDOC_TRSALESPERS')>0         : SetTransferSalesPerson(true);
          StrPos(Parameters,'SALESDOC_TRPOSTINGSETUP')>0        : SetTransferPostingsetup(true);
          StrPos(Parameters,'SALESDOC_TRDIMENSIONS')>0          : SetTransferDimensions(true);
          StrPos(Parameters,'SALESDOC_TRPAYMENTMETHOD')>0       : SetTransferPaymentMethod(true);
          StrPos(Parameters,'SALESDOC_TRSALESSETUP')>0            : SetTransferTaxSetup(true);
          StrPos(Parameters,'SALESDOC_TRTRANSDATA')>0        : SetTransferTransactionData(true);
          else Error('');
        end;
    end;

    var
        Text000002: Label '%1 %2 %3 couldn''t be printed.';
        DocumentType: Option Quote,"Order",Invoice,"Credit Memo","Blanket Order","Return Order";
        Ask: Boolean;
        SkipDefaultValues: Boolean;
        Invoice: Boolean;
        Print: Boolean;
        Post: Boolean;
        Receive: Boolean;
        Ship: Boolean;
        WriteInAuditRoll: Boolean;
        Text000003: Label 'You cannot debit item groups!';
        Text000004: Label 'There is nothing to post';
        Text000005: Label 'Debit receipt';
        Text000006: Label 'Do you wish to post the sales document created?';
        Text000007: Label 'Error. You can not post customer payments from the register using the sales module!';
        Text000008: Label '%1 %2 was created';
        ShowCreationMessage: Boolean;
        ReturnAmount: Boolean;
        Text000009: Label 'Deposit for %1 %2';
        FinishSale: Boolean;
        OutputDocument: Boolean;
        ShowDepositDialog: Boolean;
        OrderTypeSet: Boolean;
        SuggestedDepositAmount: Decimal;
        ReturnAmountPercentage: Decimal;
        OutputCodeunit: Integer;
        Text000010: Label 'You cannot post when a payment has been made';
        Text000011: Label 'Enter Deposit Amount';
        Text000012: Label 'Only one sales document can be created per sales ticket';
        OrderType: Integer;
        Text000013: Label 'Serial number must be supplied for item %1 - %2';
        TransferSalesPerson: Boolean;
        TransferPostingSetup: Boolean;
        TransferDimensions: Boolean;
        TransferPaymentMethod: Boolean;
        TransferTaxSetup: Boolean;
        TransferTransactionData: Boolean;
        AutoReserveSalesLines: Boolean;
        SendPostedPdf2Nav: Boolean;
        PrintingErrorTxt: Label 'Printing of Documents failed with error: %1';
        SendingErrorTxt: Label 'Sending of Documents failed with error: %1';
        Pdf2NavSendingErrorTxt: Label 'Sending of Documents via Pdf2Nav failed with error: %1';
        RetailPrintErrorTxt: Label 'Retail printing of Documents failed with error: %1';
        RetailPrint: Boolean;
        CreatedSalesHeader: Record "Sales Header";
        CAPTION_PAYMENT: Label 'Payment on %1 %2';
        PREPAYMENT_POSTED: Label 'Prepayment of %1 %2 on %3 %4';
        PREPAYMENT_REFUND_POSTED: Label 'Prepayment refund of %1 %2 on %3 %4';
        NEGATIVE_PREPAYMENT: Label 'Prepayment amount must be greater than zero';
        OpenSalesDocAfterExport: Boolean;
        PREPAYMENT: Label 'Prepayment of %1 %2';
        PREPAYMENT_REFUND: Label 'Prepayment refund of %1 %2';
        RESERVE_FAIL_MESSAGE: Label 'Full automatic reservation is not possible for all lines in %1 %2.\Reserve manually.';
        RESERVE_FAIL_ERROR: Label 'Full  automatic reservation failed for line with:\%1: %2\%3: %4';
        POSTING_ERROR: Label 'A problem occured during posting of %1 %2.\Document was left in unposted state.\%3';
        AmountExceedsSaleErr: Label 'The prepaid amount exceeds the total amount of the sale';
        SendDocument: Boolean;
        OnFinishCreditSaleDescription: Label 'On finish credit sale workflow';
        ERR_ORDER_SALE_SYNC: Label '%1 %2 was created successfully but an error occurred when syncing changes with POS, preventing POS sale from ending:\%3';
        ERR_DOC_MISSING: Label '%1 %2 is missing after page closed. Cannot sync with POS and end sale.';

    procedure SetAsk(AskIn: Boolean)
    begin
        Ask               := AskIn;
        SkipDefaultValues := true;
    end;

    procedure SetInvoice(InvoiceIn: Boolean)
    begin
        Invoice           := InvoiceIn;
        SkipDefaultValues := true;
    end;

    procedure SetPrint(PrintIn: Boolean)
    begin
        Print             := PrintIn;
        SkipDefaultValues := true;
    end;

    procedure SetPost(PostIn: Boolean)
    begin
        Post              := PostIn;
        SkipDefaultValues := true;
    end;

    procedure SetReceive(ReceiveIn: Boolean)
    begin
        Receive           := ReceiveIn;
        SkipDefaultValues := true;
    end;

    procedure SetShip(ShipIn: Boolean)
    begin
        Ship              := ShipIn;
        SkipDefaultValues := true;
    end;

    procedure SetDocumentTypeOrder()
    begin
        DocumentType      := DocumentType::Order;
        SkipDefaultValues := true;
    end;

    procedure SetDocumentTypeInvoice()
    begin
        DocumentType      := DocumentType::Invoice;
        SkipDefaultValues := true;
    end;

    procedure SetDocumentTypeReturnOrder()
    begin
        DocumentType      := DocumentType::"Return Order";
        SkipDefaultValues := true;
    end;

    procedure SetDocumentTypeCreditMemo()
    begin
        DocumentType      := DocumentType::"Credit Memo";
        SkipDefaultValues := true;
    end;

    procedure SetDocumentTypeQuote()
    begin
        //-NPR5.45 [325216]
        DocumentType      := DocumentType::Quote;
        SkipDefaultValues := true;
        //+NPR5.45 [325216]
    end;

    procedure SetWriteInAuditRoll(WriteInAuditRollIn: Boolean)
    begin
        WriteInAuditRoll  := WriteInAuditRollIn;
        SkipDefaultValues := true;
    end;

    procedure SetShowCreationMessage()
    begin
        ShowCreationMessage := true;
    end;

    procedure SetReturnAmount(Parameter: Text)
    var
        PercentageText: Text;
    begin
        ReturnAmount := true;
        PercentageText := CopyStr(Parameter,StrLen('SALESDOC_RET_AMT?')+1);
        if PercentageText<>'' then
          Evaluate(ReturnAmountPercentage,PercentageText)
        else
          ReturnAmountPercentage := 100;
    end;

    procedure SetOutput(Parameter: Text)
    var
        CodeunitText: Text;
    begin
        OutputDocument       := true;
        CodeunitText := CopyStr(Parameter,StrLen('SALESDOC_OUTPUT_ON?')+1);
        if CodeunitText <> '' then
          Evaluate(OutputCodeunit,CodeunitText)
        else
          OutputCodeunit := 0;
    end;

    procedure SetFinishSale()
    begin
        FinishSale := true;
    end;

    procedure SetShowDepositDialog()
    begin
        ShowDepositDialog := true;
    end;

    procedure SetOrderType(Parameter: Text)
    var
        OrderTypeText: Text;
    begin
        OrderTypeSet := true;
        OrderTypeText := CopyStr(Parameter,StrLen('SALESDOC_ORD_TYPE?')+1);
        if OrderTypeText<>'' then
          Evaluate(OrderType,OrderTypeText)
        else
          OrderType := 0;
    end;

    procedure SetTransferSalesPerson(TransferSalesPersonIn: Boolean)
    begin
        TransferSalesPerson := TransferSalesPersonIn;
    end;

    procedure SetTransferPostingsetup(TransferPostingSetupIn: Boolean)
    begin
        TransferPostingSetup := TransferPostingSetupIn;
    end;

    procedure SetTransferDimensions(TransferDimensionsIn: Boolean)
    begin
        TransferDimensions := TransferDimensionsIn;
    end;

    procedure SetTransferPaymentMethod(TransferPaymentMethodIn: Boolean)
    begin
        TransferPaymentMethod := TransferPaymentMethodIn;
    end;

    procedure SetTransferTaxSetup(TransferTaxSetupIn: Boolean)
    begin
        TransferTaxSetup  := TransferTaxSetupIn;
    end;

    procedure SetTransferTransactionData(TransferTransactionDataIn: Boolean)
    begin
        TransferTransactionData  := TransferTransactionDataIn;
    end;

    procedure SetAutoReserveSalesLine(AutoReserveSalesLine: Boolean)
    begin
        AutoReserveSalesLines := AutoReserveSalesLine;
    end;

    procedure SetSendPostedPdf2Nav(SendPostedPdf2NavIn: Boolean)
    begin
        SendPostedPdf2Nav := SendPostedPdf2NavIn;
    end;

    procedure SetRetailPrint(RetailPrintIn: Boolean)
    begin
        RetailPrint := RetailPrintIn;
    end;

    procedure SetOpenSalesDocAfterExport(OpenSalesDocAfterExportIn: Boolean)
    begin
        //-NPR5.50 [300557]
        OpenSalesDocAfterExport := OpenSalesDocAfterExportIn;
        //+NPR5.50 [300557]
    end;

    procedure SetSendDocument(SendDocumentIn: Boolean)
    begin
        //-NPR5.52 [352473]
        SendDocument := SendDocumentIn;
        //+NPR5.52 [352473]
    end;

    procedure Reset()
    begin
        Ask                    := false;
        Invoice                := false;
        Print                  := false;
        Post                   := false;
        Receive                := false;
        Ship                   := false;
        DocumentType           := DocumentType::Order;
        WriteInAuditRoll       := false;
        SkipDefaultValues      := false;
        ShowCreationMessage    := false;
        ReturnAmount           := false;
        ReturnAmountPercentage := 100;
        OutputDocument         := false;
        OutputCodeunit         := 0;
        FinishSale             := false;
        ShowDepositDialog      := false;
        OrderTypeSet           := false;
        TransferSalesPerson    := false;
        TransferPostingSetup   := true;
        TransferDimensions     := false;
        TransferPaymentMethod  := false;
        TransferTaxSetup       := false;
        AutoReserveSalesLines := false;
        SendPostedPdf2Nav := false;
        RetailPrint := false;
        //-NPR5.50 [300557]
        OpenSalesDocAfterExport := false;
        //+NPR5.50 [300557]
        Clear(CreatedSalesHeader);
        //-NPR5.52 [352473]
        SendDocument := false;
        //+NPR5.52 [352473]
    end;

    procedure "--- Sales Document Functions"()
    begin
    end;

    procedure ProcessPOSSale(var SalePOS: Record "Sale POS"): Boolean
    var
        AuditRoll: Record "Audit Roll";
        GiftVoucher: Record "Gift Voucher";
        SalesHeaderQoute: Record "Sales Header";
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        SaleLinePOS: Record "Sale Line POS";
        RetailTableCode: Codeunit "Retail Table Code";
        RetailSalesLineCode: Codeunit "Retail Sales Line Code";
        SalesPost: Codeunit "Sales-Post";
        SalesPostYesNo: Codeunit "Sales-Post (Yes/No)";
        SalesPostAndPrint: Codeunit "Sales-Post + Print";
        SalesPostAndPdf2Nav: Codeunit "Sales-Post and Pdf2Nav";
        TicketManagement: Codeunit "TM Ticket Management";
        TicketAccessRsvMgt: Codeunit "Ticket Access Reservation Mgt.";
        Posted: Boolean;
        NPRetailSetup: Record "NP Retail Setup";
        POSCreateEntry: Codeunit "POS Create Entry";
        Success: Boolean;
        POSSalesDocumentOutputMgt: Codeunit "POS Sales Document Output Mgt.";
    begin
        NPRetailSetup.Get;

        if SalePOS."Sales Document No." <> '' then
          SalesHeader.Get(SalePOS."Sales Document Type",SalePOS."Sales Document No.");

        GetSetupValues(SalesHeader,RetailSalesLineCode.GetSalesAmountInclVAT(SalePOS));

        // Delete the Qoute if we are posting the sale
        if SalesHeaderQoute.Get(SalePOS."Sales Document Type",SalePOS."Sales Document No.") and
          (SalePOS."Sales Document Type" = SalesHeaderQoute."Document Type"::Quote) and Post then begin
          SalesHeader."No." := '';
          SalesHeaderQoute.Delete(true);
        end;

        if (SalePOS."Sales Document No." <> '') then begin
          SalesHeader.Ship    := Ship;
          SalesHeader.Invoice := Invoice;
          SalesHeader.Receive := Receive;

          if SalesHeader."Salesperson Code" = '' then
            SalesHeader."Salesperson Code" := SalePOS."Salesperson Code";

          SalesLine.SetRange("Document Type",SalesHeader."Document Type");
          SalesLine.SetRange("Document No." ,SalesHeader."No.");
          SalesLine.DeleteAll(true);
        end else
          CreateSalesHeader(SalePOS,SalesHeader);

        with SalePOS do begin
          Clear(SaleLinePOS);
          SaleLinePOS.SetRange("Register No.","Register No.");
          SaleLinePOS.SetRange("Sales Ticket No.","Sales Ticket No.");
          SaleLinePOS.ModifyAll( Silent, true );
          SaleLinePOS.SetFilter( "No.", '<>%1', '' );

          if SaleLinePOS.FindSet then begin
            CopySaleCommentLines(SalePOS,SalesHeader);
            CopySalesLines(SaleLinePOS,SalesHeader);
          end;

          if AutoReserveSalesLines then
            ReserveSalesLines(SalesHeader, true);

          Commit;

          if OpenSalesDocAfterExport then begin
            //-NPR5.53 [377510]
            OpenSalesDocCardAndSyncChangesBackToPOSSale(SalesHeader, SalePOS);
            Commit;
        //+NPR5.53 [377510]
          end;

          CreatedSalesHeader := SalesHeader;

          if Post then
            if Ask then
              Posted := SalesPostYesNo.Run(SalesHeader)
            else
              Posted := SalesPost.Run(SalesHeader);

          if Post and (not Posted) then
            Message(POSTING_ERROR, SalesHeader."Document Type", SalesHeader."No.", GetLastErrorText);

          if WriteInAuditRoll then begin
            CreateDocumentPostingAudit(SalesHeader,SalePOS,Posted);
            if NPRetailSetup."Advanced POS Entries Activated" then begin
              POSCreateEntry.CreatePOSEntryForCreatedSalesDocument(SalePOS,SalesHeader,Posted);
            end;
            SaleLinePOS.DeleteAll;
          end else
            ConvertSaleLinePOSToComments(SalesHeader,SalePOS);

          Commit;

        //-NPR5.53 [377510]
          if Post and Posted then begin
            if Print then begin
              POSSalesDocumentOutputMgt.SetOnRunOperation(0, 0);
              if not POSSalesDocumentOutputMgt.Run(SalesHeader) then
                Message(PrintingErrorTxt,GetLastErrorText);
            end;

            if SendDocument then begin
              POSSalesDocumentOutputMgt.SetOnRunOperation(1, 0);
              if not POSSalesDocumentOutputMgt.Run(SalesHeader) then
                Message(SendingErrorTxt,GetLastErrorText);
            end;

            if SendPostedPdf2Nav then begin
              POSSalesDocumentOutputMgt.SetOnRunOperation(2, 0);
              if not POSSalesDocumentOutputMgt.Run(SalesHeader) then
                Message(Pdf2NavSendingErrorTxt,GetLastErrorText);
            end;
          end;
        //+NPR5.53 [377510]

          if ShowCreationMessage then
            Message(Text000008,SalesHeader."Document Type", SalesHeader."No.");

          if ReturnAmount then
            CreatePrepaymentLineLegacy(SalePOS, SalesHeader, ReturnAmountPercentage);

          if Posted then begin
            SalePOS."Last Posting No."  := SalesHeader."Last Posting No.";
            SalePOS."Last Shipping No." := SalesHeader."Last Shipping No."
          end;

          if OutputDocument and (OutputCodeunit <> 0) then
            CODEUNIT.Run(OutputCodeunit, SalesHeader);

          PrintGiftVoucher(SalePOS);

          TicketManagement.PrintTicketFromSalesTicketNo("Sales Ticket No.");

          TicketAccessRsvMgt.PrintRsvFromSalesTicketNo("Sales Ticket No.");

          Commit;

          PrintRetailReceipt(SalePOS);

          InvokeOnFinishCreditSaleWorkflow(SalePOS);  //NPR5.53 [378985]

          OnAfterDebitSalePostEvent (SalePOS, SalesHeader, Posted, WriteInAuditRoll);

          Commit;
        end;
        exit( true );
    end;

    procedure CreateSalesHeader(var SalePOS: Record "Sale POS";var SalesHeader: Record "Sales Header")
    var
        Register: Record Register;
        Customer: Record Customer;
    begin
        Register.Get(SalePOS."Register No.");

        SalesHeader.Init;
        SalesHeader."Document Type" := DocumentType;
        SalesHeader."Document Date" := WorkDate;
        SalesHeader."Posting Date"  := Today;
        SalesHeader."Document Time" := Time;
        SalesHeader."Salesperson Code"          := SalePOS."Salesperson Code";
        SalesHeader."Sell-to Customer No.":= SalePOS."Customer No.";
        SalesHeader.Insert(true);
        //-NPR5.53 [377510]
        if SalePOS."Customer No." <> '' then begin
        //+NPR5.53 [377510]
          SalesHeader.Validate("Sell-to Customer No.",SalePOS."Customer No.");
        end;

        SalesHeader.Validate("Currency Code",'');
        SalesHeader."Shortcut Dimension 1 Code" := SalePOS."Shortcut Dimension 1 Code";
        SalesHeader."Shortcut Dimension 2 Code" := SalePOS."Shortcut Dimension 2 Code";
        SalesHeader."Dimension Set ID"          := SalePOS."Dimension Set ID";

        SalesHeader."Ship-to Name"              := SalePOS.Name;
        SalesHeader."Ship-to Address"           := SalePOS.Address;
        SalesHeader."Ship-to Address 2"         := SalePOS."Address 2";
        SalesHeader."Ship-to City"              := SalePOS.City;
        SalesHeader."Ship-to Post Code"         := SalePOS."Post Code";
        SalesHeader."Ship-to Country/Region Code" := SalePOS."Country Code";

        SalesHeader.Modify(true);

        if SalePOS."Payment Terms Code" <> '' then
          SalesHeader.Validate("Payment Terms Code", SalePOS."Payment Terms Code");

        SalesHeader."Salesperson Code"      := SalePOS."Salesperson Code";
        SalesHeader."Sales Ticket No."      := SalePOS."Sales Ticket No.";
        SalesHeader."Bill-to Contact"       := SalePOS."Contact No.";
        if SalesHeader."Sell-to Contact" = '' then
          SalesHeader."Sell-to Contact"      := SalePOS."Contact No.";
        SalesHeader."Your Reference"        := SalePOS.Reference;
        SalesHeader."External Document No." := SalePOS.Reference;
        SalesHeader.Validate("Location Code", Register."Location Code");
        if Customer.Get(SalePOS."Customer No.") then
          SalesHeader."Document Processing" := Customer."Document Processing";
        SalesHeader.Ship    := Ship;
        SalesHeader.Invoice := Invoice;
        SalesHeader.Receive := Receive;

        if OrderTypeSet then
          SalesHeader."Order Type" := OrderType;

        //-NPR5.52 [352473]
        SalesHeader.Validate("Prices Including VAT", SalePOS."Prices Including VAT");
        //+NPR5.52 [352473]

        TransferInfoFromSalePOS(SalePOS,SalesHeader);

        SalesHeader.Modify;
    end;

    local procedure ConvertSaleLinePOSToComments(var SalesHeader: Record "Sales Header";var SalePOS: Record "Sale POS")
    var
        SaleLinePOS: Record "Sale Line POS";
        TempSaleLinePOS: Record "Sale Line POS" temporary;
        Text10600062: Label 'Debit to %1 on invoice %2';
        Text10600063: Label 'Delivery to %1 on delivery %2';
        Text10600064: Label 'Credit to %1 on credit note %2';
        Text10600065: Label 'Transferred to %1 %2';
        TxtReturSalg: Label 'Delivery to %1 on return order %2';
    begin
        SaleLinePOS.SetCurrentKey(SaleLinePOS."Register No.",SaleLinePOS."Sales Ticket No.",SaleLinePOS."Line No.");
        SaleLinePOS.SetRange( "Register No.", SalePOS."Register No." );
        SaleLinePOS.SetRange( "Sales Ticket No.", SalePOS."Sales Ticket No." );
        SaleLinePOS.SetRange("Sale Type", SaleLinePOS."Sale Type"::Sale);

        if SaleLinePOS.FindSet then repeat
          TempSaleLinePOS.Init;
          TempSaleLinePOS := SaleLinePOS;
          TempSaleLinePOS.Insert;
        until SaleLinePOS.Next = 0;
        SaleLinePOS.DeleteAll;

        SaleLinePOS.Init;
        SaleLinePOS."Register No."     := TempSaleLinePOS."Register No.";
        SaleLinePOS."Sales Ticket No." := TempSaleLinePOS."Sales Ticket No.";
        SaleLinePOS."Line No."         := 1;
        SaleLinePOS."Sale Type"        := SaleLinePOS."Sale Type"::Comment;
        SaleLinePOS.Type               := SaleLinePOS.Type::Comment;
        SaleLinePOS.Date               := TempSaleLinePOS.Date;
        if (SalesHeader."Last Posting No." <> '') or
           (SalesHeader."Last Shipping No." <> '') or
           (SalesHeader."Last Return Receipt No." <> '') then
          case SalesHeader."Document Type" of
            SalesHeader."Document Type"::Invoice:
              SaleLinePOS.Description       := StrSubstNo(Text10600062,SalePOS."Customer No.",SalesHeader."Last Posting No.") + ':';
            SalesHeader."Document Type"::Order:
              SaleLinePOS.Description       := StrSubstNo(Text10600063,SalePOS."Customer No.",SalesHeader."Last Shipping No.") + ':';
            SalesHeader."Document Type"::"Credit Memo":
              SaleLinePOS.Description            := StrSubstNo(Text10600064,SalePOS."Customer No.",SalesHeader."Last Posting No.") + ':';
            SalesHeader."Document Type"::"Return Order" :
              SaleLinePOS.Description       := StrSubstNo(TxtReturSalg,SalePOS."Customer No.",SalesHeader."Last Return Receipt No.") + ':';
          end
        else
          SaleLinePOS.Description := StrSubstNo(Text10600065,SalesHeader."Document Type",SalesHeader."No.") + ':';
        SaleLinePOS.Validate(Quantity,1);
        SaleLinePOS.Insert(true);

        TempSaleLinePOS.SetCurrentKey(TempSaleLinePOS."Register No.",TempSaleLinePOS."Sales Ticket No.",TempSaleLinePOS."Line No.");
        if TempSaleLinePOS.FindSet then repeat
          SaleLinePOS.Init;
          SaleLinePOS."Register No."        := TempSaleLinePOS."Register No.";
          SaleLinePOS."Sales Ticket No."    := TempSaleLinePOS."Sales Ticket No.";
          SaleLinePOS."Line No."            := TempSaleLinePOS."Line No.";
          SaleLinePOS."Sale Type"           := SaleLinePOS."Sale Type"::Comment;
          SaleLinePOS.Type                  := SaleLinePOS.Type::Comment;
          SaleLinePOS.Date                  := TempSaleLinePOS.Date;
          SaleLinePOS.Description           := TempSaleLinePOS.Description;
          SaleLinePOS."Sales Document Type" := SalesHeader."Document Type";
          SaleLinePOS."Sales Document No."  := SalesHeader."No.";
          SaleLinePOS.Validate(Quantity,TempSaleLinePOS.Quantity);
          SaleLinePOS.Validate("Unit Price", TempSaleLinePOS."Unit Price");
          SaleLinePOS.Insert(true);
        until TempSaleLinePOS.Next = 0;
    end;

    procedure CopySaleCommentLines(var SalePOS: Record "Sale POS";var SalesHeader: Record "Sales Header")
    var
        SalesCommentLine: Record "Sales Comment Line";
        RetailComment: Record "Retail Comment";
    begin
        with SalePOS do begin
          RetailComment.SetRange("Table ID", DATABASE::"Sale POS" );
          RetailComment.SetRange("No.", "Register No.");
          RetailComment.SetRange("No. 2", "Sales Ticket No.");
          if RetailComment.FindSet then repeat
            SalesCommentLine.Init;
            SalesCommentLine."Document Type" := SalesHeader."Document Type";
            SalesCommentLine."No."           := SalesHeader."No.";
            SalesCommentLine."Line No."      := RetailComment."Line No.";
            SalesCommentLine.Date            := RetailComment.Date;
            SalesCommentLine.Code            := RetailComment.Code;
            SalesCommentLine.Comment         := RetailComment.Comment;
            SalesCommentLine.Insert(true);
          until RetailComment.Next = 0;
        end;
    end;

    procedure CopySalesLines(var SaleLinePOS: Record "Sale Line POS";var SalesHeader: Record "Sales Header")
    var
        CreditVoucher: Record "Credit Voucher";
        GiftVoucher: Record "Gift Voucher";
        SalesLine: Record "Sales Line";
        ReservationEntry: Record "Reservation Entry";
        Item: Record Item;
        SerialNoInfo: Record "Serial No. Information";
        ItemTrackingCode: Record "Item Tracking Code";
        RetailFormCode: Codeunit "Retail Form Code";
        ItemTrackingManagement: Codeunit "Item Tracking Management";
        SNRequired: Boolean;
        LotRequired: Boolean;
        SNInfoRequired: Boolean;
        LotInfoRequired: Boolean;
    begin
        if SaleLinePOS.FindSet then repeat
          SalesLine.Init;

          TestSaleLinePOS(SaleLinePOS);

          SalesLine."Document Type"         := SalesHeader."Document Type";
          SalesLine."Document No."          := SalesHeader."No.";

          case SaleLinePOS.Type of
            SaleLinePOS.Type::"G/L Entry" : SalesLine.Type := SalesLine.Type::"G/L Account";
            SaleLinePOS.Type::Comment     : SalesLine.Type := SalesLine.Type::" ";
          else
            SalesLine.Type := SalesLine.Type::Item;
          end;
          //-NPR5.48 [339049]
          SalesLine."Line No."    := SaleLinePOS."Line No.";
          //+NPR5.48 [339049]
          SaleLinePOS.TransferToSalesLine( SalesLine );
          SalesLine."Line No."    := SaleLinePOS."Line No.";
          SalesLine.Insert( true );
          if SalesLine.Type <> SalesLine.Type::" " then begin
            if ( SaleLinePOS."Gift Voucher Ref." <> '' ) and ( SaleLinePOS.Quantity < 0 ) then
              RetailFormCode.SetGiftVoucherStatus( SaleLinePOS."Gift Voucher Ref.", GiftVoucher.Status::Cancelled );

            if ( SaleLinePOS."Credit voucher ref." <> '' ) and ( SaleLinePOS.Quantity < 0 ) then
              RetailFormCode.SetCreditVoucherStatus( SaleLinePOS."Credit voucher ref.", CreditVoucher.Status::Cancelled );

        //-NPR5.42 [299973]
        //    SalesLine.VALIDATE("Unit Price",SaleLinePOS."Unit Price");
        //+NPR5.42 [299973]

            if SalesHeader."Document Type" in
              [SalesHeader."Document Type"::"Return Order",SalesHeader."Document Type"::"Credit Memo"] then
              SalesLine.Validate(Quantity,-SaleLinePOS.Quantity)
            else begin
              SalesLine.Validate(Quantity,SaleLinePOS.Quantity);
              if SaleLinePOS."Sale Type" = SaleLinePOS."Sale Type"::"Out payment" then
                SalesLine.Validate(Quantity,-SaleLinePOS.Quantity);
            end;

        //-NPR5.42 [299973]
        //    IF (SaleLinePOS."Discount %" <> 0) OR (SaleLinePOS."Line Discount %, manually") OR
        //       (SaleLinePOS."Discount Type" = SaleLinePOS."Discount Type"::Manual) THEN
        //      SalesLine.VALIDATE("Line Discount %",SaleLinePOS."Discount %");
        //
        //    IF SaleLinePOS."Unit Price" = 0 THEN
        //      SalesLine.VALIDATE("Line Discount %",100);

            if SalesLine."Unit Price" <> SaleLinePOS."Unit Price" then begin
              SalesLine."Line Discount %" := SaleLinePOS."Discount %";
              SalesLine.Validate("Unit Price",SaleLinePOS."Unit Price");
            end;
            if SalesLine."Line Discount %" <> SaleLinePOS."Discount %" then
              SalesLine.Validate("Line Discount %",SaleLinePOS."Discount %");
        //+NPR5.42 [299973]

            TransferInfoFromSaleLinePOS(SaleLinePOS,SalesLine);
            SalesLine.Modify;
          end;
          if SaleLinePOS."Serial No."<>'' then begin
            ReservationEntry.SetCurrentKey("Entry No." ,Positive );
            ReservationEntry.SetRange( Positive, false );
            if ReservationEntry.Find('+') then;
            ReservationEntry.Init;
            ReservationEntry."Entry No." += 1;
            ReservationEntry.Positive := false;
            ReservationEntry."Creation Date" := Today;
            ReservationEntry."Created By" := UserId;
            ReservationEntry."Item No." := SaleLinePOS."No.";
            ReservationEntry."Location Code" := SaleLinePOS."Location Code";
            ReservationEntry."Quantity (Base)" := -SalesLine."Quantity (Base)";
            ReservationEntry."Reservation Status" := ReservationEntry."Reservation Status"::Surplus;
            ReservationEntry."Source Type" := 37;
            ReservationEntry."Source Subtype" := SalesLine."Document Type";
            ReservationEntry."Source ID" := SalesLine."Document No.";
            ReservationEntry."Source Batch Name" := '';
            ReservationEntry."Source Ref. No." := SalesLine."Line No.";
            ReservationEntry."Expected Receipt Date" := 0D;
            ReservationEntry."Serial No." := SaleLinePOS."Serial No.";
            ReservationEntry."Qty. per Unit of Measure" := SalesLine.Quantity;
            ReservationEntry.Quantity := -SalesLine.Quantity;
            ReservationEntry."Qty. to Handle (Base)" := -SalesLine.Quantity;
            ReservationEntry."Qty. to Invoice (Base)" := -SalesLine.Quantity;
            ReservationEntry.Insert;
          end;
          if Item.Get(SaleLinePOS."No.") then begin
            if Item."Item Tracking Code"<>'' then begin
              ItemTrackingCode.Get(Item."Item Tracking Code");
              ItemTrackingManagement.GetItemTrackingSettings(ItemTrackingCode,1,false,SNRequired,LotRequired,SNInfoRequired,LotInfoRequired);
              if SNRequired then begin
                if SaleLinePOS."Serial No."='' then
                  Error(Text000013,SaleLinePOS."No.",SaleLinePOS.Description);
              end;
              if SNInfoRequired then begin
                SerialNoInfo.Get(SaleLinePOS."No.",SaleLinePOS."Variant Code",SaleLinePOS."Serial No.");
                SerialNoInfo.TestField(Blocked,false);
              end;
            end else begin
              if SerialNoInfo.Get(SaleLinePOS."No.",SaleLinePOS."Variant Code",SaleLinePOS."Serial No.") then
                SerialNoInfo.TestField(Blocked,false);
            end;
          end;
        until SaleLinePOS.Next = 0;
    end;

    procedure TestSaleLinePOS(var SaleLinePOS: Record "Sale Line POS")
    begin
        if SaleLinePOS."Sale Type" = SaleLinePOS."Sale Type"::Payment then
          Error(Text000010);

        if SaleLinePOS."Sales Document No." <> '' then
          Error(Text000012);

        if (SaleLinePOS.Type = SaleLinePOS.Type::Customer) and
           (SaleLinePOS."Sale Type" = SaleLinePOS."Sale Type"::Deposit) then
          Error(Text000007);

        //-NPR5.50 [300557]
        if SaleLinePOS."Buffer Document No." <> '' then
          Error(Text000007);
        //+NPR5.50 [300557]

        if SaleLinePOS.Type = SaleLinePOS.Type::"Item Group" then
          Error(Text000003);
    end;

    procedure OpenSalesDoc(var SalePOS: Record "Sale POS")
    var
        SaleLinePOS: Record "Sale Line POS";
        SalesDocNo: Code[20];
        SalesHeader: Record "Sales Header";
        SalesOrder: Page "Sales Order";
        SalesCreditMemo: Page "Sales Credit Memo";
        BlanketSalesOrder: Page "Blanket Sales Order";
        SalesReturnOrder: Page "Sales Return Order";
        SalesQuote: Page "Sales Quote";
    begin
        SaleLinePOS.SetRange("Register No.",SalePOS."Register No.");
        SaleLinePOS.SetRange("Sales Ticket No.",SalePOS."Sales Ticket No.");

        if SaleLinePOS.FindSet then repeat
          if SaleLinePOS."Sales Document No." <> '' then begin
            SalesDocNo   := SaleLinePOS."Sales Document No.";
            DocumentType := SaleLinePOS."Sales Document Type";
          end;
        until (SaleLinePOS.Next = 0) or (SalesDocNo <> '');

        if SalesDocNo <> '' then begin
          SalesHeader.Get(DocumentType,SalesDocNo);

          if DocumentType = DocumentType::Order then begin
            SalesOrder.SetRecord(SalesHeader);
            SalesOrder.RunModal;
          end;

          if DocumentType = DocumentType::"Credit Memo" then begin
            SalesCreditMemo.SetRecord(SalesHeader);
            SalesCreditMemo.RunModal;
          end;

          if DocumentType = DocumentType::"Blanket Order" then begin
            BlanketSalesOrder.SetRecord(SalesHeader);
            BlanketSalesOrder.RunModal;
          end;

          if DocumentType = DocumentType::"Return Order" then begin
            SalesReturnOrder.SetRecord(SalesHeader);
            SalesReturnOrder.RunModal;
          end;
          //-NPR5.45 [325216]
          if DocumentType = DocumentType::Quote then begin
            SalesQuote.SetRecord(SalesHeader);
            SalesQuote.RunModal;
          end;
          //+NPR5.45 [325216]
        end;
    end;

    procedure TestSalePOS(var SalePOS: Record "Sale POS")
    var
        SaleLinePOS: Record "Sale Line POS";
    begin
        SaleLinePOS.SetRange("Register No.",SalePOS."Register No.");
        SaleLinePOS.SetRange("Sales Ticket No.",SalePOS."Sales Ticket No.");

        if SaleLinePOS.FindSet then repeat
          TestSaleLinePOS(SaleLinePOS);
        until SaleLinePOS.Next = 0;
    end;

    local procedure TransferInfoFromSalePOS(var SalePOS: Record "Sale POS";var SalesHeader: Record "Sales Header")
    var
        PaymentTypePOS: Record "Payment Type POS";
        SaleLinePOS: Record "Sale Line POS";
    begin
        if TransferSalesPerson then begin
          if SalePOS."Salesperson Code" <> '' then
            SalesHeader.Validate("Salesperson Code",SalePOS."Salesperson Code");
        end;

        if  TransferPostingSetup then begin
          if SalePOS."Gen. Bus. Posting Group" <> '' then
            SalesHeader.Validate("Gen. Bus. Posting Group",SalePOS."Gen. Bus. Posting Group");
          if SalePOS."VAT Bus. Posting Group" <> '' then
            SalesHeader.Validate("VAT Bus. Posting Group",SalePOS."VAT Bus. Posting Group");
        end;

        if TransferDimensions then begin
          SalesHeader."Dimension Set ID" := SalePOS."Dimension Set ID";
          SalesHeader."Shortcut Dimension 1 Code" := SalePOS."Shortcut Dimension 1 Code";
          SalesHeader."Shortcut Dimension 2 Code" := SalePOS."Shortcut Dimension 2 Code";
        end;

        if TransferPaymentMethod then begin
          SaleLinePOS.SetRange("Register No.",SalePOS."Register No.");
          SaleLinePOS.SetRange("Sales Ticket No.",SalePOS."Sales Ticket No.");
          SaleLinePOS.SetRange(Date,SalePOS.Date);
          SaleLinePOS.SetRange("Sale Type",SaleLinePOS."Sale Type"::Payment);
          if SaleLinePOS.FindFirst then
            if PaymentTypePOS.Get(SaleLinePOS."No.") then
              if PaymentTypePOS."Payment Method Code" <> '' then
                SalesHeader.Validate("Payment Method Code",PaymentTypePOS."Payment Method Code" );
        end;

        if TransferTaxSetup then begin
          if SalePOS."Tax Area Code" <>  '' then
            SalesHeader.Validate("Tax Area Code",SalePOS."Tax Area Code");
          if SalePOS."Tax Liable" then
            SalesHeader.Validate("Tax Liable",true);
        end;

        if TransferTransactionData then begin

        end;
    end;

    local procedure TransferInfoFromSaleLinePOS(var SaleLinePOS: Record "Sale Line POS";var SalesLine: Record "Sales Line")
    begin
        if  TransferPostingSetup then begin
          if SaleLinePOS."Posting Group" <> '' then
            SalesLine.Validate("Posting Group",SaleLinePOS."Posting Group");
          if SaleLinePOS."Gen. Prod. Posting Group" <> '' then
            SalesLine.Validate("Gen. Prod. Posting Group",SaleLinePOS."Gen. Prod. Posting Group");
          if SaleLinePOS."Gen. Bus. Posting Group" <> '' then
            SalesLine.Validate("Gen. Bus. Posting Group",SaleLinePOS."Gen. Bus. Posting Group");
        end;

        if TransferDimensions then begin
          SalesLine."Dimension Set ID" := SaleLinePOS."Dimension Set ID";
          SalesLine."Shortcut Dimension 1 Code" := SaleLinePOS."Shortcut Dimension 1 Code";
          SalesLine."Shortcut Dimension 2 Code" := SaleLinePOS."Shortcut Dimension 2 Code";
        end;

        if TransferTaxSetup then begin
         if SaleLinePOS."Tax Area Code" <>  '' then
            SalesLine.Validate("Tax Area Code",SaleLinePOS."Tax Area Code");
          if SaleLinePOS."Tax Liable" then
            SalesLine.Validate("Tax Liable",true);
        end;

        if TransferTransactionData then begin

        end;
    end;

    procedure ReserveSalesLines(var SalesHeader: Record "Sales Header";WithError: Boolean)
    var
        SalesLine: Record "Sales Line";
        AllLinesReserved: Boolean;
        Item: Record Item;
    begin
        SalesLine.Reset;
        SalesLine.SetFilter("Document Type", '=%1', SalesHeader."Document Type");
        SalesLine.SetFilter("Document No.", '=%1', SalesHeader."No.");
        SalesLine.SetFilter(Type, '=%1', SalesLine.Type::Item);
        //-NPR5.50 [300557]
        SalesLine.SetFilter(Reserve, '<>%1', SalesLine.Reserve::Never);
        //+NPR5.50 [300557]
        AllLinesReserved := true;
        if SalesLine.FindSet then begin
          repeat
            if not ReserveSaleLine(SalesLine) then begin
              AllLinesReserved := false;
              //-NPR5.50 [300557]
              if WithError then
                Error(RESERVE_FAIL_ERROR, Item.TableCaption, SalesLine."No.", SalesLine.FieldCaption(Quantity), SalesLine.Quantity);
              //+NPR5.50 [300557]
            end;
          until (0 = SalesLine.Next);
        end;

        if not AllLinesReserved then begin
          Message(RESERVE_FAIL_MESSAGE, SalesHeader."Document Type", SalesHeader."No.");
        end;
    end;

    local procedure ReserveSaleLine(var SalesLine: Record "Sales Line") FullyReservedLine: Boolean
    var
        ReservationManagement: Codeunit "Reservation Management";
        SalesLineReserve: Codeunit "Sales Line-Reserve";
        QtyToReserve: Decimal;
        QtyToReserveBase: Decimal;
        ResText000: Label 'Fully reserved.';
        FullAutoReservation: Boolean;
        QtyReserved: Decimal;
        QtyReservedBase: Decimal;
        ReservationEntry: Record "Reservation Entry";
    begin
        Clear(ReservationManagement);
        Clear(SalesLineReserve);

        //Test line
        SalesLine.TestField("Job No.",'');
        SalesLine.TestField("Drop Shipment",false);
        SalesLine.TestField(Type,SalesLine.Type::Item);
        SalesLine.TestField("Shipment Date");

        //Calc qty�s
        SalesLine.CalcFields("Reserved Quantity","Reserved Qty. (Base)");
        if SalesLine."Document Type" = SalesLine."Document Type"::"Return Order" then begin
          SalesLine."Reserved Quantity" := -SalesLine."Reserved Quantity";
          SalesLine."Reserved Qty. (Base)" := -SalesLine."Reserved Qty. (Base)";
        end;
        QtyReserved := SalesLine."Reserved Quantity";
        QtyReservedBase := SalesLine."Reserved Qty. (Base)";

        SalesLineReserve.ReservQuantity(SalesLine, QtyToReserve, QtyToReserveBase);

        //Test qty to reserve
        if Abs(QtyToReserveBase) - Abs(QtyReservedBase) = 0 then
          Error(ResText000);

        //Set record to get desc.
        ReservationEntry."Source Type" := DATABASE::"Sales Line";
        ReservationEntry."Source Subtype" := SalesLine."Document Type";
        ReservationEntry."Source ID" := SalesLine."Document No.";
        ReservationEntry."Source Ref. No." := SalesLine."Line No.";

        ReservationEntry."Item No." := SalesLine."No.";
        ReservationEntry."Variant Code" := SalesLine."Variant Code";
        ReservationEntry."Location Code" := SalesLine."Location Code";
        ReservationEntry."Shipment Date" := SalesLine."Shipment Date";

        //CaptionText := ReserveSalesLine.Caption(SalesLine);

        ReservationManagement.SetSalesLine(SalesLine);

        //Run auto reserve
        ReservationManagement.AutoReserve(
          FullAutoReservation,ReservationEntry.Description,
          ReservationEntry."Shipment Date",QtyToReserve - QtyReserved,QtyToReserveBase - QtyReservedBase);

        FullyReservedLine := FullAutoReservation;
        exit(FullyReservedLine);
    end;

    procedure CreatePrepaymentLineLegacy(SalePOS: Record "Sale POS";var SalesHeader: Record "Sales Header";DepositPercentage: Decimal)
    var
        Marshaller: Codeunit "POS Event Marshaller";
        SaleLinePOS: Record "Sale Line POS";
        LineNo: Integer;
    begin
        SalesHeader.CalcFields("Amount Including VAT");
        if SalesHeader."Amount Including VAT"<>0 then begin
          if SalesHeader."Prepayment %"<>0 then
            SuggestedDepositAmount := SalesHeader."Amount Including VAT"*(SalesHeader."Prepayment %"/100)
          else
            SuggestedDepositAmount := SalesHeader."Amount Including VAT"*(DepositPercentage/100);
          if ShowDepositDialog then begin
            if not Marshaller.NumPad(Text000011,SuggestedDepositAmount,false,false) then
              SuggestedDepositAmount := 0;
          end;
          if SuggestedDepositAmount<>0 then begin
            SaleLinePOS.Reset;
            SaleLinePOS.SetCurrentKey("Register No.","Sales Ticket No.","Line No.");
            SaleLinePOS.SetRange("Register No.",SalePOS."Register No.");
            SaleLinePOS.SetRange("Sales Ticket No.",SalePOS."Sales Ticket No.");
            if SaleLinePOS.FindLast then;
            LineNo := SaleLinePOS."Line No.";

            SaleLinePOS.SetCurrentKey("Register No.","Sales Ticket No.",Date,"Sale Type","Line No.");
            SaleLinePOS.Init;
            SaleLinePOS."Register No."     := SalePOS."Register No.";
            SaleLinePOS."Sales Ticket No." := SalePOS."Sales Ticket No.";
            SaleLinePOS.Date               := SalePOS.Date;
            SaleLinePOS."Sale Type"        := SaleLinePOS."Sale Type"::Deposit;
            SaleLinePOS."Line No."         := LineNo + 1;
            SaleLinePOS.Type               := SaleLinePOS.Type::Customer;
            SaleLinePOS.Date               := SalePOS.Date;
            SaleLinePOS.Insert(true);
            SalePOS.Validate("Customer No.",SalesHeader."Bill-to Customer No.");
            SaleLinePOS.Validate(Quantity,1);
            SaleLinePOS.Validate( "No.",SalesHeader."Bill-to Customer No.");
            SaleLinePOS."Sales Document Type" := SalesHeader."Document Type";
            SaleLinePOS."Sales Document No." := SalesHeader."No.";
            SaleLinePOS."Sales Document Prepayment" := true;
            SaleLinePOS."Sales Doc. Prepayment Value" := (SuggestedDepositAmount/SalesHeader."Amount Including VAT")*100;
            SaleLinePOS.Validate("Unit Price",SuggestedDepositAmount);
            SaleLinePOS.Description := StrSubstNo(Text000009,SalesHeader."Document Type",SalesHeader."No.");
            SaleLinePOS.Modify(true);
            Commit;
          end;
        end;
    end;

    local procedure PrintRetailReceipt(SalePOS: Record "Sale POS")
    var
        AuditRoll: Record "Audit Roll";
        POSEntry: Record "POS Entry";
        NPRetailSetup: Record "NP Retail Setup";
        Success: Boolean;
        RetailReportSelectionMgt: Codeunit "Retail Report Selection Mgt.";
        RecRef: RecordRef;
        ReportSelectionRetail: Record "Report Selection Retail";
        RetailSalesCode: Codeunit "Retail Sales Code";
        POSEntryManagement: Codeunit "POS Entry Management";
    begin
        //-NPR5.40 [304639]
        if not WriteInAuditRoll then
          exit;

        if not RetailPrint then
          exit;

        NPRetailSetup.Get;
        if NPRetailSetup."Advanced Posting Activated" then begin
          POSEntry.SetRange("Document No.", SalePOS."Sales Ticket No.");
          if not POSEntry.FindFirst then
            exit;
          ClearLastError;
          asserterror begin
        //-NPR5.53 [349793]
        //    RecRef.GETTABLE(POSEntry);
        //    RetailReportSelectionMgt.SetRegisterNo(SalePOS."Register No.");
        //    RetailReportSelectionMgt.RunObjects(RecRef, ReportSelectionRetail."Report Type"::"Sales Doc. Confirmation (POS Entry)");
            POSEntryManagement.PrintEntry(POSEntry, false);
        //+NPR5.53 [349793]
            Commit;
            Success := true;
            Error('');
          end;
          if not Success then
            Message(RetailPrintErrorTxt, GetLastErrorText);
        end else begin
          AuditRoll.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");
          if not AuditRoll.FindSet then
            exit;
          if not RetailSalesCode.Run(AuditRoll) then
            Message(Text000002,Text000005,AuditRoll.FieldCaption("Sales Ticket No."),AuditRoll."Sales Ticket No.")
        end;
        //+NPR5.40 [304639]
    end;

    local procedure PrintGiftVoucher(var SalePOS: Record "Sale POS")
    var
        AuditRoll: Record "Audit Roll";
        RetailTableCode: Codeunit "Retail Table Code";
        GiftVoucher: Record "Gift Voucher";
    begin
        //-NPR5.50 [300557]
        AuditRoll.SetRange("Register No.", SalePOS."Register No.");
        AuditRoll.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");
        AuditRoll.SetRange("Sale Date", SalePOS.Date);
        AuditRoll.SetRange(Type, AuditRoll.Type::"G/L");
        AuditRoll.SetRange("Sale Type", AuditRoll."Sale Type"::"Debit Sale");
        AuditRoll.SetFilter("Gift voucher ref.", '<>%1', '');
        if AuditRoll.FindSet() then repeat
          if GiftVoucher.Get(AuditRoll."Gift voucher ref.") then begin
            GiftVoucher.SetRecFilter();
            if not RetailTableCode.Run(GiftVoucher) then
              Message(Text000002,GiftVoucher.TableCaption,GiftVoucher.FieldCaption("No."),GiftVoucher."No.");
          end;
        until AuditRoll.Next = 0;
        //+NPR5.50 [300557]
    end;

    procedure GetCreatedSalesHeader(var CreatedSalesHeaderOut: Record "Sales Header")
    begin
        //-NPR5.40 [300557]
        CreatedSalesHeaderOut := CreatedSalesHeader;
        //+NPR5.40 [300557]
    end;

    local procedure PostPrepaymentBeforePOSSaleEnd(var SalesHeader: Record "Sales Header";var SaleLinePOS: Record "Sale Line POS")
    var
        SalesPostPrepayments: Codeunit "Sales-Post Prepayments";
        SalesLine: Record "Sales Line";
        ReportSelections: Record "Report Selections";
        RecordVariant: Variant;
        SalesInvoiceHeader: Record "Sales Invoice Header";
        Print: Boolean;
        POSPrepaymentMgt: Codeunit "POS Prepayment Mgt.";
        Send: Boolean;
        Pdf2Nav: Boolean;
        POSSalesDocumentOutputMgt: Codeunit "POS Sales Document Output Mgt.";
    begin
        with SaleLinePOS do begin
          SalesHeader.TestField("Document Type", SalesHeader."Document Type"::Order);

        //-NPR5.52 [352473]
          //-NPR5.51
          // ApplyPrepaymentPercentageToAllLines(SalesHeader, "Sales Doc. Prepayment %", TRUE);
          //ApplyPrepaymentValueToAllLines(SalesHeader,"Sales Doc. Prepayment Value",TRUE,FALSE);
          //+NPR5.51

          if "Sales Doc. Prepay Is Percent" then
            POSPrepaymentMgt.SetPrepaymentPercentageToPay(SalesHeader, true, "Sales Doc. Prepayment Value")
          else
            POSPrepaymentMgt.SetPrepaymentAmountToPayInclVAT(SalesHeader, true, "Sales Doc. Prepayment Value");

          Pdf2Nav := "Sales Document Pdf2Nav";
          Send := "Sales Document Send";
        //+NPR5.52 [352473]
          Print := "Sales Document Print";
          "Sales Document Prepayment" := false;
          "Sales Document Print" := false;
        //-NPR5.52 [352473]
          "Sales Document Pdf2Nav" := false;
          "Sales Document Send" := false;
        //+NPR5.52 [352473]
          Modify(true);

          SalesPostPrepayments.Invoice(SalesHeader);
          "Buffer Document Type" := "Buffer Document Type"::Faktura;
          "Posted Sales Document Type" := "Posted Sales Document Type"::INVOICE;
          "Posted Sales Document No." := SalesHeader."Last Prepayment No.";
          Validate("Buffer Document No.", SalesHeader."Last Prepayment No.");
          Modify(true);

          Commit;

          //-NPR5.52 [352473]
          if Print then begin
            POSSalesDocumentOutputMgt.PrintDocument(SalesHeader, 1);
          end;

          if Send then begin
            POSSalesDocumentOutputMgt.SendDocument(SalesHeader, 1);
          end;

          if Pdf2Nav then begin
            POSSalesDocumentOutputMgt.SendPdf2NavDocument(SalesHeader, 1);
          end;
          //+NPR5.52 [352473]
        end;
    end;

    local procedure PostPrepaymentRefundBeforePOSSaleEnd(var SalesHeader: Record "Sales Header";var SaleLinePOS: Record "Sale Line POS")
    var
        SalesPostPrepayments: Codeunit "Sales-Post Prepayments";
        DeleteAfter: Boolean;
        ReportSelections: Record "Report Selections";
        RecordVariant: Variant;
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        Print: Boolean;
        Send: Boolean;
        Pdf2Nav: Boolean;
        POSSalesDocumentOutputMgt: Codeunit "POS Sales Document Output Mgt.";
    begin
        //-NPR5.50 [300557]
        with SaleLinePOS do begin
          SalesHeader.TestField("Document Type", SalesHeader."Document Type"::Order);
          DeleteAfter := "Sales Document Delete";
          Print := "Sales Document Print";
          //-NPR5.52 [352473]
          Send := "Sales Document Send";
          Pdf2Nav := "Sales Document Pdf2Nav";
          //+NPR5.52 [352473]
          "Sales Document Prepay. Refund" := false;
          "Sales Document Delete" := false;
          "Sales Document Print" := false;
          //-NPR5.52 [352473]
          "Sales Document Send" := false;
          "Sales Document Pdf2Nav" := false;
          //+NPR5.52 [352473]
          Modify(true);

          SalesPostPrepayments.CreditMemo(SalesHeader);
          "Posted Sales Document Type" := "Posted Sales Document Type"::CREDIT_MEMO;
          "Posted Sales Document No." := SalesHeader."Last Prepmt. Cr. Memo No.";
          "Buffer Document Type" := "Buffer Document Type"::Kreditnota;
          Validate("Buffer Document No.", SalesHeader."Last Prepmt. Cr. Memo No.");
          Modify(true);

          if DeleteAfter then
            SalesHeader.Delete(true);

          Commit;

          //-NPR5.52 [352473]
          if Print then begin
            POSSalesDocumentOutputMgt.PrintDocument(SalesHeader, 2);
          end;

          if Send then begin
            POSSalesDocumentOutputMgt.SendDocument(SalesHeader, 2);
          end;

          if Pdf2Nav then begin
            POSSalesDocumentOutputMgt.SendPdf2NavDocument(SalesHeader, 2);
          end;
          //+NPR5.52 [352473]
        end;
        //+NPR5.50 [300557]
    end;

    local procedure PostDocumentBeforePOSSaleEnd(var SalesHeader: Record "Sales Header";var SaleLinePOS: Record "Sale Line POS")
    var
        SalesPost: Codeunit "Sales-Post";
        ReportSelections: Record "Report Selections";
        RecordVariant: Variant;
        SalesInvoiceHeader: Record "Sales Invoice Header";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        ReturnReceiptHeader: Record "Return Receipt Header";
        SalesShipmentHeader: Record "Sales Shipment Header";
        Print: Boolean;
        Send: Boolean;
        Pdf2Nav: Boolean;
        POSSalesDocumentOutputMgt: Codeunit "POS Sales Document Output Mgt.";
    begin
        //-NPR5.50 [300557]
        with SaleLinePOS do begin
          if not (SalesHeader."Document Type" in [SalesHeader."Document Type"::Invoice, SalesHeader."Document Type"::Order, SalesHeader."Document Type"::"Credit Memo", SalesHeader."Document Type"::"Return Order"]) then
            SalesHeader.FieldError("Document Type");
          SalesHeader.Ship := "Sales Document Ship";
          SalesHeader.Invoice := "Sales Document Invoice";
          SalesHeader.Receive := "Sales Document Receive";
          SalesHeader.Modify(true);
          Print := "Sales Document Print";
          //-NPR5.52 [352473]
          Send := "Sales Document Send";
          Pdf2Nav := "Sales Document Pdf2Nav";
          //+NPR5.52 [352473]

          "Sales Document Invoice" := false;
          "Sales Document Ship" := false;
          "Sales Document Receive" := false;
          "Sales Document Print" := false;
          //-NPR5.52 [352473]
          "Sales Document Send" := false;
          "Sales Document Pdf2Nav" := false;
          //+NPR5.52 [352473]
          Modify(true);

          SalesPost.Run(SalesHeader);

          if SalesHeader.Invoice then begin
            case SalesHeader."Document Type" of
              SalesHeader."Document Type"::Invoice:
                begin
                  "Buffer Document Type" := "Buffer Document Type"::Faktura;
                  if SalesHeader."Last Posting No." <> '' then
                    Validate("Buffer Document No.", SalesHeader."Last Posting No.")
                  else
                    Validate("Buffer Document No.", SalesHeader."No.");
                  "Posted Sales Document Type" := "Posted Sales Document Type"::INVOICE;
                  "Posted Sales Document No." := "Buffer Document No.";
                end;
              SalesHeader."Document Type"::Order:
                begin
                  "Buffer Document Type" := "Buffer Document Type"::Faktura;
                  Validate("Buffer Document No.", SalesHeader."Last Posting No.");
                  "Posted Sales Document Type" := "Posted Sales Document Type"::INVOICE;
                  "Posted Sales Document No." := "Buffer Document No.";
                end;
              SalesHeader."Document Type"::"Credit Memo":
                begin
                  "Buffer Document Type" := "Buffer Document Type"::Kreditnota;
                  if SalesHeader."Last Posting No." <> '' then
                    Validate("Buffer Document No.", SalesHeader."Last Posting No.")
                  else
                    Validate("Buffer Document No.", SalesHeader."No.");
                  "Posted Sales Document Type" := "Posted Sales Document Type"::CREDIT_MEMO;
                  "Posted Sales Document No." := "Buffer Document No.";
                end;
              SalesHeader."Document Type"::"Return Order" :
                begin
                  "Buffer Document Type" := "Buffer Document Type"::Kreditnota;
                  Validate("Buffer Document No.", SalesHeader."Last Posting No.");
                  "Posted Sales Document Type" := "Posted Sales Document Type"::CREDIT_MEMO;
                  "Posted Sales Document No." := "Buffer Document No.";
                end;
            end;
          end;

          if SalesHeader.Ship then begin
            "Delivered Sales Document Type" := "Delivered Sales Document Type"::SHIPMENT;
            "Delivered Sales Document No." := SalesHeader."Last Shipping No.";
          end;
          if SalesHeader.Receive then begin
            "Delivered Sales Document Type" := "Delivered Sales Document Type"::RETURN_RECEIPT;
            "Delivered Sales Document No." := SalesHeader."Last Return Receipt No.";
          end;

          Modify(true);
          Commit;

          //-NPR5.52 [352473]
          if Print then begin
            POSSalesDocumentOutputMgt.PrintDocument(SalesHeader, 0);
          end;

          if Send then begin
            POSSalesDocumentOutputMgt.SendDocument(SalesHeader, 0);
          end;

          if Pdf2Nav then begin
            POSSalesDocumentOutputMgt.SendPdf2NavDocument(SalesHeader, 0);
          end;
          //+NPR5.52 [352473]
        end;
        //+NPR5.50 [300557]
    end;

    procedure CreatePrepaymentLine(var POSSession: Codeunit "POS Session";var SalesHeader: Record "Sales Header";PrepaymentValue: Decimal;Print: Boolean;Send: Boolean;Pdf2Nav: Boolean;SyncPosting: Boolean;ValueIsAmount: Boolean)
    var
        PrepaymentAmount: Decimal;
        POSSale: Codeunit "POS Sale";
        POSSaleLine: Codeunit "POS Sale Line";
        SalePOS: Record "Sale POS";
        SaleLinePOS: Record "Sale Line POS";
        POSPrepaymentMgt: Codeunit "POS Prepayment Mgt.";
    begin
        //-NPR5.52 [352473]
        // //-NPR5.51
        // IF NOT PayByAmount THEN
        // //+NPR5.51
        //  IF (PrepaymentVal <= 0) OR (PrepaymentVal > 100) THEN
        //      EXIT;
        //
        // //-NPR5.51
        // // PrepaymentAmount := ApplyPrepaymentPercentageToAllLines(SalesHeader, PrepaymentPrc, FALSE);
        // PrepaymentAmount := ApplyPrepaymentValueToAllLines(SalesHeader,PrepaymentVal,FALSE,PayByAmount);
        // //+NPR5.51

        if ValueIsAmount then begin
          POSPrepaymentMgt.SetPrepaymentAmountToPayInclVAT(SalesHeader, true, PrepaymentValue);
          PrepaymentAmount := PrepaymentValue;
        end else begin
          PrepaymentAmount := POSPrepaymentMgt.SetPrepaymentPercentageToPay(SalesHeader, true, PrepaymentValue);
        end;
        //+NPR5.52 [352473]

        if PrepaymentAmount = 0 then
          exit;

        POSSession.GetSale(POSSale);
        POSSession.GetSaleLine(POSSaleLine);
        POSSale.GetCurrentSale(SalePOS);

        if SalePOS."Customer No." <> '' then begin
          SalePOS.TestField("Customer Type", SalePOS."Customer Type"::Ord);
          SalePOS.TestField("Customer No.", SalesHeader."Bill-to Customer No.");
        end else begin
          SalePOS."Customer Type" := SalePOS."Customer Type"::Ord;
          SalePOS.Validate("Customer No.", SalesHeader."Bill-to Customer No.");
          SalePOS.Modify(true);
          POSSale.RefreshCurrent();
        end;

        POSSaleLine.GetNewSaleLine(SaleLinePOS);
        SaleLinePOS."Sale Type" := SaleLinePOS."Sale Type"::Deposit;
        SaleLinePOS.Type := SaleLinePOS.Type::Customer;
        SaleLinePOS.Validate(Quantity, 1);
        SaleLinePOS.Validate("No.", SalesHeader."Bill-to Customer No.");
        SaleLinePOS."Sales Document Type" := SalesHeader."Document Type";
        SaleLinePOS."Sales Document No." := SalesHeader."No.";
        SaleLinePOS."Sales Document Prepayment" := true;
        //-NPR5.51
        //SaleLinePOS."Sales Doc. Prepayment %" := PrepaymentPrc;
        SaleLinePOS."Sales Doc. Prepayment Value" := PrepaymentValue;
        //+NPR5.51
        //-NPR5.52 [352473]
        SaleLinePOS."Sales Doc. Prepay Is Percent" := not ValueIsAmount;
        //+NPR5.52 [352473]
        SaleLinePOS."Sales Document Print" := Print;
        //-NPR5.52 [352473]
        SaleLinePOS."Sales Document Send" := Send;
        SaleLinePOS."Sales Document Pdf2Nav" := Pdf2Nav;
        //+NPR5.52 [352473]
        SaleLinePOS."Sales Document Sync. Posting" := SyncPosting;
        SaleLinePOS.Validate("Unit Price", PrepaymentAmount);
        SaleLinePOS.Description := StrSubstNo(PREPAYMENT, SalesHeader."Document Type", SalesHeader."No.");
        SaleLinePOS.UpdateAmounts(SaleLinePOS);
        POSSaleLine.InsertLineRaw(SaleLinePOS, false);
    end;

    procedure CreatePrepaymentRefundLine(var POSSession: Codeunit "POS Session";var SalesHeader: Record "Sales Header";Print: Boolean;Send: Boolean;Pdf2Nav: Boolean;SyncPosting: Boolean;DeleteDocumentAfter: Boolean)
    var
        PrepaymentRefundAmount: Decimal;
        POSSale: Codeunit "POS Sale";
        POSSaleLine: Codeunit "POS Sale Line";
        SalePOS: Record "Sale POS";
        SaleLinePOS: Record "Sale Line POS";
        POSPrepaymentMgt: Codeunit "POS Prepayment Mgt.";
    begin
        //-NPR5.50 [300557]
        POSSession.GetSale(POSSale);
        POSSession.GetSaleLine(POSSaleLine);
        POSSale.GetCurrentSale(SalePOS);

        //-NPR5.52 [352473]
        //PrepaymentRefundAmount := GetTotalPrepaidAmountNotDeducted(SalesHeader);
        PrepaymentRefundAmount := POSPrepaymentMgt.GetPrepaymentAmountToDeductInclVAT(SalesHeader);
        //+NPR5.52 [352473]

        POSSaleLine.GetNewSaleLine(SaleLinePOS);
        SaleLinePOS."Sale Type" := SaleLinePOS."Sale Type"::Deposit;
        SaleLinePOS.Type := SaleLinePOS.Type::Customer;
        SaleLinePOS.Validate(Quantity, 1);
        SaleLinePOS.Validate("No.", SalesHeader."Bill-to Customer No.");
        SaleLinePOS."Sales Document Type" := SalesHeader."Document Type";
        SaleLinePOS."Sales Document No." := SalesHeader."No.";
        SaleLinePOS."Sales Document Prepay. Refund" := true;
        SaleLinePOS."Sales Document Print" := Print;
        //-NPR5.52 [352473]
        SaleLinePOS."Sales Document Send" := Send;
        SaleLinePOS."Sales Document Pdf2Nav" := Pdf2Nav;
        //+NPR5.52 [352473]
        SaleLinePOS."Sales Document Sync. Posting" := SyncPosting;
        SaleLinePOS."Sales Document Delete" := DeleteDocumentAfter;
        SaleLinePOS.Validate("Unit Price", -PrepaymentRefundAmount);
        SaleLinePOS.Description := StrSubstNo(PREPAYMENT_REFUND, SalesHeader."Document Type", SalesHeader."No.");
        SaleLinePOS.UpdateAmounts(SaleLinePOS);
        POSSaleLine.InsertLineRaw(SaleLinePOS, false);
        //+NPR5.50 [300557]
    end;

    procedure HandleLinkedDocuments(POSSession: Codeunit "POS Session")
    var
        POSSale: Codeunit "POS Sale";
        POSSaleLine: Codeunit "POS Sale Line";
        SalePOS: Record "Sale POS";
        SaleLinePOS: Record "Sale Line POS";
        SalesHeader: Record "Sales Header";
    begin
        //-NPR5.50 [300557]
        //Error in this subscriber will block end-of-sale, but if we have several associated sales docs, some of them might post with commit before an error.

        POSSession.GetSale(POSSale);
        POSSession.GetSaleLine(POSSaleLine);
        POSSale.GetCurrentSale(SalePOS);

        with SaleLinePOS do begin
          SetRange("Register No.", SalePOS."Register No.");
          SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");
          SetRange("Sales Document Sync. Posting", true);
          SetFilter("Sales Document No.", '<>%1', '');
          if not FindSet then
            exit;

          repeat
            if SalesHeader.Get("Sales Document Type","Sales Document No.") then begin
              case true of
                "Sales Document Prepayment" :
                  PostPrepaymentBeforePOSSaleEnd(SalesHeader, SaleLinePOS);

                "Sales Document Prepay. Refund" :
                  PostPrepaymentRefundBeforePOSSaleEnd(SalesHeader, SaleLinePOS);

                "Sales Document Ship",
                "Sales Document Receive",
                "Sales Document Invoice" :
                  PostDocumentBeforePOSSaleEnd(SalesHeader, SaleLinePOS);
              end;
            end;
          until Next = 0;

          POSSaleLine.RefreshCurrent();
        end;
        //+NPR5.50 [300557]
    end;

    local procedure OpenSalesDocCardAndSyncChangesBackToPOSSale(var SalesHeader: Record "Sales Header";var SalePOS: Record "Sale POS")
    var
        SalesHeader2: Record "Sales Header";
        ApplySalespersontoDocument: Codeunit "Apply Salesperson to Document";
    begin
        //-NPR5.53 [377510]
        SalesHeader2 := SalesHeader;
        SalesHeader2.SetRecFilter;

        ApplySalespersontoDocument.SetCode(SalePOS."Salesperson Code");
        BindSubscription(ApplySalespersontoDocument);
        PAGE.RunModal(SalesHeader.GetCardpageID(), SalesHeader2);
        UnbindSubscription(ApplySalespersontoDocument);

        if not SalesHeader.Get(SalesHeader."Document Type", SalesHeader."No.") then
          Error(ERR_DOC_MISSING, SalesHeader."Document Type", SalesHeader."No."); //If user deleted/posted etc.

        Commit;
        UpdateActiveSaleWithDocumentChanges(SalesHeader, SalePOS);
        //+NPR5.53 [377510]
    end;

    local procedure UpdateActiveSaleWithDocumentChanges(SalesHeader: Record "Sales Header";var SalePOS: Record "Sale POS")
    var
        RetailSalesDocImpMgt: Codeunit "Retail Sales Doc. Imp. Mgt.";
    begin
        //-NPR5.53 [377510]
        SalePOS."Sales Document Type" := SalesHeader."Document Type";
        SalePOS."Sales Document No." := SalesHeader."No.";
        SalePOS.Parameters := 'IMPORT_DOCUMENT_SYNC';

        if not RetailSalesDocImpMgt.Run(SalePOS) then
          Error(ERR_ORDER_SALE_SYNC, SalesHeader."Document Type", SalesHeader."No.", GetLastErrorText);

        SalePOS.Get(SalePOS."Register No.", SalePOS."Sales Ticket No.");
        //+NPR5.53 [377510]
    end;

    local procedure "--- Audit Roll Transfer"()
    begin
    end;

    procedure CreateDocumentPostingAudit(var SalesHeader: Record "Sales Header";var SalePOS: Record "Sale POS";Posted: Boolean)
    var
        Text10600062: Label 'Debit to %1 on invoice %2';
        Text10600063: Label 'Delivery to %1 on delivery %2';
        Text10600064: Label 'Credit to %1 on credit note %2';
        Text10600065: Label 'Transferred to %1 %2';
        TxtReturSalg: Label 'Delivery to %1 on return order %2';
        AuditRoll: Record "Audit Roll";
        RetailSetup: Record "Retail Setup";
    begin
        RetailSetup.Get;
        if RetailSetup."Create POS Entries Only" then
          exit;
        AuditRoll.SetCurrentKey("Register No.","Sales Ticket No.","Sale Date" );
        AuditRoll.SetRange("Register No.",SalePOS."Register No.");
        AuditRoll.SetRange("Sales Ticket No.",SalePOS."Sales Ticket No.");
        AuditRoll.SetRange("Sale Date",Today);

        AuditRoll."Register No."           := SalePOS."Register No.";
        AuditRoll."Sales Ticket No."       := SalePOS."Sales Ticket No.";
        AuditRoll."Sale Type"              := AuditRoll."Sale Type"::"Debit Sale";
        AuditRoll."Line No."               := 1;
        AuditRoll."Sale Date"              := Today;

        AuditRoll.Type                          := AuditRoll.Type::Comment;
        case SalesHeader."Document Type" of
          SalesHeader."Document Type"::Invoice :
            AuditRoll."Document Type" := AuditRoll."Document Type"::Invoice;
          SalesHeader."Document Type"::Order :
            AuditRoll."Document Type" := AuditRoll."Document Type"::Order;
          SalesHeader."Document Type"::"Credit Memo" :
            AuditRoll."Document Type" := AuditRoll."Document Type"::"Credit Memo";
          SalesHeader."Document Type"::"Return Order" :
            AuditRoll."Document Type" := AuditRoll."Document Type"::"Return Order";
        end;
        AuditRoll."Posted Doc. No."             := SalesHeader."Last Posting No.";
        AuditRoll.Lokationskode                 := SalePOS."Location Code";
        AuditRoll."Shortcut Dimension 1 Code"   := SalePOS."Shortcut Dimension 1 Code";
        AuditRoll."Shortcut Dimension 2 Code"   := SalePOS."Shortcut Dimension 2 Code";
        AuditRoll."Dimension Set ID" := SalePOS."Dimension Set ID";

        AuditRoll."Salesperson Code"            := SalePOS."Salesperson Code";
        AuditRoll.Posted                        := true;
        AuditRoll."Closing Time"                := Time;
        AuditRoll."Retail Document Type"        := SalePOS."Retail Document Type";
        AuditRoll."Retail Document No."         := SalePOS."Retail Document No.";
        AuditRoll.Reference                     := SalePOS.Reference;
        AuditRoll.Posted             := true;

        AuditRoll."Customer Type"    := SalePOS."Customer Type";
        AuditRoll."Customer No."     := SalePOS."Customer No.";
        AuditRoll."Salesperson Code" := SalesHeader."Salesperson Code";

        if Posted then case SalesHeader."Document Type" of
          SalesHeader."Document Type"::Invoice:
            begin
              if SalesHeader."Last Posting No." <> '' then
                AuditRoll."Document No."  := SalesHeader."Last Posting No."
              else
                AuditRoll."Document No."  := SalesHeader."No.";
              AuditRoll.Description       := StrSubstNo(Text10600062,SalePOS."Customer No.",AuditRoll."Document No.");
            end;
          SalesHeader."Document Type"::Order:
            begin
              AuditRoll."Document No."    := SalesHeader."Last Shipping No.";
              AuditRoll.Description       := StrSubstNo(Text10600063,SalePOS."Customer No.",AuditRoll."Document No.");
            end;
          SalesHeader."Document Type"::"Credit Memo":
            begin
              if SalesHeader."Last Posting No." <> '' then
                AuditRoll."Document No."  := SalesHeader."Last Posting No."
              else
                AuditRoll."Document No."  := SalesHeader."No.";
              AuditRoll.Description       := StrSubstNo(Text10600064,SalePOS."Customer No.",AuditRoll."Document No.");
            end;
          SalesHeader."Document Type"::"Return Order" :
            begin
              AuditRoll."Document No."    := SalesHeader."Last Return Receipt No.";
              AuditRoll.Description       := StrSubstNo(TxtReturSalg,SalePOS."Customer No.",AuditRoll."Document No.");
            end;
        end else
          AuditRoll.Description := StrSubstNo(Text10600065,SalesHeader."Document Type",SalesHeader."No.");

        AuditRoll.Insert(true);

        TransferLinesToAuditRoll(SalePOS,AuditRoll."Document No.");
    end;

    local procedure TransferLinesToAuditRoll(var Sale: Record "Sale POS";DocumentNo: Code[20])
    var
        SaleLinePOS: Record "Sale Line POS";
        GiftVoucher: Record "Gift Voucher";
        PaymentTypePOS: Record "Payment Type POS";
        AuditRoll: Record "Audit Roll";
        TicketManagement: Codeunit "TM Ticket Management";
        DimMgt: Codeunit NPRDimensionManagement;
        Register: Record Register;
        RetailFormCode: Codeunit "Retail Form Code";
    begin
        Register.Get( Sale."Register No." );
        SaleLinePOS.SetCurrentKey(SaleLinePOS."Register No.",SaleLinePOS."Sales Ticket No.",SaleLinePOS."Line No.");

        SaleLinePOS.SetRange( "Register No.", Sale."Register No." );
        SaleLinePOS.SetRange( "Sales Ticket No.", Sale."Sales Ticket No." );
        SaleLinePOS.SetFilter( "Sale Type", '=%1|=%2|=%3', SaleLinePOS."Sale Type"::Sale, SaleLinePOS."Sale Type"::Comment, SaleLinePOS."Sale Type"::"Debit Sale" );

        AuditRoll.SetRange( "Register No.", Sale."Register No." );
        AuditRoll.SetRange( "Sales Ticket No.", Sale."Sales Ticket No." );
        if AuditRoll.FindLast then;

        if SaleLinePOS.FindSet then repeat
          AuditRoll.Init;
          AuditRoll."Register No." := SaleLinePOS."Register No.";
          AuditRoll."Sales Ticket No." := SaleLinePOS."Sales Ticket No.";

          AuditRoll."Line No." := SaleLinePOS."Line No.";

          AuditRoll.TransferFromSaleLinePOS( SaleLinePOS, Sale."Start Time", DocumentNo, AuditRoll."Document Type", AuditRoll."Allocated No." );
          AuditRoll."Sale Type" := AuditRoll."Sale Type"::"Debit Sale";
          case SaleLinePOS.Type of
            SaleLinePOS.Type::Item :
              AuditRoll.Type := AuditRoll.Type::Item;
            SaleLinePOS.Type::Customer :
              AuditRoll.Type := AuditRoll.Type::Customer;
            SaleLinePOS.Type::"G/L Entry" :
              AuditRoll.Type := AuditRoll.Type::"G/L";
          end;
          AuditRoll."Salesperson Code" := Sale."Salesperson Code";
          AuditRoll.Posted := not AuditRoll.Offline;
          AuditRoll."Customer No." := Sale."Customer No.";
          AuditRoll."Retail Document Type" := Sale."Retail Document Type";
          AuditRoll."Retail Document No." := Sale."Retail Document No.";
          if AuditRoll.Offline then
            AuditRoll.Posted := false;

          if (AuditRoll.Type = AuditRoll.Type::Item) then
            TicketManagement.IssueTicketsFromAuditRoll(AuditRoll);

          //-NPR5.51 [358582]
          RetailFormCode.OnBeforeAuditRoleLineInsertEvent(Sale,SaleLinePOS,AuditRoll);
          //+NPR5.51 [358582]

          AuditRoll.Insert(true);
          DimMgt.CopySaleLineDimToAuditDim( SaleLinePOS, AuditRoll );
        until SaleLinePOS.Next = 0;

        SaleLinePOS.SetRange( "Sale Type", SaleLinePOS."Sale Type"::Deposit );
        if SaleLinePOS.FindSet then repeat
          PaymentTypePOS.SetRange("Processing Type", PaymentTypePOS."Processing Type"::"Gift Voucher");
          PaymentTypePOS.SetRange("G/L Account No.",SaleLinePOS."No.");
          if PaymentTypePOS.Find('-') then begin
            AuditRoll.Init;
            AuditRoll."Register No." := SaleLinePOS."Register No.";
            AuditRoll."Sales Ticket No." := SaleLinePOS."Sales Ticket No.";
            AuditRoll."Line No." := SaleLinePOS."Line No.";

            AuditRoll.TransferFromSaleLinePOS( SaleLinePOS, Sale."Start Time", DocumentNo, AuditRoll."Document Type", AuditRoll."Allocated No." );

            if AuditRoll."Gift voucher ref." <> '' then begin
              GiftVoucher.Get( SaleLinePOS."Gift Voucher Ref." );
              GiftVoucher.CreateFromAuditRoll( AuditRoll );
              GiftVoucher.Modify;
            end;

            AuditRoll."Sale Type" := AuditRoll."Sale Type"::"Debit Sale";
            case SaleLinePOS.Type of
              SaleLinePOS.Type::Customer :
                AuditRoll.Type := AuditRoll.Type::Customer;
              SaleLinePOS.Type::"G/L Entry" :
                AuditRoll.Type := AuditRoll.Type::"G/L";
            end;

            AuditRoll."Salesperson Code" := Sale."Salesperson Code";
            AuditRoll.Posted := not AuditRoll.Offline;
            AuditRoll."Customer No." := Sale."Customer No.";
            AuditRoll."Retail Document Type" := Sale."Retail Document Type";
            AuditRoll."Retail Document No." := Sale."Retail Document No.";
            if AuditRoll.Offline then
              AuditRoll.Posted := false;

            //-NPR5.51 [358582]
            RetailFormCode.OnBeforeAuditRoleLineInsertEvent(Sale,SaleLinePOS,AuditRoll);
            //+NPR5.51 [358582]

            AuditRoll.Insert(true);
          end;
          DimMgt.CopySaleLineDimToAuditDim( SaleLinePOS, AuditRoll );
        until SaleLinePOS.Next = 0;

        SaleLinePOS.SetRange( "Sale Type", SaleLinePOS."Sale Type"::"Out payment" );
        if SaleLinePOS.FindSet then repeat
          if SaleLinePOS."No." = Register."Gift Voucher Discount Account" then begin
            AuditRoll.Init;
            AuditRoll."Register No." := SaleLinePOS."Register No.";
            AuditRoll."Sales Ticket No." := SaleLinePOS."Sales Ticket No.";
            AuditRoll."Line No." := SaleLinePOS."Line No.";
            AuditRoll.TransferFromSaleLinePOS(SaleLinePOS,Sale."Start Time",DocumentNo, AuditRoll."Document Type", AuditRoll."Allocated No.");

            AuditRoll."Sale Type" := AuditRoll."Sale Type"::"Debit Sale";
            case SaleLinePOS.Type of
              SaleLinePOS.Type::Customer :
                AuditRoll.Type := AuditRoll.Type::Customer;
              SaleLinePOS.Type::"G/L Entry" :
                AuditRoll.Type := AuditRoll.Type::"G/L";
            end;

            AuditRoll."Unit Price" := -AuditRoll."Unit Price";
            AuditRoll.Amount := -AuditRoll.Amount;
            AuditRoll."Amount Including VAT" := -AuditRoll."Amount Including VAT";
            AuditRoll."Salesperson Code" := Sale."Salesperson Code";
            AuditRoll.Posted := not AuditRoll.Offline;
            AuditRoll."Customer No." := Sale."Customer No.";
            AuditRoll."Retail Document Type" := Sale."Retail Document Type";
            AuditRoll."Retail Document No." := Sale."Retail Document No.";
            if AuditRoll.Offline then
              AuditRoll.Posted := false;

            //-NPR5.51 [358582]
            RetailFormCode.OnBeforeAuditRoleLineInsertEvent(Sale,SaleLinePOS,AuditRoll);
            //+NPR5.51 [358582]

            AuditRoll.Insert(true);
          end;
          DimMgt.CopySaleLineDimToAuditDim( SaleLinePOS, AuditRoll );
        until SaleLinePOS.Next = 0;
    end;

    procedure "--- Setup Functionality"()
    begin
    end;

    local procedure GetSetupValues(var SalesHeader: Record "Sales Header";Balance: Decimal)
    var
        RetailSetup: Record "Retail Setup";
    begin
        if not SkipDefaultValues then begin
          RetailSetup.Get;
        //-NPR5.40 [304639]
          RetailPrint := RetailSetup."Retail Debitnote";
        //+NPR5.40 [304639]
        //-NPR5.40 [302617]
        //  Print := RetailSetup."Sale Doc. Print On Post";
          SendPostedPdf2Nav := RetailSetup."Sale Doc. Print On Post";
        //-NPR5.40 [302617]
          DocumentType := SalesHeader."Document Type";
          WriteInAuditRoll := true;

          // Decide document type if not fetched from sales module
          if SalesHeader."No." = '' then begin
            if Balance >= 0 then begin
              case RetailSetup."Sale Doc. Type On Post. Pstv." of
                RetailSetup."Sale Doc. Type On Post. Pstv."::Order :
                  DocumentType := SalesHeader."Document Type"::Order;
                RetailSetup."Sale Doc. Type On Post. Pstv."::Invoice :
                  DocumentType := SalesHeader."Document Type"::Invoice;
              end;
            end else begin
              case RetailSetup."Sale Doc. Type On Post. Negt." of
                RetailSetup."Sale Doc. Type On Post. Negt."::"Return Order" :
                  DocumentType := SalesHeader."Document Type"::"Return Order";
                RetailSetup."Sale Doc. Type On Post. Negt."::"Credit Memo" :
                  DocumentType := SalesHeader."Document Type"::"Credit Memo";
              end;
            end;
          end;

          case DocumentType of
            DocumentType::Order :
              begin
                DocumentType := SalesHeader."Document Type"::Order;
                Ask  := RetailSetup."Sale Doc. Post. On Order" = RetailSetup."Sale Doc. Post. On Order"::Ask;
                if not Ask then begin
                  SalesHeader.Ship    := RetailSetup."Sale Doc. Post. On Order"
                                         in [RetailSetup."Sale Doc. Post. On Order"::Ship,
                                             RetailSetup."Sale Doc. Post. On Order"::"Ship and Invoice"];
                  SalesHeader.Invoice := RetailSetup."Sale Doc. Post. On Order"
                                         in [RetailSetup."Sale Doc. Post. On Order"::"Ship and Invoice"];

                  Invoice := SalesHeader.Invoice;
                  Ship    := SalesHeader.Ship;

                end;
              end;
            DocumentType::Invoice :
              begin
                case RetailSetup."Sale Doc. Post. On Invoice" of
                  RetailSetup."Sale Doc. Post. On Invoice"::Yes :
                  begin
                    Invoice := RetailSetup."Sale Doc. Post. On Invoice" = RetailSetup."Sale Doc. Post. On Invoice"::Yes;
                    Ship    := RetailSetup."Sale Doc. Post. On Invoice" = RetailSetup."Sale Doc. Post. On Invoice"::Yes;
                  end;
                  RetailSetup."Sale Doc. Post. On Invoice"::Ask :
                  begin
                    Invoice := Confirm(Text000006,true);
                    Ship    := SalesHeader.Invoice;
                  end;
                end;
              end;
            DocumentType::"Return Order" :
              begin
                DocumentType := SalesHeader."Document Type"::"Return Order";
                Ask := RetailSetup."Sale Doc. Post. On Ret. Order" = RetailSetup."Sale Doc. Post. On Ret. Order"::Ask;
                if not Ask then begin
                  Receive := RetailSetup."Sale Doc. Post. On Ret. Order"
                             in [RetailSetup."Sale Doc. Post. On Ret. Order"::Receive,
                                 RetailSetup."Sale Doc. Post. On Ret. Order"::"Receive and Invoice"];
                  Invoice := RetailSetup."Sale Doc. Post. On Ret. Order"
                             in [RetailSetup."Sale Doc. Post. On Ret. Order"::"Receive and Invoice"]
                end;
              end;
            DocumentType::"Credit Memo" :
              begin
                DocumentType := SalesHeader."Document Type"::"Credit Memo";
                case RetailSetup."Sale Doc. Post. On Cred. Memo" of
                  RetailSetup."Sale Doc. Post. On Cred. Memo"::Yes :
                  begin
                    Invoice := true;
                    Receive := true;
                  end;
                  RetailSetup."Sale Doc. Post. On Cred. Memo"::Ask:
                  begin
                    Invoice := Confirm(Text000006,true);
                    Receive := SalesHeader.Invoice;
                  end;
                end;
              end;
          end;
          Post := Ship or Invoice or Receive or Ask;
        end else
          Post := Ship or Invoice or Receive or Ask;
    end;

    local procedure "---Finish Credit Sale Workflow"()
    begin
        //NPR5.53 [378985]
    end;

    [EventSubscriber(ObjectType::Table, 6150729, 'OnDiscoverPOSSalesWorkflows', '', true, false)]
    local procedure OnDiscoverPOSWorkflows(var Sender: Record "POS Sales Workflow")
    begin
        //-NPR5.53 [378985]
        Sender.DiscoverPOSSalesWorkflow(OnFinishCreditSaleCode(),OnFinishCreditSaleDescription,CurrCodeunitId(),'OnFinishCreditSale');
        //+NPR5.53 [378985]
    end;

    local procedure OnFinishCreditSaleCode(): Code[20]
    begin
        //-NPR5.53 [378985]
        exit('FINISH_CREDIT_SALE');
        //+NPR5.53 [378985]
    end;

    local procedure CurrCodeunitId(): Integer
    begin
        //-NPR5.53 [378985]
        exit(CODEUNIT::"Retail Sales Doc. Mgt.");
        //+NPR5.53 [378985]
    end;

    local procedure InvokeOnFinishCreditSaleWorkflow(SalePOS: Record "Sale POS")
    var
        POSUnit: Record "POS Unit";
        POSSalesWorkflowSetEntry: Record "POS Sales Workflow Set Entry";
        POSSalesWorkflowStep: Record "POS Sales Workflow Step";
    begin
        //-NPR5.53 [378985]
        POSSalesWorkflowStep.SetCurrentKey("Sequence No.");
        if POSUnit.Get(SalePOS."Register No.") and (POSUnit."POS Sales Workflow Set" <> '') and
           POSSalesWorkflowSetEntry.Get(POSUnit."POS Sales Workflow Set",OnFinishCreditSaleCode())
        then
          POSSalesWorkflowStep.SetRange("Set Code",POSSalesWorkflowSetEntry."Set Code")
        else
          POSSalesWorkflowStep.SetRange("Set Code",'');
        POSSalesWorkflowStep.SetRange("Workflow Code",OnFinishCreditSaleCode());
        POSSalesWorkflowStep.SetRange(Enabled,true);
        if not POSSalesWorkflowStep.FindSet then
          exit;

        repeat
          asserterror begin
            OnFinishCreditSale(POSSalesWorkflowStep,SalePOS);
            Commit;
            Error('');
          end;
        until POSSalesWorkflowStep.Next = 0;
        //+NPR5.53 [378985]
    end;

    local procedure "--- Event Publishers"()
    begin
    end;

    [IntegrationEvent(TRUE, TRUE)]
    local procedure OnAfterDebitSalePostEvent(SalePOS: Record "Sale POS";SalesHeader: Record "Sales Header";Posted: Boolean;WriteInAuditRoll: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnFinishCreditSale(POSSalesWorkflowStep: Record "POS Sales Workflow Step";SalePOS: Record "Sale POS")
    begin
        //NPR5.53 [378985]
    end;
}

