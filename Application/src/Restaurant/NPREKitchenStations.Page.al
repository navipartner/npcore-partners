page 6150685 "NPR NPRE Kitchen Stations"
{
    Caption = 'Restaurant Kitchen Stations';
    CardPageID = "NPR NPRE Kitchen Station Card";
    Editable = false;
    PageType = List;
    SourceTable = "NPR NPRE Kitchen Station";
    UsageCategory = Administration;
    ApplicationArea = NPRRetail;


    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Restaurant Code"; Rec."Restaurant Code")
                {

                    ToolTip = 'Specifies the value of the Restaurant Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Code"; Rec.Code)
                {

                    ToolTip = 'Specifies the value of the Code field';
                    ApplicationArea = NPRRetail;
                }
                field(Description; Rec.Description)
                {

                    ToolTip = 'Specifies the value of the Description field';
                    ApplicationArea = NPRRetail;
                }
                field("Description 2"; Rec."Description 2")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Description 2 field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
        area(factboxes)
        {
            systempart(Control6014407; Notes)
            {
                Visible = false;
                ApplicationArea = NPRRetail;

            }
            systempart(Control6014408; Links)
            {
                Visible = false;
                ApplicationArea = NPRRetail;

            }
        }
    }

    actions
    {
        area(processing)
        {
            action(KitchenStationSelection)
            {
                Caption = 'Station Selection Setup';
                Image = Troubleshoot;
                RunObject = Page "NPR NPRE Kitchen Station Slct.";
                RunPageLink = "Restaurant Code" = FIELD("Restaurant Code"),
                              "Kitchen Station" = FIELD(Code);

                ToolTip = 'Executes the Station Selection Setup action';
                ApplicationArea = NPRRetail;
            }
            action(ShowKitchenRequests)
            {
                Caption = 'Kitchen Requests';
                Image = BlanketOrder;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Scope = Repeater;

                ToolTip = 'Executes the Kitchen Requests action';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                begin
                    Rec.ShowKitchenRequests();
                end;
            }
        }
    }
}
