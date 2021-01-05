page 6151509 "NPR Nc Import Type Card"
{
    Caption = 'Import Type Card';
    PageType = Card;
    UsageCategory = Administration;
    SourceTable = "NPR Nc Import Type";

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
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
                field("Import List Update Handler"; "Import List Update Handler")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the update handler, which will be used for getting new entries into import list';
                }
                field("Keep Import Entries for"; "Keep Import Entries for")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Keep Import Entries for field';
                }
                field("Lookup Codeunit ID"; "Lookup Codeunit ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Lookup Codeunit ID field';
                }
                field("Import Codeunit ID"; "Import Codeunit ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Import Codeunit ID field';
                }
                field("Send e-mail on Error"; "Send e-mail on Error")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Send e-mail on Error field';
                }
                field("E-mail address on Error"; "E-mail address on Error")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the E-mail address on Error field';
                }
                field("Max. Retry Count"; "Max. Retry Count")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Max. Retry Count field';
                }
                field("Delay between Retries"; "Delay between Retries")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Delay between Retries field';
                }
            }
            group(Transfer)
            {
                Caption = 'Transfer';
                group(API)
                {
                    Caption = 'API';
                    field("Webservice Enabled"; "Webservice Enabled")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Webservice Enabled field';
                    }
                    field("Webservice Codeunit ID"; "Webservice Codeunit ID")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Webservice Codeunit ID field';
                    }
                    field("Webservice Function"; "Webservice Function")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Webservice Function field';
                    }
                }
                group(Ftp)
                {
                    Caption = 'Ftp';
                    Enabled = "Import List Update Handler" = "Import List Update Handler"::Default;
                    Visible = "Import List Update Handler" = "Import List Update Handler"::Default;

                    field("Ftp Enabled"; "Ftp Enabled")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Ftp Enabled field';
                    }
                    field(Sftp; Sftp)
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Sftp field';
                    }
                    field("Ftp Host"; "Ftp Host")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Ftp Host field';
                    }
                    field("Ftp Port"; "Ftp Port")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Ftp Port field';
                    }
                    field("Ftp Binary"; "Ftp Binary")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Ftp Binary field';
                    }
                    field("Ftp User"; "Ftp User")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Ftp User field';
                    }
                    field("Ftp Password"; "Ftp Password")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Ftp Password field';
                    }
                    field("Ftp Passive"; "Ftp Passive")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Ftp Passive field';
                    }
                    field("Ftp Path"; "Ftp Path")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Ftp Path field';
                    }
                    field("Ftp Backup Path"; "Ftp Backup Path")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Ftp Backup Path field';
                    }
                    field("Ftp Filename"; "Ftp Filename")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Ftp Filename field';
                    }
                }
                group("File")
                {
                    Caption = 'File';
                    Enabled = "Import List Update Handler" = "Import List Update Handler"::Default;
                    Visible = "Import List Update Handler" = "Import List Update Handler"::Default;

                    field("Server File Enabled"; "Server File Enabled")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Server File Enabled field';
                    }
                    field("Server File Path"; "Server File Path")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Server File Path field';
                    }
                }
            }
            group("XML Stylesheet")
            {
                Caption = 'XML Stylesheet';
                field(XMLStylesheetData; XMLStylesheetData)
                {
                    ApplicationArea = All;
                    MultiLine = true;
                    ShowCaption = false;
                    ToolTip = 'Specifies the value of the XMLStylesheetData field';

                    trigger OnValidate()
                    begin
                        if "XML Stylesheet".HasValue then begin
                            CalcFields("XML Stylesheet");
                            Clear("XML Stylesheet");
                            Modify(false);
                        end;

                        if XMLStylesheetData <> '' then begin
                            Request.AddText(XMLStylesheetData);
                            "XML Stylesheet".CreateOutStream(OStream);
                            Request.Write(OStream);
                            Modify(false);
                        end;
                    end;
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(ShowSetup)
            {
                Caption = 'Show Setup Page';
                Image = Setup;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                ApplicationArea = All;
                ToolTip = 'Shows setup page for the update handler, which will be used for getting new entries into import list';

                trigger OnAction()
                var
                    NcDependencyFactory: Codeunit "NPR Nc Dependency Factory";
                    ImportListUpdater: Interface "NPR Nc Import List IUpdate";
                begin
                    if NcDependencyFactory.CreateNcImportListUpdater(ImportListUpdater, Rec) then
                        ImportListUpdater.ShowSetup(Rec);
                end;
            }
            action("Download Ftp")
            {
                Caption = 'Download Ftp';
                Image = Start;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Visible = "Ftp Enabled";
                ApplicationArea = All;
                ToolTip = 'Executes the Download Ftp action';

                trigger OnAction()
                var
                    NcSyncMgt: Codeunit "NPR Nc Sync. Mgt.";
                begin
                    NcSyncMgt.DownloadFtpType(Rec);
                end;
            }
            action("Download Server File")
            {
                Caption = 'Download Server File';
                Image = Save;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Visible = "Server File Enabled";
                ApplicationArea = All;
                ToolTip = 'Executes the Download Server File action';

                trigger OnAction()
                var
                    NcSyncMgt: Codeunit "NPR Nc Sync. Mgt.";
                begin
                    NcSyncMgt.DownloadServerFile(Rec);
                end;
            }
            action(SendTestErrorMail)
            {
                Caption = 'Send Test Error E-mail';
                Image = SendMail;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Visible = ("Send E-mail on Error");
                ApplicationArea = All;
                ToolTip = 'Executes the Send Test Error E-mail action';

                trigger OnAction()
                var
                    TempNcImportEntry: Record "NPR Nc Import Entry" temporary;
                    NcImportMgt: Codeunit "NPR Nc Import Mgt.";
                begin
                    NcImportMgt.SendTestErrorMail(Rec);
                end;
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        CalcFields("XML Stylesheet");

        if not "XML Stylesheet".HasValue then
            XMLStylesheetData := ''
        else begin
            "XML Stylesheet".CreateInStream(IStream);
            IStream.Read(XMLStylesheetData, MaxStrLen(XMLStylesheetData));
        end;
    end;

    var
        XMLStylesheetData: Text;
        IStream: InStream;
        OStream: OutStream;
        Request: BigText;
}