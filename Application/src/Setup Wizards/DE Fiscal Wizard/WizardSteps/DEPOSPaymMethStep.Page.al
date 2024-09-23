page 6184747 "NPR DE POS Paym. Meth. Step"
{
    Extensible = False;
    Caption = 'DE POS Payment Method Mapping';
    PageType = ListPart;
    SourceTable = "NPR Payment Method Mapper";
    SourceTableTemporary = true;
    UsageCategory = None;

    layout
    {
        area(Content)
        {
            repeater(Repeater)
            {
                field("POS Payment Method Code"; Rec."POS Payment Method")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the POS Payment Method.';
                }
                field("Fiskaly Payment Type"; Rec."Fiskaly Payment Type")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the Fiskaly Payment Type that is possible to use.';
                }
                field("DSFINVK Payment Type"; Rec."DSFINVK Type")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the DSFINVK Payment Type that is possible to use.';
                }
            }
        }
    }

    internal procedure CopyToTemp()
    var
        DEPOSPaymentMethodMap: Record "NPR Payment Method Mapper";
    begin
        if not DEPOSPaymentMethodMap.FindSet() then
            exit;

        repeat
            Rec.TransferFields(DEPOSPaymentMethodMap);
            if not Rec.Insert() then
                Rec.Modify();
        until DEPOSPaymentMethodMap.Next() = 0;
    end;

    internal procedure IsDataPopulated(): Boolean
    begin
        exit(CheckIsDataPopulated());
    end;

    internal procedure CreatePOSPaymentMethodMappingData()
    var
        DEPOSPaymentMethodMap: Record "NPR Payment Method Mapper";
    begin
        if not Rec.FindSet() then
            exit;

        repeat
            DEPOSPaymentMethodMap.TransferFields(Rec);
            if not DEPOSPaymentMethodMap.Insert() then
                DEPOSPaymentMethodMap.Modify();
        until Rec.Next() = 0;
    end;

    local procedure CheckIsDataPopulated(): Boolean
    begin
        if not Rec.FindSet() then
            exit(false);

        repeat
            if (Rec."POS Payment Method" = '') or (Rec."Fiskaly Payment Type" = Rec."Fiskaly Payment Type"::" ")then
                exit(false);
        until Rec.Next() = 0;

        exit(true);
    end;
}