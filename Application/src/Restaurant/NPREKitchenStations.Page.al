page 6150685 "NPR NPRE Kitchen Stations"
{
    // NPR5.54/ALPO/20200401 CASE 382428 Kitchen Display System (KDS) for NP Restaurant
    // NPR5.55/ALPO/20200803 CASE 382428 Kitchen Display System (KDS) for NP Restaurant (further enhancements)

    Caption = 'Restaurant Kitchen Stations';
    CardPageID = "NPR NPRE Kitchen Station Card";
    Editable = false;
    PageType = List;
    SourceTable = "NPR NPRE Kitchen Station";
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
                    ToolTip = 'Specifies the value of the Restaurant Code field';
                }
                field("Code"; Code)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Code field';
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field';
                }
                field("Description 2"; "Description 2")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Description 2 field';
                }
            }
        }
        area(factboxes)
        {
            systempart(Control6014407; Notes)
            {
                Visible = false;
                ApplicationArea = All;
            }
            systempart(Control6014408; Links)
            {
                Visible = false;
                ApplicationArea = All;
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
                ApplicationArea = All;
                ToolTip = 'Executes the Station Selection Setup action';
            }
            action(ShowKitchenRequests)
            {
                Caption = 'Kitchen Requests';
                Image = BlanketOrder;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Scope = Repeater;
                ApplicationArea = All;
                ToolTip = 'Executes the Kitchen Requests action';

                trigger OnAction()
                var
                    KitchenRequest: Record "NPR NPRE Kitchen Request";
                    KitchenRequests: Page "NPR NPRE Kitchen Req.";
                begin
                    Rec.ShowKitchenRequests();
                end;
            }
        }
    }
}

