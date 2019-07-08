page 6014515 "Warranty Catalog List"
{
    // NPR5.23/TS/20160518  CASE 240748  Renamed Page

    Caption = 'Warranty Catalog List';
    CardPageID = "Warranty Catalog";
    Editable = false;
    PageType = List;
    SourceTable = "Warranty Directory";
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            repeater(Control6150614)
            {
                ShowCaption = false;
                field("No.";"No.")
                {
                }
                field(Description;Description)
                {
                }
                field("Customer No.";"Customer No.")
                {
                }
                field(Name;Name)
                {
                }
                field("Name 2";"Name 2")
                {
                }
                field(Address;Address)
                {
                }
                field(City;City)
                {
                }
                field("Post Code";"Post Code")
                {
                }
                field("Phone No.";"Phone No.")
                {
                }
                field("E-Mail";"E-Mail")
                {
                }
                field("Your Reference";"Your Reference")
                {
                }
            }
        }
    }

    actions
    {
    }
}

