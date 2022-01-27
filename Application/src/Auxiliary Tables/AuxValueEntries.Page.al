page 6014418 "NPR Aux. Value Entries"
{
    Extensible = False;
    Caption = 'Value Entries';
    PageType = List;
    UsageCategory = None;
    SourceTable = "NPR Aux. Value Entry";
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    DeleteAllowed = false;

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("Entry No."; Rec."Entry No.")
                {

                    ToolTip = 'Specifies the value of the Entry No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Entry Type"; Rec."Entry Type")
                {

                    ToolTip = 'Specifies the value of the Entry Type field';
                    ApplicationArea = NPRRetail;
                }
                field("Posting Date"; Rec."Posting Date")
                {

                    ToolTip = 'Specifies the value of the Posting Date field';
                    ApplicationArea = NPRRetail;
                }
                field("Valuation Date"; Rec."Valuation Date")
                {

                    ToolTip = 'Specifies the value of the Valuation Date field';
                    ApplicationArea = NPRRetail;
                }
                field("Global Dimension 1 Code"; Rec."Global Dimension 1 Code")
                {

                    ToolTip = 'Specifies the value of the Global Dimension 1 Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Global Dimension 2 Code"; Rec."Global Dimension 2 Code")
                {

                    ToolTip = 'Specifies the value of the Global Dimension 2 Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Invoiced Quantity"; Rec."Invoiced Quantity")
                {

                    ToolTip = 'Specifies the value of the Invoiced Quantity field';
                    ApplicationArea = NPRRetail;
                }
                field("Item Category Code"; Rec."Item Category Code")
                {

                    ToolTip = 'Specifies the value of the Item Category Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Item Ledger Entry No."; Rec."Item Ledger Entry No.")
                {

                    ToolTip = 'Specifies the value of the Item Ledger Entry No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Item Ledger Entry Type"; Rec."Item Ledger Entry Type")
                {

                    ToolTip = 'Specifies the value of the Item Ledger Entry Type field';
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
                field("Group Sale"; Rec."Group Sale")
                {

                    ToolTip = 'Specifies the value of the Group Sale field';
                    ApplicationArea = NPRRetail;
                }
                field("Item Charge No."; Rec."Item Charge No.")
                {

                    ToolTip = 'Specifies the value of the Item Charge No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Location Code"; Rec."Location Code")
                {

                    ToolTip = 'Specifies the value of the Location Code field';
                    ApplicationArea = NPRRetail;
                }
                field("POS Unit No."; Rec."POS Unit No.")
                {

                    ToolTip = 'Specifies the value of the Cash Register No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Salespers./Purch. Code"; Rec."Salespers./Purch. Code")
                {

                    ToolTip = 'Specifies the value of the Salespers./Purch. Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Vendor No."; Rec."Vendor No.")
                {

                    ToolTip = 'Specifies the value of the Vendor No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Variance Type"; Rec."Variance Type")
                {

                    ToolTip = 'Specifies the value of the Variance Type field';
                    ApplicationArea = NPRRetail;
                }

                field("Purchase Amount (Actual)"; Rec."Purchase Amount (Actual)")
                {

                    ToolTip = 'Specifies the value of the Purchase Amount (Actual) field';
                    ApplicationArea = NPRRetail;
                }
                field("Purchase Amount (Expected)"; Rec."Purchase Amount (Expected)")
                {

                    ToolTip = 'Specifies the value of the Purchase Amount (Expected) field';
                    ApplicationArea = NPRRetail;
                }
                field("Sales Amount (Actual)"; Rec."Sales Amount (Actual)")
                {

                    ToolTip = 'Specifies the value of the Sales Amount (Actual) field';
                    ApplicationArea = NPRRetail;
                }
                field("Sales Amount (Expected)"; Rec."Sales Amount (Expected)")
                {

                    ToolTip = 'Specifies the value of the Sales Amount (Expected) field';
                    ApplicationArea = NPRRetail;
                }
                field("Cost Amount (Actual)"; Rec."Cost Amount (Actual)")
                {

                    ToolTip = 'Specifies the value of the Cost Amount (Actual) field';
                    ApplicationArea = NPRRetail;
                }
                field("Cost Amount (Expected)"; Rec."Cost Amount (Expected)")
                {

                    ToolTip = 'Specifies the value of the Cost Amount (Expected) field';
                    ApplicationArea = NPRRetail;
                }
                field("Discount Code"; Rec."Discount Code")
                {

                    ToolTip = 'Specifies the value of the Discount Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Discount Type"; Rec."Discount Type")
                {

                    ToolTip = 'Specifies the value of the Discount Type field';
                    ApplicationArea = NPRRetail;
                }
                field("Discount Amount"; Rec."Discount Amount")
                {

                    ToolTip = 'Specifies the value of the Discount Amount field';
                    ApplicationArea = NPRRetail;
                }
                field("Document Date and Time"; Rec."Document Date and Time")
                {

                    ToolTip = 'Specifies the value of the Document Date and Time field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }
}
