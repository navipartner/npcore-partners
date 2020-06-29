page 6059791 "E-mail Template"
{
    // PN1.00/MH/20140730  NAV-AddOn: PDF2NAV
    //   - Refactored module from the "Mail And Document Handler" Module.
    //   - This Page Contains E-mail Templates used for sending E-mail using PDF2NAV.
    // PN1.01/MH/20140731  NAV-AddOn: PDF2NAV
    //   - Added Action Item: AdditionalReports.
    // PN1.06/LS/20150525  CASE 205029  Added fields "Cc Recipient Address" & "Bcc Recipient Address"
    // PN1.07/TTH/20151005 CASE 222376 Adding the possibility to use HTML Template
    // PN1.08/MHA/20151214  CASE 228859 Pdf2Nav(New Version List)
    // PN1.10/MHA/20160314 CASE 236653 "Report Format"(Word) deleted
    // NPR5.36/THRO/20170913  CASE 289216 Added Group.
    // NPR5.38/THRO/20180108  CASE 286713 Added Transaction E-mail fields + hide Html + Line if TransEmail is used
    // NPR5.41/TS  /20180105  CASE 300893 Removed Caption on ActionContainer
    // NPR5.43/THRO/20180626  CASE 318935 Added "Fieldnumber Start Tag" + "Fieldnumber End Tag"
    // NPR5.48/MHA /20190123  CASE 341711 Added Html Template Functions

    Caption = 'E-mail Template';
    SourceTable = "E-mail Template Header";

    layout
    {
        area(content)
        {
            group(Generelt)
            {
                field("Code"; Code)
                {
                    Style = Standard;
                    StyleExpr = TRUE;
                }
                field(Description; Description)
                {
                }
                field("Table No."; "Table No.")
                {
                }
                field(Filename; Filename)
                {
                }
                field(Subject; Subject)
                {
                }
                field("Verify Recipient"; "Verify Recipient")
                {
                }
                field("Sender as bcc"; "Sender as bcc")
                {
                }
                field("From E-mail Name"; "From E-mail Name")
                {
                }
                field("From E-mail Address"; "From E-mail Address")
                {
                }
                field("Default Recipient Address"; "Default Recipient Address")
                {
                }
                field("Default Recipient Address CC"; "Default Recipient Address CC")
                {
                }
                field("Default Recipient Address BCC"; "Default Recipient Address BCC")
                {
                }
                field("Report ID"; "Report ID")
                {
                }
                group(Control6150644)
                {
                    ShowCaption = false;
                    Visible = ("Transactional E-mail" = 0) OR ("Transactional E-mail Code" = '');
                    field("Use HTML Template"; "Use HTML Template")
                    {
                    }
                    field("FORMAT(""HTML Template"".HASVALUE)"; Format("HTML Template".HasValue))
                    {
                        AssistEdit = true;
                        Caption = 'HTML Template';

                        trigger OnAssistEdit()
                        var
                            TextEditorPage: Page "E-mail Text Editor Dialog";
                            TempBlob: Codeunit "Temp Blob";
                            HtmlText: Text;
                            Instream: InStream;
                            Outstream: OutStream;
                        begin
                            //-PN1.07
                            Clear(TextEditorPage);
                            CalcFields("HTML Template");
                            HtmlText := '';
                            //-NPR5.48 [341711]
                            //"HTML Template".CREATEINSTREAM(Instream);
                            "HTML Template".CreateInStream(Instream, TEXTENCODING::UTF8);
                            //+NPR5.48 [341711]
                            Instream.ReadText(HtmlText);
                            if TextEditorPage.EditText(HtmlText) then begin
                                Clear("HTML Template");
                                //-NPR5.48 [341711]
                                //"HTML Template".CREATEOUTSTREAM(Outstream);
                                "HTML Template".CreateOutStream(Outstream, TEXTENCODING::UTF8);
                                //+NPR5.48 [341711]
                                Outstream.WriteText(HtmlText);
                                Modify;
                            end;
                            //+PN1.07
                        end;
                    }
                }
                field("Fieldnumber Start Tag"; "Fieldnumber Start Tag")
                {
                    Importance = Additional;
                }
                field("Fieldnumber End Tag"; "Fieldnumber End Tag")
                {
                    Importance = Additional;
                }
                field(Group; Group)
                {
                    Importance = Additional;
                }
                field("Transactional E-mail"; "Transactional E-mail")
                {
                    Importance = Additional;

                    trigger OnValidate()
                    begin
                        //-NPR5.48 [341711]
                        ////-NPR5.38 [286713]
                        //SetTransactionalType;
                        ////+NPR5.38 [286713]
                        //+NPR5.48 [341711]
                    end;
                }
                group(Control6150643)
                {
                    ShowCaption = false;
                    Visible = ("Transactional E-mail" = 1);
                    field("Transactional E-mail Code"; "Transactional E-mail Code")
                    {
                        Importance = Additional;

                        trigger OnValidate()
                        begin
                            //-NPR5.48 [341711]
                            ////-NPR5.38 [286713]
                            //SetTransactionalType;
                            ////+NPR5.38 [286713]
                            //+NPR5.48 [341711]
                        end;
                    }
                }
            }
            part("Mail line"; "E-mail Template Subform")
            {
                Caption = 'Mail line';
                ShowFilter = false;
                SubPageLink = "E-mail Template Code" = FIELD(Code);
                SubPageView = SORTING("E-mail Template Code", "Line No.");
                Visible = ("Transactional E-mail" = 0) OR ("Transactional E-mail Code" = '');
            }
        }
        area(factboxes)
        {
            part("Fields"; "E-mail Field List")
            {
                Caption = 'Fields';
                ShowFilter = false;
                SubPageLink = TableNo = FIELD("Table No.");
                SubPageView = SORTING(TableNo, "No.");
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

                trigger OnAction()
                var
                    EmailTemplateMgt: Codeunit "E-mail Template Mgt.";
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

                trigger OnAction()
                var
                    EmailTemplateMgt: Codeunit "E-mail Template Mgt.";
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

                trigger OnAction()
                var
                    EmailTemplateMgt: Codeunit "E-mail Template Mgt.";
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

                trigger OnAction()
                var
                    EmailTemplateMgt: Codeunit "E-mail Template Mgt.";
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

                trigger OnAction()
                var
                    EmailTemplateMgt: Codeunit "E-mail Template Mgt.";
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

                trigger OnAction()
                var
                    EmailTemplateMgt: Codeunit "E-mail Template Mgt.";
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
                RunObject = Page "E-mail Log";
                RunPageLink = "Table No." = FIELD("Table No.");
                RunPageView = SORTING("Entry No.");
            }
            action(EmailTemplateFilters)
            {
                Caption = 'Email Template Filters';
                Image = UseFilters;
                RunObject = Page "E-mail Template Filters";
                RunPageLink = "E-mail Template Code" = FIELD(Code),
                              "Table No." = FIELD("Table No.");
                RunPageView = SORTING("E-mail Template Code", "Table No.", "Line No.");
            }
            action(AttachedFiles)
            {
                Caption = 'Attached Files';
                Image = MailAttachment;

                trigger OnAction()
                var
                    RecRef: RecordRef;
                    RetailAttachments: Record "E-mail Attachment";
                begin
                    RecRef.GetTable(Rec);
                    Clear(RetailAttachments);
                    RetailAttachments.SetRange("Table No.", RecRef.Number);
                    RetailAttachments.SetRange("Primary Key", RecRef.GetPosition(false));
                    PAGE.Run(PAGE::"E-mail Attachments", RetailAttachments);
                end;
            }
            action(AdditionalReports)
            {
                Caption = 'Additional Reports';
                Image = "Report";
                RunObject = Page "E-mail Template Reports";
                RunPageLink = "E-mail Template Code" = FIELD(Code);
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    begin
        //-NPR5.48 [341711]
        ////-NPR5.38 [286713]
        //SetTransactionalType;
        ////+NPR5.38 [286713]
        //+NPR5.48 [341711]
    end;

    var
        Text000: Label 'Export failed';
        Text001: Label 'All values on %1 will be replaced with values from %2';
        Text002: Label 'Do you want to delete the HTML Template?';
}

