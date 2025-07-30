codeunit 6014406 "NPR Sales Doc. Imp. Mgt."
{
    Access = Internal;

    var
        ERR_DUPLICATE_DOCUMENT: Label 'Only one sales document can be processed per sale.';
        DOCUMENT_IMPORTED_DELETED: Label '%1 %2 was imported in POS. The document has been deleted.';
        DOCUMENT_IMPORTED: Label '%1 %2 was imported in POS.';
        ERR_DOCUMENT_POSTED_LINE: Label '%1 %2 has partially posted lines. Aborting action.';
        DocumentInvoiceLdbl: Label 'Amount Invoiced';
        DocumentShippedLbl: Label 'Shipped';
        DocumentReceivedLbl: Label 'Received';
        ImportInvDiscAmtQst: Label 'Selected document contain Invoice Discount Amount. Invoice Discount Amount will be lost, and the document will be posted without it, resulting in the total amount to be higher. Do you want to continue?';
        ConfirmInvDiscAmtLbl: Label 'Inv. Disc. Amt.';
        ConfirmInvDiscAmtDescLbl: Label 'Confirm Inv. Disc. Amt.';


    procedure SalesDocumentToPOS(var POSSession: Codeunit "NPR POS Session"; var SalesHeader: Record "Sales Header")
    begin
        SalesDocumentToPOSCustom(POSSession, SalesHeader, true, true);
    end;

    procedure SalesDocumentToPOSCustom(var POSSession: Codeunit "NPR POS Session"; var SalesHeader: Record "Sales Header"; DeleteDocument: Boolean; ShowSuccessMessage: Boolean)
    var
        SalesLine: Record "Sales Line";
        POSSale: Codeunit "NPR POS Sale";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        SalePOS: Record "NPR POS Sale";
        Item: Record Item;
        SalesLineTypeNotSupportedErr: Label 'Sales Document contains line with unsupported type. Supported types are %1, %2 and %3.', Comment = '%1=SalesLine.Type::"";%2=SalesLine.Type::Item;%3=SalesLine.Type::"G/L Account"';
    begin
        POSSession.GetSale(POSSale);
        POSSession.GetSaleLine(POSSaleLine);
        POSSale.GetCurrentSale(SalePOS);

        SalePOS.TestField("Customer No.", SalesHeader."Bill-to Customer No.");

        if DocumentIsAttachedToPOSSale(SalePOS) then
            Error(ERR_DUPLICATE_DOCUMENT);

        if DocumentIsPartiallyPosted(SalesHeader) then
            Error(ERR_DOCUMENT_POSTED_LINE, SalesHeader."Document Type", SalesHeader."No.");

        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        SalesLine.SetFilter(Type, '<>%1&<>%2&<>%3', SalesLine.Type::" ", SalesLine.Type::"G/L Account", SalesLine.Type::Item);
        if not SalesLine.IsEmpty() then
            Error(SalesLineTypeNotSupportedErr, SalesLine.Type::" ", SalesLine.Type::"G/L Account", SalesLine.Type::Item);
        SalesLine.SetRange(Type);
        if not SalesLine.FindSet() then
            exit;
        repeat
            case SalesLine.Type of
                SalesLine.Type::Item:
                    begin
                        Item.Get(SalesLine."No.");
                        if SpecificItemTrackingExist(Item) then
                            InsertItemWithTrackingLine(SalesLine, POSSaleLine, SalesHeader)
                        else
                            InsertLine(SalesLine, POSSaleLine, SalesHeader);
                    end;
                else
                    InsertLine(SalesLine, POSSaleLine, SalesHeader);
            end;
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

    local procedure SpecificItemTrackingExist(Item: Record Item): Boolean
    var
        ItemTrackingCode: Record "Item Tracking Code";
    begin
        if Item."Item Tracking Code" = '' then
            exit(false);
        if not ItemTrackingCode.Get(Item."Item Tracking Code") then
            exit(false);
        if ItemTrackingCode."SN Specific Tracking" then
            exit(true);
        if ItemTrackingCode."SN Sales Outbound Tracking" then
            exit(true);
        if ItemTrackingCode."Lot Specific Tracking" then
            exit(true);
        exit(false);
    end;

    local procedure InitNewLine(var POSSaleLine: Codeunit "NPR POS Sale Line"; var SaleLinePOS: Record "NPR POS Sale Line")
    begin
        POSSaleLine.GetNewSaleLine(SaleLinePOS);

        SaleLinePOS.SetSkipCalcDiscount(true); //Prevent overwrite of any discounts from sales document, until lines are added,deleted,removed.            
        SaleLinePOS.SetSkipUpdateDependantQuantity(true);
    end;

    local procedure FromSaleLineToSaleLinePOS(SalesLine: Record "Sales Line"; var SaleLinePOS: Record "NPR POS Sale Line")
    var
        SalesDocImptMgtPublic: Codeunit "NPR Sales Doc. Imp. Mgt Public";
    begin
        SaleLinePOS.SetSkipUpdateDependantQuantity(false);
        SaleLinePOS.Description := SalesLine.Description;
        SaleLinePOS."Description 2" := SalesLine."Description 2";
        SaleLinePOS."Variant Code" := SalesLine."Variant Code";

        SaleLinePOS.Validate("Unit Price", SalesLine."Unit Price");
        SaleLinePOS."Bin Code" := SalesLine."Bin Code";
        SaleLinePOS."Location Code" := SalesLine."Location Code";
        SaleLinePOS."Discount Type" := SalesLine."NPR Discount Type";
#pragma warning disable AA0139
        SaleLinePOS."Discount Code" := SalesLine."NPR Discount Code";
# pragma warning restore
        SaleLinePOS."Allow Line Discount" := SalesLine."Allow Line Disc.";
        SaleLinePOS."Discount %" := SalesLine."Line Discount %";
        SaleLinePOS."Discount Amount" := SalesLine."Line Discount Amount";
        SaleLinePOS.UpdateAmounts(SaleLinePOS);
        SaleLinePOS."Shortcut Dimension 1 Code" := SalesLine."Shortcut Dimension 1 Code";
        SaleLinePOS."Shortcut Dimension 2 Code" := SalesLine."Shortcut Dimension 2 Code";
        SaleLinePOS."Dimension Set ID" := SalesLine."Dimension Set ID";
        SaleLinePOS."Shipment Fee" := SalesLine."NPR Shipment Fee";
        SaleLinePOS."Store Ship Profile Code" := SalesLine."NPR Store Ship Profile Code";
        SaleLinePOS."Store Ship Profile Line No." := SalesLine."NPR Store Ship Prof. Line No.";
        SalesDocImptMgtPublic.OnAfterTransferFromSaleLineToSaleLinePOS(SaleLinePOS, SalesLine);
    end;

    local procedure InsertItemWithTrackingLine(SalesLine: Record "Sales Line"; var POSSaleLine: Codeunit "NPR POS Sale Line"; SalesHeader: Record "Sales Header")
    var
        ReservationEntry: Record "Reservation Entry";
        SaleLinePOS: Record "NPR POS Sale Line";
    begin
        ReservationEntry.SetRange("Item No.", SalesLine."No.");
        ReservationEntry.SetRange("Source ID", SalesLine."Document No.");
        ReservationEntry.SetRange("Source Type", DATABASE::"Sales Line");
        ReservationEntry.SetRange("Source Ref. No.", SalesLine."Line No.");
        ReservationEntry.SetRange("Source Subtype", SalesLine."Document Type");
        if ReservationEntry.FindSet() then
            repeat
                InitNewLine(POSSaleLine, SaleLinePOS);

                SaleLinePOS."Line Type" := SaleLinePOS."Line Type"::Item;
                SaleLinePOS.Validate("No.", SalesLine."No.");
                SaleLinePOS.Validate("Unit of Measure Code", SalesLine."Unit of Measure Code");

                SaleLinePOS.Validate(Quantity, -ReservationEntry.Quantity);
                FromSaleLineToSaleLinePOS(SalesLine, SaleLinePOS);

                SaleLinePOS."Serial No." := ReservationEntry."Serial No.";
                SaleLinePOS."Lot No." := ReservationEntry."Lot No.";
                POSSaleLine.InsertLineRaw(SaleLinePOS, false);
                SaleLinePOS.SetSkipCalcDiscount(false);

            until ReservationEntry.Next() = 0
        else
            InsertLine(SalesLine, POSSaleLine, SalesHeader);
    end;

    local procedure InsertLine(SalesLine: Record "Sales Line"; POSSaleLine: Codeunit "NPR POS Sale Line"; SalesHeader: Record "Sales Header")
    var
        SaleLinePOS: Record "NPR POS Sale Line";
    begin
        InitNewLine(POSSaleLine, SaleLinePOS);

        case SalesLine.Type of
            SalesLine.Type::Item:
                begin
                    SaleLinePOS."Line Type" := SaleLinePOS."Line Type"::Item;
                    SaleLinePOS.Validate("No.", SalesLine."No.");
                    SaleLinePOS.Validate("Unit of Measure Code", SalesLine."Unit of Measure Code");
                end;
            SalesLine.Type::" ":
                SaleLinePOS."Line Type" := SaleLinePOS."Line Type"::Comment;
            SalesLine.Type::"G/L Account":
                begin
                    SaleLinePOS."Line Type" := "NPR POS Sale Line Type"::"GL Payment";
                    SaleLinePOS.Validate("No.", SalesLine."No.");
                end;
        end;

        if SalesHeader."Document Type" in [SalesHeader."Document Type"::"Return Order", SalesHeader."Document Type"::"Credit Memo"] then
            SaleLinePOS.Validate(Quantity, -SalesLine.Quantity)
        else
            SaleLinePOS.Validate(Quantity, SalesLine.Quantity);

        FromSaleLineToSaleLinePOS(SalesLine, SaleLinePOS);

        POSSaleLine.InsertLineRaw(SaleLinePOS, false);
        SaleLinePOS.SetSkipCalcDiscount(false);
    end;

    procedure SalesDocumentAmountToPOS(var POSSession: Codeunit "NPR POS Session"; SalesHeader: Record "Sales Header"; Invoice: Boolean; Ship: Boolean; Receive: Boolean; Print: Boolean; Pdf2Nav: Boolean; Send: Boolean; SalePostingIn: Enum "NPR POS Sales Document Post")
    begin
        SalesDocumentAmountToPOS(POSSession, SalesHeader, Invoice, Ship, Receive, Print, Pdf2Nav, Send, false, SalePostingIn);
    end;

    procedure SalesDocumentAmountToPOS(var POSSession: Codeunit "NPR POS Session"; SalesHeader: Record "Sales Header"; Invoice: Boolean; Ship: Boolean; Receive: Boolean; Print: Boolean; Pdf2Nav: Boolean; Send: Boolean; DocumentPaymentReservation: Boolean; SalePostingIn: Enum "NPR POS Sales Document Post")
    var
        PaymentAmount: Decimal;
    begin
        PaymentAmount := GetTotalAmountToBeInvoiced(SalesHeader);
        SalesDocumentAmountToPOS(POSSession, SalesHeader, Invoice, Ship, Receive, Print, Pdf2Nav, Send, DocumentPaymentReservation, SalePostingIn, PaymentAmount);
    end;

    procedure SalesDocumentAmountToPOS(var POSSession: Codeunit "NPR POS Session"; SalesHeader: Record "Sales Header"; Invoice: Boolean; Ship: Boolean; Receive: Boolean; Print: Boolean; Pdf2Nav: Boolean; Send: Boolean; DocumentPaymentReservation: Boolean; SalePostingIn: Enum "NPR POS Sales Document Post"; PaymentAmount: Decimal)
    var
        POSSale: Codeunit "NPR POS Sale";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        SalePOS: Record "NPR POS Sale";
        SaleLinePOS: Record "NPR POS Sale Line";
    begin
        POSSession.GetSale(POSSale);
        POSSession.GetSaleLine(POSSaleLine);
        POSSale.GetCurrentSale(SalePOS);

        if SalePOS."Customer No." <> '' then begin
            SalePOS.TestField("Customer No.", SalesHeader."Bill-to Customer No.");
        end else begin
            SalePOS.Validate("Customer No.", SalesHeader."Bill-to Customer No.");
            SalePOS.Modify(true);
            POSSale.RefreshCurrent();
        end;

        if not SalePOS."Prices Including VAT" then begin
            SalePOS.Validate("Prices Including VAT", true);
            SalePOS.Modify(true);
            POSSale.RefreshCurrent();
        end;

        POSSaleLine.GetNewSaleLine(SaleLinePOS);
        SalesHeader.Invoice := Invoice;
        SalesHeader.Ship := Ship;
        SalesHeader."Print Posted Documents" := Print;
        SalesHeader.Receive := Receive;
        SalesDocumentPaymentAmountToPOSSaleLine(PaymentAmount, SaleLinePOS, SalesHeader, Pdf2Nav, Send, DocumentPaymentReservation, SalePostingIn);
        SaleLinePOS.UpdateAmounts(SaleLinePOS);
        POSSaleLine.InsertLineRaw(SaleLinePOS, false);
    end;

    procedure SalesDocumentPaymentAmountToPOSSaleLine(PaymentAmount: Decimal; var SaleLinePOS: Record "NPR POS Sale Line"; var SalesHeader: Record "Sales Header"; Pdf2Nav: Boolean; Send: Boolean; DocumentPaymentReservation: Boolean; SalePostingIn: Enum "NPR POS Sales Document Post")
    begin
        SaleLinePOS."Line Type" := SaleLinePOS."Line Type"::"Customer Deposit";
        SaleLinePOS.Validate(Quantity, 1);
        SaleLinePOS.Validate("No.", SalesHeader."Bill-to Customer No.");
        SaleLinePOS."Sales Document Type" := SalesHeader."Document Type";
        SaleLinePOS."Sales Document No." := SalesHeader."No.";
        SaleLinePOS."Sales Document Invoice" := SalesHeader.Invoice;
        SaleLinePOS."Sales Document Ship" := SalesHeader.Ship;
        SaleLinePOS."Sales Document Print" := SalesHeader."Print Posted Documents";
        SaleLinePOS."Sales Document Receive" := SalesHeader.Receive;
        SaleLinePOS."Sales Document Post" := SalePostingIn;
        SaleLinePOS."Sales Document Send" := Send;
        SaleLinePOS."Sales Document Pdf2Nav" := Pdf2Nav;
        SaleLinePOS."Document Payment Reservation" := DocumentPaymentReservation;
        if SalesHeader."Document Type" in [SalesHeader."Document Type"::"Return Order", SalesHeader."Document Type"::"Credit Memo"] then
            SaleLinePOS.Validate("Unit Price", -PaymentAmount)
        else
            SaleLinePOS.Validate("Unit Price", PaymentAmount);

        SaleLinePOS.Description := StrSubstNo('%1 %2', SalesHeader."Document Type", SalesHeader."No.");
        if SalesHeader.Invoice then
            SaleLinePOS.Description += ', ' + DocumentInvoiceLdbl;
        if SalesHeader.Receive then
            SaleLinePOS.Description += ', ' + DocumentReceivedLbl;
        if SalesHeader.Ship then
            SaleLinePOS.Description += ', ' + DocumentShippedLbl;
    end;

    procedure SalesDocumentPaymentAmountToPOSSaleLine(PaymentAmount: Decimal; var SaleLinePOS: Record "NPR POS Sale Line"; var SalesHeader: Record "Sales Header"; Pdf2Nav: Boolean; Send: Boolean; SalePostingIn: Enum "NPR POS Sales Document Post")
    begin
        SalesDocumentPaymentAmountToPOSSaleLine(PaymentAmount, SaleLinePOS, SalesHeader, Pdf2Nav, Send, false, SalePostingIn);
    end;

    procedure SalesDocumentPaymentAmountToPOSSaleLine(PaymentAmount: Decimal; var SaleLinePOS: Record "NPR POS Sale Line"; var SalesInvoiceHeader: Record "Sales Invoice Header"; Pdf2Nav: Boolean; Send: Boolean; SyncPost: Boolean)
    begin
        SaleLinePOS."Line Type" := SaleLinePOS."Line Type"::"Customer Deposit";
        SaleLinePOS.Validate(Quantity, 1);
        SaleLinePOS.Validate("No.", SalesInvoiceHeader."Bill-to Customer No.");
        SaleLinePOS.Validate("Unit Price", PaymentAmount);
#pragma warning disable AA0139
        SaleLinePOS.Description := StrSubstNo('%1 %2', SalesInvoiceHeader.TableCaption, SalesInvoiceHeader."No.");
# pragma warning restore
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

    procedure GetTotalAmountToBeInvoiced(SalesHeader: Record "Sales Header"): Decimal
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

    procedure GetTotalAmountToBeInvoiced(SalesInvoiceHeader: Record "Sales Invoice Header"): Decimal
    begin
        SalesInvoiceHeader.CalcFields("Remaining Amount");
        exit(SalesInvoiceHeader."Remaining Amount");
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

        POSSaleLine.DeleteAll(true);

        POSSale.RefreshCurrent();
        POSSale.GetCurrentSale(SalePOS);
        Clear(SalePOS."Sales Document No.");
        Clear(SalePOS."Sales Document Type");
        if SalePOS."Customer No." <> SalesHeader."Bill-to Customer No." then
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

    procedure GetImportInvDiscAmtQst(): Text
    begin
        Exit(ImportInvDiscAmtQst);
    end;

    procedure GetConfirmInvDiscAmtLbl(): Text
    begin
        Exit(ConfirmInvDiscAmtLbl);
    end;

    procedure GetConfirmInvDiscAmtDescLbl(): Text
    begin
        Exit(ConfirmInvDiscAmtDescLbl);
    end;
}

