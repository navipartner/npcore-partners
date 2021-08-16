table 6184850 "NPR FR Audit Setup"
{
    Caption = 'FR Audit Setup';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            Caption = 'Primary Key';
            DataClassification = CustomerContent;
        }
        field(2; "Certification No."; Text[30])
        {
            Caption = 'Certification No.';
            DataClassification = CustomerContent;
            InitValue = '0274';
            Editable = false;
        }
        field(3; "Certification Category"; Text[30])
        {
            Caption = 'Certification Category';
            DataClassification = CustomerContent;
            InitValue = 'B';
            Editable = false;
        }
        field(4; "Signing Certificate"; BLOB)
        {
            Caption = 'Signing Certificate';
            DataClassification = CustomerContent;
        }
        field(5; "Signing Certificate Password"; Text[250])
        {
            Caption = 'Signing Certificate Password';
            DataClassification = CustomerContent;
            ExtendedDatatype = Masked;
        }
        field(6; "Signing Certificate Thumbprint"; Text[250])
        {
            Caption = 'Signing Certificate Thumbprint';
            DataClassification = CustomerContent;
        }
        field(30; "Monthly Workshift Duration"; DateFormula)
        {
            Caption = 'Monthly Workshift Duration';
            DataClassification = CustomerContent;
        }
        field(35; "Yearly Workshift Duration"; DateFormula)
        {
            Caption = 'Yearly Workshift Duration';
            DataClassification = CustomerContent;
        }
        field(40; "Last Auto Archived Workshift"; Integer)
        {
            Caption = 'Last Auto Archived Workshift';
            DataClassification = CustomerContent;
        }
        field(50; "Auto Archive URL"; Text[250])
        {
            Caption = 'Auto Archive URL';
            DataClassification = CustomerContent;
        }
        field(51; "Auto Archive API Key"; Text[250])
        {
            Caption = 'Auto Archive API Key';
            DataClassification = CustomerContent;
            ExtendedDatatype = Masked;
        }
        field(52; "Auto Archive SAS"; Text[250])
        {
            Caption = 'Auto Archive SAS';
            DataClassification = CustomerContent;
        }
        field(60; "Item VAT Identifier Filter"; Text[250])
        {
            Caption = 'Item VAT Identifier Filter';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteReason = 'New Field Item VAT ID Filter BLOB Type';
        }
        field(61; "Item VAT ID Filter"; Blob)
        {
            Caption = 'Item VAT Identifier Filter';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Primary Key")
        {
        }
    }
    procedure GetItemVATIDFilter(): Text
    var
        VATIDFilter: Text;
        InStr: InStream;
    begin
        "Item VAT ID Filter".CreateInStream(InStr, TextEncoding::UTF8);
        CalcFields("Item VAT ID Filter");
        InStr.Read(VATIDFilter);
        exit(VATIDFilter);
    end;

    procedure SetVATIDFilter(VATIDFilter: Text)
    var
        OutStr: OutStream;
    begin
        "Item VAT ID Filter".CreateOutStream(OutStr, TextEncoding::UTF8);
        OutStr.Write(VATIDFilter);
    end;
}