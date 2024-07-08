page 6151519 "NPR BG SIS Return Reason Step"
{
    Extensible = False;
    Caption = 'BG SIS Return Reason Mapping';
    PageType = ListPart;
    SourceTable = "NPR BG SIS Return Reason Map";
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
                field("BG SIS Return Reason"; Rec."BG SIS Return Reason")
                {
                    ApplicationArea = NPRBGSISFiscal;
                    ToolTip = 'Specifies the Return Reason that is possible to use in Bulgaria.';
                }
            }
        }
    }

    internal procedure CopyToTemp()
    begin
        if not BGSISReturnReasonMap.FindSet() then
            exit;

        repeat
            Rec.TransferFields(BGSISReturnReasonMap);
            if not Rec.Insert() then
                Rec.Modify();
        until BGSISReturnReasonMap.Next() = 0;
    end;

    internal procedure IsDataPopulated(): Boolean
    begin
        exit(CheckIsDataPopulated());
    end;

    internal procedure CreateReturnReasonMappingData()
    begin
        if not Rec.FindSet() then
            exit;

        repeat
            BGSISReturnReasonMap.TransferFields(Rec);
            if not BGSISReturnReasonMap.Insert() then
                BGSISReturnReasonMap.Modify();
        until Rec.Next() = 0;
    end;

    local procedure CheckIsDataPopulated(): Boolean
    begin
        if not Rec.FindSet() then
            exit(false);

        repeat
            if (Rec."Return Reason Code" = '') or (Rec."BG SIS Return Reason" = Rec."BG SIS Return Reason"::" ") then
                exit(false);
        until Rec.Next() = 0;

        exit(true);
    end;

    var
        BGSISReturnReasonMap: Record "NPR BG SIS Return Reason Map";
}