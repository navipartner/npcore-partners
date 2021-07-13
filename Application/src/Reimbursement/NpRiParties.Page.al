page 6151105 "NPR NpRi Parties"
{

    Caption = 'Reimbursement Parties';
    DelayedInsert = true;
    PageType = List;
    SourceTable = "NPR NpRi Party";
    UsageCategory = Lists;
    ApplicationArea = NPRRetail;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Party Type"; Rec."Party Type")
                {

                    ToolTip = 'Specifies the value of the Party Type field';
                    ApplicationArea = NPRRetail;
                }
                field("No."; Rec."No.")
                {

                    ToolTip = 'Specifies the value of the No. field';
                    ApplicationArea = NPRRetail;
                }
                field(Name; Rec.Name)
                {

                    ToolTip = 'Specifies the value of the Name field';
                    ApplicationArea = NPRRetail;
                }
                field("Reimburse every"; Rec."Reimburse every")
                {

                    ToolTip = 'Specifies the value of the Reimburse every field';
                    ApplicationArea = NPRRetail;
                }
                field("Next Posting Date Calculation"; Rec."Next Posting Date Calculation")
                {

                    ToolTip = 'Specifies the value of the Next Posting Date Calculation field';
                    ApplicationArea = NPRRetail;
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

                ToolTip = 'Executes the Reimbursements action';
                ApplicationArea = NPRRetail;
            }
        }
    }
}

