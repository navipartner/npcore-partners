codeunit 6150876 "NPR POS Action: HTTP Print"
{
    // NPR5.51/MMV /20190812 CASE 342048 Created object


    trigger OnRun()
    begin
    end;

    var
        ACTION_DESC: Label 'Action for sending http print requests';

    local procedure ActionCode(): Text
    begin
        exit('HTTP_PRINT');
    end;

    local procedure ActionVersion(): Text
    begin
        exit('1.01');
    end;

    [EventSubscriber(ObjectType::Table, 6150703, 'OnDiscoverActions', '', false, false)]
    local procedure OnDiscoverAction(var Sender: Record "NPR POS Action")
    begin
        if Sender.DiscoverAction20(
          ActionCode(),
          ACTION_DESC,
          ActionVersion())
        then begin
            Sender.RegisterWorkflow20(
              'let request = new Request($param.Endpoint, { method: "POST", body: atob($param.PrintJob) });' +
              'let response = await fetch(request);' +
              'if (response.status !== 200) {' +
                  'throw new Error("HTTP print error (" + $param.Endpoint + "): " + response.status);' +
              '}'
            );

            Sender.RegisterTextParameter('Endpoint', '');
            Sender.RegisterTextParameter('PrintJob', '');
        end;
    end;

    procedure QueuePrint(URL: Text; Endpoint: Text; PrintBytes: Text; TargetEncoding: Text)
    var
        POSSession: Codeunit "NPR POS Session";
        POSAction: Record "NPR POS Action";
        Convert: DotNet NPRNetConvert;
        Encoding: DotNet NPRNetEncoding;
        POSFrontEndManagement: Codeunit "NPR POS Front End Management";
    begin
        POSSession.GetSession(POSSession, true);
        POSSession.GetFrontEnd(POSFrontEndManagement, true);

        if (StrPos(URL, 'http://') <> 1) and (StrPos(URL, 'https://') <> 1) then
            URL := 'http://' + URL;

        Encoding := Encoding.GetEncoding(TargetEncoding);
        POSFrontEndManagement.QueueWorkflow(ActionCode(), '{"Endpoint": "' + URL + '", "PrintJob": "' + Convert.ToBase64String(Encoding.GetBytes(PrintBytes)) + '"}');
    end;
}

