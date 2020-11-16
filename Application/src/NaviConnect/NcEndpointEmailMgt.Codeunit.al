codeunit 6151525 "NPR Nc Endpoint Email Mgt."
{
    // NC2.01/BR /20160818  CASE 248630 NaviConnect
    // NC2.01/BR /20161028  CASE 248630 Fix BCC
    // NC2.12/MHA /20180418  CASE 308107 Added functions EmailProcessOutput(),OnRunEndpoint()


    trigger OnRun()
    begin
    end;

    local procedure ProcessNcEndpoints(NcTriggerCode: Code[20]; Output: Text; var NcTask: Record "NPR Nc Task"; Filename: Text; Subject: Text; Body: Text)
    var
        NcTrigger: Record "NPR Nc Trigger";
        NcEndpoint: Record "NPR Nc Endpoint";
        NcEndpointEmail: Record "NPR Nc Endpoint E-mail";
        NcEndpointTriggerLink: Record "NPR Nc Endpoint Trigger Link";
    begin
        case NcTask."Table No." of
            DATABASE::"NPR Nc Trigger":
                begin
                    NcEndpointTriggerLink.Reset;
                    NcEndpointTriggerLink.SetRange("Trigger Code", NcTriggerCode);
                    if NcEndpointTriggerLink.FindSet then
                        repeat
                            if NcEndpoint.Get(NcEndpointTriggerLink."Endpoint Code") then begin
                                if NcEndpoint."Endpoint Type" = NcEndpointEmail.GetEndpointTypeCode then begin
                                    if NcEndpointEmail.Get(NcEndpointTriggerLink."Endpoint Code") then begin
                                        ProcessNcEndpointTrigger(NcTriggerCode, Output, Filename, Subject, Body, NcTask, NcEndpointEmail);
                                    end;
                                end;
                            end;
                        until NcEndpointTriggerLink.Next = 0;
                end;
            DATABASE::"NPR Nc Endpoint E-mail":
                begin
                    //Process Endpoint Task
                    NcEndpointEmail.SetPosition(NcTask."Record Position");
                    NcEndpointEmail.SetRange(Code, NcEndpointEmail.Code);
                    NcEndpointEmail.SetRange(Enabled, true);
                    if NcEndpointEmail.FindFirst then begin
                        ProcessEndPointTask(NcEndpointEmail, NcTask, Output, Filename, Subject, Body);
                        NcTask.Modify;
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
            NcTask.Modify;
        end else begin
            //Insert New Task per Endpoint
            InsertEndpointTask(NcEndpointEmail, NcTask, Filename, Subject, Body);
            NcTask.Modify;
        end;
    end;

    local procedure InsertEndpointTask(var NcEndpointEmail: Record "NPR Nc Endpoint E-mail"; var NcTask: Record "NPR Nc Task"; Filename: Text; Subject: Text; Body: Text)
    var
        NcTriggerSyncMgt: Codeunit "NPR Nc Trigger Sync. Mgt.";
        NewTask: Record "NPR Nc Task";
        TempNcEndPointEmail: Record "NPR Nc Endpoint E-mail" temporary;
        RecRef: RecordRef;
        TextTaskInserted: Label 'Email Task inserted for Nc Endpoint FTP %1 %2, email: %3. Nc Task Entry No. %4.';
        TaskEntryNo: BigInteger;
    begin
        RecRef.Get(NcEndpointEmail.RecordId);
        NcTriggerSyncMgt.InsertTask(RecRef, TaskEntryNo);
        NewTask.Get(TaskEntryNo);
        TempNcEndPointEmail.Init;
        TempNcEndPointEmail.Copy(NcEndpointEmail);
        TempNcEndPointEmail."Output Nc Task Entry No." := NcTask."Entry No.";
        if Filename <> '' then
            TempNcEndPointEmail."Filename Attachment" := Filename;
        if Subject <> '' then
            TempNcEndPointEmail."Subject Text" := Subject;
        if Body <> '' then
            TempNcEndPointEmail."Body Text" := Body;
        NcTriggerSyncMgt.FillFields(NewTask, TempNcEndPointEmail);
        NcTriggerSyncMgt.AddResponse(NcTask, StrSubstNo(TextTaskInserted, NcEndpointEmail.Code, NcEndpointEmail.Description, NcEndpointEmail."Recipient E-Mail Address", NewTask."Entry No."));
    end;

    local procedure ProcessEndPointTask(var NcEndpointEmail: Record "NPR Nc Endpoint E-mail"; var NcTask: Record "NPR Nc Task"; Output: Text; Filename: Text; Subject: Text; Body: Text)
    var
        NcTaskMgt: Codeunit "NPR Nc Task Mgt.";
        TextNoOutput: Label 'FTP Task not executed because there was no output to send.';
        RecRef: RecordRef;
        FldRef: FieldRef;
    begin
        NcTaskMgt.RestoreRecord(NcTask."Entry No.", RecRef);
        if Output = '' then
            Error(TextNoOutput);
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
        ResponseDescriptionText: Text;
        ResponseCodeText: Text;
        TextEmailFailed: Label 'File could not be emailed to %1. STMP returned error: %2.';
        TextEmailSuccess: Label 'File emailed to %1.';
        NcTriggerSyncMgt: Codeunit "NPR Nc Trigger Sync. Mgt.";
        SMTPMail: Codeunit "SMTP Mail";
        IStream: InStream;
        OStream: OutStream;
        TempBlob: Codeunit "Temp Blob";
        Recipients: List of [Text];
        CCRecipients: List of [Text];
        BCCRecipients: List of [Text];
        Separators: List of [Text];
    begin
        Separators.Add(';');
        Separators.Add(',');
        Recipients := NcEndpointEmail."Recipient E-Mail Address".Split(Separators);
        SMTPMail.CreateMessage(NcEndpointEmail."Sender Name", NcEndpointEmail."Sender E-Mail Address", Recipients, Subject, Body, true);
        TempBlob.CreateOutStream(OStream, TEXTENCODING::UTF8);
        OStream.WriteText(OutputText);
        TempBlob.CreateInStream(IStream, TEXTENCODING::UTF8);
        SMTPMail.AddAttachmentStream(IStream, Filename);

        if NcEndpointEmail."CC E-Mail Address" <> '' then begin
            CCRecipients := NcEndpointEmail."CC E-Mail Address".Split(Separators);
            SMTPMail.AddCC(CCRecipients);
        end;

        if NcEndpointEmail."BCC E-Mail Address" <> '' then begin
            BCCRecipients := NcEndpointEmail."BCC E-Mail Address".Split(Separators);
            SMTPMail.AddBCC(BCCRecipients);
        end;

        if SMTPMail.Send then begin
            //Positive Response
            NcTriggerSyncMgt.AddResponse(NcTask, StrSubstNo(TextEmailSuccess, NcEndpointEmail."Recipient E-Mail Address"));
        end else begin
            //Negative Response
            Error(TextEmailFailed, NcEndpointEmail."Recipient E-Mail Address", SMTPMail.GetLastSendMailErrorText);
        end;
    end;

    local procedure EmailProcessOutput(NcTaskOutput: Record "NPR Nc Task Output"; NcEndpointEmail: Record "NPR Nc Endpoint E-mail")
    var
        TextEmailFailed: Label 'File could not be emailed to %1. STMP returned error: %2.';
        TextEmailSuccess: Label 'File emailed to %1.';
        SMTPMail: Codeunit "SMTP Mail";
        InStream: InStream;
        Recipients: List of [Text];
        CCRecipients: List of [Text];
        BCCRecipients: List of [Text];
        Separators: List of [Text];
    begin
        Separators.Add(';');
        Separators.Add(',');

        //-NC2.12 [308107]
        Recipients := NcEndpointEmail."Recipient E-Mail Address".Split(Separators);
        SMTPMail.CreateMessage(
          NcEndpointEmail."Sender Name", NcEndpointEmail."Sender E-Mail Address",
          Recipients, NcEndpointEmail."Subject Text", NcEndpointEmail."Body Text", true);

        NcTaskOutput.Data.CreateInStream(InStream, TEXTENCODING::UTF8);
        SMTPMail.AddAttachmentStream(InStream, NcTaskOutput.Name);

        if NcEndpointEmail."CC E-Mail Address" <> '' then begin
            CCRecipients := NcEndpointEmail."CC E-Mail Address".Split(Separators);
            SMTPMail.AddCC(CCRecipients);
        end;

        if NcEndpointEmail."BCC E-Mail Address" <> '' then begin
            BCCRecipients := NcEndpointEmail."BCC E-Mail Address".Split(Separators);
            SMTPMail.AddBCC(BCCRecipients);
        end;

        if not SMTPMail.Send then
            Error(TextEmailFailed, NcEndpointEmail."Recipient E-Mail Address", SMTPMail.GetLastSendMailErrorText);
        //+NC2.12 [308107]
    end;

    local procedure "---Subscribers"()
    begin
    end;

    [EventSubscriber(ObjectType::Codeunit, 6151522, 'OnAfterGetOutputTriggerTask', '', false, false)]
    local procedure OnAfterGetOutputTriggerTaskFTPOutput(NcTriggerCode: Code[20]; Output: Text; var NcTask: Record "NPR Nc Task"; Filename: Text; Subject: Text; Body: Text)
    begin
        ProcessNcEndpoints(NcTriggerCode, Output, NcTask, Filename, Subject, Body);
    end;

    [EventSubscriber(ObjectType::Table, 6151531, 'OnSetupEndpointTypes', '', false, false)]
    local procedure OnSetupEndpointTypeInsertEndpointTypeCode()
    var
        NcEndpointEmail: Record "NPR Nc Endpoint E-mail";
        NcEndpointType: Record "NPR Nc Endpoint Type";
    begin
        if not NcEndpointType.Get(NcEndpointEmail.GetEndpointTypeCode) then begin
            NcEndpointType.Init;
            NcEndpointType.Code := NcEndpointEmail.GetEndpointTypeCode;
            NcEndpointType.Insert;
        end;
    end;

    [EventSubscriber(ObjectType::Table, 6151533, 'OnOpenEndpointSetup', '', false, false)]
    local procedure OnOpenEndpointSetupOpenPage(var Sender: Record "NPR Nc Endpoint"; var Handled: Boolean)
    var
        NcEndpointEmail: Record "NPR Nc Endpoint E-mail";
    begin
        if Handled then
            exit;
        if Sender."Endpoint Type" <> NcEndpointEmail.GetEndpointTypeCode then
            exit;
        if not NcEndpointEmail.Get(Sender.Code) then begin
            NcEndpointEmail.Init;
            NcEndpointEmail.Validate(Code, Sender.Code);
            NcEndpointEmail.Description := Sender.Description;
            NcEndpointEmail.Insert;
        end else begin
            if NcEndpointEmail.Description <> Sender.Description then begin
                NcEndpointEmail.Description := Sender.Description;
                NcEndpointEmail.Modify(true);
            end;
        end;
        PAGE.Run(PAGE::"NPR Nc Endpoint E-mail Card", NcEndpointEmail);
        Handled := true;
    end;

    [EventSubscriber(ObjectType::Table, 6151533, 'OnAfterDeleteEvent', '', false, false)]
    local procedure OnDeleteEndpoint(var Rec: Record "NPR Nc Endpoint"; RunTrigger: Boolean)
    var
        NcEndpointEmail: Record "NPR Nc Endpoint E-mail";
    begin
        if NcEndpointEmail.Get(Rec.Code) then
            NcEndpointEmail.Delete(true);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6151519, 'OnRunEndpoint', '', true, true)]
    local procedure OnRunEndpoint(NcTaskOutput: Record "NPR Nc Task Output"; NcEndpoint: Record "NPR Nc Endpoint")
    var
        NcEndpointEmail: Record "NPR Nc Endpoint E-mail";
    begin
        //-NC2.12 [308107]
        if NcEndpoint."Endpoint Type" <> NcEndpointEmail.GetEndpointTypeCode() then
            exit;
        if not NcEndpointEmail.Get(NcEndpoint.Code) then
            exit;

        EmailProcessOutput(NcTaskOutput, NcEndpointEmail);
        //+NC2.12 [308107]
    end;
}

