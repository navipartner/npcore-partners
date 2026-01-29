codeunit 6150975 "NPR NationalIdentifier_DK_VAT" implements "NPR NationalIdentifierIface"
{
    Access = Public;

    procedure DisplayName(): Text
    var
        DkVat: Label 'DK VAT number';
    begin
        exit(DkVat);
    end;

    procedure ExpectedInputExample(): Text
    begin
        exit('DKNNNNNNNN (DK + CVR)');
    end;

    procedure TryParse(Input: Text; var Canonical: Text[30]; var ErrorMessage: Text): Boolean
    var
        NationalIdentifier: Codeunit "NPR NationalIdentifier_DK";
    begin
        exit(NationalIdentifier.TryParse_VAT(Input, Canonical, ErrorMessage));
    end;

    procedure ShowUnMasked(Canonical: Text[30]): Text[30]
    begin
        // Canonical expected: DKNNNNNNNN
        exit(Canonical);
    end;

    procedure ShowMasked(Canonical: Text[30]): Text[30]
    begin
        // Same as unmasked for VAT
        exit(Canonical);
    end;
}