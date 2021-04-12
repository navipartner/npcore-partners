page 6151162 "NPR MM Loy. Store Setup Client"
{

    Caption = 'Loyalty Store Setup (Server)';
    PageType = List;
    UsageCategory = Administration;
    ApplicationArea = All;
    SourceTable = "NPR MM Loyalty Store Setup";
    SourceTableView = WHERE(Setup = CONST(CLIENT));

    layout
    {
        area(content)
        {
            repeater(Group)
            {
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
                field(Setup; Rec.Setup)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Setup field';
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
                field("POS Payment Method Code"; Rec."POS Payment Method Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the POS Payment Method Code field';
                }
                field("Store Endpoint Code"; Rec."Store Endpoint Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Store Endpoint Code field';
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
                ToolTip = 'Executes the Transaction Log action';
            }
        }
    }
}

