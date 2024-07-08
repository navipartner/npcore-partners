page 6151355 "NPR CRO POS Paym. Method Step"
{
    Extensible = False;
    Caption = 'CRO POS Payment Method Mapping';
    PageType = ListPart;
    SourceTable = "NPR CRO POS Paym. Method Mapp.";
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
                    ApplicationArea = NPRCROFiscal;
                    ToolTip = 'Specifies the Payment Method Code.';
                }
                field("Payment Method"; Rec."Payment Method")
                {
                    ApplicationArea = NPRCROFiscal;
                    ToolTip = 'Specifies the value of the CRO Payment Method Mapping.';
                }
            }
        }
    }

    internal procedure CopyRealToTemp()
    begin
        if not CROPOSPaymentMethodMapp.FindSet() then
            exit;
        repeat
            Rec.TransferFields(CROPOSPaymentMethodMapp);
            if not Rec.Insert() then
                Rec.Modify();
        until CROPOSPaymentMethodMapp.Next() = 0;
    end;

    internal procedure CROPOSPaymentMethodMappingDataToCreate(): Boolean
    begin
        exit(CheckIsDataSet());
    end;

    internal procedure CreatePOSPaymMethodMappingData()
    begin
        if not Rec.FindSet() then
            exit;
        repeat
            CROPOSPaymentMethodMapp.TransferFields(Rec);
            if not CROPOSPaymentMethodMapp.Insert() then
                CROPOSPaymentMethodMapp.Modify();
        until Rec.Next() = 0;
    end;

    local procedure CheckIsDataSet(): Boolean
    begin
        if not Rec.FindFirst() then
            exit(false);
        exit(Rec."Payment Method Code" <> '');
    end;

    var
        CROPOSPaymentMethodMapp: Record "NPR CRO POS Paym. Method Mapp.";
}