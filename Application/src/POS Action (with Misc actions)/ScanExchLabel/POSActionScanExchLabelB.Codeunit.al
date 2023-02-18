codeunit 6060038 "NPR POS Action:ScanExchLabel B"
{
    Access = Internal;
    procedure HandleExchangeLabelBarcode(iBarcode: Text; POSSale: Codeunit "NPR POS Sale"; POSSaleLine: Codeunit "NPR POS Sale Line")
    var
        ExchangeLabelManagement: Codeunit "NPR Exchange Label Mgt.";
        SalePOS: Record "NPR POS Sale";
        CodeBarcode: Code[20];
        ErrNotExchLabel: Label '%1 ';
    begin

        CodeBarcode := CopyStr(iBarcode, 1, MaxStrLen(CodeBarcode));

        if not BarCodeIsExchangeLabel(CodeBarcode) then
            Error(ErrNotExchLabel, iBarcode);

        POSSale.GetCurrentSale(SalePOS);

        if ExchangeLabelManagement.ScanExchangeLabel(SalePOS, CodeBarcode, CodeBarcode) then
            POSSaleLine.SetFirst();
    end;

    procedure BarCodeIsExchangeLabel(Barcode: Text): Boolean
    var
        ExchangeLabel: Record "NPR Exchange Label";
        ExchangeLabelSetup: Record "NPR Exchange Label Setup";
        ExchangeLabelManagement: Codeunit "NPR Exchange Label Mgt.";
    begin
        if StrLen(Barcode) > MaxStrLen(ExchangeLabel.Barcode) then
            exit(false);

        Barcode := UpperCase(Barcode);
        ExchangeLabelSetup.Get();
        if not ExchangeLabelManagement.CheckPrefix(Barcode, ExchangeLabelSetup."EAN Prefix Exhange Label") then
            exit(false);

        ExchangeLabel.SetCurrentKey(Barcode);
        ExchangeLabel.SetRange(Barcode, Barcode);
        if ExchangeLabel.FindFirst() then
            exit(true);

        exit(false);
    end;
}