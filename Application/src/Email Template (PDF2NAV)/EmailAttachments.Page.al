page 6059797 "NPR E-mail Attachments"
{
    AutoSplitKey = true;
    Caption = 'E-mail Attachments';
    PageType = List;
    UsageCategory = Administration;
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
                field("Line No."; "Line No.")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Line No. field';
                }
                field("Attached File"; "Attached File")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Attached data field';
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field';
                }
            }
        }
    }

    actions
    {
    }
}

