page 6150723 "NPR POS Entry Comments"
{
    Caption = 'POS Entry Comments';
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    UsageCategory = Administration;
    ApplicationArea = All;
    SourceTable = "NPR POS Entry Comm. Line";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("POS Entry No."; Rec."POS Entry No.")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the POS Entry No. field';
                }
                field("Code"; Rec.Code)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Code field';
                }
                field(Comment; Rec.Comment)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Comment field';
                }
            }
        }
    }

    actions
    {
    }
}

