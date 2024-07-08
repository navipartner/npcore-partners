codeunit 6059914 "NPR POS Action: Doc.Pay&Post B"
{
    Access = Internal;
    internal procedure CheckCustomer(var SalePOS: Record "NPR POS Sale"; POSSale: Codeunit "NPR POS Sale"; SelectCustomer: Boolean): Boolean
    var
        Customer: Record Customer;
    begin
        if SalePOS."Customer No." <> '' then
            exit(true);

        if not SelectCustomer then
            exit(true);

        if Page.RunModal(0, Customer) <> Action::LookupOK then
            exit(false);

        SalePOS.Validate("Customer No.", Customer."No.");
        SalePOS.Modify(true);
        POSSale.RefreshCurrent();
        Commit();
        exit(true);
    end;

    internal procedure SelectDocument(SalePOS: Record "NPR POS Sale"; var SalesHeader: Record "Sales Header"): Boolean
    var
        RetailSalesDocImpMgt: Codeunit "NPR Sales Doc. Imp. Mgt.";
    begin
        if SalePOS."Customer No." <> '' then
            SalesHeader.SetRange("Bill-to Customer No.", SalePOS."Customer No.");
        SalesHeader.SetRange("Document Type", SalesHeader."Document Type"::Order);
        SetFilterSalesHeader(SalePOS, SalesHeader);
        exit(RetailSalesDocImpMgt.SelectSalesDocument(SalesHeader.GetView(false), SalesHeader));
    end;

    internal procedure SetLinesToPost(SalesHeader: Record "Sales Header"; AutoQtyToInvoice: Option Disabled,None,All; AutoQtyToShip: Option Disabled,None,All; AutoQtyToReceive: Option Disabled,None,All)
    var
        SalesLine: Record "Sales Line";
        NoLinesErr: Label 'Selected Document %1 has no lines.', Comment = '%1 = Sales Header No.';
    begin
        if (AutoQtyToInvoice = AutoQtyToInvoice::Disabled) and (AutoQtyToShip = AutoQtyToShip::Disabled) and (AutoQtyToReceive = AutoQtyToReceive::Disabled) then
            exit;

        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        if not SalesLine.FindSet(true) then
            Error(NoLinesErr, SalesHeader."No.");

        repeat
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

            case AutoQtyToReceive of
                AutoQtyToReceive::Disabled:
                    ;
                AutoQtyToReceive::All:
                    begin
                        SalesLine.Validate("Return Qty. to Receive", SalesLine.Quantity - SalesLine."Return Qty. Received");
                    end;
                AutoQtyToReceive::None:
                    begin
                        SalesLine.Validate("Return Qty. to Receive", 0);
                    end;
            end;

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

            SalesLine.Modify();
        until SalesLine.Next() = 0;
        Commit();
    end;

    internal procedure ConfirmDocument(SalesHeader: Record "Sales Header"; OpenDoc: Boolean): Boolean
    var
        PageMgt: Codeunit "Page Management";
    begin
        if OpenDoc then
            exit(Page.RunModal(PageMgt.GetPageID(SalesHeader), SalesHeader) = Action::LookupOK);

        exit(true);
    end;

    internal procedure ConfirmIfInvoiceQuantityIncreased(SalesHeader: Record "Sales Header"; AutoQtyToInvoice: Option Disabled,None,All): Boolean
    var
        SalesLine: Record "Sales Line";
        ContinueWithInvoicing: Label 'One or more lines is set to be invoiced, not just shipped or received. Do you want to continue?';
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

    internal procedure ConfirmImportInvDiscAmt(SalesHeader: Record "Sales Header"; ConfirmInvDiscAmt: Boolean): Boolean
    var
        SalesLine: Record "Sales Line";
        SalesDocImpMgt: Codeunit "NPR Sales Doc. Imp. Mgt.";
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

    local procedure SetFilterSalesHeader(SalePOS: Record "NPR POS Sale"; var SalesHeader: Record "Sales Header")
    var
        POSSaleLine: Record "NPR POS Sale Line";
        FilterSalesNo: text;
    begin
        POSSaleLine.SetRange("Register No.", SalePOS."Register No.");
        POSSaleLine.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");
        POSSaleLine.SetFilter("Sales Document No.", '<>%1', '');
        if POSSaleLine.FindSet() then
            repeat
                if FilterSalesNo = '' then
                    FilterSalesNo := '<>' + POSSaleLine."Sales Document No."
                else
                    FilterSalesNo += '&<>' + POSSaleLine."Sales Document No.";
            until POSSaleLine.Next() = 0;

        SalesHeader.SetFilter("No.", FilterSalesNo);
    end;

    internal procedure CreateDocumentPaymentLine(POSSession: Codeunit "NPR POS Session"; SalesHeader: Record "Sales Header"; Print: Boolean; Send: Boolean; Pdf2Nav: Boolean; POSSalesDocumentPost: Enum "NPR POS Sales Document Post")
    var
        RetailSalesDocImpMgt: Codeunit "NPR Sales Doc. Imp. Mgt.";
        Ship: Boolean;
        Receive: Boolean;
        Invoice: Boolean;
        Post: Boolean;
        SalesLine: Record "Sales Line";
        POSAsyncPosting: Codeunit "NPR POS Async. Posting Mgt.";
    begin
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        SalesLine.SetRange("Document Type", SalesHeader."Document Type");

        SalesLine.SetFilter("Qty. to Ship", '>%1', 0);
        Ship := not SalesLine.IsEmpty;
        SalesLine.SetRange("Qty. to Ship");

        SalesLine.SetFilter("Qty. to Invoice", '>%1', 0);
        Invoice := not SalesLine.IsEmpty;
        SalesLine.SetRange("Qty. to Invoice");

        SalesLine.SetFilter("Return Qty. to Receive", '>%1', 0);
        Receive := not SalesLine.IsEmpty;
        SalesLine.SetRange("Return Qty. to Receive");

        Post := Ship or Invoice or Receive;

        if Post then begin
            if POSSalesDocumentPost = POSSalesDocumentPost::Asynchronous then
                POSAsyncPosting.CheckPostingStatusFromPOS(SalesHeader);
        end else
            POSSalesDocumentPost := POSSalesDocumentPost::No;

        RetailSalesDocImpMgt.SalesDocumentAmountToPOS(POSSession, SalesHeader, Invoice, Ship, Receive, Print, Pdf2Nav, Send, POSSalesDocumentPost);
    end;

}
