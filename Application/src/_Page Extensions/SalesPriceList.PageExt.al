pageextension 6014444 "NPR SalesPriceList" extends "Sales Price List"
{
    layout
    {
        addafter(EndingDate)
        {
            field("NPR Retail Price List"; Rec."NPR Retail Price List")
            {
                ToolTip = 'Specifies the value of the Retail Price List field.';
                ApplicationArea = NPRRetail;
                trigger OnValidate()
                begin
                    CheckIfRetailPriceList();
                end;
            }
            field("NPR Location Code"; Rec."NPR Location Code")
            {
                ToolTip = 'Specifies Location Code for Sales Price List';
                ApplicationArea = NPRRetail;
                Editable = LocationCodeEnabled;
            }
        }
    }
    trigger OnOpenPage()
    begin
        CheckIfRetailPriceList();
    end;

    var
        LocationCodeEnabled: Boolean;

    local procedure CheckIfRetailPriceList()
    begin
        LocationCodeEnabled := Rec."NPR Retail Price List";
        if not LocationCodeEnabled then
            Clear(Rec."NPR Location Code");
    end;
}