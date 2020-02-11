table 6151136 "TM Concurrent Admission Setup"
{
    // TM1.45/TSA /20200116 CASE 385922 Initial Version

    Caption = 'Concurrent Admission Setup';
    DrillDownPageID = "TM Concurrent Admission Setup";
    LookupPageID = "TM Concurrent Admission Setup";

    fields
    {
        field(1;"Code";Code[20])
        {
            Caption = 'Code';
            NotBlank = true;
        }
        field(10;Description;Text[30])
        {
            Caption = 'Description';
        }
        field(20;"Total Capacity";Integer)
        {
            Caption = 'Total Capacity';
        }
        field(30;"Capacity Control";Option)
        {
            Caption = 'Capacity Control';
            OptionCaption = 'None,Sales,Admitted,Admitted & Departed,Seating';
            OptionMembers = NA,SALES,ADMITTED,FULL,SEATING;
        }
        field(40;"Concurrency Type";Option)
        {
            Caption = 'Concurrency Type';
            OptionCaption = 'No Concurrency Check,Admission & Concurrency Code,Schedule & Concurrency Code,Concurrency Code';
            OptionMembers = NA,ADMISSION,SCHEDULE,CONCURRENCY_CODE;
        }
    }

    keys
    {
        key(Key1;"Code")
        {
        }
    }

    fieldgroups
    {
    }
}

