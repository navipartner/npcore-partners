codeunit 6150968 "NPR NationalIdentifier_SE_ONR" implements "NPR NationalIdentifierIface"
{
    Access = Public;

    procedure DisplayName(): Text
    var
        SeOnr: Label 'SE - Organisation number';
    begin
        exit(SeOnr);
    end;

    procedure ExpectedInputExample(): Text
    begin
        exit('NNNNNN-NNNN or NNNNNNNNNN');
    end;

    procedure TryParse(Input: Text; var Canonical: Text[30]; var ErrorMessage: Text): Boolean
    var
        NationalIdentifier: Codeunit "NPR NationalIdentifier_SE";
    begin
        exit(NationalIdentifier.TryParse_ONR(Input, Canonical, ErrorMessage));
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
        exit(ShowUnMasked(Canonical));
    end;
}