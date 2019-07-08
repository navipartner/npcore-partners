page 6151105 "NpRi Parties"
{
    // NPR5.44/MHA /20180723  CASE 320133 Object Created - NaviPartner Reimbursement

    Caption = 'Reimbursement Parties';
    DelayedInsert = true;
    PageType = List;
    SourceTable = "NpRi Party";
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Party Type";"Party Type")
                {
                }
                field("No.";"No.")
                {
                }
                field(Name;Name)
                {
                }
                field("Reimburse every";"Reimburse every")
                {
                }
                field("Next Posting Date Calculation";"Next Posting Date Calculation")
                {
                }
            }
        }
    }

    actions
    {
        area(navigation)
        {
            action(Reimbursements)
            {
                Caption = 'Reimbursements';
                Image = List;
                RunObject = Page "NpRi Reimbursements";
                RunPageLink = "Party Type"=FIELD("Party Type"),
                              "Party No."=FIELD("No.");
            }
        }
    }
}

