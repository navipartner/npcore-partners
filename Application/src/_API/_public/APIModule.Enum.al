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

    value(6185039; ticketing)
    {
        Implementation = "NPR API Module Resolver" = "NPR TicketingModuleResolver";
    }
}
#endif