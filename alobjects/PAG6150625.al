page 6150625 "POS NPRE Restaurant Profiles"
{
    // NPR5.55/ALPO/20200730 CASE 414938 POS Store/POS Unit - Restaurant link

    PageType = ListPlus;
    SourceTable = "POS NPRE Restaurant Profile";

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
                field("Restaurant Code";"Restaurant Code")
                {
                }
            }
        }
        area(factboxes)
        {
            systempart(Control6014406;Notes)
            {
                Visible = false;
            }
            systempart(Control6014407;Links)
            {
                Visible = false;
            }
        }
    }

    actions
    {
    }
}

