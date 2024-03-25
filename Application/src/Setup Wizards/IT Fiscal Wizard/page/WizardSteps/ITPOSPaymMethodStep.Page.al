page 6184543 "NPR IT POS Paym. Method Step"
{
    Extensible = False;
    Caption = 'IT POS Payment Method Mapping';
    PageType = ListPart;
    SourceTable = "NPR IT POS Paym. Method Mapp.";
    SourceTableTemporary = true;
    UsageCategory = None;

    layout
    {
        area(Content)
        {
            repeater(PaymentMethodMappingLines)
            {
                field("POS Unit No."; Rec."POS Unit No.")
                {
                    ApplicationArea = NPRITFiscal;
                    ToolTip = 'Specifies the value of the POS Unit No. field.';
                }
                field("Payment Method Code"; Rec."Payment Method Code")
                {
                    ApplicationArea = NPRITFiscal;
                    ToolTip = 'Specifies the POS Payment Method Code.';
                }
                field("IT Payment Method"; Rec."IT Payment Method")
                {
                    ApplicationArea = NPRITFiscal;
                    ToolTip = 'Specifies the value of the IT Payment Method field.';
                }
                field("IT Payment Method Index"; Rec."IT Payment Method Index")
                {
                    ApplicationArea = NPRITFiscal;
                    ToolTip = 'Specifies the value of the IT Payment Method Index field.';
                }
            }
        }
    }

    trigger OnDeleteRecord(): Boolean
    begin
        ITPOSPaymentMethodMapp.SetRange("POS Unit No.", Rec."POS Unit No.");
        ITPOSPaymentMethodMapp.SetRange("Payment Method Code", Rec."Payment Method Code");
        if not ITPOSPaymentMethodMapp.FindFirst() then
            exit;
        ITPOSPaymentMethodMapp.Delete();
    end;

    trigger OnModifyRecord(): Boolean
    begin
        ITPOSPaymentMethodMapp.SetRange("POS Unit No.", Rec."POS Unit No.");
        ITPOSPaymentMethodMapp.SetRange("Payment Method Code", Rec."Payment Method Code");
        if not ITPOSPaymentMethodMapp.FindFirst() then
            exit;
        ITPOSPaymentMethodMapp.TransferFields(Rec);
        ITPOSPaymentMethodMapp.Modify();
    end;

    internal procedure CopyRealToTemp()
    begin
        if not ITPOSPaymentMethodMapp.FindSet() then
            exit;
        repeat
            Rec.TransferFields(ITPOSPaymentMethodMapp);
            if not Rec.Insert() then
                Rec.Modify();
        until ITPOSPaymentMethodMapp.Next() = 0;
    end;

    internal procedure ITPOSPaymentMethodMappingDataToCreate(): Boolean
    begin
        exit(CheckIsDataSet());
    end;

    internal procedure CreatePOSPaymMethodMappingData()
    begin
        if not Rec.FindSet() then
            exit;
        repeat
            ITPOSPaymentMethodMapp.TransferFields(Rec);
            if not ITPOSPaymentMethodMapp.Insert() then
                ITPOSPaymentMethodMapp.Modify();
        until Rec.Next() = 0;
    end;

    local procedure CheckIsDataSet(): Boolean
    begin
        if not Rec.FindSet() then
            exit(false);
        repeat
            if (Rec."Payment Method Code" <> '') then
                exit(true);
        until Rec.Next() = 0;
    end;

    var
        ITPOSPaymentMethodMapp: Record "NPR IT POS Paym. Method Mapp.";
}