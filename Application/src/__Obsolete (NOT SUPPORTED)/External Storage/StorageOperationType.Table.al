table 6184891 "NPR Storage Operation Type"
{
    Access = Internal;
    Caption = 'Storage Operations';
    DataClassification = CustomerContent;
    ObsoleteState = Removed;
    ObsoleteTag = '2023-06-28';
    ObsoleteReason = 'Not used';
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

