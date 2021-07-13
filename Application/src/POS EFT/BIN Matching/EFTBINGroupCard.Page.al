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
            part(Control6014405; "NPR EFT BIN Group Paym. Links")
            {
                SubPageLink = "Group Code" = FIELD(Code);
                ApplicationArea = NPRRetail;

            }
            part(Control6014406; "NPR EFT BIN Range SubPage")
            {
                SubPageLink = "BIN Group Code" = FIELD(Code);
                ApplicationArea = NPRRetail;

            }
        }
    }
}

