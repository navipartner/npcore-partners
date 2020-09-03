table 6014625 "NPR Dependency Mgt. Setup"
{
    // NPR5.01/VB/20160223 CASE 234462 Object created to support managed dependency deployment
    // NPR5.26/MMV /20160905 CASE 242977 Added field 17.
    // NPR5.48/JDH /20181109 CASE 334163 Added Caption to field Disable Deployment

    Caption = 'Dependency Management Setup';
    DataPerCompany = false;

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            Caption = 'Primary Key';
        }
        field(10; "OData URL"; Text[250])
        {
            Caption = 'Managed Dependency OData URL';
        }
        field(11; Username; Text[30])
        {
            Caption = 'Managed Dependency Username';
        }
        field(12; Password; BLOB)
        {
            Caption = 'Managed Dependency Password';
        }
        field(13; Configured; Boolean)
        {
            Caption = 'Managed Dependency Configured';
            Editable = false;
        }
        field(14; "Accept Statuses"; Option)
        {
            Caption = 'Accept Dependency Statuses';
            OptionCaption = 'Released,Staging (incl. Released),Testing (incl. Staging and Released)';
            OptionMembers = Released,Staging,Testing;
        }
        field(15; "Tag Filter"; Code[250])
        {
            Caption = 'Tag Filter';
        }
        field(16; "Tag Filter Comparison Operator"; Option)
        {
            Caption = 'Tag Filter Comparison Operator';
            OptionCaption = 'Any,All';
            OptionMembers = Any,All;
        }
        field(17; "Disable Deployment"; Boolean)
        {
            Caption = 'Disable Deployment';
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

