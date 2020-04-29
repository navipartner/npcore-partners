codeunit 6059947 "CashKeeper Capture"
{
    // NPR5.29\CLVA\20161108 CASE NPR5.29 Object Created

    TableNo = "Sale Line POS";

    trigger OnRun()
    var
        CashKeeperAPI: Codeunit "CashKeeper API";
    begin
        CashKeeperAPI.CallCaptureStart(Rec);
    end;

    var
        ProxyDialog: Page "Proxy Dialog";
}

