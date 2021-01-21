page 6150735 "NPR POS Themes"
{
    // NPR5.49/VB  /20181106 CASE 335141 Introducing the POS Theme functionality

    Caption = 'POS Themes';
    PageType = List;
    SourceTable = "NPR POS Theme";
    UsageCategory = Administration;
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code"; Code)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Code field';
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field';
                }
                field(Blocked; Blocked)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Blocked field';
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
				PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                RunObject = Page "NPR POS Theme Dependencies";
                RunPageLink = "POS Theme Code" = FIELD(Code);
                ApplicationArea = All;
                ToolTip = 'Executes the Theme Dependencies action';
            }
        }
    }
}

