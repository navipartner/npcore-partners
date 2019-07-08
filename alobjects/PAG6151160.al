page 6151160 "MM Loyalty Store Setup Server"
{
    // MM1.38/TSA /20190524 CASE 338215 Initial Version

    Caption = 'Loyalty Store Setup (Server)';
    PageType = List;
    SourceTable = "MM Loyalty Store Setup";
    SourceTableView = WHERE(Setup=CONST(SERVER));

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Setup;Setup)
                {
                }
                field("Client Company Name";"Client Company Name")
                {
                }
                field("Store Code";"Store Code")
                {
                }
                field("Unit Code";"Unit Code")
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
                field("Customer No.";"Customer No.")
                {
                }
                field("Customer Name";"Customer Name")
                {
                }
                field("Posting Model";"Posting Model")
                {
                }
                field("Loyalty Setup Code";"Loyalty Setup Code")
                {
                }
                field("Burn Points Currency Code";"Burn Points Currency Code")
                {
                }
                field("G/L Account No.";"G/L Account No.")
                {
                }
                field("Invoice No. Series";"Invoice No. Series")
                {
                }
                field("Reconciliation Period";"Reconciliation Period")
                {
                }
                field("Outstanding Earn Points";"Outstanding Earn Points")
                {
                }
                field("Outstanding Burn Points";"Outstanding Burn Points")
                {
                }
            }
        }
    }

    actions
    {
        area(navigation)
        {
            action("Transaction Entries")
            {
                Caption = 'Transaction Entries';
                Image = EntriesList;
                Promoted = true;
                PromotedCategory = "Report";
                PromotedIsBig = true;
                RunObject = Page "MM Loyalty Server Trans. Log";
                RunPageLink = "Company Name"=FIELD("Client Company Name"),
                              "POS Store Code"=FIELD("Store Code"),
                              "POS Unit Code"=FIELD("Unit Code");
            }
        }
        area(processing)
        {
            action("Reconcile All Stores")
            {
                Caption = 'Reconcile All Stores';
                Image = IssueFinanceCharge;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                var
                    LoyaltyPointsMgrServer: Codeunit "MM Loyalty Points Mgr (Server)";
                begin

                    LoyaltyPointsMgrServer.InvoiceAllStorePoints ();
                end;
            }
            action("Reconcile Selected Store")
            {
                Caption = 'Reconcile Selected Store';
                Image = IssueFinanceCharge;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                var
                    LoyaltyPointsMgrServer: Codeunit "MM Loyalty Points Mgr (Server)";
                begin

                    LoyaltyPointsMgrServer.InvoiceOneStorePoints (Rec);
                end;
            }
        }
    }
}

