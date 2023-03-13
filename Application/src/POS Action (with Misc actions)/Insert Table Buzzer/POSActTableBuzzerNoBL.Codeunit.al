codeunit 6150694 "NPR POS Act:TableBuzzerNo BL"
{
    Access = Internal;
    procedure InputPosCommentLine(var SaleLine: Codeunit "NPR POS Sale Line"; CommentTextPattern: Text; InputText: Text)
    var
        Line: Record "NPR POS Sale Line";
        BuzzerText: Label 'Table Buzzer %1';
    begin
        if CommentTextPattern = '' then
            CommentTextPattern := BuzzerText;

        Line."Line Type" := Line."Line Type"::Comment;
        Line.Description := StrSubstNo(CommentTextPattern, InputText);

        SaleLine.InsertLine(Line);
    end;
}