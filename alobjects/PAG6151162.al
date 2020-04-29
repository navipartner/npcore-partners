page 6151162 "MM Loyalty Store Setup Client"
{
    // MM1.38/TSA /20190221 CASE 338215 Initial Version

    Caption = 'Loyalty Store Setup (Server)';
    PageType = List;
    SourceTable = "MM Loyalty Store Setup";
    SourceTableView = WHERE(Setup=CONST(CLIENT));

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Store Code";"Store Code")
                {
                }
                field("Unit Code";"Unit Code")
                {
                }
                field(Setup;Setup)
                {
                }
                field(Description;Description)
                {
                }
                field("Authorization Code";"Authorization Code")
                {
                }
                field("Accept Client Transactions";"Accept Client Transactions")
                {
                }
                field("POS Payment Method Code";"POS Payment Method Code")
                {
                }
                field("Store Endpoint Code";"Store Endpoint Code")
                {
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
                RunObject = Page "MM Loyalty Server Trans. Log";
                RunPageLink = "POS Store Code"=FIELD("Store Code");
            }
        }
    }
}

