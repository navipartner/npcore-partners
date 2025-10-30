#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22
enum 6059812 "NPR API Module" implements "NPR API Module Resolver"
{
    Extensible = true;

    value(0; helloworld)
    {
        Implementation = "NPR API Module Resolver" = "NPR API Hello World Resolver";
    }
    value(1; pos)
    {
        Implementation = "NPR API Module Resolver" = "NPR API POS Resolver";
    }
    value(2; externalpos)
    {
        ObsoleteState = Pending;
        ObsoleteTag = '2025-02-05';
        ObsoleteReason = 'Segment path changed from externalpos to pos.';
        Implementation = "NPR API Module Resolver" = "NPR API External POS Resolver";
    }
    value(3; inventory)
    {
        Implementation = "NPR API Module Resolver" = "NPR API Inventory Resolver";
    }
    value(4; account)
    {
        Implementation = "NPR API Module Resolver" = "NPR UserAccountResolver";
    }
    value(5; customer)
    {
        Implementation = "NPR API Module Resolver" = "NPR API Customer Resolver";
    }
    value(6185039; ticketing)
    {
        Implementation = "NPR API Module Resolver" = "NPR TicketingModuleResolver";
        ObsoleteState = Pending;
        ObsoleteTag = '2024-11-27';
        ObsoleteReason = 'Segment path changed from ticketing to ticket';
    }
    value(6185040; ticket)
    {
        Implementation = "NPR API Module Resolver" = "NPR TicketingModuleResolver";
    }
    value(6185106; memberships)
    {
        Implementation = "NPR API Module Resolver" = "NPR MembershipsModuleResolver";
        ObsoleteState = Pending;
        ObsoleteTag = '2024-11-27';
        ObsoleteReason = 'Segment path changed from /memberships to /membership';
    }
    value(6185107; membership)
    {
        Implementation = "NPR API Module Resolver" = "NPR MembershipsModuleResolver";
    }
    value(6185116; speedgate)
    {
        Implementation = "NPR API Module Resolver" = "NPR ApiSpeedgateResolver";
    }
    value(6185120; voucher)
    {
        Implementation = "NPR API Module Resolver" = "NPR RetailVModuleResolver";
    }
    value(6248328; attractionWallet)
    {
        Implementation = "NPR API Module Resolver" = "NPR AttrWalletModuleResolver";
    }

    value(6248518; ecommerce)
    {
        Implementation = "NPR API Module Resolver" = "NPR EcomResolver";
    }
    value(6248329; loyalty)
    {
        Implementation = "NPR API Module Resolver" = "NPR LoyaltyModuleResolver";
    }

    value(6248598; npdesigner)
    {
        Implementation = "NPR API Module Resolver" = "NPR NPDesignerManifestResolver";
    }
}
#endif