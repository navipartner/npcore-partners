page 6184602 NPRPowerBICustomer
{
    PageType = List;
    Caption = 'PowerBI Customer';
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = Customer;
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field(Address; Rec.Address)
                {
                    ToolTip = 'Specifies the customer''s address. This address will appear on all sales documents for the customer.';
                    ApplicationArea = All;
                }
                field("Address 2"; Rec."Address 2")
                {
                    ToolTip = 'Specifies additional address information.';
                    ApplicationArea = All;
                }
                field(City; Rec.City)
                {
                    ToolTip = 'Specifies the customer''s city.';
                    ApplicationArea = All;
                }
                field("Country/Region Code"; Rec."Country/Region Code")
                {
                    ToolTip = 'Specifies the country/region of the address.';
                    ApplicationArea = All;
                }
                field(Name; Rec.Name)
                {
                    ToolTip = 'Specifies the customer''s name.';
                    ApplicationArea = All;
                }
                field("No."; Rec."No.")
                {
                    ToolTip = 'Specifies the number of the customer. The field is either filled automatically from a defined number series, or you enter the number manually because you have enabled manual number entry in the number-series setup.';
                    ApplicationArea = All;
                }
                field("Name 2"; Rec."Name 2")
                {
                    ToolTip = 'Specifies an additional part of the name.';
                    ApplicationArea = All;
                }
                field("Post Code"; Rec."Post Code")
                {
                    ToolTip = 'Specifies the postal code.';
                    ApplicationArea = All;
                }
            }
        }
    }
}