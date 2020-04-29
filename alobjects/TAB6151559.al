table 6151559 "NpXml Template Archive"
{
    // NC1.21/TTH/20151020 CASE 224528 Adding versioning and possibility to lock the modified versions. New table for the archive.
    // NC2.00/MHA/20160525  CASE 240005 NaviConnect
    // NC2.01/MHA/20160905 CASE 242551 ValidateTableRelation and TestTableRelation disabled on Field 1 Xml Template Code
    // NC2.17/JDH /20181112 CASE 334163 Added Caption to Object

    Caption = 'NpXml Template Archive';

    fields
    {
        field(1;"Code";Code[20])
        {
            Caption = 'Code';
            Description = 'NC2.01';
            NotBlank = true;
            TableRelation = "NpXml Template";
            //This property is currently not supported
            //TestTableRelation = false;
            ValidateTableRelation = false;
        }
        field(2;"Template Version No.";Code[20])
        {
            Caption = 'Template Version No.';
        }
        field(5;"Version Description";Text[250])
        {
            Caption = 'Version Description';
        }
        field(10;"Archived Template";BLOB)
        {
            Caption = 'Archived Template';
        }
        field(30;"Archived by";Code[50])
        {
            Caption = 'Archived by';
        }
        field(31;"Archived at";DateTime)
        {
            Caption = 'Archived at';
        }
    }

    keys
    {
        key(Key1;"Code","Template Version No.")
        {
        }
        key(Key2;"Archived at")
        {
        }
    }

    fieldgroups
    {
    }
}

