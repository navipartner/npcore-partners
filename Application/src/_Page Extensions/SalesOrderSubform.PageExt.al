pageextension 6014447 "NPR Sales Order Subform" extends "Sales Order Subform"
{
    layout
    {
        addafter(Description)
        {
            field("NPR Description 2"; Rec."Description 2")
            {

                Visible = false;
                ToolTip = 'Specifies the value of the Description 2 field';
                ApplicationArea = NPRRetail;
            }
        }
        addafter("Unit Cost (LCY)")
        {
            field("NPR Units per Parcel"; Rec."Units per Parcel")
            {

                Visible = false;
                ToolTip = 'Specifies the value of the Units per Parcel field';
                ApplicationArea = NPRRetail;
            }
        }
        addafter("Inv. Discount Amount")
        {
            field("NPR Net Weight"; Rec."Net Weight")
            {

                Importance = Additional;
                ToolTip = 'Specifies the value of the Net Weight field';
                ApplicationArea = NPRRetail;
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
                PromotedCategory = Process;
                PromotedOnly = true;
                PromotedIsBig = true;
                ShortCutKey = 'Ctrl+Alt+V';

                ToolTip = 'Executes the Variety action';
                ApplicationArea = NPRRetail;
            }
        }
    }
}