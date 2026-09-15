#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22
page 6150979 "NPR Ecom Billing Events"
{
    Caption = 'Ecommerce Billing Events';
    PageType = List;
    SourceTable = "NPR Ecom Billing Event";
    UsageCategory = Administration;
    ApplicationArea = NPRRetail;
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    DeleteAllowed = false;
    Extensible = false;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Entry No."; Rec."Entry No.")
                {
                    ToolTip = 'Specifies the unique identifier of the ecommerce billing event entry.';
                    ApplicationArea = NPRRetail;
                }
                field(Channel; Rec.Channel)
                {
                    ToolTip = 'Specifies the ecommerce channel the billable order was imported from.';
                    ApplicationArea = NPRRetail;
                }
                field("Store Code"; Rec."Store Code")
                {
                    ToolTip = 'Specifies the ecommerce store the billable order belongs to.';
                    ApplicationArea = NPRRetail;
                }
                field("External No."; Rec."External No.")
                {
                    ToolTip = 'Specifies the order number shown to the customer on the ecommerce platform.';
                    ApplicationArea = NPRRetail;
                }
                field("Event Type"; Rec."Event Type")
                {
                    ToolTip = 'Specifies whether the row is the order count event or one of the amount events.';
                    ApplicationArea = NPRRetail;
                }
                field(Amount; Rec.Amount)
                {
                    ToolTip = 'Specifies the quantity or amount that was registered with the billing event, in the currency code shown on this row. A count is a plain quantity; an amount is a delta.';
                    ApplicationArea = NPRRetail;
                }
                field("Currency Code"; Rec."Currency Code")
                {
                    ToolTip = 'Specifies the currency of the amount on this row.';
                    ApplicationArea = NPRRetail;
                }
                field("Registered At"; Rec."Registered At")
                {
                    ToolTip = 'Specifies when the billing event was registered.';
                    ApplicationArea = NPRRetail;
                }
                field("Billing Queue Entry No."; Rec."Billing Queue Entry No.")
                {
                    ToolTip = 'Specifies the billing queue entry that carries this event.';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }
}
#endif
