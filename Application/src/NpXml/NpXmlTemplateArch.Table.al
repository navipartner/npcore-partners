table 6151559 "NPR NpXml Template Arch."
{
    Access = Internal;
    Caption = 'NpXml Template Archive';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Code"; Code[20])
        {
            Caption = 'Code';
            DataClassification = CustomerContent;
            Description = 'NC2.01';
            NotBlank = true;
            TableRelation = "NPR NpXml Template";

            ValidateTableRelation = false;
        }
        field(2; "Template Version No."; Code[20])
        {
            Caption = 'Template Version No.';
            DataClassification = CustomerContent;
        }
        field(5; "Version Description"; Text[250])
        {
            Caption = 'Version Description';
            DataClassification = CustomerContent;
        }
        field(10; "Archived Template"; BLOB)
        {
            Caption = 'Archived Template';
            DataClassification = CustomerContent;
        }
        field(30; "Archived by"; Code[50])
        {
            Caption = 'Archived by';
            DataClassification = EndUserIdentifiableInformation;
        }
        field(31; "Archived at"; DateTime)
        {
            Caption = 'Archived at';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Code", "Template Version No.")
        {
        }
        key(Key2; "Archived at")
        {
        }
    }
}

