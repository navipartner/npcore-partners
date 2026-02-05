codeunit 6151525 "NPR Nc Endpoint Email Mgt."
{
    ObsoleteState = Pending;
    ObsoleteTag = '2026-01-29';
    ObsoleteReason = 'This module is no longer being maintained';
    Access = Internal;

    local procedure EmailProcessOutput(NcTaskOutput: Record "NPR Nc Task Output"; NcEndpointEmail: Record "NPR Nc Endpoint E-mail")
    var
        TextEmailFailedErr: Label 'File could not be emailed to %1. STMP returned error: %2.';
        TempEmailItem: Record "Email Item" temporary;
        TempErrorMessage: Record "Error Message" temporary;
        InStr: InStream;
        Recipients: List of [Text];
        CCRecipients: List of [Text];
        BCCRecipients: List of [Text];
        Separators: List of [Text];
        EmailSendingHandler: Codeunit "NPR Email Sending Handler";
    begin
        Separators.Add(';');
        Separators.Add(',');

        Recipients := NcEndpointEmail."Recipient E-Mail Address".Split(Separators);
        EmailSendingHandler.CreateEmailItem(TempEmailItem,
          NcEndpointEmail."Sender Name", NcEndpointEmail."Sender E-Mail Address",
          Recipients, NcEndpointEmail."Subject Text", NcEndpointEmail."Body Text", true);

        NcTaskOutput.Data.CreateInStream(InStr, TEXTENCODING::UTF8);
        EmailSendingHandler.AddAttachmentFromStream(TempEmailItem, InStr, NcTaskOutput.Name);
        if NcEndpointEmail."CC E-Mail Address" <> '' then begin
            CCRecipients := NcEndpointEmail."CC E-Mail Address".Split(Separators);
            EmailSendingHandler.AddRecipientCC(TempEmailItem, CCRecipients);
        end;

        if NcEndpointEmail."BCC E-Mail Address" <> '' then begin
            BCCRecipients := NcEndpointEmail."BCC E-Mail Address".Split(Separators);
            EmailSendingHandler.AddRecipientBCC(TempEmailItem, BCCRecipients);
        end;

        if not EmailSendingHandler.Send(TempEmailItem, TempErrorMessage) then begin
            Error(TextEmailFailedErr, NcEndpointEmail."Recipient E-Mail Address", TempErrorMessage.ToString());
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR Nc Endpoint Type", 'OnSetupEndpointTypes', '', false, false)]
    local procedure OnSetupEndpointTypeInsertEndpointTypeCode()
    var
        NcEndpointEmail: Record "NPR Nc Endpoint E-mail";
        NcEndpointType: Record "NPR Nc Endpoint Type";
    begin
        if not NcEndpointType.Get(NcEndpointEmail.GetEndpointTypeCode()) then begin
            NcEndpointType.Init();
            NcEndpointType.Code := NcEndpointEmail.GetEndpointTypeCode();
            NcEndpointType.Insert();
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR Nc Endpoint", 'OnOpenEndpointSetup', '', false, false)]
    local procedure OnOpenEndpointSetupOpenPage(var Sender: Record "NPR Nc Endpoint"; var Handled: Boolean)
    var
        NcEndpointEmail: Record "NPR Nc Endpoint E-mail";
    begin
        if Handled then
            exit;
        if Sender."Endpoint Type" <> NcEndpointEmail.GetEndpointTypeCode() then
            exit;
        if not NcEndpointEmail.Get(Sender.Code) then begin
            NcEndpointEmail.Init();
            NcEndpointEmail.Validate(Code, Sender.Code);
            NcEndpointEmail.Description := Sender.Description;
            NcEndpointEmail.Insert();
        end else begin
            if NcEndpointEmail.Description <> Sender.Description then begin
                NcEndpointEmail.Description := Sender.Description;
                NcEndpointEmail.Modify(true);
            end;
        end;
        PAGE.Run(PAGE::"NPR Nc Endpoint E-mail Card", NcEndpointEmail);
        Handled := true;
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR Nc Endpoint", 'OnAfterDeleteEvent', '', false, false)]
    local procedure OnDeleteEndpoint(var Rec: Record "NPR Nc Endpoint"; RunTrigger: Boolean)
    var
        NcEndpointEmail: Record "NPR Nc Endpoint E-mail";
    begin
        if NcEndpointEmail.Get(Rec.Code) then
            NcEndpointEmail.Delete(true);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR Nc Endpoint Mgt.", 'OnRunEndpoint', '', true, true)]
    local procedure OnRunEndpoint(NcTaskOutput: Record "NPR Nc Task Output"; NcEndpoint: Record "NPR Nc Endpoint")
    var
        NcEndpointEmail: Record "NPR Nc Endpoint E-mail";
    begin
        if NcEndpoint."Endpoint Type" <> NcEndpointEmail.GetEndpointTypeCode() then
            exit;
        if not NcEndpointEmail.Get(NcEndpoint.Code) then
            exit;

        EmailProcessOutput(NcTaskOutput, NcEndpointEmail);
    end;
}

