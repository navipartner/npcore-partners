page 6059795 "NPR E-mail Templates"
{
    Extensible = false;

    Caption = 'E-mail Templates';
    CardPageId = "NPR E-mail Template";
    Editable = false;
    PageType = List;
    SourceTable = "NPR E-mail Template Header";
    UsageCategory = Lists;
    ApplicationArea = NPRRetail;


    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("Code"; Rec.Code)
                {

                    ToolTip = 'Specifies the value of the Code field';
                    ApplicationArea = NPRRetail;
                }
                field(Description; Rec.Description)
                {

                    ToolTip = 'Specifies the value of the Description field';
                    ApplicationArea = NPRRetail;
                }
                field("Report ID"; Rec."Report ID")
                {

                    ToolTip = 'Specifies the value of the Report ID field';
                    ApplicationArea = NPRRetail;
                }
                field("Table No."; Rec."Table No.")
                {

                    ToolTip = 'Specifies the value of the Table No. field';
                    ApplicationArea = NPRRetail;
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

                ToolTip = 'Executes the View HTML Template action';
                ApplicationArea = NPRRetail;

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

                ToolTip = 'Executes the Import HTML Template action';
                ApplicationArea = NPRRetail;

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

                ToolTip = 'Executes the Export HTML Template action';
                ApplicationArea = NPRRetail;

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

                ToolTip = 'Executes the Copy From E-Mail Template action';
                ApplicationArea = NPRRetail;

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

                ToolTip = 'Executes the Delete HTML Template action';
                ApplicationArea = NPRRetail;

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

                ToolTip = 'Executes the E-mail Log action';
                ApplicationArea = NPRRetail;
            }
            action(EmailTemplateFilters)
            {
                Caption = 'Email Template Filters';
                Image = UseFilters;
                RunObject = page "NPR E-mail Templ. Filters";
                RunPageLink = "E-mail Template Code" = field(Code),
                              "Table No." = field("Table No.");
                RunPageView = sorting("E-mail Template Code", "Table No.", "Line No.");

                ToolTip = 'Executes the Email Template Filters action';
                ApplicationArea = NPRRetail;
            }
            action(AttachedFiles)
            {
                Caption = 'Attached Files';
                Image = MailAttachment;

                ToolTip = 'Executes the Attached Files action';
                ApplicationArea = NPRRetail;

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

                ToolTip = 'Executes the Additional Reports action';
                ApplicationArea = NPRRetail;
            }
        }
    }
}

