page 6151424 "NPR RS POS Paym. Meth. Step"
{
    Extensible = False;
    Caption = 'RS POS Payment Method Setup';
    PageType = ListPart;
    SourceTable = "NPR RS POS Paym. Meth. Mapping";
    SourceTableTemporary = true;
    UsageCategory = None;

    layout
    {
        area(Content)
        {
            repeater(POSPaymentMethodMappingLines)
            {
                field("Payment Method Code"; Rec."POS Payment Method Code")
                {
                    ApplicationArea = NPRRSFiscal;
                    ToolTip = 'Specifies the value of the Payment Method Code field.';
                }
                field("RS Payment Method"; Rec."RS Payment Method")
                {
                    ApplicationArea = NPRRSFiscal;
                    ToolTip = 'Specifies the value of the RS Payment Method field.';
                }
            }
        }
    }

    internal procedure CopyRealToTemp()
    begin
        if not RSPOSPaymentMethodMapp.FindSet() then
            exit;
        repeat
            Rec.TransferFields(RSPOSPaymentMethodMapp);
            if not Rec.Insert() then
                Rec.Modify();
        until RSPOSPaymentMethodMapp.Next() = 0;
    end;

    internal procedure RSPOSPaymentMethodMappingDataToCreate(): Boolean
    begin
        exit(CheckIsDataSet());
    end;

    internal procedure CreatePOSPaymMethodMappingData()
    begin
        if not Rec.FindSet() then
            exit;
        repeat
            RSPOSPaymentMethodMapp.TransferFields(Rec);
            if not RSPOSPaymentMethodMapp.Insert() then
                RSPOSPaymentMethodMapp.Modify();
        until Rec.Next() = 0;
    end;

    local procedure CheckIsDataSet(): Boolean
    begin
        if not Rec.FindFirst() then
            exit(false);
        exit(Rec."POS Payment Method Code" <> '');
    end;

    var
        RSPOSPaymentMethodMapp: Record "NPR RS POS Paym. Meth. Mapping";
}