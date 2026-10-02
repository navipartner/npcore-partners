page 6151329 "NPR DK SAF-T Cash Export Zips"
{
    Extensible = False;
    Caption = 'SAF-T Cash Register Export Zips';
    PageType = List;
    SourceTable = "NPR DK SAF-T Cash Export Zip";
    UsageCategory = None;
    Editable = false;
    ObsoleteState = Pending;
    ObsoleteTag = '2026-09-29';
    ObsoleteReason = 'The SAF-T file is delivered as one XML file stored on the export line, not as a ZIP archive.';

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
}
