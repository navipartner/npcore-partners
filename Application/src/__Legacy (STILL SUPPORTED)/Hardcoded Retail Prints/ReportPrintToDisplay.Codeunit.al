codeunit 6014579 "NPR Report: Print To Display"
{
    // NPR5.32/MMV /20170411 CASE 241995 Retail Print 2.0


    trigger OnRun()
    begin
        PrintLines();
        //-NPR5.32 [241995]
        //LinePrintBuffer.ProcessBuffer(CODEUNIT::"Report - Print To Display");
        LinePrintBuffer.ProcessBufferForCodeunit(CODEUNIT::"NPR Report: Print To Display", '');
        //+NPR5.32 [241995]
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

