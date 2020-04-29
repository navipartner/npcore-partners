table 6151561 "NpXml Namespace"
{
    // NC1.22/MHA/20160429  CASE 237658 Object created
    // NC2.00/MHA/20160525  CASE 240005 NaviConnect
    // NC2.01/MHA/20160905 CASE 242551 Object renamed from plural to singular
    // NC2.17/JDH /20181112 CASE 334163 Added Caption to Object and field 5 and 10
    // NC2.18/JDH /20181210 CASE 334163 Added Caption to Object

    Caption = 'NpXml Namespace';

    fields
    {
        field(1;"Xml Template Code";Code[20])
        {
            Caption = 'Xml Template Code';
            Description = 'MAG2.00';
            TableRelation = "NpXml Template";
            //This property is currently not supported
            //TestTableRelation = false;
            ValidateTableRelation = false;
        }
        field(5;Alias;Text[50])
        {
            Caption = 'Alias';
        }
        field(10;Namespace;Text[250])
        {
            Caption = 'Namespace';
        }
    }

    keys
    {
        key(Key1;"Xml Template Code",Alias)
        {
        }
    }

    fieldgroups
    {
        fieldgroup(DropDown;Alias,Namespace)
        {
        }
    }
}

