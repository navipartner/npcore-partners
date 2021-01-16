page 6059904 "NPR Task Log (Task)"
{
    // TQ1.17/JDH/20141015 CASE 179044 Page made non editable
    // TQ1.28/MHA/20151216  CASE 229609 Task Queue
    // TQ1.29/JDH /20161101 CASE 242044 Changed sorting order

    Caption = 'Task Log';
    Editable = false;
    PageType = List;
    SourceTable = "NPR Task Log (Task)";
    SourceTableView = SORTING("Entry No.")
                      ORDER(Descending);
    UsageCategory = History;
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Entry No."; "Entry No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Entry No. field';
                }
                field("Journal Template Name"; "Journal Template Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Journal Template Name field';
                }
                field("Journal Batch Name"; "Journal Batch Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Journal Batch Name field';
                }
                field("Line No."; "Line No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Line No. field';
                }
                field("Entry Type"; "Entry Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Entry Type field';
                }
                field("Starting Time"; "Starting Time")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Starting Time field';
                }
                field("Expected Ending Time"; "Expected Ending Time")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Expected Ending Time field';
                }
                field("Ending Time"; "Ending Time")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Ending Time field';
                }
                field("Task Duration"; "Task Duration")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Task Duration field';
                }
                field(Status; Status)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Status field';
                }
                field("Last Error Message"; "Last Error Message")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Last Error Message field';
                }
                field("User ID"; "User ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the User ID field';
                }
                field("Server Instance ID"; "Server Instance ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Server Instance ID field';
                }
                field("Session ID"; "Session ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Session ID field';
                }
                field("Task Worker Group"; "Task Worker Group")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Task Worker Group field';
                }
                field("Object Type"; "Object Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Object Type field';
                }
                field("Object No."; "Object No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Object No. field';
                }
                field("No. of Output Log Entries"; "No. of Output Log Entries")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the No. of Output Log Entries field';
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

