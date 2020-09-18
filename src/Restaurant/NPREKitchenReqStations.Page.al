page 6150692 "NPR NPRE Kitchen Req. Stations"
{
    // NPR5.54/ALPO/20200401 CASE 382428 Kitchen Display System (KDS) for NP Restaurant

    Caption = 'Kitchen Request Stations';
    Editable = false;
    PageType = List;
    UsageCategory = Administration;
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
                }
                field("Line No."; "Line No.")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Production Restaurant Code"; "Production Restaurant Code")
                {
                    ApplicationArea = All;
                }
                field("Kitchen Station"; "Kitchen Station")
                {
                    ApplicationArea = All;
                }
                field("Production Status"; "Production Status")
                {
                    ApplicationArea = All;
                }
                field("Start Date-Time"; "Start Date-Time")
                {
                    ApplicationArea = All;
                }
                field("End Date-Time"; "End Date-Time")
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

