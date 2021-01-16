page 6151212 "NPR NpCs Arch.Doc.Log Entries"
{
    Caption = 'Archived Collect Document Log Entries';
    Editable = false;
    PageType = List;
    UsageCategory = Administration;
    ApplicationArea = All;
    SourceTable = "NPR NpCs Arch. Doc. Log Entry";

    layout
    {
        area(content)
        {
            usercontrol(PingPong; "NPRMicrosoft.Dynamics.Nav.Client.PingPong")
            {
                ApplicationArea = All;

                trigger AddInReady()
                begin
                    PingPongReady := true;
                    Ping();
                end;

                trigger Pong()
                begin
                    CurrPage.PingPong.Stop();

                    CurrPage.Update(false);

                    Ping();
                end;
            }
            repeater(Group)
            {
                field("Log Date"; "Log Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Log Date field';
                }
                field("Workflow Type"; "Workflow Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Workflow Type field';
                }
                field("Workflow Module"; "Workflow Module")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Workflow Module field';
                }
                field("Store Code"; "Store Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Store Code field';
                }
                field("Log Message"; "Log Message")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Log Message field';
                }
                field("Error Entry"; "Error Entry")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Error Entry field';
                }
                field("GetErrorMessage()"; GetErrorMessage())
                {
                    ApplicationArea = All;
                    Caption = 'Error Message';
                    ToolTip = 'Specifies the value of the Error Message field';
                }
                field("User ID"; "User ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the User ID field';
                }
                field("Entry No."; "Entry No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Entry No. field';
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
                ApplicationArea = All;
                ToolTip = 'Executes the View Error Message action';

                trigger OnAction()
                var
                    ErrorMessage: Text;
                begin
                    ErrorMessage := GetErrorMessage();
                    Message(ErrorMessage);
                end;
            }
        }
    }

    var
        AutoUpdate: Boolean;
        PingPongReady: Boolean;

    local procedure Ping()
    begin
        if not AutoUpdate then
            exit;
        if not PingPongReady then
            exit;

        CurrPage.PingPong.Ping(1000);
    end;
}

