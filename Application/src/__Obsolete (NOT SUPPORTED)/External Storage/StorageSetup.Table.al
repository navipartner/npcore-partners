table 6184892 "NPR Storage Setup"
{
    Caption = 'External Storage Setup';
    DataClassification = CustomerContent;
    ObsoleteState = Removed;
    ObsoleteReason = 'Not used';
    fields
    {
        field(1; "Storage ID"; Text[24])
        {
            Caption = 'Storage ID';
            DataClassification = CustomerContent;
        }
        field(10; "Storage Type"; Code[20])
        {
            Caption = 'Storage Type';
            DataClassification = CustomerContent;
        }
        field(20; Description; Text[250])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Storage ID", "Storage Type")
        {
        }
    }

    fieldgroups
    {
    }
}

