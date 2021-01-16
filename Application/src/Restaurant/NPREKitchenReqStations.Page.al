page 6150692 "NPR NPRE Kitchen Req. Stations"
{
    // NPR5.54/ALPO/20200401 CASE 382428 Kitchen Display System (KDS) for NP Restaurant

    Caption = 'Kitchen Request Stations';
    Editable = false;
    PageType = List;
    UsageCategory = Administration;
    ApplicationArea = All;
    SourceTable = "NPR NPRE Kitchen Req. Station";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Request No."; "Request No.")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Request No. field';
                }
                field("Line No."; "Line No.")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Line No. field';
                }
                field("Production Restaurant Code"; "Production Restaurant Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Production Restaurant Code field';
                }
                field("Kitchen Station"; "Kitchen Station")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Kitchen Station field';
                }
                field("Production Status"; "Production Status")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Production Status field';
                }
                field("Start Date-Time"; "Start Date-Time")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Start Date-Time field';
                }
                field("End Date-Time"; "End Date-Time")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the End Date-Time field';
                }
            }
        }
    }

    actions
    {
    }
}

