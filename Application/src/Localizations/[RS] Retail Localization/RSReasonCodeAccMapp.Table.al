table 6059918 "NPR RS Reason Code Acc. Mapp."
{
    Access = Internal;
    Caption = 'RS Retail Reason Code Account Mapping';
    DataClassification = CustomerContent;
    LookupPageId = "NPR RS Reason Code Acc. Mapp.";
    DrillDownPageId = "NPR RS Reason Code Acc. Mapp.";

    fields
    {
        field(1; "Reason Code"; Code[10])
        {
            Caption = 'Reason Code';
            DataClassification = CustomerContent;
            TableRelation = if ("Reason Type" = const("Reason Code")) "Reason Code"
            else
            if ("Reason Type" = const("Return Reason")) "Return Reason";
            ToolTip = 'Specifies the reason code the accounts on this line apply to.';
        }
        field(2; "Reason Type"; Enum "NPR RS Count Reason Type")
        {
            Caption = 'Reason Type';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies which list the code on this line is taken from. An item journal count carries a Reason Code, while the POS Adjust Inventory action carries a Return Reason. They are separate tables, so the same code can exist in both and each needs its own line here.';
        }
        field(10; "Surplus Account"; Code[20])
        {
            Caption = 'Surplus Account';
            DataClassification = CustomerContent;
            TableRelation = "G/L Account";
            ToolTip = 'Specifies the G/L account that an inventory surplus carrying this reason code is posted to. Leave blank to use the account set up for the location, or the one on the RS Retail Localization Setup page.';

            trigger OnValidate()
            var
                GLAccountCategory: Record "G/L Account Category";
                GLAccountCategoryMgt: Codeunit "G/L Account Category Mgt.";
            begin
                GLAccountCategoryMgt.CheckGLAccount("Surplus Account", false, false, GLAccountCategory."Account Category"::Income, GLAccountCategoryMgt.GetOtherIncomeExpense());
            end;
        }
        field(11; "Shortage Account"; Code[20])
        {
            Caption = 'Shortage Account';
            DataClassification = CustomerContent;
            TableRelation = "G/L Account";
            ToolTip = 'Specifies the G/L account that an inventory shortage carrying this reason code is posted to. Use it to book write-offs such as breakage or wastage to their own account instead of the shortage account. Leave blank to use the account set up for the location, or the one on the RS Retail Localization Setup page.';

            trigger OnValidate()
            var
                GLAccountCategory: Record "G/L Account Category";
                GLAccountCategoryMgt: Codeunit "G/L Account Category Mgt.";
            begin
                GLAccountCategoryMgt.CheckGLAccount("Shortage Account", false, false, GLAccountCategory."Account Category"::Expense, GLAccountCategoryMgt.GetOtherIncomeExpense());
            end;
        }
    }

    keys
    {
        key(PK; "Reason Type", "Reason Code")
        {
            Clustered = true;
        }
    }
}
