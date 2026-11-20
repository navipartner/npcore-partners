codeunit 6151331 "NPR POS Action - Insert Comm B"
{
    Access = Internal;

    procedure InputPosCommentLine(CommentDescription: Text[100]; POSSaleLine: Codeunit "NPR POS Sale Line")
    begin
        InputPosCommentLine(CommentDescription, false, POSSaleLine);
    end;

    procedure InputPosCommentLine(CommentDescription: Text[100]; Indent: Boolean; POSSaleLine: Codeunit "NPR POS Sale Line")
    var
        SaleLinePOS: Record "NPR POS Sale Line";
        TargetSaleLinePOS: Record "NPR POS Sale Line";
        SaleLinePOSAddOn: Record "NPR NpIa SaleLinePOS AddOn";
        NewLineNo: Integer;
    begin
        if Indent then
            if FindCommentTarget(POSSaleLine, TargetSaleLinePOS) then
                NewLineNo := AttachedCommentLineNo(TargetSaleLinePOS);

        POSSaleLine.GetNewSaleLine(SaleLinePOS);
        SaleLinePOS."Line Type" := SaleLinePOS."Line Type"::Comment;
        SaleLinePOS.Description := CommentDescription;
        SaleLinePOS."No." := '*';

        if NewLineNo <> 0 then begin
            SaleLinePOS."Line No." := NewLineNo;
            SaleLinePOS.Indentation := TargetSaleLinePOS.Indentation + 1;

            SaleLinePOSAddOn.Init();
            SaleLinePOSAddOn."Register No." := SaleLinePOS."Register No.";
            SaleLinePOSAddOn."Sales Ticket No." := SaleLinePOS."Sales Ticket No.";
            SaleLinePOSAddOn."Sale Date" := SaleLinePOS.Date;
            SaleLinePOSAddOn."Sale Line No." := SaleLinePOS."Line No.";
            SaleLinePOSAddOn."Line No." := 10000;
            SaleLinePOSAddOn."Applies-to Line No." := TargetSaleLinePOS."Line No.";
            SaleLinePOSAddOn.Insert(true);
        end;

        POSSaleLine.InsertLineRaw(SaleLinePOS, false);
    end;

    local procedure FindCommentTarget(POSSaleLine: Codeunit "NPR POS Sale Line"; var TargetSaleLinePOS: Record "NPR POS Sale Line"): Boolean
    var
        SaleLinePOSAddOn: Record "NPR NpIa SaleLinePOS AddOn";
        ItemAddOnMgt: Codeunit "NPR NpIa Item AddOn Mgt.";
    begin
        if not POSSaleLine.RefreshCurrent() then
            exit(false);
        POSSaleLine.GetCurrentSaleLine(TargetSaleLinePOS);

        if (TargetSaleLinePOS."Line Type" = TargetSaleLinePOS."Line Type"::Item) and not (TargetSaleLinePOS."No." in ['', '*']) then
            exit(true);
        if TargetSaleLinePOS."Line Type" <> TargetSaleLinePOS."Line Type"::Comment then
            exit(false);

        ItemAddOnMgt.FilterSaleLinePOS2ItemAddOnPOSLine(TargetSaleLinePOS, SaleLinePOSAddOn);
        SaleLinePOSAddOn.SetFilter("Applies-to Line No.", '<>%1', 0);
        if not SaleLinePOSAddOn.FindFirst() then
            exit(false);
        exit(TargetSaleLinePOS.Get(
            TargetSaleLinePOS."Register No.", TargetSaleLinePOS."Sales Ticket No.", TargetSaleLinePOS.Date, TargetSaleLinePOS."Sale Type", SaleLinePOSAddOn."Applies-to Line No."));
    end;

    local procedure AttachedCommentLineNo(TargetSaleLinePOS: Record "NPR POS Sale Line"): Integer
    var
        NextSaleLinePOS: Record "NPR POS Sale Line";
        LastGroupLineNo: Integer;
        NewLineNo: Integer;
        NoFreeLineNoErr: Label 'Autosplit key can''t insert the new line %1 as it already exists. Highlight a different line before selling next item.', Comment = '%1 = line number';
    begin
        LastGroupLineNo := LastLineNoOfGroup(TargetSaleLinePOS, TargetSaleLinePOS."Line No.");

        NextSaleLinePOS.SetCurrentKey("Register No.", "Sales Ticket No.", "Line No.");
        NextSaleLinePOS.SetRange("Register No.", TargetSaleLinePOS."Register No.");
        NextSaleLinePOS.SetRange("Sales Ticket No.", TargetSaleLinePOS."Sales Ticket No.");
        NextSaleLinePOS.SetFilter("Line No.", '>%1', LastGroupLineNo);
        if not NextSaleLinePOS.FindFirst() then
            exit(LastGroupLineNo + 10000);

        NewLineNo := Round((NextSaleLinePOS."Line No." - LastGroupLineNo) / 2, 1) + LastGroupLineNo;
        if NewLineNo = NextSaleLinePOS."Line No." then
            Error(NoFreeLineNoErr, NewLineNo);
        exit(NewLineNo);
    end;

    local procedure LastLineNoOfGroup(SaleLinePOS: Record "NPR POS Sale Line"; LineNo: Integer): Integer
    var
        VisitedLineNos: List of [Integer];
    begin
        exit(LastLineNoOfGroup(SaleLinePOS, LineNo, VisitedLineNos));
    end;

    local procedure LastLineNoOfGroup(SaleLinePOS: Record "NPR POS Sale Line"; LineNo: Integer; var VisitedLineNos: List of [Integer]) LastLineNo: Integer
    var
        SaleLinePOSAddOn: Record "NPR NpIa SaleLinePOS AddOn";
        ItemAddOnMgt: Codeunit "NPR NpIa Item AddOn Mgt.";
        ChildLastLineNo: Integer;
    begin
        LastLineNo := LineNo;
        //Each line is walked once, so a cycle in corrupt link data cannot recurse without end
        if VisitedLineNos.Contains(LineNo) then
            exit;
        VisitedLineNos.Add(LineNo);
        ItemAddOnMgt.FilterAttachedItemAddonLines(SaleLinePOS, LineNo, SaleLinePOSAddOn);
        if SaleLinePOSAddOn.FindSet() then
            repeat
                ChildLastLineNo := LastLineNoOfGroup(SaleLinePOS, SaleLinePOSAddOn."Sale Line No.", VisitedLineNos);
                if ChildLastLineNo > LastLineNo then
                    LastLineNo := ChildLastLineNo;
            until SaleLinePOSAddOn.Next() = 0;
    end;
}