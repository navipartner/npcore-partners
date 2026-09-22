pageextension 6014473 "NPR RS Invt. Posting Setup" extends "Inventory Posting Setup"
{
    layout
    {
        addlast(Control1)
        {
            field("NPR RS Calc. VAT Account"; Rec."NPR RS Calc. VAT Account")
            {
                ApplicationArea = NPRRSRLocal;

                trigger OnLookup(var Text: Text): Boolean
                var
                    GLAccountCategory: Record "G/L Account Category";
                    GLAccountCategoryMgt: Codeunit "G/L Account Category Mgt.";
                    AccountNo: Code[20];
                begin
                    AccountNo := Rec."NPR RS Calc. VAT Account";
                    if Rec."View All Accounts on Lookup" then
                        GLAccountCategoryMgt.LookupGLAccountWithoutCategory(AccountNo)
                    else
                        GLAccountCategoryMgt.LookupGLAccount(AccountNo, GLAccountCategory."Account Category"::Assets, GLAccountCategoryMgt.GetInventory());
                    Text := AccountNo;
                    exit(true);
                end;
            }
            field("NPR RS Calc. Margin Account"; Rec."NPR RS Calc. Margin Account")
            {
                ApplicationArea = NPRRSRLocal;

                trigger OnLookup(var Text: Text): Boolean
                var
                    GLAccountCategory: Record "G/L Account Category";
                    GLAccountCategoryMgt: Codeunit "G/L Account Category Mgt.";
                    AccountNo: Code[20];
                begin
                    AccountNo := Rec."NPR RS Calc. Margin Account";
                    if Rec."View All Accounts on Lookup" then
                        GLAccountCategoryMgt.LookupGLAccountWithoutCategory(AccountNo)
                    else
                        GLAccountCategoryMgt.LookupGLAccount(AccountNo, GLAccountCategory."Account Category"::Assets, GLAccountCategoryMgt.GetInventory());
                    Text := AccountNo;
                    exit(true);
                end;
            }
            field("NPR RS Surplus Account"; Rec."NPR RS Surplus Account")
            {
                ApplicationArea = NPRRSRLocal;

                trigger OnLookup(var Text: Text): Boolean
                var
                    GLAccountCategory: Record "G/L Account Category";
                    GLAccountCategoryMgt: Codeunit "G/L Account Category Mgt.";
                    AccountNo: Code[20];
                begin
                    AccountNo := Rec."NPR RS Surplus Account";
                    if Rec."View All Accounts on Lookup" then
                        GLAccountCategoryMgt.LookupGLAccountWithoutCategory(AccountNo)
                    else
                        GLAccountCategoryMgt.LookupGLAccount(AccountNo, GLAccountCategory."Account Category"::Income, GLAccountCategoryMgt.GetOtherIncomeExpense());
                    Text := AccountNo;
                    exit(true);
                end;
            }
            field("NPR RS Shortage Account"; Rec."NPR RS Shortage Account")
            {
                ApplicationArea = NPRRSRLocal;

                trigger OnLookup(var Text: Text): Boolean
                var
                    GLAccountCategory: Record "G/L Account Category";
                    GLAccountCategoryMgt: Codeunit "G/L Account Category Mgt.";
                    AccountNo: Code[20];
                begin
                    AccountNo := Rec."NPR RS Shortage Account";
                    if Rec."View All Accounts on Lookup" then
                        GLAccountCategoryMgt.LookupGLAccountWithoutCategory(AccountNo)
                    else
                        GLAccountCategoryMgt.LookupGLAccount(AccountNo, GLAccountCategory."Account Category"::Expense, GLAccountCategoryMgt.GetOtherIncomeExpense());
                    Text := AccountNo;
                    exit(true);
                end;
            }
        }
    }
}
