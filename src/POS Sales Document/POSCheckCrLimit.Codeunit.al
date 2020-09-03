codeunit 6014412 "NPR POS-Check Cr. Limit"
{
    // NPR5.29/JDH /20161210 CASE 256289 Credit limit Check function in 2017


    trigger OnRun()
    begin
    end;

    var
        InstructionMgt: Codeunit "Instruction Mgt.";
        CustCheckCreditLimit: Page "Check Credit Limit";
        CustCheckCrLimit: Codeunit "Cust-Check Cr. Limit";
        OK: Boolean;
        Text000: TextConst ENU = '';

    procedure POSHeaderCheck(SalesHeader: Record "Sales Header") CreditLimitExceeded: Boolean
    begin
        if not GuiAllowed then
            exit;

        if not CustCheckCreditLimit.SalesHeaderShowWarning(SalesHeader) then
            SalesHeader.OnCustomerCreditLimitNotExceeded
        else
            if InstructionMgt.IsEnabled(CustCheckCrLimit.GetInstructionType(Format(SalesHeader."Document Type"), SalesHeader."No.")) then begin
                CreditLimitExceeded := true;
                //CreateAndSendNotification;
                SalesHeader.OnCustomerCreditLimitExceeded;
            end;
    end;

    procedure SalesHeaderPOSCheck(SalesHeader: Record "Sales Header"): Boolean
    begin
        //-NPR7.100.000
        if CustCheckCreditLimit.SalesHeaderShowWarning(SalesHeader) then begin
            OK := CustCheckCreditLimit.RunModal = ACTION::Yes;
            Clear(CustCheckCreditLimit);
            if not OK then begin
                Message(Text000);
                exit(false);
            end;
        end;

        exit(true);
        //+NPR7.100.000
    end;
}

