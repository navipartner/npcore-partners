table 6151550 "NPR NpXml Setup"
{
    Caption = 'NpXml Setup';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            Caption = 'Primary Key';
            DataClassification = CustomerContent;
        }
        field(10; "NpXml Enabled"; Boolean)
        {
            Caption = 'NpXml Enabled';
            DataClassification = CustomerContent;
        }
        field(60; "Template Version Prefix"; Code[5])
        {
            Caption = 'Template Version Prefix';
            DataClassification = CustomerContent;
            Description = 'NC1.21';

            trigger OnValidate()
            begin
                if (StrPos("Template Version Prefix", 'NC') = 1) then
                    Error(Text100);
            end;
        }
        field(65; "Template Version No."; Integer)
        {
            Caption = 'Template Version No.';
            DataClassification = CustomerContent;
            Description = 'NC1.21';
            InitValue = 1;
            MinValue = 1;
            NotBlank = true;
        }
    }

    keys
    {
        key(Key1; "Primary Key")
        {
        }
    }

    var
        Text100: Label 'Invalid version tag';
}

