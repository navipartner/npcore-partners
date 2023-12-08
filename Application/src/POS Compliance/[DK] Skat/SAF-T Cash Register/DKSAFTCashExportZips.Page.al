page 6151329 "NPR DK SAF-T Cash Export Zips"
{
    Extensible = False;
    Caption = 'SAF-T Cash Register Export Zips';
    PageType = List;
    SourceTable = "NPR DK SAF-T Cash Export Zip";
    UsageCategory = None;

    layout
    {
        area(Content)
        {
            repeater(Groupings)
            {
                field("No."; Rec."Zip No.")
                {
                    ApplicationArea = NPRDKFiscal;
                    ToolTip = 'Specifies the number of the file.';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(DownloadFile)
            {
                ApplicationArea = NPRDKFiscal;
                Caption = 'Download ZIP File';
                Image = ExportFile;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                ToolTip = 'Download the generated SAF-T ZIP file.';

                trigger OnAction()
                var
                    SAFTExportMgt: Codeunit "NPR DK SAF-T Cash Export Mgt.";
                begin
                    SAFTExportMgt.DownloadExportFile(Rec);
                end;
            }
        }
    }
}
