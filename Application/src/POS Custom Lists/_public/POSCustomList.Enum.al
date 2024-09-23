enum 6059782 "NPR POS Custom List" implements "NPR POS Custom List IHandler"
{
#if not BC17
    Access = Public;
    UnknownValueImplementation = "NPR POS Custom List IHandler" = "NPR POS List: Undefined";
#endif
    Extensible = true;
    DefaultImplementation = "NPR POS Custom List IHandler" = "NPR POS List: Undefined";

    value(0; UNDEFINED)
    {
        Caption = '<Undefined>';
    }
    value(10; ITEM)
    {
        Caption = 'Items';
        Implementation = "NPR POS Custom List IHandler" = "NPR POS List: Item";
    }
    value(20; ITEM_VARIANT)
    {
        Caption = 'Item Variants';
        Implementation = "NPR POS Custom List IHandler" = "NPR POS List: Item Variant";
    }
    value(30; CUSTOMER)
    {
        Caption = 'Customers';
        Implementation = "NPR POS Custom List IHandler" = "NPR POS List: Customer";
    }
    value(40; MEMBER)
    {
        Caption = 'Members';
        Implementation = "NPR POS Custom List IHandler" = "NPR POS List: Member";
    }
    value(50; TICKET)
    {
        Caption = 'Tickets';
        Implementation = "NPR POS Custom List IHandler" = "NPR POS List: Ticket";
    }
}