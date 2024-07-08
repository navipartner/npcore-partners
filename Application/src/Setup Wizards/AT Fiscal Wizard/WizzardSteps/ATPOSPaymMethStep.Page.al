page 6184679 "NPR AT POS Paym. Meth. Step"
{
    Extensible = False;
    Caption = 'AT POS Payment Method Mapping';
    PageType = ListPart;
    SourceTable = "NPR AT POS Payment Method Map";
    SourceTableTemporary = true;
    UsageCategory = None;

    layout
    {
        area(Content)
        {
            repeater(Repeater)
            {
                field("POS Payment Method Code"; Rec."POS Payment Method Code")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the POS Payment Method.';
                }
                field("AT Payment Type"; Rec."AT Payment Type")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the Payment Type that is possible to use in Austria.';
                }
            }
        }
    }

    internal procedure CopyToTemp()
    var
        ATPOSPaymentMethodMap: Record "NPR AT POS Payment Method Map";
    begin
        if not ATPOSPaymentMethodMap.FindSet() then
            exit;

        repeat
            Rec.TransferFields(ATPOSPaymentMethodMap);
            if not Rec.Insert() then
                Rec.Modify();
        until ATPOSPaymentMethodMap.Next() = 0;
    end;

    internal procedure IsDataPopulated(): Boolean
    begin
        exit(CheckIsDataPopulated());
    end;

    internal procedure CreatePOSPaymentMethodMappingData()
    var
        ATPOSPaymentMethodMap: Record "NPR AT POS Payment Method Map";
    begin
        if not Rec.FindSet() then
            exit;

        repeat
            ATPOSPaymentMethodMap.TransferFields(Rec);
            if not ATPOSPaymentMethodMap.Insert() then
                ATPOSPaymentMethodMap.Modify();
        until Rec.Next() = 0;
    end;

    local procedure CheckIsDataPopulated(): Boolean
    begin
        if not Rec.FindSet() then
            exit(false);

        repeat
            if (Rec."POS Payment Method Code" = '') or (Rec."AT Payment Type" = Rec."AT Payment Type"::" ") then
                exit(false);
        until Rec.Next() = 0;

        exit(true);
    end;
}