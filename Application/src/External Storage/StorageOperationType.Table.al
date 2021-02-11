table 6184891 "NPR Storage Operation Type"
{
    Caption = 'Storage Operations';
    DataClassification = CustomerContent;
    ObsoleteState = Removed;
    fields
    {
        field(1; "Storage Type"; Code[20])
        {
            Caption = 'Storage Type';
            DataClassification = CustomerContent;
        }
        field(10; Description; Text[250])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(20; "Operation Code"; Code[20])
        {
            Caption = 'Operation Code';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Storage Type", "Operation Code")
        {
        }
    }

    fieldgroups
    {
    }
}

