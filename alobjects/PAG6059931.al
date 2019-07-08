page 6059931 "Doc. Exch. Setup"
{
    // NPR5.25/TJ/20160629 CASE 242206 Added new tab Export, renamed General to Import and indented Import File Settings under Import tab
    // NPR5.25/BR/20160725 CASE 246088 Added new fields for unmatched items
    // NPR5.26/TJ/20160818 CASE 248831 Redesigned page to have proper properties and code as a regular setup card has
    // NPR5.29/BR/20170117 CASE 263705 New Fields added fro FTP Import
    // NPR5.33/BR/20170216 CASE 266527 Added fields for FTP and local file export
    // NPR5.38/MHA /20180105  CASE 301053 Removed empty function RequestEDI() and Action RequestEDI

    Caption = 'Doc. Exch. Setup';
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = Card;
    SourceTable = "Doc. Exch. Setup";
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            group(ImportFile)
            {
                Caption = 'Import Files';
                field("File Import Enabled";"File Import Enabled")
                {
                }
                group(ImportFileSettings)
                {
                    Caption = 'Import File Settings';
                    field("Import File Location";"Import File Location")
                    {
                    }
                    field("Import Local";"Import Local")
                    {
                    }
                    field("Archive File Location";"Archive File Location")
                    {
                    }
                    field("Archive Local";"Archive Local")
                    {
                    }
                    field("Create Document";"Create Document")
                    {
                    }
                }
            }
            group(ImportFTP)
            {
                Caption = 'Import FTP';
                field("FTP Import Enabled";"FTP Import Enabled")
                {
                }
                group(ImportFTPSettings)
                {
                    Caption = 'Import FTP Settings';
                    field("Import FTP Server";"Import FTP Server")
                    {
                    }
                    field("Import FTP Using Passive";"Import FTP Using Passive")
                    {
                    }
                    field("Import FTP Username";"Import FTP Username")
                    {
                    }
                    field("Import FTP Password";"Import FTP Password")
                    {
                        ExtendedDatatype = Masked;
                    }
                    field("Import FTP Folder";"Import FTP Folder")
                    {
                    }
                    field("Import FTP File Mask";"Import FTP File Mask")
                    {
                    }
                    field("Archive FTP Folder";"Archive FTP Folder")
                    {
                    }
                }
            }
            group(Export)
            {
                Caption = 'Export';
                field("File Export Enabled";"File Export Enabled")
                {
                }
                group(ExportFileSettings)
                {
                    Caption = 'Export File Settings';
                    field("Export File Location";"Export File Location")
                    {
                    }
                    field("Export Local";"Export Local")
                    {
                    }
                }
            }
            group(ExportFTP)
            {
                Caption = 'Export FTP';
                field("FTP Export Enabled";"FTP Export Enabled")
                {
                }
                group(ExportFTPSettings)
                {
                    Caption = 'Export FTP Settings';
                    field("Export FTP Server";"Export FTP Server")
                    {
                    }
                    field("Export FTP Username";"Export FTP Username")
                    {
                    }
                    field("Export FTP Password";"Export FTP Password")
                    {
                        ExtendedDatatype = Masked;
                    }
                    field("Export FTP Folder";"Export FTP Folder")
                    {
                    }
                    field("Export FTP Using Passive";"Export FTP Using Passive")
                    {
                    }
                }
            }
            group(ItemMatching)
            {
                Caption = 'Item Matching';
                field("Unmatched Items Wsht. Template";"Unmatched Items Wsht. Template")
                {
                }
                field("Unmatched Items Wsht. Name";"Unmatched Items Wsht. Name")
                {
                }
                field("Autom. Create Unmatched Items";"Autom. Create Unmatched Items")
                {
                }
                field("Autom. Query Item Information";"Autom. Query Item Information")
                {
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(DocExchangePaths)
            {
                Caption = 'Doc. Exchange Paths';
                Image = CopyBOMVersion;
                RunObject = Page "Doc. Exchange Paths";
            }
        }
    }

    trigger OnOpenPage()
    begin
        //-NPR5.26
        Reset;
        if not Get then begin
          Init;
          Insert;
        end;
        //+NPR5.26
    end;
}

