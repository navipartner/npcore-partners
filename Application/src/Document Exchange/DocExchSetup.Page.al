page 6059931 "NPR Doc. Exch. Setup"
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
    SourceTable = "NPR Doc. Exch. Setup";
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
                    ToolTip = 'Specifies the value of the File Import Enabled field';
                }
                group(ImportFileSettings)
                {
                    Caption = 'Import File Settings';
                    field("Import File Location"; "Import File Location")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Import File Location field';
                    }
                    field("Import Local"; "Import Local")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Import Local field';
                    }
                    field("Archive File Location"; "Archive File Location")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Archive File Location field';
                    }
                    field("Archive Local"; "Archive Local")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Archive Local field';
                    }
                    field("Create Document"; "Create Document")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Create Document field';
                    }
                }
            }
            group(ImportFTP)
            {
                Caption = 'Import FTP';
                field("FTP Import Enabled"; "FTP Import Enabled")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the FTP Import Enabled field';
                }
                group(ImportFTPSettings)
                {
                    Caption = 'Import FTP Settings';
                    field("Import FTP Server"; "Import FTP Server")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Import FTP Server field';
                    }
                    field("Import FTP Using Passive"; "Import FTP Using Passive")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Import FTP Using Passive field';
                    }
                    field("Import FTP Username"; "Import FTP Username")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Import FTP Username field';
                    }
                    field("Import FTP Password"; "Import FTP Password")
                    {
                        ApplicationArea = All;
                        ExtendedDatatype = Masked;
                        ToolTip = 'Specifies the value of the Import FTP Password field';
                    }
                    field("Import FTP Folder"; "Import FTP Folder")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Import FTP Folder field';
                    }
                    field("Import FTP File Mask"; "Import FTP File Mask")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Import FTP File Mask field';
                    }
                    field("Archive FTP Folder"; "Archive FTP Folder")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Archive FTP Folder field';
                    }
                }
            }
            group(Export)
            {
                Caption = 'Export';
                field("File Export Enabled"; "File Export Enabled")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the File Export Enabled field';
                }
                group(ExportFileSettings)
                {
                    Caption = 'Export File Settings';
                    field("Export File Location"; "Export File Location")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Export File Location field';
                    }
                    field("Export Local"; "Export Local")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Export Local field';
                    }
                }
            }
            group(ExportFTP)
            {
                Caption = 'Export FTP';
                field("FTP Export Enabled"; "FTP Export Enabled")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the FTP Export Enabled field';
                }
                group(ExportFTPSettings)
                {
                    Caption = 'Export FTP Settings';
                    field("Export FTP Server"; "Export FTP Server")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Export FTP Server field';
                    }
                    field("Export FTP Username"; "Export FTP Username")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Export FTP Username field';
                    }
                    field("Export FTP Password"; "Export FTP Password")
                    {
                        ApplicationArea = All;
                        ExtendedDatatype = Masked;
                        ToolTip = 'Specifies the value of the Export FTP Password field';
                    }
                    field("Export FTP Folder"; "Export FTP Folder")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Export FTP Folder field';
                    }
                    field("Export FTP Using Passive"; "Export FTP Using Passive")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Export FTP Using Passive field';
                    }
                }
            }
            group(ItemMatching)
            {
                Caption = 'Item Matching';
                field("Unmatched Items Wsht. Template"; "Unmatched Items Wsht. Template")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Unmatched Items Wsht. Template field';
                }
                field("Unmatched Items Wsht. Name"; "Unmatched Items Wsht. Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Unmatched Items Wsht. Name field';
                }
                field("Autom. Create Unmatched Items"; "Autom. Create Unmatched Items")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Autom. Create Unmatched Items field';
                }
                field("Autom. Query Item Information"; "Autom. Query Item Information")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Autom. Query Item Information field';
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
                RunObject = Page "NPR Doc. Exchange Paths";
                ApplicationArea = All;
                ToolTip = 'Executes the Doc. Exchange Paths action';
            }
            action("Run Document Exchange")
            {
                Caption = 'Run Document Exchange';
                Image = Start;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ApplicationArea = All;
                ToolTip = 'Executes the Run Document Exchange action';

                trigger OnAction()
                begin
                    //-NPR5.55 [400777]
                    CODEUNIT.Run(CODEUNIT::"NPR Doc. Exch. File Mgt.");
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

