page 6150634 "NPRE Print Templates Subpage"
{
    // NPR5.41/THRO/20180412 CASE 309873 Page created

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

