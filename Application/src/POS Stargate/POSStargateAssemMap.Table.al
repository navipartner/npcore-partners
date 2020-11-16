table 6150720 "NPR POS Stargate Assem. Map"
{
    Caption = 'POS Stargate Assembly Map';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Assembly Name"; Text[250])
        {
            Caption = 'Assembly Name';
            DataClassification = CustomerContent;
        }
        field(2; Path; Text[250])
        {
            Caption = 'Path';
            DataClassification = CustomerContent;
        }
        field(3; Status; Option)
        {
            Caption = 'Status';
            DataClassification = CustomerContent;
            OptionCaption = 'Unknown,Mapped,Known,Additional';
            OptionMembers = Unknown,Mapped,Known,Additional;
        }
    }

    keys
    {
        key(Key1; "Assembly Name")
        {
        }
        key(Key2; Status)
        {
        }
    }

    fieldgroups
    {
    }
}

