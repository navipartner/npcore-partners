page 6150668 "NPRE Print Category"
{
    // NPR5.34/ANEN  /2017012  CASE 270255 Object Created for Hospitality - Version 1.0
    // NPR5.35/ANEN /20170821 CASE 283376 Solution rename to NP Restaurant

    Caption = 'Print Category';
    PageType = List;
    SourceTable = "NPRE Print Category";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code";Code)
                {
                }
                field("Print Tag";"Print Tag")
                {
                }
                field("Kitchen Order Template";"Kitchen Order Template")
                {
                }
            }
        }
    }

    actions
    {
    }
}

