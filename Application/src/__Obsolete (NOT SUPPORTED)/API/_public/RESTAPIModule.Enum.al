#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22
enum 6059791 "NPR REST API Module" implements "NPR REST API Module Resolver"
{
    Extensible = true;
    ObsoleteState = Pending;
    ObsoleteTag = '2024-10-13';
    ObsoleteReason = 'Removed REST from object name';

    value(0; helloworld)
    {
        Implementation = "NPR REST API Module Resolver" = "NPR HelloWorld Module Resolver";
    }
}
#endif