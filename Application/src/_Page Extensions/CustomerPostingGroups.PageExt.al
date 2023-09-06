pageextension 6014474 "NPR Customer Posting Groups" extends "Customer Posting Groups"
{
    layout
    {
        addlast(Control1)
        {
            field("NPR Prepayment Account"; RSCustomerPostingGroup."Prepayment Account")
            {
                Caption = 'Prepayment Account';
                ApplicationArea = NPRRSLocal;
                ToolTip = 'Specifies the value of the Prepayment Account field.';
                
                trigger OnDrillDown()
                var
                    GLAccountCategory: Record "G/L Account Category";
                    GLAccountCategoryMgt: Codeunit "G/L Account Category Mgt.";
                begin
                    if Rec."View All Accounts on Lookup" then
                        GLAccountCategoryMgt.LookupGLAccountWithoutCategory(RSCustomerPostingGroup."Prepayment Account")
                    else
                        GLAccountCategoryMgt.LookupGLAccount(RSCustomerPostingGroup."Prepayment Account", GLAccountCategory."Account Category"::Assets, GLAccountCategoryMgt.GetAR());

                    RSCustomerPostingGroup.Validate("Prepayment Account");
                    RSCustomerPostingGroup.Save();
                end;

                trigger OnValidate()
                begin
                    RSCustomerPostingGroup.Validate("Prepayment Account");
                    RSCustomerPostingGroup.Save();
                end;
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    begin
        RSCustomerPostingGroup.Read(Rec.SystemId);
    end;

    var
        RSCustomerPostingGroup: Record "NPR RS Customer Posting Group";
}