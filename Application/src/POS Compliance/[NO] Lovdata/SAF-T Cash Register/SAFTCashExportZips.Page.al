page 6151283 "NPR SAF-T Cash Export Zips"
{
    Extensible = False;
    Caption = 'SAF-T Cash Register Export Zips';
    PageType = List;
    SourceTable = "NPR SAF-T Cash Export Zip";
    UsageCategory = None;

    layout
    {
        area(Content)
        {
            repeater(Groupings)
            {
                field("No."; Rec."Zip No.")
                {
                    ApplicationArea = NPRNOFiscal;
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
                ApplicationArea = NPRNOFiscal;
                Caption = 'Download ZIP File';
                Image = ExportFile;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                ToolTip = 'Download the generated SAF-T ZIP file.';

                trigger OnAction()
                var
                    SAFTExportMgt: Codeunit "NPR SAF-T Cash Export Mgt.";
                begin
                    SAFTExportMgt.DownloadExportFile(Rec);
                end;
            }
        }
    }
}
