page 6014413 "NPR Phone Number Lookup"
{
    Extensible = False;
    Caption = 'Online service Name and Numbers search';
    Editable = false;
    PageType = List;
    UsageCategory = Administration;

    SourceTable = "NPR Phone Lookup Buffer";
    SourceTableTemporary = true;
    ApplicationArea = NPRRetail;

    layout
    {
        area(content)
        {
            repeater(Control6150613)
            {
                ShowCaption = false;
                field("Phone No."; Rec."Phone No.")
                {

                    ToolTip = 'Specifies the value of the Phone No. field';
                    ApplicationArea = NPRRetail;
                }
                field(Name; Rec.Name)
                {

                    ToolTip = 'Specifies the value of the Name field';
                    ApplicationArea = NPRRetail;
                }
                field(Address; Rec.Address)
                {

                    ToolTip = 'Specifies the value of the Address field';
                    ApplicationArea = NPRRetail;
                }
                field("Post Code"; Rec."Post Code")
                {

                    ToolTip = 'Specifies the value of the Post Code field';
                    ApplicationArea = NPRRetail;
                }
                field(City; Rec.City)
                {

                    ToolTip = 'Specifies the value of the City field';
                    ApplicationArea = NPRRetail;
                }
                field("Country/Region Code"; Rec."Country/Region Code")
                {

                    ToolTip = 'Specifies the value of the Country/Region Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Mobile Phone No."; Rec."Mobile Phone No.")
                {

                    ToolTip = 'Specifies the value of the Customer Template field';
                    ApplicationArea = NPRRetail;
                }
                field("E-Mail"; Rec."E-Mail")
                {

                    ToolTip = 'Specifies the value of the E-Mail field';
                    ApplicationArea = NPRRetail;
                }
                field("Home Page"; Rec."Home Page")
                {

                    ToolTip = 'Specifies the value of the Home Page field';
                    ApplicationArea = NPRRetail;
                }
                field("VAT Registration No."; Rec."VAT Registration No.")
                {

                    ToolTip = 'Specifies the value of the VAT Registration No. field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }
}

