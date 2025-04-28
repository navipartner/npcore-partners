page 6185006 "NPR HUL POS Paym Meth Map Step"
{
    Caption = 'HU Laurel POS Payment Method Mapping';
    UsageCategory = None;
    PageType = ListPart;
    SourceTable = "NPR HU L POS Paym. Meth. Mapp.";
    SourceTableTemporary = true;
    Extensible = false;

    layout
    {
        area(Content)
        {
            repeater(PaymentMethodMappingLines)
            {
                field("POS Payment Method Code"; Rec."POS Payment Method Code")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the POS Payment Method Code field.';
                }
                field("Payment Fiscal Type"; Rec."Payment Fiscal Type")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Payment Fiscal Type field.';
                }
                field("Payment Fiscal Subtype"; Rec."Payment Fiscal Subtype")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Payment Fiscal Subtype field.';
                }
                field("Payment Currency Type"; Rec."Payment Currency Type")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Payment Currency Type field.';
                }
            }
        }
    }

    internal procedure CopyRealToTemp()
    begin
        if not HULPOSPaymMethMapp.FindSet() then
            exit;
        repeat
            Rec.TransferFields(HULPOSPaymMethMapp);
            if not Rec.Insert() then
                Rec.Modify();
        until HULPOSPaymMethMapp.Next() = 0;
    end;

    internal procedure IsDataPopulated(): Boolean
    begin
        exit(not Rec.IsEmpty());
    end;

    internal procedure CreatePOSPaymMethodMappingData()
    begin
        if not Rec.FindSet() then
            exit;
        repeat
            HULPOSPaymMethMapp.TransferFields(Rec);
            if not HULPOSPaymMethMapp.Insert() then
                HULPOSPaymMethMapp.Modify();
        until Rec.Next() = 0;
    end;

    var
        HULPOSPaymMethMapp: Record "NPR HU L POS Paym. Meth. Mapp.";
}