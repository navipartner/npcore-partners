page 6185005 "NPR HU L POS Paym. Meth. Step"
{
    Caption = 'HU Laurel POS Payment Method';
    UsageCategory = None;
    PageType = ListPart;
    SourceTable = "NPR POS Payment Method";
    SourceTableTemporary = true;
    Extensible = false;

    layout
    {
        area(Content)
        {
            repeater(Methods)
            {
                field("Code"; Rec.Code)
                {
                    ToolTip = 'Specifies the Code of the selected POS Payment Method.';
                    ApplicationArea = NPRRetail;
                }
                field("Processing Type"; Rec."Processing Type")
                {
                    ToolTip = 'Specifies the payment method processing type. Cash is for bills and coins in all currencies. Voucher is used for gift cards, coupons and vouchers. Check is used for checks. EFT is used for credit and debit card payments. Customer is currently not supported. Payout is used for cash movements, for example Payin/Payout to/from thePOS.';
                    ApplicationArea = NPRRetail;
                }
                field("Currency Code"; Rec."Currency Code")
                {
                    ToolTip = 'Specifies the Currency Code if the POS Payment Method is for a foreign currency.';
                    ApplicationArea = NPRRetail;
                }
                field("Rounding Precision"; Rec."Rounding Precision")
                {
                    ToolTip = 'Specifies the decimal precision for rounding.';
                    ApplicationArea = NPRRetail;
                }
                field("Rounding Type"; Rec."Rounding Type")
                {
                    ToolTip = 'Specifies the type of rounding to be applied.';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }

    internal procedure CopyRealToTemp()
    begin
        POSPaymentMethod.SetRange("Processing Type", POSPaymentMethod."Processing Type"::CASH);
        if POSPaymentMethod.FindSet() then
            repeat
                Rec.TransferFields(POSPaymentMethod);
                if not Rec.Insert() then
                    Rec.Modify();
            until POSPaymentMethod.Next() = 0;
    end;

    internal procedure IsDataPopulated(): Boolean
    begin
        Rec.SetRange("Processing Type", Rec."Processing Type"::CASH);
        Rec.SetRange("Rounding Type", Rec."Rounding Type"::Nearest);
        Rec.SetRange("Rounding Precision", 5);
        exit(not Rec.IsEmpty());
    end;

    internal procedure CreatePOSPaymentMethodData()
    begin
        if not Rec.FindSet() then
            exit;
        repeat
            if not POSPaymentMethod.Get(Rec.Code) then begin
                POSPaymentMethod.Init();
                POSPaymentMethod.Code := Rec.Code;
            end;

            POSPaymentMethod."Rounding Precision" := Rec."Rounding Precision";
            POSPaymentMethod."Rounding Type" := Rec."Rounding Type";
            POSPaymentMethod."Processing Type" := Rec."Processing Type";
            POSPaymentMethod."Currency Code" := Rec."Currency Code";

            if not POSPaymentMethod.Insert() then
                POSPaymentMethod.Modify();
        until Rec.Next() = 0;
    end;

    var
        POSPaymentMethod: Record "NPR POS Payment Method";
}