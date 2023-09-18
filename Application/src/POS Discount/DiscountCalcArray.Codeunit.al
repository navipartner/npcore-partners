codeunit 6151477 "NPR Discount Calc Array"
{
    Access = Internal;

    var
        TempGlobalSaleLinePOS: Record "NPR POS Sale Line" temporary;

    internal procedure SetSaleLinePOSBuffer(var FromSaleLinePOS: Record "NPR POS Sale Line")
    begin
        ClearSaleLinePOSBuffer();

        if not FromSaleLinePOS.FindSet(false) then
            exit;

        repeat
            TempGlobalSaleLinePOS.Init();
            TempGlobalSaleLinePOS := FromSaleLinePOS;
            TempGlobalSaleLinePOS.Insert();
        until FromSaleLinePOS.Next() = 0;
    end;

    internal procedure GetSaleLinePOSBuffer(var ToTempSaleLinePOS: Record "NPR POS Sale Line" temporary)
    var
        TempErrorLbl: Label 'The provided parameter must be a temporary table.';
    begin
        if not ToTempSaleLinePOS.IsTemporary then
            Error(TempErrorLbl);

        ToTempSaleLinePOS.Reset();
        if not ToTempSaleLinePOS.IsEmpty then
            ToTempSaleLinePOS.DeleteAll();

        TempGlobalSaleLinePOS.Reset();
        if not TempGlobalSaleLinePOS.FindSet(false) then
            exit;

        repeat
            ToTempSaleLinePOS.Init();
            ToTempSaleLinePOS := TempGlobalSaleLinePOS;
            ToTempSaleLinePOS.Insert();
        until TempGlobalSaleLinePOS.Next() = 0;
    end;

    internal procedure ClearSaleLinePOSBuffer()
    begin
        TempGlobalSaleLinePOS.Reset();
        if not TempGlobalSaleLinePOS.IsEmpty then
            TempGlobalSaleLinePOS.DeleteAll();
    end;
}