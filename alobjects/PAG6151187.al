page 6151187 "MM Member Communication Setup"
{
    // MM1.42/TSA /20191219 CASE 382728 Initial Version

    Caption = 'Member Communication Setup';
    PageType = List;
    SourceTable = "MM Member Communication Setup";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Membership Code";"Membership Code")
                {
                }
                field("Message Type";"Message Type")
                {
                }
                field("Preferred Method";"Preferred Method")
                {
                }
            }
        }
    }

    actions
    {
    }
}

