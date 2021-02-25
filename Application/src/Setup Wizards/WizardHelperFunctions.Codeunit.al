codeunit 6014458 "NPR Wizard Helper Functions"
{
    procedure FormatCode(NoToFormat: Code[10]): Code[10]
    var
        FormattedStartingNo: Text;
    begin
        FormattedStartingNo := DelChr(NoToFormat, '=', '0123456789');
        if FormattedStartingNo = NoToFormat then
            exit(NoToFormat + '1')
        else
            exit(IncStr(NoToFormat));
    end;

    procedure FormatCode20(NoToFormat: Code[20]): Code[20]
    var
        FormattedStartingNo: Text;
    begin
        FormattedStartingNo := DelChr(NoToFormat, '=', '0123456789');
        if FormattedStartingNo = NoToFormat then
            exit(NoToFormat + '1')
        else
            exit(IncStr(NoToFormat));
    end;
}