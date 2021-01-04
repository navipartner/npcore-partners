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
                ApplicationArea = All;

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
                    ToolTip = 'Specifies the value of the Server Instance ID field';
                }
                field("User ID"; "User ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the User ID field';
                }
                field("Session ID"; "Session ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Session ID field';
                }
                field("Login Time"; "Login Time")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Login Time field';
                }
                field("Current Company"; "Current Company")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Current Company field';
                }
                field("Last HeartBeat (When Idle)"; "Last HeartBeat (When Idle)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Last HeartBeat (When Idle) field';
                }
                field("Current Check Interval"; "Current Check Interval")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Current Check Interval field';
                }
                field("Current Task Company"; "Current Task Company")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Current Task Company field';
                }
                field("Current Task Template"; "Current Task Template")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Current Task Template field';
                }
                field("Current Task Batch"; "Current Task Batch")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Current Task Batch field';
                }
                field("Current Task Line No."; "Current Task Line No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Current Task Line no. field';
                }
                field("Task Worker Group"; "Task Worker Group")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Task Worker Group field';
                }
                field("Current Language ID"; "Current Language ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Current Language ID field';
                }
                field(Active; Active)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Active field';
                }
                field("Application Name"; "Application Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Application Name field';
                }
                field("DB Name"; "DB Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Database Name field';
                }
                field("Host Name"; "Host Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Host Name field';
                }
            }
        }
    }

    actions
    {
    }
}

