codeunit 6014579 "NPR Print To Display"
{
    Access = Internal;
    trigger OnRun()
    begin
        PrintLines();
        LinePrintBuffer.ProcessBufferForCodeunit(CODEUNIT::"NPR Print To Display", '');
    end;

    var
        LinePrintBuffer: Codeunit "NPR RP Line Print Mgt.";
        Lines: array[2] of Text;

    procedure PrintLines()
    var
        Line: Integer;
    begin
        for Line := 1 to 2 do
            LinePrintBuffer.AddLine(Lines[Line]);
    end;

    procedure SetLine(Line1: Text; Line2: Text)
    begin
        Lines[1] := Line1;
        Lines[2] := Line2;
    end;
}

