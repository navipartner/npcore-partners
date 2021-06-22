codeunit 6014406 "NPR Sales Doc. Imp. Mgt."
{
    var
        ERR_DUPLICATE_DOCUMENT: Label 'Only one sales document can be processed per sale.';
        DOCUMENT_IMPORTED_DELETED: Label '%1 %2 was imported in POS. The document has been deleted.';
        DOCUMENT_IMPORTED: Label '%1 %2 was imported in POS.';
        ERR_DOCUMENT_POSTED_LINE: Label '%1 %2 has partially posted lines. Aborting action.';
        DOCUMENT_FULL_AMOUNT: Label 'Remaining Amount for %1 %2';
        DOCUMENT_SPLIT_AMOUNT: Label 'Amount for %1 %2';

    procedure SalesDocumentToPOS(var POSSession: Codeunit "NPR POS Session"; var SalesHeader: Record "Sales Header")
    begin
        SalesDocumentToPOSCustom(POSSession, SalesHeader, true, true);
    end;

    procedure SalesDocumentToPOSCustom(var POSSession: Codeunit "NPR POS Session"; var SalesHeader: Record "Sales Header"; DeleteDocument: Boolean; ShowSuccessMessage: Boolean)
    var
        SaleLinePOS: Record "NPR POS Sale Line";
        SalesLine: Record "Sales Line";
        POSSale: Codeunit "NPR POS Sale";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        SalePOS: Record "NPR POS Sale";
    begin
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
        SalesLine.FindSet();

        repeat
            POSSaleLine.GetNewSaleLine(SaleLinePOS);

            SaleLinePOS.SetSkipCalcDiscount(true); //Prevent overwrite of any discounts from sales document, until lines are added,deleted,removed.            
            SaleLinePOS.SetSkipUpdateDependantQuantity(true);

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

            SaleLinePOS.SetSkipUpdateDependantQuantity(false);

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
        until SalesLine.Next() = 0;

        if DeleteDocument then begin
            SalesHeader.Delete(true);
        end;

        Commit();

        if ShowSuccessMessage then begin
            if DeleteDocument then
                Message(StrSubstNo(DOCUMENT_IMPORTED_DELETED, SalesHeader."Document Type", SalesHeader."No."))
            else
                Message(StrSubstNo(DOCUMENT_IMPORTED, SalesHeader."Document Type", SalesHeader."No."));
        end;
    end;

    procedure SalesDocumentAmountToPOS(var POSSession: Codeunit "NPR POS Session"; SalesHeader: Record "Sales Header"; Invoice: Boolean; Ship: Boolean; Receive: Boolean; Print: Boolean; Pdf2Nav: Boolean; Send: Boolean; SyncPost: Boolean)
    var
        PaymentAmount: Decimal;
        POSSale: Codeunit "NPR POS Sale";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        SalePOS: Record "NPR POS Sale";
        SaleLinePOS: Record "NPR POS Sale Line";
    begin
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

        if not SalePOS."Prices Including VAT" then begin
            SalePOS.Validate("Prices Including VAT", true);
            SalePOS.Modify(true);
            POSSale.RefreshCurrent();
        end;

        PaymentAmount := GetTotalAmountToBeInvoiced(SalesHeader);

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
        if DocumentIsSetToFullPosting(SalesHeader) then begin
            SaleLinePOS.Description := StrSubstNo(DOCUMENT_FULL_AMOUNT, SalesHeader."Document Type", SalesHeader."No.")
        end else begin
            SaleLinePOS.Description := StrSubstNo(DOCUMENT_SPLIT_AMOUNT, SalesHeader."Document Type", SalesHeader."No.");
        end;
        SaleLinePOS.UpdateAmounts(SaleLinePOS);
        POSSaleLine.InsertLineRaw(SaleLinePOS, false);
    end;

    procedure SelectSalesDocument(TableView: Text; var SalesHeader: Record "Sales Header"): Boolean
    begin
        if TableView <> '' then
            SalesHeader.SetView(TableView);

        exit(PAGE.RunModal(0, SalesHeader) = ACTION::LookupOK);
    end;

    procedure DocumentIsAttachedToPOSSale(SalePOS: Record "NPR POS Sale"): Boolean
    var
        SaleLinePOS: Record "NPR POS Sale Line";
    begin
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
    end;

    procedure DocumentIsPartiallyPosted(SalesHeader: Record "Sales Header"): Boolean
    var
        SalesLine: Record "Sales Line";
    begin
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
    end;

    procedure SynchronizePOSSaleWithDocument(SalePOS: Record "NPR POS Sale")
    var
        SalesHeader: Record "Sales Header";
        POSSession: Codeunit "NPR POS Session";
        POSSale: Codeunit "NPR POS Sale";
        POSSaleLine: Codeunit "NPR POS Sale Line";
    begin
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
        SalePOS.Modify();
        POSSale.RefreshCurrent();

        SalesDocumentToPOSCustom(POSSession, SalesHeader, false, false);
    end;

    procedure DocumentIsSetToFullPosting(SalesHeader: Record "Sales Header"): Boolean
    var
        SalesLine: Record "Sales Line";
    begin
        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        if SalesLine.FindSet() then
            repeat
                if ((SalesLine."Qty. to Invoice" + SalesLine."Quantity Invoiced") <> SalesLine.Quantity) then
                    exit(false);
            until SalesLine.Next() = 0;

        exit(true);
    end;

    procedure SetDocumentToFullPosting(SalesHeader: Record "Sales Header")
    var
        SalesLine: Record "Sales Line";
    begin
        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        if SalesLine.FindSet(true) then
            repeat
                if ((SalesLine."Qty. to Invoice" + SalesLine."Quantity Invoiced") <> SalesLine.Quantity) then begin
                    SalesLine.Validate("Qty. to Invoice", SalesLine.Quantity - SalesLine."Quantity Invoiced");
                    SalesLine.Modify(true);
                end;
            until SalesLine.Next() = 0;
    end;
}

