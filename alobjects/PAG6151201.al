page 6151201 "NpCs Document Log Entries"
{
    // NPR5.50/MHA /20190531  CASE 345261 Object created - Collect in Store

    Caption = 'Collect Document Log Entries';
    Editable = false;
    PageType = List;
    SourceTable = "NpCs Document Log Entry";

    layout
    {
        area(content)
        {
            usercontrol(PingPong;"Microsoft.Dynamics.Nav.Client.PingPong")
            {

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
                field("Log Date";"Log Date")
                {
                }
                field("Workflow Type";"Workflow Type")
                {
                }
                field("Workflow Module";"Workflow Module")
                {
                }
                field("Store Code";"Store Code")
                {
                }
                field("Log Message";"Log Message")
                {
                }
                field("Error Entry";"Error Entry")
                {
                }
                field("GetErrorMessage()";GetErrorMessage())
                {
                    Caption = 'Error Message';
                }
                field("User ID";"User ID")
                {
                }
                field("Entry No.";"Entry No.")
                {
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

