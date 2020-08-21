page 6059931 "Doc. Exch. Setup"
{
    // NPR5.25/TJ/20160629 CASE 242206 Added new tab Export, renamed General to Import and indented Import File Settings under Import tab
    // NPR5.25/BR/20160725 CASE 246088 Added new fields for unmatched items
    // NPR5.26/TJ/20160818 CASE 248831 Redesigned page to have proper properties and code as a regular setup card has
    // NPR5.29/BR/20170117 CASE 263705 New Fields added fro FTP Import
    // NPR5.33/BR/20170216 CASE 266527 Added fields for FTP and local file export
    // NPR5.38/MHA /20180105  CASE 301053 Removed empty function RequestEDI() and Action RequestEDI
    // NPR5.55/MHA /20200623  CASE 400777 Added Page Action "Run Document Exchange"

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
                field("File Import Enabled"; "File Import Enabled")
                {
                    ApplicationArea = All;
                }
                group(ImportFileSettings)
                {
                    Caption = 'Import File Settings';
                    field("Import File Location"; "Import File Location")
                    {
                        ApplicationArea = All;
                    }
                    field("Import Local"; "Import Local")
                    {
                        ApplicationArea = All;
                    }
                    field("Archive File Location"; "Archive File Location")
                    {
                        ApplicationArea = All;
                    }
                    field("Archive Local"; "Archive Local")
                    {
                        ApplicationArea = All;
                    }
                    field("Create Document"; "Create Document")
                    {
                        ApplicationArea = All;
                    }
                }
            }
            group(ImportFTP)
            {
                Caption = 'Import FTP';
                field("FTP Import Enabled"; "FTP Import Enabled")
                {
                    ApplicationArea = All;
                }
                group(ImportFTPSettings)
                {
                    Caption = 'Import FTP Settings';
                    field("Import FTP Server"; "Import FTP Server")
                    {
                        ApplicationArea = All;
                    }
                    field("Import FTP Using Passive"; "Import FTP Using Passive")
                    {
                        ApplicationArea = All;
                    }
                    field("Import FTP Username"; "Import FTP Username")
                    {
                        ApplicationArea = All;
                    }
                    field("Import FTP Password"; "Import FTP Password")
                    {
                        ApplicationArea = All;
                        ExtendedDatatype = Masked;
                    }
                    field("Import FTP Folder"; "Import FTP Folder")
                    {
                        ApplicationArea = All;
                    }
                    field("Import FTP File Mask"; "Import FTP File Mask")
                    {
                        ApplicationArea = All;
                    }
                    field("Archive FTP Folder"; "Archive FTP Folder")
                    {
                        ApplicationArea = All;
                    }
                }
            }
            group(Export)
            {
                Caption = 'Export';
                field("File Export Enabled"; "File Export Enabled")
                {
                    ApplicationArea = All;
                }
                group(ExportFileSettings)
                {
                    Caption = 'Export File Settings';
                    field("Export File Location"; "Export File Location")
                    {
                        ApplicationArea = All;
                    }
                    field("Export Local"; "Export Local")
                    {
                        ApplicationArea = All;
                    }
                }
            }
            group(ExportFTP)
            {
                Caption = 'Export FTP';
                field("FTP Export Enabled"; "FTP Export Enabled")
                {
                    ApplicationArea = All;
                }
                group(ExportFTPSettings)
                {
                    Caption = 'Export FTP Settings';
                    field("Export FTP Server"; "Export FTP Server")
                    {
                        ApplicationArea = All;
                    }
                    field("Export FTP Username"; "Export FTP Username")
                    {
                        ApplicationArea = All;
                    }
                    field("Export FTP Password"; "Export FTP Password")
                    {
                        ApplicationArea = All;
                        ExtendedDatatype = Masked;
                    }
                    field("Export FTP Folder"; "Export FTP Folder")
                    {
                        ApplicationArea = All;
                    }
                    field("Export FTP Using Passive"; "Export FTP Using Passive")
                    {
                        ApplicationArea = All;
                    }
                }
            }
            group(ItemMatching)
            {
                Caption = 'Item Matching';
                field("Unmatched Items Wsht. Template"; "Unmatched Items Wsht. Template")
                {
                    ApplicationArea = All;
                }
                field("Unmatched Items Wsht. Name"; "Unmatched Items Wsht. Name")
                {
                    ApplicationArea = All;
                }
                field("Autom. Create Unmatched Items"; "Autom. Create Unmatched Items")
                {
                    ApplicationArea = All;
                }
                field("Autom. Query Item Information"; "Autom. Query Item Information")
                {
                    ApplicationArea = All;
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
            action("Run Document Exchange")
            {
                Caption = 'Run Document Exchange';
                Image = Start;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                begin
                    //-NPR5.55 [400777]
                    CODEUNIT.Run(CODEUNIT::"Doc. Exch. File Mgt.");
                    //+NPR5.55 [400777]
                end;
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

