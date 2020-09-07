page 6059795 "NPR E-mail Templates"
{
    // PN1.00/MH/20140730  NAV-AddOn: PDF2NAV
    //   - Refactored module from the "Mail And Document Handler" Module.
    //   - This Page Contains a List of E-mail Templates used for sending E-mail using PDF2NAV.
    // PN1.08/MHA/20151214  CASE 228859 Pdf2Nav (New Version List)
    // NPR5.48/MHA /20190123  CASE 341711 Added Page Actions

    Caption = 'E-mail Templates';
    CardPageID = "NPR E-mail Template";
    Editable = false;
    PageType = List;
    SourceTable = "NPR E-mail Template Header";
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code"; Code)
                {
                    ApplicationArea = All;
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                }
                field("Report ID"; "Report ID")
                {
                    ApplicationArea = All;
                }
                field("Table No."; "Table No.")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(EditHTMLTemplate)
            {
                Caption = 'Edit HTML Template';
                Image = Edit;
                Visible = ("Transactional E-mail" = 0) OR ("Transactional E-mail Code" = '');
                ApplicationArea=All;

                trigger OnAction()
                var
                    EmailTemplateMgt: Codeunit "NPR E-mail Templ. Mgt.";
                begin
                    //-NPR5.48 [341711]
                    EmailTemplateMgt.EditHtmlTemplate(Rec);
                    //+NPR5.48 [341711]
                end;
            }
            action(ViewHTMLTemplate)
            {
                Caption = 'View HTML Template';
                Image = View;
                Visible = ("Transactional E-mail" = 0) OR ("Transactional E-mail Code" = '');
                ApplicationArea=All;

                trigger OnAction()
                var
                    EmailTemplateMgt: Codeunit "NPR E-mail Templ. Mgt.";
                begin
                    //-NPR5.48 [341711]
                    EmailTemplateMgt.ViewHtmlTemplate(Rec);
                    //+NPR5.48 [341711]
                end;
            }
            action(ImportHTMLTemplate)
            {
                Caption = 'Import HTML Template';
                Image = Import;
                Visible = ("Transactional E-mail" = 0) OR ("Transactional E-mail Code" = '');
                ApplicationArea=All;

                trigger OnAction()
                var
                    EmailTemplateMgt: Codeunit "NPR E-mail Templ. Mgt.";
                    Path: Text;
                begin
                    //-NPR5.48 [341711]
                    EmailTemplateMgt.ImportHtmlTemplate(Path, true, Rec);
                    //+NPR5.48 [341711]
                end;
            }
            action(ExportHtmlTemplate)
            {
                Caption = 'Export HTML Template';
                Image = Export;
                Visible = ("Transactional E-mail" = 0) OR ("Transactional E-mail Code" = '');
                ApplicationArea=All;

                trigger OnAction()
                var
                    EmailTemplateMgt: Codeunit "NPR E-mail Templ. Mgt.";
                begin
                    //-NPR5.48 [341711]
                    EmailTemplateMgt.ExportHtmlTemplate(Rec, true);
                    //+NPR5.48 [341711]
                end;
            }
            action(CopyFromTemplate)
            {
                Caption = 'Copy From E-Mail Template';
                Image = Copy;
                Visible = ("Transactional E-mail" = 0) OR ("Transactional E-mail Code" = '');
                ApplicationArea=All;

                trigger OnAction()
                var
                    EmailTemplateMgt: Codeunit "NPR E-mail Templ. Mgt.";
                begin
                    //-NPR5.48 [341711]
                    EmailTemplateMgt.CopyFromTemplate(Rec);
                    //+NPR5.48 [341711]
                end;
            }
            action(DeleteHTMLTemplate)
            {
                Caption = 'Delete HTML Template';
                Image = Delete;
                Visible = ("Transactional E-mail" = 0) OR ("Transactional E-mail Code" = '');
                ApplicationArea=All;

                trigger OnAction()
                var
                    EmailTemplateMgt: Codeunit "NPR E-mail Templ. Mgt.";
                begin
                    //-NPR5.48 [341711]
                    EmailTemplateMgt.DeleteHtmlTemplate(Rec);
                    //+NPR5.48 [341711]
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
                ApplicationArea=All;
            }
            action(EmailTemplateFilters)
            {
                Caption = 'Email Template Filters';
                Image = UseFilters;
                RunObject = Page "NPR E-mail Templ. Filters";
                RunPageLink = "E-mail Template Code" = FIELD(Code),
                              "Table No." = FIELD("Table No.");
                RunPageView = SORTING("E-mail Template Code", "Table No.", "Line No.");
                ApplicationArea=All;
            }
            action(AttachedFiles)
            {
                Caption = 'Attached Files';
                Image = MailAttachment;
                ApplicationArea=All;

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
                ApplicationArea=All;
            }
        }
    }
}

