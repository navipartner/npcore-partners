page 6150723 "NPR POS Entry Comments"
{
    // NPR5.36/NPKNAV/20171003  CASE 277096 Transport NPR5.36 - 3 October 2017

    Caption = 'POS Entry Comments';
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    UsageCategory = Administration;
    SourceTable = "NPR POS Entry Comm. Line";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("POS Entry No."; "POS Entry No.")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the POS Entry No. field';
                }
                field("Code"; Code)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Code field';
                }
                field(Comment; Comment)
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

