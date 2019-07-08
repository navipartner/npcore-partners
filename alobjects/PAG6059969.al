page 6059969 "Description Control"
{
    // NPR5.29/NPKNAV/20170127  CASE 260472 Transport NPR5.29 - 27 januar 2017

    Caption = 'Description Control';
    PageType = List;
    SourceTable = "Description Control";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code";Code)
                {
                }
                field("Setup Type";"Setup Type")
                {
                }
                field("Disable Item Translations";"Disable Item Translations")
                {
                }
                field("Description 1 Var (Simple)";"Description 1 Var (Simple)")
                {
                }
                field("Description 2 Var (Simple)";"Description 2 Var (Simple)")
                {
                }
                field("Description 1 Std (Simple)";"Description 1 Std (Simple)")
                {
                }
                field("Description 2 Std (Simple)";"Description 2 Std (Simple)")
                {
                }
                field("Description 1 Var (Adv)";"Description 1 Var (Adv)")
                {
                    Visible = false;
                }
                field("Description 2 Var (Adv)";"Description 2 Var (Adv)")
                {
                    Visible = false;
                }
                field("Description 1 Std (Adv)";"Description 1 Std (Adv)")
                {
                    Visible = false;
                }
                field("Description 2 Std (Adv)";"Description 2 Std (Adv)")
                {
                    Visible = false;
                }
            }
        }
    }

    actions
    {
    }
}

