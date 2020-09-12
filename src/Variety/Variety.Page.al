page 6059971 "NPR Variety"
{
    // VRT1.11/TR/20150428  CASE 210960 - Caption on action changed from "Variety Value" to "Variety Table".
    // NPR5.41/TS  /20180105 CASE 300893 ActionContainers cannot have captions

    Caption = 'Variety';
    PageType = List;
    SourceTable = "NPR Variety";
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
                field("Use in Variant Description"; "Use in Variant Description")
                {
                    ApplicationArea = All;
                }
                field("Pre tag In Variant Description"; "Pre tag In Variant Description")
                {
                    ApplicationArea = All;
                }
                field("Use Description field"; "Use Description field")
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
            action("Variety Tabel")
            {
                Caption = 'Variety Tabel';
                Image = "Table";
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                RunObject = Page "NPR Variety Table";
                RunPageLink = Type = FIELD(Code);
                RunPageView = SORTING(Type, Code);
                ApplicationArea = All;
            }
        }
    }
}

