page 6151090 "Nc RapidConnect Setup Card"
{
    // NC2.12/MHA /20180418  CASE 308107 Object created - RapidStart with NaviConnect
    // NC2.17/MHA /20181122  CASE 335927 Added field 110 "Export File Type"
    // NC14.00.2.22/MHA /20190715  CASE 361941 Removed Action "Export to Excel"

    Caption = 'RapidConnect Setup';
    SourceTable = "Nc RapidConnect Setup";

    layout
    {
        area(content)
        {
            group(General)
            {
                field("Code"; Code)
                {
                }
                field(Description; Description)
                {
                }
                field("Package Code"; "Package Code")
                {
                    Importance = Promoted;
                    ShowMandatory = true;
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
                        Importance = Promoted;
                    }
                    field("Task Processor Code"; "Task Processor Code")
                    {
                        Importance = Promoted;
                    }
                    field("Export File Type"; "Export File Type")
                    {
                    }
                }
                group(Control6151414)
                {
                    ShowCaption = false;
                    part(Control6151411; "Nc RapidConnect Subform")
                    {
                        SubPageLink = "Setup Code" = FIELD(Code);
                    }
                    part(Control6151416; "Nc RapidConnect Endpoint Sub.")
                    {
                        SubPageLink = "Setup Code" = FIELD(Code);
                    }
                }
            }
            group(Import)
            {
                Caption = 'Import';
                field("Import Enabled"; "Import Enabled")
                {
                    Importance = Promoted;
                }
                field("Import Type"; "Import Type")
                {
                }
                field("Validate Package"; "Validate Package")
                {
                }
                field("Apply Package"; "Apply Package")
                {
                }
                field("Disable Data Log on Import"; "Disable Data Log on Import")
                {
                }
                group("Download from")
                {
                    Caption = 'Download from';
                    field("Ftp Host"; "Ftp Host")
                    {
                        Importance = Promoted;
                    }
                    field("Ftp Port"; "Ftp Port")
                    {
                    }
                    field("Ftp User"; "Ftp User")
                    {
                    }
                    field("Ftp Password"; "Ftp Password")
                    {
                    }
                    field("Ftp Passive"; "Ftp Passive")
                    {
                    }
                    field("Ftp Binary"; "Ftp Binary")
                    {
                    }
                    field("Ftp Path"; "Ftp Path")
                    {
                    }
                    field("Ftp Backup Path"; "Ftp Backup Path")
                    {
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

                    trigger OnAction()
                    var
                        NcRapidConnectSetupMgt: Codeunit "Nc RapidConnect Setup Mgt.";
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

                    trigger OnAction()
                    var
                        NcImportType: Record "Nc Import Type";
                        NcSyncMgt: Codeunit "Nc Sync. Mgt.";
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

