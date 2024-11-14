page 6059797 "NPR E-mail Attachments"
{
    Extensible = false;
    AutoSplitKey = true;
    Caption = 'E-mail Attachments';
    PageType = List;
    UsageCategory = Administration;

    RefreshOnActivate = true;
    SaveValues = true;
    SourceTable = "NPR E-mail Attachment";
    SourceTableView = sorting("Table No.", "Primary Key", "Line No.");
    ApplicationArea = NPRRetail;

    layout
    {
        area(Content)
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

    actions
    {
        area(Processing)
        {
            action(UploadFile)
            {
                ApplicationArea = NPRRetail;
                Caption = 'Upload File';
                ToolTip = 'Uploads file to the email attachment';
                Image = Insert;
                trigger OnAction()
                var
                    EmailTemplMgt: Codeunit "NPR E-mail Templ. Mgt.";
                begin
                    EmailTemplMgt.UploadAttachment(Rec);
                end;
            }
        }
    }
}

