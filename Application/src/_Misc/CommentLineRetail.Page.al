page 6014479 "NPR Comment Line - Retail"
{
    // NPR5.36/TJ  /20170809  CASE 286283 Removed unused functions
    // NPR5.48/TJ  /20190129  CASE 340446 Added version NPHC1.00 as used by codeunit 6151558

    Caption = 'Comment Line - Retail';
    PageType = List;
    UsageCategory = Administration;
    SourceTable = "Comment Line";

    layout
    {
        area(content)
        {
            repeater(Control6150613)
            {
                ShowCaption = false;
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

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        SetUpNewLine;
    end;
}

