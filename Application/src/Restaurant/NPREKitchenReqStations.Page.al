page 6150692 "NPR NPRE Kitchen Req. Stations"
{
    Caption = 'Kitchen Request Stations';
    Editable = false;
    PageType = List;
    UsageCategory = Administration;

    SourceTable = "NPR NPRE Kitchen Req. Station";
    ApplicationArea = NPRRetail;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Request No."; Rec."Request No.")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Request No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Line No."; Rec."Line No.")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Line No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Production Restaurant Code"; Rec."Production Restaurant Code")
                {

                    ToolTip = 'Specifies the value of the Production Restaurant Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Kitchen Station"; Rec."Kitchen Station")
                {

                    ToolTip = 'Specifies the value of the Kitchen Station field';
                    ApplicationArea = NPRRetail;
                }
                field("Production Status"; Rec."Production Status")
                {

                    ToolTip = 'Specifies the value of the Production Status field';
                    ApplicationArea = NPRRetail;
                }
                field("Start Date-Time"; Rec."Start Date-Time")
                {

                    ToolTip = 'Specifies the value of the Start Date-Time field';
                    ApplicationArea = NPRRetail;
                }
                field("End Date-Time"; Rec."End Date-Time")
                {

                    ToolTip = 'Specifies the value of the End Date-Time field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }
}