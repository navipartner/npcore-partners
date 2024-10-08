page 6150839 "NPR HU MS POS Paym. Meth. Step"
{
    Extensible = False;
    Caption = 'HU MS POS Payment Method Mapping';
    PageType = ListPart;
    SourceTable = "NPR HU MS Payment Method Map.";
    SourceTableTemporary = true;
    UsageCategory = None;

    layout
    {
        area(Content)
        {
            repeater(PaymentMethodMappingLines)
            {
                field("Payment Method"; Rec."Payment Method")
                {
                    ApplicationArea = NPRHUMultiSoftEInv;
                    ToolTip = 'Specifies the value of the Payment Method field.';
                }
                field(Cash; Rec."Cash")
                {
                    ApplicationArea = NPRHUMultiSoftEInv;
                    ToolTip = 'Specifies the value of the Cash field.';
                }
                field(Card; Rec."Card")
                {
                    ApplicationArea = NPRHUMultiSoftEInv;
                    ToolTip = 'Specifies the value of the Card field.';
                }
                field(Voucher; Rec."Voucher")
                {
                    ApplicationArea = NPRHUMultiSoftEInv;
                    ToolTip = 'Specifies the value of the Voucher field.';
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        if not Rec.Get() then begin
            Rec.Init();
            Rec.Insert();
        end;
    end;

    internal procedure CopyRealToTemp()
    begin
        if not HUMSPOSPaymentMethodMapp.FindSet() then
            exit;
        repeat
            Rec.TransferFields(HUMSPOSPaymentMethodMapp);
            if not Rec.Insert() then
                Rec.Modify();
        until HUMSPOSPaymentMethodMapp.Next() = 0;
    end;

    internal procedure HUMSPOSPaymentMethodMappingDataToCreate(): Boolean
    begin
        exit(CheckIsDataSet());
    end;

    internal procedure CreatePOSPaymMethodMappingData()
    begin
        if not Rec.FindSet() then
            exit;
        repeat
            HUMSPOSPaymentMethodMapp.TransferFields(Rec);
            if not HUMSPOSPaymentMethodMapp.Insert() then
                HUMSPOSPaymentMethodMapp.Modify();
        until Rec.Next() = 0;
    end;

    local procedure CheckIsDataSet(): Boolean
    begin
        if not Rec.FindSet() then
            exit(false);
        repeat
            if (Rec."Payment Method" <> '') then
                exit(true);
        until Rec.Next() = 0;
    end;

    var
        HUMSPOSPaymentMethodMapp: Record "NPR HU MS Payment Method Map.";
}