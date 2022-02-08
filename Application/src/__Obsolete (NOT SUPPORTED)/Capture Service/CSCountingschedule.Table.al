table 6151399 "NPR CS Counting schedule"
{
    Access = Internal;

    Caption = 'CS Counting schedule';
    DataClassification = CustomerContent;
    ObsoleteState = Removed;
    ObsoleteReason = 'Object moved to NP Warehouse App.';


    fields
    {
        field(1; "POS Store"; Code[10])
        {
            Caption = 'POS Store';
            DataClassification = CustomerContent;
            NotBlank = true;
        }
        field(10; "Earliest Start Date/Time"; DateTime)
        {
            Caption = 'Earliest Start Date/Time';
            DataClassification = CustomerContent;


        }
        field(12; "Job Queue Entry ID"; Guid)
        {
            Caption = 'Job Queue Entry ID';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(13; "Job Queue Priority for Post"; Integer)
        {
            Caption = 'Job Queue Priority for Post';
            DataClassification = CustomerContent;
            Editable = true;
            InitValue = 2000;
            MinValue = 1000;
        }
        field(14; "Expiration Date/Time"; DateTime)
        {
            Caption = 'Expiration Date/Time';
            DataClassification = CustomerContent;


        }
        field(15; "Recurring Job"; Boolean)
        {
            Caption = 'Recurring Job';
            DataClassification = CustomerContent;
        }
        field(16; "Run on Mondays"; Boolean)
        {
            Caption = 'Run on Mondays';
            DataClassification = CustomerContent;


        }
        field(17; "Run on Tuesdays"; Boolean)
        {
            Caption = 'Run on Tuesdays';
            DataClassification = CustomerContent;


        }
        field(18; "Run on Wednesdays"; Boolean)
        {
            Caption = 'Run on Wednesdays';
            DataClassification = CustomerContent;


        }
        field(19; "Run on Thursdays"; Boolean)
        {
            Caption = 'Run on Thursdays';
            DataClassification = CustomerContent;


        }
        field(20; "Run on Fridays"; Boolean)
        {
            Caption = 'Run on Fridays';
            DataClassification = CustomerContent;


        }
        field(21; "Run on Saturdays"; Boolean)
        {
            Caption = 'Run on Saturdays';
            DataClassification = CustomerContent;


        }
        field(22; "Run on Sundays"; Boolean)
        {
            Caption = 'Run on Sundays';
            DataClassification = CustomerContent;


        }
        field(23; "Starting Time"; Time)
        {
            Caption = 'Starting Time';
            DataClassification = CustomerContent;


        }
        field(24; "Ending Time"; Time)
        {
            Caption = 'Ending Time';
            DataClassification = CustomerContent;


        }

        field(26; "Job Queue Created"; Boolean)
        {
            Caption = 'Job Queue Created';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(27; "No. of Minutes between Runs"; Integer)
        {
            Caption = 'No. of Minutes between Runs';
            DataClassification = CustomerContent;


        }
        field(28; Status; Option)
        {
            Caption = 'Status';
            DataClassification = CustomerContent;
            Editable = false;
            OptionCaption = ' ,Scheduled,Error,Running';
            OptionMembers = " ",Scheduled,Error,Running;


        }
        field(29; "Last Executed"; DateTime)
        {
            Caption = 'Last Executed';
            DataClassification = CustomerContent;
            Editable = false;
        }

    }

    keys
    {
        key(Key1; "POS Store")
        {
        }
    }

    fieldgroups
    {
    }





}

