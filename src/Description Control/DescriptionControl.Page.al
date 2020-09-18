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
                }
                field("Setup Type"; "Setup Type")
                {
                    ApplicationArea = All;
                }
                field("Disable Item Translations"; "Disable Item Translations")
                {
                    ApplicationArea = All;
                }
                field("Description 1 Var (Simple)"; "Description 1 Var (Simple)")
                {
                    ApplicationArea = All;
                }
                field("Description 2 Var (Simple)"; "Description 2 Var (Simple)")
                {
                    ApplicationArea = All;
                }
                field("Description 1 Std (Simple)"; "Description 1 Std (Simple)")
                {
                    ApplicationArea = All;
                }
                field("Description 2 Std (Simple)"; "Description 2 Std (Simple)")
                {
                    ApplicationArea = All;
                }
                field("Description 1 Var (Adv)"; "Description 1 Var (Adv)")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Description 2 Var (Adv)"; "Description 2 Var (Adv)")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Description 1 Std (Adv)"; "Description 1 Std (Adv)")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Description 2 Std (Adv)"; "Description 2 Std (Adv)")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
            }
        }
    }

    actions
    {
    }
}

