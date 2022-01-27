page 6150625 "NPR POS NPRE Restaur. Profiles"
{
    Extensible = False;
    PageType = List;
    UsageCategory = Administration;

    SourceTable = "NPR POS NPRE Rest. Profile";
    Caption = 'POS Restaur. Profiles';
    CardPageId = "NPR POS Restaur. Profile Card";
    Editable = false;
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
                field("Restaurant Code"; Rec."Restaurant Code")
                {

                    ToolTip = 'Specifies the value of the Restaurant Code field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
        area(factboxes)
        {
            systempart(Control6014406; Notes)
            {
                Visible = false;
                ApplicationArea = NPRRetail;

            }
            systempart(Control6014407; Links)
            {
                Visible = false;
                ApplicationArea = NPRRetail;

            }
        }
    }
}
