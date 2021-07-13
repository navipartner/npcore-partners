page 6150672 "NPR POS Entry Output Log"
{
    Caption = 'POS Entry Output Log';
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    UsageCategory = Administration;

    SourceTable = "NPR POS Entry Output Log";
    ApplicationArea = NPRRetail;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Entry No."; Rec."Entry No.")
                {

                    ToolTip = 'Specifies the value of the Entry No. field';
                    ApplicationArea = NPRRetail;
                }
                field("POS Entry No."; Rec."POS Entry No.")
                {

                    ToolTip = 'Specifies the value of the POS Entry No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Output Timestamp"; Rec."Output Timestamp")
                {

                    ToolTip = 'Specifies the value of the Output Timestamp field';
                    ApplicationArea = NPRRetail;
                }
                field("Output Type"; Rec."Output Type")
                {

                    ToolTip = 'Specifies the value of the Output Type field';
                    ApplicationArea = NPRRetail;
                }
                field("User ID"; Rec."User ID")
                {

                    ToolTip = 'Specifies the value of the User ID field';
                    ApplicationArea = NPRRetail;
                }
                field("Salesperson Code"; Rec."Salesperson Code")
                {

                    ToolTip = 'Specifies the value of the Salesperson Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Output Method"; Rec."Output Method")
                {

                    ToolTip = 'Specifies the value of the Output Method field';
                    ApplicationArea = NPRRetail;
                }
                field("Output Method Code"; Rec."Output Method Code")
                {

                    ToolTip = 'Specifies the value of the Output Method Code field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }

    actions
    {
    }
}

