page 6184626 NPRPowerBIVendor
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = Vendor;
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field("Vendor Posting Group"; Rec."Vendor Posting Group")
                {
                    ToolTip = 'Specifies the vendor''s market type to link business transactions made for the vendor with the appropriate account in the general ledger.';
                    ApplicationArea = All;
                }
                field("No."; Rec."No.")
                {
                    ToolTip = 'Specifies the number of the involved entry or record, according to the specified number series.';
                    ApplicationArea = All;
                }
                field(Name; Rec.Name)
                {
                    ToolTip = 'Specifies the vendor''s name. You can enter a maximum of 30 characters, both numbers and letters.';
                    ApplicationArea = All;
                }
                field(City; Rec.City)
                {
                    ToolTip = 'Specifies the vendor''s city.';
                    ApplicationArea = All;
                }
                field("Country/Region Code"; Rec."Country/Region Code")
                {
                    ToolTip = 'Specifies the country/region of the address.';
                    ApplicationArea = All;
                }
                field(County; Rec.County)
                {
                    ToolTip = 'Specifies the state, province or county as a part of the address.';
                    ApplicationArea = All;
                }
                field("Post Code"; Rec."Post Code")
                {
                    ToolTip = 'Specifies the postal code.';
                    ApplicationArea = All;
                }
                field("Global Dimension 1 Code"; Rec."Global Dimension 1 Code")
                {
                    ToolTip = 'Specifies the value of the Global Dimension 1 Code field.';
                    ApplicationArea = All;
                }
                field("Global Dimension 2 Code"; Rec."Global Dimension 2 Code")
                {
                    ToolTip = 'Specifies the value of the Global Dimension 2 Code field.';
                    ApplicationArea = All;
                }
            }
        }
    }
}