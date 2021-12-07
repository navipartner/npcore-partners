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

                    Style = Standard;
                    StyleExpr = TRUE;
                    ToolTip = 'Specifies the value of the Code field';
                    ApplicationArea = NPRRetail;
                }
                field(Description; Rec.Description)
                {

                    ToolTip = 'Specifies the value of the Description field';
                    ApplicationArea = NPRRetail;
                }
                field("Table No."; Rec."Table No.")
                {

                    ToolTip = 'Specifies the value of the Table No. field';
                    ApplicationArea = NPRRetail;
                }
                field(Filename; Rec.Filename)
                {

                    ToolTip = 'Specifies the value of the Filename field';
                    ApplicationArea = NPRRetail;
                }
                field(Subject; Rec.Subject)
                {

                    ToolTip = 'Specifies the value of the Subject field';
                    ApplicationArea = NPRRetail;
                }
                field("Verify Recipient"; Rec."Verify Recipient")
                {

                    ToolTip = 'Specifies the value of the Verify Recipient field';
                    ApplicationArea = NPRRetail;
                }
                field("Sender as bcc"; Rec."Sender as bcc")
                {

                    ToolTip = 'Specifies the value of the Sender as bcc field';
                    ApplicationArea = NPRRetail;
                }
                field("From E-mail Name"; Rec."From E-mail Name")
                {

                    ToolTip = 'Specifies the value of the From E-mail Name field';
                    ApplicationArea = NPRRetail;
                }
                field("From E-mail Address"; Rec."From E-mail Address")
                {

                    ToolTip = 'Specifies the value of the From E-mail Address field';
                    ApplicationArea = NPRRetail;
                }
                field("Default Recipient Address"; Rec."Default Recipient Address")
                {

                    ToolTip = 'Specifies the value of the Default recipient e-mail address field';
                    ApplicationArea = NPRRetail;
                }
                field("Default Recipient Address CC"; Rec."Default Recipient Address CC")
                {

                    ToolTip = 'Specifies the value of the Default recipient e-mail address (CC) field';
                    ApplicationArea = NPRRetail;
                }
                field("Default Recipient Address BCC"; Rec."Default Recipient Address BCC")
                {

                    ToolTip = 'Specifies the value of the Default recipient e-mail address (BCC) field';
                    ApplicationArea = NPRRetail;
                }
                field("Report ID"; Rec."Report ID")
                {

                    ToolTip = 'Specifies the value of the Report ID field';
                    ApplicationArea = NPRRetail;
                }
                group(Control6150644)
                {
                    ShowCaption = false;
                    Visible = (Rec."Transactional E-mail" = 0) OR (Rec."Transactional E-mail Code" = '');
                    field("Use HTML Template"; Rec."Use HTML Template")
                    {

                        ToolTip = 'Specifies the value of the Use HTML Template field';
                        ApplicationArea = NPRRetail;
                    }
                    field(HTMLTemplateHasValue; Format(Rec."HTML Template".HasValue))
                    {

                        AssistEdit = true;
                        Caption = 'HTML Template';
                        ToolTip = 'Specifies the value of the HTML Template field';
                        ApplicationArea = NPRRetail;

                        trigger OnAssistEdit()
                        var
                            MagentoFunctions: Codeunit "NPR Magento Functions";
                            TempBlob: Codeunit "Temp Blob";
                            OutStr: OutStream;
                            InStr: InStream;
                        begin
                            TempBlob.CreateOutStream(OutStr);
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
                    ApplicationArea = NPRRetail;
                }
                field("Fieldnumber End Tag"; Rec."Fieldnumber End Tag")
                {

                    Importance = Additional;
                    ToolTip = 'Specifies the value of the Fieldnumber End Tag field';
                    ApplicationArea = NPRRetail;
                }
                field(Group; Rec.Group)
                {

                    Importance = Additional;
                    ToolTip = 'Specifies the value of the Group field';
                    ApplicationArea = NPRRetail;
                }
                field("Transactional E-mail"; Rec."Transactional E-mail")
                {

                    Importance = Additional;
                    ToolTip = 'Specifies the value of the Transactional E-mail field';
                    ApplicationArea = NPRRetail;
                }
                group(Control6150643)
                {
                    ShowCaption = false;
                    Visible = (Rec."Transactional E-mail" = 1);
                    field("Transactional E-mail Code"; Rec."Transactional E-mail Code")
                    {

                        Importance = Additional;
                        ToolTip = 'Specifies the value of the Transactional E-mail Code field';
                        ApplicationArea = NPRRetail;
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
                ApplicationArea = NPRRetail;

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
                ApplicationArea = NPRRetail;

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
                Visible = (Rec."Transactional E-mail" = 0) OR (Rec."Transactional E-mail Code" = '');

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
                Visible = (Rec."Transactional E-mail" = 0) OR (Rec."Transactional E-mail Code" = '');

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
                Visible = (Rec."Transactional E-mail" = 0) OR (Rec."Transactional E-mail Code" = '');

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
                Visible = (Rec."Transactional E-mail" = 0) OR (Rec."Transactional E-mail Code" = '');

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
        area(navigation)
        {
            action(EmailLog)
            {
                Caption = 'E-mail Log';
                Image = ListPage;
                RunObject = Page "NPR E-mail Log";
                RunPageLink = "Table No." = FIELD("Table No.");
                RunPageView = SORTING("Entry No.");

                ToolTip = 'Executes the E-mail Log action';
                ApplicationArea = NPRRetail;
            }
            action(EmailTemplateFilters)
            {
                Caption = 'Email Template Filters';
                Image = UseFilters;
                RunObject = Page "NPR E-mail Templ. Filters";
                RunPageLink = "E-mail Template Code" = FIELD(Code),
                              "Table No." = FIELD("Table No.");
                RunPageView = SORTING("E-mail Template Code", "Table No.", "Line No.");

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
                    PAGE.Run(PAGE::"NPR E-mail Attachments", RetailAttachments);
                end;
            }
            action(AdditionalReports)
            {
                Caption = 'Additional Reports';
                Image = "Report";
                RunObject = Page "NPR E-mail Templ. Reports";
                RunPageLink = "E-mail Template Code" = FIELD(Code);

                ToolTip = 'Executes the Additional Reports action';
                ApplicationArea = NPRRetail;
            }
        }
    }
}

