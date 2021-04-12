table 6151397 "NPR CS Posting Buffer"
{

    Caption = 'CS Posting Buffer';
    DataClassification = CustomerContent;
    ObsoleteState = Removed;
    ObsoleteReason = 'Object moved to NP Warehouse App.';

    fields
    {
        field(1; Id; Integer)
        {
            AutoIncrement = true;
            Caption = 'Id';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(10; "Table No."; Integer)
        {
            Caption = 'Table No.';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(11; "Record Id"; RecordID)
        {
            Caption = 'Record Id';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(12; "Created By"; Code[50])
        {
            Caption = 'Created By';
            DataClassification = CustomerContent;
            Editable = false;
            TableRelation = User."User Name";
            ValidateTableRelation = false;


        }
        field(13; Created; DateTime)
        {
            Caption = 'Created';
            DataClassification = CustomerContent;
            Editable = true;
        }
        field(14; Executed; Boolean)
        {
            Caption = 'Executed';
            DataClassification = CustomerContent;
            Editable = true;
        }
        field(15; "Posting Index"; Integer)
        {
            Caption = 'Posting Index';
            DataClassification = CustomerContent;
        }
        field(16; "Update Posting Date"; Boolean)
        {
            Caption = 'Update Posting Date';
            DataClassification = CustomerContent;
        }
        field(17; "Job Queue Status"; Option)
        {
            Caption = 'Job Queue Status';
            DataClassification = CustomerContent;
            Editable = true;
            OptionCaption = ' ,Scheduled for Posting,Error,Posting';
            OptionMembers = " ","Scheduled for Posting",Error,Posting;


        }
        field(18; "Job Queue Entry ID"; Guid)
        {
            Caption = 'Job Queue Entry ID';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(19; "Job Type"; Option)
        {
            Caption = 'Job Type';
            DataClassification = CustomerContent;
            Editable = false;
            OptionCaption = 'Invt. Pick,Invt. Put-away,Pick,Put-away,Phy. Inv. Journal,Item Journal,Transfer Order,Movement,Invt. Movement,Store Counting,Item Reclass.,Approve Counting,Unplanned Count';
            OptionMembers = "Invt. Pick","Invt. Put-away",Pick,"Put-away","Phy. Inv. Journal","Item Journal","Transfer Order",Movement,"Invt. Movement","Store Counting","Item Reclass.","Approve Counting","Unplanned Count";
        }
        field(20; "Job Queue Priority for Post"; Integer)
        {
            Caption = 'Job Queue Priority for Post';
            DataClassification = CustomerContent;
            Editable = false;
            InitValue = 1000;
            MinValue = 0;


        }
        field(21; "Session Id"; Text[30])
        {
            Caption = 'Session Id';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; Id)
        {
        }
    }

    fieldgroups
    {
    }



}

