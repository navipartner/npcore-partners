page 6184511 "NPR EFT BIN Group List"
{
    Caption = 'EFT Mapping Group List';
    CardPageID = "NPR EFT BIN Group Card";
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    SourceTable = "NPR EFT BIN Group";
    UsageCategory = Administration;
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code"; Rec.Code)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Code field';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field';
                }
                field(Priority; Rec.Priority)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Priority field';
                }
                field("Card Issuer ID"; Rec."Card Issuer ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Card Issuer ID field';
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
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                RunObject = XMLport "NPR EFT BIN Import";
                ApplicationArea = All;
                ToolTip = 'Executes the Import File action';
            }
            action(ShowAllRanges)
            {
                Caption = 'Show All Ranges';
                Image = List;
                RunObject = Page "NPR EFT BIN Ranges";
                ApplicationArea = All;
                ToolTip = 'Executes the Show All Ranges action';
            }
        }
    }
}

