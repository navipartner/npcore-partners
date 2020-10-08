page 6151162 "NPR MM Loy. Store Setup Client"
{

    Caption = 'Loyalty Store Setup (Server)';
    PageType = List;
    UsageCategory = Administration;
    SourceTable = "NPR MM Loyalty Store Setup";
    SourceTableView = WHERE(Setup = CONST(CLIENT));

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Store Code"; "Store Code")
                {
                    ApplicationArea = All;
                }
                field("Unit Code"; "Unit Code")
                {
                    ApplicationArea = All;
                }
                field(Setup; Setup)
                {
                    ApplicationArea = All;
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                }
                field("Authorization Code"; "Authorization Code")
                {
                    ApplicationArea = All;
                }
                field("Accept Client Transactions"; "Accept Client Transactions")
                {
                    ApplicationArea = All;
                }
                field("POS Payment Method Code"; "POS Payment Method Code")
                {
                    ApplicationArea = All;
                }
                field("Store Endpoint Code"; "Store Endpoint Code")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
        area(navigation)
        {
            action("Transaction Log")
            {
                Caption = 'Transaction Log';
                Image = Log;
                //The property 'PromotedCategory' can only be set if the property 'Promoted' is set to 'true'
                //PromotedCategory = "Report";
                //The property 'PromotedIsBig' can only be set if the property 'Promoted' is set to 'true'
                //PromotedIsBig = true;
                RunObject = Page "NPR MM Loyalty Server Trx Log";
                RunPageLink = "POS Store Code" = FIELD("Store Code");
                ApplicationArea = All;
            }
        }
    }
}

