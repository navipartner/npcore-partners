page 6014538 "Insurance Companies"
{
    Caption = 'Insurance - Companies';
    PageType = List;
    SourceTable = "Insurance Companies";

    layout
    {
        area(content)
        {
            repeater(Control6150614)
            {
                ShowCaption = false;
                field("Code";Code)
                {
                }
            }
        }
    }

    actions
    {
    }
}

