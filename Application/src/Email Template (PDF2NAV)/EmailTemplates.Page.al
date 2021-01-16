page 6059795 "NPR E-mail Templates"
{

    Caption = 'E-mail Templates';
    CardPageID = "NPR E-mail Template";
    Editable = false;
    PageType = List;
    SourceTable = "NPR E-mail Template Header";
    UsageCategory = Lists;
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code"; Code)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Code field';
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field';
                }
                field("Report ID"; "Report ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Report ID field';
                }
                field("Table No."; "Table No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Table No. field';
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(ViewHTMLTemplate)
            {
                Caption = 'View HTML Template';
                Image = View;
                Visible = ("Transactional E-mail" = 0) OR ("Transactional E-mail Code" = '');
                ApplicationArea = All;
                ToolTip = 'Executes the View HTML Template action';

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
                Visible = ("Transactional E-mail" = 0) OR ("Transactional E-mail Code" = '');
                ApplicationArea = All;
                ToolTip = 'Executes the Import HTML Template action';

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
                Visible = ("Transactional E-mail" = 0) OR ("Transactional E-mail Code" = '');
                ApplicationArea = All;
                ToolTip = 'Executes the Export HTML Template action';

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
                Visible = ("Transactional E-mail" = 0) OR ("Transactional E-mail Code" = '');
                ApplicationArea = All;
                ToolTip = 'Executes the Copy From E-Mail Template action';

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
                Visible = ("Transactional E-mail" = 0) OR ("Transactional E-mail Code" = '');
                ApplicationArea = All;
                ToolTip = 'Executes the Delete HTML Template action';

                trigger OnAction()
                var
                    EmailTemplateMgt: Codeunit "NPR E-mail Templ. Mgt.";
                begin
                    EmailTemplateMgt.DeleteHtmlTemplate(Rec);
                end;
            }
        }
        area(navigation)
        {
            action(EmailLog)
            {
                Caption = 'E-mail Log';
                Image = ListPage;
                RunObject = Page "NPR E-mail Log";
                RunPageLink = "Table No." = FIELD("Table No.");
                RunPageView = SORTING("Entry No.");
                ApplicationArea = All;
                ToolTip = 'Executes the E-mail Log action';
            }
            action(EmailTemplateFilters)
            {
                Caption = 'Email Template Filters';
                Image = UseFilters;
                RunObject = Page "NPR E-mail Templ. Filters";
                RunPageLink = "E-mail Template Code" = FIELD(Code),
                              "Table No." = FIELD("Table No.");
                RunPageView = SORTING("E-mail Template Code", "Table No.", "Line No.");
                ApplicationArea = All;
                ToolTip = 'Executes the Email Template Filters action';
            }
            action(AttachedFiles)
            {
                Caption = 'Attached Files';
                Image = MailAttachment;
                ApplicationArea = All;
                ToolTip = 'Executes the Attached Files action';

                trigger OnAction()
                var
                    RecRef: RecordRef;
                    RetailAttachments: Record "NPR E-mail Attachment";
                begin
                    RecRef.GetTable(Rec);
                    Clear(RetailAttachments);
                    RetailAttachments.SetRange("Table No.", RecRef.Number);
                    RetailAttachments.SetRange("Primary Key", RecRef.GetPosition(false));
                    PAGE.Run(PAGE::"NPR E-mail Attachments", RetailAttachments);
                end;
            }
            action(AdditionalReports)
            {
                Caption = 'Additional Reports';
                Image = "Report";
                RunObject = Page "NPR E-mail Templ. Reports";
                RunPageLink = "E-mail Template Code" = FIELD(Code);
                ApplicationArea = All;
                ToolTip = 'Executes the Additional Reports action';
            }
        }
    }
}

