﻿page 6059791 "NPR E-mail Template"
{
    Extensible = false;
    UsageCategory = None;
    Caption = 'E-mail Template';
    ContextSensitiveHelpPage = 'docs/retail/vouchers/how-to/email_templates/';
    SourceTable = "NPR E-mail Template Header";
    PopulateAllFields = true;

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';

                field("Code"; Rec.Code)
                {
                    Style = Standard;
                    StyleExpr = true;
                    ToolTip = 'Specifies the value of the Code field';
                    ApplicationArea = NPRLegacyEmail;
                }
                field(Description; Rec.Description)
                {
                    ToolTip = 'Specifies the value of the Description field';
                    ApplicationArea = NPRLegacyEmail;
                }
                field("Table No."; Rec."Table No.")
                {
                    ToolTip = 'Specifies the value of the Table No. field';
                    ApplicationArea = NPRLegacyEmail;
                }
                field(Filename; Rec.Filename)
                {
                    ToolTip = 'Specifies the value of the Filename field';
                    ApplicationArea = NPRLegacyEmail;
                }
                field(Subject; Rec.Subject)
                {
                    ToolTip = 'Specifies the value of the Subject field';
                    ApplicationArea = NPRLegacyEmail;
                }
                field("Verify Recipient"; Rec."Verify Recipient")
                {
                    ToolTip = 'Specifies the value of the Verify Recipient field';
                    ApplicationArea = NPRLegacyEmail;
                }
                field("Sender as bcc"; Rec."Sender as bcc")
                {
                    ToolTip = 'Specifies the value of the Sender as bcc field';
                    ApplicationArea = NPRLegacyEmail;
                }
                field("From E-mail Name"; Rec."From E-mail Name")
                {
                    ToolTip = 'Specifies the value of the From E-mail Name field';
                    ApplicationArea = NPRLegacyEmail;
                    ShowMandatory = true;
                }
                field("From E-mail Address"; Rec."From E-mail Address")
                {
                    ToolTip = 'Specifies the value of the From E-mail Address field';
                    ApplicationArea = NPRLegacyEmail;
                    ShowMandatory = true;
                }
                field("Email Scenario"; Rec."Email Scenario")
                {
                    ToolTip = 'Specifies the e-mail scenario that the e-mail will be sent as';
                    ApplicationArea = NPRLegacyEmail;
                }
                field("Default Recipient Address"; Rec."Default Recipient Address")
                {
                    ToolTip = 'Specifies the value of the Default recipient e-mail address field';
                    ApplicationArea = NPRLegacyEmail;
                }
                field("Default Recipient Address CC"; Rec."Default Recipient Address CC")
                {
                    ToolTip = 'Specifies the value of the Default recipient e-mail address (CC) field';
                    ApplicationArea = NPRLegacyEmail;
                }
                field("Default Recipient Address BCC"; Rec."Default Recipient Address BCC")
                {
                    ToolTip = 'Specifies the value of the Default recipient e-mail address (BCC) field';
                    ApplicationArea = NPRLegacyEmail;
                }
                field("Report ID"; Rec."Report ID")
                {
                    ToolTip = 'Specifies the value of the Report ID field';
                    ApplicationArea = NPRLegacyEmail;
                }
                group(Control6150644)
                {
                    ShowCaption = false;
                    Visible = (Rec."Transactional E-mail" = 0) or (Rec."Transactional E-mail Code" = '');
                    field("Use HTML Template"; Rec."Use HTML Template")
                    {
                        ToolTip = 'Specifies the value of the Use HTML Template field';
                        ApplicationArea = NPRLegacyEmail;
                    }
                    field(HTMLTemplateHasValue; Format(Rec."HTML Template".HasValue))
                    {
                        AssistEdit = true;
                        Caption = 'HTML Template';
                        ToolTip = 'Specifies the value of the HTML Template field';
                        ApplicationArea = NPRLegacyEmail;

                        trigger OnAssistEdit()
                        var
                            MagentoFunctions: Codeunit "NPR Magento Functions";
                            TempBlob: Codeunit "Temp Blob";
                            OutStr: OutStream;
                            InStr: InStream;
                        begin
                            TempBlob.CreateOutStream(OutStr);
                            Rec.CalcFields("HTML Template");
                            Rec."HTML Template".CreateInStream(InStr);
                            CopyStream(OutStr, InStr);
                            if MagentoFunctions.NaviEditorEditTempBlob(TempBlob) then begin
                                if TempBlob.HasValue() then begin
                                    TempBlob.CreateInStream(InStr);
                                    Rec."HTML Template".CreateOutStream(OutStr);
                                    CopyStream(OutStr, InStr);
                                end else
                                    Clear(Rec."HTML Template");
                                Rec.Modify(true);
                            end;
                        end;
                    }
                }
                field("Fieldnumber Start Tag"; Rec."Fieldnumber Start Tag")
                {
                    Importance = Additional;
                    ToolTip = 'Specifies the value of the Fieldnumber Start Tag field';
                    ApplicationArea = NPRLegacyEmail;
                }
                field("Fieldnumber End Tag"; Rec."Fieldnumber End Tag")
                {
                    Importance = Additional;
                    ToolTip = 'Specifies the value of the Fieldnumber End Tag field';
                    ApplicationArea = NPRLegacyEmail;
                }
                field(Group; Rec.Group)
                {
                    Importance = Additional;
                    ToolTip = 'Specifies the value of the Group field';
                    ApplicationArea = NPRLegacyEmail;
                }
                field("Transactional E-mail"; Rec."Transactional E-mail")
                {
                    Importance = Additional;
                    ToolTip = 'Specifies the value of the Transactional E-mail field';
                    ApplicationArea = NPRLegacyEmail;
                }
                group(Control6150643)
                {
                    ShowCaption = false;
                    Visible = (Rec."Transactional E-mail" = 1);
                    field("Transactional E-mail Code"; Rec."Transactional E-mail Code")
                    {
                        Importance = Additional;
                        ToolTip = 'Specifies the value of the Transactional E-mail Code field';
                        ApplicationArea = NPRLegacyEmail;
                    }
                }
            }
            part("Mail line"; "NPR E-mail Templ. Subform")
            {
                Caption = 'Mail line';
                ShowFilter = false;
                SubPageLink = "E-mail Template Code" = field(Code);
                SubPageView = sorting("E-mail Template Code", "Line No.");
                Visible = (Rec."Transactional E-mail" = 0) or (Rec."Transactional E-mail Code" = '');
                ApplicationArea = NPRLegacyEmail;
            }
        }
        area(FactBoxes)
        {
            part("Fields"; "NPR E-mail Field List")
            {
                Caption = 'Fields';
                ShowFilter = false;
                SubPageLink = TableNo = field("Table No.");
                SubPageView = sorting(TableNo, "No.");
                ApplicationArea = NPRLegacyEmail;
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
                ToolTip = 'Executes the Import HTML Template action';
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
                ToolTip = 'Executes the Export HTML Template action';
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
                ToolTip = 'Executes the Copy From E-Mail Template action';
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
                ToolTip = 'Executes the Delete HTML Template action';
                ApplicationArea = NPRLegacyEmail;

                trigger OnAction()
                var
                    EmailTemplateMgt: Codeunit "NPR E-mail Templ. Mgt.";
                begin
                    EmailTemplateMgt.DeleteHtmlTemplate(Rec);
                end;
            }
            action(SendTestEmail)
            {
                Caption = 'Send E-mail';
                Image = SendMail;
                Visible = true;
                ToolTip = 'Send Test E-mail';
                ApplicationArea = NPRLegacyEmail;

                trigger OnAction()
                var
                    EmailTemplateHeader: Record "NPR E-mail Template Header";
                    EmailTemplateMgt: Codeunit "NPR E-mail Templ. Mgt.";
                begin
                    EmailTemplateHeader := Rec;
                    EmailTemplateMgt.SendTestEmail(EmailTemplateHeader);
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
                ToolTip = 'Executes the Email Template Filters action';
                ApplicationArea = NPRLegacyEmail;
            }
            action(AttachedFiles)
            {
                Caption = 'Attached Files';
                Image = MailAttachment;
                ToolTip = 'Executes the Attached Files action';
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
                ToolTip = 'Executes the Additional Reports action';
                ApplicationArea = NPRLegacyEmail;
            }
        }
    }
}
