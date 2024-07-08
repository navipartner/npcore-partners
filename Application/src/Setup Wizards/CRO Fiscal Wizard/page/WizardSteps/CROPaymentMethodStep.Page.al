page 6151465 "NPR CRO Payment Method Step"
{
    Extensible = False;
    Caption = 'CRO Payment Method Mapping';
    PageType = ListPart;
    SourceTable = "NPR CRO Payment Method Mapping";
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
                field("Payment Method"; Rec."CRO Payment Method")
                {
                    ApplicationArea = NPRCROFiscal;
                    ToolTip = 'Specifies the value of the CRO Payment Method Mapping.';
                }
            }
        }
    }

    internal procedure CopyRealToTemp()
    begin
        if not CROPaymentMethodMapp.FindSet() then
            exit;
        repeat
            Rec.TransferFields(CROPaymentMethodMapp);
            if not Rec.Insert() then
                Rec.Modify();
        until CROPaymentMethodMapp.Next() = 0;
    end;

    internal procedure CROPaymentMethodMappingDataToCreate(): Boolean
    begin
        exit(CheckIsDataSet());
    end;

    internal procedure CreatePaymMethodMappingData()
    begin
        if not Rec.FindSet() then
            exit;
        repeat
            CROPaymentMethodMapp.TransferFields(Rec);
            if not CROPaymentMethodMapp.Insert() then
                CROPaymentMethodMapp.Modify();
        until Rec.Next() = 0;
    end;

    local procedure CheckIsDataSet(): Boolean
    begin
        if not Rec.FindFirst() then
            exit(false);
        exit(Rec."Payment Method Code" <> '');
    end;

    var
        CROPaymentMethodMapp: Record "NPR CRO Payment Method Mapping";
}