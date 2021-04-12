page 6014496 "NPR Exchange Label"
{
    // NPR5.26/MMV /20160810 CASE 248262 Removed deprecated fields 25 & 26
    // NPR5.26/MMV /20160802 CASE 246998 Added field 30 - Quantity.
    //                                   Added field 32 - Unit of Measure.
    // NPR5.49/MHA /20190211 CASE 345209 Added field 35 "Unit Price"
    // NPR5.51/ALST/20190628 CASE 337539 Added field 35 "Retail Cross Reference No."

    Caption = 'Exchange Label';
    Editable = false;
    PageType = List;
    SourceTable = "NPR Exchange Label";
    UsageCategory = Lists;
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Store ID"; Rec."Store ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Store ID field';
                }
                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the No. field';
                }
                field(Barcode; Rec.Barcode)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Barcode field';
                }
                field("Batch No."; Rec."Batch No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Batch No. field';
                }
                field("No. Series"; Rec."No. Series")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the No. Series field';
                }
                field("Packaged Batch"; Rec."Packaged Batch")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Packaged Batch field';
                }
                field("Valid From"; Rec."Valid From")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Valid From field';
                }
                field("Valid To"; Rec."Valid To")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Valid To field';
                }
                field("Table No."; Rec."Table No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Table No. field';
                }
                field("Register No."; Rec."Register No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the POS Unit No. field';
                }
                field("Sales Ticket No."; Rec."Sales Ticket No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Sales Ticket No. field';
                }
                field("Sales Line No."; Rec."Sales Line No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Sales Line No. field';
                }
                field("Item No."; Rec."Item No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Item No. field';
                }
                field("Variant Code"; Rec."Variant Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Variant Code field';
                }
                field(Quantity; Rec.Quantity)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Quantity field';
                }
                field("Unit Price"; Rec."Unit Price")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Unit Price field';
                }
                field("Sales Price Incl. Vat"; Rec."Sales Price Incl. Vat")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Sales Price Incl. Vat field';
                }
                field("Sales Header Type"; Rec."Sales Header Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Sales Header Type field';
                }
                field("Sales Header No."; Rec."Sales Header No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Sales Header No. field';
                }
                field("Unit of Measure"; Rec."Unit of Measure")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Unit of Measure field';
                }
                field("Company Name"; Rec."Company Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Company Name field';
                }
                field("Printed Date"; Rec."Printed Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Printed Date field';
                }
                field("Retail Cross Reference No."; Rec."Retail Cross Reference No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Retail Cross Reference No. field';
                }
            }
        }
    }

    actions
    {
    }
}

