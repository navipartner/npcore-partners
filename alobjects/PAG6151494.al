page 6151494 "Raptor Action List"
{
    // NPR5.53/ALPO/20191125 CASE 377727 Raptor integration enhancements

    Caption = 'Raptor Action List';
    Editable = false;
    PageType = List;
    SourceTable = "Raptor Action";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code";Code)
                {
                }
                field(Comment;Comment)
                {
                }
                field("Data Type Description";"Data Type Description")
                {
                    Visible = false;
                }
                field("Raptor Module Code";"Raptor Module Code")
                {
                }
                field("Raptor Module API Req. String";"Raptor Module API Req. String")
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

