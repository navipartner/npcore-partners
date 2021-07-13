page 6150686 "NPR NPRE Kitchen Station Card"
{
    Caption = 'Restaurant Kitchen Station Card';
    PageType = Card;
    SourceTable = "NPR NPRE Kitchen Station";
    UsageCategory = None;

    layout
    {
        area(content)
        {
            group(General)
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

                    ToolTip = 'Specifies the value of the Description 2 field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
        area(factboxes)
        {
            systempart(Control6014407; Notes)
            {
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
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
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
