page 6150634 "NPRE Print Templates Subpage"
{
    // NPR5.41/THRO/20180412 CASE 309873 Page created
    // NPR5.53/ALPO/20200102 CASE 360258 Possibility to send to kitchen only selected waiter pad lines or lines of specific print category

    Caption = 'NPRE Print Templates Subpage';
    PageType = ListPart;
    SourceTable = "NPRE Print Template";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Print Type";"Print Type")
                {
                }
                field("Seating Location";"Seating Location")
                {
                }
                field("Print Category Code";"Print Category Code")
                {
                }
                field("Template Code";"Template Code")
                {
                }
            }
        }
    }

    actions
    {
    }
}

