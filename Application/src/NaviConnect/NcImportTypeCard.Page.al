page 6151509 "NPR Nc Import Type Card"
{
    Caption = 'Import Type Card';
    PageType = Card;
    UsageCategory = Administration;
    SourceTable = "NPR Nc Import Type";
    ApplicationArea = NPRNaviConnect;

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field("Code"; Rec.Code)
                {

                    ToolTip = 'Specifies the value of the Code field';
                    ApplicationArea = NPRNaviConnect;
                }
                field(Description; Rec.Description)
                {

                    ToolTip = 'Specifies the value of the Description field';
                    ApplicationArea = NPRNaviConnect;
                }
                field("Import List Update Handler"; Rec."Import List Update Handler")
                {

                    ToolTip = 'Specifies the update handler, which will be used for getting new entries into import list';
                    ApplicationArea = NPRNaviConnect;

                    trigger OnValidate()
                    begin
                        UpdateControls();
                    end;
                }
                field("Keep Import Entries for"; Rec."Keep Import Entries for")
                {

                    ToolTip = 'Specifies the value of the Keep Import Entries for field';
                    ApplicationArea = NPRNaviConnect;
                }
                field("Lookup Codeunit ID"; Rec."Lookup Codeunit ID")
                {

                    ToolTip = 'Specifies the value of the Lookup Codeunit ID field';
                    ApplicationArea = NPRNaviConnect;
                }
                field("Import Codeunit ID"; Rec."Import Codeunit ID")
                {

                    ToolTip = 'Specifies the value of the Import Codeunit ID field';
                    ApplicationArea = NPRNaviConnect;
                }
                field("Send e-mail on Error"; Rec."Send e-mail on Error")
                {

                    ToolTip = 'Specifies the value of the Send e-mail on Error field';
                    ApplicationArea = NPRNaviConnect;
                }
                field("E-mail address on Error"; Rec."E-mail address on Error")
                {

                    ToolTip = 'Specifies the value of the E-mail address on Error field';
                    ApplicationArea = NPRNaviConnect;
                }
                field("Max. Retry Count"; Rec."Max. Retry Count")
                {

                    ToolTip = 'Specifies the value of the Max. Retry Count field';
                    ApplicationArea = NPRNaviConnect;
                }
                field("Delay between Retries"; Rec."Delay between Retries")
                {

                    ToolTip = 'Specifies the value of the Delay between Retries field';
                    ApplicationArea = NPRNaviConnect;
                }
            }
            group(Transfer)
            {
                Caption = 'Transfer';
                group(API)
                {
                    Caption = 'API';
                    field("Webservice Enabled"; Rec."Webservice Enabled")
                    {

                        ToolTip = 'Specifies the value of the Webservice Enabled field';
                        ApplicationArea = NPRNaviConnect;
                    }
                    field("Webservice Codeunit ID"; Rec."Webservice Codeunit ID")
                    {

                        ToolTip = 'Specifies the value of the Webservice Codeunit ID field';
                        ApplicationArea = NPRNaviConnect;
                    }
                    field("Webservice Function"; Rec."Webservice Function")
                    {

                        ToolTip = 'Specifies the value of the Webservice Function field';
                        ApplicationArea = NPRNaviConnect;
                    }
                }
                group(Ftp)
                {
                    Caption = 'Ftp';
                    Enabled = Rec."Import List Update Handler" = Rec."Import List Update Handler"::Default;
                    Visible = Rec."Import List Update Handler" = Rec."Import List Update Handler"::Default;

                    field("Ftp Enabled"; Rec."Ftp Enabled")
                    {

                        ToolTip = 'Specifies the value of the Ftp Enabled field';
                        ApplicationArea = NPRNaviConnect;
                    }
                    field(Sftp; Rec.Sftp)
                    {

                        ToolTip = 'Specifies the value of the Sftp field';
                        ApplicationArea = NPRNaviConnect;
                    }
                    field("Ftp Host"; Rec."Ftp Host")
                    {

                        ToolTip = 'Specifies the value of the Ftp Host field';
                        ApplicationArea = NPRNaviConnect;
                    }
                    field("Ftp Port"; Rec."Ftp Port")
                    {

                        ToolTip = 'Specifies the value of the Ftp Port field';
                        ApplicationArea = NPRNaviConnect;
                    }
                    field("Ftp Binary"; Rec."Ftp Binary")
                    {

                        ToolTip = 'Specifies the value of the Ftp Binary field';
                        ApplicationArea = NPRNaviConnect;
                    }
                    field("Ftp User"; Rec."Ftp User")
                    {

                        ToolTip = 'Specifies the value of the Ftp User field';
                        ApplicationArea = NPRNaviConnect;
                    }
                    field("Ftp Password"; Rec."Ftp Password")
                    {

                        ToolTip = 'Specifies the value of the Ftp Password field';
                        ApplicationArea = NPRNaviConnect;
                    }
                    field("Ftp Passive"; Rec."Ftp Passive")
                    {

                        ToolTip = 'Specifies the value of the Ftp Passive field';
                        ApplicationArea = NPRNaviConnect;
                    }
                    field("FTP Encryption mode"; Rec."Ftp EncMode")
                    {
                        ToolTip = 'Specifies which mode of encryption is used between client and server';
                        ApplicationArea = NPRRetail;
                    }
                    field("Ftp Path"; Rec."Ftp Path")
                    {

                        ToolTip = 'Specifies the value of the Ftp Path field';
                        ApplicationArea = NPRNaviConnect;
                    }
                    field("Ftp Backup Path"; Rec."Ftp Backup Path")
                    {

                        ToolTip = 'Specifies the value of the Ftp Backup Path field';
                        ApplicationArea = NPRNaviConnect;
                    }
                    field("Ftp Filename"; Rec."Ftp Filename")
                    {

                        ToolTip = 'Specifies the value of the Ftp Filename field';
                        ApplicationArea = NPRNaviConnect;
                    }
                }
            }
            group("XML Stylesheet")
            {
                Caption = 'XML Stylesheet';
                field(XMLStylesheetData; XMLStylesheetData)
                {

                    MultiLine = true;
                    ShowCaption = false;
                    ToolTip = 'Specifies the value of the XMLStylesheetData field';
                    ApplicationArea = NPRNaviConnect;

                    trigger OnValidate()
                    begin
                        if Rec."XML Stylesheet".HasValue() then begin
                            Rec.CalcFields("XML Stylesheet");
                            Clear(Rec."XML Stylesheet");
                            Rec.Modify(false);
                        end;

                        if XMLStylesheetData <> '' then begin
                            Request.AddText(XMLStylesheetData);
                            Rec."XML Stylesheet".CreateOutStream(OStream);
                            Request.Write(OStream);
                            Rec.Modify(false);
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
                Caption = 'Update Handler Setup Page';
                Image = Setup;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Visible = not IsDefaultUpdateHandler;

                ToolTip = 'Shows setup page for the update handler, which will be used for getting new entries into import list';
                ApplicationArea = NPRNaviConnect;

                trigger OnAction()
                var
                    NcDependencyFactory: Codeunit "NPR Nc Dependency Factory";
                    ImportListUpdater: Interface "NPR Nc Import List IUpdate";
                begin
                    if NcDependencyFactory.CreateNcImportListUpdater(ImportListUpdater, Rec) then
                        ImportListUpdater.ShowSetup(Rec);
                end;
            }
            action(SetupJobQueue)
            {
                Caption = 'Setup Job Queue';
                Image = Setup;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ToolTip = 'Sets up a Job Queue Entry to automate creation and processing of import list entries of selected import type';
                ApplicationArea = NPRNaviConnect;

                trigger OnAction()
                var
                    JobQueueEntry: Record "Job Queue Entry";
                    JobQueueMgt: Codeunit "NPR Job Queue Management";
                begin
                    CurrPage.SaveRecord();
                    JobQueueMgt.ScheduleNcImportListProcessing(JobQueueEntry, Rec.Code, '');
                    if not IsNullGuid(JobQueueEntry.ID) then
                        Page.Run(Page::"Job Queue Entry Card", JobQueueEntry);
                end;
            }
            action("Download Ftp")
            {
                Caption = 'Download Ftp';
                Image = Start;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Visible = Rec."Ftp Enabled";

                ToolTip = 'Executes the Download Ftp action';
                ApplicationArea = NPRNaviConnect;

                trigger OnAction()
                var
                    NcSyncMgt: Codeunit "NPR Nc Sync. Mgt.";
                begin
                    NcSyncMgt.DownloadFtpType(Rec);
                end;
            }
            action("Download XML Stylesheet")
            {
                Caption = 'Download XML Stylesheet';
                Image = ImportDatabase;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ApplicationArea = NPRNaviConnect;
                Enabled = Rec.Code <> '';
                ToolTip = 'Executes the Download XML Stylesheet from Azure Blob Storage action';

                trigger OnAction()
                var
                    XmlStylesheetDeoployFromAzure: Page "NPR Nc XML Styl. Dep. From Az.";
                begin
                    XmlStylesheetDeoployFromAzure.Initialize(Rec.Code);
                    XmlStylesheetDeoployFromAzure.Run();
                end;
            }
            action(SendTestErrorMail)
            {
                Caption = 'Send Test Error E-mail';
                Image = SendMail;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Visible = (Rec."Send E-mail on Error");
                ToolTip = 'Executes the Send Test Error E-mail action';
                ApplicationArea = NPRNaviConnect;

                trigger OnAction()
                var
                    NcImportMgt: Codeunit "NPR Nc Import Mgt.";
                begin
                    NcImportMgt.SendTestErrorMail(Rec);
                end;
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    begin
        Rec.CalcFields("XML Stylesheet");

        if not Rec."XML Stylesheet".HasValue() then
            XMLStylesheetData := ''
        else begin
            Rec."XML Stylesheet".CreateInStream(IStream);
            IStream.Read(XMLStylesheetData, MaxStrLen(XMLStylesheetData));
        end;

        UpdateControls();
    end;

    trigger OnOpenPage()
    begin
        UpdateControls();
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        UpdateControls();
    end;

    local procedure UpdateControls()
    begin
        IsDefaultUpdateHandler := Rec."Import List Update Handler" = Rec."Import List Update Handler"::Default;
    end;

    var
        XMLStylesheetData: Text;
        IStream: InStream;
        OStream: OutStream;
        Request: BigText;
        IsDefaultUpdateHandler: Boolean;
}
