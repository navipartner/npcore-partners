page 6059907 "NPR Task Worker"
{
    Caption = 'Task Worker';
    PageType = List;
    SourceTable = "NPR Task Worker";
    UsageCategory = History;

    layout
    {
        area(content)
        {
            usercontrol(PingPong; "NPRMicrosoft.Dynamics.Nav.Client.PingPong")
            {
                ApplicationArea=All;

                trigger AddInReady()
                begin
                    CurrPage.PingPong.Ping(500);
                end;

                trigger Pong()
                begin
                    CurrPage.PingPong.Ping(1000);
                    CurrPage.Update(false);
                end;
            }
            repeater(Group)
            {
                field("Server Instance ID"; "Server Instance ID")
                {
                    ApplicationArea = All;
                }
                field("User ID"; "User ID")
                {
                    ApplicationArea = All;
                }
                field("Session ID"; "Session ID")
                {
                    ApplicationArea = All;
                }
                field("Login Time"; "Login Time")
                {
                    ApplicationArea = All;
                }
                field("Current Company"; "Current Company")
                {
                    ApplicationArea = All;
                }
                field("Last HeartBeat (When Idle)"; "Last HeartBeat (When Idle)")
                {
                    ApplicationArea = All;
                }
                field("Current Check Interval"; "Current Check Interval")
                {
                    ApplicationArea = All;
                }
                field("Current Task Company"; "Current Task Company")
                {
                    ApplicationArea = All;
                }
                field("Current Task Template"; "Current Task Template")
                {
                    ApplicationArea = All;
                }
                field("Current Task Batch"; "Current Task Batch")
                {
                    ApplicationArea = All;
                }
                field("Current Task Line No."; "Current Task Line No.")
                {
                    ApplicationArea = All;
                }
                field("Task Worker Group"; "Task Worker Group")
                {
                    ApplicationArea = All;
                }
                field("Current Language ID"; "Current Language ID")
                {
                    ApplicationArea = All;
                }
                field(Active; Active)
                {
                    ApplicationArea = All;
                }
                field("Application Name"; "Application Name")
                {
                    ApplicationArea = All;
                }
                field("DB Name"; "DB Name")
                {
                    ApplicationArea = All;
                }
                field("Host Name"; "Host Name")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
    }
}

