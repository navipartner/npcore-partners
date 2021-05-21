page 6059797 "NPR E-mail Attachments"
{
    AutoSplitKey = true;
    Caption = 'E-mail Attachments';
    PageType = List;
    UsageCategory = Administration;
    ApplicationArea = All;
    RefreshOnActivate = true;
    SaveValues = true;
    SourceTable = "NPR E-mail Attachment";
    SourceTableView = SORTING("Table No.", "Primary Key", "Line No.");

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                Caption = 'Files';
                field("Line No."; Rec."Line No.")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Line No. field';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field';
                }
            }
        }
    }
}

