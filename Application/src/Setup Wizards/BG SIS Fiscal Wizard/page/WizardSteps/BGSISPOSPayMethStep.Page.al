page 6151513 "NPR BG SIS POS Pay. Meth. Step"
{
    Extensible = False;
    Caption = 'BG SIS POS Payment Method Mapping';
    PageType = ListPart;
    SourceTable = "NPR BG SIS POS Paym. Meth. Map";
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
                field("BG SIS Payment Method"; Rec."BG SIS Payment Method")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the Payment Method that is possible to use in Bulgaria.';
                }
            }
        }
    }

    internal procedure CopyToTemp()
    begin
        if not BGSISPOSPaymMethMap.FindSet() then
            exit;

        repeat
            Rec.TransferFields(BGSISPOSPaymMethMap);
            if not Rec.Insert() then
                Rec.Modify();
        until BGSISPOSPaymMethMap.Next() = 0;
    end;

    internal procedure IsDataPopulated(): Boolean
    begin
        exit(CheckIsDataPopulated());
    end;

    internal procedure CreatePOSPaymentMethodMappingData()
    begin
        if not Rec.FindSet() then
            exit;

        repeat
            BGSISPOSPaymMethMap.TransferFields(Rec);
            if not BGSISPOSPaymMethMap.Insert() then
                BGSISPOSPaymMethMap.Modify();
        until Rec.Next() = 0;
    end;

    local procedure CheckIsDataPopulated(): Boolean
    begin
        if not Rec.FindSet() then
            exit(false);

        repeat
            if (Rec."POS Payment Method Code" = '') or (Rec."BG SIS Payment Method" = Rec."BG SIS Payment Method"::" ") then
                exit(false);
        until Rec.Next() = 0;

        exit(true);
    end;

    var
        BGSISPOSPaymMethMap: Record "NPR BG SIS POS Paym. Meth. Map";
}