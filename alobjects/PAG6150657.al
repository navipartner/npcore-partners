page 6150657 "POS Posting Setup"
{
    // NPR5.36/BR  /20170810  CASE  277096 Object created

    Caption = 'POS Posting Setup';
    PageType = List;
    SourceTable = "POS Posting Setup";
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("POS Store Code";"POS Store Code")
                {
                }
                field("POS Payment Method Code";"POS Payment Method Code")
                {
                }
                field("POS Payment Bin Code";"POS Payment Bin Code")
                {
                }
                field("Account Type";"Account Type")
                {
                }
                field("Account No.";"Account No.")
                {
                }
                field("Difference Account Type";"Difference Account Type")
                {
                }
                field("Close to POS Bin No.";"Close to POS Bin No.")
                {
                }
                field("Difference Acc. No.";"Difference Acc. No.")
                {
                }
                field("Difference Acc. No. (Neg)";"Difference Acc. No. (Neg)")
                {
                }
            }
        }
    }

    actions
    {
    }
}

