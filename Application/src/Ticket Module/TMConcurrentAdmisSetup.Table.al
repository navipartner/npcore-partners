table 6151136 "NPR TM Concurrent Admis. Setup"
{
    Access = Internal;
    // TM1.45/TSA /20200116 CASE 385922 Initial Version

    Caption = 'Concurrent Admission Setup';
    DataClassification = CustomerContent;
    DrillDownPageID = "NPR TM Concurrent Admis. Setup";
    LookupPageID = "NPR TM Concurrent Admis. Setup";

    fields
    {
        field(1; "Code"; Code[20])
        {
            Caption = 'Code';
            DataClassification = CustomerContent;
            NotBlank = true;
        }
        field(10; Description; Text[30])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(20; "Total Capacity"; Integer)
        {
            Caption = 'Total Capacity';
            DataClassification = CustomerContent;
        }
        field(30; "Capacity Control"; Option)
        {
            Caption = 'Capacity Control';
            DataClassification = CustomerContent;
            OptionCaption = 'None,Sales,Admitted,Admitted & Departed,Seating';
            OptionMembers = NA,SALES,ADMITTED,FULL,SEATING;
        }
        field(40; "Concurrency Type"; Option)
        {
            Caption = 'Concurrency Type';
            DataClassification = CustomerContent;
            OptionCaption = 'No Concurrency Check,Admission & Concurrency Code,Schedule & Concurrency Code,Concurrency Code';
            OptionMembers = NA,ADMISSION,SCHEDULE,CONCURRENCY_CODE;
        }
    }

    keys
    {
        key(Key1; "Code")
        {
        }
    }

    fieldgroups
    {
    }
}

