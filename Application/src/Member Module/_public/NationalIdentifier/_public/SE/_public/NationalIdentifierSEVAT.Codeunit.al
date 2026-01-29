codeunit 6150971 "NPR NationalIdentifier_SE_VAT" implements "NPR NationalIdentifierIface"
{
    Access = Public;

    procedure DisplayName(): Text
    var
        SeVat: Label 'SE - VAT number';
    begin
        exit(SeVat);
    end;

    procedure ExpectedInputExample(): Text
    begin
        exit('SENNNNNNNNNN01');
    end;

    procedure TryParse(Input: Text; var Canonical: Text[30]; var ErrorMessage: Text): Boolean
    var
        NationalIdentifier: Codeunit "NPR NationalIdentifier_SE";
    begin
        exit(NationalIdentifier.TryParse_VAT(Input, Canonical, ErrorMessage));
    end;

    procedure ShowUnMasked(Canonical: Text[30]): Text[30]
    begin
        // Canonical expected: SEYYMMDDNNNN01
        exit(Canonical);
    end;

    procedure ShowMasked(Canonical: Text[30]): Text[30]
    begin
        // Masking not defined for VAT numbers
        exit(Canonical);
    end;
}