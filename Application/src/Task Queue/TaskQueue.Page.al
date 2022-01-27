page 6059905 "NPR Task Queue"
{
    Extensible = False;
    // TQ1.28/TS/20150909 CASE 222526 Prevent Modify if not in Current Company
    // NPR5.37/BR/20171023 CASE 293886 Disabled Drilldown and Lookup from "Assigned To User" field for security reasons

    Caption = 'Task Queue';
    PageType = List;
    SourceTable = "NPR Task Queue";
    UsageCategory = History;
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
                field(Company; Rec.Company)
                {

                    Editable = SetEditable;
                    ToolTip = 'Specifies the value of the Company field';
                    ApplicationArea = NPRRetail;
                }
                field("Task Template"; Rec."Task Template")
                {

                    Editable = SetEditable;
                    ToolTip = 'Specifies the value of the Task Template field';
                    ApplicationArea = NPRRetail;
                }
                field("Task Batch"; Rec."Task Batch")
                {

                    Editable = SetEditable;
                    ToolTip = 'Specifies the value of the Task Batch field';
                    ApplicationArea = NPRRetail;
                }
                field("Task Line No."; Rec."Task Line No.")
                {

                    Editable = SetEditable;
                    ToolTip = 'Specifies the value of the Task Line No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Next Run time"; Rec."Next Run time")
                {

                    Editable = SetEditable;
                    ToolTip = 'Specifies the value of the Next Run time field';
                    ApplicationArea = NPRRetail;
                }
                field("Task Worker Group"; Rec."Task Worker Group")
                {

                    ToolTip = 'Specifies the value of the Task Worker Group field';
                    ApplicationArea = NPRRetail;
                }
                field(Status; Rec.Status)
                {

                    ToolTip = 'Specifies the value of the Status field';
                    ApplicationArea = NPRRetail;
                }
                field("Assigned To User"; Rec."Assigned To User")
                {

                    DrillDown = false;
                    Lookup = false;
                    ToolTip = 'Specifies the value of the Assigned To User field';
                    ApplicationArea = NPRRetail;
                }
                field("Assigned Time"; Rec."Assigned Time")
                {

                    ToolTip = 'Specifies the value of the Assigned Time field';
                    ApplicationArea = NPRRetail;
                }
                field("Started Time"; Rec."Started Time")
                {

                    ToolTip = 'Specifies the value of the Started Time field';
                    ApplicationArea = NPRRetail;
                }
                field(Enabled; Rec.Enabled)
                {

                    ToolTip = 'Specifies the value of the Enabled field';
                    ApplicationArea = NPRRetail;
                }
                field("Estimated Duration"; Rec."Estimated Duration")
                {

                    ToolTip = 'Specifies the value of the Estimated Duration field';
                    ApplicationArea = NPRRetail;
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
        if Rec.Company <> CompanyName then
            Error(Text001);
        //+TQ1.28
    end;

    var
        [InDataSet]
        SetEditable: Boolean;
        Text001: Label 'Line cannot be modify in current company.';
}

