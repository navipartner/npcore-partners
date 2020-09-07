page 6184511 "NPR EFT BIN Group List"
{
    // NPR5.40/NPKNAV/20180330  CASE 290734 Transport NPR5.40 - 30 March 2018
    // NPR5.42/MMV /20180507  CASE 306689 Renamed object & removed payment type field.
    // NPR5.53/MMV /20191204 CASE 349520 Added 'ShowAllRanges' action

    Caption = 'EFT BIN Group List';
    CardPageID = "NPR EFT BIN Group Card";
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    SourceTable = "NPR EFT BIN Group";
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code"; Code)
                {
                    ApplicationArea = All;
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                }
                field(Priority; Priority)
                {
                    ApplicationArea = All;
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
                RunObject = XMLport "NPR EFT BIN Import";
                ApplicationArea=All;
            }
            action(ShowAllRanges)
            {
                Caption = 'Show All Ranges';
                Image = List;
                RunObject = Page "NPR EFT BIN Ranges";
                ApplicationArea=All;
            }
        }
    }
}

