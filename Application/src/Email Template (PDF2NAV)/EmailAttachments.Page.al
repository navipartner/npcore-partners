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
                }
                field("Attached File"; "Attached File")
                {
                    ApplicationArea = All;
                }
                field(Description; Description)
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

