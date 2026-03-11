#if not (BC17 or BC18 or BC19 or BC20 or BC21 or BC22)
codeunit 6248628 "NPR API POS Delta Builder"
{
    Access = Internal;

    var
        _RefreshSaleLine: Codeunit "NPR POS Refresh Sale Line";
        _RefreshPaymentLine: Codeunit "NPR POS Refresh Payment Line";
        _RefreshSale: Codeunit "NPR POS Refresh Sale";

    procedure StartDataCollection()
    begin
        BindSubscription(_RefreshSale);
        BindSubscription(_RefreshSaleLine);
        BindSubscription(_RefreshPaymentLine);
    end;

    procedure BuildDeltaResponse() Json: JsonObject
    var
        POSSession: Codeunit "NPR POS Session";
        POSSale: Codeunit "NPR POS Sale";
        POSSaleRec: Record "NPR POS Sale";
        PaymentRows: Dictionary of [Text, Text];
        SaleLineRows: Dictionary of [Text, Text];
        APIPOSSale: Codeunit "NPR API POS Sale";
    begin
        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(POSSaleRec);

        SaleLineRows := _RefreshSaleLine.GetRows();
        PaymentRows := _RefreshPaymentLine.GetRows();

        exit(APIPOSSale.POSSaleAsJson(POSSaleRec, true, true, SaleLineRows.Keys(), PaymentRows.Keys()).Build());
    end;

}
#endif
