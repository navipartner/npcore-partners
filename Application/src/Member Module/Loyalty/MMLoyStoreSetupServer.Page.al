page 6151160 "NPR MM Loy. Store Setup Server"
{
    Extensible = False;

    Caption = 'Loyalty Store Setup (Server)';
    PageType = List;
    UsageCategory = Administration;

    SourceTable = "NPR MM Loyalty Store Setup";
    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Setup; Rec.Setup)
                {

                    ToolTip = 'Specifies the value of the Setup field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Client Company Name"; Rec."Client Company Name")
                {

                    ToolTip = 'Specifies the value of the Client Company Name field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Store Code"; Rec."Store Code")
                {

                    ToolTip = 'Specifies the value of the Store Code field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Unit Code"; Rec."Unit Code")
                {

                    ToolTip = 'Specifies the value of the Unit Code field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field(Description; Rec.Description)
                {

                    ToolTip = 'Specifies the value of the Description field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Authorization Code"; Rec."Authorization Code")
                {

                    ToolTip = 'Specifies the value of the Authorization Code field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Accept Client Transactions"; Rec."Accept Client Transactions")
                {

                    ToolTip = 'Specifies the value of the Accept Client Transactions field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Customer No."; Rec."Customer No.")
                {

                    ToolTip = 'Specifies the value of the Customer No. field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Customer Name"; Rec."Customer Name")
                {

                    ToolTip = 'Specifies the value of the Customer Name field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Posting Model"; Rec."Posting Model")
                {

                    ToolTip = 'Specifies the value of the Posting Model field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Loyalty Setup Code"; Rec."Loyalty Setup Code")
                {

                    ToolTip = 'Specifies the value of the Loyalty Setup Code field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Burn Points Currency Code"; Rec."Burn Points Currency Code")
                {

                    ToolTip = 'Specifies the value of the Burn Points LCY Currency Code field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("G/L Account No."; Rec."G/L Account No.")
                {

                    ToolTip = 'Specifies the value of the G/L Account No. field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Invoice No. Series"; Rec."Invoice No. Series")
                {

                    ToolTip = 'Specifies the value of the Invoice No. Series field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Reconciliation Period"; Rec."Reconciliation Period")
                {

                    ToolTip = 'Specifies the value of the Reconciliation Period field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Outstanding Earn Points"; Rec."Outstanding Earn Points")
                {

                    ToolTip = 'Specifies the value of the Outstanding Earn Points field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Outstanding Burn Points"; Rec."Outstanding Burn Points")
                {

                    ToolTip = 'Specifies the value of the Outstanding Burn Points field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
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
                PromotedOnly = true;
                PromotedCategory = "Report";
                PromotedIsBig = true;
                RunObject = Page "NPR MM Loyalty Server Trx Log";
                RunPageLink = "Company Name" = FIELD("Client Company Name"),
                              "POS Store Code" = FIELD("Store Code"),
                              "POS Unit Code" = FIELD("Unit Code");

                ToolTip = 'Executes the Transaction Entries action';
                ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
            }
        }
        area(processing)
        {
            action("Reconcile All Stores")
            {
                Caption = 'Reconcile All Stores';
                Image = IssueFinanceCharge;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                ToolTip = 'Executes the Reconcile All Stores action';
                ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;

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
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                ToolTip = 'Executes the Reconcile Selected Store action';
                ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;

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

