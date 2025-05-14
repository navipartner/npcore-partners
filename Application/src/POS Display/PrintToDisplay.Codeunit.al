codeunit 6014579 "NPR Print To Display"
{
    Access = Internal;
    trigger OnRun()
    var
        TempPrinterDeviceSettings: Record "NPR Printer Device Settings" temporary;
    begin
        PrintLines();
        LinePrintMgt.ProcessBuffer(Codeunit::"NPR Print To Display", Enum::"NPR Line Printer Device"::BixolonDisplay, TempPrinterDeviceSettings);
    end;

    var
        LinePrintMgt: Codeunit "NPR RP Line Print Mgt.";
        Lines: array[2] of Text;

    procedure PrintLines()
    var
        Line: Integer;
    begin
        for Line := 1 to 2 do
            LinePrintMgt.AddLine(Lines[Line], 0);
    end;

    procedure SetLine(Line1: Text; Line2: Text)
    begin
        Lines[1] := Line1;
        Lines[2] := Line2;
    end;
}

