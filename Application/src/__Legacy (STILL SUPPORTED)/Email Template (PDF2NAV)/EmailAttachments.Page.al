page 6059797 "NPR E-mail Attachments"
{
    ObsoleteState = Pending;
    ObsoleteTag = '2026-01-29';
    ObsoleteReason = 'This module is no longer being maintained';
    Extensible = false;
    AutoSplitKey = true;
    Caption = 'E-mail Attachments';
    PageType = List;
    UsageCategory = Administration;

    RefreshOnActivate = true;
    SaveValues = true;
    SourceTable = "NPR E-mail Attachment";
    SourceTableView = sorting("Table No.", "Primary Key", "Line No.");
    ApplicationArea = NPRLegacyEmail;

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
                    ApplicationArea = NPRLegacyEmail;
                }
                field(Description; Rec.Description)
                {

                    ToolTip = 'Specifies the value of the Description field';
                    ApplicationArea = NPRLegacyEmail;
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
                ApplicationArea = NPRLegacyEmail;
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

