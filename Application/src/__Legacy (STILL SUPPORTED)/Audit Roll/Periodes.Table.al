table 6060102 "NPR Periodes"
{
    Caption = 'Period';
    DataClassification = CustomerContent;
    DataPerCompany = false;

    fields
    {
        field(1; "Period Code"; Code[20])
        {
            Caption = 'Period Code';
            DataClassification = CustomerContent;
        }
        field(2; Description; Text[50])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(3; "Start Date"; Date)
        {
            Caption = 'Start Date';
            DataClassification = CustomerContent;
        }
        field(4; "End Date"; Date)
        {
            Caption = 'End Date';
            DataClassification = CustomerContent;
        }
        field(5; "Start Date Last Year"; Date)
        {
            Caption = 'Start Date Last Year';
            DataClassification = CustomerContent;
        }
        field(6; "End Date Last Year"; Date)
        {
            Caption = 'End Date Last Year';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Period Code")
        {
        }
    }

    fieldgroups
    {
    }
}

