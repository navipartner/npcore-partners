codeunit 6014407 "NPR Sales Doc. Exp. Mgt."
{
    Permissions = TableData "NPR Audit Roll" = rimd;
    TableNo = "NPR Sale POS";

    trigger OnRun()
    begin
        case FunctionToRun of
            FunctionToRun::"Invoke OnFinishCreditSale Subsribers":
                begin
                    OnFinishCreditSale(POSSalesWorkflowStepGlobal, Rec);
                end;
            else
                case true of
                    StrPos(Parameters, 'SALESDOC_ASK_ON') > 0:
                        SetAsk(true);
                    StrPos(Parameters, 'SALESDOC_ASK_OFF') > 0:
                        SetAsk(false);
                    StrPos(Parameters, 'SALESDOC_PRINT_ON') > 0:
                        SetPrint(true);
                    StrPos(Parameters, 'SALESDOC_PRINT_OFF') > 0:
                        SetPrint(false);
                    StrPos(Parameters, 'SALESDOC_INVOICE_ON') > 0:
                        SetInvoice(true);
                    StrPos(Parameters, 'SALESDOC_INVOICE_OFF') > 0:
                        SetInvoice(false);
                    StrPos(Parameters, 'SALESDOC_POST_ON') > 0:
                        SetPost(true);
                    StrPos(Parameters, 'SALESDOC_POST_OFF') > 0:
                        SetPost(false);
                    StrPos(Parameters, 'SALESDOC_RECEIVE_ON') > 0:
                        SetReceive(true);
                    StrPos(Parameters, 'SALESDOC_RECEIVE_OFF') > 0:
                        SetReceive(false);
                    StrPos(Parameters, 'SALESDOC_SHIP_ON') > 0:
                        SetShip(true);
                    StrPos(Parameters, 'SALESDOC_SHIP_OFF') > 0:
                        SetShip(false);
                    StrPos(Parameters, 'SALESDOC_TYPE_ORD') > 0:
                        SetDocumentTypeOrder();
                    StrPos(Parameters, 'SALESDOC_TYPE_INV') > 0:
                        SetDocumentTypeInvoice();
                    StrPos(Parameters, 'SALESDOC_TYPE_RET') > 0:
                        SetDocumentTypeReturnOrder();
                    StrPos(Parameters, 'SALESDOC_TYPE_CRED') > 0:
                        SetDocumentTypeCreditMemo();
                    StrPos(Parameters, 'SALESDOC_WRITE_AUDIT') > 0:
                        SetWriteInAuditRoll(true);
                    StrPos(Parameters, 'SALESDOC_CR_MSG') > 0:
                        SetShowCreationMessage;
                    StrPos(Parameters, 'SALESDOC_RET_AMT') > 0:
                        SetReturnAmount(Parameters);
                    StrPos(Parameters, 'SALESDOC_OUTPUT_DOCUMENT') > 0:
                        SetOutput(Parameters);
                    StrPos(Parameters, 'SALESDOC_FINISH_SALE') > 0:
                        SetFinishSale;
                    StrPos(Parameters, 'SALESDOC_DEPOSIT_DLG') > 0:
                        SetShowDepositDialog;
                    StrPos(Parameters, 'SALESDOC_TEST_SALE') > 0:
                        TestSalePOS(Rec);
                    StrPos(Parameters, 'SALESDOC_PROCESS') > 0:
                        ProcessPOSSale(Rec);
                    StrPos(Parameters, 'SALESDOC_OPEN_PAGE') > 0:
                        OpenSalesDoc(Rec);
                    StrPos(Parameters, 'SALESDOC_ORD_TYPE') > 0:
                        SetOrderType(Parameters);
                    StrPos(Parameters, 'SALESDOC_TRSALESPERS') > 0:
                        SetTransferSalesPerson(true);
                    StrPos(Parameters, 'SALESDOC_TRPOSTINGSETUP') > 0:
                        SetTransferPostingsetup(true);
                    StrPos(Parameters, 'SALESDOC_TRDIMENSIONS') > 0:
                        SetTransferDimensions(true);
                    StrPos(Parameters, 'SALESDOC_TRPAYMENTMETHOD') > 0:
                        SetTransferPaymentMethod(true);
                    StrPos(Parameters, 'SALESDOC_TRSALESSETUP') > 0:
                        SetTransferTaxSetup(true);
                    StrPos(Parameters, 'SALESDOC_TRTRANSDATA') > 0:
                        SetTransferTransactionData(true);
                    else
                        Error('');
                end;
        end;
    end;

    procedure SetInvokeOnFinishCreditSaleSubsribers(POSSalesWorkflowStepIn: Record "NPR POS Sales Workflow Step")
    begin
        FunctionToRun := FunctionToRun::"Invoke OnFinishCreditSale Subsribers";
        POSSalesWorkflowStepGlobal := POSSalesWorkflowStepIn;
    end;

    var
        POSSalesWorkflowStepGlobal: Record "NPR POS Sales Workflow Step";
        FunctionToRun: Option Default,"Invoke OnFinishCreditSale Subsribers";
        Text000002: Label '%1 %2 %3 couldn''t be printed.';
        DocumentType: Enum "Sales Document Type";
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
        SendICOrderConf: Boolean;
        UseLocationFrom: Option Register,"POS Store","POS Sale","Specific Location";
        UseLocationCode: Code[10];

    procedure SetAsk(AskIn: Boolean)
    begin
        Ask := AskIn;
        SkipDefaultValues := true;
    end;

    procedure SetInvoice(InvoiceIn: Boolean)
    begin
        Invoice := InvoiceIn;
        SkipDefaultValues := true;
    end;

    procedure SetPrint(PrintIn: Boolean)
    begin
        Print := PrintIn;
        SkipDefaultValues := true;
    end;

    procedure SetPost(PostIn: Boolean)
    begin
        Post := PostIn;
        SkipDefaultValues := true;
    end;

    procedure SetReceive(ReceiveIn: Boolean)
    begin
        Receive := ReceiveIn;
        SkipDefaultValues := true;
    end;

    procedure SetShip(ShipIn: Boolean)
    begin
        Ship := ShipIn;
        SkipDefaultValues := true;
    end;

    procedure SetDocumentTypeOrder()
    begin
        DocumentType := DocumentType::Order;
        SkipDefaultValues := true;
    end;

    procedure SetDocumentTypeInvoice()
    begin
        DocumentType := DocumentType::Invoice;
        SkipDefaultValues := true;
    end;

    procedure SetDocumentTypeReturnOrder()
    begin
        DocumentType := DocumentType::"Return Order";
        SkipDefaultValues := true;
    end;

    procedure SetDocumentTypeCreditMemo()
    begin
        DocumentType := DocumentType::"Credit Memo";
        SkipDefaultValues := true;
    end;

    procedure SetDocumentTypeQuote()
    begin
        DocumentType := DocumentType::Quote;
        SkipDefaultValues := true;
    end;

    procedure SetWriteInAuditRoll(WriteInAuditRollIn: Boolean)
    begin
        WriteInAuditRoll := WriteInAuditRollIn;
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
        PercentageText := CopyStr(Parameter, StrLen('SALESDOC_RET_AMT?') + 1);
        if PercentageText <> '' then
            Evaluate(ReturnAmountPercentage, PercentageText)
        else
            ReturnAmountPercentage := 100;
    end;

    procedure SetOutput(Parameter: Text)
    var
        CodeunitText: Text;
    begin
        OutputDocument := true;
        CodeunitText := CopyStr(Parameter, StrLen('SALESDOC_OUTPUT_ON?') + 1);
        if CodeunitText <> '' then
            Evaluate(OutputCodeunit, CodeunitText)
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
        OrderTypeText := CopyStr(Parameter, StrLen('SALESDOC_ORD_TYPE?') + 1);
        if OrderTypeText <> '' then
            Evaluate(OrderType, OrderTypeText)
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
        TransferTaxSetup := TransferTaxSetupIn;
    end;

    procedure SetTransferTransactionData(TransferTransactionDataIn: Boolean)
    begin
        TransferTransactionData := TransferTransactionDataIn;
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
        OpenSalesDocAfterExport := OpenSalesDocAfterExportIn;
    end;

    procedure SetSendDocument(SendDocumentIn: Boolean)
    begin
        SendDocument := SendDocumentIn;
    end;

    procedure SetSendICOrderConf(Set: Boolean)
    begin
        SendICOrderConf := Set;
    end;

    procedure Reset()
    begin
        Ask := false;
        Invoice := false;
        Print := false;
        Post := false;
        Receive := false;
        Ship := false;
        DocumentType := DocumentType::Order;
        WriteInAuditRoll := false;
        SkipDefaultValues := false;
        ShowCreationMessage := false;
        ReturnAmount := false;
        ReturnAmountPercentage := 100;
        OutputDocument := false;
        OutputCodeunit := 0;
        FinishSale := false;
        ShowDepositDialog := false;
        OrderTypeSet := false;
        TransferSalesPerson := false;
        TransferPostingSetup := true;
        TransferDimensions := false;
        TransferPaymentMethod := false;
        TransferTaxSetup := false;
        AutoReserveSalesLines := false;
        SendPostedPdf2Nav := false;
        RetailPrint := false;
        OpenSalesDocAfterExport := false;
        Clear(CreatedSalesHeader);
        SendDocument := false;
        SendICOrderConf := false;
    end;

    procedure SetLocationSource(NewSource: Option Register,"POS Store","POS Sale","Specific Location"; NewLocationCode: Code[10])
    begin
        UseLocationFrom := NewSource;
        UseLocationCode := NewLocationCode;
    end;

    //--- Sales Document Functions ---

    procedure ProcessPOSSale(var SalePOS: Record "NPR Sale POS"): Boolean
    var
        AuditRoll: Record "NPR Audit Roll";
        GiftVoucher: Record "NPR Gift Voucher";
        SalesHeaderQoute: Record "Sales Header";
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        SaleLinePOS: Record "NPR Sale Line POS";
        RetailTableCode: Codeunit "NPR Retail Table Code";
        RetailSalesLineCode: Codeunit "NPR Retail Sales Line Code";
        SalesPost: Codeunit "Sales-Post";
        SalesPostYesNo: Codeunit "Sales-Post (Yes/No)";
        SalesPostAndPrint: Codeunit "Sales-Post + Print";
        SalesPostAndPdf2Nav: Codeunit "NPR Sales-Post and Pdf2Nav";
        TicketManagement: Codeunit "NPR TM Ticket Management";
        TicketAccessRsvMgt: Codeunit "NPR Ticket AccessReserv.Mgt";
        Posted: Boolean;
        NPRetailSetup: Record "NPR NP Retail Setup";
        POSCreateEntry: Codeunit "NPR POS Create Entry";
        Success: Boolean;
        POSSalesDocumentOutputMgt: Codeunit "NPR POS Sales Doc. Output Mgt.";
    begin
        NPRetailSetup.Get;

        if SalePOS."Sales Document No." <> '' then
            SalesHeader.Get(SalePOS."Sales Document Type", SalePOS."Sales Document No.");

        GetSetupValues(SalesHeader, RetailSalesLineCode.GetSalesAmountInclVAT(SalePOS));

        // Delete the Qoute if we are posting the sale
        if SalesHeaderQoute.Get(SalePOS."Sales Document Type", SalePOS."Sales Document No.") and
          (SalePOS."Sales Document Type" = SalesHeaderQoute."Document Type"::Quote) and Post then begin
            SalesHeader."No." := '';
            SalesHeaderQoute.Delete(true);
        end;

        if (SalePOS."Sales Document No." <> '') then begin
            SalesHeader.Ship := Ship;
            SalesHeader.Invoice := Invoice;
            SalesHeader.Receive := Receive;

            if SalesHeader."Salesperson Code" = '' then
                SalesHeader."Salesperson Code" := SalePOS."Salesperson Code";

            SalesLine.SetRange("Document Type", SalesHeader."Document Type");
            SalesLine.SetRange("Document No.", SalesHeader."No.");
            SalesLine.DeleteAll(true);
        end else
            CreateSalesHeader(SalePOS, SalesHeader);

        with SalePOS do begin
            Clear(SaleLinePOS);
            SaleLinePOS.SetRange("Register No.", "Register No.");
            SaleLinePOS.SetRange("Sales Ticket No.", "Sales Ticket No.");
            SaleLinePOS.ModifyAll(Silent, true);

            if SaleLinePOS.FindSet then begin
                CopySaleCommentLines(SalePOS, SalesHeader);
                CopySalesLines(SaleLinePOS, SalesHeader);
            end;

            if AutoReserveSalesLines then
                ReserveSalesLines(SalesHeader, true);

            Commit;

            if OpenSalesDocAfterExport then begin
                OpenSalesDocCardAndSyncChangesBackToPOSSale(SalesHeader, SalePOS);
                Commit;
            end;

            CreatedSalesHeader := SalesHeader;

            if Post then
                if Ask then
                    Posted := SalesPostYesNo.Run(SalesHeader)
                else
                    Posted := SalesPost.Run(SalesHeader);

            if Post and (not Posted) then
                Message(POSTING_ERROR, SalesHeader."Document Type", SalesHeader."No.", GetLastErrorText);

            if not (Post and Posted) and SendICOrderConf then
                SendICOrderConfirmation(SalesHeader);

            if WriteInAuditRoll then begin
                CreateDocumentPostingAudit(SalesHeader, SalePOS, Posted);
                if NPRetailSetup."Advanced POS Entries Activated" then begin
                    POSCreateEntry.CreatePOSEntryForCreatedSalesDocument(SalePOS, SalesHeader, Posted);
                end;
                SaleLinePOS.DeleteAll;
                if not ReturnAmount then
                    SalePOS.Delete;
            end else
                ConvertSaleLinePOSToComments(SalesHeader, SalePOS);

            Commit;

            if Post and Posted then begin
                if Print then begin
                    POSSalesDocumentOutputMgt.SetOnRunOperation(0, 0);
                    if not POSSalesDocumentOutputMgt.Run(SalesHeader) then
                        Message(PrintingErrorTxt, GetLastErrorText);
                end;

                if SendDocument then begin
                    POSSalesDocumentOutputMgt.SetOnRunOperation(1, 0);
                    if not POSSalesDocumentOutputMgt.Run(SalesHeader) then
                        Message(SendingErrorTxt, GetLastErrorText);
                end;

                if SendPostedPdf2Nav then begin
                    POSSalesDocumentOutputMgt.SetOnRunOperation(2, 0);
                    if not POSSalesDocumentOutputMgt.Run(SalesHeader) then
                        Message(Pdf2NavSendingErrorTxt, GetLastErrorText);
                end;
            end;

            if ShowCreationMessage then
                Message(Text000008, SalesHeader."Document Type", SalesHeader."No.");

            if ReturnAmount then
                CreatePrepaymentLineLegacy(SalePOS, SalesHeader, ReturnAmountPercentage);

            if Posted then begin
                SalePOS."Last Posting No." := SalesHeader."Last Posting No.";
                SalePOS."Last Shipping No." := SalesHeader."Last Shipping No."
            end;

            if OutputDocument and (OutputCodeunit <> 0) then
                CODEUNIT.Run(OutputCodeunit, SalesHeader);

            PrintGiftVoucher(SalePOS);

            TicketManagement.PrintTicketFromSalesTicketNo("Sales Ticket No.");

            TicketAccessRsvMgt.PrintRsvFromSalesTicketNo("Sales Ticket No.");

            Commit;

            PrintRetailReceipt(SalePOS);

            Commit();
            InvokeOnFinishCreditSaleWorkflow(SalePOS);

            OnAfterDebitSalePostEvent(SalePOS, SalesHeader, Posted, WriteInAuditRoll);

            Commit;
        end;
        exit(true);
    end;

    procedure CreateSalesHeader(var SalePOS: Record "NPR Sale POS"; var SalesHeader: Record "Sales Header")
    var
        Customer: Record Customer;
        GLSetup: Record "General Ledger Setup";
    begin
        SalesHeader.Init;
        SalesHeader."Document Type" := DocumentType;
        SalesHeader."Document Date" := WorkDate;
        SalesHeader."Posting Date" := Today;
        SalesHeader."NPR Document Time" := Time;
        SalesHeader."Salesperson Code" := SalePOS."Salesperson Code";
        SalesHeader."Sell-to Customer No." := SalePOS."Customer No.";
        SalesHeader.Insert(true);
        if SalePOS."Customer No." <> '' then begin
            SalesHeader.Validate("Sell-to Customer No.", SalePOS."Customer No.");
        end;

        SalesHeader.Validate("Sell-to Customer No.");
        SalesHeader.Validate("Currency Code", '');
        if Customer.Get(SalesHeader."Bill-to Customer No.") then begin
            GLSetup.Get;
            if Customer."Currency Code" = GLSetup."LCY Code" then
                SalesHeader.Validate("Currency Code", Customer."Currency Code");
        end;
        SalesHeader."Shortcut Dimension 1 Code" := SalePOS."Shortcut Dimension 1 Code";
        SalesHeader."Shortcut Dimension 2 Code" := SalePOS."Shortcut Dimension 2 Code";
        SalesHeader."Dimension Set ID" := SalePOS."Dimension Set ID";

        SalesHeader."Ship-to Name" := SalePOS.Name;
        SalesHeader."Ship-to Address" := SalePOS.Address;
        SalesHeader."Ship-to Address 2" := SalePOS."Address 2";
        SalesHeader."Ship-to City" := SalePOS.City;
        SalesHeader."Ship-to Post Code" := SalePOS."Post Code";
        SalesHeader."Ship-to Country/Region Code" := SalePOS."Country Code";

        SalesHeader.Modify(true);

        if SalePOS."Payment Terms Code" <> '' then
            SalesHeader.Validate("Payment Terms Code", SalePOS."Payment Terms Code");

        SalesHeader."Salesperson Code" := SalePOS."Salesperson Code";
        SalesHeader."NPR Sales Ticket No." := SalePOS."Sales Ticket No.";
        SalesHeader."Bill-to Contact" := SalePOS."Contact No.";
        if SalesHeader."Sell-to Contact" = '' then
            SalesHeader."Sell-to Contact" := SalePOS."Contact No.";
        SalesHeader."Your Reference" := SalePOS.Reference;
        SalesHeader."External Document No." := SalePOS.Reference;
        SalesHeader.Validate("Location Code", GetLocationCode(SalePOS));
        if Customer.Get(SalePOS."Customer No.") then
            SalesHeader."NPR Document Processing" := Customer."NPR Document Processing";
        SalesHeader.Ship := Ship;
        SalesHeader.Invoice := Invoice;
        SalesHeader.Receive := Receive;

        if OrderTypeSet then
            SalesHeader."NPR Order Type" := OrderType;

        SalesHeader.Validate("Prices Including VAT", SalePOS."Prices Including VAT");

        TransferInfoFromSalePOS(SalePOS, SalesHeader);

        SalesHeader.Modify;
    end;

    local procedure ConvertSaleLinePOSToComments(var SalesHeader: Record "Sales Header"; var SalePOS: Record "NPR Sale POS")
    var
        SaleLinePOS: Record "NPR Sale Line POS";
        TempSaleLinePOS: Record "NPR Sale Line POS" temporary;
        Text10600062: Label 'Debit to %1 on invoice %2';
        Text10600063: Label 'Delivery to %1 on delivery %2';
        Text10600064: Label 'Credit to %1 on credit note %2';
        Text10600065: Label 'Transferred to %1 %2';
        TxtReturSalg: Label 'Delivery to %1 on return order %2';
    begin
        SaleLinePOS.SetCurrentKey(SaleLinePOS."Register No.", SaleLinePOS."Sales Ticket No.", SaleLinePOS."Line No.");
        SaleLinePOS.SetRange("Register No.", SalePOS."Register No.");
        SaleLinePOS.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");
        SaleLinePOS.SetRange("Sale Type", SaleLinePOS."Sale Type"::Sale);

        if SaleLinePOS.FindSet then
            repeat
                TempSaleLinePOS.Init;
                TempSaleLinePOS := SaleLinePOS;
                TempSaleLinePOS.Insert;
            until SaleLinePOS.Next = 0;
        SaleLinePOS.DeleteAll;

        SaleLinePOS.Init;
        SaleLinePOS."Register No." := TempSaleLinePOS."Register No.";
        SaleLinePOS."Sales Ticket No." := TempSaleLinePOS."Sales Ticket No.";
        SaleLinePOS."Line No." := 1;
        SaleLinePOS."Sale Type" := SaleLinePOS."Sale Type"::Comment;
        SaleLinePOS.Type := SaleLinePOS.Type::Comment;
        SaleLinePOS.Date := TempSaleLinePOS.Date;
        if (SalesHeader."Last Posting No." <> '') or
           (SalesHeader."Last Shipping No." <> '') or
           (SalesHeader."Last Return Receipt No." <> '') then
            case SalesHeader."Document Type" of
                SalesHeader."Document Type"::Invoice:
                    SaleLinePOS.Description := StrSubstNo(Text10600062, SalePOS."Customer No.", SalesHeader."Last Posting No.") + ':';
                SalesHeader."Document Type"::Order:
                    SaleLinePOS.Description := StrSubstNo(Text10600063, SalePOS."Customer No.", SalesHeader."Last Shipping No.") + ':';
                SalesHeader."Document Type"::"Credit Memo":
                    SaleLinePOS.Description := StrSubstNo(Text10600064, SalePOS."Customer No.", SalesHeader."Last Posting No.") + ':';
                SalesHeader."Document Type"::"Return Order":
                    SaleLinePOS.Description := StrSubstNo(TxtReturSalg, SalePOS."Customer No.", SalesHeader."Last Return Receipt No.") + ':';
            end
        else
            SaleLinePOS.Description := StrSubstNo(Text10600065, SalesHeader."Document Type", SalesHeader."No.") + ':';
        SaleLinePOS.Validate(Quantity, 1);
        SaleLinePOS.Insert(true);

        TempSaleLinePOS.SetCurrentKey(TempSaleLinePOS."Register No.", TempSaleLinePOS."Sales Ticket No.", TempSaleLinePOS."Line No.");
        if TempSaleLinePOS.FindSet then
            repeat
                SaleLinePOS.Init;
                SaleLinePOS."Register No." := TempSaleLinePOS."Register No.";
                SaleLinePOS."Sales Ticket No." := TempSaleLinePOS."Sales Ticket No.";
                SaleLinePOS."Line No." := TempSaleLinePOS."Line No.";
                SaleLinePOS."Sale Type" := SaleLinePOS."Sale Type"::Comment;
                SaleLinePOS.Type := SaleLinePOS.Type::Comment;
                SaleLinePOS.Date := TempSaleLinePOS.Date;
                SaleLinePOS.Description := TempSaleLinePOS.Description;
                SaleLinePOS."Sales Document Type" := SalesHeader."Document Type";
                SaleLinePOS."Sales Document No." := SalesHeader."No.";
                SaleLinePOS.Validate(Quantity, TempSaleLinePOS.Quantity);
                SaleLinePOS.Validate("Unit Price", TempSaleLinePOS."Unit Price");
                SaleLinePOS.Insert(true);
            until TempSaleLinePOS.Next = 0;
    end;

    procedure CopySaleCommentLines(var SalePOS: Record "NPR Sale POS"; var SalesHeader: Record "Sales Header")
    var
        SalesCommentLine: Record "Sales Comment Line";
        RetailComment: Record "NPR Retail Comment";
    begin
        with SalePOS do begin
            RetailComment.SetRange("Table ID", DATABASE::"NPR Sale POS");
            RetailComment.SetRange("No.", "Register No.");
            RetailComment.SetRange("No. 2", "Sales Ticket No.");
            if RetailComment.FindSet then
                repeat
                    SalesCommentLine.Init;
                    SalesCommentLine."Document Type" := SalesHeader."Document Type";
                    SalesCommentLine."No." := SalesHeader."No.";
                    SalesCommentLine."Line No." := RetailComment."Line No.";
                    SalesCommentLine.Date := RetailComment.Date;
                    SalesCommentLine.Code := RetailComment.Code;
                    SalesCommentLine.Comment := RetailComment.Comment;
                    SalesCommentLine.Insert(true);
                until RetailComment.Next = 0;
        end;
    end;

    procedure CopySalesLines(var SaleLinePOS: Record "NPR Sale Line POS"; var SalesHeader: Record "Sales Header")
    var
        CreditVoucher: Record "NPR Credit Voucher";
        GiftVoucher: Record "NPR Gift Voucher";
        NpRvSalesLine: Record "NPR NpRv Sales Line";
        SalesLine: Record "Sales Line";
        ReservationEntry: Record "Reservation Entry";
        Item: Record Item;
        SerialNoInfo: Record "Serial No. Information";
        ItemTrackingCode: Record "Item Tracking Code";
        ItemTrackingSetup: Record "Item Tracking Setup";
        RetailFormCode: Codeunit "NPR Retail Form Code";
        ItemTrackingManagement: Codeunit "Item Tracking Management";
    begin
        if SaleLinePOS.FindSet then
            repeat
                SalesLine.Init;

                TestSaleLinePOS(SaleLinePOS);

                SalesLine."Document Type" := SalesHeader."Document Type";
                SalesLine."Document No." := SalesHeader."No.";

                case SaleLinePOS.Type of
                    SaleLinePOS.Type::"G/L Entry":
                        SalesLine.Type := SalesLine.Type::"G/L Account";
                    SaleLinePOS.Type::Comment:
                        SalesLine.Type := SalesLine.Type::" ";
                    else
                        SalesLine.Type := SalesLine.Type::Item;
                end;
                SalesLine."Line No." := SaleLinePOS."Line No.";
                SaleLinePOS.TransferToSalesLine(SalesLine);
                SalesLine."Line No." := SaleLinePOS."Line No.";
                SalesLine.Insert(true);
                if SalesLine.Type <> SalesLine.Type::" " then begin
                    if (SaleLinePOS."Gift Voucher Ref." <> '') and (SaleLinePOS.Quantity < 0) then
                        RetailFormCode.SetGiftVoucherStatus(SaleLinePOS."Gift Voucher Ref.", GiftVoucher.Status::Cancelled);

                    if (SaleLinePOS."Credit voucher ref." <> '') and (SaleLinePOS.Quantity < 0) then
                        RetailFormCode.SetCreditVoucherStatus(SaleLinePOS."Credit voucher ref.", CreditVoucher.Status::Cancelled);

                    if SalesHeader."Document Type" in
                      [SalesHeader."Document Type"::"Return Order", SalesHeader."Document Type"::"Credit Memo"] then
                        SalesLine.Validate(Quantity, -SaleLinePOS.Quantity)
                    else begin
                        SalesLine.Validate(Quantity, SaleLinePOS.Quantity);
                        if SaleLinePOS."Sale Type" = SaleLinePOS."Sale Type"::"Out payment" then
                            SalesLine.Validate(Quantity, -SaleLinePOS.Quantity);
                    end;

                    if SalesLine."Unit Price" <> SaleLinePOS."Unit Price" then begin
                        SalesLine."Line Discount %" := SaleLinePOS."Discount %";
                        SalesLine.Validate("Unit Price", SaleLinePOS."Unit Price");
                    end;
                    if SalesLine."Line Discount %" <> SaleLinePOS."Discount %" then
                        SalesLine.Validate("Line Discount %", SaleLinePOS."Discount %");

                    TransferInfoFromSaleLinePOS(SaleLinePOS, SalesLine);
                    SalesLine.Modify;
                end;
                if SaleLinePOS."Serial No." <> '' then begin
                    ReservationEntry.SetCurrentKey("Entry No.", Positive);
                    ReservationEntry.SetRange(Positive, false);
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
                    ReservationEntry."Source Subtype" := SalesLine."Document Type".AsInteger();
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
                    if Item."Item Tracking Code" <> '' then begin
                        ItemTrackingCode.Get(Item."Item Tracking Code");
                        ItemTrackingManagement.GetItemTrackingSetup(ItemTrackingCode, 1, false, ItemTrackingSetup);
                        if ItemTrackingSetup."Serial No. Required" then begin
                            if SaleLinePOS."Serial No." = '' then
                                Error(Text000013, SaleLinePOS."No.", SaleLinePOS.Description);
                        end;
                        if ItemTrackingSetup."Serial No. Info Required" then begin
                            SerialNoInfo.Get(SaleLinePOS."No.", SaleLinePOS."Variant Code", SaleLinePOS."Serial No.");
                            SerialNoInfo.TestField(Blocked, false);
                        end;
                    end else begin
                        if SerialNoInfo.Get(SaleLinePOS."No.", SaleLinePOS."Variant Code", SaleLinePOS."Serial No.") then
                            SerialNoInfo.TestField(Blocked, false);
                    end;
                end;
                NpRvSalesLine.SetRange("Document Source", NpRvSalesLine."Document Source"::POS);
                NpRvSalesLine.SetRange("Retail ID", SaleLinePOS."Retail ID");
                if NpRvSalesLine.FindSet then
                    repeat
                        NpRvSalesLine."Document Source" := NpRvSalesLine."Document Source"::"Sales Document";
                        NpRvSalesLine."Document Type" := SalesLine."Document Type";
                        NpRvSalesLine."Document No." := SalesLine."Document No.";
                        NpRvSalesLine."Document Line No." := SalesLine."Line No.";
                        NpRvSalesLine.Modify(true);
                    until NpRvSalesLine.Next = 0;
            until SaleLinePOS.Next = 0;
    end;

    procedure TestSaleLinePOS(var SaleLinePOS: Record "NPR Sale Line POS")
    begin
        if SaleLinePOS."Sale Type" = SaleLinePOS."Sale Type"::Payment then
            Error(Text000010);

        if SaleLinePOS."Sales Document No." <> '' then
            Error(Text000012);

        if (SaleLinePOS.Type = SaleLinePOS.Type::Customer) and
           (SaleLinePOS."Sale Type" = SaleLinePOS."Sale Type"::Deposit) then
            Error(Text000007);

        if SaleLinePOS."Buffer Document No." <> '' then
            Error(Text000007);

        if SaleLinePOS.Type = SaleLinePOS.Type::"Item Group" then
            Error(Text000003);
    end;

    procedure OpenSalesDoc(var SalePOS: Record "NPR Sale POS")
    var
        SaleLinePOS: Record "NPR Sale Line POS";
        SalesDocNo: Code[20];
        SalesHeader: Record "Sales Header";
        SalesOrder: Page "Sales Order";
        SalesCreditMemo: Page "Sales Credit Memo";
        BlanketSalesOrder: Page "Blanket Sales Order";
        SalesReturnOrder: Page "Sales Return Order";
        SalesQuote: Page "Sales Quote";
    begin
        SaleLinePOS.SetRange("Register No.", SalePOS."Register No.");
        SaleLinePOS.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");

        if SaleLinePOS.FindSet then
            repeat
                if SaleLinePOS."Sales Document No." <> '' then begin
                    SalesDocNo := SaleLinePOS."Sales Document No.";
                    DocumentType := SaleLinePOS."Sales Document Type";
                end;
            until (SaleLinePOS.Next = 0) or (SalesDocNo <> '');

        if SalesDocNo <> '' then begin
            SalesHeader.Get(DocumentType, SalesDocNo);

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

            if DocumentType = DocumentType::Quote then begin
                SalesQuote.SetRecord(SalesHeader);
                SalesQuote.RunModal;
            end;
        end;
    end;

    procedure TestSalePOS(var SalePOS: Record "NPR Sale POS")
    var
        SaleLinePOS: Record "NPR Sale Line POS";
    begin
        SaleLinePOS.SetRange("Register No.", SalePOS."Register No.");
        SaleLinePOS.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");

        if SaleLinePOS.FindSet then
            repeat
                TestSaleLinePOS(SaleLinePOS);
            until SaleLinePOS.Next = 0;
    end;

    local procedure TransferInfoFromSalePOS(var SalePOS: Record "NPR Sale POS"; var SalesHeader: Record "Sales Header")
    var
        PaymentTypePOS: Record "NPR Payment Type POS";
        SaleLinePOS: Record "NPR Sale Line POS";
    begin
        if TransferSalesPerson then begin
            if SalePOS."Salesperson Code" <> '' then
                SalesHeader.Validate("Salesperson Code", SalePOS."Salesperson Code");
        end;

        if TransferPostingSetup then begin
            if SalePOS."Gen. Bus. Posting Group" <> '' then
                SalesHeader.Validate("Gen. Bus. Posting Group", SalePOS."Gen. Bus. Posting Group");
            if SalePOS."VAT Bus. Posting Group" <> '' then
                SalesHeader.Validate("VAT Bus. Posting Group", SalePOS."VAT Bus. Posting Group");
        end;

        if TransferDimensions then begin
            SalesHeader."Dimension Set ID" := SalePOS."Dimension Set ID";
            SalesHeader."Shortcut Dimension 1 Code" := SalePOS."Shortcut Dimension 1 Code";
            SalesHeader."Shortcut Dimension 2 Code" := SalePOS."Shortcut Dimension 2 Code";
        end;

        if TransferPaymentMethod then begin
            SaleLinePOS.SetRange("Register No.", SalePOS."Register No.");
            SaleLinePOS.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");
            SaleLinePOS.SetRange(Date, SalePOS.Date);
            SaleLinePOS.SetRange("Sale Type", SaleLinePOS."Sale Type"::Payment);
            if SaleLinePOS.FindFirst then
                if PaymentTypePOS.Get(SaleLinePOS."No.") then
                    if PaymentTypePOS."Payment Method Code" <> '' then
                        SalesHeader.Validate("Payment Method Code", PaymentTypePOS."Payment Method Code");
        end;

        if TransferTaxSetup then begin
            if SalePOS."Tax Area Code" <> '' then
                SalesHeader.Validate("Tax Area Code", SalePOS."Tax Area Code");
            if SalePOS."Tax Liable" then
                SalesHeader.Validate("Tax Liable", true);
        end;

        if TransferTransactionData then begin

        end;
    end;

    local procedure TransferInfoFromSaleLinePOS(var SaleLinePOS: Record "NPR Sale Line POS"; var SalesLine: Record "Sales Line")
    begin
        if TransferPostingSetup then begin
            if SaleLinePOS."Posting Group" <> '' then
                SalesLine.Validate("Posting Group", SaleLinePOS."Posting Group");
            if SaleLinePOS."Gen. Prod. Posting Group" <> '' then
                SalesLine.Validate("Gen. Prod. Posting Group", SaleLinePOS."Gen. Prod. Posting Group");
            if SaleLinePOS."Gen. Bus. Posting Group" <> '' then
                SalesLine.Validate("Gen. Bus. Posting Group", SaleLinePOS."Gen. Bus. Posting Group");
        end;

        if TransferDimensions then begin
            SalesLine."Dimension Set ID" := SaleLinePOS."Dimension Set ID";
            SalesLine."Shortcut Dimension 1 Code" := SaleLinePOS."Shortcut Dimension 1 Code";
            SalesLine."Shortcut Dimension 2 Code" := SaleLinePOS."Shortcut Dimension 2 Code";
        end;

        if TransferTaxSetup then begin
            if SaleLinePOS."Tax Area Code" <> '' then
                SalesLine.Validate("Tax Area Code", SaleLinePOS."Tax Area Code");
            if SaleLinePOS."Tax Liable" then
                SalesLine.Validate("Tax Liable", true);
        end;

        if TransferTransactionData then begin

        end;
    end;

    procedure ReserveSalesLines(var SalesHeader: Record "Sales Header"; WithError: Boolean)
    var
        SalesLine: Record "Sales Line";
        AllLinesReserved: Boolean;
        Item: Record Item;
    begin
        SalesLine.Reset;
        SalesLine.SetFilter("Document Type", '=%1', SalesHeader."Document Type");
        SalesLine.SetFilter("Document No.", '=%1', SalesHeader."No.");
        SalesLine.SetFilter(Type, '=%1', SalesLine.Type::Item);
        SalesLine.SetFilter(Reserve, '<>%1', SalesLine.Reserve::Never);
        AllLinesReserved := true;
        if SalesLine.FindSet then begin
            repeat
                if not ReserveSaleLine(SalesLine) then begin
                    AllLinesReserved := false;
                    if WithError then
                        Error(RESERVE_FAIL_ERROR, Item.TableCaption, SalesLine."No.", SalesLine.FieldCaption(Quantity), SalesLine.Quantity);
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
        SalesLine.TestField("Job No.", '');
        SalesLine.TestField("Drop Shipment", false);
        SalesLine.TestField(Type, SalesLine.Type::Item);
        SalesLine.TestField("Shipment Date");

        //Calc qtyÙs
        SalesLine.CalcFields("Reserved Quantity", "Reserved Qty. (Base)");
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
        ReservationEntry."Source Subtype" := SalesLine."Document Type".AsInteger();
        ReservationEntry."Source ID" := SalesLine."Document No.";
        ReservationEntry."Source Ref. No." := SalesLine."Line No.";

        ReservationEntry."Item No." := SalesLine."No.";
        ReservationEntry."Variant Code" := SalesLine."Variant Code";
        ReservationEntry."Location Code" := SalesLine."Location Code";
        ReservationEntry."Shipment Date" := SalesLine."Shipment Date";

        //CaptionText := ReserveSalesLine.Caption(SalesLine);

        ReservationManagement.SetReservSource(SalesLine);

        //Run auto reserve
        ReservationManagement.AutoReserve(
          FullAutoReservation, ReservationEntry.Description,
          ReservationEntry."Shipment Date", QtyToReserve - QtyReserved, QtyToReserveBase - QtyReservedBase);

        FullyReservedLine := FullAutoReservation;
        exit(FullyReservedLine);
    end;

    local procedure CreatePrepaymentLineLegacy(SalePOS: Record "NPR Sale POS"; var SalesHeader: Record "Sales Header"; DepositPercentage: Decimal)
    var
        // TODO: CTRLUPGRADE - Marshaller is obsolete and must not be used
        //Marshaller: Codeunit "POS Event Marshaller";
        SaleLinePOS: Record "NPR Sale Line POS";
        LineNo: Integer;
    begin
        SalesHeader.CalcFields("Amount Including VAT");
        if SalesHeader."Amount Including VAT" <> 0 then begin
            if SalesHeader."Prepayment %" <> 0 then
                SuggestedDepositAmount := SalesHeader."Amount Including VAT" * (SalesHeader."Prepayment %" / 100)
            else
                SuggestedDepositAmount := SalesHeader."Amount Including VAT" * (DepositPercentage / 100);
            if ShowDepositDialog then begin
                // TODO: CTRLUPGRADE - Must refactor without Marshaller
                Error('CTRLUPGRADE');
                /*
                if not Marshaller.NumPad(Text000011, SuggestedDepositAmount, false, false) then
                    SuggestedDepositAmount := 0;
                */
            end;
            if SuggestedDepositAmount <> 0 then begin
                SaleLinePOS.Reset;
                SaleLinePOS.SetCurrentKey("Register No.", "Sales Ticket No.", "Line No.");
                SaleLinePOS.SetRange("Register No.", SalePOS."Register No.");
                SaleLinePOS.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");
                if SaleLinePOS.FindLast then;
                LineNo := SaleLinePOS."Line No.";

                SaleLinePOS.SetCurrentKey("Register No.", "Sales Ticket No.", Date, "Sale Type", "Line No.");
                SaleLinePOS.Init;
                SaleLinePOS."Register No." := SalePOS."Register No.";
                SaleLinePOS."Sales Ticket No." := SalePOS."Sales Ticket No.";
                SaleLinePOS.Date := SalePOS.Date;
                SaleLinePOS."Sale Type" := SaleLinePOS."Sale Type"::Deposit;
                SaleLinePOS."Line No." := LineNo + 1;
                SaleLinePOS.Type := SaleLinePOS.Type::Customer;
                SaleLinePOS.Date := SalePOS.Date;
                SaleLinePOS.Insert(true);
                SalePOS.Validate("Customer No.", SalesHeader."Bill-to Customer No.");
                SaleLinePOS.Validate(Quantity, 1);
                SaleLinePOS.Validate("No.", SalesHeader."Bill-to Customer No.");
                SaleLinePOS."Sales Document Type" := SalesHeader."Document Type";
                SaleLinePOS."Sales Document No." := SalesHeader."No.";
                SaleLinePOS."Sales Document Prepayment" := true;
                SaleLinePOS."Sales Doc. Prepayment Value" := (SuggestedDepositAmount / SalesHeader."Amount Including VAT") * 100;
                SaleLinePOS.Validate("Unit Price", SuggestedDepositAmount);
                SaleLinePOS.Description := StrSubstNo(Text000009, SalesHeader."Document Type", SalesHeader."No.");
                SaleLinePOS.Modify(true);
                Commit;
            end;
        end;
    end;

    local procedure PrintRetailReceipt(SalePOS: Record "NPR Sale POS")
    var
        AuditRoll: Record "NPR Audit Roll";
        POSEntry: Record "NPR POS Entry";
        NPRetailSetup: Record "NPR NP Retail Setup";
        RetailReportSelectionMgt: Codeunit "NPR Retail Report Select. Mgt.";
        RecRef: RecordRef;
        ReportSelectionRetail: Record "NPR Report Selection Retail";
        RetailSalesCode: Codeunit "NPR Retail Sales Code";
        POSEntryManagement: Codeunit "NPR POS Entry Management";
    begin
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
            clear(POSEntryManagement);
            POSEntryManagement.SetFunctionToRun(1);
            POSEntryManagement.SetLargePrint(false);
            if not POSEntryManagement.Run(POSEntry) then
                Message(RetailPrintErrorTxt, GetLastErrorText);
        end else begin
            AuditRoll.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");
            if not AuditRoll.FindSet then
                exit;
            if not RetailSalesCode.Run(AuditRoll) then
                Message(Text000002, Text000005, AuditRoll.FieldCaption("Sales Ticket No."), AuditRoll."Sales Ticket No.")
        end;
    end;

    local procedure PrintGiftVoucher(var SalePOS: Record "NPR Sale POS")
    var
        AuditRoll: Record "NPR Audit Roll";
        RetailTableCode: Codeunit "NPR Retail Table Code";
        GiftVoucher: Record "NPR Gift Voucher";
    begin
        AuditRoll.SetRange("Register No.", SalePOS."Register No.");
        AuditRoll.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");
        AuditRoll.SetRange("Sale Date", SalePOS.Date);
        AuditRoll.SetRange(Type, AuditRoll.Type::"G/L");
        AuditRoll.SetRange("Sale Type", AuditRoll."Sale Type"::"Debit Sale");
        AuditRoll.SetFilter("Gift voucher ref.", '<>%1', '');
        if AuditRoll.FindSet() then
            repeat
                if GiftVoucher.Get(AuditRoll."Gift voucher ref.") then begin
                    GiftVoucher.SetRecFilter();
                    if not RetailTableCode.Run(GiftVoucher) then
                        Message(Text000002, GiftVoucher.TableCaption, GiftVoucher.FieldCaption("No."), GiftVoucher."No.");
                end;
            until AuditRoll.Next = 0;
    end;

    procedure GetCreatedSalesHeader(var CreatedSalesHeaderOut: Record "Sales Header")
    begin
        CreatedSalesHeaderOut := CreatedSalesHeader;
    end;

    local procedure PostPrepaymentBeforePOSSaleEnd(var SalesHeader: Record "Sales Header"; var SaleLinePOS: Record "NPR Sale Line POS")
    var
        SalesPostPrepayments: Codeunit "Sales-Post Prepayments";
        SalesLine: Record "Sales Line";
        ReportSelections: Record "Report Selections";
        RecordVariant: Variant;
        SalesInvoiceHeader: Record "Sales Invoice Header";
        Print: Boolean;
        POSPrepaymentMgt: Codeunit "NPR POS Prepayment Mgt.";
        Send: Boolean;
        Pdf2Nav: Boolean;
        POSSalesDocumentOutputMgt: Codeunit "NPR POS Sales Doc. Output Mgt.";
    begin
        with SaleLinePOS do begin
            SalesHeader.TestField("Document Type", SalesHeader."Document Type"::Order);

            if "Sales Doc. Prepay Is Percent" then
                POSPrepaymentMgt.SetPrepaymentPercentageToPay(SalesHeader, true, "Sales Doc. Prepayment Value")
            else
                POSPrepaymentMgt.SetPrepaymentAmountToPayInclVAT(SalesHeader, true, "Sales Doc. Prepayment Value");

            Pdf2Nav := "Sales Document Pdf2Nav";
            Send := "Sales Document Send";
            Print := "Sales Document Print";
            "Sales Document Prepayment" := false;
            "Sales Document Print" := false;
            "Sales Document Pdf2Nav" := false;
            "Sales Document Send" := false;
            Modify(true);

            SalesPostPrepayments.Invoice(SalesHeader);
            "Buffer Document Type" := "Buffer Document Type"::Invoice;
            "Posted Sales Document Type" := "Posted Sales Document Type"::INVOICE;
            "Posted Sales Document No." := SalesHeader."Last Prepayment No.";
            Validate("Buffer Document No.", SalesHeader."Last Prepayment No.");
            Modify(true);

            Commit;

            if Print then begin
                POSSalesDocumentOutputMgt.PrintDocument(SalesHeader, 1);
            end;

            if Send then begin
                POSSalesDocumentOutputMgt.SendDocument(SalesHeader, 1);
            end;

            if Pdf2Nav then begin
                POSSalesDocumentOutputMgt.SendPdf2NavDocument(SalesHeader, 1);
            end;
        end;
    end;

    local procedure PostPrepaymentRefundBeforePOSSaleEnd(var SalesHeader: Record "Sales Header"; var SaleLinePOS: Record "NPR Sale Line POS")
    var
        SalesPostPrepayments: Codeunit "Sales-Post Prepayments";
        DeleteAfter: Boolean;
        ReportSelections: Record "Report Selections";
        RecordVariant: Variant;
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        Print: Boolean;
        Send: Boolean;
        Pdf2Nav: Boolean;
        POSSalesDocumentOutputMgt: Codeunit "NPR POS Sales Doc. Output Mgt.";
    begin
        with SaleLinePOS do begin
            SalesHeader.TestField("Document Type", SalesHeader."Document Type"::Order);
            DeleteAfter := "Sales Document Delete";
            Print := "Sales Document Print";
            Send := "Sales Document Send";
            Pdf2Nav := "Sales Document Pdf2Nav";
            "Sales Document Prepay. Refund" := false;
            "Sales Document Delete" := false;
            "Sales Document Print" := false;
            "Sales Document Send" := false;
            "Sales Document Pdf2Nav" := false;
            Modify(true);

            SalesPostPrepayments.CreditMemo(SalesHeader);
            "Posted Sales Document Type" := "Posted Sales Document Type"::CREDIT_MEMO;
            "Posted Sales Document No." := SalesHeader."Last Prepmt. Cr. Memo No.";
            "Buffer Document Type" := "Buffer Document Type"::"Credit Memo";
            Validate("Buffer Document No.", SalesHeader."Last Prepmt. Cr. Memo No.");
            Modify(true);

            if DeleteAfter then
                SalesHeader.Delete(true);

            Commit;

            if Print then begin
                POSSalesDocumentOutputMgt.PrintDocument(SalesHeader, 2);
            end;

            if Send then begin
                POSSalesDocumentOutputMgt.SendDocument(SalesHeader, 2);
            end;

            if Pdf2Nav then begin
                POSSalesDocumentOutputMgt.SendPdf2NavDocument(SalesHeader, 2);
            end;
        end;
    end;

    local procedure PostDocumentBeforePOSSaleEnd(var SalesHeader: Record "Sales Header"; var SaleLinePOS: Record "NPR Sale Line POS")
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
        POSSalesDocumentOutputMgt: Codeunit "NPR POS Sales Doc. Output Mgt.";
    begin
        with SaleLinePOS do begin
            if not (SalesHeader."Document Type" in [SalesHeader."Document Type"::Invoice, SalesHeader."Document Type"::Order, SalesHeader."Document Type"::"Credit Memo", SalesHeader."Document Type"::"Return Order"]) then
                SalesHeader.FieldError("Document Type");
            SalesHeader.Ship := "Sales Document Ship";
            SalesHeader.Invoice := "Sales Document Invoice";
            SalesHeader.Receive := "Sales Document Receive";
            SalesHeader.Modify(true);
            Print := "Sales Document Print";
            Send := "Sales Document Send";
            Pdf2Nav := "Sales Document Pdf2Nav";

            "Sales Document Invoice" := false;
            "Sales Document Ship" := false;
            "Sales Document Receive" := false;
            "Sales Document Print" := false;
            "Sales Document Send" := false;
            "Sales Document Pdf2Nav" := false;
            Modify(true);

            SalesPost.Run(SalesHeader);

            if SalesHeader.Invoice then begin
                case SalesHeader."Document Type" of
                    SalesHeader."Document Type"::Invoice:
                        begin
                            "Buffer Document Type" := "Buffer Document Type"::Invoice;
                            if SalesHeader."Last Posting No." <> '' then
                                Validate("Buffer Document No.", SalesHeader."Last Posting No.")
                            else
                                Validate("Buffer Document No.", SalesHeader."No.");
                            "Posted Sales Document Type" := "Posted Sales Document Type"::INVOICE;
                            "Posted Sales Document No." := "Buffer Document No.";
                        end;
                    SalesHeader."Document Type"::Order:
                        begin
                            "Buffer Document Type" := "Buffer Document Type"::Invoice;
                            Validate("Buffer Document No.", SalesHeader."Last Posting No.");
                            "Posted Sales Document Type" := "Posted Sales Document Type"::INVOICE;
                            "Posted Sales Document No." := "Buffer Document No.";
                        end;
                    SalesHeader."Document Type"::"Credit Memo":
                        begin
                            "Buffer Document Type" := "Buffer Document Type"::"Credit Memo";
                            if SalesHeader."Last Posting No." <> '' then
                                Validate("Buffer Document No.", SalesHeader."Last Posting No.")
                            else
                                Validate("Buffer Document No.", SalesHeader."No.");
                            "Posted Sales Document Type" := "Posted Sales Document Type"::CREDIT_MEMO;
                            "Posted Sales Document No." := "Buffer Document No.";
                        end;
                    SalesHeader."Document Type"::"Return Order":
                        begin
                            "Buffer Document Type" := "Buffer Document Type"::"Credit Memo";
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

            if Print then begin
                POSSalesDocumentOutputMgt.PrintDocument(SalesHeader, 0);
            end;

            if Send then begin
                POSSalesDocumentOutputMgt.SendDocument(SalesHeader, 0);
            end;

            if Pdf2Nav then begin
                POSSalesDocumentOutputMgt.SendPdf2NavDocument(SalesHeader, 0);
            end;
        end;
    end;

    procedure CreatePrepaymentLine(var POSSession: Codeunit "NPR POS Session"; var SalesHeader: Record "Sales Header"; PrepaymentValue: Decimal; Print: Boolean; Send: Boolean; Pdf2Nav: Boolean; SyncPosting: Boolean; ValueIsAmount: Boolean)
    var
        PrepaymentAmount: Decimal;
        POSSale: Codeunit "NPR POS Sale";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        SalePOS: Record "NPR Sale POS";
        SaleLinePOS: Record "NPR Sale Line POS";
        POSPrepaymentMgt: Codeunit "NPR POS Prepayment Mgt.";
    begin
        if ValueIsAmount then begin
            POSPrepaymentMgt.SetPrepaymentAmountToPayInclVAT(SalesHeader, true, PrepaymentValue);
            PrepaymentAmount := PrepaymentValue;
        end else begin
            PrepaymentAmount := POSPrepaymentMgt.SetPrepaymentPercentageToPay(SalesHeader, true, PrepaymentValue);
        end;

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
        SaleLinePOS."Sales Doc. Prepayment Value" := PrepaymentValue;
        SaleLinePOS."Sales Doc. Prepay Is Percent" := not ValueIsAmount;
        SaleLinePOS."Sales Document Print" := Print;
        SaleLinePOS."Sales Document Send" := Send;
        SaleLinePOS."Sales Document Pdf2Nav" := Pdf2Nav;
        SaleLinePOS."Sales Document Sync. Posting" := SyncPosting;
        SaleLinePOS.Validate("Unit Price", PrepaymentAmount);
        SaleLinePOS.Description := StrSubstNo(PREPAYMENT, SalesHeader."Document Type", SalesHeader."No.");
        SaleLinePOS.UpdateAmounts(SaleLinePOS);
        POSSaleLine.InsertLineRaw(SaleLinePOS, false);
    end;

    procedure CreatePrepaymentRefundLine(var POSSession: Codeunit "NPR POS Session"; var SalesHeader: Record "Sales Header"; Print: Boolean; Send: Boolean; Pdf2Nav: Boolean; SyncPosting: Boolean; DeleteDocumentAfter: Boolean)
    var
        PrepaymentRefundAmount: Decimal;
        POSSale: Codeunit "NPR POS Sale";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        SalePOS: Record "NPR Sale POS";
        SaleLinePOS: Record "NPR Sale Line POS";
        POSPrepaymentMgt: Codeunit "NPR POS Prepayment Mgt.";
    begin
        POSSession.GetSale(POSSale);
        POSSession.GetSaleLine(POSSaleLine);
        POSSale.GetCurrentSale(SalePOS);

        PrepaymentRefundAmount := POSPrepaymentMgt.GetPrepaymentAmountToDeductInclVAT(SalesHeader);

        POSSaleLine.GetNewSaleLine(SaleLinePOS);
        SaleLinePOS."Sale Type" := SaleLinePOS."Sale Type"::Deposit;
        SaleLinePOS.Type := SaleLinePOS.Type::Customer;
        SaleLinePOS.Validate(Quantity, 1);
        SaleLinePOS.Validate("No.", SalesHeader."Bill-to Customer No.");
        SaleLinePOS."Sales Document Type" := SalesHeader."Document Type";
        SaleLinePOS."Sales Document No." := SalesHeader."No.";
        SaleLinePOS."Sales Document Prepay. Refund" := true;
        SaleLinePOS."Sales Document Print" := Print;
        SaleLinePOS."Sales Document Send" := Send;
        SaleLinePOS."Sales Document Pdf2Nav" := Pdf2Nav;
        SaleLinePOS."Sales Document Sync. Posting" := SyncPosting;
        SaleLinePOS."Sales Document Delete" := DeleteDocumentAfter;
        SaleLinePOS.Validate("Unit Price", -PrepaymentRefundAmount);
        SaleLinePOS.Description := StrSubstNo(PREPAYMENT_REFUND, SalesHeader."Document Type", SalesHeader."No.");
        SaleLinePOS.UpdateAmounts(SaleLinePOS);
        POSSaleLine.InsertLineRaw(SaleLinePOS, false);
    end;

    procedure HandleLinkedDocuments(POSSession: Codeunit "NPR POS Session")
    var
        POSSale: Codeunit "NPR POS Sale";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        SalePOS: Record "NPR Sale POS";
        SaleLinePOS: Record "NPR Sale Line POS";
        SalesHeader: Record "Sales Header";
    begin
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
                if SalesHeader.Get("Sales Document Type", "Sales Document No.") then begin
                    case true of
                        "Sales Document Prepayment":
                            PostPrepaymentBeforePOSSaleEnd(SalesHeader, SaleLinePOS);

                        "Sales Document Prepay. Refund":
                            PostPrepaymentRefundBeforePOSSaleEnd(SalesHeader, SaleLinePOS);

                        "Sales Document Ship",
                        "Sales Document Receive",
                        "Sales Document Invoice":
                            PostDocumentBeforePOSSaleEnd(SalesHeader, SaleLinePOS);
                    end;
                end;
            until Next = 0;

            POSSaleLine.RefreshCurrent();
        end;
    end;

    local procedure OpenSalesDocCardAndSyncChangesBackToPOSSale(var SalesHeader: Record "Sales Header"; var SalePOS: Record "NPR Sale POS")
    var
        SalesHeader2: Record "Sales Header";
        ApplySalespersontoDocument: Codeunit "NPR Apply Salesperson to Doc.";
    begin
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
    end;

    local procedure UpdateActiveSaleWithDocumentChanges(SalesHeader: Record "Sales Header"; var SalePOS: Record "NPR Sale POS")
    var
        RetailSalesDocImpMgt: Codeunit "NPR Sales Doc. Imp. Mgt.";
    begin
        SalePOS."Sales Document Type" := SalesHeader."Document Type";
        SalePOS."Sales Document No." := SalesHeader."No.";
        SalePOS.Parameters := 'IMPORT_DOCUMENT_SYNC';

        if not RetailSalesDocImpMgt.Run(SalePOS) then
            Error(ERR_ORDER_SALE_SYNC, SalesHeader."Document Type", SalesHeader."No.", GetLastErrorText);

        SalePOS.Get(SalePOS."Register No.", SalePOS."Sales Ticket No.");
    end;

    local procedure GetLocationCode(SalePOS: Record "NPR Sale POS"): Code[10]
    var
        POSStore: Record "NPR POS Store";
        Register: Record "NPR Register";
    begin
        case UseLocationFrom of
            UseLocationFrom::Register:
                begin
                    Register.Get(SalePOS."Register No.");
                    exit(Register."Location Code");
                end;
            UseLocationFrom::"POS Store":
                begin
                    POSStore.Get(SalePOS."POS Store Code");
                    exit(POSStore."Location Code");
                end;
            UseLocationFrom::"POS Sale":
                exit(SalePOS."Location Code");
            UseLocationFrom::"Specific Location":
                exit(UseLocationCode);
        end;
    end;

    local procedure SendICOrderConfirmation(var SalesHeader: Record "Sales Header")
    var
        ICPartner: Record "IC Partner";
        ApprovalsMgmt: Codeunit "Approvals Mgmt.";
        ICInOutboxMgt: Codeunit ICInboxOutboxMgt;
    begin
        with SalesHeader do begin
            if not (
                ("Document Type" in ["Document Type"::Order, "Document Type"::"Return Order"]) and
                ("IC Status" = "IC Status"::New) and "Send IC Document")
            then
                exit;

            if (Status = Status::Open) and ApprovalsMgmt.IsSalesApprovalsWorkflowEnabled(SalesHeader) then  //must go through approval workflow first
                exit;

            if "Sell-to IC Partner Code" <> '' then
                ICPartner.Get("Sell-to IC Partner Code")
            else
                ICPartner.Get("Bill-to IC Partner Code");
            if ICPartner."Inbox Type" = ICPartner."Inbox Type"::"No IC Transfer" then
                exit;

            ICInOutboxMgt.SendSalesDoc(SalesHeader, false);
        end;
    end;

    //--- Audit Roll Transfer ---

    procedure CreateDocumentPostingAudit(var SalesHeader: Record "Sales Header"; var SalePOS: Record "NPR Sale POS"; Posted: Boolean)
    var
        Text10600062: Label 'Debit to %1 on invoice %2';
        Text10600063: Label 'Delivery to %1 on delivery %2';
        Text10600064: Label 'Credit to %1 on credit note %2';
        Text10600065: Label 'Transferred to %1 %2';
        TxtReturSalg: Label 'Delivery to %1 on return order %2';
        AuditRoll: Record "NPR Audit Roll";
        RetailSetup: Record "NPR Retail Setup";
    begin
        RetailSetup.Get;
        if RetailSetup."Create POS Entries Only" then
            exit;
        AuditRoll.SetCurrentKey("Register No.", "Sales Ticket No.", "Sale Date");
        AuditRoll.SetRange("Register No.", SalePOS."Register No.");
        AuditRoll.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");
        AuditRoll.SetRange("Sale Date", Today);

        AuditRoll."Register No." := SalePOS."Register No.";
        AuditRoll."Sales Ticket No." := SalePOS."Sales Ticket No.";
        AuditRoll."Sale Type" := AuditRoll."Sale Type"::"Debit Sale";
        AuditRoll."Line No." := 1;
        AuditRoll."Sale Date" := Today;

        AuditRoll.Type := AuditRoll.Type::Comment;
        case SalesHeader."Document Type" of
            SalesHeader."Document Type"::Invoice:
                AuditRoll."Document Type" := AuditRoll."Document Type"::Invoice;
            SalesHeader."Document Type"::Order:
                AuditRoll."Document Type" := AuditRoll."Document Type"::Order;
            SalesHeader."Document Type"::"Credit Memo":
                AuditRoll."Document Type" := AuditRoll."Document Type"::"Credit Memo";
            SalesHeader."Document Type"::"Return Order":
                AuditRoll."Document Type" := AuditRoll."Document Type"::"Return Order";
        end;
        AuditRoll."Posted Doc. No." := SalesHeader."Last Posting No.";
        AuditRoll.Lokationskode := SalePOS."Location Code";
        AuditRoll."Shortcut Dimension 1 Code" := SalePOS."Shortcut Dimension 1 Code";
        AuditRoll."Shortcut Dimension 2 Code" := SalePOS."Shortcut Dimension 2 Code";
        AuditRoll."Dimension Set ID" := SalePOS."Dimension Set ID";

        AuditRoll."Salesperson Code" := SalePOS."Salesperson Code";
        AuditRoll.Posted := true;
        AuditRoll."Closing Time" := Time;
        AuditRoll."Retail Document Type" := SalePOS."Retail Document Type";
        AuditRoll."Retail Document No." := SalePOS."Retail Document No.";
        AuditRoll.Reference := SalePOS.Reference;
        AuditRoll.Posted := true;

        AuditRoll."Customer Type" := SalePOS."Customer Type";
        AuditRoll."Customer No." := SalePOS."Customer No.";
        AuditRoll."Salesperson Code" := SalesHeader."Salesperson Code";

        if Posted then
            case SalesHeader."Document Type" of
                SalesHeader."Document Type"::Invoice:
                    begin
                        if SalesHeader."Last Posting No." <> '' then
                            AuditRoll."Document No." := SalesHeader."Last Posting No."
                        else
                            AuditRoll."Document No." := SalesHeader."No.";
                        AuditRoll.Description := StrSubstNo(Text10600062, SalePOS."Customer No.", AuditRoll."Document No.");
                    end;
                SalesHeader."Document Type"::Order:
                    begin
                        AuditRoll."Document No." := SalesHeader."Last Shipping No.";
                        AuditRoll.Description := StrSubstNo(Text10600063, SalePOS."Customer No.", AuditRoll."Document No.");
                    end;
                SalesHeader."Document Type"::"Credit Memo":
                    begin
                        if SalesHeader."Last Posting No." <> '' then
                            AuditRoll."Document No." := SalesHeader."Last Posting No."
                        else
                            AuditRoll."Document No." := SalesHeader."No.";
                        AuditRoll.Description := StrSubstNo(Text10600064, SalePOS."Customer No.", AuditRoll."Document No.");
                    end;
                SalesHeader."Document Type"::"Return Order":
                    begin
                        AuditRoll."Document No." := SalesHeader."Last Return Receipt No.";
                        AuditRoll.Description := StrSubstNo(TxtReturSalg, SalePOS."Customer No.", AuditRoll."Document No.");
                    end;
            end else
            AuditRoll.Description := StrSubstNo(Text10600065, SalesHeader."Document Type", SalesHeader."No.");

        AuditRoll.Insert(true);

        TransferLinesToAuditRoll(SalePOS, AuditRoll."Document No.");
    end;

    local procedure TransferLinesToAuditRoll(var Sale: Record "NPR Sale POS"; DocumentNo: Code[20])
    var
        SaleLinePOS: Record "NPR Sale Line POS";
        GiftVoucher: Record "NPR Gift Voucher";
        PaymentTypePOS: Record "NPR Payment Type POS";
        AuditRoll: Record "NPR Audit Roll";
        TicketManagement: Codeunit "NPR TM Ticket Management";
        DimMgt: Codeunit "NPR Dimension Mgt.";
        Register: Record "NPR Register";
        RetailFormCode: Codeunit "NPR Retail Form Code";
    begin
        Register.Get(Sale."Register No.");
        SaleLinePOS.SetCurrentKey(SaleLinePOS."Register No.", SaleLinePOS."Sales Ticket No.", SaleLinePOS."Line No.");

        SaleLinePOS.SetRange("Register No.", Sale."Register No.");
        SaleLinePOS.SetRange("Sales Ticket No.", Sale."Sales Ticket No.");
        SaleLinePOS.SetFilter("Sale Type", '=%1|=%2|=%3', SaleLinePOS."Sale Type"::Sale, SaleLinePOS."Sale Type"::Comment, SaleLinePOS."Sale Type"::"Debit Sale");

        AuditRoll.SetRange("Register No.", Sale."Register No.");
        AuditRoll.SetRange("Sales Ticket No.", Sale."Sales Ticket No.");
        if AuditRoll.FindLast then;

        if SaleLinePOS.FindSet then
            repeat
                AuditRoll.Init;
                AuditRoll."Register No." := SaleLinePOS."Register No.";
                AuditRoll."Sales Ticket No." := SaleLinePOS."Sales Ticket No.";

                AuditRoll."Line No." := SaleLinePOS."Line No.";

                AuditRoll.TransferFromSaleLinePOS(SaleLinePOS, Sale."Start Time", DocumentNo, AuditRoll."Document Type", AuditRoll."Allocated No.");
                AuditRoll."Sale Type" := AuditRoll."Sale Type"::"Debit Sale";
                case SaleLinePOS.Type of
                    SaleLinePOS.Type::Item:
                        AuditRoll.Type := AuditRoll.Type::Item;
                    SaleLinePOS.Type::Customer:
                        AuditRoll.Type := AuditRoll.Type::Customer;
                    SaleLinePOS.Type::"G/L Entry":
                        AuditRoll.Type := AuditRoll.Type::"G/L";
                end;
                AuditRoll."Salesperson Code" := Sale."Salesperson Code";
                AuditRoll.Posted := not AuditRoll.Offline;
                AuditRoll."Customer No." := Sale."Customer No.";
                AuditRoll."Retail Document Type" := Sale."Retail Document Type";
                AuditRoll."Retail Document No." := Sale."Retail Document No.";
                if AuditRoll.Offline then
                    AuditRoll.Posted := false;

                RetailFormCode.OnBeforeAuditRoleLineInsertEvent(Sale, SaleLinePOS, AuditRoll);

                AuditRoll.Insert(true);
                DimMgt.CopySaleLineDimToAuditDim(SaleLinePOS, AuditRoll);
            until SaleLinePOS.Next = 0;

        SaleLinePOS.SetRange("Sale Type", SaleLinePOS."Sale Type"::Deposit);
        if SaleLinePOS.FindSet then
            repeat
                PaymentTypePOS.SetRange("Processing Type", PaymentTypePOS."Processing Type"::"Gift Voucher");
                PaymentTypePOS.SetRange("G/L Account No.", SaleLinePOS."No.");
                if PaymentTypePOS.Find('-') then begin
                    AuditRoll.Init;
                    AuditRoll."Register No." := SaleLinePOS."Register No.";
                    AuditRoll."Sales Ticket No." := SaleLinePOS."Sales Ticket No.";
                    AuditRoll."Line No." := SaleLinePOS."Line No.";

                    AuditRoll.TransferFromSaleLinePOS(SaleLinePOS, Sale."Start Time", DocumentNo, AuditRoll."Document Type", AuditRoll."Allocated No.");

                    if AuditRoll."Gift voucher ref." <> '' then begin
                        GiftVoucher.Get(SaleLinePOS."Gift Voucher Ref.");
                        GiftVoucher.CreateFromAuditRoll(AuditRoll);
                        GiftVoucher.Modify;
                    end;

                    AuditRoll."Sale Type" := AuditRoll."Sale Type"::"Debit Sale";
                    case SaleLinePOS.Type of
                        SaleLinePOS.Type::Customer:
                            AuditRoll.Type := AuditRoll.Type::Customer;
                        SaleLinePOS.Type::"G/L Entry":
                            AuditRoll.Type := AuditRoll.Type::"G/L";
                    end;

                    AuditRoll."Salesperson Code" := Sale."Salesperson Code";
                    AuditRoll.Posted := not AuditRoll.Offline;
                    AuditRoll."Customer No." := Sale."Customer No.";
                    AuditRoll."Retail Document Type" := Sale."Retail Document Type";
                    AuditRoll."Retail Document No." := Sale."Retail Document No.";
                    if AuditRoll.Offline then
                        AuditRoll.Posted := false;

                    RetailFormCode.OnBeforeAuditRoleLineInsertEvent(Sale, SaleLinePOS, AuditRoll);

                    AuditRoll.Insert(true);
                end;
                DimMgt.CopySaleLineDimToAuditDim(SaleLinePOS, AuditRoll);
            until SaleLinePOS.Next = 0;

        SaleLinePOS.SetRange("Sale Type", SaleLinePOS."Sale Type"::"Out payment");
        if SaleLinePOS.FindSet then
            repeat
                if SaleLinePOS."No." = Register."Gift Voucher Discount Account" then begin
                    AuditRoll.Init;
                    AuditRoll."Register No." := SaleLinePOS."Register No.";
                    AuditRoll."Sales Ticket No." := SaleLinePOS."Sales Ticket No.";
                    AuditRoll."Line No." := SaleLinePOS."Line No.";
                    AuditRoll.TransferFromSaleLinePOS(SaleLinePOS, Sale."Start Time", DocumentNo, AuditRoll."Document Type", AuditRoll."Allocated No.");

                    AuditRoll."Sale Type" := AuditRoll."Sale Type"::"Debit Sale";
                    case SaleLinePOS.Type of
                        SaleLinePOS.Type::Customer:
                            AuditRoll.Type := AuditRoll.Type::Customer;
                        SaleLinePOS.Type::"G/L Entry":
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

                    RetailFormCode.OnBeforeAuditRoleLineInsertEvent(Sale, SaleLinePOS, AuditRoll);

                    AuditRoll.Insert(true);
                end;
                DimMgt.CopySaleLineDimToAuditDim(SaleLinePOS, AuditRoll);
            until SaleLinePOS.Next = 0;
    end;

    //--- Setup Functionality ---

    local procedure GetSetupValues(var SalesHeader: Record "Sales Header"; Balance: Decimal)
    var
        RetailSetup: Record "NPR Retail Setup";
    begin
        if not SkipDefaultValues then begin
            RetailSetup.Get;
            RetailPrint := RetailSetup."Retail Debitnote";
            SendPostedPdf2Nav := RetailSetup."Sale Doc. Print On Post";
            DocumentType := SalesHeader."Document Type";
            WriteInAuditRoll := true;

            // Decide document type if not fetched from sales module
            if SalesHeader."No." = '' then begin
                if Balance >= 0 then begin
                    case RetailSetup."Sale Doc. Type On Post. Pstv." of
                        RetailSetup."Sale Doc. Type On Post. Pstv."::Order:
                            DocumentType := SalesHeader."Document Type"::Order;
                        RetailSetup."Sale Doc. Type On Post. Pstv."::Invoice:
                            DocumentType := SalesHeader."Document Type"::Invoice;
                    end;
                end else begin
                    case RetailSetup."Sale Doc. Type On Post. Negt." of
                        RetailSetup."Sale Doc. Type On Post. Negt."::"Return Order":
                            DocumentType := SalesHeader."Document Type"::"Return Order";
                        RetailSetup."Sale Doc. Type On Post. Negt."::"Credit Memo":
                            DocumentType := SalesHeader."Document Type"::"Credit Memo";
                    end;
                end;
            end;

            case DocumentType of
                DocumentType::Order:
                    begin
                        DocumentType := SalesHeader."Document Type"::Order;
                        Ask := RetailSetup."Sale Doc. Post. On Order" = RetailSetup."Sale Doc. Post. On Order"::Ask;
                        if not Ask then begin
                            SalesHeader.Ship := RetailSetup."Sale Doc. Post. On Order"
                                                   in [RetailSetup."Sale Doc. Post. On Order"::Ship,
                                                       RetailSetup."Sale Doc. Post. On Order"::"Ship and Invoice"];
                            SalesHeader.Invoice := RetailSetup."Sale Doc. Post. On Order"
                                                   in [RetailSetup."Sale Doc. Post. On Order"::"Ship and Invoice"];

                            Invoice := SalesHeader.Invoice;
                            Ship := SalesHeader.Ship;

                        end;
                    end;
                DocumentType::Invoice:
                    begin
                        case RetailSetup."Sale Doc. Post. On Invoice" of
                            RetailSetup."Sale Doc. Post. On Invoice"::Yes:
                                begin
                                    Invoice := RetailSetup."Sale Doc. Post. On Invoice" = RetailSetup."Sale Doc. Post. On Invoice"::Yes;
                                    Ship := RetailSetup."Sale Doc. Post. On Invoice" = RetailSetup."Sale Doc. Post. On Invoice"::Yes;
                                end;
                            RetailSetup."Sale Doc. Post. On Invoice"::Ask:
                                begin
                                    Invoice := Confirm(Text000006, true);
                                    Ship := SalesHeader.Invoice;
                                end;
                        end;
                    end;
                DocumentType::"Return Order":
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
                DocumentType::"Credit Memo":
                    begin
                        DocumentType := SalesHeader."Document Type"::"Credit Memo";
                        case RetailSetup."Sale Doc. Post. On Cred. Memo" of
                            RetailSetup."Sale Doc. Post. On Cred. Memo"::Yes:
                                begin
                                    Invoice := true;
                                    Receive := true;
                                end;
                            RetailSetup."Sale Doc. Post. On Cred. Memo"::Ask:
                                begin
                                    Invoice := Confirm(Text000006, true);
                                    Receive := SalesHeader.Invoice;
                                end;
                        end;
                    end;
            end;
            Post := Ship or Invoice or Receive or Ask;
        end else
            Post := Ship or Invoice or Receive or Ask;
    end;

    //---Finish Credit Sale Workflow ---

    [EventSubscriber(ObjectType::Table, 6150729, 'OnDiscoverPOSSalesWorkflows', '', true, false)]
    local procedure OnDiscoverPOSWorkflows(var Sender: Record "NPR POS Sales Workflow")
    begin
        Sender.DiscoverPOSSalesWorkflow(OnFinishCreditSaleCode(), OnFinishCreditSaleDescription, CurrCodeunitId(), 'OnFinishCreditSale');
    end;

    local procedure OnFinishCreditSaleCode(): Code[20]
    begin
        exit('FINISH_CREDIT_SALE');
    end;

    local procedure CurrCodeunitId(): Integer
    begin
        exit(CODEUNIT::"NPR Sales Doc. Exp. Mgt.");
    end;

    local procedure InvokeOnFinishCreditSaleWorkflow(SalePOS: Record "NPR Sale POS")
    var
        POSUnit: Record "NPR POS Unit";
        POSSalesWorkflowSetEntry: Record "NPR POS Sales WF Set Entry";
        POSSalesWorkflowStep: Record "NPR POS Sales Workflow Step";
        SalesDocExpMgt: Codeunit "NPR Sales Doc. Exp. Mgt.";
    begin
        POSSalesWorkflowStep.SetCurrentKey("Sequence No.");
        if POSUnit.Get(SalePOS."Register No.") and (POSUnit."POS Sales Workflow Set" <> '') and
           POSSalesWorkflowSetEntry.Get(POSUnit."POS Sales Workflow Set", OnFinishCreditSaleCode())
        then
            POSSalesWorkflowStep.SetRange("Set Code", POSSalesWorkflowSetEntry."Set Code")
        else
            POSSalesWorkflowStep.SetRange("Set Code", '');
        POSSalesWorkflowStep.SetRange("Workflow Code", OnFinishCreditSaleCode());
        POSSalesWorkflowStep.SetRange(Enabled, true);
        if not POSSalesWorkflowStep.FindSet then
            exit;

        repeat
            Clear(SalesDocExpMgt);
            SalesDocExpMgt.SetInvokeOnFinishCreditSaleSubsribers(POSSalesWorkflowStep);
            if SalesDocExpMgt.Run(SalePOS) then;
            Commit();
        until POSSalesWorkflowStep.Next = 0;
    end;

    //--- Event Publishers ---

    [IntegrationEvent(true, false)]
    local procedure OnAfterDebitSalePostEvent(SalePOS: Record "NPR Sale POS"; SalesHeader: Record "Sales Header"; Posted: Boolean; WriteInAuditRoll: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnFinishCreditSale(POSSalesWorkflowStep: Record "NPR POS Sales Workflow Step"; SalePOS: Record "NPR Sale POS")
    begin
    end;
}