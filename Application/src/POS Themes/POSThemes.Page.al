page 6150735 "NPR POS Themes"
{
    // NPR5.49/VB  /20181106 CASE 335141 Introducing the POS Theme functionality

    Caption = 'POS Themes';
    PageType = List;
    SourceTable = "NPR POS Theme";
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
                field(Blocked; Blocked)
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
            action("Theme Dependencies")
            {
                Caption = 'Theme Dependencies';
                Image = StyleSheet;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                RunObject = Page "NPR POS Theme Dependencies";
                RunPageLink = "POS Theme Code" = FIELD(Code);
                ApplicationArea = All;
            }
        }
    }
}

