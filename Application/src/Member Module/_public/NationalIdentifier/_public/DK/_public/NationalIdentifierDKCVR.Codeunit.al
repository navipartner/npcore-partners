codeunit 6150979 "NPR NationalIdentifier_DK_CVR" implements "NPR NationalIdentifierIface"
{
    Access = Public;

    procedure DisplayName(): Text
    var
        DkCvr: Label 'DK CVR number';
    begin
        exit(DkCvr);
    end;

    procedure ExpectedInputExample(): Text
    begin
        exit('NNNNNNNN');
    end;

    procedure TryParse(Input: Text; var Canonical: Text[30]; var ErrorMessage: Text): Boolean
    var
        NationalIdentifier: Codeunit "NPR NationalIdentifier_DK";
    begin
        exit(NationalIdentifier.TryParse_CVR(Input, Canonical, ErrorMessage));
    end;

    procedure ShowUnMasked(Canonical: Text[30]): Text[30]
    begin
        // Canonical expected: NNNNNNNN
        exit(Canonical);
    end;

    procedure ShowMasked(Canonical: Text[30]): Text[30]
    begin
        // Same as unmasked for CVR
        exit(Canonical);
    end;
}
