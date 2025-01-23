codeunit 6248234 "NPR POS Workflow Events"
{
    Access = Public;

    /// <summary>
    /// This event allows the subscriber to inject additional parameters to an existing action.
    /// </summary>
    /// <param name="POSActionParamBuf">Facade to add more parameters.</param>
    [IntegrationEvent(false, false)]
    internal procedure OnRefreshActionOnAfterRegister(var POSActionParamBuf: Codeunit "NPR POS Action Param Buf.")
    begin
    end;
}