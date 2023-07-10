codeunit 6151331 "NPR POS Action - Insert Comm B"
{
    Access = Internal;

    procedure InputPosCommentLine(NewDesc: Text[100]; SaleLine: codeunit "NPR POS Sale Line")
    var
        POSSaleLine: Record "NPR POS Sale Line";
    begin
        POSSaleLine."Line Type" := POSSaleLine."Line Type"::Comment;
        POSSaleLine.Description := NewDesc;

        SaleLine.InsertLine(POSSaleLine);
    end;
}