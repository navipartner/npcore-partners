page 6059969 "NPR Description Control"
{
    // NPR5.29/NPKNAV/20170127  CASE 260472 Transport NPR5.29 - 27 januar 2017

    Caption = 'Description Control';
    PageType = List;
    UsageCategory = Administration;
    ApplicationArea = All;
    SourceTable = "NPR Description Control";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code"; Rec.Code)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Code field';
                }
                field("Setup Type"; Rec."Setup Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Setup Type field';
                }
                field("Disable Item Translations"; Rec."Disable Item Translations")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Disable Item Translations field';
                }
                field("Description 1 Var (Simple)"; Rec."Description 1 Var (Simple)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description 1 Var (Simple) field';
                }
                field("Description 2 Var (Simple)"; Rec."Description 2 Var (Simple)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description 2 Var (Simple) field';
                }
                field("Description 1 Std (Simple)"; Rec."Description 1 Std (Simple)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description 1 Std (Simple) field';
                }
                field("Description 2 Std (Simple)"; Rec."Description 2 Std (Simple)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description 2 Std (Simple) field';
                }
                field("Description 1 Var (Adv)"; Rec."Description 1 Var (Adv)")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Description 1 Var (Adv) field';
                }
                field("Description 2 Var (Adv)"; Rec."Description 2 Var (Adv)")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Description 2 Var (Adv) field';
                }
                field("Description 1 Std (Adv)"; Rec."Description 1 Std (Adv)")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Description 1 Std (Adv) field';
                }
                field("Description 2 Std (Adv)"; Rec."Description 2 Std (Adv)")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Description 2 Std (Adv) field';
                }
            }
        }
    }

    actions
    {
    }
}

