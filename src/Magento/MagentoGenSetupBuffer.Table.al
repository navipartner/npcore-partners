table 6151400 "NPR Magento Gen. Setup Buffer"
{
    // MAG1.17/MH/20150617  CASE 215910 Object created - Displays Generic Xml Setup stored in BLOB as Tree structure
    // MAG2.00/MHA/20160525  CASE 242557 Magento Integration
    // MAG2.17/JDH /20181112 CASE 334163 Added missing object caption and caption on field Line No.

    Caption = 'Magento Generic Setup Buffer';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Line No."; Integer)
        {
            Caption = 'Line No.';
            DataClassification = CustomerContent;
        }
        field(5; "Data Type"; Text[50])
        {
            Caption = 'Data Type';
            DataClassification = CustomerContent;
        }
        field(10; Name; Text[250])
        {
            Caption = 'Field Name';
            DataClassification = CustomerContent;
        }
        field(15; Value; Text[250])
        {
            Caption = 'Value';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if Container then
                    exit;

                Value := GenericSetupMgt.ValidateValue("Data Type", Value);
            end;
        }
        field(100; Container; Boolean)
        {
            Caption = 'Group';
            DataClassification = CustomerContent;
        }
        field(110; Level; Integer)
        {
            Caption = 'Level';
            DataClassification = CustomerContent;
        }
        field(115; "Node Path"; Text[250])
        {
            Caption = 'Node Path';
            DataClassification = CustomerContent;
        }
        field(120; "Root Element"; Text[250])
        {
            Caption = 'Root Element';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Line No.")
        {
        }
    }

    fieldgroups
    {
    }

    var
        GenericSetupMgt: Codeunit "NPR Magento Gen. Setup Mgt.";
}

