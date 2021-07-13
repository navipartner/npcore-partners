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
    ApplicationArea = NPRRetail;


    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Entry No."; Rec."Entry No.")
                {

                    ToolTip = 'Specifies the value of the Entry No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Journal Template Name"; Rec."Journal Template Name")
                {

                    ToolTip = 'Specifies the value of the Journal Template Name field';
                    ApplicationArea = NPRRetail;
                }
                field("Journal Batch Name"; Rec."Journal Batch Name")
                {

                    ToolTip = 'Specifies the value of the Journal Batch Name field';
                    ApplicationArea = NPRRetail;
                }
                field("Line No."; Rec."Line No.")
                {

                    ToolTip = 'Specifies the value of the Line No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Entry Type"; Rec."Entry Type")
                {

                    ToolTip = 'Specifies the value of the Entry Type field';
                    ApplicationArea = NPRRetail;
                }
                field("Starting Time"; Rec."Starting Time")
                {

                    ToolTip = 'Specifies the value of the Starting Time field';
                    ApplicationArea = NPRRetail;
                }
                field("Expected Ending Time"; Rec."Expected Ending Time")
                {

                    ToolTip = 'Specifies the value of the Expected Ending Time field';
                    ApplicationArea = NPRRetail;
                }
                field("Ending Time"; Rec."Ending Time")
                {

                    ToolTip = 'Specifies the value of the Ending Time field';
                    ApplicationArea = NPRRetail;
                }
                field("Task Duration"; Rec."Task Duration")
                {

                    ToolTip = 'Specifies the value of the Task Duration field';
                    ApplicationArea = NPRRetail;
                }
                field(Status; Rec.Status)
                {

                    ToolTip = 'Specifies the value of the Status field';
                    ApplicationArea = NPRRetail;
                }
                field("Last Error Message"; Rec."Last Error Message")
                {

                    ToolTip = 'Specifies the value of the Last Error Message field';
                    ApplicationArea = NPRRetail;
                }
                field("User ID"; Rec."User ID")
                {

                    ToolTip = 'Specifies the value of the User ID field';
                    ApplicationArea = NPRRetail;
                }
                field("Server Instance ID"; Rec."Server Instance ID")
                {

                    ToolTip = 'Specifies the value of the Server Instance ID field';
                    ApplicationArea = NPRRetail;
                }
                field("Session ID"; Rec."Session ID")
                {

                    ToolTip = 'Specifies the value of the Session ID field';
                    ApplicationArea = NPRRetail;
                }
                field("Task Worker Group"; Rec."Task Worker Group")
                {

                    ToolTip = 'Specifies the value of the Task Worker Group field';
                    ApplicationArea = NPRRetail;
                }
                field("Object Type"; Rec."Object Type")
                {

                    ToolTip = 'Specifies the value of the Object Type field';
                    ApplicationArea = NPRRetail;
                }
                field("Object No."; Rec."Object No.")
                {

                    ToolTip = 'Specifies the value of the Object No. field';
                    ApplicationArea = NPRRetail;
                }
                field("No. of Output Log Entries"; Rec."No. of Output Log Entries")
                {

                    ToolTip = 'Specifies the value of the No. of Output Log Entries field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }

    actions
    {
    }

    trigger OnOpenPage()
    begin
        if Rec.FindFirst() then;
    end;
}

