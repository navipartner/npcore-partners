table 6151365 "CS Refill Section Data"
{
    // NPR5.54/CLVA/20200310  CASE 384506 Object created


    fields
    {
        field(1;"Item No.";Code[20])
        {
            Caption = 'Item No.';
            TableRelation = Item."No.";
        }
        field(10;"Item Description";Text[50])
        {
            Caption = 'Item Description';
            Editable = false;
            FieldClass = Normal;
        }
        field(11;"Item Group Code";Code[10])
        {
            Caption = 'Item Group Code';
            TableRelation = "Item Group";
        }
        field(12;Refilled;Boolean)
        {
            Caption = 'Refilled';
        }
    }

    keys
    {
        key(Key1;"Item No.")
        {
        }
    }

    fieldgroups
    {
    }
}

