page 6059795 "NPR E-mail Templates"
{
    ObsoleteState = Pending;
    ObsoleteTag = '2026-01-29';
    ObsoleteReason = 'This module is no longer being maintained';
    Extensible = false;

    Caption = 'E-mail Templates';
    CardPageId = "NPR E-mail Template";
    Editable = false;
    PageType = List;
    SourceTable = "NPR E-mail Template Header";
    UsageCategory = Lists;
    ApplicationArea = NPRLegacyEmail;

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("Code"; Rec.Code)
                {

                    ToolTip = 'Specifies the unique code assigned to this e-mail template';
                    ApplicationArea = NPRLegacyEmail;
                }
                field(Description; Rec.Description)
                {

                    ToolTip = 'Specifies the description or name of this e-mail template';
                    ApplicationArea = NPRLegacyEmail;
                }
                field("Report ID"; Rec."Report ID")
                {

                    ToolTip = 'Specifies the ID of the associated report for this e-mail template';
                    ApplicationArea = NPRLegacyEmail;
                }
                field("Table No."; Rec."Table No.")
                {

                    ToolTip = 'Specifies the table number associated with this e-mail template.';
                    ApplicationArea = NPRLegacyEmail;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(ViewHTMLTemplate)
            {
                Caption = 'View HTML Template';
                Image = View;
                Visible = (Rec."Transactional E-mail" = 0) or (Rec."Transactional E-mail Code" = '');

                ToolTip = 'Open and view the HTML template associated with this e-mail template';
                ApplicationArea = NPRLegacyEmail;

                trigger OnAction()
                var
                    EmailTemplateMgt: Codeunit "NPR E-mail Templ. Mgt.";
                begin
                    EmailTemplateMgt.ViewHtmlTemplate(Rec);
                end;
            }
            action(ImportHTMLTemplate)
            {
                Caption = 'Import HTML Template';
                Image = Import;
                Visible = (Rec."Transactional E-mail" = 0) or (Rec."Transactional E-mail Code" = '');

                ToolTip = 'Import an external HTML template to use with this e-mail template';
                ApplicationArea = NPRLegacyEmail;

                trigger OnAction()
                var
                    EmailTemplateMgt: Codeunit "NPR E-mail Templ. Mgt.";
                    Path: Text;
                begin
                    EmailTemplateMgt.ImportHtmlTemplate(Path, true, Rec);
                end;
            }
            action(ExportHtmlTemplate)
            {
                Caption = 'Export HTML Template';
                Image = Export;
                Visible = (Rec."Transactional E-mail" = 0) or (Rec."Transactional E-mail Code" = '');

                ToolTip = 'Export the HTML template associated with this e-mail template as a file';
                ApplicationArea = NPRLegacyEmail;

                trigger OnAction()
                var
                    EmailTemplateMgt: Codeunit "NPR E-mail Templ. Mgt.";
                begin
                    EmailTemplateMgt.ExportHtmlTemplate(Rec, true);
                end;
            }
            action(CopyFromTemplate)
            {
                Caption = 'Copy From E-Mail Template';
                Image = Copy;
                Visible = (Rec."Transactional E-mail" = 0) or (Rec."Transactional E-mail Code" = '');

                ToolTip = 'Copy the contents and settings from another e-mail template to create a new one';
                ApplicationArea = NPRLegacyEmail;

                trigger OnAction()
                var
                    EmailTemplateMgt: Codeunit "NPR E-mail Templ. Mgt.";
                begin
                    EmailTemplateMgt.CopyFromTemplate(Rec);
                end;
            }
            action(DeleteHTMLTemplate)
            {
                Caption = 'Delete HTML Template';
                Image = Delete;
                Visible = (Rec."Transactional E-mail" = 0) or (Rec."Transactional E-mail Code" = '');

                ToolTip = 'Delete the HTML template associated with this e-mail template';
                ApplicationArea = NPRLegacyEmail;

                trigger OnAction()
                var
                    EmailTemplateMgt: Codeunit "NPR E-mail Templ. Mgt.";
                begin
                    EmailTemplateMgt.DeleteHtmlTemplate(Rec);
                end;
            }
        }
        area(Navigation)
        {
            action(EmailLog)
            {
                Caption = 'E-mail Log';
                Image = ListPage;
                RunObject = page "NPR E-mail Log";
                RunPageLink = "Table No." = field("Table No.");
                RunPageView = sorting("Entry No.");

                ToolTip = 'View the log of sent e-mails related to this e-mail template';
                ApplicationArea = NPRLegacyEmail;
            }
            action(EmailTemplateFilters)
            {
                Caption = 'Email Template Filters';
                Image = UseFilters;
                RunObject = page "NPR E-mail Templ. Filters";
                RunPageLink = "E-mail Template Code" = field(Code),
                              "Table No." = field("Table No.");
                RunPageView = sorting("E-mail Template Code", "Table No.", "Line No.");

                ToolTip = 'Set up filters to define conditions for applying this e-mail template';
                ApplicationArea = NPRLegacyEmail;
            }
            action(AttachedFiles)
            {
                Caption = 'Attached Files';
                Image = MailAttachment;

                ToolTip = 'View and manage the attached files associated with this e-mail template';
                ApplicationArea = NPRLegacyEmail;

                trigger OnAction()
                var
                    RecRef: RecordRef;
                    RetailAttachments: Record "NPR E-mail Attachment";
                begin
                    RecRef.GetTable(Rec);
                    Clear(RetailAttachments);
                    RetailAttachments.SetRange("Table No.", RecRef.Number);
                    RetailAttachments.SetRange("Primary Key", RecRef.GetPosition(false));
                    Page.Run(Page::"NPR E-mail Attachments", RetailAttachments);
                end;
            }
            action(AdditionalReports)
            {
                Caption = 'Additional Reports';
                Image = "Report";
                RunObject = page "NPR E-mail Templ. Reports";
                RunPageLink = "E-mail Template Code" = field(Code);

                ToolTip = 'Configure additional reports to be included when this e-mail template is generated';
                ApplicationArea = NPRLegacyEmail;
            }
        }
    }
}