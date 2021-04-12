codeunit 6014458 "NPR Wizard Helper Functions"
{
    procedure FormatCode(var NoToFormat: Code[10]; returnNewValue: Boolean)
    var
        FormattedStartingNo: Text;
    begin
        FormattedStartingNo := DelChr(NoToFormat, '=', '0123456789');
        if FormattedStartingNo = NoToFormat then begin
            if returnNewValue then
                NoToFormat += '1'
        end else
            NoToFormat := IncStr(NoToFormat);
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