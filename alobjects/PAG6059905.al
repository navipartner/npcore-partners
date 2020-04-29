page 6059905 "Task Queue"
{
    // TQ1.28/TS/20150909 CASE 222526 Prevent Modify if not in Current Company
    // NPR5.37/BR/20171023 CASE 293886 Disabled Drilldown and Lookup from "Assigned To User" field for security reasons

    Caption = 'Task Queue';
    PageType = List;
    SourceTable = "Task Queue";
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
                field(Company;Company)
                {
                    Editable = SetEditable;
                }
                field("Task Template";"Task Template")
                {
                    Editable = SetEditable;
                }
                field("Task Batch";"Task Batch")
                {
                    Editable = SetEditable;
                }
                field("Task Line No.";"Task Line No.")
                {
                    Editable = SetEditable;
                }
                field("Next Run time";"Next Run time")
                {
                    Editable = SetEditable;
                }
                field("Task Worker Group";"Task Worker Group")
                {
                }
                field(Status;Status)
                {
                }
                field("Assigned To User";"Assigned To User")
                {
                    DrillDown = false;
                    Lookup = false;
                }
                field("Assigned Time";"Assigned Time")
                {
                }
                field("Started Time";"Started Time")
                {
                }
                field(Enabled;Enabled)
                {
                }
                field("Estimated Duration";"Estimated Duration")
                {
                }
            }
        }
    }

    actions
    {
    }

    trigger OnModifyRecord(): Boolean
    begin
        //-TQ1.28
        if Company <> CompanyName then
          Error(Text001);
        //+TQ1.28
    end;

    var
        [InDataSet]
        SetEditable: Boolean;
        Text001: Label 'Line cannot be modify in current company.';
}

