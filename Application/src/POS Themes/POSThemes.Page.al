page 6150735 "NPR POS Themes"
{
    // NPR5.49/VB  /20181106 CASE 335141 Introducing the POS Theme functionality

    Caption = 'POS Themes';
    PageType = List;
    SourceTable = "NPR POS Theme";
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

                    ToolTip = 'Specifies the value of the Code field';
                    ApplicationArea = NPRRetail;
                }
                field(Description; Rec.Description)
                {

                    ToolTip = 'Specifies the value of the Description field';
                    ApplicationArea = NPRRetail;
                }
                field(Blocked; Rec.Blocked)
                {

                    ToolTip = 'Specifies the value of the Blocked field';
                    ApplicationArea = NPRRetail;
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

                ToolTip = 'Executes the Theme Dependencies action';
                ApplicationArea = NPRRetail;
            }
        }
    }
}

