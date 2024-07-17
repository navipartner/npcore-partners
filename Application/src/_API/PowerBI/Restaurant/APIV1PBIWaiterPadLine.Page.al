page 6060000 "NPR APIV1 PBIWaiterPadLine"
{
    APIGroup = 'powerBI';
    APIPublisher = 'navipartner';
    APIVersion = 'v1.0';
    PageType = API;
    EntityName = 'waiterPadLine';
    EntitySetName = 'waiterPadLines';
    Caption = 'PowerBI Waiter Pad Line';
    DataAccessIntent = ReadOnly;
    ODataKeyFields = SystemId;
    DelayedInsert = true;
    SourceTable = "NPR NPRE Waiter Pad Line";
    Extensible = false;
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field(id; Rec.SystemId)
                {
                    Caption = 'SystemId', Locked = true;
                }
                field(waiterPadNo; Rec."Waiter Pad No.")
                {
                    Caption = 'Waiter Pad No.', Locked = true;
                }
                field(lineNo; Rec."Line No.")
                {
                    Caption = 'Line No.', Locked = true;
                }
                field(openedDateTime; Rec.SystemCreatedAt)
                {
                    Caption = 'Opened Date-Time', Locked = true;
                }
                field(amountExclVat; Rec."Amount Excl. VAT")
                {
                    Caption = 'Amount Excl. VAT', Locked = true;
                }
                field(amountInclVat; Rec."Amount Incl. VAT")
                {
                    Caption = 'Amount Incl. VAT', Locked = true;
                }
                field(orderLineNoFromWeb; Rec."Order Line No. from Web")
                {
                    Caption = 'Order Line No. from Web', Locked = true;
                }
                field(unitPrice; Rec."Unit Price")
                {
                    Caption = 'Unit Price', Locked = true;
                }
                field(type; Rec."Line Type")
                {
                    Caption = 'Type', Locked = true;
                }
                field(no; Rec."No.")
                {
                    Caption = 'No.', Locked = true;
                }
                field(orderNoFromWeb; Rec."Order No. from Web")
                {
                    Caption = 'Order No. from Web', Locked = true;
                }
                field(quantity; Rec.Quantity)
                {
                    Caption = 'Quantity', Locked = true;
                }
                field(discountAmount; Rec."Discount Amount")
                {
                    Caption = 'Discount Amount', Locked = true;
                }
                field(priceIncludesVat; Rec."Price Includes VAT")
                {
                    Caption = 'Price Includes VAT', Locked = true;
                }
            }
        }
    }
}