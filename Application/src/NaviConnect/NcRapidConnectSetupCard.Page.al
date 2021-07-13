page 6151090 "NPR Nc RapidConnect Setup Card"
{
    UsageCategory = None;
    Caption = 'RapidConnect Setup';
    SourceTable = "NPR Nc RapidConnect Setup";

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
                field("Package Code"; Rec."Package Code")
                {

                    Importance = Promoted;
                    ShowMandatory = true;
                    ToolTip = 'Specifies the value of the Package Code field';
                    ApplicationArea = NPRNaviConnect;
                }
            }
            group(Export)
            {
                Caption = 'Export';
                group(Control6151431)
                {
                    ShowCaption = false;
                    field("Export Enabled"; Rec."Export Enabled")
                    {

                        Importance = Promoted;
                        ToolTip = 'Specifies the value of the Export Enabled field';
                        ApplicationArea = NPRNaviConnect;
                    }
                    field("Task Processor Code"; Rec."Task Processor Code")
                    {

                        Importance = Promoted;
                        ToolTip = 'Specifies the value of the Task Processor Code field';
                        ApplicationArea = NPRNaviConnect;
                    }
                    field("Export File Type"; Rec."Export File Type")
                    {

                        ToolTip = 'Specifies the value of the Export File Type field';
                        ApplicationArea = NPRNaviConnect;
                    }
                }
                group(Control6151414)
                {
                    ShowCaption = false;
                    part(Control6151411; "NPR Nc RapidConnect Subform")
                    {
                        SubPageLink = "Setup Code" = FIELD(Code);
                        ApplicationArea = NPRNaviConnect;

                    }
                    part(Control6151416; "NPR Nc RapidConnect Endp. Sub.")
                    {
                        SubPageLink = "Setup Code" = FIELD(Code);
                        ApplicationArea = NPRNaviConnect;

                    }
                }
            }
            group(Import)
            {
                Caption = 'Import';
                field("Import Enabled"; Rec."Import Enabled")
                {

                    Importance = Promoted;
                    ToolTip = 'Specifies the value of the Import Enabled field';
                    ApplicationArea = NPRNaviConnect;
                }
                field("Import Type"; Rec."Import Type")
                {

                    ToolTip = 'Specifies the value of the Import Type field';
                    ApplicationArea = NPRNaviConnect;
                }
                field("Validate Package"; Rec."Validate Package")
                {

                    ToolTip = 'Specifies the value of the Validate Package field';
                    ApplicationArea = NPRNaviConnect;
                }
                field("Apply Package"; Rec."Apply Package")
                {

                    ToolTip = 'Specifies the value of the Apply Package field';
                    ApplicationArea = NPRNaviConnect;
                }
                field("Disable Data Log on Import"; Rec."Disable Data Log on Import")
                {

                    ToolTip = 'Specifies the value of the Disable Data Log on Import field';
                    ApplicationArea = NPRNaviConnect;
                }
                group("Download from")
                {
                    Caption = 'Download from';
                    field("Ftp Host"; Rec."Ftp Host")
                    {

                        Importance = Promoted;
                        ToolTip = 'Specifies the value of the Ftp Host field';
                        ApplicationArea = NPRNaviConnect;
                    }
                    field("Ftp Port"; Rec."Ftp Port")
                    {

                        ToolTip = 'Specifies the value of the Ftp Port field';
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
                    field("Ftp Binary"; Rec."Ftp Binary")
                    {

                        ToolTip = 'Specifies the value of the Ftp Binary field';
                        ApplicationArea = NPRNaviConnect;
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
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            group(ExportActionGroup)
            {
                Caption = 'Export';
                action("Init Export Triggers")
                {
                    Caption = 'Init Export Triggers';
                    Image = "Action";

                    ToolTip = 'Executes the Init Export Triggers action';
                    ApplicationArea = NPRNaviConnect;

                    trigger OnAction()
                    var
                        NcRapidConnectSetupMgt: Codeunit "NPR Nc RapidConnect Setup Mgt.";
                    begin
                        NcRapidConnectSetupMgt.InitExportTriggers(Rec);
                    end;
                }
            }
            group(ImportActionGroup)
            {
                Caption = 'Import';
                action("Download Ftp")
                {
                    Caption = 'Download Ftp';
                    Image = Delegate;
                    Visible = Rec."Import Enabled";

                    ToolTip = 'Executes the Download Ftp action';
                    ApplicationArea = NPRNaviConnect;

                    trigger OnAction()
                    var
                        NcImportType: Record "NPR Nc Import Type";
                        NcSyncMgt: Codeunit "NPR Nc Sync. Mgt.";
                    begin
                        NcImportType.Get(Rec."Import Type");
                        NcSyncMgt.DownloadFtpType(NcImportType);
                    end;
                }
            }
        }
    }
}

