page 6184513 "NPR EFT BIN Group Card"
{
    // NPR5.42/NPKNAV/20180525  CASE 306689 Transport NPR5.42 - 25 May 2018

    Caption = 'EFT BIN Group Card';
    PageType = Card;
    SourceTable = "NPR EFT BIN Group";

    layout
    {
        area(content)
        {
            group(General)
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
            part(Control6014405; "NPR EFT BIN Group Paym. Links")
            {
                SubPageLink = "Group Code" = FIELD(Code);
                ApplicationArea=All;
            }
            part(Control6014406; "NPR EFT BIN Range SubPage")
            {
                SubPageLink = "BIN Group Code" = FIELD(Code);
                ApplicationArea=All;
            }
        }
    }

    actions
    {
    }
}

