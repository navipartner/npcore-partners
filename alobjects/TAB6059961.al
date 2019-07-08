table 6059961 "MCS Person Business Entities"
{
    // NPR5.48/JAVA/20190205  CASE 334163 Transport NPR5.48 - 5 February 2019

    Caption = 'MCS Person Business Entities';

    fields
    {
        field(1;PersonId;Text[50])
        {
            Caption = 'Person Id';
            TableRelation = "MCS Person";
        }
        field(2;"Table Id";Integer)
        {
            Caption = 'Table Id';
        }
        field(11;"Key";RecordID)
        {
            Caption = 'Key';
        }
    }

    keys
    {
        key(Key1;PersonId,"Table Id")
        {
        }
        key(Key2;"Key")
        {
        }
    }

    fieldgroups
    {
    }
}

