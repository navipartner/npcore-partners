page 6014413 "NPR Phone Number Lookup"
{
    // NPR5.23/TS/20152611  CASE 222711 Reworking the Page
    // NPR5.26/MHA /20160921  CASE 252881 Added field 30 Mobile Phone No. and deleted unused field 18 P and functions

    Caption = 'Online service Name and Numbers search';
    Editable = false;
    PageType = List;
    UsageCategory = Administration;
    SourceTable = "NPR Phone Lookup Buffer";
    SourceTableTemporary = true;

    layout
    {
        area(content)
        {
            repeater(Control6150613)
            {
                ShowCaption = false;
                field("Phone No."; "Phone No.")
                {
                    ApplicationArea = All;
                }
                field(Name; Name)
                {
                    ApplicationArea = All;
                }
                field(Address; Address)
                {
                    ApplicationArea = All;
                }
                field("Post Code"; "Post Code")
                {
                    ApplicationArea = All;
                }
                field(City; City)
                {
                    ApplicationArea = All;
                }
                field("Country/Region Code"; "Country/Region Code")
                {
                    ApplicationArea = All;
                }
                field("Mobile Phone No."; "Mobile Phone No.")
                {
                    ApplicationArea = All;
                }
                field("E-Mail"; "E-Mail")
                {
                    ApplicationArea = All;
                }
                field("Home Page"; "Home Page")
                {
                    ApplicationArea = All;
                }
                field("VAT Registration No."; "VAT Registration No.")
                {
                    ApplicationArea = All;
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

