page 6151160 "NPR MM Loy. Store Setup Server"
{
    // MM1.38/TSA /20190524 CASE 338215 Initial Version

    Caption = 'Loyalty Store Setup (Server)';
    PageType = List;
    SourceTable = "NPR MM Loyalty Store Setup";
    SourceTableView = WHERE(Setup = CONST(SERVER));

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Setup; Setup)
                {
                    ApplicationArea = All;
                }
                field("Client Company Name"; "Client Company Name")
                {
                    ApplicationArea = All;
                }
                field("Store Code"; "Store Code")
                {
                    ApplicationArea = All;
                }
                field("Unit Code"; "Unit Code")
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
                field("Customer No."; "Customer No.")
                {
                    ApplicationArea = All;
                }
                field("Customer Name"; "Customer Name")
                {
                    ApplicationArea = All;
                }
                field("Posting Model"; "Posting Model")
                {
                    ApplicationArea = All;
                }
                field("Loyalty Setup Code"; "Loyalty Setup Code")
                {
                    ApplicationArea = All;
                }
                field("Burn Points Currency Code"; "Burn Points Currency Code")
                {
                    ApplicationArea = All;
                }
                field("G/L Account No."; "G/L Account No.")
                {
                    ApplicationArea = All;
                }
                field("Invoice No. Series"; "Invoice No. Series")
                {
                    ApplicationArea = All;
                }
                field("Reconciliation Period"; "Reconciliation Period")
                {
                    ApplicationArea = All;
                }
                field("Outstanding Earn Points"; "Outstanding Earn Points")
                {
                    ApplicationArea = All;
                }
                field("Outstanding Burn Points"; "Outstanding Burn Points")
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
            action("Transaction Entries")
            {
                Caption = 'Transaction Entries';
                Image = EntriesList;
                Promoted = true;
                PromotedCategory = "Report";
                PromotedIsBig = true;
                RunObject = Page "NPR MM Loyalty Server Trx Log";
                RunPageLink = "Company Name" = FIELD("Client Company Name"),
                              "POS Store Code" = FIELD("Store Code"),
                              "POS Unit Code" = FIELD("Unit Code");
                ApplicationArea=All;
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
                ApplicationArea=All;

                trigger OnAction()
                var
                    LoyaltyPointsMgrServer: Codeunit "NPR MM Loy. Point Mgr (Server)";
                begin

                    LoyaltyPointsMgrServer.InvoiceAllStorePoints();
                end;
            }
            action("Reconcile Selected Store")
            {
                Caption = 'Reconcile Selected Store';
                Image = IssueFinanceCharge;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ApplicationArea=All;

                trigger OnAction()
                var
                    LoyaltyPointsMgrServer: Codeunit "NPR MM Loy. Point Mgr (Server)";
                begin

                    LoyaltyPointsMgrServer.InvoiceOneStorePoints(Rec);
                end;
            }
        }
    }
}

