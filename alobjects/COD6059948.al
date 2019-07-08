codeunit 6059948 "CashKeeper PayOut"
{
    // NPR5.29\CLVA\20161108 CASE NPR5.29 Object Created

    TableNo = "Sale Line POS";

    trigger OnRun()
    var
        CashKeeperAPI: Codeunit "CashKeeper API";
    begin
        CashKeeperAPI.CallPayOutStart(Rec);
    end;
}

