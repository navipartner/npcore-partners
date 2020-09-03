table 6151559 "NPR NpXml Template Arch."
{
    // NC1.21/TTH/20151020 CASE 224528 Adding versioning and possibility to lock the modified versions. New table for the archive.
    // NC2.00/MHA/20160525  CASE 240005 NaviConnect
    // NC2.01/MHA/20160905 CASE 242551 ValidateTableRelation and TestTableRelation disabled on Field 1 Xml Template Code
    // NC2.17/JDH /20181112 CASE 334163 Added Caption to Object

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
            //This property is currently not supported
            //TestTableRelation = false;
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
            DataClassification = CustomerContent;
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

    fieldgroups
    {
    }
}

