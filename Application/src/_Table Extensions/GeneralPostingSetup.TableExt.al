tableextension 6014516 "NPR General Posting Setup" extends "General Posting Setup"
{
    fields
    {
        field(6060100; NPR_AchievedRevenueTicketAcc; Code[20])
        {
            Caption = 'Achieved Revenue (Ticketing) Account';
            DataClassification = CustomerContent;
            TableRelation = "G/L Account";
            trigger OnLookup()
            begin
                if ("View All Accounts on Lookup") then begin
                    GLAccountCategoryMgt.LookupGLAccountWithoutCategory(Rec.NPR_AchievedRevenueTicketAcc);
                end else begin
                    GLAccountCategoryMgt.LookupGLAccount(
                      Rec.NPR_AchievedRevenueTicketAcc, GLAccountCategory."Account Category"::Income,
                      StrSubstNo('%1|%2', GLAccountCategoryMgt.GetIncomeProdSales(), GLAccountCategoryMgt.GetIncomeService()));
                end;
            end;

            trigger OnValidate()
            begin
                Rec.CheckGLAcc(Rec.NPR_AchievedRevenueTicketAcc);
            end;
        }
    }

    var
        GLAccountCategoryMgt: Codeunit "G/L Account Category Mgt.";
        GLAccountCategory: Record "G/L Account Category";
}