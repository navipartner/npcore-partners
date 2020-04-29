page 6150681 "NPRE Flow Status Pr.Categories"
{
    // NPR5.53/ALPO/20200102 CASE 360258 Possibility to send to kitchen only selected waiter pad lines or lines of specific print category

    Caption = 'Flow Status Print Categories';
    DelayedInsert = true;
    PageType = List;
    SourceTable = "NPRE Flow Status Pr.Category";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Flow Status Object";"Flow Status Object")
                {
                    Visible = false;
                }
                field("Flow Status Code";"Flow Status Code")
                {
                    Visible = false;
                }
                field("Print Category Code";"Print Category Code")
                {
                }
            }
        }
    }

    actions
    {
    }
}

