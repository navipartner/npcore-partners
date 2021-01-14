page 6151104 "NPR NpRi Party Types"
{
    Caption = 'Reimbursement Party Types';
    DelayedInsert = true;
    PageType = List;
    SourceTable = "NPR NpRi Party Type";
    UsageCategory = Administration;
    ApplicationArea = All;
    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code"; Rec.Code)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Code field';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field';
                }
                field("Table No."; Rec."Table No.")
                {
                    ApplicationArea = All;
                    ShowMandatory = true;
                    ToolTip = 'Specifies the value of the Table No. field';
                }
                field("Table Name"; Rec."Table Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Table Name field';
                }
                field("Reimburse every"; Rec."Reimburse every")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Reimburse every field';
                }
                field("Next Posting Date Calculation"; Rec."Next Posting Date Calculation")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Next Posting Date Calculation field';
                }
            }
        }
    }
}

