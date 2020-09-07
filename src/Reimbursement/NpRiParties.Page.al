page 6151105 "NPR NpRi Parties"
{
    // NPR5.44/MHA /20180723  CASE 320133 Object Created - NaviPartner Reimbursement

    Caption = 'Reimbursement Parties';
    DelayedInsert = true;
    PageType = List;
    SourceTable = "NPR NpRi Party";
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Party Type"; "Party Type")
                {
                    ApplicationArea = All;
                }
                field("No."; "No.")
                {
                    ApplicationArea = All;
                }
                field(Name; Name)
                {
                    ApplicationArea = All;
                }
                field("Reimburse every"; "Reimburse every")
                {
                    ApplicationArea = All;
                }
                field("Next Posting Date Calculation"; "Next Posting Date Calculation")
                {
                    ApplicationArea = All;
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
                RunObject = Page "NPR NpRi Reimbursements";
                RunPageLink = "Party Type" = FIELD("Party Type"),
                              "Party No." = FIELD("No.");
                ApplicationArea=All;
            }
        }
    }
}

