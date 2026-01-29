codeunit 6150964 "NPR NationalIdentifier_SE_PNR" implements "NPR NationalIdentifierIface"
{
    Access = Public;

    procedure DisplayName(): Text
    var
        SePnr: Label 'SE - Person number';
    begin
        exit(SePnr);
    end;

    procedure ExpectedInputExample(): Text
    begin
        exit('YYYYMMDD-NNNN or YYYYMMDDNNNN');
    end;

    procedure TryParse(Input: Text; var Canonical: Text[30]; var ErrorMessage: Text): Boolean
    var
        NationalIdentifier: Codeunit "NPR NationalIdentifier_SE";
    begin
        exit(NationalIdentifier.TryParse_PNR(Input, Canonical, ErrorMessage));
    end;

    procedure ShowUnMasked(Canonical: Text[30]): Text[30]
    begin
        // Canonical expected: YYYYMMDDNNNN
        if StrLen(Canonical) <> 12 then
            exit(Canonical);

        exit(CopyStr(Canonical, 1, 8) + '-' + CopyStr(Canonical, 9, 4));
    end;

    procedure ShowMasked(Canonical: Text[30]): Text[30]
    begin
        // YYYYMMDD-****
        if StrLen(Canonical) <> 12 then
            exit(Canonical);

        exit(CopyStr(Canonical, 1, 8) + '-****');
    end;
}