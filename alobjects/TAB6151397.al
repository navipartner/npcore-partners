table 6151397 "CS Posting Buffer"
{
    // NPR5.51/CLVA  /20190813  CASE 365659 Object created - NP Capture Service
    // NPR5.52/CLVA  /20190904  CASE 365967 Added init values and delete handling
    // NPR5.52/CLVA  /20190937  CASE 370509 Added "Job Type" option "Item Reclass."
    //                                       Added field "Session Id"

    Caption = 'CS Posting Buffer';

    fields
    {
        field(1;Id;Integer)
        {
            AutoIncrement = true;
            Caption = 'Id';
            Editable = false;
        }
        field(10;"Table No.";Integer)
        {
            Caption = 'Table No.';
            Editable = false;
        }
        field(11;"Record Id";RecordID)
        {
            Caption = 'Record Id';
            Editable = false;
        }
        field(12;"Created By";Code[50])
        {
            Caption = 'Created By';
            Editable = false;
            TableRelation = User."User Name";
            ValidateTableRelation = false;

            trigger OnLookup()
            var
                UserMgt: Codeunit "User Management";
            begin
            end;

            trigger OnValidate()
            var
                UserMgt: Codeunit "User Management";
            begin
            end;
        }
        field(13;Created;DateTime)
        {
            Caption = 'Created';
            Editable = false;
        }
        field(14;Executed;Boolean)
        {
            Caption = 'Executed';
            Editable = false;
        }
        field(15;"Posting Index";Integer)
        {
            Caption = 'Posting Index';
        }
        field(16;"Update Posting Date";Boolean)
        {
            Caption = 'Update Posting Date';
        }
        field(17;"Job Queue Status";Option)
        {
            Caption = 'Job Queue Status';
            Editable = false;
            OptionCaption = ' ,Scheduled for Posting,Error,Posting';
            OptionMembers = " ","Scheduled for Posting",Error,Posting;

            trigger OnLookup()
            var
                JobQueueEntry: Record "Job Queue Entry";
            begin
                if ("Job Queue Status" = "Job Queue Status"::" ") and Executed then
                  exit;
                JobQueueEntry.ShowStatusMsg("Job Queue Entry ID");
            end;
        }
        field(18;"Job Queue Entry ID";Guid)
        {
            Caption = 'Job Queue Entry ID';
            Editable = false;
        }
        field(19;"Job Type";Option)
        {
            Caption = 'Job Type';
            Editable = false;
            OptionCaption = 'Invt. Pick,Invt. Put-away,Pick,Put-away,Phy. Inv. Journal,Item Journal,Transfer Order,Movement,Invt. Movement,Store Counting,Item Reclass.';
            OptionMembers = "Invt. Pick","Invt. Put-away",Pick,"Put-away","Phy. Inv. Journal","Item Journal","Transfer Order",Movement,"Invt. Movement","Store Counting","Item Reclass.";
        }
        field(20;"Job Queue Priority for Post";Integer)
        {
            Caption = 'Job Queue Priority for Post';
            Editable = false;
            InitValue = 1000;
            MinValue = 0;

            trigger OnValidate()
            begin
                //IF "Job Queue Priority for Post" < 0 THEN
                //  ERROR(TXT002);
            end;
        }
        field(21;"Session Id";Text[30])
        {
            Caption = 'Session Id';
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

    trigger OnDelete()
    begin
        //-NPR5.52 [365967]
        if not IsNullGuid("Job Queue Entry ID") then
          if JobQueueEntry.Get("Job Queue Entry ID") then
            JobQueueEntry.Delete(true);
        //+NPR5.52 [365967]
    end;

    trigger OnInsert()
    begin
        //-NPR5.52 [365967]
        Created := CurrentDateTime;
        "Created By" := UserId;
        //+NPR5.52 [365967]
    end;

    var
        JobQueueEntry: Record "Job Queue Entry";
        TXT002: Label 'Job Queue Priority must be zero or positive.';
}

