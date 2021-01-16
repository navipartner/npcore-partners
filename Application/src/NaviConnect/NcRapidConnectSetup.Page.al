page 6151091 "NPR Nc RapidConnect Setup"
{
    // NC2.12/MHA /20180418  CASE 308107 Object created - RapidStart with NaviConnect
    // NC14.00.2.22/MHA /20190715  CASE 361941 Removed Action "Export to Excel"

    Caption = 'RapidConnect Setup';
    CardPageID = "NPR Nc RapidConnect Setup Card";
    Editable = false;
    PageType = List;
    SourceTable = "NPR Nc RapidConnect Setup";
    UsageCategory = Lists;
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            repeater(Group)
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
                    ToolTip = 'Specifies the value of the Package Code field';
                }
                field("Export Enabled"; "Export Enabled")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Export Enabled field';
                }
                field("Task Processor Code"; "Task Processor Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Task Processor Code field';
                }
                field("Import Enabled"; "Import Enabled")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Import Enabled field';
                }
                field("Import Type"; "Import Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Import Type field';
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            group(Import)
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
}

