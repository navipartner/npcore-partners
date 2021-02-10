page 6059782 "NPR POS Pmt Methods Select"
{
    Caption = 'POS Payment Method List';
    PageType = List;
    SourceTable = "NPR POS Payment Method";
    InsertAllowed = false;
    ModifyAllowed = false;
    DeleteAllowed = false;
    UsageCategory = None;

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
                field("Processing Type"; "Processing Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Processing Type field';
                }
                field("Currency Code"; "Currency Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Currency Code field';
                }
                field("Vouched By"; "Vouched By")
                {
                    Visible = false;
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Vouched By field';
                }
                field("Is Finance Agreement"; "Is Finance Agreement")
                {
                    Visible = false;
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Is Finance Agreement field';
                }
                field("Include In Counting"; "Include In Counting")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Include In Counting field';
                }
                field("Post Condensed"; "Post Condensed")
                {
                    Visible = false;
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Post Condensed field';
                }
                field("Condensed Posting Description"; "Condensed Posting Description")
                {
                    Visible = false;
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Condensed Posting Description field';
                }
                field("Rounding Precision"; "Rounding Precision")
                {
                    Visible = false;
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Rounding Precision field';
                }
                field("Rounding Type"; "Rounding Type")
                {
                    Visible = false;
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Rounding Type field';
                }
                field("Rounding Gains Account"; "Rounding Gains Account")
                {
                    Visible = false;
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Rounding Gains Account field';
                }
                field("Rounding Losses Account"; "Rounding Losses Account")
                {
                    Visible = false;
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Rounding Losses Account field';
                }
            }
        }
    }
}