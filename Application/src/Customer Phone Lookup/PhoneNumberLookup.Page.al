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
                    ToolTip = 'Specifies the value of the Phone No. field';
                }
                field(Name; Name)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Name field';
                }
                field(Address; Address)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Address field';
                }
                field("Post Code"; "Post Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Post Code field';
                }
                field(City; City)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the City field';
                }
                field("Country/Region Code"; "Country/Region Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Country/Region Code field';
                }
                field("Mobile Phone No."; "Mobile Phone No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Customer Template field';
                }
                field("E-Mail"; "E-Mail")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the E-Mail field';
                }
                field("Home Page"; "Home Page")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Home Page field';
                }
                field("VAT Registration No."; "VAT Registration No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the VAT Registration No. field';
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

