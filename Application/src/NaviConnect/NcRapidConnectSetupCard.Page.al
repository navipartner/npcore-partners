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
                field("Code"; Rec.Code)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Code field';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field';
                }
                field("Package Code"; Rec."Package Code")
                {
                    ApplicationArea = All;
                    Importance = Promoted;
                    ShowMandatory = true;
                    ToolTip = 'Specifies the value of the Package Code field';
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
                        ApplicationArea = All;
                        Importance = Promoted;
                        ToolTip = 'Specifies the value of the Export Enabled field';
                    }
                    field("Task Processor Code"; Rec."Task Processor Code")
                    {
                        ApplicationArea = All;
                        Importance = Promoted;
                        ToolTip = 'Specifies the value of the Task Processor Code field';
                    }
                    field("Export File Type"; Rec."Export File Type")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Export File Type field';
                    }
                }
                group(Control6151414)
                {
                    ShowCaption = false;
                    part(Control6151411; "NPR Nc RapidConnect Subform")
                    {
                        SubPageLink = "Setup Code" = FIELD(Code);
                        ApplicationArea = All;
                    }
                    part(Control6151416; "NPR Nc RapidConnect Endp. Sub.")
                    {
                        SubPageLink = "Setup Code" = FIELD(Code);
                        ApplicationArea = All;
                    }
                }
            }
            group(Import)
            {
                Caption = 'Import';
                field("Import Enabled"; Rec."Import Enabled")
                {
                    ApplicationArea = All;
                    Importance = Promoted;
                    ToolTip = 'Specifies the value of the Import Enabled field';
                }
                field("Import Type"; Rec."Import Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Import Type field';
                }
                field("Validate Package"; Rec."Validate Package")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Validate Package field';
                }
                field("Apply Package"; Rec."Apply Package")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Apply Package field';
                }
                field("Disable Data Log on Import"; Rec."Disable Data Log on Import")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Disable Data Log on Import field';
                }
                group("Download from")
                {
                    Caption = 'Download from';
                    field("Ftp Host"; Rec."Ftp Host")
                    {
                        ApplicationArea = All;
                        Importance = Promoted;
                        ToolTip = 'Specifies the value of the Ftp Host field';
                    }
                    field("Ftp Port"; Rec."Ftp Port")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Ftp Port field';
                    }
                    field("Ftp User"; Rec."Ftp User")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Ftp User field';
                    }
                    field("Ftp Password"; Rec."Ftp Password")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Ftp Password field';
                    }
                    field("Ftp Passive"; Rec."Ftp Passive")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Ftp Passive field';
                    }
                    field("Ftp Binary"; Rec."Ftp Binary")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Ftp Binary field';
                    }
                    field("Ftp Path"; Rec."Ftp Path")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Ftp Path field';
                    }
                    field("Ftp Backup Path"; Rec."Ftp Backup Path")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Ftp Backup Path field';
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
                    ApplicationArea = All;
                    ToolTip = 'Executes the Init Export Triggers action';

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
                    ApplicationArea = All;
                    ToolTip = 'Executes the Download Ftp action';

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

