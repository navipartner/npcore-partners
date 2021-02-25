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
                field("Code"; Rec.Code)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Code field';
                }
                field("Processing Type"; Rec."Processing Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Processing Type field';
                }
                field("Currency Code"; Rec."Currency Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Currency Code field';
                }
                field("Vouched By"; Rec."Vouched By")
                {
                    Visible = false;
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Vouched By field';
                }
                field("Include In Counting"; Rec."Include In Counting")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Include In Counting field';
                }
                field("Post Condensed"; Rec."Post Condensed")
                {
                    Visible = false;
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Post Condensed field';
                }
                field("Condensed Posting Description"; Rec."Condensed Posting Description")
                {
                    Visible = false;
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Condensed Posting Description field';
                }
                field("Rounding Precision"; Rec."Rounding Precision")
                {
                    Visible = false;
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Rounding Precision field';
                }
                field("Rounding Type"; Rec."Rounding Type")
                {
                    Visible = false;
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Rounding Type field';
                }
                field("Rounding Gains Account"; Rec."Rounding Gains Account")
                {
                    Visible = false;
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Rounding Gains Account field';
                }
                field("Rounding Losses Account"; Rec."Rounding Losses Account")
                {
                    Visible = false;
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Rounding Losses Account field';
                }
            }
        }
    }
}