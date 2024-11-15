#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22
interface "NPR API Request Handler"
{
    procedure Handle(var Request: Codeunit "NPR API Request"): Codeunit "NPR API Response"
}
#endif