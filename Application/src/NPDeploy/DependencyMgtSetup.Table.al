table 6014625 "NPR Dependency Mgt. Setup"
{
    Caption = 'Dependency Management Setup';
    DataPerCompany = false;
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            Caption = 'Primary Key';
            DataClassification = CustomerContent;
        }
        field(10; "OData URL"; Text[250])
        {
            Caption = 'Managed Dependency OData URL';
            DataClassification = CustomerContent;
        }
        field(11; Username; Text[30])
        {
            Caption = 'Managed Dependency Username';
            DataClassification = CustomerContent;
        }
        field(12; Password; BLOB)
        {
            Caption = 'Managed Dependency Password';
            DataClassification = CustomerContent;
        }
        field(13; Configured; Boolean)
        {
            Caption = 'Managed Dependency Configured';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(14; "Accept Statuses"; Option)
        {
            Caption = 'Accept Dependency Statuses';
            OptionCaption = 'Released,Staging (incl. Released),Testing (incl. Staging and Released)';
            OptionMembers = Released,Staging,Testing;
            DataClassification = CustomerContent;
        }
        field(15; "Tag Filter"; Code[250])
        {
            Caption = 'Tag Filter';
            DataClassification = CustomerContent;
        }
        field(16; "Tag Filter Comparison Operator"; Option)
        {
            Caption = 'Tag Filter Comparison Operator';
            OptionCaption = 'Any,All';
            OptionMembers = Any,All;
            DataClassification = CustomerContent;
        }
        field(17; "Disable Deployment"; Boolean)
        {
            Caption = 'Disable Deployment';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Primary Key")
        {
        }
    }

    procedure StoreManagedDependencyPassword(Pwd: Text)
    var
        OutStr: OutStream;
    begin
        Password.CreateOutStream(OutStr, TextEncoding::UTF8);
        OutStr.Write(Pwd);
    end;

    [NonDebuggable]
    procedure GetManagedDependencyPassword() Pwd: Text
    var
        InStr: InStream;
    begin
        if Password.HasValue then begin
            CalcFields(Password);
            Password.CreateInStream(InStr, TextEncoding::UTF8);
            InStr.Read(Pwd);
        end;
    end;
}

