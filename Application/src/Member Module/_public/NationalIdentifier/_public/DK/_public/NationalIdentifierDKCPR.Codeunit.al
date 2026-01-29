codeunit 6150980 "NPR NationalIdentifier_DK_CPR" implements "NPR NationalIdentifierIface"
{
    Access = Public;

    procedure DisplayName(): Text
    var
        DkCpr: Label 'DK CPR number';
    begin
        exit(DkCpr);
    end;

    procedure ExpectedInputExample(): Text
    begin
        exit('DDMMYYNNNN or DDMMYY-NNNN');
    end;

    procedure TryParse(Input: Text; var Canonical: Text[30]; var ErrorMessage: Text): Boolean
    var
        NationalIdentifier: Codeunit "NPR NationalIdentifier_DK";
    begin
        // After 2007, CPR numbers check may not comply with Mod11 checksum
        exit(NationalIdentifier.TryParse_CPR(Input, Canonical, false, ErrorMessage));
    end;

    procedure ShowUnMasked(Canonical: Text[30]): Text[30]
    begin
        // Canonical expected: YYMMDDNNNN
        if StrLen(Canonical) <> 10 then
            exit(Canonical);

        exit(CopyStr(Canonical, 1, 6) + '-' + CopyStr(Canonical, 7, 4));
    end;

    procedure ShowMasked(Canonical: Text[30]): Text[30]
    begin
        // YYMMDD-****
        if StrLen(Canonical) <> 10 then
            exit(Canonical);

        exit(CopyStr(Canonical, 1, 6) + '-****');
    end;
}
