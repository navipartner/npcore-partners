#if not BC17
interface "NPR Spfy App Request IHndlr"
{
    Access = Internal;

    procedure ProcessAppRequest(var SpfyAppRequest: Record "NPR Spfy App Request");
    procedure NavigateToRelatedBCEntity(SpfyAppRequest: Record "NPR Spfy App Request");
}
#endif