tableextension 6150613 "NPR RS Inventory Posting Setup" extends "Inventory Posting Setup"
{
    fields
    {
        field(6150613; "NPR RS Calc. VAT Account"; Code[20])
        {
            Caption = 'RS Calc. VAT Account';
            DataClassification = CustomerContent;
            TableRelation = "G/L Account";
            ToolTip = 'Specifies the Calculated VAT (ukalkulisani PDV) account for this location and inventory posting group. Leave blank to use the account on the RS Retail Localization Setup page.';

            trigger OnValidate()
            var
                GLAccountCategory: Record "G/L Account Category";
                GLAccountCategoryMgt: Codeunit "G/L Account Category Mgt.";
            begin
                if "View All Accounts on Lookup" then
                    GLAccountCategoryMgt.CheckGLAccountWithoutCategory("NPR RS Calc. VAT Account", false, false)
                else
                    GLAccountCategoryMgt.CheckGLAccount("NPR RS Calc. VAT Account", false, false, GLAccountCategory."Account Category"::Assets, GLAccountCategoryMgt.GetInventory());
            end;
        }
        field(6150614; "NPR RS Calc. Margin Account"; Code[20])
        {
            Caption = 'RS Calc. Margin Account';
            DataClassification = CustomerContent;
            TableRelation = "G/L Account";
            ToolTip = 'Specifies the Calculated Margin (ukalkulisana razlika u ceni) account for this location and inventory posting group. Leave blank to use the account on the RS Retail Localization Setup page.';

            trigger OnValidate()
            var
                GLAccountCategory: Record "G/L Account Category";
                GLAccountCategoryMgt: Codeunit "G/L Account Category Mgt.";
            begin
                if "View All Accounts on Lookup" then
                    GLAccountCategoryMgt.CheckGLAccountWithoutCategory("NPR RS Calc. Margin Account", false, false)
                else
                    GLAccountCategoryMgt.CheckGLAccount("NPR RS Calc. Margin Account", false, false, GLAccountCategory."Account Category"::Assets, GLAccountCategoryMgt.GetInventory());
            end;
        }
        field(6014400; "NPR RS Surplus Account"; Code[20])
        {
            Caption = 'RS Surplus Account';
            DataClassification = CustomerContent;
            TableRelation = "G/L Account";
            ToolTip = 'Specifies the G/L account that a counted inventory surplus is posted to for this location and inventory posting group. Leave blank to use the account on the RS Retail Localization Setup page.';

            trigger OnValidate()
            var
                GLAccountCategory: Record "G/L Account Category";
                GLAccountCategoryMgt: Codeunit "G/L Account Category Mgt.";
            begin
                if "View All Accounts on Lookup" then
                    GLAccountCategoryMgt.CheckGLAccountWithoutCategory("NPR RS Surplus Account", false, false)
                else
                    GLAccountCategoryMgt.CheckGLAccount("NPR RS Surplus Account", false, false, GLAccountCategory."Account Category"::Income, GLAccountCategoryMgt.GetOtherIncomeExpense());
            end;
        }
        field(6014401; "NPR RS Shortage Account"; Code[20])
        {
            Caption = 'RS Shortage Account';
            DataClassification = CustomerContent;
            TableRelation = "G/L Account";
            ToolTip = 'Specifies the G/L account that a counted inventory shortage is posted to for this location and inventory posting group. Leave blank to use the account on the RS Retail Localization Setup page.';

            trigger OnValidate()
            var
                GLAccountCategory: Record "G/L Account Category";
                GLAccountCategoryMgt: Codeunit "G/L Account Category Mgt.";
            begin
                if "View All Accounts on Lookup" then
                    GLAccountCategoryMgt.CheckGLAccountWithoutCategory("NPR RS Shortage Account", false, false)
                else
                    GLAccountCategoryMgt.CheckGLAccount("NPR RS Shortage Account", false, false, GLAccountCategory."Account Category"::Expense, GLAccountCategoryMgt.GetOtherIncomeExpense());
            end;
        }
    }
}
