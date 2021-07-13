page 6059969 "NPR Description Control"
{
    // NPR5.29/NPKNAV/20170127  CASE 260472 Transport NPR5.29 - 27 januar 2017

    Caption = 'Description Control';
    PageType = List;
    UsageCategory = Administration;

    SourceTable = "NPR Description Control";
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
                field("Setup Type"; Rec."Setup Type")
                {

                    ToolTip = 'Specifies the value of the Setup Type field';
                    ApplicationArea = NPRRetail;
                }
                field("Disable Item Translations"; Rec."Disable Item Translations")
                {

                    ToolTip = 'Specifies the value of the Disable Item Translations field';
                    ApplicationArea = NPRRetail;
                }
                field("Description 1 Var (Simple)"; Rec."Description 1 Var (Simple)")
                {

                    ToolTip = 'Specifies the value of the Description 1 Var (Simple) field';
                    ApplicationArea = NPRRetail;
                }
                field("Description 2 Var (Simple)"; Rec."Description 2 Var (Simple)")
                {

                    ToolTip = 'Specifies the value of the Description 2 Var (Simple) field';
                    ApplicationArea = NPRRetail;
                }
                field("Description 1 Std (Simple)"; Rec."Description 1 Std (Simple)")
                {

                    ToolTip = 'Specifies the value of the Description 1 Std (Simple) field';
                    ApplicationArea = NPRRetail;
                }
                field("Description 2 Std (Simple)"; Rec."Description 2 Std (Simple)")
                {

                    ToolTip = 'Specifies the value of the Description 2 Std (Simple) field';
                    ApplicationArea = NPRRetail;
                }
                field("Description 1 Var (Adv)"; Rec."Description 1 Var (Adv)")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Description 1 Var (Adv) field';
                    ApplicationArea = NPRRetail;
                }
                field("Description 2 Var (Adv)"; Rec."Description 2 Var (Adv)")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Description 2 Var (Adv) field';
                    ApplicationArea = NPRRetail;
                }
                field("Description 1 Std (Adv)"; Rec."Description 1 Std (Adv)")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Description 1 Std (Adv) field';
                    ApplicationArea = NPRRetail;
                }
                field("Description 2 Std (Adv)"; Rec."Description 2 Std (Adv)")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Description 2 Std (Adv) field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }

    actions
    {
    }
}

