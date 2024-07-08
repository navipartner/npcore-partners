page 6014496 "NPR Exchange Label"
{
    Extensible = False;
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
    ApplicationArea = NPRRetail;


    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Store ID"; Rec."Store ID")
                {

                    ToolTip = 'Specifies the value of the Store ID field';
                    ApplicationArea = NPRRetail;
                }
                field("No."; Rec."No.")
                {

                    ToolTip = 'Specifies the value of the No. field';
                    ApplicationArea = NPRRetail;
                }
                field(Barcode; Rec.Barcode)
                {

                    ToolTip = 'Specifies the value of the Barcode field';
                    ApplicationArea = NPRRetail;
                }
                field("Batch No."; Rec."Batch No.")
                {

                    ToolTip = 'Specifies the value of the Batch No. field';
                    ApplicationArea = NPRRetail;
                }
                field("No. Series"; Rec."No. Series")
                {

                    ToolTip = 'Specifies the value of the No. Series field';
                    ApplicationArea = NPRRetail;
                }
                field("Packaged Batch"; Rec."Packaged Batch")
                {

                    ToolTip = 'Specifies the value of the Packaged Batch field';
                    ApplicationArea = NPRRetail;
                }
                field("Valid From"; Rec."Valid From")
                {

                    ToolTip = 'Specifies the value of the Valid From field';
                    ApplicationArea = NPRRetail;
                }
                field("Valid To"; Rec."Valid To")
                {

                    ToolTip = 'Specifies the value of the Valid To field';
                    ApplicationArea = NPRRetail;
                }
                field("Table No."; Rec."Table No.")
                {

                    ToolTip = 'Specifies the value of the Table No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Register No."; Rec."Register No.")
                {

                    ToolTip = 'Specifies the value of the POS Unit No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Sales Ticket No."; Rec."Sales Ticket No.")
                {

                    ToolTip = 'Specifies the value of the Sales Ticket No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Sales Line No."; Rec."Sales Line No.")
                {

                    ToolTip = 'Specifies the value of the Sales Line No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Item No."; Rec."Item No.")
                {

                    ToolTip = 'Specifies the value of the Item No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Variant Code"; Rec."Variant Code")
                {

                    ToolTip = 'Specifies the value of the Variant Code field';
                    ApplicationArea = NPRRetail;
                }
                field(Quantity; Rec.Quantity)
                {

                    ToolTip = 'Specifies the value of the Quantity field';
                    ApplicationArea = NPRRetail;
                }
                field("Unit Price"; Rec."Unit Price")
                {

                    ToolTip = 'Specifies the value of the Unit Price field';
                    ApplicationArea = NPRRetail;
                }
                field("Sales Price Incl. Vat"; Rec."Sales Price Incl. Vat")
                {

                    ToolTip = 'Specifies the value of the Sales Price Incl. Vat field';
                    ApplicationArea = NPRRetail;
                }
                field("Sales Header Type"; Rec."Sales Header Type")
                {

                    ToolTip = 'Specifies the value of the Sales Header Type field';
                    ApplicationArea = NPRRetail;
                }
                field("Sales Header No."; Rec."Sales Header No.")
                {

                    ToolTip = 'Specifies the value of the Sales Header No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Unit of Measure"; Rec."Unit of Measure")
                {

                    ToolTip = 'Specifies the value of the Unit of Measure field';
                    ApplicationArea = NPRRetail;
                }
                field("Company Name"; Rec."Company Name")
                {

                    ToolTip = 'Specifies the value of the Company Name field';
                    ApplicationArea = NPRRetail;
                }
                field("Printed Date"; Rec."Printed Date")
                {

                    ToolTip = 'Specifies the value of the Printed Date field';
                    ApplicationArea = NPRRetail;
                }
                field("Retail Cross Reference No."; Rec."Retail Cross Reference No.")
                {

                    ToolTip = 'Specifies the value of the Retail Cross Reference No. field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }

    actions
    {
    }
}

