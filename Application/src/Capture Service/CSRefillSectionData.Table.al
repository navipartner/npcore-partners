table 6151365 "NPR CS Refill Section Data"
{
    DataClassification = CustomerContent;
    // NPR5.54/CLVA/20200310  CASE 384506 Object created


    fields
    {
        field(1; "Item No."; Code[20])
        {
            Caption = 'Item No.';
            DataClassification = CustomerContent;
            TableRelation = Item."No.";
        }
        field(10; "Item Description"; Text[50])
        {
            Caption = 'Item Description';
            DataClassification = CustomerContent;
            Editable = false;
            FieldClass = Normal;
        }
        field(11; "Item Group Code"; Code[10])
        {
            Caption = 'Item Group Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR Item Group";
        }
        field(12; Refilled; Boolean)
        {
            Caption = 'Refilled';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Item No.")
        {
        }
    }

    fieldgroups
    {
    }
}

