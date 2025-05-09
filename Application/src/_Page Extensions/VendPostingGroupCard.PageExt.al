pageextension 6014500 "NPR Vend. Posting Group Card" extends "Vendor Posting Group Card"
{
    layout
    {
        addlast(General)
        {
            group("NPR Prepayment")
            {
                Caption = 'Prepayment';

                field("NPR Prepayment Account"; RSVendorPostingGroup."Prepayment Account")
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
                            GLAccountCategoryMgt.LookupGLAccountWithoutCategory(RSVendorPostingGroup."Prepayment Account")
                        else
                            GLAccountCategoryMgt.LookupGLAccount(RSVendorPostingGroup."Prepayment Account", GLAccountCategory."Account Category"::Liabilities, GLAccountCategoryMgt.GetCurrentLiabilities());

                        RSVendorPostingGroup.Validate("Prepayment Account");
                        RSVendorPostingGroup.Save();
                    end;

                    trigger OnValidate()
                    begin
                        RSVendorPostingGroup.Validate("Prepayment Account");
                        RSVendorPostingGroup.Save();
                    end;
                }
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    begin
        RSVendorPostingGroup.Read(Rec.SystemId);
    end;

    var
        RSVendorPostingGroup: Record "NPR RS Vendor Posting Group";
}