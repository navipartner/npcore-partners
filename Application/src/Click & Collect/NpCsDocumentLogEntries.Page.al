page 6151201 "NPR NpCs Document Log Entries"
{
    Extensible = False;
    Caption = 'Collect Document Log Entries';
    Editable = false;
    PageType = List;
    UsageCategory = Administration;

    SourceTable = "NPR NpCs Document Log Entry";
    ApplicationArea = NPRRetail;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Log Date"; Rec."Log Date")
                {

                    ToolTip = 'Specifies the value of the Log Date field';
                    ApplicationArea = NPRRetail;
                }
                field("Workflow Type"; Rec."Workflow Type")
                {

                    ToolTip = 'Specifies the value of the Workflow Type field';
                    ApplicationArea = NPRRetail;
                }
                field("Workflow Module"; Rec."Workflow Module")
                {

                    ToolTip = 'Specifies the value of the Workflow Module field';
                    ApplicationArea = NPRRetail;
                }
                field("Store Code"; Rec."Store Code")
                {

                    ToolTip = 'Specifies the value of the Store Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Log Message"; Rec."Log Message")
                {

                    ToolTip = 'Specifies the value of the Log Message field';
                    ApplicationArea = NPRRetail;
                }
                field("Error Entry"; Rec."Error Entry")
                {

                    ToolTip = 'Specifies the value of the Error Entry field';
                    ApplicationArea = NPRRetail;
                }
                field(ErrorMessage; Rec.GetErrorMessage())
                {

                    Caption = 'Error Message';
                    ToolTip = 'Specifies the value of the Error Message field';
                    ApplicationArea = NPRRetail;
                }
                field("User ID"; Rec."User ID")
                {

                    ToolTip = 'Specifies the value of the User ID field';
                    ApplicationArea = NPRRetail;
                }
                field("Entry No."; Rec."Entry No.")
                {

                    ToolTip = 'Specifies the value of the Entry No. field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("View Error Message")
            {
                Caption = 'View Error Message';
                Image = Log;

                ToolTip = 'Executes the View Error Message action';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                var
                    ErrorMessage: Text;
                begin
                    ErrorMessage := Rec.GetErrorMessage();
                    Message(ErrorMessage);
                end;
            }
        }
    }
}

