page 6059907 "Task Worker"
{
    Caption = 'Task Worker';
    PageType = List;
    SourceTable = "Task Worker";
    UsageCategory = History;

    layout
    {
        area(content)
        {
            usercontrol(PingPong;"Microsoft.Dynamics.Nav.Client.PingPong")
            {

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
                field("Server Instance ID";"Server Instance ID")
                {
                }
                field("User ID";"User ID")
                {
                }
                field("Session ID";"Session ID")
                {
                }
                field("Login Time";"Login Time")
                {
                }
                field("Current Company";"Current Company")
                {
                }
                field("Last HeartBeat (When Idle)";"Last HeartBeat (When Idle)")
                {
                }
                field("Current Check Interval";"Current Check Interval")
                {
                }
                field("Current Task Company";"Current Task Company")
                {
                }
                field("Current Task Template";"Current Task Template")
                {
                }
                field("Current Task Batch";"Current Task Batch")
                {
                }
                field("Current Task Line No.";"Current Task Line No.")
                {
                }
                field("Task Worker Group";"Task Worker Group")
                {
                }
                field("Current Language ID";"Current Language ID")
                {
                }
                field(Active;Active)
                {
                }
                field("Application Name";"Application Name")
                {
                }
                field("DB Name";"DB Name")
                {
                }
                field("Host Name";"Host Name")
                {
                }
            }
        }
    }

    actions
    {
    }
}

