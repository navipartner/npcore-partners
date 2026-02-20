
codeunit 6248623 "NPR NP Loyalty Discount Mgt"
{
    Access = Internal;

    procedure CreateDiscountSalesLine(var PaymentLine: Record "NPR Magento Payment Line"; SalesHeader: Record "Sales Header")
    var
        LoyaltyServerStoreLedger: Record "NPR MM Loy. LedgerEntry (Srvr)";
        SalesLine: Record "Sales Line";
        LineNo: Integer;
    begin
        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        if SalesLine.FindLast() then;
        LineNo := SalesLine."Line No." + 10000;

        SalesLine.Init();
        SalesLine."Document Type" := SalesHeader."Document Type";
        SalesLine."Document No." := SalesHeader."No.";
        SalesLine."Line No." := LineNo;
        SalesLine.Insert();
        SalesLine.Validate(Type, SalesLine.Type::"G/L Account");
        SalesLine.Validate("No.", PaymentLine."Account No.");
        SalesLine.Validate(Quantity, 1);
        SalesLine.Validate("Unit Price", (-1 * PaymentLine.Amount));
        SalesLine.Validate(Description, PaymentLine."Source No.");
        SalesLine.Validate("Description 2", PaymentLine."No.");
        SalesLine."NPR Loyalty Discount" := true;
        SalesLine."NPR CreatedfrmPointsPmntLineId" := PaymentLine.SystemId;
        SalesLine.Modify();

        OnAfterCreateSalesDiscountLine(SalesLine, PaymentLine);

        LoyaltyServerStoreLedger.SetCurrentKey("Authorization Code");
        LoyaltyServerStoreLedger.SetRange("Authorization Code", CopyStr(PaymentLine."Transaction ID", 1, MaxStrLen(LoyaltyServerStoreLedger."Authorization Code")));
        if LoyaltyServerStoreLedger.FindFirst() then begin
            LoyaltyServerStoreLedger."Inc Ecom Sale Id" := PaymentLine."NPR Inc Ecom Sale Id";
            LoyaltyServerStoreLedger.Modify();
        end;
    end;

    procedure GetMembershipId(CustomerNo: Code[20]): Guid
    var
        Membership: Record "NPR MM Membership";
    begin
        Membership.SetRange("Customer No.", CustomerNo);
        Membership.SetRange(Blocked, false);
        if Membership.FindFirst() then
            exit(Membership.SystemId);
    end;

    [IntegrationEvent(false, false)]
    procedure OnAfterCreateSalesDiscountLine(var SalesLine: Record "Sales Line"; PaymentLine: Record "NPR Magento Payment Line")
    begin
    end;
}
