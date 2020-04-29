page 6060069 "MM Admission Scanner Stations"
{
    // NPR5.43/NPKNAV/20180629  CASE 318579 Transport NPR5.43 - 29 June 2018

    Caption = 'MM Admission Scanner Stations';
    PageType = List;
    SourceTable = "MM Admission Scanner Stations";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Scanner Station Id";"Scanner Station Id")
                {
                }
                field("Guest Avatar";"Guest Avatar")
                {
                }
                field("Turnstile Default Image";"Turnstile Default Image")
                {
                }
                field("Turnstile Error Image";"Turnstile Error Image")
                {
                }
                field(Activated;Activated)
                {
                }
            }
        }
    }

    actions
    {
    }
}

