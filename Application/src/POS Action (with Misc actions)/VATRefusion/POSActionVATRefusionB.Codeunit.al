codeunit 6150643 "NPR POSAction: VAT Refusion-B"
{
    Access = Internal;

    procedure DoRefusion(PaymentTypeCode: Code[10]; AmountInclVAT: Decimal)
    var
        PaymentLinePOS: Record "NPR POS Sale Line";
        POSPaymentMethod: Record "NPR POS Payment Method";
        POSPaymentLine: Codeunit "NPR POS Payment Line";
        POSSession: Codeunit "NPR POS Session";
    begin
        //Get payment type
        POSSession.GetPaymentLine(POSPaymentLine);
        POSPaymentLine.GetPOSPaymentMethod(POSPaymentMethod, PaymentTypeCode);
        POSPaymentMethod.Get(POSPaymentMethod.Code);

        if not IfRefusionExist(POSPaymentMethod, AmountInclVAT) then begin
            //Get amount and add to payment line
            PaymentLinePOS."No." := POSPaymentMethod.Code;
            PaymentLinePOS."Amount Including VAT" := AmountInclVAT;
            POSPaymentLine.InsertPaymentLine(PaymentLinePOS, 0);
        end;
    end;

    procedure CalcVATFromSale(SalePOS: Record "NPR POS Sale"): Decimal
    var
        SaleLinePOS: Record "NPR POS Sale Line";
    begin
        SaleLinePOS.Reset();
        SaleLinePOS.SetRange("Register No.", SalePOS."Register No.");
        SaleLinePOS.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");
        SaleLinePOS.SetRange(Date, SalePOS.Date);
        SaleLinePOS.SetFilter("Line Type", '<>%1', SaleLinePOS."Line Type"::"POS Payment");
        if SaleLinePOS.IsEmpty() then
            exit;

        SaleLinePOS.CalcSums("Amount Including VAT", "VAT Base Amount");
        exit(SaleLinePOS."Amount Including VAT" - SaleLinePOS."VAT Base Amount");
    end;

    procedure ValidateMinMaxAmount(NPRPOSPaymentMethod: Record "NPR POS Payment Method"; AmountToCapture: Decimal)
    var
        MaxAmountLimit: Label 'Maximum payment amount for %1 is %2.';
    begin

        if (NPRPOSPaymentMethod."Maximum Amount" <> 0) then
            if (AmountToCapture > NPRPOSPaymentMethod."Maximum Amount") then
                Error(MaxAmountLimit, NPRPOSPaymentMethod.Description, NPRPOSPaymentMethod."Maximum Amount");

        if (NPRPOSPaymentMethod."Minimum Amount" <> 0) then
            if (AmountToCapture < NPRPOSPaymentMethod."Minimum Amount") then
                Error(MaxAmountLimit, NPRPOSPaymentMethod.Description, NPRPOSPaymentMethod."Minimum Amount");
    end;

    internal procedure IfRefusionExist(NPRPOSPaymentMethod: Record "NPR POS Payment Method"; TotalVATOnSale: Decimal) RefusionExist: Boolean;
    var
        PaymentLinePOS: Record "NPR POS Sale Line";
        POSSession: Codeunit "NPR POS Session";
        AlreadyExitErrLbl: Label 'VAT Refusion line already exist.';
        AlreadyExistConfLbl: Label 'VAT Refusion line already exist. Do you want to update an exiting line?';
        SalePOS: Record "NPR POS Sale";
        POSSale: Codeunit "NPR POS Sale";
    begin
        RefusionExist := false;

        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);

        PaymentLinePOS.SetRange("Register No.", SalePOS."Register No.");
        PaymentLinePOS.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");
        PaymentLinePOS.SetRange("Line Type", PaymentLinePOS."Line Type"::"POS Payment");
        PaymentLinePOS.SetRange("No.", NPRPOSPaymentMethod.Code);
        if PaymentLinePOS.FindFirst() then begin
            RefusionExist := true;
            if (PaymentLinePOS."Amount Including VAT" = TotalVATOnSale) then
                Error(AlreadyExitErrLbl)
            else
                if Confirm(AlreadyExistConfLbl) then begin
                    PaymentLinePOS."Amount Including VAT" := TotalVATOnSale;
                    PaymentLinePOS."Currency Amount" := TotalVATOnSale;
                    PaymentLinePOS.Modify(true);
                end;
        end;
    end;
}

