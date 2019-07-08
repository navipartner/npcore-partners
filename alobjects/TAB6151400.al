table 6151400 "Magento Generic Setup Buffer"
{
    // MAG1.17/MH/20150617  CASE 215910 Object created - Displays Generic Xml Setup stored in BLOB as Tree structure
    // MAG2.00/MHA/20160525  CASE 242557 Magento Integration
    // MAG2.17/JDH /20181112 CASE 334163 Added missing object caption and caption on field Line No.

    Caption = 'Magento Generic Setup Buffer';

    fields
    {
        field(1;"Line No.";Integer)
        {
            Caption = 'Line No.';
        }
        field(5;"Data Type";Text[50])
        {
            Caption = 'Data Type';
        }
        field(10;Name;Text[250])
        {
            Caption = 'Field Name';
        }
        field(15;Value;Text[250])
        {
            Caption = 'Value';

            trigger OnValidate()
            begin
                if Container then
                  exit;

                Value := GenericSetupMgt.ValidateValue("Data Type",Value);
            end;
        }
        field(100;Container;Boolean)
        {
            Caption = 'Group';
        }
        field(110;Level;Integer)
        {
            Caption = 'Level';
        }
        field(115;"Node Path";Text[250])
        {
            Caption = 'Node Path';
        }
        field(120;"Root Element";Text[250])
        {
            Caption = 'Root Element';
        }
    }

    keys
    {
        key(Key1;"Line No.")
        {
        }
    }

    fieldgroups
    {
    }

    var
        GenericSetupMgt: Codeunit "Magento Generic Setup Mgt.";
}

