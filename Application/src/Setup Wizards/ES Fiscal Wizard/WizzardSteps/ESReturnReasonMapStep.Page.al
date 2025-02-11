page 6184769 "NPR ES Return Reason Map Step"
{
    Extensible = False;
    Caption = 'ES Return Reason Mapping';
    PageType = ListPart;
    SourceTable = "NPR ES Return Reason Mapping";
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
                field("ES Return Reason"; Rec."ES Return Reason")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the Return Reason that is possible to use in Spain.';
                }
            }
        }
    }

    internal procedure CopyToTemp()
    var
        ESReturnReasonMapping: Record "NPR ES Return Reason Mapping";
    begin
        if not ESReturnReasonMapping.FindSet() then
            exit;

        repeat
            Rec.TransferFields(ESReturnReasonMapping);
            if not Rec.Insert() then
                Rec.Modify();
        until ESReturnReasonMapping.Next() = 0;
    end;

    internal procedure IsDataPopulated(): Boolean
    begin
        exit(CheckIsDataPopulated());
    end;

    internal procedure CreateReturnReasonMappingData()
    var
        ESReturnReasonMapping: Record "NPR ES Return Reason Mapping";
    begin
        if not Rec.FindSet() then
            exit;

        repeat
            ESReturnReasonMapping.TransferFields(Rec);
            if not ESReturnReasonMapping.Insert() then
                ESReturnReasonMapping.Modify();
        until Rec.Next() = 0;
    end;

    local procedure CheckIsDataPopulated(): Boolean
    begin
        if not Rec.FindSet() then
            exit(false);

        repeat
            if (Rec."Return Reason Code" = '') or (Rec."ES Return Reason" = Rec."ES Return Reason"::" ") then
                exit(false);
        until Rec.Next() = 0;

        exit(true);
    end;
}