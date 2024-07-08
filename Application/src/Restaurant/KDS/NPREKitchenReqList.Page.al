page 6150691 "NPR NPRE Kitchen Req. List"
{
    Extensible = False;
    Caption = 'Kitchen Request List';
    Editable = false;
    PageType = List;
    UsageCategory = None;
    SourceTable = "NPR NPRE Kitchen Request";

    layout
    {
        area(content)
        {
            repeater("Order Lines")
            {
                Caption = 'Order Lines';
                IndentationColumn = Rec.Indentation;
                IndentationControls = Description;
                field("Request No."; Rec."Request No.")
                {
                    ToolTip = 'Specifies the request unique Id, assigned by the system according to an automatically maintained number series.';
                    ApplicationArea = NPRRetail;
                }
                field("Order ID"; Rec."Order ID")
                {
                    ToolTip = 'Specifies the order Id this request belongs to.';
                    ApplicationArea = NPRRetail;
                }
                field("Line Type"; Rec."Line Type")
                {
                    ToolTip = 'Specifies the type of entity for this request line, such as Item, or Comment.';
                    ApplicationArea = NPRRetail;
                }
                field("No."; Rec."No.")
                {
                    ToolTip = 'Specifies the product you are preparing, if you have chosen "Item" in the Line Type field.';
                    ApplicationArea = NPRRetail;
                }
                field("Variant Code"; Rec."Variant Code")
                {
                    ToolTip = 'Specifies the variant of the item on this line.';
                    ApplicationArea = NPRRetail;
                }
                field(Description; Rec.Description)
                {
                    ToolTip = 'Specifies a description of what you are preparing. Based on your choices in the Line Type and No. fields, the field may show product description or a comment line.';
                    ApplicationArea = NPRRetail;
                }
                field(Quantity; Rec.Quantity)
                {
                    ToolTip = 'Specifies how many units of the product have been requested.';
                    ApplicationArea = NPRRetail;
                }
                field("Unit of Measure Code"; Rec."Unit of Measure Code")
                {
                    ToolTip = 'Specifies how each unit of the product is measured, such as in pieces or boxes.';
                    ApplicationArea = NPRRetail;
                }
                field("Serving Step"; Rec."Serving Step")
                {
                    ToolTip = 'Specifies the meal flow serving step the product of this request is to be served at.';
                    ApplicationArea = NPRRetail;
                }
                field("Created Date-Time"; Rec."Created Date-Time")
                {
                    ToolTip = 'Specifies the date-time the request was created at.';
                    ApplicationArea = NPRRetail;
                }
                field("Expected Dine Date-Time"; Rec."Expected Dine Date-Time")
                {
                    ToolTip = 'Specifies the date-time the customer requested the order be ready at.';
                    ApplicationArea = NPRRetail;
                }
                field("Serving Requested Date-Time"; Rec."Serving Requested Date-Time")
                {
                    ToolTip = 'Specifies the date-time waiter requested serving of the product on the line.';
                    ApplicationArea = NPRRetail;
                }
                field("Line Status"; Rec."Line Status")
                {
                    ToolTip = 'Specifies the status of this request.';
                    ApplicationArea = NPRRetail;
                }
                field("Production Status"; Rec."Production Status")
                {
                    ToolTip = 'Specifies overal production status of the request.';
                    ApplicationArea = NPRRetail;
                }
                field("No. of Kitchen Stations"; Rec."No. of Kitchen Stations")
                {
                    ToolTip = 'Specifies the number of kitchen stations involved in preparation of the product of this request.';
                    ApplicationArea = NPRRetail;
                }
                field("Restaurant Code"; Rec."Restaurant Code")
                {
                    Visible = false;
                    ToolTip = 'Specifies the restaurant the ordered was created for.';
                    ApplicationArea = NPRRetail;
                }
                field(SeatingCodes; SeatingCodes)
                {
                    Caption = 'Seating Code';
                    ToolTip = 'Specifies the seating (table) code(s) the request was created for.';
                    Visible = false;
                    ApplicationArea = NPRRetail;
                }
                field(SeatingNos; SeatingNos)
                {
                    Caption = 'Seating No.';
                    ToolTip = 'Specifies the seating (table) number(s) the request was created for.';
                    ApplicationArea = NPRRetail;
                }
                field(AssignedWaiters; AssignedWaiters)
                {
                    Caption = 'Waiter Code';
                    ToolTip = 'Specifies the waiter (salesperson) code(s) the request was created for.';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        Rec.GetSeatingAndWaiter(AssignedWaiters, SeatingCodes, SeatingNos);
    end;

    var
        AssignedWaiters: Text;
        SeatingCodes: Text;
        SeatingNos: Text;
}
