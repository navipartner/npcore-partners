page 6014463 "Touch Screen - Meta Triggers"
{
    Caption = 'Touch Screen - Meta Triggers';
    DelayedInsert = true;
    PageType = ListPart;
    SourceTable = "Touch Screen - MetaTriggers";

    layout
    {
        area(content)
        {
            repeater(Control6150621)
            {
                ShowCaption = false;
                field(When; When)
                {
                    ApplicationArea = All;
                }
                field(Sequence; Sequence)
                {
                    ApplicationArea = All;
                }
                field("Register No."; "Register No.")
                {
                    ApplicationArea = All;
                }
                field("Line Type"; "Line Type")
                {
                    ApplicationArea = All;
                }
                field(ID; ID)
                {
                    ApplicationArea = All;
                }
                field("Var Parameter"; "Var Parameter")
                {
                    ApplicationArea = All;
                }
                field("Var Record Param"; "Var Record Param")
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

