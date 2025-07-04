#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22
interface "NPR MembershipApiAddProperties"
{
#if not BC17
    Access = Internal;
#endif
    procedure AddProperties(var Json: Codeunit "NPR JSON Builder"; var RecRef: RecordRef): Codeunit "NPR JSON Builder";
}
#endif