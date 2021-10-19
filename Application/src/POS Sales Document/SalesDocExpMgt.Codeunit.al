codeunit 6014407 "NPR Sales Doc. Exp. Mgt."
{
    Permissions = TableData "NPR POS Entry" = rimd;

    var
        DocumentType: Enum "Sales Document Type";
        Ask: Boolean;
        Invoice: Boolean;
        Print: Boolean;
        Receive: Boolean;
        Ship: Boolean;
        CannotDeleteItemGroupsErr: Label 'You cannot debit item groups!';
        CannotPostPaymentSalesModuleErr: Label 'Error. You can not post customer payments from the register using the sales module!';
        SalesHeaderCreatedLbl: Label '%1 %2 was created', Comment = '%1=SalesHeader."Document Type";%2=SalesHeader."No."';
        OrderShippedLbl: Label '%1 %2 has been shipped under the number %3', Comment = '%1=SalesHeader."Document Type";%2=SalesHeader."No.";%3=SalesHeader."Last Shipping No."';
        ShowCreationMessage, ShowPostedMessage : Boolean;
        OrderTypeSet: Boolean;
        CannotPostPaymentErr: Label 'You cannot post when a payment has been made';
        OneDocPerSalesTicketErr: Label 'Only one sales document can be created per sales ticket';
        OrderType: Integer;
        Text000013: Label 'Serial number must be supplied for item %1 - %2';
        TransferSalesPerson: Boolean;
        TransferPostingSetup: Boolean;
        TransferDimensions: Boolean;
        TransferTaxSetup: Boolean;
        AutoReserveSalesLines: Boolean;
        SendPostedPdf2Nav: Boolean;
        PrintingErrorTxt: Label 'Printing of Documents failed with error: %1';
        SendingErrorTxt: Label 'Sending of Documents failed with error: %1';
        Pdf2NavSendingErrorTxt: Label 'Sending of Documents via Pdf2Nav failed with error: %1';
        RetailPrintErrorTxt: Label 'Retail printing of Documents failed with error: %1';
        RetailPrint: Boolean;
        CreatedSalesHeader: Record "Sales Header";
        OpenSalesDocAfterExport: Boolean;
        PREPAYMENT: Label 'Prepayment of %1 %2';
        PREPAYMENT_REFUND: Label 'Prepayment refund of %1 %2';
        RESERVE_FAIL_MESSAGE: Label 'Full automatic reservation is not possible for all lines in %1 %2.\Reserve manually.';
        RESERVE_FAIL_ERROR: Label 'Full  automatic reservation failed for line with:\%1: %2\%3: %4';
        POSTING_ERROR: Label 'A problem occured during posting of %1 %2.\Document was left in unposted state.\%3';
        SendDocument: Boolean;
        OnFinishCreditSaleDescription: Label 'On finish credit sale workflow';
        ERR_ORDER_SALE_SYNC: Label '%1 %2 was created successfully but an error occurred when syncing changes with POS, preventing POS sale from ending:\%3';
        ERR_DOC_MISSING: Label '%1 %2 is missing after page closed. Cannot sync with POS and end sale.';
        SendICOrderConf: Boolean;
        UseLocationFrom: Option "POS Unit","POS Store","POS Sale","Specific Location";
        UseLocationCode: Code[10];

        PaymentMethodCode: Code[10];
        CustomerCreditCheck: Boolean;
        CUSTOMER_CREDIT_CHECK_FAILED: Label 'Customer credit check failed';

    procedure SetAsk(AskIn: Boolean)
    begin
        Ask := AskIn;
    end;

    procedure SetInvoice(InvoiceIn: Boolean)
    begin
        Invoice := InvoiceIn;
    end;

    procedure SetPrint(PrintIn: Boolean)
    begin
        Print := PrintIn;
    end;

    procedure SetReceive(ReceiveIn: Boolean)
    begin
        Receive := ReceiveIn;
    end;

    procedure SetShip(ShipIn: Boolean)
    begin
        Ship := ShipIn;
    end;

    procedure SetDocumentTypeOrder()
    begin
        DocumentType := DocumentType::Order;
    end;

    procedure SetDocumentTypeInvoice()
    begin
        DocumentType := DocumentType::Invoice;
    end;

    procedure SetDocumentTypeReturnOrder()
    begin
        DocumentType := DocumentType::"Return Order";
    end;

    procedure SetDocumentTypeCreditMemo()
    begin
        DocumentType := DocumentType::"Credit Memo";
    end;

    procedure SetDocumentTypeQuote()
    begin
        DocumentType := DocumentType::Quote;
    end;

    procedure SetShowCreationMessage()
    begin
        ShowCreationMessage := true;
    end;

    procedure SetShowPostedMessage(_ShowPostedMessage: Boolean)
    begin
        ShowPostedMessage := _ShowPostedMessage;
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

    procedure SetTransferTaxSetup(TransferTaxSetupIn: Boolean)
    begin
        TransferTaxSetup := TransferTaxSetupIn;
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

    procedure SetLocationSource(NewSource: Option "POS Unit","POS Store","POS Sale","Specific Location"; NewLocationCode: Code[10])
    begin
        UseLocationFrom := NewSource;
        UseLocationCode := NewLocationCode;
    end;

    procedure SetCustomerCreditCheck(Set: Boolean)
    begin
        CustomerCreditCheck := Set;
    end;

    procedure SetPaymentMethod(NewPaymentMethodCode: Code[10])
    begin
        PaymentMethodCode := NewPaymentMethodCode;
    end;

    procedure ProcessPOSSale(var SalePOS: Record "NPR POS Sale")
    var
        SalesHeader: Record "Sales Header";
        SaleLinePOS: Record "NPR POS Sale Line";
        SalesPost: Codeunit "Sales-Post";
        SalesPostYesNo: Codeunit "Sales-Post (Yes/No)";
        TicketManagement: Codeunit "NPR TM Ticket Management";
        Posted: Boolean;
        POSCreateEntry: Codeunit "NPR POS Create Entry";
        POSSalesDocumentOutputMgt: Codeunit "NPR POS Sales Doc. Output Mgt.";
        Post: Boolean;
    begin
        CreateSalesHeader(SalePOS, SalesHeader);

        if CustomerCreditCheck then begin
            DoCustomerCreditCheck(SalesHeader);
        end;

        SaleLinePOS.SetRange("Register No.", SalePOS."Register No.");
        SaleLinePOS.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");

        if SaleLinePOS.FindSet() then begin
            CopySaleCommentLines(SalePOS, SalesHeader);
            CopySalesLines(SaleLinePOS, SalesHeader);
        end;

        if AutoReserveSalesLines then begin
            ReserveSalesLines(SalesHeader, true);
        end;

        Commit();

        if OpenSalesDocAfterExport then begin
            OpenSalesDocCardAndSyncChangesBackToPOSSale(SalesHeader, SalePOS);
            Commit();
        end;

        CreatedSalesHeader := SalesHeader;
        Post := SalesHeader.Invoice or SalesHeader.Receive or SalesHeader.Ship;

        if Post then begin
            if Ask then
                Posted := SalesPostYesNo.Run(SalesHeader)
            else
                Posted := SalesPost.Run(SalesHeader);
        end;

        if Post and (not Posted) then
            Message(POSTING_ERROR, SalesHeader."Document Type", SalesHeader."No.", GetLastErrorText);

        if not (Post and Posted) and SendICOrderConf then
            SendICOrderConfirmation(SalesHeader);

        POSCreateEntry.CreatePOSEntryForCreatedSalesDocument(SalePOS, SalesHeader, Posted);
        SaleLinePOS.DeleteAll();
        SalePOS.Delete();

        Commit();

        if Post and Posted then begin
            if Print then begin
                POSSalesDocumentOutputMgt.SetOnRunOperation(1, 0);
                if not POSSalesDocumentOutputMgt.Run(SalesHeader) then
                    Message(PrintingErrorTxt, GetLastErrorText);
            end;

            if SendDocument then begin
                POSSalesDocumentOutputMgt.SetOnRunOperation(0, 0);
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
            Message(SalesHeaderCreatedLbl, SalesHeader."Document Type", SalesHeader."No.");

        TicketManagement.PrintTicketFromSalesTicketNo(SalePOS."Sales Ticket No.");

        Commit();

        PrintRetailReceipt(SalePOS);

        InvokeOnFinishCreditSaleWorkflow(SalePOS);

        OnAfterDebitSalePostEvent(SalePOS, SalesHeader, Posted);

        Commit();
    end;

    procedure ProcessSalesDocumentAsShipmentInPOSSale(var SalePOS: Record "NPR POS Sale"; var SalesHeader: Record "Sales Header")
    var
        SaleLinePOS: Record "NPR POS Sale Line";
        SalesPost: Codeunit "Sales-Post";
        POSSalesDocumentOutputMgt: Codeunit "NPR POS Sales Doc. Output Mgt.";
        POSCreateEntry: Codeunit "NPR POS Create Entry";
        TicketManagement: Codeunit "NPR TM Ticket Management";
        Posted: Boolean;
    begin
        CreatedSalesHeader := SalesHeader;
        SalesHeader.TestField(Ship);
        Posted := SalesPost.Run(SalesHeader);
        if not Posted then
            Message(POSTING_ERROR, SalesHeader."Document Type", SalesHeader."No.", GetLastErrorText());

        POSCreateEntry.CreatePOSEntryForCreatedSalesDocument(SalePOS, SalesHeader, Posted);

        SaleLinePOS.SetRange("Register No.", SalePOS."Register No.");
        SaleLinePOS.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");
        if not SaleLinePOS.IsEmpty() then
            SaleLinePOS.DeleteAll();
        SalePOS.Delete();

        if Posted then begin
            if Print then
                POSSalesDocumentOutputMgt.PrintDocument(SalesHeader, 0);

            if SendDocument then
                POSSalesDocumentOutputMgt.SendDocument(SalesHeader, 0);

            if SendPostedPdf2Nav then
                POSSalesDocumentOutputMgt.SendPdf2NavDocument(SalesHeader, 0);
            if ShowPostedMessage then
                Message(OrderShippedLbl, SalesHeader."Document Type", SalesHeader."No.", SalesHeader."Last Shipping No.");
        end;

        TicketManagement.PrintTicketFromSalesTicketNo(SalePOS."Sales Ticket No.");

        Commit();

        PrintRetailReceipt(SalePOS);

        InvokeOnFinishCreditSaleWorkflow(SalePOS);
    end;

    procedure CreateSalesHeader(var SalePOS: Record "NPR POS Sale"; var SalesHeader: Record "Sales Header")
    var
        Customer: Record Customer;
        GLSetup: Record "General Ledger Setup";
    begin
        SalesHeader.Init();
        SalesHeader."Document Type" := DocumentType;
        SalesHeader."Document Date" := WorkDate();
        SalesHeader."Posting Date" := Today();
        SalesHeader."Salesperson Code" := SalePOS."Salesperson Code";
        SalesHeader."Sell-to Customer No." := SalePOS."Customer No.";
        SalesHeader.Insert(true);
        if SalePOS."Customer No." <> '' then begin
            SalesHeader.Validate("Sell-to Customer No.", SalePOS."Customer No.");
        end;

        SalesHeader.Validate("Sell-to Customer No.");
        SalesHeader.Validate("Currency Code", '');
        if Customer.Get(SalesHeader."Bill-to Customer No.") then begin
            GLSetup.Get();
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
        SalesHeader."External Document No." := SalePOS."External Document No.";
        SalesHeader.Validate("Location Code", GetLocationCode(SalePOS));
        SalesHeader.Validate("Payment Method Code", PaymentMethodCode);
        SalesHeader.Ship := Ship;
        SalesHeader.Invoice := Invoice;
        SalesHeader.Receive := Receive;

        if OrderTypeSet then
            SalesHeader."NPR Order Type" := OrderType;

        SalesHeader.Validate("Prices Including VAT", SalePOS."Prices Including VAT");

        TransferInfoFromSalePOS(SalePOS, SalesHeader);

        SalesHeader.Modify();
    end;

    procedure CopySaleCommentLines(var SalePOS: Record "NPR POS Sale"; var SalesHeader: Record "Sales Header")
    var
        SalesCommentLine: Record "Sales Comment Line";
        RetailComment: Record "NPR Retail Comment";
    begin
        RetailComment.SetRange("Table ID", DATABASE::"NPR POS Sale");
        RetailComment.SetRange("No.", SalePOS."Register No.");
        RetailComment.SetRange("No. 2", SalePOS."Sales Ticket No.");
        if RetailComment.FindSet() then
            repeat
                SalesCommentLine.Init();
                SalesCommentLine."Document Type" := SalesHeader."Document Type";
                SalesCommentLine."No." := SalesHeader."No.";
                SalesCommentLine."Line No." := RetailComment."Line No.";
                SalesCommentLine.Date := RetailComment.Date;
                SalesCommentLine.Code := RetailComment.Code;
                SalesCommentLine.Comment := RetailComment.Comment;
                SalesCommentLine.Insert(true);
            until RetailComment.Next() = 0;
    end;

    procedure CopySalesLines(var SaleLinePOS: Record "NPR POS Sale Line"; var SalesHeader: Record "Sales Header")
    var
        NpRvSalesLine: Record "NPR NpRv Sales Line";
        SalesLine: Record "Sales Line";
        ReservationEntry: Record "Reservation Entry";
        Item: Record Item;
        SerialNoInfo: Record "Serial No. Information";
        ItemTrackingCode: Record "Item Tracking Code";
        ItemTrackingSetup: Record "Item Tracking Setup";
        ItemTrackingManagement: Codeunit "Item Tracking Management";
    begin
        if SaleLinePOS.FindSet() then
            repeat
                SalesLine.Init();

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
                    SalesLine.Modify();
                end;
                if SaleLinePOS."Serial No." <> '' then begin
                    ReservationEntry.SetCurrentKey("Entry No.", Positive);
                    ReservationEntry.SetRange(Positive, false);
                    if ReservationEntry.Find('+') then;
                    ReservationEntry.Init();
                    ReservationEntry."Entry No." += 1;
                    ReservationEntry.Positive := false;
                    ReservationEntry."Creation Date" := Today();
                    ReservationEntry."Created By" := CopyStr(UserId, 1, MaxStrLen(ReservationEntry."Created By"));
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
                    ReservationEntry.Insert();
                end;
                if Item.Get(SaleLinePOS."No.") then begin
                    if Item."Item Tracking Code" <> '' then begin
                        ItemTrackingCode.Get(Item."Item Tracking Code");
#if BC17                        
                        ItemTrackingManagement.GetItemTrackingSetup(ItemTrackingCode, 1, false, ItemTrackingSetup);
#else
                        ItemTrackingManagement.GetItemTrackingSetup(ItemTrackingCode, "Item Ledger Entry Type"::Sale, false, ItemTrackingSetup);
#endif
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
                NpRvSalesLine.SetRange("Retail ID", SaleLinePOS.SystemId);
                if NpRvSalesLine.FindSet() then
                    repeat
                        NpRvSalesLine."Document Source" := NpRvSalesLine."Document Source"::"Sales Document";
                        NpRvSalesLine."Document Type" := SalesLine."Document Type";
                        NpRvSalesLine."Document No." := SalesLine."Document No.";
                        NpRvSalesLine."Document Line No." := SalesLine."Line No.";
                        NpRvSalesLine.Modify(true);
                    until NpRvSalesLine.Next() = 0;
            until SaleLinePOS.Next() = 0;
    end;

    procedure TestSaleLinePOS(var SaleLinePOS: Record "NPR POS Sale Line")
    begin
        if SaleLinePOS."Sale Type" = SaleLinePOS."Sale Type"::Payment then
            Error(CannotPostPaymentErr);

        if SaleLinePOS."Sales Document No." <> '' then
            Error(OneDocPerSalesTicketErr);

        if (SaleLinePOS.Type = SaleLinePOS.Type::Customer) and
           (SaleLinePOS."Sale Type" = SaleLinePOS."Sale Type"::Deposit) then
            Error(CannotPostPaymentSalesModuleErr);

        if SaleLinePOS."Buffer Document No." <> '' then
            Error(CannotPostPaymentSalesModuleErr);

        if SaleLinePOS.Type = SaleLinePOS.Type::"Item Group" then
            Error(CannotDeleteItemGroupsErr);
    end;

    procedure OpenSalesDoc(var SalePOS: Record "NPR POS Sale")
    var
        SaleLinePOS: Record "NPR POS Sale Line";
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

        if SaleLinePOS.FindSet() then
            repeat
                if SaleLinePOS."Sales Document No." <> '' then begin
                    SalesDocNo := SaleLinePOS."Sales Document No.";
                    DocumentType := SaleLinePOS."Sales Document Type";
                end;
            until (SaleLinePOS.Next() = 0) or (SalesDocNo <> '');

        if SalesDocNo <> '' then begin
            SalesHeader.Get(DocumentType, SalesDocNo);

            if DocumentType = DocumentType::Order then begin
                SalesOrder.SetRecord(SalesHeader);
                SalesOrder.RunModal();
            end;

            if DocumentType = DocumentType::"Credit Memo" then begin
                SalesCreditMemo.SetRecord(SalesHeader);
                SalesCreditMemo.RunModal();
            end;

            if DocumentType = DocumentType::"Blanket Order" then begin
                BlanketSalesOrder.SetRecord(SalesHeader);
                BlanketSalesOrder.RunModal();
            end;

            if DocumentType = DocumentType::"Return Order" then begin
                SalesReturnOrder.SetRecord(SalesHeader);
                SalesReturnOrder.RunModal();
            end;

            if DocumentType = DocumentType::Quote then begin
                SalesQuote.SetRecord(SalesHeader);
                SalesQuote.RunModal();
            end;
        end;
    end;

    procedure TestSalePOS(var SalePOS: Record "NPR POS Sale")
    var
        SaleLinePOS: Record "NPR POS Sale Line";
    begin
        SaleLinePOS.SetRange("Register No.", SalePOS."Register No.");
        SaleLinePOS.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");

        if SaleLinePOS.FindSet() then
            repeat
                TestSaleLinePOS(SaleLinePOS);
            until SaleLinePOS.Next() = 0;
    end;

    local procedure TransferInfoFromSalePOS(var SalePOS: Record "NPR POS Sale"; var SalesHeader: Record "Sales Header")
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

        if TransferTaxSetup then begin
            if SalePOS."Tax Area Code" <> '' then
                SalesHeader.Validate("Tax Area Code", SalePOS."Tax Area Code");
            if SalePOS."Tax Liable" then
                SalesHeader.Validate("Tax Liable", true);
        end;
    end;

    local procedure TransferInfoFromSaleLinePOS(var SaleLinePOS: Record "NPR POS Sale Line"; var SalesLine: Record "Sales Line")
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

    end;

    procedure ReserveSalesLines(var SalesHeader: Record "Sales Header"; WithError: Boolean)
    var
        SalesLine: Record "Sales Line";
        AllLinesReserved: Boolean;
        Item: Record Item;
    begin
        SalesLine.Reset();
        SalesLine.SetFilter("Document Type", '=%1', SalesHeader."Document Type");
        SalesLine.SetFilter("Document No.", '=%1', SalesHeader."No.");
        SalesLine.SetFilter(Type, '=%1', SalesLine.Type::Item);
        SalesLine.SetFilter(Reserve, '<>%1', SalesLine.Reserve::Never);
        AllLinesReserved := true;
        if SalesLine.FindSet() then begin
            repeat
                if not ReserveSaleLine(SalesLine) then begin
                    AllLinesReserved := false;
                    if WithError then
                        Error(RESERVE_FAIL_ERROR, Item.TableCaption, SalesLine."No.", SalesLine.FieldCaption(Quantity), SalesLine.Quantity);
                end;
            until (0 = SalesLine.Next());
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

    local procedure PrintRetailReceipt(SalePOS: Record "NPR POS Sale")
    var
        POSEntry: Record "NPR POS Entry";
        POSEntryManagement: Codeunit "NPR POS Entry Management";
    begin
        if not RetailPrint then
            exit;

        POSEntry.SetRange("Document No.", SalePOS."Sales Ticket No.");
        if not POSEntry.FindFirst() then
            exit;

        ClearLastError();
        clear(POSEntryManagement);
        POSEntryManagement.SetFunctionToRun(1);
        POSEntryManagement.SetLargePrint(false);
        if not POSEntryManagement.Run(POSEntry) then
            Message(RetailPrintErrorTxt, GetLastErrorText);
    end;

    procedure GetCreatedSalesHeader(var CreatedSalesHeaderOut: Record "Sales Header")
    begin
        CreatedSalesHeaderOut := CreatedSalesHeader;
    end;

    local procedure PostPrepaymentBeforePOSSaleEnd(var SalesHeader: Record "Sales Header"; var SaleLinePOS: Record "NPR POS Sale Line")
    var
        SalesPostPrepayments: Codeunit "Sales-Post Prepayments";
        POSPrint: Boolean;
        POSPrepaymentMgt: Codeunit "NPR POS Prepayment Mgt.";
        Send: Boolean;
        Pdf2Nav: Boolean;
        POSSalesDocumentOutputMgt: Codeunit "NPR POS Sales Doc. Output Mgt.";
    begin
        SalesHeader.TestField("Document Type", SalesHeader."Document Type"::Order);

        if SaleLinePOS."Sales Doc. Prepay Is Percent" then
            POSPrepaymentMgt.SetPrepaymentPercentageToPay(SalesHeader, true, SaleLinePOS."Sales Doc. Prepayment Value")
        else
            POSPrepaymentMgt.SetPrepaymentAmountToPayInclVAT(SalesHeader, true, SaleLinePOS."Sales Doc. Prepayment Value");

        Pdf2Nav := SaleLinePOS."Sales Document Pdf2Nav";
        Send := SaleLinePOS."Sales Document Send";
        POSPrint := SaleLinePOS."Sales Document Print";
        SaleLinePOS."Sales Document Prepayment" := false;
        SaleLinePOS."Sales Document Print" := false;
        SaleLinePOS."Sales Document Pdf2Nav" := false;
        SaleLinePOS."Sales Document Send" := false;
        SaleLinePOS.Modify(true);

        SalesPostPrepayments.Invoice(SalesHeader);
        SaleLinePOS."Buffer Document Type" := SaleLinePOS."Buffer Document Type"::Invoice;
        SaleLinePOS."Posted Sales Document Type" := SaleLinePOS."Posted Sales Document Type"::INVOICE;
        SaleLinePOS."Posted Sales Document No." := SalesHeader."Last Prepayment No.";
        SaleLinePOS.Validate("Buffer Document No.", SalesHeader."Last Prepayment No.");
        SaleLinePOS.Modify(true);

        Commit();

        if POSPrint then begin
            POSSalesDocumentOutputMgt.PrintDocument(SalesHeader, 1);
        end;

        if Send then begin
            POSSalesDocumentOutputMgt.SendDocument(SalesHeader, 1);
        end;

        if Pdf2Nav then begin
            POSSalesDocumentOutputMgt.SendPdf2NavDocument(SalesHeader, 1);
        end;
    end;

    local procedure PostPrepaymentRefundBeforePOSSaleEnd(var SalesHeader: Record "Sales Header"; var SaleLinePOS: Record "NPR POS Sale Line")
    var
        SalesPostPrepayments: Codeunit "Sales-Post Prepayments";
        DeleteAfter: Boolean;
        POSPrint: Boolean;
        Send: Boolean;
        Pdf2Nav: Boolean;
        POSSalesDocumentOutputMgt: Codeunit "NPR POS Sales Doc. Output Mgt.";
    begin
        SalesHeader.TestField("Document Type", SalesHeader."Document Type"::Order);
        DeleteAfter := SaleLinePOS."Sales Document Delete";
        POSPrint := SaleLinePOS."Sales Document Print";
        Send := SaleLinePOS."Sales Document Send";
        Pdf2Nav := SaleLinePOS."Sales Document Pdf2Nav";
        SaleLinePOS."Sales Document Prepay. Refund" := false;
        SaleLinePOS."Sales Document Delete" := false;
        SaleLinePOS."Sales Document Print" := false;
        SaleLinePOS."Sales Document Send" := false;
        SaleLinePOS."Sales Document Pdf2Nav" := false;
        SaleLinePOS.Modify(true);

        SalesPostPrepayments.CreditMemo(SalesHeader);
        SaleLinePOS."Posted Sales Document Type" := SaleLinePOS."Posted Sales Document Type"::CREDIT_MEMO;
        SaleLinePOS."Posted Sales Document No." := SalesHeader."Last Prepmt. Cr. Memo No.";
        SaleLinePOS."Buffer Document Type" := SaleLinePOS."Buffer Document Type"::"Credit Memo";
        SaleLinePOS.Validate("Buffer Document No.", SalesHeader."Last Prepmt. Cr. Memo No.");
        SaleLinePOS.Modify(true);

        if DeleteAfter then
            SalesHeader.Delete(true);

        Commit();

        if POSPrint then begin
            POSSalesDocumentOutputMgt.PrintDocument(SalesHeader, 2);
        end;

        if Send then begin
            POSSalesDocumentOutputMgt.SendDocument(SalesHeader, 2);
        end;

        if Pdf2Nav then begin
            POSSalesDocumentOutputMgt.SendPdf2NavDocument(SalesHeader, 2);
        end;
    end;

    local procedure PostDocumentBeforePOSSaleEnd(var SalesHeader: Record "Sales Header"; var SaleLinePOS: Record "NPR POS Sale Line")
    var
        SalesPost: Codeunit "Sales-Post";
        POSPrint: Boolean;
        Send: Boolean;
        Pdf2Nav: Boolean;
        POSSalesDocumentOutputMgt: Codeunit "NPR POS Sales Doc. Output Mgt.";
    begin
        if not (SalesHeader."Document Type" in [SalesHeader."Document Type"::Invoice, SalesHeader."Document Type"::Order, SalesHeader."Document Type"::"Credit Memo", SalesHeader."Document Type"::"Return Order"]) then
            SalesHeader.FieldError("Document Type");
        SalesHeader.Ship := SaleLinePOS."Sales Document Ship";
        SalesHeader.Invoice := SaleLinePOS."Sales Document Invoice";
        SalesHeader.Receive := SaleLinePOS."Sales Document Receive";
        SalesHeader.Modify(true);
        POSPrint := SaleLinePOS."Sales Document Print";
        Send := SaleLinePOS."Sales Document Send";
        Pdf2Nav := SaleLinePOS."Sales Document Pdf2Nav";

        SaleLinePOS."Sales Document Invoice" := false;
        SaleLinePOS."Sales Document Ship" := false;
        SaleLinePOS."Sales Document Receive" := false;
        SaleLinePOS."Sales Document Print" := false;
        SaleLinePOS."Sales Document Send" := false;
        SaleLinePOS."Sales Document Pdf2Nav" := false;
        SaleLinePOS.Modify(true);

        SalesPost.Run(SalesHeader);

        if SalesHeader.Invoice then begin
            case SalesHeader."Document Type" of
                SalesHeader."Document Type"::Invoice:
                    begin
                        SaleLinePOS."Buffer Document Type" := SaleLinePOS."Buffer Document Type"::Invoice;
                        if SalesHeader."Last Posting No." <> '' then
                            SaleLinePOS.Validate("Buffer Document No.", SalesHeader."Last Posting No.")
                        else
                            SaleLinePOS.Validate("Buffer Document No.", SalesHeader."No.");
                        SaleLinePOS."Posted Sales Document Type" := SaleLinePOS."Posted Sales Document Type"::INVOICE;
                        SaleLinePOS."Posted Sales Document No." := SaleLinePOS."Buffer Document No.";
                    end;
                SalesHeader."Document Type"::Order:
                    begin
                        SaleLinePOS."Buffer Document Type" := SaleLinePOS."Buffer Document Type"::Invoice;
                        SaleLinePOS.Validate("Buffer Document No.", SalesHeader."Last Posting No.");
                        SaleLinePOS."Posted Sales Document Type" := SaleLinePOS."Posted Sales Document Type"::INVOICE;
                        SaleLinePOS."Posted Sales Document No." := SaleLinePOS."Buffer Document No.";
                    end;
                SalesHeader."Document Type"::"Credit Memo":
                    begin
                        SaleLinePOS."Buffer Document Type" := SaleLinePOS."Buffer Document Type"::"Credit Memo";
                        if SalesHeader."Last Posting No." <> '' then
                            SaleLinePOS.Validate("Buffer Document No.", SalesHeader."Last Posting No.")
                        else
                            SaleLinePOS.Validate("Buffer Document No.", SalesHeader."No.");
                        SaleLinePOS."Posted Sales Document Type" := SaleLinePOS."Posted Sales Document Type"::CREDIT_MEMO;
                        SaleLinePOS."Posted Sales Document No." := SaleLinePOS."Buffer Document No.";
                    end;
                SalesHeader."Document Type"::"Return Order":
                    begin
                        SaleLinePOS."Buffer Document Type" := SaleLinePOS."Buffer Document Type"::"Credit Memo";
                        SaleLinePOS.Validate("Buffer Document No.", SalesHeader."Last Posting No.");
                        SaleLinePOS."Posted Sales Document Type" := SaleLinePOS."Posted Sales Document Type"::CREDIT_MEMO;
                        SaleLinePOS."Posted Sales Document No." := SaleLinePOS."Buffer Document No.";
                    end;
            end;
        end;

        if SalesHeader.Ship then begin
            SaleLinePOS."Delivered Sales Document Type" := SaleLinePOS."Delivered Sales Document Type"::SHIPMENT;
            SaleLinePOS."Delivered Sales Document No." := SalesHeader."Last Shipping No.";
        end;
        if SalesHeader.Receive then begin
            SaleLinePOS."Delivered Sales Document Type" := SaleLinePOS."Delivered Sales Document Type"::RETURN_RECEIPT;
            SaleLinePOS."Delivered Sales Document No." := SalesHeader."Last Return Receipt No.";
        end;

        SaleLinePOS.Modify(true);
        Commit();

        if POSPrint then begin
            POSSalesDocumentOutputMgt.PrintDocument(SalesHeader, 0);
        end;

        if Send then begin
            POSSalesDocumentOutputMgt.SendDocument(SalesHeader, 0);
        end;

        if Pdf2Nav then begin
            POSSalesDocumentOutputMgt.SendPdf2NavDocument(SalesHeader, 0);
        end;
    end;

    procedure CreatePrepaymentLine(var POSSession: Codeunit "NPR POS Session"; var SalesHeader: Record "Sales Header"; PrepaymentValue: Decimal; Print: Boolean; Send: Boolean; Pdf2Nav: Boolean; SyncPosting: Boolean; ValueIsAmount: Boolean)
    var
        PrepaymentAmount: Decimal;
        POSSale: Codeunit "NPR POS Sale";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        SalePOS: Record "NPR POS Sale";
        SaleLinePOS: Record "NPR POS Sale Line";
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
        SalePOS: Record "NPR POS Sale";
        SaleLinePOS: Record "NPR POS Sale Line";
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
        SalePOS: Record "NPR POS Sale";
        SaleLinePOS: Record "NPR POS Sale Line";
        SalesHeader: Record "Sales Header";
    begin
        //Error in this subscriber will block end-of-sale, but if we have several associated sales docs, some of them might post with commit before an error.

        POSSession.GetSale(POSSale);
        POSSession.GetSaleLine(POSSaleLine);
        POSSale.GetCurrentSale(SalePOS);

        SaleLinePOS.SetRange("Register No.", SalePOS."Register No.");
        SaleLinePOS.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");
        SaleLinePOS.SetRange("Sales Document Sync. Posting", true);
        SaleLinePOS.SetFilter("Sales Document No.", '<>%1', '');
        if not SaleLinePOS.FindSet() then
            exit;

        repeat
            if SalesHeader.Get(SaleLinePOS."Sales Document Type", SaleLinePOS."Sales Document No.") then begin
                case true of
                    SaleLinePOS."Sales Document Prepayment":
                        PostPrepaymentBeforePOSSaleEnd(SalesHeader, SaleLinePOS);

                    SaleLinePOS."Sales Document Prepay. Refund":
                        PostPrepaymentRefundBeforePOSSaleEnd(SalesHeader, SaleLinePOS);

                    SaleLinePOS."Sales Document Ship",
                    SaleLinePOS."Sales Document Receive",
                    SaleLinePOS."Sales Document Invoice":
                        PostDocumentBeforePOSSaleEnd(SalesHeader, SaleLinePOS);
                end;
            end;
        until SaleLinePOS.Next() = 0;

        POSSaleLine.RefreshCurrent();
    end;

    local procedure OpenSalesDocCardAndSyncChangesBackToPOSSale(var SalesHeader: Record "Sales Header"; var SalePOS: Record "NPR POS Sale")
    var
        SalesHeader2: Record "Sales Header";
        ApplySalespersontoDocument: Codeunit "NPR Apply Salesperson to Doc.";
        PageMgt: Codeunit "Page Management";
    begin
        SalesHeader2 := SalesHeader;
        SalesHeader2.SetRecFilter();

        ApplySalespersontoDocument.SetCode(SalePOS."Salesperson Code");
        BindSubscription(ApplySalespersontoDocument);
        Page.RunModal(PageMgt.GetPageID(SalesHeader2), SalesHeader2);
        UnbindSubscription(ApplySalespersontoDocument);

        if not SalesHeader.Get(SalesHeader."Document Type", SalesHeader."No.") then
            Error(ERR_DOC_MISSING, SalesHeader."Document Type", SalesHeader."No."); //If user deleted/posted etc.

        Commit();
        UpdateActiveSaleWithDocumentChanges(SalesHeader, SalePOS);
    end;

    local procedure UpdateActiveSaleWithDocumentChanges(SalesHeader: Record "Sales Header"; var SalePOS: Record "NPR POS Sale")
    var
        ImportSalesDocInPOS: Codeunit "NPR Import Sales Doc. In POS";
    begin
        SalePOS."Sales Document Type" := SalesHeader."Document Type";
        SalePOS."Sales Document No." := SalesHeader."No.";

        if not ImportSalesDocInPOS.Run(SalePOS) then
            Error(ERR_ORDER_SALE_SYNC, SalesHeader."Document Type", SalesHeader."No.", GetLastErrorText);

        SalePOS.Get(SalePOS."Register No.", SalePOS."Sales Ticket No.");
    end;

    local procedure GetLocationCode(SalePOS: Record "NPR POS Sale"): Code[10]
    var
        POSStore: Record "NPR POS Store";
        POSUnit: Record "NPR POS Unit";
    begin
        case UseLocationFrom of
            UseLocationFrom::"POS Unit":
                begin
                    POSUnit.Get(SalePOS."Register No.");
                    POSStore.Get(POSUnit."POS Store Code");
                    exit(POSStore."Location Code");
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
        if not (
    (SalesHeader."Document Type" in [SalesHeader."Document Type"::Order, SalesHeader."Document Type"::"Return Order"]) and
    (SalesHeader."IC Status" = SalesHeader."IC Status"::New) and SalesHeader."Send IC Document")
then
            exit;

        if (SalesHeader.Status = SalesHeader.Status::Open) and ApprovalsMgmt.IsSalesApprovalsWorkflowEnabled(SalesHeader) then  //must go through approval workflow first
            exit;

        if SalesHeader."Sell-to IC Partner Code" <> '' then
            ICPartner.Get(SalesHeader."Sell-to IC Partner Code")
        else
            ICPartner.Get(SalesHeader."Bill-to IC Partner Code");
        if ICPartner."Inbox Type" = ICPartner."Inbox Type"::"No IC Transfer" then
            exit;

        ICInOutboxMgt.SendSalesDoc(SalesHeader, false);
    end;

    local procedure DoCustomerCreditCheck(SalesHeader: Record "Sales Header")
    var
        CustCheckCrLimit: Codeunit "Cust-Check Cr. Limit";
    begin
        if CustCheckCrLimit.SalesHeaderCheck(SalesHeader) then
            error(CUSTOMER_CREDIT_CHECK_FAILED);
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Sales Workflow", 'OnDiscoverPOSSalesWorkflows', '', true, false)]
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

    local procedure InvokeOnFinishCreditSaleWorkflow(SalePOS: Record "NPR POS Sale")
    var
        POSUnit: Record "NPR POS Unit";
        POSSalesWorkflowSetEntry: Record "NPR POS Sales WF Set Entry";
        POSSalesWorkflowStep: Record "NPR POS Sales Workflow Step";
        CreditSalePostProcessing: Codeunit "NPR Credit Sale Post-Process";
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
        if not POSSalesWorkflowStep.FindSet() then
            exit;

        repeat
            Clear(CreditSalePostProcessing);
            CreditSalePostProcessing.SetInvokeOnFinishCreditSaleSubsribers(POSSalesWorkflowStep);
            if CreditSalePostProcessing.Run(SalePOS) then;
        until POSSalesWorkflowStep.Next() = 0;
    end;

    [IntegrationEvent(true, false)]
    local procedure OnAfterDebitSalePostEvent(SalePOS: Record "NPR POS Sale"; SalesHeader: Record "Sales Header"; Posted: Boolean)
    begin
    end;
}