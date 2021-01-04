page 6151104 "NPR NpRi Party Types"
{
    // NPR5.44/MHA /20180723  CASE 320133 Object Created - NaviPartner Reimbursement

    Caption = 'Reimbursement Party Types';
    DelayedInsert = true;
    PageType = List;
    SourceTable = "NPR NpRi Party Type";
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
                    ToolTip = 'Specifies the value of the Code field';
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field';
                }
                field("Table No."; "Table No.")
                {
                    ApplicationArea = All;
                    ShowMandatory = true;
                    ToolTip = 'Specifies the value of the Table No. field';
                }
                field("Table Name"; "Table Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Table Name field';
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
    }
}

