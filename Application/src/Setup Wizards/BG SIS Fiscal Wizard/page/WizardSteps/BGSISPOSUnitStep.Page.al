page 6151517 "NPR BG SIS POS Unit Step"
{
    Extensible = False;
    Caption = 'BG SIS POS Unit Mapping';
    PageType = ListPart;
    SourceTable = "NPR BG SIS POS Unit Mapping";
    SourceTableTemporary = true;
    UsageCategory = None;

    layout
    {
        area(Content)
        {
            repeater(Repeater)
            {
                field("POS Unit No."; Rec."POS Unit No.")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the number of the POS unit.';

                    trigger OnValidate()
                    begin
                        Rec.CalcFields("POS Unit Name");
                    end;
                }
                field("POS Unit Name"; Rec."POS Unit Name")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the name of the POS unit.';
                }
                field("Fiscal Printer IP Address"; Rec."Fiscal Printer IP Address")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the IP address of the fiscal printer related to this POS unit.';
                }
                field("Fiscal Printer Device No."; Rec."Fiscal Printer Device No.")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the device number of the fiscal printer related to this POS unit.';
                }
                field("Fiscal Printer Memory No."; Rec."Fiscal Printer Memory No.")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the memory number of the fiscal printer related to this POS unit.';
                }
                field("Extended Receipt Invoice No."; Rec."Extended Receipt Invoice No.")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the No Serie of the Extended Receipt Invoice No. field.';
                }
                field("Extended Receipt Cr. Memo No."; Rec."Extended Receipt Cr. Memo No.")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the No Serie of the Extended Receipt Cr. Memo No. field.';
                }
            }
        }
    }

    internal procedure CopyToTemp()
    begin
        if not BGSISPOSUnitMapping.FindSet() then
            exit;

        repeat
            Rec.TransferFields(BGSISPOSUnitMapping);
            if not Rec.Insert() then
                Rec.Modify();
        until BGSISPOSUnitMapping.Next() = 0;
    end;

    internal procedure IsDataPopulated(): Boolean
    begin
        exit(CheckIsDataPopulated());
    end;

    internal procedure CreatePOSUnitMappingData()
    begin
        if not Rec.FindSet() then
            exit;

        repeat
            BGSISPOSUnitMapping.TransferFields(Rec);
            if not BGSISPOSUnitMapping.Insert() then
                BGSISPOSUnitMapping.Modify();
        until Rec.Next() = 0;
    end;

    local procedure CheckIsDataPopulated(): Boolean
    begin
        if not Rec.FindSet() then
            exit(false);

        repeat
            if (Rec."POS Unit No." = '') or
                (Rec."Fiscal Printer IP Address" = '') or
                (Rec."Extended Receipt Invoice No." = '') or
                (Rec."Extended Receipt Cr. Memo No." = '')
            then
                exit(false);
        until Rec.Next() = 0;

        exit(true);
    end;

    var
        BGSISPOSUnitMapping: Record "NPR BG SIS POS Unit Mapping";
}