page 6151091 "Nc RapidConnect Setup"
{
    // NC2.12/MHA /20180418  CASE 308107 Object created - RapidStart with NaviConnect
    // NC14.00.2.22/MHA /20190715  CASE 361941 Removed Action "Export to Excel"

    Caption = 'RapidConnect Setup';
    CardPageID = "Nc RapidConnect Setup Card";
    Editable = false;
    PageType = List;
    SourceTable = "Nc RapidConnect Setup";
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code";Code)
                {
                }
                field(Description;Description)
                {
                }
                field("Package Code";"Package Code")
                {
                }
                field("Export Enabled";"Export Enabled")
                {
                }
                field("Task Processor Code";"Task Processor Code")
                {
                }
                field("Import Enabled";"Import Enabled")
                {
                }
                field("Import Type";"Import Type")
                {
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
}

