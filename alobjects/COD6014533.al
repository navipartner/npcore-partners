codeunit 6014533 "RP Preprocess - Signature test"
{
    // Print pre-processing codeunit that checks whether or not a sale in audit roll should have a signature receipt printed for it:

    TableNo = "Audit Roll";

    trigger OnRun()
    begin
        AuditRoll.Copy(Rec);
        SetGlobals();

        // Return sale check
        AuditRollSale.SetFilter(Quantity, '<%1', 0);
        if not AuditRollSale.IsEmpty then begin
          AuditRollTotals.CalcSums("Amount Including VAT");
          if RetailSetup."Return Receipt Positive Amount" or (AuditRollTotals."Amount Including VAT" < 0) then
            exit;
        end;
        AuditRollSale.SetRange(Quantity);

        // Customer payment check
        if AuditRollCustomerPayments.FindFirst then
          exit;

        //GL payment check
        AuditRollFinance.SetRange("Gift voucher ref.", '');
        AuditRollFinance.SetRange("Credit voucher ref.", '');
        if not AuditRollFinance.IsEmpty then
          exit;

        //Gift/credit voucher sale check
        AuditRollFinance.SetRange("Gift voucher ref.");
        AuditRollFinance.SetRange("Credit voucher ref.");
        if not AuditRollFinance.IsEmpty then
          if RetailSetup."Copy Sales Ticket on Giftvo." then
            exit;

        // Out payment check
        AuditRollSale.SetRange("Sale Type", AuditRollSale."Sale Type"::"Out payment");
        if AuditRollSale.FindSet then repeat
          if not ((AuditRollSale.Type = AuditRollSale.Type::"G/L") and (AuditRollSale."No." = Register.Rounding)) then
            exit;
        until AuditRollSale.Next = 0;


        Error(''); //Will cancel the signature receipt template that has this CU set as pre-processing
    end;

    var
        AuditRoll: Record "Audit Roll";
        AuditRollSale: Record "Audit Roll";
        AuditRollPayment: Record "Audit Roll";
        AuditRollFinance: Record "Audit Roll";
        AuditRollTotals: Record "Audit Roll";
        AuditRollCustomerPayments: Record "Audit Roll";
        RetailSetup: Record "Retail Setup";
        Register: Record Register;

    local procedure SetGlobals()
    begin
        AuditRollSale.Copy(AuditRoll);
        AuditRollSale.SetFilter("Sale Type",'%1|%2|%3|%4|%5',
                                              AuditRollSale."Sale Type"::Sale,
                                              AuditRollSale."Sale Type"::"Out payment",
                                              AuditRollSale."Sale Type"::Deposit,
                                              AuditRollSale."Sale Type"::Comment,
                                              AuditRollSale."Sale Type"::"Debit Sale");

        AuditRollFinance.Copy(AuditRoll);
        AuditRollFinance.SetFilter("Sale Type",'%1',AuditRollFinance."Sale Type"::Deposit);
        AuditRollFinance.SetFilter(Type,'%1',AuditRollFinance.Type::"G/L");

        AuditRollPayment.Copy(AuditRoll);
        AuditRollPayment.SetRange("Sale Type",AuditRollPayment."Sale Type"::Payment);

        AuditRollTotals.Copy(AuditRollSale);
        AuditRollTotals.SetCurrentKey("Register No.","Sales Ticket No.","Line No.");

        AuditRollCustomerPayments.Copy(AuditRoll);
        AuditRollCustomerPayments.SetRange("Sale Type", AuditRollCustomerPayments."Sale Type"::Deposit);
        AuditRollCustomerPayments.SetRange(Type, AuditRollCustomerPayments.Type::Customer);

        RetailSetup.Get();
        Register.Get(AuditRoll."Register No.");
    end;
}

