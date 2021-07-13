page 6151212 "NPR NpCs Arch.Doc.Log Entries"
{
    Caption = 'Archived Collect Document Log Entries';
    Editable = false;
    PageType = List;
    UsageCategory = Administration;

    SourceTable = "NPR NpCs Arch. Doc. Log Entry";
    ApplicationArea = NPRRetail;

    layout
    {
        area(content)
        {
            usercontrol(PingPong; "NPRMicrosoft.Dynamics.Nav.Client.PingPong")
            {
                ApplicationArea = NPRRetail;


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

