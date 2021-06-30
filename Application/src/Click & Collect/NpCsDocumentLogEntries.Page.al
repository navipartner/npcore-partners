page 6151201 "NPR NpCs Document Log Entries"
{
    Caption = 'Collect Document Log Entries';
    Editable = false;
    PageType = List;
    UsageCategory = Administration;
    ApplicationArea = All;
    SourceTable = "NPR NpCs Document Log Entry";

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
                field("Log Date"; Rec."Log Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Log Date field';
                }
                field("Workflow Type"; Rec."Workflow Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Workflow Type field';
                }
                field("Workflow Module"; Rec."Workflow Module")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Workflow Module field';
                }
                field("Store Code"; Rec."Store Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Store Code field';
                }
                field("Log Message"; Rec."Log Message")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Log Message field';
                }
                field("Error Entry"; Rec."Error Entry")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Error Entry field';
                }
                field(ErrorMessage; Rec.GetErrorMessage())
                {
                    ApplicationArea = All;
                    Caption = 'Error Message';
                    ToolTip = 'Specifies the value of the Error Message field';
                }
                field("User ID"; Rec."User ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the User ID field';
                }
                field("Entry No."; Rec."Entry No.")
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
                    ErrorMessage := Rec.GetErrorMessage();
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

    procedure SetAutoUpdate(NewAutoUpdate: Boolean)
    begin
        AutoUpdate := NewAutoUpdate;
        Ping();
    end;
}

