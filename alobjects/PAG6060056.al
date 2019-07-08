page 6060056 "Item Status"
{
    // NPR5.25\BR  \20160720  CASE 246088 Object Created
    // NPR5.48/JDH /20181109 CASE 334163 Added Caption to Object

    Caption = 'Item Status';
    PageType = List;
    SourceTable = "Item Status";

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
                field(Initial;Initial)
                {
                }
                field(Blocked;Blocked)
                {
                }
                field("Delete Allowed";"Delete Allowed")
                {
                }
                field("Rename Allowed";"Rename Allowed")
                {
                }
                field("Purchase Insert";"Purchase Insert")
                {
                }
                field("Purchase Release";"Purchase Release")
                {
                }
                field("Purchase Post";"Purchase Post")
                {
                }
                field("Sales Insert";"Sales Insert")
                {
                }
                field("Sales Release";"Sales Release")
                {
                }
                field("Sales Post";"Sales Post")
                {
                }
            }
        }
    }

    actions
    {
    }
}

