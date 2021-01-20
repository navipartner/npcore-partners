page 6150692 "NPR NPRE Kitchen Req. Stations"
{
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
                field("Request No."; Rec."Request No.")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Request No. field';
                }
                field("Line No."; Rec."Line No.")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Line No. field';
                }
                field("Production Restaurant Code"; Rec."Production Restaurant Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Production Restaurant Code field';
                }
                field("Kitchen Station"; Rec."Kitchen Station")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Kitchen Station field';
                }
                field("Production Status"; Rec."Production Status")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Production Status field';
                }
                field("Start Date-Time"; Rec."Start Date-Time")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Start Date-Time field';
                }
                field("End Date-Time"; Rec."End Date-Time")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the End Date-Time field';
                }
            }
        }
    }
}