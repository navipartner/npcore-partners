page 6059782 "NPR POS Pmt Methods Select"
{
    Extensible = False;
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

                    ToolTip = 'Specifies the value of the Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Processing Type"; Rec."Processing Type")
                {

                    ToolTip = 'Specifies the value of the Processing Type field';
                    ApplicationArea = NPRRetail;
                }
                field("Currency Code"; Rec."Currency Code")
                {

                    ToolTip = 'Specifies the value of the Currency Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Vouched By"; Rec."Vouched By")
                {
                    Visible = false;

                    ToolTip = 'Specifies the value of the Vouched By field';
                    ApplicationArea = NPRRetail;
                }
                field("Include In Counting"; Rec."Include In Counting")
                {

                    ToolTip = 'Specifies the value of the Include In Counting field';
                    ApplicationArea = NPRRetail;
                }
                field("Post Condensed"; Rec."Post Condensed")
                {
                    Visible = false;

                    ToolTip = 'Specifies the value of the Post Condensed field';
                    ApplicationArea = NPRRetail;
                }
                field("Condensed Posting Description"; Rec."Condensed Posting Description")
                {
                    Visible = false;

                    ToolTip = 'Specifies the value of the Condensed Posting Description field';
                    ApplicationArea = NPRRetail;
                }
                field("Rounding Precision"; Rec."Rounding Precision")
                {
                    Visible = false;

                    ToolTip = 'Specifies the value of the Rounding Precision field';
                    ApplicationArea = NPRRetail;
                }
                field("Rounding Type"; Rec."Rounding Type")
                {
                    Visible = false;

                    ToolTip = 'Specifies the value of the Rounding Type field';
                    ApplicationArea = NPRRetail;
                }
                field("Rounding Gains Account"; Rec."Rounding Gains Account")
                {
                    Visible = false;

                    ToolTip = 'Specifies the value of the Rounding Gains Account field';
                    ApplicationArea = NPRRetail;
                }
                field("Rounding Losses Account"; Rec."Rounding Losses Account")
                {
                    Visible = false;

                    ToolTip = 'Specifies the value of the Rounding Losses Account field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }
}
