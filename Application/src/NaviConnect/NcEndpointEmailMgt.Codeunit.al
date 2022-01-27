codeunit 6151525 "NPR Nc Endpoint Email Mgt."
{
    Access = Internal;
    local procedure ProcessNcEndpoints(NcTriggerCode: Code[20]; Output: Text; var NcTask: Record "NPR Nc Task"; Filename: Text; Subject: Text; Body: Text)
    var
        NcEndpoint: Record "NPR Nc Endpoint";
        NcEndpointEmail: Record "NPR Nc Endpoint E-mail";
        NcEndpointTriggerLink: Record "NPR Nc Endpoint Trigger Link";
    begin
        case NcTask."Table No." of
            DATABASE::"NPR Nc Trigger":
                begin
                    NcEndpointTriggerLink.Reset();
                    NcEndpointTriggerLink.SetRange("Trigger Code", NcTriggerCode);
                    if NcEndpointTriggerLink.FindSet() then
                        repeat
                            if NcEndpoint.Get(NcEndpointTriggerLink."Endpoint Code") then begin
                                if NcEndpoint."Endpoint Type" = NcEndpointEmail.GetEndpointTypeCode() then begin
                                    if NcEndpointEmail.Get(NcEndpointTriggerLink."Endpoint Code") then begin
                                        ProcessNcEndpointTrigger(NcTriggerCode, Output, Filename, Subject, Body, NcTask, NcEndpointEmail);
                                    end;
                                end;
                            end;
                        until NcEndpointTriggerLink.Next() = 0;
                end;
            DATABASE::"NPR Nc Endpoint E-mail":
                begin
                    //Process Endpoint Task
                    NcEndpointEmail.SetPosition(NcTask."Record Position");
                    NcEndpointEmail.SetRange(Code, NcEndpointEmail.Code);
                    NcEndpointEmail.SetRange(Enabled, true);
                    if NcEndpointEmail.FindFirst() then begin
                        ProcessEndPointTask(NcEndpointEmail, NcTask, Output, Filename, Subject, Body);
                        NcTask.Modify();
                    end;
                end;
        end;
    end;

    local procedure ProcessNcEndpointTrigger(NcTriggerCode: Code[20]; Output: Text; Filename: Text; Subject: Text; Body: Text; var NcTask: Record "NPR Nc Task"; NcEndpointEmail: Record "NPR Nc Endpoint E-mail")
    var
        NcTrigger: Record "NPR Nc Trigger";
    begin
        if not NcEndpointEmail.Enabled then
            exit;
        NcTrigger.Get(NcTriggerCode);
        if not NcTrigger."Split Trigger and Endpoint" then begin
            //Process Trigger Task Directly
            EmailProcess(NcTask, NcEndpointEmail, Output, Filename, Subject, Body);
            NcTask.Modify();
        end else begin
            //Insert New Task per Endpoint
            InsertEndpointTask(NcEndpointEmail, NcTask, Filename, Subject, Body);
            NcTask.Modify();
        end;
    end;

    local procedure InsertEndpointTask(var NcEndpointEmail: Record "NPR Nc Endpoint E-mail"; var NcTask: Record "NPR Nc Task"; Filename: Text; Subject: Text; Body: Text)
    var
        NcTriggerSyncMgt: Codeunit "NPR Nc Trigger Sync. Mgt.";
        NewTask: Record "NPR Nc Task";
        TempNcEndPointEmail: Record "NPR Nc Endpoint E-mail" temporary;
        RecRef: RecordRef;
        TextTaskInsertedLbl: Label 'Email Task inserted for Nc Endpoint FTP %1 %2, email: %3. Nc Task Entry No. %4.', Comment = '%1=NcEndpointEmail.Code;%2=NcEndpointEmail.Description;%3=NcEndpointEmail."Recipient E-Mail Address";%4=NewTask."Entry No."';
        TaskEntryNo: BigInteger;
    begin
        RecRef.Get(NcEndpointEmail.RecordId);
        NcTriggerSyncMgt.InsertTask(RecRef, TaskEntryNo);
        NewTask.Get(TaskEntryNo);
        TempNcEndPointEmail.Init();
        TempNcEndPointEmail.Copy(NcEndpointEmail);
        TempNcEndPointEmail."Output Nc Task Entry No." := NcTask."Entry No.";
        if Filename <> '' then
            TempNcEndPointEmail."Filename Attachment" := Filename;
        if Subject <> '' then
            TempNcEndPointEmail."Subject Text" := Subject;
        if Body <> '' then
            TempNcEndPointEmail."Body Text" := Body;
        NcTriggerSyncMgt.FillFields(NewTask, TempNcEndPointEmail);
        NcTriggerSyncMgt.AddResponse(NcTask, StrSubstNo(TextTaskInsertedLbl, NcEndpointEmail.Code, NcEndpointEmail.Description, NcEndpointEmail."Recipient E-Mail Address", NewTask."Entry No."));
    end;

    local procedure ProcessEndPointTask(var NcEndpointEmail: Record "NPR Nc Endpoint E-mail"; var NcTask: Record "NPR Nc Task"; Output: Text; Filename: Text; Subject: Text; Body: Text)
    var
        NcTaskMgt: Codeunit "NPR Nc Task Mgt.";
        TextNoOutputErr: Label 'FTP Task not executed because there was no output to send.';
        RecRef: RecordRef;
        FldRef: FieldRef;
    begin
        NcTaskMgt.RestoreRecord(NcTask."Entry No.", RecRef);
        if Output = '' then
            Error(TextNoOutputErr);
        FldRef := RecRef.Field(NcEndpointEmail.FieldNo("Filename Attachment"));
        if Format(FldRef.Value) <> '' then
            Filename := Format(FldRef.Value);
        FldRef := RecRef.Field(NcEndpointEmail.FieldNo("Body Text"));
        if Format(FldRef.Value) <> '' then
            Body := Format(FldRef.Value);
        FldRef := RecRef.Field(NcEndpointEmail.FieldNo("Subject Text"));
        if Format(FldRef.Value) <> '' then
            Subject := Format(FldRef.Value);
        EmailProcess(NcTask, NcEndpointEmail, Output, Filename, Subject, Body);
    end;

    local procedure EmailProcess(var NcTask: Record "NPR Nc Task"; NcEndpointEmail: Record "NPR Nc Endpoint E-mail"; OutputText: Text; Filename: Text; Subject: Text; Body: Text)
    var
        TextEmailFailedErr: Label 'File could not be emailed to %1. STMP returned error: %2.', Comment = '"NPR Nc Endpoint E-mail"."Recipient E-Mail Address";%2=Smtp.ErrorMessage';
        TextEmailSuccessLbl: Label 'File emailed to %1.';
        NcTriggerSyncMgt: Codeunit "NPR Nc Trigger Sync. Mgt.";
        TempEmailItem: Record "Email Item" temporary;
        TempErrorMessage: Record "Error Message" temporary;
        IStream: InStream;
        OStream: OutStream;
        TempBlob: Codeunit "Temp Blob";
        Recipients: List of [Text];
        CCRecipients: List of [Text];
        BCCRecipients: List of [Text];
        Separators: List of [Text];
        EmailSendingHandler: Codeunit "NPR Email Sending Handler";
    begin
        Separators.Add(';');
        Separators.Add(',');
        Recipients := NcEndpointEmail."Recipient E-Mail Address".Split(Separators);
        EmailSendingHandler.CreateEmailItem(TempEmailItem, NcEndpointEmail."Sender Name", NcEndpointEmail."Sender E-Mail Address", Recipients, Subject, Body, true);
        TempBlob.CreateOutStream(OStream, TEXTENCODING::UTF8);
        OStream.WriteText(OutputText);
        TempBlob.CreateInStream(IStream, TEXTENCODING::UTF8);
        EmailSendingHandler.AddAttachmentFromStream(TempEmailItem, IStream, Filename);

        if NcEndpointEmail."CC E-Mail Address" <> '' then begin
            CCRecipients := NcEndpointEmail."CC E-Mail Address".Split(Separators);
            EmailSendingHandler.AddRecipientCC(TempEmailItem, CCRecipients);
        end;

        if NcEndpointEmail."BCC E-Mail Address" <> '' then begin
            BCCRecipients := NcEndpointEmail."BCC E-Mail Address".Split(Separators);
            EmailSendingHandler.AddRecipientBCC(TempEmailItem, CCRecipients);
        end;

        if EmailSendingHandler.Send(TempEmailItem, TempErrorMessage) then
            NcTriggerSyncMgt.AddResponse(NcTask, StrSubstNo(TextEmailSuccessLbl, NcEndpointEmail."Recipient E-Mail Address"))
        else begin
            Error(TextEmailFailedErr, NcEndpointEmail."Recipient E-Mail Address", TempErrorMessage.ToString());
        end;
    end;

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

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR Nc Trigger Task Mgt.", 'OnAfterGetOutputTriggerTask', '', false, false)]
    local procedure OnAfterGetOutputTriggerTaskFTPOutput(NcTriggerCode: Code[20]; Output: Text; var NcTask: Record "NPR Nc Task"; Filename: Text; Subject: Text; Body: Text)
    begin
        ProcessNcEndpoints(NcTriggerCode, Output, NcTask, Filename, Subject, Body);
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

