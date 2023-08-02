page 6184511 "NPR EFT BIN Group List"
{
    Extensible = False;
    Caption = 'EFT Mapping Group List';
    ContextSensitiveHelpPage = 'docs/retail/eft/how-to/eft_bin/';
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

                    ToolTip = 'Specifies the unique code of the EFT BIN Mapping Group';
                    ApplicationArea = NPRRetail;
                }
                field(Description; Rec.Description)
                {

                    ToolTip = 'Specifies the Description of the EFT BIN Mapping Group';
                    ApplicationArea = NPRRetail;
                }
                field(Priority; Rec.Priority)
                {

                    ToolTip = 'Specifies the Priority of the EFT BIN Mapping Group. A group with the lowest priority will be selected if criteria of the EFT Transaction is valid for multiple EFT BIN Mapping Groups.';
                    ApplicationArea = NPRRetail;
                }
                field("Card Issuer ID"; Rec."Card Issuer ID")
                {

                    ToolTip = 'Specifies the Card Issuer ID of the EFT BIN Mapping Group. Certain EFT Integrations can use this criteria to perform mapping to the EFT BIN Mapping Group.';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }

    actions
    {
        area(navigation)
        {
            action(ShowAllRanges)
            {
                Caption = 'Show All Ranges';
                Image = List;
                RunObject = Page "NPR EFT BIN Ranges";

                ToolTip = 'Opens the EFT BIN Ranges List';
                ApplicationArea = NPRRetail;
            }
        }
    }
}