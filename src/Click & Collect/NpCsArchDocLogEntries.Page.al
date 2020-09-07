page 6151212 "NPR NpCs Arch.Doc.Log Entries"
{
    // NPR5.50/MHA /20190531  CASE 345261 Object created - Collect in Store

    Caption = 'Archived Collect Document Log Entries';
    Editable = false;
    PageType = List;
    SourceTable = "NPR NpCs Arch. Doc. Log Entry";

    layout
    {
        area(content)
        {
            usercontrol(PingPong; "NPRMicrosoft.Dynamics.Nav.Client.PingPong")
            {
                ApplicationArea=All;

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
                }
                field("Workflow Type"; "Workflow Type")
                {
                    ApplicationArea = All;
                }
                field("Workflow Module"; "Workflow Module")
                {
                    ApplicationArea = All;
                }
                field("Store Code"; "Store Code")
                {
                    ApplicationArea = All;
                }
                field("Log Message"; "Log Message")
                {
                    ApplicationArea = All;
                }
                field("Error Entry"; "Error Entry")
                {
                    ApplicationArea = All;
                }
                field("GetErrorMessage()"; GetErrorMessage())
                {
                    ApplicationArea = All;
                    Caption = 'Error Message';
                }
                field("User ID"; "User ID")
                {
                    ApplicationArea = All;
                }
                field("Entry No."; "Entry No.")
                {
                    ApplicationArea = All;
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
                ApplicationArea=All;

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

    procedure SetAutoUpdate(NewAutoUpdate: Boolean)
    begin
        AutoUpdate := NewAutoUpdate;
        Ping();
    end;
}

