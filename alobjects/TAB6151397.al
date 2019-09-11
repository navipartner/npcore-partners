table 6151397 "CS Posting Buffer"
{
    // NPR5.51/CLVA  /20190813  CASE 365659 Object created - NP Capture Service

    Caption = 'CS Posting Buffer';

    fields
    {
        field(1;Id;Integer)
        {
            AutoIncrement = true;
            Caption = 'Id';
        }
        field(10;"Entry Type";Option)
        {
            Caption = 'Entry Type';
            OptionCaption = 'Transfer Order,Item Journal';
            OptionMembers = "Transfer Order","Item Journal","Warehouse Activity";
        }
        field(11;"Key 1";Code[20])
        {
            Caption = 'Key 1';
        }
        field(12;"key 2";Code[20])
        {
            Caption = 'key 2';
        }
        field(13;Created;DateTime)
        {
            Caption = 'Created';
        }
        field(14;Posted;Boolean)
        {
            Caption = 'Posted';
        }
        field(15;Aborted;Boolean)
        {
            Caption = 'Aborted';
        }
        field(16;Description;Text[250])
        {
            Caption = 'Description';
        }
        field(17;"Start Time";Time)
        {
            Caption = 'Start Time';
        }
        field(18;"End time";Time)
        {
            Caption = 'End time';
        }
        field(19;"Job Duration";Duration)
        {
            Caption = 'Job Duration';
        }
        field(20;"Activity Type";Option)
        {
            Caption = 'Activity Type';
            Editable = false;
            OptionCaption = ' ,Put-away,Pick,Movement,Invt. Put-away,Invt. Pick,Invt. Movement';
            OptionMembers = " ","Put-away",Pick,Movement,"Invt. Put-away","Invt. Pick","Invt. Movement";
        }
        field(21;"Job Execution No.";Integer)
        {
            Caption = 'Job Execution No.';
        }
    }

    keys
    {
        key(Key1;Id)
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnModify()
    begin
        if ("Start Time" > 0T) and ("End time" <> 0T) then
          "Job Duration" := "End time" - "Start Time";
    end;
}

