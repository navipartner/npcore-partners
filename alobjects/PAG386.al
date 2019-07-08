pageextension 70000234 pageextension70000234 extends "Extended Text" 
{
    // NPR5.49/TJ  /20190218 CASE 345047 New group Jobs and field Event
    layout
    {
        addafter(Service)
        {
            group(Jobs)
            {
                Caption = 'Jobs';
                field("Event";"Event")
                {
                }
            }
        }
    }
}

