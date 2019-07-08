page 6014599 "Connection Profiles"
{
    Caption = 'Connection Profiles';
    PageType = List;
    SourceTable = "Connection Profile";

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
                field("Hosting type";"Hosting type")
                {
                }
                field("Credit Card Extension";"Credit Card Extension")
                {
                }
            }
        }
    }

    actions
    {
    }
}

