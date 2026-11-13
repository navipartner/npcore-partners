// What a license lets a user do. SKUs map to capabilities in "NPR License Capability Mgt."; gates check
// capabilities, never SKUs.
enum 6014685 "NPR License Capability"
{
    Access = Internal;
    Extensible = false;
    Caption = 'NPR License Capability';

    value(0; _)
    {
        Caption = '', Locked = true;
    }
    // Every NP application area no other capability claims (CapabilityForTag). All SKUs except KDS and Scanner.
    value(1; BackOffice)
    {
        Caption = 'Back Office';
    }
    // Using the POS (name from the portal SKU matrix). Retail POS and Attraction POS.
    value(2; POSEndOfSale)
    {
        Caption = 'POS End of Sale';
    }
    // The #NPRTicket* areas. Attraction POS and Attraction without POS.
    value(3; TicketManagement)
    {
        Caption = 'Ticket Management';
    }
}
