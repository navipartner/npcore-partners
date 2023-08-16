page 6150692 "NPR NPRE Kitchen Req. Stations"
{
    Extensible = False;
    Caption = 'Kitchen Request Stations';
    Editable = false;
    PageType = List;
    UsageCategory = None;
    SourceTable = "NPR NPRE Kitchen Req. Station";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Request No."; Rec."Request No.")
                {
                    Visible = false;
                    ToolTip = 'Specifies the request Id this kitchen station is assigned to.';
                    ApplicationArea = NPRRetail;
                }
                field("Line No."; Rec."Line No.")
                {
                    Visible = false;
                    ToolTip = 'Specifies the line number to identify this kitchen station request.';
                    ApplicationArea = NPRRetail;
                }
                field("Production Restaurant Code"; Rec."Production Restaurant Code")
                {
                    ToolTip = 'Specifies the restaurant this request is handled by.';
                    ApplicationArea = NPRRetail;
                }
                field("Kitchen Station"; Rec."Kitchen Station")
                {
                    ToolTip = 'Specifies the kitchen station this request is handled by.';
                    ApplicationArea = NPRRetail;
                }
                field("Production Status"; Rec."Production Status")
                {
                    ToolTip = 'Specifies the production status of this kitchen station request.';
                    ApplicationArea = NPRRetail;
                }
                field("Start Date-Time"; Rec."Start Date-Time")
                {
                    ToolTip = 'Specifies the date-time production of this request started at the kitchen station.';
                    ApplicationArea = NPRRetail;
                }
                field("End Date-Time"; Rec."End Date-Time")
                {
                    ToolTip = 'Specifies the date-time production of this request ended at the kitchen station.';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }
}
