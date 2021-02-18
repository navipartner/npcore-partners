codeunit 6014533 "NPR RP Preprocess: Sign. test"
{
    // Print pre-processing codeunit that checks whether or not a sale in audit roll should have a signature receipt printed for it:
    // NPR5.53/ALPO/20191024 CASE 371955 Rounding related fields moved to POS Posting Profiles

    TableNo = "NPR Audit Roll";

    trigger OnRun()
    begin
        AuditRoll.Copy(Rec);
        SetGlobals();

        // Return sale check
        AuditRollSale.SetFilter(Quantity, '<%1', 0);
        if not AuditRollSale.IsEmpty then begin
            AuditRollTotals.CalcSums("Amount Including VAT");
            if AuditRollTotals."Amount Including VAT" < 0 then
                exit;
        end;
        AuditRollSale.SetRange(Quantity);

        // Customer payment check
        if AuditRollCustomerPayments.FindFirst then
            exit;

        // Out payment check
        AuditRollSale.SetRange("Sale Type", AuditRollSale."Sale Type"::"Out payment");
        if AuditRollSale.FindSet then
            repeat
                //IF NOT ((AuditRollSale.Type = AuditRollSale.Type::"G/L") AND (AuditRollSale."No." = Register.Rounding)) THEN  //NPR5.53 [371955]-revoked
                if not ((AuditRollSale.Type = AuditRollSale.Type::"G/L") and (AuditRollSale."No." = POSSetup.RoundingAccount(true))) then  //NPR5.53 [371955]
                    exit;
            until AuditRollSale.Next = 0;


        Error(''); //Will cancel the signature receipt template that has this CU set as pre-processing
    end;

    var
        AuditRoll: Record "NPR Audit Roll";
        AuditRollSale: Record "NPR Audit Roll";
        AuditRollPayment: Record "NPR Audit Roll";
        AuditRollFinance: Record "NPR Audit Roll";
        AuditRollTotals: Record "NPR Audit Roll";
        AuditRollCustomerPayments: Record "NPR Audit Roll";
        POSUnit: Record "NPR POS Unit";
        POSSetup: Codeunit "NPR POS Setup";

    local procedure SetGlobals()
    begin
        AuditRollSale.Copy(AuditRoll);
        AuditRollSale.SetFilter("Sale Type", '%1|%2|%3|%4|%5',
                                              AuditRollSale."Sale Type"::Sale,
                                              AuditRollSale."Sale Type"::"Out payment",
                                              AuditRollSale."Sale Type"::Deposit,
                                              AuditRollSale."Sale Type"::Comment,
                                              AuditRollSale."Sale Type"::"Debit Sale");

        AuditRollFinance.Copy(AuditRoll);
        AuditRollFinance.SetFilter("Sale Type", '%1', AuditRollFinance."Sale Type"::Deposit);
        AuditRollFinance.SetFilter(Type, '%1', AuditRollFinance.Type::"G/L");

        AuditRollPayment.Copy(AuditRoll);
        AuditRollPayment.SetRange("Sale Type", AuditRollPayment."Sale Type"::Payment);

        AuditRollTotals.Copy(AuditRollSale);
        AuditRollTotals.SetCurrentKey("Register No.", "Sales Ticket No.", "Line No.");

        AuditRollCustomerPayments.Copy(AuditRoll);
        AuditRollCustomerPayments.SetRange("Sale Type", AuditRollCustomerPayments."Sale Type"::Deposit);
        AuditRollCustomerPayments.SetRange(Type, AuditRollCustomerPayments.Type::Customer);

        POSUnit.Get(AuditRoll."Register No.");
        POSSetup.SetPOSUnit(POSUnit);
    end;
}

