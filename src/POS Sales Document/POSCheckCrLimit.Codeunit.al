codeunit 6014412 "NPR POS-Check Cr. Limit"
{
    trigger OnRun()
    begin
    end;

    var
        InstructionMgt: Codeunit "Instruction Mgt.";
        CustCheckCreditLimit: Page "Check Credit Limit";
        CustCheckCrLimit: Codeunit "Cust-Check Cr. Limit";
        OK: Boolean;
        Text000: Label '';

    procedure POSHeaderCheck(SalesHeader: Record "Sales Header") CreditLimitExceeded: Boolean
    begin
        if not GuiAllowed then
            exit;

        if not CustCheckCreditLimit.SalesHeaderShowWarning(SalesHeader) then
            SalesHeader.OnCustomerCreditLimitNotExceeded
        else
            if InstructionMgt.IsEnabled(CustCheckCrLimit.GetInstructionType(Format(SalesHeader."Document Type"), SalesHeader."No.")) then begin
                CreditLimitExceeded := true;
                SalesHeader.OnCustomerCreditLimitExceeded;
            end;
    end;

    procedure SalesHeaderPOSCheck(SalesHeader: Record "Sales Header"): Boolean
    begin
        if CustCheckCreditLimit.SalesHeaderShowWarning(SalesHeader) then begin
            OK := CustCheckCreditLimit.RunModal = ACTION::Yes;
            Clear(CustCheckCreditLimit);
            if not OK then begin
                Message(Text000);
                exit(false);
            end;
        end;

        exit(true);
    end;
}

