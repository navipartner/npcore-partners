page 6059969 "NPR Description Control"
{
    // NPR5.29/NPKNAV/20170127  CASE 260472 Transport NPR5.29 - 27 januar 2017

    Caption = 'Description Control';
    PageType = List;
    UsageCategory = Administration;
    SourceTable = "NPR Description Control";

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
                field("Setup Type"; "Setup Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Setup Type field';
                }
                field("Disable Item Translations"; "Disable Item Translations")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Disable Item Translations field';
                }
                field("Description 1 Var (Simple)"; "Description 1 Var (Simple)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description 1 Var (Simple) field';
                }
                field("Description 2 Var (Simple)"; "Description 2 Var (Simple)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description 2 Var (Simple) field';
                }
                field("Description 1 Std (Simple)"; "Description 1 Std (Simple)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description 1 Std (Simple) field';
                }
                field("Description 2 Std (Simple)"; "Description 2 Std (Simple)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description 2 Std (Simple) field';
                }
                field("Description 1 Var (Adv)"; "Description 1 Var (Adv)")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Description 1 Var (Adv) field';
                }
                field("Description 2 Var (Adv)"; "Description 2 Var (Adv)")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Description 2 Var (Adv) field';
                }
                field("Description 1 Std (Adv)"; "Description 1 Std (Adv)")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Description 1 Std (Adv) field';
                }
                field("Description 2 Std (Adv)"; "Description 2 Std (Adv)")
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

