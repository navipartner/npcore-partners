table 6014625 "NPR Dependency Mgt. Setup"
{
    // NPR5.01/VB/20160223 CASE 234462 Object created to support managed dependency deployment
    // NPR5.26/MMV /20160905 CASE 242977 Added field 17.
    // NPR5.48/JDH /20181109 CASE 334163 Added Caption to field Disable Deployment

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

    fieldgroups
    {
    }

    procedure StoreManagedDependencyPassword(Pwd: Text)
    var
        Convert: DotNet NPRNetConvert;
        Encoding: DotNet NPRNetEncoding;
        MemStream: DotNet NPRNetMemoryStream;
        OutStream: OutStream;
    begin
        Password.CreateOutStream(OutStream);
        MemStream := MemStream.MemoryStream(Encoding.UTF8.GetBytes(Pwd));
        CopyStream(OutStream, MemStream);
    end;

    procedure GetManagedDependencyPassword() Pwd: Text
    var
        Convert: DotNet NPRNetConvert;
        Encoding: DotNet NPRNetEncoding;
        MemStream: DotNet NPRNetMemoryStream;
        InStream: InStream;
    begin
        if Password.HasValue then begin
            CalcFields(Password);
            Password.CreateInStream(InStream);
            MemStream := MemStream.MemoryStream();
            CopyStream(MemStream, InStream);
            Pwd := Encoding.UTF8.GetString(MemStream.ToArray());
        end;
    end;
}

