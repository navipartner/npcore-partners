table 6060145 "NPR MM Member Arr. Log Entry"
{

    Caption = 'MM Member Arrival Log Entry';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            AutoIncrement = true;
            Caption = 'Entry No.';
            DataClassification = CustomerContent;
        }
        field(5; "Event Type"; Option)
        {
            Caption = 'Event Type';
            DataClassification = CustomerContent;
            OptionCaption = 'Arrival,Departure';
            OptionMembers = ARRIVAL,DEPARTURE;
        }
        field(10; "Created At"; DateTime)
        {
            Caption = 'Created At';
            DataClassification = CustomerContent;
        }
        field(11; "Local Date"; Date)
        {
            Caption = 'Local Date';
            DataClassification = CustomerContent;
        }
        field(12; "Local Time"; Time)
        {
            Caption = 'Local Time';
            DataClassification = CustomerContent;
        }
        field(20; "External Membership No."; Code[20])
        {
            Caption = 'External Membership No.';
            DataClassification = CustomerContent;
        }
        field(30; "External Member No."; Code[20])
        {
            Caption = 'External Member No.';
            DataClassification = CustomerContent;
        }
        field(40; "External Card No."; Text[100])
        {
            Caption = 'External Card No.';
            DataClassification = CustomerContent;
        }
        field(50; "Scanner Station Id"; Code[10])
        {
            Caption = 'Scanner Station Id';
            DataClassification = CustomerContent;
        }
        field(60; "Admission Code"; Code[20])
        {
            Caption = 'Admission Code';
            DataClassification = CustomerContent;
        }
        field(70; "Temporary Card"; Boolean)
        {
            Caption = 'Temporary Card';
            DataClassification = CustomerContent;
        }
        field(100; "Response Message"; Text[250])
        {
            Caption = 'Response Message';
            DataClassification = CustomerContent;
        }
        field(110; "Response Type"; Option)
        {
            Caption = 'Response Type';
            DataClassification = CustomerContent;
            OptionCaption = 'Access Denied,Validation Failure,Success';
            OptionMembers = ACCESS_DENIED,VALIDATION_FAILURE,SUCCESS;
        }
        field(120; "Response Code"; Integer)
        {
            Caption = 'Response Code';
            DataClassification = CustomerContent;
        }
        field(121; "Response Rule Entry No."; Integer)
        {
            Caption = 'Response Rule Entry No.';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Entry No.")
        {
        }
    }

    fieldgroups
    {
    }
}

