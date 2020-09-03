page 6151057 "NPR Distribution Header"
{
    // NPR5.38.01/JKL /20180126  CASE 289017 Object created - Replenishment Module

    AutoSplitKey = true;
    Caption = 'Distribution Group Setup';
    PageType = List;
    SourceTable = "NPR Distribution Headers";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Distribution Group"; "Distribution Group")
                {
                    ApplicationArea = All;
                }
                field("Item Hiearachy"; "Item Hiearachy")
                {
                    ApplicationArea = All;
                }
                field("Distribution Type"; "Distribution Type")
                {
                    ApplicationArea = All;
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("Distribution Lines")
            {
                Caption = 'Distribution Lines';
                Image = List;
                Promoted = true;
                RunObject = Page "NPR Distribution Lines";
                RunPageLink = "Distribution Id" = FIELD("Distribution Id");
            }
        }
    }
}

