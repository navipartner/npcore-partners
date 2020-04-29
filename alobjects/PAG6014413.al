page 6014413 "Phone Number Lookup"
{
    // NPR5.23/TS/20152611  CASE 222711 Reworking the Page
    // NPR5.26/MHA /20160921  CASE 252881 Added field 30 Mobile Phone No. and deleted unused field 18 P and functions

    Caption = 'Online service Name and Numbers search';
    Editable = false;
    PageType = List;
    SourceTable = "Phone Lookup Buffer";
    SourceTableTemporary = true;

    layout
    {
        area(content)
        {
            repeater(Control6150613)
            {
                ShowCaption = false;
                field("Phone No.";"Phone No.")
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
                field("Country/Region Code";"Country/Region Code")
                {
                }
                field("Mobile Phone No.";"Mobile Phone No.")
                {
                }
                field("E-Mail";"E-Mail")
                {
                }
                field("Home Page";"Home Page")
                {
                }
                field("VAT Registration No.";"VAT Registration No.")
                {
                }
            }
        }
    }

    actions
    {
    }

    var
        Type: Option " ",Customer,Vendor,Contact;
}

