page 6059905 "NPR Task Queue"
{
    // TQ1.28/TS/20150909 CASE 222526 Prevent Modify if not in Current Company
    // NPR5.37/BR/20171023 CASE 293886 Disabled Drilldown and Lookup from "Assigned To User" field for security reasons

    Caption = 'Task Queue';
    PageType = List;
    SourceTable = "NPR Task Queue";
    UsageCategory = History;

    layout
    {
        area(content)
        {
            usercontrol(PingPong; "NPRMicrosoft.Dynamics.Nav.Client.PingPong")
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
                field(Company; Company)
                {
                    ApplicationArea = All;
                    Editable = SetEditable;
                }
                field("Task Template"; "Task Template")
                {
                    ApplicationArea = All;
                    Editable = SetEditable;
                }
                field("Task Batch"; "Task Batch")
                {
                    ApplicationArea = All;
                    Editable = SetEditable;
                }
                field("Task Line No."; "Task Line No.")
                {
                    ApplicationArea = All;
                    Editable = SetEditable;
                }
                field("Next Run time"; "Next Run time")
                {
                    ApplicationArea = All;
                    Editable = SetEditable;
                }
                field("Task Worker Group"; "Task Worker Group")
                {
                    ApplicationArea = All;
                }
                field(Status; Status)
                {
                    ApplicationArea = All;
                }
                field("Assigned To User"; "Assigned To User")
                {
                    ApplicationArea = All;
                    DrillDown = false;
                    Lookup = false;
                }
                field("Assigned Time"; "Assigned Time")
                {
                    ApplicationArea = All;
                }
                field("Started Time"; "Started Time")
                {
                    ApplicationArea = All;
                }
                field(Enabled; Enabled)
                {
                    ApplicationArea = All;
                }
                field("Estimated Duration"; "Estimated Duration")
                {
                    ApplicationArea = All;
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

