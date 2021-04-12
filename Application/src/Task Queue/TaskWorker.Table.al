table 6059907 "NPR Task Worker"
{
    // TQ1.24/JDH/20150320 CASE 208247 Added Captions
    // TQ1.28/MHA/20151216  CASE 229609 Task Queue
    // TQ1.34/JDH /20181011 CASE 326930 New key

    Caption = 'Task Worker';
    DataPerCompany = false;
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Server Instance ID"; Integer)
        {
            Caption = 'Server Instance ID';
            DataClassification = CustomerContent;
        }
        field(2; "User ID"; Text[64])
        {
            Caption = 'User ID';
            DataClassification = CustomerContent;
        }
        field(3; "Session ID"; Integer)
        {
            Caption = 'Session ID';
            DataClassification = CustomerContent;
        }
        field(10; "Login Time"; DateTime)
        {
            Caption = 'Login Time';
            DataClassification = CustomerContent;
        }
        field(11; "Current Company"; Text[30])
        {
            Caption = 'Current Company';
            DataClassification = CustomerContent;
        }
        field(15; "Last HeartBeat (When Idle)"; DateTime)
        {
            Caption = 'Last HeartBeat (When Idle)';
            DataClassification = CustomerContent;
        }
        field(16; "Current Check Interval"; Duration)
        {
            Caption = 'Current Check Interval';
            DataClassification = CustomerContent;
        }
        field(25; "Current Task Company"; Text[30])
        {
            CalcFormula = Lookup("NPR Task Queue".Company WHERE("Assigned to Service Inst.ID" = FIELD("Server Instance ID"),
                                                             "Assigned to Session ID" = FIELD("Session ID")));
            Caption = 'Current Task Company';
            FieldClass = FlowField;
        }
        field(26; "Current Task Template"; Code[10])
        {
            CalcFormula = Lookup("NPR Task Queue"."Task Template" WHERE("Assigned to Service Inst.ID" = FIELD("Server Instance ID"),
                                                                     "Assigned to Session ID" = FIELD("Session ID")));
            Caption = 'Current Task Template';
            FieldClass = FlowField;
        }
        field(27; "Current Task Batch"; Code[10])
        {
            CalcFormula = Lookup("NPR Task Queue"."Task Batch" WHERE("Assigned to Service Inst.ID" = FIELD("Server Instance ID"),
                                                                  "Assigned to Session ID" = FIELD("Session ID")));
            Caption = 'Current Task Batch';
            FieldClass = FlowField;
        }
        field(28; "Current Task Line No."; Integer)
        {
            CalcFormula = Lookup("NPR Task Queue"."Task Line No." WHERE("Assigned to Service Inst.ID" = FIELD("Server Instance ID"),
                                                                     "Assigned to Session ID" = FIELD("Session ID")));
            Caption = 'Current Task Line no.';
            FieldClass = FlowField;
        }
        field(30; "Task Worker Group"; Code[10])
        {
            Caption = 'Task Worker Group';
            TableRelation = "NPR Task Worker Group";
            DataClassification = CustomerContent;
        }
        field(31; "Current Language ID"; Integer)
        {
            Caption = 'Current Language ID';
            DataClassification = CustomerContent;
        }
        field(40; Active; Boolean)
        {
            Caption = 'Active';
            DataClassification = CustomerContent;
        }
        field(50; "Application Name"; Text[64])
        {
            Caption = 'Application Name';
            DataClassification = CustomerContent;
        }
        field(51; "DB Name"; Text[128])
        {
            Caption = 'Database Name';
            DataClassification = CustomerContent;
        }
        field(52; "Host Name"; Text[64])
        {
            Caption = 'Host Name';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Server Instance ID", "Session ID")
        {
        }
        key(Key2; "Last HeartBeat (When Idle)")
        {
        }
    }

    fieldgroups
    {
    }
}

