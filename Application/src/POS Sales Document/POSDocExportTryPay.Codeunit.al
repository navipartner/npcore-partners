﻿codeunit 6014417 "NPR POS Doc. Export Try Pay"
{
    Access = Internal;

    var
        HandleType: Option Undefined,Prepayment,Post;
        FullPosting: Boolean;
        SalesHeader: Record "Sales Header";
        POSSession: Codeunit "NPR POS Session";
        PrepaymentValue: Decimal;
        PrepaymentIsAmount: Boolean;
        Print: Boolean;
        Send: Boolean;
        Pdf2Nav: Boolean;
        PrepaymentManualLineControl: Boolean;
        POSSalesDocumentPost: Enum "NPR POS Sales Document Post";
        TextDirectInvocationNotAllowed: Label 'You must not run codeunit "NPR POS Handle Payment" directly.';

    trigger OnRun()
    var
        POSSale: Codeunit "NPR POS Sale";
        SalePOS: Record "NPR POS Sale";
        RetailSalesDocMgt: Codeunit "NPR Sales Doc. Exp. Mgt.";
        RetailSalesDocImpMgt: Codeunit "NPR Sales Doc. Imp. Mgt.";
    begin
        if HandleType = HandleType::Undefined then
            Error(TextDirectInvocationNotAllowed);

        SalesHeader.LockTable();
        if SalesHeader.Find() then begin
            if (HandleType = HandleType::Post) and FullPosting then
                RetailSalesDocImpMgt.SetDocumentToFullPosting(SalesHeader);

            POSSession.GetSale(POSSale);
            POSSale.GetCurrentSale(SalePOS);
            SalePOS.Validate("Customer No.", SalesHeader."Bill-to Customer No.");
            SalePOS.Modify(true);
            POSSale.RefreshCurrent();

            case HandleType of
                HandleType::Prepayment:
                    begin
                        RetailSalesDocMgt.SetManualLinePrepaymentControl(PrepaymentManualLineControl);
                        RetailSalesDocMgt.CreatePrepaymentLine(POSSession, SalesHeader, PrepaymentValue, Print, Send, Pdf2Nav, POSSalesDocumentPost, PrepaymentIsAmount);
                    end;

                HandleType::Post:
                    RetailSalesDocImpMgt.SalesDocumentAmountToPOS(POSSession, SalesHeader, true, true, true, Print, Pdf2Nav, Send, POSSalesDocumentPost)
            end;

            Commit();
        end;
    end;

    procedure HandlePrepaymentTransactional(POSSessionIn: Codeunit "NPR POS Session"; SalesHeaderIn: Record "Sales Header"; PrepaymentValueIn: Decimal; PrepaymentIsAmountIn: Boolean; PrintIn: Boolean; SendIn: Boolean; Pdf2NavIn: Boolean; Self: Codeunit "NPR POS Doc. Export Try Pay"; SalePostingIn: Enum "NPR POS Sales Document Post"; PrepaymentManualLineControlIn: Boolean) Success: Boolean
    begin
        POSSession := POSSessionIn;
        SalesHeader := SalesHeaderIn;
        PrepaymentValue := PrepaymentValueIn;
        PrepaymentIsAmount := PrepaymentIsAmountIn;
        Print := PrintIn;
        Send := SendIn;
        Pdf2Nav := Pdf2NavIn;
        POSSalesDocumentPost := SalePostingIn;
        PrepaymentManualLineControl := PrepaymentManualLineControlIn;

        HandleType := HandleType::Prepayment;

        Commit();
        Success := Self.Run();
    end;

    procedure HandlePayAndPostTransactional(POSSessionIn: Codeunit "NPR POS Session"; SalesHeaderIn: Record "Sales Header"; PrintIn: Boolean; Pdf2NavIn: Boolean; SendIn: Boolean; FullPostingIn: Boolean; Self: Codeunit "NPR POS Doc. Export Try Pay"; SalePostingIn: Enum "NPR POS Sales Document Post") Success: Boolean;
    begin
        POSSession := POSSessionIn;
        SalesHeader := SalesHeaderIn;
        Print := PrintIn;
        Pdf2Nav := Pdf2NavIn;
        Send := SendIn;
        FullPosting := FullPostingIn;
        POSSalesDocumentPost := SalePostingIn;

        HandleType := HandleType::Post;

        Commit();
        Success := Self.Run();
    end;
}
