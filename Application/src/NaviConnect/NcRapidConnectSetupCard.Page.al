page 6151090 "NPR Nc RapidConnect Setup Card"
{
    // NC2.12/MHA /20180418  CASE 308107 Object created - RapidStart with NaviConnect
    // NC2.17/MHA /20181122  CASE 335927 Added field 110 "Export File Type"
    // NC14.00.2.22/MHA /20190715  CASE 361941 Removed Action "Export to Excel"

    UsageCategory = None;
    Caption = 'RapidConnect Setup';
    SourceTable = "NPR Nc RapidConnect Setup";

    layout
    {
        area(content)
        {
            group(General)
            {
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
                field("Package Code"; "Package Code")
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
                    field("Export Enabled"; "Export Enabled")
                    {
                        ApplicationArea = All;
                        Importance = Promoted;
                        ToolTip = 'Specifies the value of the Export Enabled field';
                    }
                    field("Task Processor Code"; "Task Processor Code")
                    {
                        ApplicationArea = All;
                        Importance = Promoted;
                        ToolTip = 'Specifies the value of the Task Processor Code field';
                    }
                    field("Export File Type"; "Export File Type")
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
                field("Import Enabled"; "Import Enabled")
                {
                    ApplicationArea = All;
                    Importance = Promoted;
                    ToolTip = 'Specifies the value of the Import Enabled field';
                }
                field("Import Type"; "Import Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Import Type field';
                }
                field("Validate Package"; "Validate Package")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Validate Package field';
                }
                field("Apply Package"; "Apply Package")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Apply Package field';
                }
                field("Disable Data Log on Import"; "Disable Data Log on Import")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Disable Data Log on Import field';
                }
                group("Download from")
                {
                    Caption = 'Download from';
                    field("Ftp Host"; "Ftp Host")
                    {
                        ApplicationArea = All;
                        Importance = Promoted;
                        ToolTip = 'Specifies the value of the Ftp Host field';
                    }
                    field("Ftp Port"; "Ftp Port")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Ftp Port field';
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
                    field("Ftp Binary"; "Ftp Binary")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Ftp Binary field';
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
                    Visible = "Import Enabled";
                    ApplicationArea = All;
                    ToolTip = 'Executes the Download Ftp action';

                    trigger OnAction()
                    var
                        NcImportType: Record "NPR Nc Import Type";
                        NcSyncMgt: Codeunit "NPR Nc Sync. Mgt.";
                    begin
                        NcImportType.Get("Import Type");
                        NcSyncMgt.DownloadFtpType(NcImportType);
                    end;
                }
            }
        }
    }

    var
        Text000: Label 'Export package %1 with %2 tables?';
}

