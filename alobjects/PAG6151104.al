page 6151104 "NpRi Party Types"
{
    // NPR5.44/MHA /20180723  CASE 320133 Object Created - NaviPartner Reimbursement

    Caption = 'Reimbursement Party Types';
    DelayedInsert = true;
    PageType = List;
    SourceTable = "NpRi Party Type";
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code"; Code)
                {
                    ApplicationArea = All;
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                }
                field("Table No."; "Table No.")
                {
                    ApplicationArea = All;
                    ShowMandatory = true;
                }
                field("Table Name"; "Table Name")
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
    }
}

