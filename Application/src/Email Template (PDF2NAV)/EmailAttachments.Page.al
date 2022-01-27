page 6059797 "NPR E-mail Attachments"
{
    Extensible = False;
    AutoSplitKey = true;
    Caption = 'E-mail Attachments';
    PageType = List;
    UsageCategory = Administration;

    RefreshOnActivate = true;
    SaveValues = true;
    SourceTable = "NPR E-mail Attachment";
    SourceTableView = SORTING("Table No.", "Primary Key", "Line No.");
    ApplicationArea = NPRRetail;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                Caption = 'Files';
                field("Line No."; Rec."Line No.")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Line No. field';
                    ApplicationArea = NPRRetail;
                }
                field(Description; Rec.Description)
                {

                    ToolTip = 'Specifies the value of the Description field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }
}

