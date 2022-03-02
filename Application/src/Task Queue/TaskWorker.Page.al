page 6059907 "NPR Task Worker"
{
    Extensible = False;
    Caption = 'Task Worker';
    PageType = List;
    SourceTable = "NPR Task Worker";
    UsageCategory = History;
    ApplicationArea = NPRRetail;


    layout
    {
        area(content)
        {
#if not CLOUD
            usercontrol(PingPong; "NPRMicrosoft.Dynamics.Nav.Client.PingPong")
            {
                ApplicationArea = NPRRetail;


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
#endif
            repeater(Group)
            {
                field("Server Instance ID"; Rec."Server Instance ID")
                {

                    ToolTip = 'Specifies the value of the Server Instance ID field';
                    ApplicationArea = NPRRetail;
                }
                field("User ID"; Rec."User ID")
                {

                    ToolTip = 'Specifies the value of the User ID field';
                    ApplicationArea = NPRRetail;
                }
                field("Session ID"; Rec."Session ID")
                {

                    ToolTip = 'Specifies the value of the Session ID field';
                    ApplicationArea = NPRRetail;
                }
                field("Login Time"; Rec."Login Time")
                {

                    ToolTip = 'Specifies the value of the Login Time field';
                    ApplicationArea = NPRRetail;
                }
                field("Current Company"; Rec."Current Company")
                {

                    ToolTip = 'Specifies the value of the Current Company field';
                    ApplicationArea = NPRRetail;
                }
                field("Last HeartBeat (When Idle)"; Rec."Last HeartBeat (When Idle)")
                {

                    ToolTip = 'Specifies the value of the Last HeartBeat (When Idle) field';
                    ApplicationArea = NPRRetail;
                }
                field("Current Check Interval"; Rec."Current Check Interval")
                {

                    ToolTip = 'Specifies the value of the Current Check Interval field';
                    ApplicationArea = NPRRetail;
                }
                field("Current Task Company"; Rec."Current Task Company")
                {

                    ToolTip = 'Specifies the value of the Current Task Company field';
                    ApplicationArea = NPRRetail;
                }
                field("Current Task Template"; Rec."Current Task Template")
                {

                    ToolTip = 'Specifies the value of the Current Task Template field';
                    ApplicationArea = NPRRetail;
                }
                field("Current Task Batch"; Rec."Current Task Batch")
                {

                    ToolTip = 'Specifies the value of the Current Task Batch field';
                    ApplicationArea = NPRRetail;
                }
                field("Current Task Line No."; Rec."Current Task Line No.")
                {

                    ToolTip = 'Specifies the value of the Current Task Line no. field';
                    ApplicationArea = NPRRetail;
                }
                field("Task Worker Group"; Rec."Task Worker Group")
                {

                    ToolTip = 'Specifies the value of the Task Worker Group field';
                    ApplicationArea = NPRRetail;
                }
                field("Current Language ID"; Rec."Current Language ID")
                {

                    ToolTip = 'Specifies the value of the Current Language ID field';
                    ApplicationArea = NPRRetail;
                }
                field(Active; Rec.Active)
                {

                    ToolTip = 'Specifies the value of the Active field';
                    ApplicationArea = NPRRetail;
                }
                field("Application Name"; Rec."Application Name")
                {

                    ToolTip = 'Specifies the value of the Application Name field';
                    ApplicationArea = NPRRetail;
                }
                field("DB Name"; Rec."DB Name")
                {

                    ToolTip = 'Specifies the value of the Database Name field';
                    ApplicationArea = NPRRetail;
                }
                field("Host Name"; Rec."Host Name")
                {

                    ToolTip = 'Specifies the value of the Host Name field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }

    actions
    {
    }
}

