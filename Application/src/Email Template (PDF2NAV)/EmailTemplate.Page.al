page 6059791 "NPR E-mail Template"
{
    UsageCategory = None;
    Caption = 'E-mail Template';
    SourceTable = "NPR E-mail Template Header";

    layout
    {
        area(content)
        {
            group(Generelt)
            {
                field("Code"; Rec.Code)
                {
                    ApplicationArea = All;
                    Style = Standard;
                    StyleExpr = TRUE;
                    ToolTip = 'Specifies the value of the Code field';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field';
                }
                field("Table No."; Rec."Table No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Table No. field';
                }
                field(Filename; Rec.Filename)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Filename field';
                }
                field(Subject; Rec.Subject)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Subject field';
                }
                field("Verify Recipient"; Rec."Verify Recipient")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Verify Recipient field';
                }
                field("Sender as bcc"; Rec."Sender as bcc")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Sender as bcc field';
                }
                field("From E-mail Name"; Rec."From E-mail Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the From E-mail Name field';
                }
                field("From E-mail Address"; Rec."From E-mail Address")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the From E-mail Address field';
                }
                field("Default Recipient Address"; Rec."Default Recipient Address")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Default recipient e-mail address field';
                }
                field("Default Recipient Address CC"; Rec."Default Recipient Address CC")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Default recipient e-mail address (CC) field';
                }
                field("Default Recipient Address BCC"; Rec."Default Recipient Address BCC")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Default recipient e-mail address (BCC) field';
                }
                field("Report ID"; Rec."Report ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Report ID field';
                }
                group(Control6150644)
                {
                    ShowCaption = false;
                    Visible = (Rec."Transactional E-mail" = 0) OR (Rec."Transactional E-mail Code" = '');
                    field("Use HTML Template"; Rec."Use HTML Template")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Use HTML Template field';
                    }
                    field("FORMAT(""HTML Template"".HASVALUE)"; Format(Rec."HTML Template".HasValue))
                    {
                        ApplicationArea = All;
                        AssistEdit = true;
                        Caption = 'HTML Template';
                        ToolTip = 'Specifies the value of the HTML Template field';

                        trigger OnAssistEdit()
                        var
                            TextEditorPage: Page "NPR E-mail Txt Editor Dlg";
                            HtmlText: Text;
                            Instream: InStream;
                            Outstream: OutStream;
                        begin
                            Clear(TextEditorPage);
                            Rec.CalcFields("HTML Template");
                            HtmlText := '';
                            Rec."HTML Template".CreateInStream(Instream, TEXTENCODING::UTF8);
                            Instream.ReadText(HtmlText);
                            if TextEditorPage.EditText(HtmlText) then begin
                                Clear(Rec."HTML Template");
                                Rec."HTML Template".CreateOutStream(Outstream, TEXTENCODING::UTF8);
                                Outstream.WriteText(HtmlText);
                                Rec.Modify;
                            end;
                        end;
                    }
                }
                field("Fieldnumber Start Tag"; Rec."Fieldnumber Start Tag")
                {
                    ApplicationArea = All;
                    Importance = Additional;
                    ToolTip = 'Specifies the value of the Fieldnumber Start Tag field';
                }
                field("Fieldnumber End Tag"; Rec."Fieldnumber End Tag")
                {
                    ApplicationArea = All;
                    Importance = Additional;
                    ToolTip = 'Specifies the value of the Fieldnumber End Tag field';
                }
                field(Group; Rec.Group)
                {
                    ApplicationArea = All;
                    Importance = Additional;
                    ToolTip = 'Specifies the value of the Group field';
                }
                field("Transactional E-mail"; Rec."Transactional E-mail")
                {
                    ApplicationArea = All;
                    Importance = Additional;
                    ToolTip = 'Specifies the value of the Transactional E-mail field';
                }
                group(Control6150643)
                {
                    ShowCaption = false;
                    Visible = (Rec."Transactional E-mail" = 1);
                    field("Transactional E-mail Code"; Rec."Transactional E-mail Code")
                    {
                        ApplicationArea = All;
                        Importance = Additional;
                        ToolTip = 'Specifies the value of the Transactional E-mail Code field';
                    }
                }
            }
            part("Mail line"; "NPR E-mail Templ. Subform")
            {
                Caption = 'Mail line';
                ShowFilter = false;
                SubPageLink = "E-mail Template Code" = FIELD(Code);
                SubPageView = SORTING("E-mail Template Code", "Line No.");
                Visible = (Rec."Transactional E-mail" = 0) OR (Rec."Transactional E-mail Code" = '');
                ApplicationArea = All;
            }
        }
        area(factboxes)
        {
            part("Fields"; "NPR E-mail Field List")
            {
                Caption = 'Fields';
                ShowFilter = false;
                SubPageLink = TableNo = FIELD("Table No.");
                SubPageView = SORTING(TableNo, "No.");
                ApplicationArea = All;
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
                Visible = (Rec."Transactional E-mail" = 0) OR (Rec."Transactional E-mail Code" = '');
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
                Visible = (Rec."Transactional E-mail" = 0) OR (Rec."Transactional E-mail Code" = '');
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
                Visible = (Rec."Transactional E-mail" = 0) OR (Rec."Transactional E-mail Code" = '');
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
                Visible = (Rec."Transactional E-mail" = 0) OR (Rec."Transactional E-mail Code" = '');
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
                Visible = (Rec."Transactional E-mail" = 0) OR (Rec."Transactional E-mail Code" = '');
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

