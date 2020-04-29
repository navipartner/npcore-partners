page 6184511 "EFT BIN Group List"
{
    // NPR5.40/NPKNAV/20180330  CASE 290734 Transport NPR5.40 - 30 March 2018
    // NPR5.42/MMV /20180507  CASE 306689 Renamed object & removed payment type field.
    // NPR5.53/MMV /20191204 CASE 349520 Added 'ShowAllRanges' action

    Caption = 'EFT BIN Group List';
    CardPageID = "EFT BIN Group Card";
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    SourceTable = "EFT BIN Group";
    UsageCategory = Administration;

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
                field(Priority;Priority)
                {
                }
            }
        }
    }

    actions
    {
        area(navigation)
        {
            action(ImportFile)
            {
                Caption = 'Import File';
                Image = Import;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                RunObject = XMLport "EFT BIN Import";
            }
            action(ShowAllRanges)
            {
                Caption = 'Show All Ranges';
                Image = List;
                RunObject = Page "EFT BIN Ranges";
            }
        }
    }
}

