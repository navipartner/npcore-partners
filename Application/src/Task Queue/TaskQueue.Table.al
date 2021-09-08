table 6059903 "NPR Task Queue"
{
    // TQ1.11/JDH/20140905 CASE 179044 Key changed from  "Task Worker Group","Next Run time" to
    //                                                   "Task Worker Group",Priority,"Next Run time"
    // TQ1.16/JDH /20140916 CASE 179044 Aligned code in order to upgrade to 2013
    // TQ1.17/JDH /20141013 CASE 179044 lookupform added
    // TQ1.18/JDH /20141126 CASE 198170 Key added Task Worker Group,Assigned to Service Inst.ID,Assigned to Session ID,Enabled,Company,Next Run time
    // TQ1.24/JDH /20150320 CASE 208247 Added Captions
    // TQ1.28/MHA /20151216 CASE 229609 Task Queue
    // TQ1.29/JDH /20161101 CASE 242044 removed executing connection id
    // TQ1.33/BHR /20180824 CASE 322752 Replace record Object to Allobj -field 41
    // TQ1.34/JDH /20181011 CASE 326930 Changed field order in key, and disabled key Task Worker Group,Enabled,Priority,Next Run time

    Caption = 'Task Queue';
    DataPerCompany = false;
    DrillDownPageID = "NPR Task Queue";
    LookupPageID = "NPR Task Queue";
    DataClassification = CustomerContent;

    fields
    {
        field(1; Company; Text[30])
        {
            Caption = 'Company';
            NotBlank = true;
            TableRelation = Company;
            DataClassification = CustomerContent;
        }
        field(2; "Task Template"; Code[10])
        {
            Caption = 'Task Template';
            NotBlank = true;
            TableRelation = "NPR Task Template";
            DataClassification = CustomerContent;
        }
        field(3; "Task Batch"; Code[10])
        {
            Caption = 'Task Batch';
            NotBlank = true;
            TableRelation = "NPR Task Batch".Name WHERE("Journal Template Name" = FIELD("Task Template"));
            DataClassification = CustomerContent;
        }
        field(4; "Task Line No."; Integer)
        {
            Caption = 'Task Line No.';
            NotBlank = true;
            TableRelation = "NPR Task Line"."Line No." WHERE("Journal Template Name" = FIELD("Task Template"),
                                                          "Journal Batch Name" = FIELD("Task Batch"));
            DataClassification = CustomerContent;
        }
        field(9; Enabled; Boolean)
        {
            Caption = 'Enabled';
            InitValue = true;
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                //-TQ1.11
                UpdateTaskLine();
                //+TQ1.11
            end;
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

            trigger OnValidate()
            begin
                //-TQ1.11
                UpdateTaskLine();
                //+TQ1.11
            end;
        }
        field(16; "Estimated Duration"; Duration)
        {
            Caption = 'Estimated Duration';
            DataClassification = CustomerContent;
        }
        field(20; "Task Worker Group"; Code[10])
        {
            Caption = 'Task Worker Group';
            TableRelation = "NPR Task Worker Group";
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                //-TQ1.11
                UpdateTaskLine();
                //+TQ1.11
            end;
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

            trigger OnValidate()
            begin
                case Status of
                    Status::Awaiting:
                        begin
                            "Assigned To User" := '';
                            "Assigned Time" := 0DT;
                            "Assigned to Service Inst.ID" := 0;
                            "Assigned to Session ID" := 0;
                            "Started Time" := 0DT;
                        end;
                    Status::Assigned:
                        begin
                            "Assigned To User" := CopyStr(UserId, 1, MaxStrLen("Assigned To User"));
                            "Assigned Time" := CurrentDateTime;
                            "Assigned to Service Inst.ID" := ServiceInstanceId();
                            "Assigned to Session ID" := SessionId();
                        end;
                    Status::Started:
                        begin
                            "Assigned To User" := CopyStr(UserId, 1, MaxStrLen("Assigned To User"));
                            "Assigned Time" := CurrentDateTime;
                            "Assigned to Service Inst.ID" := ServiceInstanceId();
                            "Assigned to Session ID" := SessionId();
                            "Started Time" := CurrentDateTime;
                        end;
                end;
            end;
        }
        field(31; "Assigned To User"; Code[50])
        {
            Caption = 'Assigned To User';
            TableRelation = User."User Name";
            //This property is currently not supported
            //TestTableRelation = false;
            ValidateTableRelation = false;
            DataClassification = CustomerContent;
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
            DataClassification = CustomerContent;
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
            TableRelation = IF ("Object Type" = CONST(Report)) AllObj."Object ID" WHERE("Object Type" = CONST(Report))
            ELSE
            IF ("Object Type" = CONST(Codeunit)) AllObj."Object ID" WHERE("Object Type" = CONST(Codeunit));
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
            end;
        }
        field(60; "Last Task Log Entry No."; Integer)
        {
            Caption = 'Last Task Log Entry No.';
            DataClassification = CustomerContent;
        }
        field(61; "Last Executed Date"; DateTime)
        {
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

    fieldgroups
    {
    }

    trigger OnDelete()
    begin
        TestField("Template Type", "Template Type"::General);
    end;

    trigger OnInsert()
    begin
        TestField("Template Type", "Template Type"::General);
    end;

    trigger OnModify()
    begin
        TestField("Template Type", "Template Type"::General);
    end;

    trigger OnRename()
    begin
        TestField("Template Type", "Template Type"::General);
    end;

    var
        Text001: Label 'Task Line not found. This task cant be changed';

    procedure SetupNewLine(TaskLine: Record "NPR Task Line"; UseCurrentDateTime: Boolean)
    var
        TaskTemplate: Record "NPR Task Template";
    begin
        TaskTemplate.Get(TaskLine."Journal Template Name");
        Company := CopyStr(CompanyName, 1, MaxStrLen(Company));
        "Task Template" := TaskLine."Journal Template Name";
        "Task Batch" := TaskLine."Journal Batch Name";
        "Task Line No." := TaskLine."Line No.";
        "Task Worker Group" := TaskLine."Task Worker Group";
        Enabled := TaskLine.Enabled;
        "Object Type" := TaskLine."Object Type";
        "Object No." := TaskLine."Object No.";
        Priority := TaskLine.Priority;
        "Template Type" := TaskTemplate.Type;

        if UseCurrentDateTime then
            "Next Run time" := CurrentDateTime;
    end;

    procedure UpdateTaskLine()
    var
        TaskLine: Record "NPR Task Line";
    begin
        //-TQ1.11
        TaskLine.ChangeCompany(Company);
        TaskLine.LockTable();
        if not TaskLine.Get("Task Template", "Task Batch", "Task Line No.") then
            Error(Text001);

        //only if the user changes the line (not if its done by code)
        if CurrFieldNo <> 0 then
            TaskLine.Enabled := Enabled;
        TaskLine.Priority := Priority;
        TaskLine."Task Worker Group" := "Task Worker Group";
        TaskLine.Modify();
        //+TQ1.11
    end;
}

