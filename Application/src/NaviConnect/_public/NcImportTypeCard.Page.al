page 6151509 "NPR Nc Import Type Card"
{
    Extensible = true;
    Caption = 'Import Type Card';
    PageType = Card;
    UsageCategory = None;
    SourceTable = "NPR Nc Import Type";

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
                field("Import List Lookup Handler"; Rec."Import List Lookup Handler")
                {
                    ToolTip = 'Specifies the process handler, which will be used to lookup created entries.';
                    ApplicationArea = NPRNaviConnect;
                    trigger OnValidate()
                    begin
                        UpdateControls();
                    end;
                }
                group(LookupCodeunit)
                {
                    ShowCaption = false;
                    Visible = IsDefaultLookupHandler;
                    field("Lookup Codeunit ID"; Rec."Lookup Codeunit ID")
                    {

                        ToolTip = 'Specifies the value of the Lookup Codeunit ID field';
                        ApplicationArea = NPRNaviConnect;
                    }
                }
                field("Import List Process Handler"; Rec."Import List Process Handler")
                {
                    ToolTip = 'Specifies the process handler, which will be used to process the import list entry.';
                    ApplicationArea = NPRNaviConnect;
                    trigger OnValidate()
                    begin
                        UpdateControls();
                    end;
                }
                group(ImportCodeunit)
                {
                    ShowCaption = false;
                    Visible = IsDefaultProcessHandler;
                    field("Import Codeunit ID"; Rec."Import Codeunit ID")
                    {
                        ToolTip = 'Specifies the value of the Import Codeunit ID field';
                        ApplicationArea = NPRNaviConnect;
                    }
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

                    ToolTip = 'Specifies how many times the system should automatically try to reprocess the ''Import Entries''. For each run, the ''Import Count'' field on the ''Import Entry'' is incresed by one. For the ''Import Entries'' with processing errors, if needed, the latter can be reset by creating a ''Import List Processing Job Queue Entry'' with parameter ''reset_retry_count'' that runs, for example, once per night. The result in this case will be that the system will reschedule these entries for processing.';
                    ApplicationArea = NPRNaviConnect;
                }
                field("Delay between Retries"; Rec."Delay between Retries")
                {

                    ToolTip = 'Specifies the value of the Delay between Retries field';
                    ApplicationArea = NPRNaviConnect;
                }
                field(Actionable; Rec.Actionable)
                {
                    ToolTip = 'Specifies if Import Entries of this type is actionable, meaning that a user can take action and retry the import';
                    ApplicationArea = NPRNaviConnect;
                    Visible = false;
                }
                field("Background Session Reschedule"; Rec."Background Session Reschedule")
                {
                    ToolTip = 'Failed import entries can be rescheduled manually by using the action ''Reschedule Selected for Import'' or automatically by setting up the ''Max. Retry Count'' on the ''Import Type''. Normally, the reschedule is done in the user session or when the Job Queue picks up again the import entry to reprocess it. By enabling this setting, the reschedule is done in a new background session';
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
                    field("FTP Connection"; Rec."FTP Connection")
                    {

                        ToolTip = 'Specifies a FTP Connection. If one is selected, this connection will take priority over the FTP connection fields on this page.';
                        ApplicationArea = NPRNaviConnect;
                        Enabled = Rec."Ftp Enabled";
                    }
                    field("Sftp Enabled"; Rec."Sftp Enabled")
                    {

                        ToolTip = 'Specifies the value of the Ftp Enabled field';
                        ApplicationArea = NPRNaviConnect;
                    }
                    field("SFTP Connection"; Rec."SFTP Connection")
                    {

                        ToolTip = 'Specifies a SFTP Connection. If one is selected, this connection will take priority over the SFTP connection fields on this page.';
                        ApplicationArea = NPRNaviConnect;
                        Enabled = Rec."Sftp Enabled";
                    }
                    field("Ftp Path"; Rec."Ftp Path")
                    {

                        ToolTip = 'Specifies the absolute directory path where the file(s) to be downloaded exists.';
                        ApplicationArea = NPRNaviConnect;

                        trigger OnValidate()
                        begin
                            Rec."Ftp Path" := CopyStr(Rec."Ftp Path".Replace('\', '/'), 1, 250);
                            if (not Rec."Ftp Path".StartsWith('/')) then
                                Rec."Ftp Path" := CopyStr('/' + Rec."Ftp Path", 1, 250);
                            if (not Rec."Ftp Path".EndsWith('/')) then
                                Rec."Ftp Path" := CopyStr(Rec."Ftp Path" + '/', 1, 250);
                            Rec.Modify(False);
                        end;
                    }
                    field("Ftp Filename"; Rec."Ftp Filename")
                    {

                        ToolTip = 'Specifies the name of the file to be downloaded.';
                        ApplicationArea = NPRNaviConnect;
                    }
                    field("Ftp Backup Dir Path"; Rec."Ftp Backup Dir Path")
                    {

                        ToolTip = 'Specifies the absolute path of the backup directory. If specified files downloaded will not be deleted but moved to /"Backup Dir Path"/Filename';
                        ApplicationArea = NPRNaviConnect;

                        trigger OnValidate()
                        begin
                            if (Rec."Ftp Backup Dir Path" = '') then exit;
                            Rec."Ftp Backup Dir Path" := CopyStr(Rec."Ftp Backup Dir Path".Replace('\', '/'), 1, 250);
                            if (not Rec."Ftp Backup Dir Path".StartsWith('/')) then
                                Rec."Ftp Backup Dir Path" := CopyStr('/' + Rec."Ftp Backup Dir Path", 1, 250);
                            if (not Rec."Ftp Backup Dir Path".EndsWith('/')) then
                                Rec."Ftp Backup Dir Path" := CopyStr(Rec."Ftp Backup Dir Path" + '/', 1, 250);
                            Rec.Modify(False);
                        end;
                    }
                    field("Ftp Backup Path"; Rec."Ftp Backup Path")
                    {

                        ToolTip = 'Specifies the value of the Ftp Backup Path field';
                        ApplicationArea = NPRNaviConnect;
                        ObsoleteState = Pending;
                        ObsoleteTag = '2023-06-28';
                        ObsoleteReason = 'Using "FTP Backup Dir Path"';
                        Visible = false;
                    }
                    field("Ftp Host"; Rec."Ftp Host")
                    {

                        ToolTip = 'Specifies the value of the Ftp Host field';
                        ApplicationArea = NPRNaviConnect;
                        ObsoleteState = Pending;
                        ObsoleteTag = '2023-06-28';
                        ObsoleteReason = 'Using Sftp and Ftp connections instead.';
                        Visible = false;
                    }
                    field("Ftp Port"; Rec."Ftp Port")
                    {

                        ToolTip = 'Specifies the value of the Ftp Port field';
                        ApplicationArea = NPRNaviConnect;
                        ObsoleteState = Pending;
                        ObsoleteTag = '2023-06-28';
                        ObsoleteReason = 'Using Sftp and Ftp connections instead.';
                        Visible = false;
                    }
                    field("Ftp Binary"; Rec."Ftp Binary")
                    {

                        ToolTip = 'Specifies the value of the Ftp Binary field';
                        ApplicationArea = NPRNaviConnect;
                        ObsoleteState = Pending;
                        ObsoleteTag = '2023-06-28';
                        ObsoleteReason = 'Using Sftp and Ftp connections instead.';
                        Visible = false;
                    }
                    field("Ftp User"; Rec."Ftp User")
                    {

                        ToolTip = 'Specifies the value of the Ftp User field';
                        ApplicationArea = NPRNaviConnect;
                        ObsoleteState = Pending;
                        ObsoleteTag = '2023-06-28';
                        ObsoleteReason = 'Using Sftp and Ftp connections instead.';
                        Visible = false;
                    }
                    field("Ftp Password"; Rec."Ftp Password")
                    {

                        ToolTip = 'Specifies the value of the Ftp Password field';
                        ApplicationArea = NPRNaviConnect;
                        ObsoleteState = Pending;
                        ObsoleteTag = '2023-06-28';
                        ObsoleteReason = 'Using Sftp and Ftp connections instead.';
                        Visible = false;
                    }
                    field("Ftp Passive"; Rec."Ftp Passive")
                    {

                        ToolTip = 'Specifies the value of the Ftp Passive field';
                        ApplicationArea = NPRNaviConnect;
                        ObsoleteState = Pending;
                        ObsoleteTag = '2023-06-28';
                        ObsoleteReason = 'Using Sftp and Ftp connections instead.';
                        Visible = false;
                    }
                    field("FTP Encryption mode"; Rec."Ftp EncMode")
                    {
                        ToolTip = 'Specifies which mode of encryption is used between client and server';
                        ApplicationArea = NPRRetail;
                        ObsoleteState = Pending;
                        ObsoleteTag = '2023-06-28';
                        ObsoleteReason = 'Using Sftp and Ftp connections instead.';
                        Visible = false;
                    }
                    field(Sftp; Rec.Sftp)
                    {

                        ToolTip = 'Specifies the value of the Sftp field';
                        ApplicationArea = NPRNaviConnect;
                        ObsoleteState = Pending;
                        ObsoleteTag = '2023-06-28';
                        ObsoleteReason = 'Using Sftp and Ftp connections instead.';
                        Visible = false;

                    }
                }
            }
            group("XML Stylesheet")
            {
                Caption = 'XML Stylesheet';
                ObsoleteState = Pending;
                ObsoleteTag = '2023-06-28';
                ObsoleteReason = 'Field XML Stylesheet is not used anymore.';
                Visible = false;
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
                    JobQueueMgt.SetProtected(true);
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
                Visible = (Rec."Ftp Enabled" or Rec."Sftp Enabled");

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
        IsDefaultProcessHandler := Rec."Import List Process Handler" = Rec."Import List Process Handler"::Default;
        IsDefaultLookupHandler := Rec."Import List Lookup Handler" = Rec."Import List Lookup Handler"::Default;
    end;

    var
        XMLStylesheetData: Text;
        IStream: InStream;
        OStream: OutStream;
        Request: BigText;
        IsDefaultUpdateHandler: Boolean;
        IsDefaultProcessHandler: Boolean;
        IsDefaultLookupHandler: Boolean;
}
