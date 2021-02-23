page 6184513 "NPR EFT BIN Group Card"
{

    Caption = 'EFT Mapping Group Card';
    PageType = Card;
    UsageCategory = None;
    SourceTable = "NPR EFT BIN Group";

    layout
    {
        area(content)
        {
            group(General)
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
            part(Control6014405; "NPR EFT BIN Group Paym. Links")
            {
                SubPageLink = "Group Code" = FIELD(Code);
                ApplicationArea = All;
            }
            part(Control6014406; "NPR EFT BIN Range SubPage")
            {
                SubPageLink = "BIN Group Code" = FIELD(Code);
                ApplicationArea = All;
            }
        }
    }
}

