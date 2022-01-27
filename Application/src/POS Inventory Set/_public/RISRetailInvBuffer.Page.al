page 6151088 "NPR RIS Retail Inv. Buffer"
{
    Caption = 'Retail Inventory';
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    UsageCategory = None;
    SourceTable = "NPR RIS Retail Inv. Buffer";

    layout
    {
        area(content)
        {
            repeater(Group)
            {

                field("Phys. Inventory"; Rec."Phys. Inventory")
                {
                    Style = Attention;
                    StyleExpr = Rec."Processing Error";
                    ToolTip = 'Specifies the value of the "Phys. Inventory" field calculated in company defined under the "Company Name" with respect to applied filters';
                    ApplicationArea = NPRRetail;
                }
                field("Qty. on Sales Order"; Rec."Qty. on Sales Order")
                {
                    Style = Attention;
                    StyleExpr = Rec."Processing Error";
                    ToolTip = 'Specifies the value of the "Qty. on Sales Order" field calculated in company defined under the "Company Name" with respect to applied filters';
                    ApplicationArea = NPRRetail;
                }
                field(Inventory; Rec.Inventory)
                {
                    Style = Attention;
                    StyleExpr = Rec."Processing Error";
                    ToolTip = 'Specifies the value of the Inventory ("Phys. Inventory" - "Qty. on Sales Order") field calculated in company defined under the "Company Name" with respect to applied filters';
                    ApplicationArea = NPRRetail;
                }
                field("Qty. on Sales Return"; Rec."Qty. on Sales Return")
                {
                    Style = Attention;
                    StyleExpr = Rec."Processing Error";
                    ToolTip = 'Specifies the value of the "Qty. on Sales Return" field calculated in company defined under the "Company Name" with respect to applied filters';
                    ApplicationArea = NPRRetail;
                    Visible = false;
                }
                field("Qty. on Purch. Order"; Rec."Qty. on Purch. Order")
                {
                    Style = Attention;
                    StyleExpr = Rec."Processing Error";
                    ToolTip = 'Specifies the value of the "Qty. on Purch. Order" field calculated in company defined under the "Company Name" with respect to applied filters';
                    ApplicationArea = NPRRetail;
                }
                field("Qty. on Purch. Return"; Rec."Qty. on Purch. Return")
                {
                    Style = Attention;
                    StyleExpr = Rec."Processing Error";
                    ToolTip = 'Specifies the value of the "Qty. on Purch. Return" field calculated in company defined under the "Company Name" with respect to applied filters';
                    ApplicationArea = NPRRetail;
                    Visible = false;
                }
                field("Company Name"; Rec."Company Name")
                {
                    Style = Attention;
                    StyleExpr = Rec."Processing Error";
                    ToolTip = 'Specifies company where Item Available quantities will be calculated with respect to applied filters';
                    ApplicationArea = NPRRetail;
                }
                field("Location Filter"; Rec."Location Filter")
                {
                    ToolTip = 'Specified filter will be applied in quantities calculation.';
                    ApplicationArea = NPRRetail;
                }
                field("Variant Filter"; Rec."Variant Filter")
                {
                    ToolTip = 'Specified filter will be applied in quantities calculation.';
                    ApplicationArea = NPRRetail;
                    Visible = false;
                }
                field("Global Dimension 1 Filter"; Rec."Global Dimension 1 Filter")
                {
                    ToolTip = 'Specified filter will be applied in quantities calculation.';
                    ApplicationArea = NPRRetail;
                    Visible = false;
                }
                field("Global Dimension 2 Filter"; Rec."Global Dimension 2 Filter")
                {
                    ToolTip = 'Specified filter will be applied in quantities calculation.';
                    ApplicationArea = NPRRetail;
                    Visible = false;
                }
                field("Drop Shipment Filter"; Rec."Drop Shipment Filter")
                {
                    ToolTip = 'Specified filter will be applied in quantities calculation.';
                    ApplicationArea = NPRRetail;
                    Visible = false;
                }
                field("Lot No. Filter"; Rec."Lot No. Filter")
                {
                    ToolTip = 'Specified filter will be applied in quantities calculation.';
                    ApplicationArea = NPRRetail;
                    Visible = false;
                }
                field("Serial No. Filter"; Rec."Serial No. Filter")
                {
                    ToolTip = 'Specified filter will be applied in quantities calculation.';
                    ApplicationArea = NPRRetail;
                    Visible = false;
                }
                field("Unit of Measure Filter"; Rec."Unit of Measure Filter")
                {
                    ToolTip = 'Specified filter will be applied in quantities calculation.';
                    ApplicationArea = NPRRetail;
                    Visible = false;
                }
                field("Date Filter"; Rec."Date Filter")
                {
                    ToolTip = 'Specified filter will be applied in quantities calculation.';
                    ApplicationArea = NPRRetail;
                    Visible = false;
                }
                field("Processing Error Message"; Rec."Processing Error Message")
                {
                    Visible = ProcessingErrorExists;
                    ToolTip = 'Specifies the value of the Processing Error Message field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }

    trigger OnOpenPage()
    var
        RetailInventoryBuffer: Record "NPR RIS Retail Inv. Buffer";
    begin
        RetailInventoryBuffer.Copy(Rec, true);
        RetailInventoryBuffer.SetRange("Processing Error", true);
        ProcessingErrorExists := not RetailInventoryBuffer.IsEmpty();
    end;

    var
        ProcessingErrorExists: Boolean;
}
