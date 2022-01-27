page 6151104 "NPR NpRi Party Types"
{
    Extensible = False;
    Caption = 'Reimbursement Party Types';
    DelayedInsert = true;
    PageType = List;
    SourceTable = "NPR NpRi Party Type";
    UsageCategory = Administration;
    ApplicationArea = NPRRetail;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code"; Rec.Code)
                {

                    ToolTip = 'Specifies the value of the Code field';
                    ApplicationArea = NPRRetail;
                }
                field(Description; Rec.Description)
                {

                    ToolTip = 'Specifies the value of the Description field';
                    ApplicationArea = NPRRetail;
                }
                field("Table No."; Rec."Table No.")
                {

                    ShowMandatory = true;
                    ToolTip = 'Specifies the value of the Table No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Table Name"; Rec."Table Name")
                {

                    ToolTip = 'Specifies the value of the Table Name field';
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
}

