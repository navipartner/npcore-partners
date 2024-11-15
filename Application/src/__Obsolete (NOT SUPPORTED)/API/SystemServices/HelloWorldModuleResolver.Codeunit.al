#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22
codeunit 6185005 "NPR HelloWorld Module Resolver" implements "NPR REST API Module Resolver"
{
    Access = Internal;
    ObsoleteState = Pending;
    ObsoleteTag = '2024-10-13';
    ObsoleteReason = 'Removed REST from object name';

    procedure Resolve(var Request: Codeunit "NPR REST API Request"): Interface "NPR REST API Request Handler"
    begin
    end;
}
#endif