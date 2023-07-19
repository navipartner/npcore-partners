codeunit 6150694 "NPR POS Act:TableBuzzerNo BL"
{
    Access = Internal;

    procedure InputPosCommentLine(var POSSaleLine: Codeunit "NPR POS Sale Line"; CommentTextPattern: Text; InputText: Text)
    var
        SaleLinePos: Record "NPR POS Sale Line";
        BuzzerTxt: Label 'Table Buzzer %1';
    begin
        POSSaleLine.GetNewSaleLine(SaleLinePos);

        if CommentTextPattern = '' then
            CommentTextPattern := BuzzerTxt;

        SaleLinePos."Line Type" := SaleLinePos."Line Type"::Comment;
        SaleLinePos.Description := StrSubstNo(CommentTextPattern, InputText);

        POSSaleLine.InsertLineRaw(SaleLinePos, false);
    end;
}