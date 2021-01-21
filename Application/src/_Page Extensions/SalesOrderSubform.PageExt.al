pageextension 6014447 "NPR Sales Order Subform" extends "Sales Order Subform"
{
    // NPR4.04/MH/20150423  CASE 212082 Changed "Variant Code".VISIBLE from FALSE to TRUE
    // NPR4.04/JDH/20150427  CASE 212229  Removed references to old Variant solution "Color Size"
    // NPR5.22/MHA/20160404 CASE 237825 Added Description 2
    // NPR5.22/TJ/20160412 CASE 238601 Removed unused variables
    // NPR5.29/TJ/20170113 CASE 262797 Removed unused function and functions used as separators
    // NPR5.31/BHR /20170403 CASE 268129 Added field "Units per parcel"
    // NPR5.33/TS  /20170620 CASE 277879 Added Field Net Weight ( Additional )
    layout
    {
        addafter(Description)
        {
            field("NPR Description 2"; "Description 2")
            {
                ApplicationArea = All;
                Visible = false;
                ToolTip = 'Specifies the value of the Description 2 field';
            }
        }
        addafter("Unit Cost (LCY)")
        {
            field("NPR Units per Parcel"; "Units per Parcel")
            {
                ApplicationArea = All;
                Visible = false;
                ToolTip = 'Specifies the value of the Units per Parcel field';
            }
        }
        addafter("Inv. Discount Amount")
        {
            field("NPR Net Weight"; "Net Weight")
            {
                ApplicationArea = All;
                Importance = Additional;
                ToolTip = 'Specifies the value of the Net Weight field';
            }
        }
    }
    actions
    {
        addafter(DocAttach)
        {
            action("NPR Variety")
            {
                Caption = 'Variety';
                Image = ItemVariant;
                Promoted = true;
				PromotedOnly = true;
                PromotedIsBig = true;
                ShortCutKey = 'Ctrl+Alt+V';
                ApplicationArea = All;
                ToolTip = 'Executes the Variety action';
            }
        }
    }
}

