page 6151474 "NPR RS Payment Method Step"
{
    Extensible = False;
    Caption = 'RS Payment Method Mapping';
    PageType = ListPart;
    SourceTable = "NPR RS Payment Method Mapping";
    SourceTableTemporary = true;
    UsageCategory = None;

    layout
    {
        area(Content)
        {
            repeater(PaymentMethodMappingLines)
            {
                field("Payment Method Code"; Rec."Payment Method Code")
                {
                    ApplicationArea = NPRRSFiscal;
                    ToolTip = 'Specifies the Payment Method Code.';
                }
                field("Payment Method"; Rec."RS Payment Method")
                {
                    ApplicationArea = NPRRSFiscal;
                    ToolTip = 'Specifies the value of the RS Payment Method Mapping.';
                }
            }
        }
    }

    internal procedure CopyRealToTemp()
    begin
        if not RSPaymentMethodMapp.FindSet() then
            exit;
        repeat
            Rec.TransferFields(RSPaymentMethodMapp);
            if not Rec.Insert() then
                Rec.Modify();
        until RSPaymentMethodMapp.Next() = 0;
    end;

    internal procedure RSPaymentMethodMappingDataToCreate(): Boolean
    begin
        exit(CheckIsDataSet());
    end;

    internal procedure CreatePaymMethodMappingData()
    begin
        if not Rec.FindSet() then
            exit;
        repeat
            RSPaymentMethodMapp.TransferFields(Rec);
            if not RSPaymentMethodMapp.Insert() then
                RSPaymentMethodMapp.Modify();
        until Rec.Next() = 0;
    end;

    local procedure CheckIsDataSet(): Boolean
    begin
        if not Rec.FindFirst() then
            exit(false);
        exit(Rec."Payment Method Code" <> '');
    end;

    var
        RSPaymentMethodMapp: Record "NPR RS Payment Method Mapping";
}