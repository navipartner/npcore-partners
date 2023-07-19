codeunit 6151331 "NPR POS Action - Insert Comm B"
{
    Access = Internal;

    procedure InputPosCommentLine(CommentDescription: Text[100]; POSSaleLine: Codeunit "NPR POS Sale Line")
    var
        SaleLinePOS: Record "NPR POS Sale Line";
    begin
        POSSaleLine.GetNewSaleLine(SaleLinePOS);

        SaleLinePOS."Line Type" := SaleLinePOS."Line Type"::Comment;
        SaleLinePOS.Description := CommentDescription;

        POSSaleLine.InsertLineRaw(SaleLinePOS, false);
    end;
}