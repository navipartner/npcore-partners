page 6185010 "NPR HU L Return Reason Step"
{
    Extensible = False;
    Caption = 'HU Laurel Return Reason Mapping';
    PageType = ListPart;
    SourceTable = "NPR HU L Return Reason Mapp.";
    SourceTableTemporary = true;
    UsageCategory = None;

    layout
    {
        area(Content)
        {
            repeater(Repeater)
            {
                field("Return Reason Code"; Rec."Return Reason Code")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the Return Reason Code.';
                }
                field("HU L Return Reason Code"; Rec."HU L Return Reason Code")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the Return Reason that is possible to use in Laurel fiscal control units.';
                }
            }
        }
    }

    internal procedure CopyRealToTemp()
    begin
        if not HULReturnReasonMapp.FindSet() then
            exit;

        repeat
            Rec.TransferFields(HULReturnReasonMapp);
            if not Rec.Insert() then
                Rec.Modify();
        until HULReturnReasonMapp.Next() = 0;
    end;

    internal procedure IsDataPopulated(): Boolean
    begin
        Rec.SetFilter("HU L Return Reason Code", '<>%1', Rec."HU L Return Reason Code"::" ");
        exit(not Rec.IsEmpty());
    end;

    internal procedure CreateReturnReasonMappingData()
    begin
        if not Rec.FindSet() then
            exit;

        repeat
            HULReturnReasonMapp.TransferFields(Rec);
            if not HULReturnReasonMapp.Insert() then
                HULReturnReasonMapp.Modify();
        until Rec.Next() = 0;
    end;

    var
        HULReturnReasonMapp: Record "NPR HU L Return Reason Mapp.";
}