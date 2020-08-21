page 6059904 "Task Log (Task)"
{
    // TQ1.17/JDH/20141015 CASE 179044 Page made non editable
    // TQ1.28/MHA/20151216  CASE 229609 Task Queue
    // TQ1.29/JDH /20161101 CASE 242044 Changed sorting order

    Caption = 'Task Log';
    Editable = false;
    PageType = List;
    SourceTable = "Task Log (Task)";
    SourceTableView = SORTING("Entry No.")
                      ORDER(Descending);
    UsageCategory = History;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Entry No."; "Entry No.")
                {
                    ApplicationArea = All;
                }
                field("Journal Template Name"; "Journal Template Name")
                {
                    ApplicationArea = All;
                }
                field("Journal Batch Name"; "Journal Batch Name")
                {
                    ApplicationArea = All;
                }
                field("Line No."; "Line No.")
                {
                    ApplicationArea = All;
                }
                field("Entry Type"; "Entry Type")
                {
                    ApplicationArea = All;
                }
                field("Starting Time"; "Starting Time")
                {
                    ApplicationArea = All;
                }
                field("Expected Ending Time"; "Expected Ending Time")
                {
                    ApplicationArea = All;
                }
                field("Ending Time"; "Ending Time")
                {
                    ApplicationArea = All;
                }
                field("Task Duration"; "Task Duration")
                {
                    ApplicationArea = All;
                }
                field(Status; Status)
                {
                    ApplicationArea = All;
                }
                field("Last Error Message"; "Last Error Message")
                {
                    ApplicationArea = All;
                }
                field("User ID"; "User ID")
                {
                    ApplicationArea = All;
                }
                field("Server Instance ID"; "Server Instance ID")
                {
                    ApplicationArea = All;
                }
                field("Session ID"; "Session ID")
                {
                    ApplicationArea = All;
                }
                field("Task Worker Group"; "Task Worker Group")
                {
                    ApplicationArea = All;
                }
                field("Object Type"; "Object Type")
                {
                    ApplicationArea = All;
                }
                field("Object No."; "Object No.")
                {
                    ApplicationArea = All;
                }
                field("No. of Output Log Entries"; "No. of Output Log Entries")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
    }

    trigger OnOpenPage()
    begin
        if FindFirst then;
    end;
}

