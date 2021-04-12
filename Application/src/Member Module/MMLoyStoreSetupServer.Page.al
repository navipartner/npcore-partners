page 6151160 "NPR MM Loy. Store Setup Server"
{

    Caption = 'Loyalty Store Setup (Server)';
    PageType = List;
    UsageCategory = Administration;
    ApplicationArea = All;
    SourceTable = "NPR MM Loyalty Store Setup";
    SourceTableView = WHERE(Setup = CONST(SERVER));

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Setup; Rec.Setup)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Setup field';
                }
                field("Client Company Name"; Rec."Client Company Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Client Company Name field';
                }
                field("Store Code"; Rec."Store Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Store Code field';
                }
                field("Unit Code"; Rec."Unit Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Unit Code field';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field';
                }
                field("Authorization Code"; Rec."Authorization Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Authorization Code field';
                }
                field("Accept Client Transactions"; Rec."Accept Client Transactions")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Accept Client Transactions field';
                }
                field("Customer No."; Rec."Customer No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Customer No. field';
                }
                field("Customer Name"; Rec."Customer Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Customer Name field';
                }
                field("Posting Model"; Rec."Posting Model")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Posting Model field';
                }
                field("Loyalty Setup Code"; Rec."Loyalty Setup Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Loyalty Setup Code field';
                }
                field("Burn Points Currency Code"; Rec."Burn Points Currency Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Burn Points LCY Currency Code field';
                }
                field("G/L Account No."; Rec."G/L Account No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the G/L Account No. field';
                }
                field("Invoice No. Series"; Rec."Invoice No. Series")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Invoice No. Series field';
                }
                field("Reconciliation Period"; Rec."Reconciliation Period")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Reconciliation Period field';
                }
                field("Outstanding Earn Points"; Rec."Outstanding Earn Points")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Outstanding Earn Points field';
                }
                field("Outstanding Burn Points"; Rec."Outstanding Burn Points")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Outstanding Burn Points field';
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
                ApplicationArea = All;
                ToolTip = 'Executes the Transaction Entries action';
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
                ApplicationArea = All;
                ToolTip = 'Executes the Reconcile All Stores action';

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
                ApplicationArea = All;
                ToolTip = 'Executes the Reconcile Selected Store action';

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

