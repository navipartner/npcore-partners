codeunit 6014458 "NPR Wizard Helper Functions"
{
    procedure FormatCode(var NoToFormat: Code[10])
    var
        FormattedStartingNo: Text;
    begin
        FormattedStartingNo := DelChr(NoToFormat, '=', '0123456789');
        if FormattedStartingNo = NoToFormat then
            NoToFormat := NoToFormat + '1'
        else
            NoToFormat := IncStr(NoToFormat);
    end;
}