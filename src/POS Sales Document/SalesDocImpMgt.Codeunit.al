codeunit 6014406 "NPR Sales Doc. Imp. Mgt."
{
    // NPR5.50/MMV /20190321 CASE 300557 Refactored.
    // NPR5.50/MMV /20190606 CASE 352473 Correct sign on return sales document amounts.
    // NPR5.52/MMV /20191002 CASE 352473 Fixed prepayment VAT & amount dialog bugs.
    // NPR5.53/MMV /20191219 CASE 377510 Support for importing document silently to sync with document changes.
    // NPR5.53/MMV /20191220 CASE 375290 Calculate amount to be invoiced correctly. Support split posting in SalesDocumentAmountToPOS()

    TableNo = "NPR Sale POS";

    trigger OnRun()
    var
        SalesHeader: Record "Sales Header";
        OrderTypeText: Text;
    begin
        case true of
            StrPos(Parameters, 'IMPORT_SALESQUOTE') > 0:
                begin
                    DocumentType := DocumentType::Quote;
                    SalesDocumentToPOSLegacy(Rec, DocumentType);
                end;
            StrPos(Parameters, 'IMPORT_SALESINVOICE') > 0:
                begin
                    DocumentType := DocumentType::Invoice;
                    SalesDocumentToPOSLegacy(Rec, DocumentType);
                end;
            StrPos(Parameters, 'IMPORT_SALESORDER_DEL') > 0:
                begin
                    DocumentType := DocumentType::Order;
                    SetDeleteDocumentOnImport(true, false);
                    SalesDocumentToPOSLegacy(Rec, DocumentType);
                end;
            StrPos(Parameters, 'IMPORT_SALESORDER') > 0:
                begin
                    DocumentType := DocumentType::Order;
                    SalesDocumentToPOSLegacy(Rec, DocumentType);
                end;
            StrPos(Parameters, 'IMPORT_CREDITMEMO') > 0:
                begin
                    DocumentType := DocumentType::"Credit Memo";
                    SalesDocumentToPOSLegacy(Rec, DocumentType);
                end;
            StrPos(Parameters, 'IMPORT_RETURNORDER') > 0:
                begin
                    DocumentType := DocumentType::"Return Order";
                    SalesDocumentToPOSLegacy(Rec, DocumentType);
                end;
            StrPos(Parameters, 'IMPORT_SO_AMT') > 0:
                begin
                    DocumentType := DocumentType::Order;
                    SalesDocumentAmountToPOSLegacy(Rec, DocumentType);
                end;
            StrPos(Parameters, 'IMPORT_ORD_TYPE') > 0:
                begin
                    OrderTypeSet := true;
                    OrderTypeText := CopyStr(Parameters, StrLen('IMPORT_ORD_TYPE?') + 1);
                    if OrderTypeText <> '' then
                        Evaluate(OrderType, OrderTypeText)
                    else
                        OrderType := 0;
                end;
            //-NPR5.53 [377510]
            StrPos(Parameters, 'IMPORT_DOCUMENT_SYNC') > 0:
                begin
                    SynchronizePOSSaleWithDocument(Rec);
                end;
            //+NPR5.53 [377510]
            else
                Error('')
        end;
    end;

    var
        DocumentType: Option Quote,"Order",Invoice,"Credit Memo","Blanket Order","Return Order";
        Text001: Label 'Remaining Amount for %1 %2';
        Text002: Label 'Received from %1 %2';
        OrderType: Integer;
        OrderTypeSet: Boolean;
        ERRORDERTYPE: Label 'Wrong Order Type. Order Type is set to %1. It must be one of %2, %3, %4.';
        DeleteDocumentOnImportToPOS: Boolean;
        ConfirmDeleteDocumentOnImportToPOS: Boolean;
        TextConfDocDelete: Label 'Do you want to delete existing %1 - %2 ?';
        TextMsgDocDelete: Label 'Please note that %1 %2 has been deleted';
        PREPAYMENT: Label 'Prepayment for %1 %2';
        ERR_DUPLICATE_DOCUMENT: Label 'Only one sales document can be processed per sale.';
        DOCUMENT_IMPORTED_DELETED: Label '%1 %2 was imported in POS. The document has been deleted.';
        DOCUMENT_IMPORTED: Label '%1 %2 was imported in POS.';
        ERR_DOCUMENT_POSTED_LINE: Label '%1 %2 has partially posted lines. Aborting action.';
        DOCUMENT_FULL_AMOUNT: Label 'Remaining Amount for %1 %2';
        DOCUMENT_SPLIT_AMOUNT: Label 'Amount for %1 %2';

    procedure SalesDocumentToPOSLegacy(var SalePOS: Record "NPR Sale POS"; DocumentTypeIn: Option Quote,"Order",Invoice,"Credit Memo","Blanket Order","Return Order")
    var
        CustLedgerEntry: Record "Cust. Ledger Entry";
        SaleLinePOS: Record "NPR Sale Line POS";
        SalesLine: Record "Sales Line";
        SalesHeader: Record "Sales Header";
        SalesList: Page "Sales List";
        LineNo: Integer;
        txtDeposit: Label 'Deposit';
        ErrDoubleOrder: Label 'Error. Only one sales order can be processed per sale.';
    begin
        //SalesDocumentToPOS
        SaleLinePOS.SetRange("Register No.", SalePOS."Register No.");
        SaleLinePOS.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");
        SaleLinePOS.SetRange(Date, SalePOS.Date);
        if SaleLinePOS.FindLast then
            LineNo := SaleLinePOS."Line No." + 10000
        else
            LineNo := 10000;

        //-NPR5.48 [300557]
        // SaleLinePOS.SETFILTER("Buffer Document No.",'<>%1','');
        // IF SaleLinePOS.FINDSET THEN
        //  ERROR(ErrDoubleOrder);
        if DocumentIsAttachedToPOSSale(SalePOS) then
            Error(ERR_DUPLICATE_DOCUMENT);
        //+NPR5.48 [300557]

        SalesHeader.SetRange("Document Type", DocumentTypeIn);
        SalesHeader.SetRange(Status, SalesHeader.Status::Open);
        if OrderTypeSet then
            SalesHeader.SetRange("NPR Order Type", OrderType);

        SalesList.SetTableView(SalesHeader);
        SalesList.LookupMode(true);
        if SalesList.RunModal <> ACTION::LookupOK then
            exit
        else
            SalesList.GetRecord(SalesHeader);

        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.SetRange("Document No.", SalesHeader."No.");

        if SalesHeader."Sell-to Customer No." <> '' then
            SalePOS.Validate("Customer No.", SalesHeader."Sell-to Customer No.");

        SalePOS."Sales Document Type" := SalesHeader."Document Type";
        SalePOS."Sales Document No." := SalesHeader."No.";
        SalePOS.Validate("Prices Including VAT", SalesHeader."Prices Including VAT");
        SalePOS.Validate("Location Code", SalesHeader."Location Code");
        SalePOS.Modify;

        if SalesLine.FindSet then
            repeat
                SalesLine.TestField("Qty. Shipped Not Invoiced", 0);
                SalesLine.TestField("Return Qty. Received", 0);
                SaleLinePOS.Init;
                SaleLinePOS.Silent := true;
                SaleLinePOS.Validate("Register No.", SalePOS."Register No.");
                SaleLinePOS.Validate("Sales Ticket No.", SalePOS."Sales Ticket No.");
                SaleLinePOS.Validate(Date, SalePOS.Date);

                case SalesLine.Type of
                    SalesLine.Type::Item:
                        begin
                            SaleLinePOS.Type := SaleLinePOS.Type::Item;
                            SaleLinePOS."Sale Type" := SaleLinePOS."Sale Type"::Sale;
                        end;
                    SalesLine.Type::" ":
                        begin
                            SaleLinePOS.Type := SaleLinePOS.Type::Comment;
                            SaleLinePOS.Description := SalesLine.Description;
                        end;
                end;

                if SaleLinePOS.Type <> SaleLinePOS.Type::Comment then
                    SaleLinePOS.Validate("No.", SalesLine."No.");

                SaleLinePOS.Description := SalesLine.Description;
                //-NPR5.50 [300557]
                //  SaleLinePOS."Buffer Ref. No."         := SalesLine."Line No.";
                //  SaleLinePOS."Buffer Document Type"    := SalesLine."Document Type";
                //  SaleLinePOS."Buffer Document No."     := SalesLine."Document No.";
                //-NPR5.50 [300557]
                SaleLinePOS."Description 2" := SalesLine."Description 2";
                SaleLinePOS."Variant Code" := SalesLine."Variant Code";
                SaleLinePOS."Line No." := LineNo;
                SaleLinePOS."Order No. from Web" := SalesLine."Document No.";
                SaleLinePOS."Order Line No. from Web" := SalesLine."Line No.";

                if SaleLinePOS.Type = SaleLinePOS.Type::Item then
                    //-NPR5.48 [335967]
                    //SaleLinePOS.VALIDATE("Unit of Measure Code");
                    SaleLinePOS.Validate("Unit of Measure Code", SalesLine."Unit of Measure Code");
                //+NPR5.48 [335967]

                SaleLinePOS.Insert(true);
                SaleLinePOS.Silent := false;

                if SalesHeader."Document Type" in [SalesHeader."Document Type"::"Return Order", SalesHeader."Document Type"::"Credit Memo"] then
                    SaleLinePOS.Validate(Quantity, -SalesLine.Quantity)
                else
                    SaleLinePOS.Validate(Quantity, SalesLine.Quantity);

                SaleLinePOS.Validate("Unit Price", SalesLine."Unit Price");

                SaleLinePOS."Bin Code" := SalesLine."Bin Code";
                SaleLinePOS."Location Code" := SalesLine."Location Code";
                SaleLinePOS."Shortcut Dimension 1 Code" := SalesLine."Shortcut Dimension 1 Code";
                SaleLinePOS."Shortcut Dimension 2 Code" := SalesLine."Shortcut Dimension 2 Code";

                SaleLinePOS.Validate("Discount Type", SalesLine."NPR Discount Type");
                SaleLinePOS.Validate("Discount Code", SalesLine."NPR Discount Code");

                SaleLinePOS.Validate("Allow Line Discount", SalesLine."Allow Line Disc.");
                SaleLinePOS.Validate("Discount %", SalesLine."Line Discount %");
                SaleLinePOS.Validate("Discount Amount", SalesLine."Line Discount Amount");

                SaleLinePOS.Validate("Allow Invoice Discount", SalesLine."Allow Invoice Disc.");
                SaleLinePOS.Validate("Invoice Discount Amount", SalesLine."Inv. Discount Amount");
                SaleLinePOS.Modify;
                LineNo += 10000;
            until SalesLine.Next = 0;

        //-NPR5.32 [268218]
        if DeleteDocumentOnImportToPOS then begin
            if ConfirmDeleteDocumentOnImportToPOS then begin
                if Confirm(TextConfDocDelete, true, SalesHeader."Document Type", SalesHeader."No.") then begin
                    SalesHeader.Delete(true);
                    SalePOS."Sales Document Type" := 0;
                    SalePOS."Sales Document No." := '';
                    SalePOS.Modify;
                end;
            end else begin
                //-NPR5.34
                Message(StrSubstNo(TextMsgDocDelete, SalesHeader."Document Type", SalesHeader."No."));
                //+NPR5.34
                SalesHeader.Delete(true);
                SalePOS."Sales Document Type" := 0;
                SalePOS."Sales Document No." := '';
                SalePOS.Modify;
            end;
        end;
        //+NPR5.32 [268218]
    end;

    procedure SalesDocumentAmountToPOSLegacy(var SalePOS: Record "NPR Sale POS"; DocumentTypeIn: Option Quote,"Order",Invoice,"Credit Memo","Blanket Order","Return Order")
    var
        CustLedgerEntry: Record "Cust. Ledger Entry";
        SaleLinePOS: Record "NPR Sale Line POS";
        SalesLine: Record "Sales Line";
        SalesHeader: Record "Sales Header";
        SalesList: Page "Sales List";
        PaymentAmount: Decimal;
        LineNo: Integer;
        txtDeposit: Label 'Deposit';
        ErrDoubleOrder: Label 'Error. Only one sales order can be processed per sale.';
        PrepaymentAmount: Decimal;
        ReceivedFromSaleLinePOS: Record "NPR Sale Line POS";
    begin
        //-NPR4.14
        SaleLinePOS.SetCurrentKey("Register No.", "Sales Ticket No.", "Line No.");
        SaleLinePOS.SetRange("Register No.", SalePOS."Register No.");
        SaleLinePOS.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");
        if SaleLinePOS.FindLast then
            LineNo := SaleLinePOS."Line No." + 10000
        else
            LineNo := 10000;

        //-NPR5.48 [300557]
        // SaleLinePOS.SETFILTER("Buffer Document No.",'<>%1','');
        // IF SaleLinePOS.FINDSET THEN
        //  ERROR(ErrDoubleOrder);
        if DocumentIsAttachedToPOSSale(SalePOS) then
            Error(ERR_DUPLICATE_DOCUMENT);
        //+NPR5.48 [300557]

        SalesHeader.SetRange("Document Type", DocumentTypeIn);
        if OrderTypeSet then
            SalesHeader.SetRange("NPR Order Type", OrderType);
        SalesList.SetTableView(SalesHeader);
        SalesList.LookupMode(true);
        if SalesList.RunModal <> ACTION::LookupOK then
            exit
        else
            SalesList.GetRecord(SalesHeader);

        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.SetRange("Document No.", SalesHeader."No.");

        SalePOS.Validate("Customer No.", SalesHeader."Bill-to Customer No.");
        SalePOS."Sales Document Type" := SalesHeader."Document Type";
        SalePOS."Sales Document No." := SalesHeader."No.";
        SalePOS.Validate("Prices Including VAT", SalesHeader."Prices Including VAT");
        SalePOS.Validate("Location Code", SalesHeader."Location Code");
        SalePOS.Modify;

        if SalesLine.FindSet then begin
            SaleLinePOS.Init;
            SaleLinePOS."Register No." := SalePOS."Register No.";
            SaleLinePOS."Sales Ticket No." := SalePOS."Sales Ticket No.";
            SaleLinePOS."Line No." := LineNo;
            SaleLinePOS."Sale Type" := SaleLinePOS."Sale Type"::Comment;
            SaleLinePOS.Type := SaleLinePOS.Type::Comment;
            SaleLinePOS.Date := SalePOS.Date;
            SaleLinePOS.Description := StrSubstNo(Text002, SalesHeader."Document Type", SalesHeader."No.") + ':';
            SaleLinePOS.Validate(Quantity, 1);
            SaleLinePOS.Insert(true);
            //-NPR5.40 [305414]
            ReceivedFromSaleLinePOS := SaleLinePOS;
            //+NPR5.40 [305414]
            LineNo += 10000;
            repeat
                SalesLine.TestField("Qty. Shipped Not Invoiced", 0);
                SalesLine.TestField("Return Qty. Received", 0);
                SaleLinePOS.Init;
                SaleLinePOS.Silent := true;
                SaleLinePOS.Validate("Register No.", SalePOS."Register No.");
                SaleLinePOS.Validate("Sales Ticket No.", SalePOS."Sales Ticket No.");
                SaleLinePOS.Validate(Date, SalePOS.Date);
                SaleLinePOS.Type := SaleLinePOS.Type::Comment;
                SaleLinePOS.Description := SalesLine.Description;
                //-NPR5.50 [300557]
                //    SaleLinePOS."Buffer Ref. No."         := SalesLine."Line No.";
                //    SaleLinePOS."Buffer Document Type"    := SalesLine."Document Type";
                //    SaleLinePOS."Buffer Document No."     := SalesLine."Document No.";
                //+NPR5.50 [300557]
                SaleLinePOS."Description 2" := SalesLine."Description 2";
                SaleLinePOS."Variant Code" := SalesLine."Variant Code";
                SaleLinePOS."Line No." := LineNo;
                SaleLinePOS."Order No. from Web" := SalesLine."Document No.";
                SaleLinePOS."Order Line No. from Web" := SalesLine."Line No.";
                SaleLinePOS.Validate(Quantity, SalesLine.Quantity);
                SaleLinePOS.Insert(true);
                SaleLinePOS.Type := SaleLinePOS.Type::Comment;
                SaleLinePOS.Silent := false;
                SaleLinePOS.Validate("Unit Price", SalesLine."Unit Price");
                SaleLinePOS."Bin Code" := SalesLine."Bin Code";
                SaleLinePOS."Location Code" := SalesLine."Location Code";
                SaleLinePOS."Shortcut Dimension 1 Code" := SalesLine."Shortcut Dimension 1 Code";
                SaleLinePOS."Shortcut Dimension 2 Code" := SalesLine."Shortcut Dimension 2 Code";
                SaleLinePOS."Sales Document Type" := SalesHeader."Document Type";
                SaleLinePOS."Sales Document No." := SalesHeader."No.";
                SaleLinePOS.Modify;
                LineNo += 10000;
                PaymentAmount := PaymentAmount + (SalesLine."Amount Including VAT" - SalesLine."Prepmt. Amount Inv. Incl. VAT");
                //-NPR5.40 [305414]
                PrepaymentAmount += SalesLine."Prepmt. Amount Inv. Incl. VAT";
            //+NPR5.40 [305414]
            until SalesLine.Next = 0;
            //-NPR5.40 [305414]
            if PrepaymentAmount <> 0 then begin
                ReceivedFromSaleLinePOS.Validate("Unit Price", PrepaymentAmount);
                ReceivedFromSaleLinePOS.Modify(true);
            end;
            //+NPR5.40 [305414]
        end;

        if PaymentAmount <> 0 then begin
            SaleLinePOS.Init;
            SaleLinePOS."Register No." := SalePOS."Register No.";
            SaleLinePOS."Sales Ticket No." := SalePOS."Sales Ticket No.";
            SaleLinePOS.Date := SalePOS.Date;
            SaleLinePOS."Sale Type" := SaleLinePOS."Sale Type"::Deposit;
            SaleLinePOS."Line No." := SaleLinePOS."Line No." + 1;
            SaleLinePOS.Type := SaleLinePOS.Type::Customer;
            SaleLinePOS.Date := SalePOS.Date;
            SaleLinePOS.Insert(true);
            SalePOS.Validate("Customer No.", SalesHeader."Bill-to Customer No.");
            SaleLinePOS.Validate(Quantity, 1);
            SaleLinePOS.Validate("No.", SalesHeader."Bill-to Customer No.");
            SaleLinePOS."Sales Document Type" := SalesHeader."Document Type";
            SaleLinePOS."Sales Document No." := SalesHeader."No.";
            SaleLinePOS."Sales Document Invoice" := true;
            SaleLinePOS."Sales Document Ship" := true;
            SaleLinePOS.Validate("Unit Price", PaymentAmount);
            SaleLinePOS.Description := StrSubstNo(Text001, SalesHeader."Document Type", SalesHeader."No.");
            SaleLinePOS.Modify(true);
        end;
        //+NPR4.14

        //-NPR5.32 [268218]
        if DeleteDocumentOnImportToPOS then begin
            if ConfirmDeleteDocumentOnImportToPOS then begin
                if Confirm(TextConfDocDelete, true, SalesHeader."Document Type", SalesHeader."No.") then SalesHeader.Delete(true);
            end else begin
                //-NPR5.34 [279215]
                Message(StrSubstNo(TextMsgDocDelete, SalesHeader."Document Type", SalesHeader."No."));
                //+NPR5.34
                SalesHeader.Delete(true);
            end;
        end;
        //+NPR5.32 [268218]
    end;

    procedure SalesDocumentToPOS(var POSSession: Codeunit "NPR POS Session"; var SalesHeader: Record "Sales Header")
    var
        txtDeposit: Label 'Deposit';
        ErrDoubleOrder: Label 'Error. Only one sales order can be processed per sale.';
    begin
        //-NPR5.53 [377510]
        SalesDocumentToPOSCustom(POSSession, SalesHeader, true, true);
        //+NPR5.53 [377510]
    end;

    procedure SalesDocumentToPOSCustom(var POSSession: Codeunit "NPR POS Session"; var SalesHeader: Record "Sales Header"; DeleteDocument: Boolean; ShowSuccessMessage: Boolean)
    var
        SaleLinePOS: Record "NPR Sale Line POS";
        SalesLine: Record "Sales Line";
        txtDeposit: Label 'Deposit';
        ErrDoubleOrder: Label 'Error. Only one sales order can be processed per sale.';
        POSSale: Codeunit "NPR POS Sale";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        SalePOS: Record "NPR Sale POS";
    begin
        //-NPR5.53 [377510]
        POSSession.GetSale(POSSale);
        POSSession.GetSaleLine(POSSaleLine);
        POSSale.GetCurrentSale(SalePOS);

        SalePOS.TestField("Customer Type", SalePOS."Customer Type"::Ord);
        SalePOS.TestField("Customer No.", SalesHeader."Bill-to Customer No.");

        if DocumentIsAttachedToPOSSale(SalePOS) then
            Error(ERR_DUPLICATE_DOCUMENT);

        if DocumentIsPartiallyPosted(SalesHeader) then
            Error(ERR_DOCUMENT_POSTED_LINE, SalesHeader."Document Type", SalesHeader."No.");

        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        SalesLine.SetFilter(Type, '%1|%2', SalesLine.Type::Item, SalesLine.Type::" ");
        SalesLine.FindSet;

        repeat
            POSSaleLine.GetNewSaleLine(SaleLinePOS);

            SaleLinePOS.SetSkipCalcDiscount(true); //Prevent overwrite of any discounts from sales document, until lines are added,deleted,removed.
            SaleLinePOS.Silent := true;

            case SalesLine.Type of
                SalesLine.Type::Item:
                    begin
                        SaleLinePOS.Type := SaleLinePOS.Type::Item;
                        SaleLinePOS."Sale Type" := SaleLinePOS."Sale Type"::Sale;
                        SaleLinePOS.Validate("No.", SalesLine."No.");
                        SaleLinePOS.Validate("Unit of Measure Code", SalesLine."Unit of Measure Code");
                    end;
                SalesLine.Type::" ":
                    begin
                        SaleLinePOS.Type := SaleLinePOS.Type::Comment;
                        SaleLinePOS.Description := SalesLine.Description;
                    end;
            end;

            SaleLinePOS.Silent := false;

            SaleLinePOS.Description := SalesLine.Description;
            SaleLinePOS."Description 2" := SalesLine."Description 2";
            SaleLinePOS."Variant Code" := SalesLine."Variant Code";

            if SalesHeader."Document Type" in [SalesHeader."Document Type"::"Return Order", SalesHeader."Document Type"::"Credit Memo"] then
                SaleLinePOS.Validate(Quantity, -SalesLine.Quantity)
            else
                SaleLinePOS.Validate(Quantity, SalesLine.Quantity);

            SaleLinePOS.Validate("Unit Price", SalesLine."Unit Price");
            SaleLinePOS."Bin Code" := SalesLine."Bin Code";
            SaleLinePOS."Location Code" := SalesLine."Location Code";
            SaleLinePOS."Shortcut Dimension 1 Code" := SalesLine."Shortcut Dimension 1 Code";
            SaleLinePOS."Shortcut Dimension 2 Code" := SalesLine."Shortcut Dimension 2 Code";
            SaleLinePOS.Validate("Discount Type", SalesLine."NPR Discount Type");
            SaleLinePOS.Validate("Discount Code", SalesLine."NPR Discount Code");
            SaleLinePOS.Validate("Allow Line Discount", SalesLine."Allow Line Disc.");
            SaleLinePOS.Validate("Discount %", SalesLine."Line Discount %");
            SaleLinePOS.Validate("Discount Amount", SalesLine."Line Discount Amount");

            SaleLinePOS.Validate("Allow Invoice Discount", SalesLine."Allow Invoice Disc.");
            SaleLinePOS.Validate("Invoice Discount Amount", SalesLine."Inv. Discount Amount");

            SaleLinePOS.UpdateAmounts(SaleLinePOS);
            POSSaleLine.InsertLineRaw(SaleLinePOS, false);
            SaleLinePOS.SetSkipCalcDiscount(false);
        until SalesLine.Next = 0;

        if DeleteDocument then begin
            SalesHeader.Delete(true);
        end;

        Commit;

        if ShowSuccessMessage then begin
            if DeleteDocument then
                Message(StrSubstNo(DOCUMENT_IMPORTED_DELETED, SalesHeader."Document Type", SalesHeader."No."))
            else
                Message(StrSubstNo(DOCUMENT_IMPORTED, SalesHeader."Document Type", SalesHeader."No."));
        end;
        //+NPR5.53 [377510]
    end;

    procedure SalesDocumentAmountToPOS(var POSSession: Codeunit "NPR POS Session"; SalesHeader: Record "Sales Header"; Invoice: Boolean; Ship: Boolean; Receive: Boolean; Print: Boolean; Pdf2Nav: Boolean; Send: Boolean; SyncPost: Boolean)
    var
        txtDeposit: Label 'Deposit';
        ErrDoubleOrder: Label 'Error. Only one sales order can be processed per sale.';
        PaymentAmount: Decimal;
        SalesLine: Record "Sales Line";
        POSSale: Codeunit "NPR POS Sale";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        SalePOS: Record "NPR Sale POS";
        SaleLinePOS: Record "NPR Sale Line POS";
        POSPrepaymentMgt: Codeunit "NPR POS Prepayment Mgt.";
    begin
        POSSession.GetSale(POSSale);
        POSSession.GetSaleLine(POSSaleLine);
        POSSale.GetCurrentSale(SalePOS);

        //-NPR5.53 [375290]
        // IF DocumentIsPartiallyPosted(SalesHeader) THEN
        //  ERROR(ERR_DOCUMENT_POSTED_LINE, SalesHeader."Document Type", SalesHeader."No.");
        //+NPR5.53 [375290]

        if SalePOS."Customer No." <> '' then begin
            SalePOS.TestField("Customer Type", SalePOS."Customer Type"::Ord);
            SalePOS.TestField("Customer No.", SalesHeader."Bill-to Customer No.");
        end else begin
            SalePOS."Customer Type" := SalePOS."Customer Type"::Ord;
            SalePOS.Validate("Customer No.", SalesHeader."Bill-to Customer No.");
            SalePOS.Modify(true);
            POSSale.RefreshCurrent();
        end;

        if not SalePOS."Prices Including VAT" then begin
            SalePOS.Validate("Prices Including VAT", true);
            SalePOS.Modify(true);
            POSSale.RefreshCurrent();
        end;

        //-NPR5.53 [375290]
        // SalesLine.SETRANGE("Document Type",SalesHeader."Document Type");
        // SalesLine.SETRANGE("Document No.",SalesHeader."No.");
        // SalesLine.CALCSUMS("Amount Including VAT");
        // PaymentAmount := SalesLine."Amount Including VAT" - POSPrepaymentMgt.GetPrepaymentAmountToDeductInclVAT(SalesHeader);
        PaymentAmount := GetTotalAmountToBeInvoiced(SalesHeader);
        //+NPR5.53 [375290]

        POSSaleLine.GetNewSaleLine(SaleLinePOS);
        SaleLinePOS."Sale Type" := SaleLinePOS."Sale Type"::Deposit;
        SaleLinePOS.Type := SaleLinePOS.Type::Customer;
        SaleLinePOS.Validate(Quantity, 1);
        SaleLinePOS.Validate("No.", SalesHeader."Bill-to Customer No.");
        SaleLinePOS."Sales Document Type" := SalesHeader."Document Type";
        SaleLinePOS."Sales Document No." := SalesHeader."No.";
        SaleLinePOS."Sales Document Invoice" := Invoice;
        SaleLinePOS."Sales Document Ship" := Ship;
        SaleLinePOS."Sales Document Print" := Print;
        SaleLinePOS."Sales Document Receive" := Receive;
        SaleLinePOS."Sales Document Sync. Posting" := SyncPost;
        SaleLinePOS."Sales Document Send" := Send;
        SaleLinePOS."Sales Document Pdf2Nav" := Pdf2Nav;
        if SalesHeader."Document Type" in [SalesHeader."Document Type"::"Return Order", SalesHeader."Document Type"::"Credit Memo"] then
            SaleLinePOS.Validate("Unit Price", -PaymentAmount)
        else
            SaleLinePOS.Validate("Unit Price", PaymentAmount);
        //-NPR5.53 [375290]
        if DocumentIsSetToFullPosting(SalesHeader) then begin
            SaleLinePOS.Description := StrSubstNo(DOCUMENT_FULL_AMOUNT, SalesHeader."Document Type", SalesHeader."No.")
        end else begin
            SaleLinePOS.Description := StrSubstNo(DOCUMENT_SPLIT_AMOUNT, SalesHeader."Document Type", SalesHeader."No.");
        end;
        //+NPR5.53 [375290]
        SaleLinePOS.UpdateAmounts(SaleLinePOS);
        POSSaleLine.InsertLineRaw(SaleLinePOS, false);
    end;

    procedure SetOrderType(OrderTypeOption: Option NotSet,"Order",Lending)
    begin

        case OrderTypeOption of
            OrderTypeOption::NotSet:
                begin
                    OrderType := 0;
                    OrderTypeSet := false;
                end;
            OrderTypeOption::Order:
                begin
                    OrderType := 1;
                    OrderTypeSet := true;
                end;
            OrderTypeOption::Lending:
                begin
                    OrderType := 2;
                    OrderTypeSet := true;
                end;
            else
                Error(ERRORDERTYPE, Format(OrderTypeOption), Format(OrderTypeOption::NotSet), Format(OrderTypeOption::Order), Format(OrderTypeOption::Lending));
        end;
    end;

    procedure SetDeleteDocumentOnImport(SetDelete: Boolean; SetConfirm: Boolean)
    begin
        DeleteDocumentOnImportToPOS := SetDelete;
        ConfirmDeleteDocumentOnImportToPOS := SetConfirm;
    end;

    procedure SelectSalesDocument(TableView: Text; var SalesHeader: Record "Sales Header"): Boolean
    begin
        //-NPR5.48 [300557]
        if TableView <> '' then
            SalesHeader.SetView(TableView);

        exit(PAGE.RunModal(0, SalesHeader) = ACTION::LookupOK);
        //+NPR5.48 [300557]
    end;

    procedure DocumentIsAttachedToPOSSale(SalePOS: Record "NPR Sale POS"): Boolean
    var
        SaleLinePOS: Record "NPR Sale Line POS";
    begin
        //-NPR5.48 [300557]
        if SalePOS."Sales Document No." <> '' then
            exit(true);

        SaleLinePOS.SetRange("Register No.", SalePOS."Register No.");
        SaleLinePOS.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");
        SaleLinePOS.SetFilter("Buffer Document No.", '<>%1', '');
        if not SaleLinePOS.IsEmpty then
            exit(true);

        SaleLinePOS.SetRange("Buffer Document No.");
        SaleLinePOS.SetFilter("Sales Document No.", '<>%1', '');
        if not SaleLinePOS.IsEmpty then
            exit(true);

        exit(false);
        //+NPR5.48 [300557]
    end;

    procedure DocumentIsPartiallyPosted(SalesHeader: Record "Sales Header"): Boolean
    var
        SalesLine: Record "Sales Line";
    begin
        //-NPR5.50 [300557]
        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.SetRange("Document No.", SalesHeader."No.");

        SalesLine.SetFilter("Qty. Invoiced (Base)", '<>%1', 0);
        if not SalesLine.IsEmpty then
            exit(true);
        SalesLine.SetRange("Qty. Invoiced (Base)");

        SalesLine.SetFilter("Qty. Shipped (Base)", '<>%1', 0);

        if not SalesLine.IsEmpty then
            exit(true);
        SalesLine.SetRange("Qty. Shipped (Base)");

        SalesLine.SetFilter("Return Qty. Received (Base)", '<>%1', 0);
        if not SalesLine.IsEmpty then
            exit(true);
        SalesLine.SetRange("Return Qty. Received (Base)");

        exit(false);
        //+NPR5.50 [300557]
    end;

    local procedure GetTotalAmountToBeInvoiced(SalesHeader: Record "Sales Header"): Decimal
    var
        SalesPost: Codeunit "Sales-Post";
        TempSalesLine: Record "Sales Line" temporary;
        SalesLine: Record "Sales Line";
        TempVATAmountLine: Record "VAT Amount Line" temporary;
        TotalSalesLine: Record "Sales Line";
        TotalSalesLineLCY: Record "Sales Line";
        VATAmount: Decimal;
        ProfitLCY: Decimal;
        ProfitPct: Decimal;
        TotalAdjCostLCY: Decimal;
        VATAmountText: Text[30];
    begin
        //-NPR5.53 [375290]
        SalesPost.GetSalesLines(SalesHeader, TempSalesLine, 1);
        Clear(SalesPost);
        SalesLine.CalcVATAmountLines(0, SalesHeader, TempSalesLine, TempVATAmountLine);

        SalesPost.SumSalesLinesTemp(
          SalesHeader, TempSalesLine, 1, TotalSalesLine, TotalSalesLineLCY,
          VATAmount, VATAmountText, ProfitLCY, ProfitPct, TotalAdjCostLCY);

        if SalesHeader."Prices Including VAT" then begin
            exit(TotalSalesLine.Amount + VATAmount);
        end else begin
            exit(TotalSalesLine."Amount Including VAT");
        end;
        //+NPR5.53 [375290]
    end;

    local procedure SynchronizePOSSaleWithDocument(SalePOS: Record "NPR Sale POS")
    var
        SalesHeader: Record "Sales Header";
        POSSession: Codeunit "NPR POS Session";
        POSSale: Codeunit "NPR POS Sale";
        POSSaleLine: Codeunit "NPR POS Sale Line";
    begin
        //-NPR5.53 [377510]
        SalePOS.TestField("Sales Document No.");
        SalesHeader.Get(SalePOS."Sales Document Type", SalePOS."Sales Document No.");
        POSSession.GetSession(POSSession, true);
        POSSession.GetSale(POSSale);
        POSSession.GetSaleLine(POSSaleLine);

        POSSaleLine.DeleteAll();

        POSSale.RefreshCurrent();
        POSSale.GetCurrentSale(SalePOS);
        Clear(SalePOS."Sales Document No.");
        Clear(SalePOS."Sales Document Type");
        SalePOS."Customer Type" := SalePOS."Customer Type"::Ord;
        SalePOS.Validate("Customer No.", SalesHeader."Bill-to Customer No.");
        SalePOS.Modify;
        POSSale.RefreshCurrent();

        SalesDocumentToPOSCustom(POSSession, SalesHeader, false, false);
        //+NPR5.53 [377510]
    end;

    procedure DocumentIsSetToFullPosting(SalesHeader: Record "Sales Header"): Boolean
    var
        SalesLine: Record "Sales Line";
    begin
        //-NPR5.53 [377510]
        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        if SalesLine.FindSet then
            repeat
                if ((SalesLine."Qty. to Invoice" + SalesLine."Quantity Invoiced") <> SalesLine.Quantity) then
                    exit(false);
            until SalesLine.Next = 0;

        exit(true);
        //+NPR5.53 [377510]
    end;

    procedure SetDocumentToFullPosting(SalesHeader: Record "Sales Header")
    var
        SalesLine: Record "Sales Line";
    begin
        //-NPR5.53 [377510]
        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        if SalesLine.FindSet(true) then
            repeat
                if ((SalesLine."Qty. to Invoice" + SalesLine."Quantity Invoiced") <> SalesLine.Quantity) then begin
                    SalesLine.Validate("Qty. to Invoice", SalesLine.Quantity - SalesLine."Quantity Invoiced");
                    SalesLine.Modify(true);
                end;
            until SalesLine.Next = 0;
        //+NPR5.53 [377510]
    end;
}

