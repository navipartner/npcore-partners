codeunit 6150936 "NPR NationalIdentifier_None" implements "NPR NationalIdentifierIface"
{
    Access = Public;

    procedure DisplayName(): Text
    begin
        exit('Free text');
    end;

    procedure ExpectedInputExample(): Text
    begin
        exit('');
    end;

#pragma warning disable AA0139
    procedure TryParse(Input: Text; var Canonical: Text[30]; var ErrorMessage: Text): Boolean
    begin
        Canonical := Input;
        Clear(ErrorMessage);
        exit(true);
    end;
#pragma warning restore AA0139

    procedure ShowUnMasked(Canonical: Text[30]): Text[30]
    begin
        exit(Canonical);
    end;

    procedure ShowMasked(Canonical: Text[30]): Text[30]
    begin
        exit(Canonical);
    end;
}