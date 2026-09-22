table 6060007 "NPR RS R Localization Setup"
{
    DataClassification = CustomerContent;
    Access = Internal;
    Caption = 'RS Retail Localization Setup';
    DrillDownPageId = "NPR RS R Localization Setup";
    LookupPageId = "NPR RS R Localization Setup";

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            Caption = 'Primary Key';
            DataClassification = CustomerContent;
        }
        field(2; "Enable RS Retail Localization"; Boolean)
        {
            Caption = 'Enable RS Retail Localization';
            DataClassification = CustomerContent;
        }
        field(3; "RS Calc. VAT GL Account"; Code[20])
        {
            Caption = 'Calc. VAT GL Account';
            DataClassification = CustomerContent;
            TableRelation = "G/L Account";
        }
        field(4; "RS Calc. Margin GL Account"; Code[20])
        {
            Caption = 'Calc. Margin GL Account';
            DataClassification = CustomerContent;
            TableRelation = "G/L Account";
        }
        field(5; "RS Nivelation Hdr No. Series"; Code[20])
        {
            Caption = 'Nivelation No. Series';
            DataClassification = CustomerContent;
            TableRelation = "No. Series";
        }
        field(6; "RS Posted Niv. No. Series"; Code[20])
        {
            Caption = 'Posted Nivelation No. Series';
            DataClassification = CustomerContent;
            TableRelation = "No. Series";
        }
        field(7; "RS Ret. Purch. Report Ord."; Code[20])
        {
            Caption = 'Retail Purchase Price Report Order';
            DataClassification = CustomerContent;
            TableRelation = "No. Series";
        }
        field(8; "RS Ret. Transfer Report Ord."; Code[20])
        {
            Caption = 'Retail Transfer Receipt Report Order';
            DataClassification = CustomerContent;
            TableRelation = "No. Series";
        }
        field(9; "RS Ret. Localization Country"; Enum "NPR RS R Localization Country")
        {
            Caption = 'RS Ret. Localization Country';
            DataClassification = CustomerContent;
        }
        field(10; "RS Surplus GL Account"; Code[20])
        {
            Caption = 'Surplus GL Account';
            DataClassification = CustomerContent;
            TableRelation = "G/L Account";
            ToolTip = 'Specifies the G/L account that a counted inventory surplus is posted to. Can be overridden per location and inventory posting group on the Inventory Posting Setup page.';

            trigger OnValidate()
            var
                GLAccountCategory: Record "G/L Account Category";
                GLAccountCategoryMgt: Codeunit "G/L Account Category Mgt.";
            begin
                GLAccountCategoryMgt.CheckGLAccount("RS Surplus GL Account", false, false, GLAccountCategory."Account Category"::Income, GLAccountCategoryMgt.GetOtherIncomeExpense());
            end;
        }
        field(11; "RS Shortage GL Account"; Code[20])
        {
            Caption = 'Shortage GL Account';
            DataClassification = CustomerContent;
            TableRelation = "G/L Account";
            ToolTip = 'Specifies the G/L account that a counted inventory shortage is posted to. Can be overridden per location and inventory posting group on the Inventory Posting Setup page.';

            trigger OnValidate()
            var
                GLAccountCategory: Record "G/L Account Category";
                GLAccountCategoryMgt: Codeunit "G/L Account Category Mgt.";
            begin
                GLAccountCategoryMgt.CheckGLAccount("RS Shortage GL Account", false, false, GLAccountCategory."Account Category"::Expense, GLAccountCategoryMgt.GetOtherIncomeExpense());
            end;
        }
    }

    keys
    {
        key(PK; "Primary Key")
        {
            Clustered = true;
        }
    }
}