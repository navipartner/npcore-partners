page 6059971 Variety
{
    // VRT1.11/TR/20150428  CASE 210960 - Caption on action changed from "Variety Value" to "Variety Table".
    // NPR5.41/TS  /20180105 CASE 300893 ActionContainers cannot have captions

    Caption = 'Variety';
    PageType = List;
    SourceTable = Variety;
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
                field("Use in Variant Description";"Use in Variant Description")
                {
                }
                field("Pre tag In Variant Description";"Pre tag In Variant Description")
                {
                }
                field("Use Description field";"Use Description field")
                {
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
                RunObject = Page "Variety Table";
                RunPageLink = Type=FIELD(Code);
                RunPageView = SORTING(Type,Code);
            }
        }
    }
}

