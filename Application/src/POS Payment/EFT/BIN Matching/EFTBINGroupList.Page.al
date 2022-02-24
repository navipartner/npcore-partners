page 6184511 "NPR EFT BIN Group List"
{
    Extensible = False;
    Caption = 'EFT Mapping Group List';
    CardPageID = "NPR EFT BIN Group Card";
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    SourceTable = "NPR EFT BIN Group";
    UsageCategory = Administration;
    ApplicationArea = NPRRetail;


    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code"; Rec.Code)
                {

                    ToolTip = 'Specifies the value of the Code field';
                    ApplicationArea = NPRRetail;
                }
                field(Description; Rec.Description)
                {

                    ToolTip = 'Specifies the value of the Description field';
                    ApplicationArea = NPRRetail;
                }
                field(Priority; Rec.Priority)
                {

                    ToolTip = 'Specifies the value of the Priority field';
                    ApplicationArea = NPRRetail;
                }
                field("Card Issuer ID"; Rec."Card Issuer ID")
                {

                    ToolTip = 'Specifies the value of the Card Issuer ID field';
                    ApplicationArea = NPRRetail;
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

                ToolTip = 'Executes the Import File action';
                ApplicationArea = NPRRetail;
            }
            action(ShowAllRanges)
            {
                Caption = 'Show All Ranges';
                Image = List;
                RunObject = Page "NPR EFT BIN Ranges";

                ToolTip = 'Executes the Show All Ranges action';
                ApplicationArea = NPRRetail;
            }
        }
    }
}

