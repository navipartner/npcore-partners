page 6185015 "NPR HU L POS Unit Mapp. Step"
{
    Extensible = False;
    Caption = 'HU Laurel POS Unit Mapping';
    PageType = ListPart;
    SourceTable = "NPR HU L POS Unit Mapping";
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
                field("Laurel Licence"; Rec."Laurel License")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Laurel License field.';
                }
                field("POS FCU Day Status"; Rec."POS FCU Day Status")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the POS FCU Day Status field.';
                }
            }
        }
    }

    internal procedure CopyRealToTemp()
    begin
        if not HULPOSUnitMapping.FindSet() then
            exit;
        repeat
            Rec.TransferFields(HULPOSUnitMapping);
            if not Rec.Insert() then
                Rec.Modify();
        until HULPOSUnitMapping.Next() = 0;
    end;

    internal procedure IsDataSet(): Boolean
    begin
        Rec.SetFilter("Laurel License", '<>''''');
        exit(not Rec.IsEmpty());
    end;

    internal procedure CreatePOSUnitMappingData()
    begin
        if not Rec.FindSet() then
            exit;
        repeat
            HULPOSUnitMapping.TransferFields(Rec);
            if not HULPOSUnitMapping.Insert() then
                HULPOSUnitMapping.Modify();
        until Rec.Next() = 0;
    end;

    var
        HULPOSUnitMapping: Record "NPR HU L POS Unit Mapping";
}