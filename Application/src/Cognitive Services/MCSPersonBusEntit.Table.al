table 6059961 "NPR MCS Person Bus. Entit."
{
    Access = Internal;

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
}

