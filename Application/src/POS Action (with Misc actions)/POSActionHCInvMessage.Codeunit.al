codeunit 6150914 "NPR POS Action: HC Inv.Message"
{
    var
        ActionDescription: Label 'This action makes remote call to aquire item price information ';

    local procedure ActionCode(): Text
    begin
        exit('HC_INVMESSAGE');
    end;

    local procedure ActionVersion(): Text
    begin
        exit('1.0');
    end;

    [EventSubscriber(ObjectType::Table, 6150703, 'OnDiscoverActions', '', false, false)]
    local procedure OnDiscoverAction(var Sender: Record "NPR POS Action")
    begin
        with Sender do
            if DiscoverAction(
              ActionCode,
              ActionDescription,
              ActionVersion,
              Type::Generic,
              "Subscriber Instances Allowed"::Multiple)
            then begin
                RegisterWorkflowStep('1', 'respond();');
                RegisterWorkflow(false);

                RegisterBooleanParameter('ShowList', false);
                RegisterBooleanParameter('UseShopLocationAsFilter', false);
                RegisterTextParameter('ExternalLocationFilter', '');

            end;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150701, 'OnAction', '', false, false)]
    local procedure OnAction("Action": Record "NPR POS Action"; WorkflowStep: Text; Context: JsonObject; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean)
    var
        JSON: Codeunit "NPR POS JSON Management";
        POSSale: Codeunit "NPR POS Sale";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        POSHCGenericWebRequest: Codeunit "NPR POS HC Gen. Web Req.";
        SaleLinePOS: Record "NPR POS Sale Line";
        SalePOS: Record "NPR POS Sale";
        EndpointSetup: Record "NPR POS HC Endpoint Setup";
        ParametersText: array[6] of Text;
        ResponseText: array[4] of Text;
        ExtLocationFilter: Text;
    begin
        if not Action.IsThisAction(ActionCode) then
            exit;

        Handled := true;

        POSSession.GetSale(POSSale);
        POSSession.GetSaleLine(POSSaleLine);

        POSSale.GetCurrentSale(SalePOS);

        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);

        JSON.InitializeJObjectParser(Context, FrontEnd);
        ExtLocationFilter := JSON.GetStringParameter('ExternalLocationFilter');
        if JSON.GetBooleanParameter('UseShopLocationAsFilter') then
            ExtLocationFilter := SaleLinePOS."Location Code";
        if JSON.GetBooleanParameter('ShowList') then
            ExtLocationFilter := 'LIST:' + ExtLocationFilter;

        SaleLinePOS.TestField(Type, SaleLinePOS.Type::Item);
        SaleLinePOS.TestField("No.");

        ParametersText[1] := SaleLinePOS."No.";
        ParametersText[2] := SaleLinePOS."Variant Code";
        ParametersText[3] := ExtLocationFilter;

        EndpointSetup.SetFilter(Active, '=%1', true);
        EndpointSetup.FindFirst();

        POSHCGenericWebRequest.CallGenericWebRequest(EndpointSetup.Code, 'INVENTORYMESSAGE', ParametersText, ResponseText);

        if ResponseText[1] <> '' then
            Message(ResponseText[1]);
    end;
}
