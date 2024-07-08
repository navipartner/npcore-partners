codeunit 6014458 "NPR Wizard Helper Functions"
{
    Access = Internal;
    procedure FormatCode(var NoToFormat: Code[10]; returnNewValue: Boolean)
    var
        FormattedStartingNo: Text;
    begin
        FormattedStartingNo := DelChr(NoToFormat, '=', '0123456789');
        if FormattedStartingNo = NoToFormat then begin
            if returnNewValue then
#pragma warning disable AA0139
            NoToFormat += '1'
#pragma warning restore
        end else
            NoToFormat := IncStr(NoToFormat);
    end;


    procedure FormatCode20(NoToFormat: Code[20]): Code[20]
    var
        FormattedStartingNo: Text;
    begin
        FormattedStartingNo := DelChr(NoToFormat, '=', '0123456789');
        if FormattedStartingNo = NoToFormat then
#pragma warning disable AA0139
            exit(NoToFormat + '1')
#pragma warning restore
        else
            exit(IncStr(NoToFormat));
    end;

    procedure FormatCode32(var NoToFormat: Code[32])
    var
        FormattedStartingNo: Text;
    begin
        FormattedStartingNo := DelChr(NoToFormat, '=', '0123456789');
        if FormattedStartingNo = NoToFormat then
#pragma warning disable AA0139
            NoToFormat += '1'
#pragma warning restore
        else
            NoToFormat := IncStr(NoToFormat);
    end;
}
