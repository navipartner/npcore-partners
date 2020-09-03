table 6059961 "NPR MCS Person Bus. Entit."
{
    // NPR5.48/JAVA/20190205  CASE 334163 Transport NPR5.48 - 5 February 2019

    Caption = 'MCS Person Business Entities';
    DataClassification = CustomerContent;

    fields
    {
        field(1; PersonId; Text[50])
        {
            Caption = 'Person Id';
            DataClassification = CustomerContent;
            TableRelation = "NPR MCS Person";
        }
        field(2; "Table Id"; Integer)
        {
            Caption = 'Table Id';
            DataClassification = CustomerContent;
        }
        field(11; "Key"; RecordID)
        {
            Caption = 'Key';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; PersonId, "Table Id")
        {
        }
        key(Key2; "Key")
        {
        }
    }

    fieldgroups
    {
    }
}

