page 6151364 "CS Warehouse Activity Setup"
{
    // NPR5.55/ALPO/20200729 CASE 404663 Possibility to use vendor item number & description for CS warehouse activity lines

    Caption = 'CS Warehouse Activity Setup';
    DelayedInsert = true;
    PageType = ListPlus;
    SourceTable = "CS Warehouse Activity Setup";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Source Document";"Source Document")
                {
                }
                field("Activity Type";"Activity Type")
                {
                }
                field("Show as Item No.";"Show as Item No.")
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

