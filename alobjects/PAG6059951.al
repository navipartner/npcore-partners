page 6059951 "Display Content"
{
    // NPR5.48/JDH /20181109 CASE 334163 Added object caption

    Caption = 'Display Content';
    PageType = List;
    RefreshOnActivate = true;
    SourceTable = "Display Content";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code";Code)
                {
                }
                field(Type;Type)
                {
                }
                field("Content Lines";"Content Lines")
                {
                }
            }
        }
    }

    actions
    {
    }
}

