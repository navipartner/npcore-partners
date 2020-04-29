table 6150720 "POS Stargate Assembly Map"
{
    Caption = 'POS Stargate Assembly Map';

    fields
    {
        field(1;"Assembly Name";Text[250])
        {
            Caption = 'Assembly Name';
        }
        field(2;Path;Text[250])
        {
            Caption = 'Path';
        }
        field(3;Status;Option)
        {
            Caption = 'Status';
            OptionCaption = 'Unknown,Mapped,Known,Additional';
            OptionMembers = Unknown,Mapped,Known,Additional;
        }
    }

    keys
    {
        key(Key1;"Assembly Name")
        {
        }
    }

    fieldgroups
    {
    }
}

