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
                field(Company; Company)
                {
                    ApplicationArea = All;
                    Editable = SetEditable;
                    ToolTip = 'Specifies the value of the Company field';
                }
                field("Task Template"; "Task Template")
                {
                    ApplicationArea = All;
                    Editable = SetEditable;
                    ToolTip = 'Specifies the value of the Task Template field';
                }
                field("Task Batch"; "Task Batch")
                {
                    ApplicationArea = All;
                    Editable = SetEditable;
                    ToolTip = 'Specifies the value of the Task Batch field';
                }
                field("Task Line No."; "Task Line No.")
                {
                    ApplicationArea = All;
                    Editable = SetEditable;
                    ToolTip = 'Specifies the value of the Task Line No. field';
                }
                field("Next Run time"; "Next Run time")
                {
                    ApplicationArea = All;
                    Editable = SetEditable;
                    ToolTip = 'Specifies the value of the Next Run time field';
                }
                field("Task Worker Group"; "Task Worker Group")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Task Worker Group field';
                }
                field(Status; Status)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Status field';
                }
                field("Assigned To User"; "Assigned To User")
                {
                    ApplicationArea = All;
                    DrillDown = false;
                    Lookup = false;
                    ToolTip = 'Specifies the value of the Assigned To User field';
                }
                field("Assigned Time"; "Assigned Time")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Assigned Time field';
                }
                field("Started Time"; "Started Time")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Started Time field';
                }
                field(Enabled; Enabled)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Enabled field';
                }
                field("Estimated Duration"; "Estimated Duration")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Estimated Duration field';
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

