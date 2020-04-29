page 6150735 "POS Themes"
{
    // NPR5.49/VB  /20181106 CASE 335141 Introducing the POS Theme functionality

    Caption = 'POS Themes';
    PageType = List;
    SourceTable = "POS Theme";
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
                field(Blocked;Blocked)
                {
                }
            }
        }
    }

    actions
    {
        area(navigation)
        {
            action("Theme Dependencies")
            {
                Caption = 'Theme Dependencies';
                Image = StyleSheet;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                RunObject = Page "POS Theme Dependencies";
                RunPageLink = "POS Theme Code"=FIELD(Code);
            }
        }
    }
}

