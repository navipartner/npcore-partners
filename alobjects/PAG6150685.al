page 6150685 "NPRE Kitchen Stations"
{
    // NPR5.54/ALPO/20200401 CASE 382428 Kitchen Display System (KDS) for NP Restaurant
    // NPR5.55/ALPO/20200803 CASE 382428 Kitchen Display System (KDS) for NP Restaurant (further enhancements)

    Caption = 'Restaurant Kitchen Stations';
    CardPageID = "NPRE Kitchen Station Card";
    Editable = false;
    PageType = List;
    SourceTable = "NPRE Kitchen Station";
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Restaurant Code"; "Restaurant Code")
                {
                    ApplicationArea = All;
                }
                field("Code"; Code)
                {
                    ApplicationArea = All;
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                }
                field("Description 2"; "Description 2")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
            }
        }
        area(factboxes)
        {
            systempart(Control6014407; Notes)
            {
                Visible = false;
            }
            systempart(Control6014408; Links)
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
                RunObject = Page "NPRE Kitchen Station Selection";
                RunPageLink = "Restaurant Code" = FIELD("Restaurant Code"),
                              "Kitchen Station" = FIELD(Code);
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

