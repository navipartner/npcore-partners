codeunit 6184625 "NPR POS Action End Sale B"
{
    Access = Internal;

    internal procedure EndSale(POSSale: Codeunit "NPR POS Sale"; POSSession: Codeunit "NPR POS Session"; StartNewSale: Boolean; PaymentMethodCode: Code[20]; EndSaleWithBalancing: Boolean; SelectViewForEndOfSale: Boolean) Success: Boolean
    var
        POSPaymentMethod: Record "NPR POS Payment Method";
        ReturnPOSPaymentMethod: Record "NPR POS Payment Method";
    begin
        if EndSaleWithBalancing then begin
            POSPaymentMethod.Get(PaymentMethodCode);
            ReturnPOSPaymentMethod.Get(POSPaymentMethod."Return Payment Method Code");

            Success := POSSale.TryEndDirectSaleWithBalancing(POSSession, POSPaymentMethod, ReturnPOSPaymentMethod);
        end else begin
            Success := POSSale.TryEndSale(POSSession, StartNewSale);

            if not StartNewSale and SelectViewForEndOfSale then
                POSSale.SelectViewForEndOfSale();
        end;
    end;

    internal procedure LookUpPaymentNoParameter(var POSParameterValue: Record "NPR POS Parameter Value")
    var
        POSPaymentMethod: Record "NPR POS Payment Method";
    begin
        if POSParameterValue.Name <> 'paymentNo' then
            exit;

        if Page.RunModal(0, POSPaymentMethod) <> Action::LookupOK then
            exit;

        POSParameterValue.Value := POSPaymentMethod.Code;
    end;

    internal procedure ValidatePaymentNoParameter(POSParameterValue: Record "NPR POS Parameter Value")
    var
        POSPaymentMethod: Record "NPR POS Payment Method";
    begin
        if POSParameterValue.Name <> 'paymentNo' then
            exit;

        if POSParameterValue.Value = '' then
            exit;

        POSPaymentMethod.Get(POSParameterValue.Value);
    end;
}