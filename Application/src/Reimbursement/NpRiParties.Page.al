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
                    ToolTip = 'Specifies the value of the Party Type field';
                }
                field("No."; "No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the No. field';
                }
                field(Name; Name)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Name field';
                }
                field("Reimburse every"; "Reimburse every")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Reimburse every field';
                }
                field("Next Posting Date Calculation"; "Next Posting Date Calculation")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Next Posting Date Calculation field';
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
                ApplicationArea = All;
                ToolTip = 'Executes the Reimbursements action';
            }
        }
    }
}

