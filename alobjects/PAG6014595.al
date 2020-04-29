page 6014595 "IC Vendor List"
{
    Caption = 'Vendor List';
    PageType = List;
    SourceTable = Vendor;

    layout
    {
        area(content)
        {
            repeater(Control6150613)
            {
                ShowCaption = false;
                field("No.";"No.")
                {
                }
                field(Name;Name)
                {
                }
                field(Address;Address)
                {
                }
                field("Post Code";"Post Code")
                {
                }
                field(City;City)
                {
                }
                field("Phone No.";"Phone No.")
                {
                }
            }
        }
    }

    actions
    {
    }
}

