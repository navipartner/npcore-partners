page 6151162 "NPR MM Loy. Store Setup Client"
{
    Extensible = False;

    Caption = 'Loyalty Store Setup (Client)';
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
                field(Setup; Rec.Setup)
                {

                    ToolTip = 'Specifies the value of the Setup field';
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
                field("POS Payment Method Code"; Rec."POS Payment Method Code")
                {

                    ToolTip = 'Specifies the value of the POS Payment Method Code field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Store Endpoint Code"; Rec."Store Endpoint Code")
                {

                    ToolTip = 'Specifies the value of the Store Endpoint Code field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
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

                ToolTip = 'Executes the Transaction Log action';
                ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
            }
        }
    }
}

