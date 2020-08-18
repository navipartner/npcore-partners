page 6150686 "NPRE Kitchen Station Card"
{
    // NPR5.54/ALPO/20200401 CASE 382428 Kitchen Display System (KDS) for NP Restaurant
    // NPR5.55/ALPO/20200803 CASE 382428 Kitchen Display System (KDS) for NP Restaurant (further enhancements)

    Caption = 'Restaurant Kitchen Station Card';
    PageType = Card;
    SourceTable = "NPRE Kitchen Station";

    layout
    {
        area(content)
        {
            group(General)
            {
                field("Restaurant Code";"Restaurant Code")
                {
                }
                field("Code";Code)
                {
                }
                field(Description;Description)
                {
                }
                field("Description 2";"Description 2")
                {
                }
            }
        }
        area(factboxes)
        {
            systempart(Control6014407;Notes)
            {
            }
            systempart(Control6014408;Links)
            {
                Visible = false;
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
                PromotedCategory = Process;
                PromotedIsBig = true;
                RunObject = Page "NPRE Kitchen Station Selection";
                RunPageLink = "Restaurant Code"=FIELD("Restaurant Code"),
                              "Kitchen Station"=FIELD(Code);
            }
            action(ShowKitchenRequests)
            {
                Caption = 'Kitchen Requests';
                Image = BlanketOrder;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Scope = Repeater;

                trigger OnAction()
                var
                    KitchenRequest: Record "NPRE Kitchen Request";
                    KitchenRequests: Page "NPRE Kitchen Requests";
                begin
                    Rec.ShowKitchenRequests();
                end;
            }
        }
    }
}

