query 6014445 "NPR GL Revenue"
{
    Access = Internal;
    Caption = 'G/L Revenue';
    QueryType = Normal;
    OrderBy = ascending(PostingDate);

    elements
    {
        dataitem(GLEntry; "G/L Entry")
        {
            DataItemTableFilter = "Gen. Posting Type" = const(Sale), "Business Unit Code" = filter('');

            filter(EntryNo; "Entry No.")
            {
            }
            filter(SourceCode; "Source Code")
            {
            }
            column(PostingDate; "Posting Date")
            {
            }
            column(Amount; Amount)
            {
                Method = Sum;
            }
            dataitem(GLAccount; "G/L Account")
            {
                DataItemLink = "No." = GLEntry."G/L Account No.";
                DataItemTableFilter = "Income/Balance" = const("Income Statement");
                SqlJoinType = InnerJoin;
            }
        }
    }
}
