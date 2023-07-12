table 6059903 "NPR Task Queue"
{
    Access = Internal;
    Caption = 'Task Queue';
    DataPerCompany = false;
    DataClassification = CustomerContent;
    ObsoleteState = Removed;
    ObsoleteTag = 'NPR23.0';
    ObsoleteReason = 'Task Queue module removed from NP Retail. We are now using Job Queue instead.';

    fields
    {
        field(1; Company; Text[30])
        {
            Caption = 'Company';
            NotBlank = true;
            DataClassification = CustomerContent;
        }
        field(2; "Task Template"; Code[10])
        {
            Caption = 'Task Template';
            NotBlank = true;
            DataClassification = CustomerContent;
        }
        field(3; "Task Batch"; Code[10])
        {
            Caption = 'Task Batch';
            NotBlank = true;
            DataClassification = CustomerContent;
        }
        field(4; "Task Line No."; Integer)
        {
            Caption = 'Task Line No.';
            NotBlank = true;
            DataClassification = CustomerContent;
        }
        field(9; Enabled; Boolean)
        {
            Caption = 'Enabled';
            InitValue = true;
            DataClassification = CustomerContent;
        }
        field(10; "Next Run time"; DateTime)
        {
            Caption = 'Next Run time';
            DataClassification = CustomerContent;
        }
        field(15; Priority; Option)
        {
            Caption = 'Priority';
            OptionCaption = 'Low,,Medium,,High';
            OptionMembers = Low,,Medium,,High;
            DataClassification = CustomerContent;
        }
        field(16; "Estimated Duration"; Duration)
        {
            Caption = 'Estimated Duration';
            DataClassification = CustomerContent;
        }
        field(20; "Task Worker Group"; Code[10])
        {
            Caption = 'Task Worker Group';
            DataClassification = CustomerContent;
        }
        field(21; "Template Type"; Option)
        {
            Caption = 'Template Type';
            Editable = false;
            OptionCaption = 'General,NaviPartner';
            OptionMembers = General,NaviPartner;
            DataClassification = CustomerContent;
        }
        field(30; Status; Option)
        {
            Caption = 'Status';
            OptionCaption = 'Awaiting,Assigned,Started';
            OptionMembers = Awaiting,Assigned,Started;
            DataClassification = CustomerContent;
        }
        field(31; "Assigned To User"; Code[50])
        {
            Caption = 'Assigned To User';
            DataClassification = EndUserIdentifiableInformation;
        }
        field(32; "Assigned Time"; DateTime)
        {
            Caption = 'Assigned Time';
            DataClassification = CustomerContent;
        }
        field(33; "Started Time"; DateTime)
        {
            Caption = 'Started Time';
            DataClassification = CustomerContent;
        }
        field(34; "Assigned to Service Inst.ID"; Integer)
        {
            Caption = 'Assigned to Service Inst.ID';
            DataClassification = CustomerContent;
        }
        field(35; "Assigned to Session ID"; Integer)
        {
            Caption = 'Assigned to Session ID';
            DataClassification = EndUserPseudonymousIdentifiers;
        }
        field(40; "Object Type"; Option)
        {
            Caption = 'Object Type';
            OptionCaption = ',Report,Codeunit';
            OptionMembers = " ","Report","Codeunit";
            DataClassification = CustomerContent;
        }
        field(41; "Object No."; Integer)
        {
            Caption = 'Object No.';
            DataClassification = CustomerContent;
        }
        field(60; "Last Task Log Entry No."; Integer)
        {
            Caption = 'Last Task Log Entry No.';
            DataClassification = CustomerContent;
        }
        field(61; "Last Executed Date"; DateTime)
        {
            ObsoleteState = Removed;
            ObsoleteTag = 'NPR23.0';
            ObsoleteReason = 'Task Queue module removed from NP Retail. We are now using Job Queue instead.';
            CalcFormula = Max("NPR Task Log (Task)"."Ending Time" WHERE("Journal Template Name" = FIELD("Task Template"),
                                                                     "Journal Batch Name" = FIELD("Task Batch"),
                                                                     "Line No." = FIELD("Task Line No.")));
            Caption = 'Last Executed Date';
            FieldClass = FlowField;
        }
        field(62; "Last Execution Status"; Option)
        {
            Caption = 'Last Execution Status';
            OptionCaption = ' ,Started,Error,Succes';
            OptionMembers = " ",Started,Error,Succes;
            DataClassification = CustomerContent;
        }
        field(63; "Last Successfull Run"; DateTime)
        {
            Caption = 'Last Successfull Run';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; Company, "Task Template", "Task Batch", "Task Line No.")
        {
        }
        key(Key2; "Next Run time")
        {
        }
        key(Key3; "Task Worker Group", Enabled, Priority, "Next Run time")
        {
            Enabled = false;
        }
        key(Key4; "Assigned to Service Inst.ID", "Assigned to Session ID", Enabled, "Task Worker Group", Company, "Next Run time")
        {
        }
    }
}

