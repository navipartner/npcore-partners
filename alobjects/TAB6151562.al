table 6151562 "NpXml Api Header"
{
    // NC2.06 /MHA /20170809  CASE 265779 Object created

    Caption = 'NpXml Api Header';

    fields
    {
        field(1;"Xml Template Code";Code[20])
        {
            Caption = 'Xml Template Code';
            NotBlank = true;
            TableRelation = "NpXml Template";
            //This property is currently not supported
            //TestTableRelation = false;
            ValidateTableRelation = false;
        }
        field(5;Name;Text[250])
        {
            Caption = 'Name';
            NotBlank = true;
        }
        field(10;Value;Text[250])
        {
            Caption = 'Value';
        }
    }

    keys
    {
        key(Key1;"Xml Template Code",Name)
        {
        }
    }

    fieldgroups
    {
    }
}

