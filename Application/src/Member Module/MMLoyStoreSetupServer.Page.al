page 6151160 "NPR MM Loy. Store Setup Server"
{

    Caption = 'Loyalty Store Setup (Server)';
    PageType = List;
    UsageCategory = Administration;

    SourceTable = "NPR MM Loyalty Store Setup";
    SourceTableView = WHERE(Setup = CONST(SERVER));
    ApplicationArea = NPRRetail;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Setup; Rec.Setup)
                {

                    ToolTip = 'Specifies the value of the Setup field';
                    ApplicationArea = NPRRetail;
                }
                field("Client Company Name"; Rec."Client Company Name")
                {

                    ToolTip = 'Specifies the value of the Client Company Name field';
                    ApplicationArea = NPRRetail;
                }
                field("Store Code"; Rec."Store Code")
                {

                    ToolTip = 'Specifies the value of the Store Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Unit Code"; Rec."Unit Code")
                {

                    ToolTip = 'Specifies the value of the Unit Code field';
                    ApplicationArea = NPRRetail;
                }
                field(Description; Rec.Description)
                {

                    ToolTip = 'Specifies the value of the Description field';
                    ApplicationArea = NPRRetail;
                }
                field("Authorization Code"; Rec."Authorization Code")
                {

                    ToolTip = 'Specifies the value of the Authorization Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Accept Client Transactions"; Rec."Accept Client Transactions")
                {

                    ToolTip = 'Specifies the value of the Accept Client Transactions field';
                    ApplicationArea = NPRRetail;
                }
                field("Customer No."; Rec."Customer No.")
                {

                    ToolTip = 'Specifies the value of the Customer No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Customer Name"; Rec."Customer Name")
                {

                    ToolTip = 'Specifies the value of the Customer Name field';
                    ApplicationArea = NPRRetail;
                }
                field("Posting Model"; Rec."Posting Model")
                {

                    ToolTip = 'Specifies the value of the Posting Model field';
                    ApplicationArea = NPRRetail;
                }
                field("Loyalty Setup Code"; Rec."Loyalty Setup Code")
                {

                    ToolTip = 'Specifies the value of the Loyalty Setup Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Burn Points Currency Code"; Rec."Burn Points Currency Code")
                {

                    ToolTip = 'Specifies the value of the Burn Points LCY Currency Code field';
                    ApplicationArea = NPRRetail;
                }
                field("G/L Account No."; Rec."G/L Account No.")
                {

                    ToolTip = 'Specifies the value of the G/L Account No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Invoice No. Series"; Rec."Invoice No. Series")
                {

                    ToolTip = 'Specifies the value of the Invoice No. Series field';
                    ApplicationArea = NPRRetail;
                }
                field("Reconciliation Period"; Rec."Reconciliation Period")
                {

                    ToolTip = 'Specifies the value of the Reconciliation Period field';
                    ApplicationArea = NPRRetail;
                }
                field("Outstanding Earn Points"; Rec."Outstanding Earn Points")
                {

                    ToolTip = 'Specifies the value of the Outstanding Earn Points field';
                    ApplicationArea = NPRRetail;
                }
                field("Outstanding Burn Points"; Rec."Outstanding Burn Points")
                {

                    ToolTip = 'Specifies the value of the Outstanding Burn Points field';
                    ApplicationArea = NPRRetail;
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
                ApplicationArea = NPRRetail;
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
                ApplicationArea = NPRRetail;

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
                ApplicationArea = NPRRetail;

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

