page 6150661 "NPR NPRE Waiter Pad Subform"
{
    Extensible = False;
    Caption = 'Lines';
    InsertAllowed = false;
    PageType = ListPart;
    SourceTable = "NPR NPRE Waiter Pad Line";
    UsageCategory = None;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(LineIsMarked; LineIsMarked)
                {
                    Caption = 'Select';
                    ToolTip = 'Specifies if this line is selected to be processed by a multi-line action.';
                    ApplicationArea = NPRRetail;

                    trigger OnValidate()
                    begin
                        Rec.Mark(not Rec.Mark());
                    end;
                }
                field("Waiter Pad No."; Rec."Waiter Pad No.")
                {
                    Editable = false;
                    Visible = false;
                    ToolTip = 'Specifies the waiter pad the line belongs to.';
                    ApplicationArea = NPRRetail;
                }
                field("Line No."; Rec."Line No.")
                {
                    Editable = false;
                    Visible = false;
                    ToolTip = 'Specifies a unique number to identify current line.';
                    ApplicationArea = NPRRetail;
                }
                field("Register No."; Rec."Register No.")
                {
                    Editable = false;
                    Visible = false;
                    Caption = 'POS Unit No.';
                    ToolTip = 'Specifies the POS unit number the line was originally created on.';
                    ApplicationArea = NPRRetail;
                }
                field(openedDateTime; Rec.SystemCreatedAt)
                {
                    Caption = 'Opened Date-Time';
                    ToolTip = 'Specifies the date-time the waiter pad was opened at.';
                    Editable = false;
                    Visible = false;
                    ApplicationArea = NPRRetail;
                }
                field(Type; Rec."Line Type")
                {
                    Editable = false;
                    Visible = false;
                    ToolTip = 'Specifies the type of entity for this waiter pad line, such as Item, or Comment.';
                    ApplicationArea = NPRRetail;
                }
                field("No."; Rec."No.")
                {
                    Editable = false;
                    ToolTip = 'Specifies the product you are preparing, if you have chosen "Item" in the Line Type field.';
                    ApplicationArea = NPRRetail;
                }
                field(Description; Rec.Description)
                {
                    Editable = false;
                    ToolTip = 'Specifies a description of what you are preparing. Based on your choices in the Line Type and No. fields, the field may show product description or a comment line.';
                    ApplicationArea = NPRRetail;
                }
                field(Quantity; Rec.Quantity)
                {
                    Editable = false;
                    ToolTip = 'Specifies how many units of the product are being prepared.';
                    ApplicationArea = NPRRetail;
                }
                field("Billed Quantity"; Rec."Billed Quantity")
                {
                    Editable = false;
                    ToolTip = 'Specifies how many units of the product has already been included in a finished sale.';
                    ApplicationArea = NPRRetail;
                }
                field("Description 2"; Rec."Description 2")
                {
                    Editable = false;
                    Visible = false;
                    ToolTip = 'Specifies information in addition to the description.';
                    ApplicationArea = NPRRetail;
                }
                field("Variant Code"; Rec."Variant Code")
                {
                    Editable = false;
                    ToolTip = 'Specifies the variant of the item on the line.';
                    ApplicationArea = NPRRetail;
                }
                field("Order No. from Web"; Rec."Order No. from Web")
                {
                    Editable = false;
                    Visible = false;
                    ToolTip = 'Specifies Magento order number.';
                    ApplicationArea = NPRRetail;
                }
                field("Order Line No. from Web"; Rec."Order Line No. from Web")
                {
                    Editable = false;
                    Visible = false;
                    ToolTip = 'Specifies Magento order line number.';
                    ApplicationArea = NPRRetail;
                }
                field("Unit Price"; Rec."Unit Price")
                {
                    Editable = false;
                    Visible = false;
                    ToolTip = 'Specifies the price for one unit on the waiter pad line.';
                    ApplicationArea = NPRRetail;
                }
                field("Discount Type"; Rec."Discount Type")
                {
                    Editable = false;
                    Visible = false;
                    ToolTip = 'Specifies the discount type granted by the system to the line.';
                    ApplicationArea = NPRRetail;
                }
                field("Discount Code"; Rec."Discount Code")
                {
                    Editable = false;
                    Visible = false;
                    ToolTip = 'Specifies the discount code granted by the system to the line.';
                    ApplicationArea = NPRRetail;
                }
                field("Allow Line Discount"; Rec."Allow Line Discount")
                {
                    Editable = false;
                    Visible = false;
                    ToolTip = 'Specifies if it is allowed granting discounts for the waiter pad line.';
                    ApplicationArea = NPRRetail;
                }
                field("Discount %"; Rec."Discount %")
                {
                    Editable = false;
                    Visible = false;
                    ToolTip = 'Specifies the discount percentage that is granted for the item on the line.';
                    ApplicationArea = NPRRetail;
                }
                field("Discount Amount"; Rec."Discount Amount")
                {
                    Editable = false;
                    Visible = false;
                    ToolTip = 'Specifies the discount amount that is granted for the item on the line.';
                    ApplicationArea = NPRRetail;
                }
                field("Currency Code"; Rec."Currency Code")
                {
                    Editable = false;
                    Visible = false;
                    ToolTip = 'Specifies the currency of amounts on the line.';
                    ApplicationArea = NPRRetail;
                }
                field("Unit of Measure Code"; Rec."Unit of Measure Code")
                {
                    Editable = false;
                    Visible = false;
                    ToolTip = 'Specifies how each unit of the product is measured, such as in pieces or boxes. By default, the value in the Base Unit of Measure field on the item card is inserted.';
                    ApplicationArea = NPRRetail;
                }
                field("Amount Excl. VAT"; Rec."Amount Excl. VAT")
                {
                    Editable = false;
                    Visible = false;
                    ToolTip = 'Specifies the net amount excluding VAT, that must be paid for products on the line.';
                    ApplicationArea = NPRRetail;
                }
                field("Amount Incl. VAT"; Rec."Amount Incl. VAT")
                {
                    Editable = false;
                    Visible = false;
                    ToolTip = 'Specifies the net amount including VAT, that must be paid for products on the line.';
                    ApplicationArea = NPRRetail;
                }
                field("Line Status"; Rec."Line Status")
                {
                    Visible = false;
                    ToolTip = 'Specifies current status code of the line.';
                    ApplicationArea = NPRRetail;
                }
                field("Line Status Description"; Rec."Line Status Description")
                {
                    Editable = false;
                    Visible = false;
                    ToolTip = 'Specifies current status of the line.';
                    ApplicationArea = NPRRetail;
                }
                field(AssignedFlowStatuses; Rec.AssignedFlowStatusesAsString(FlowStatus."Status Object"::WaiterPadLineMealFlow))
                {
                    Caption = 'Serving Steps';
                    Editable = false;
                    ToolTip = 'Specifies the list of serving steps the product is being prepared and served at.';
                    ApplicationArea = NPRRetail;

                    trigger OnDrillDown()
                    begin
                        Rec.ShowFlowStatuses(FlowStatus."Status Object"::WaiterPadLineMealFlow);
                    end;
                }
                field(AssignedPrintCategories; Rec.AssignedPrintCategoriesAsString())
                {
                    Caption = 'Print/Prod. Categories';
                    Editable = false;
                    Visible = false;
                    ToolTip = 'Specifies the list of assigned print/production categories for the line.';
                    ApplicationArea = NPRRetail;

                    trigger OnDrillDown()
                    begin
                        Rec.ShowPrintCategories();
                    end;
                }
                field("Kitchen Order Sent"; Rec."Kitchen Order Sent")
                {
                    ToolTip = 'Specifies if kitchen order has been created and sent to the kitchen for the line.';
                    ApplicationArea = NPRRetail;
                }
                field("Serving Requested"; Rec."Serving Requested")
                {
                    ToolTip = 'Specifies if serving request for the product selected on the line has been sent to the kitchen.';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        LineIsMarked := Rec.Mark();
    end;

    var
        FlowStatus: Record "NPR NPRE Flow Status";
        LineIsMarked: Boolean;

    internal procedure GetSelection(var WaiterPadLine: Record "NPR NPRE Waiter Pad Line")
    begin
        WaiterPadLine.Copy(Rec);
    end;

    internal procedure ClearMarkedLines()
    begin
        Rec.ClearMarks();
    end;
}
