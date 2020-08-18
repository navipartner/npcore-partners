codeunit 6151522 "Nc Trigger Task Mgt."
{
    // NC2.01/BR /20160825  CASE 247479 NaviConnect: Object created
    // NC2.03/BR /20170103  CASE 271242 Added field Error on Empty Output
    // NPR5.55/MHA /20200611  CASE 409410 Changed ManualTransferOutput() from TryFunction to use AssertError

    TableNo = "Nc Task";

    trigger OnRun()
    var
        NcTriggerSetup: Record "Nc Trigger Setup";
        NcTriggerCode: Code[20];
        CurrentIteration: Integer;
        MaxIteration: Integer;
        Output: Text;
        Filename: Text;
        Subject: Text;
        Body: Text;
        ExpectedIteration: Decimal;
        NcTask: Record "Nc Task";
        TextTriggerDisabled: Label 'Trigger %1 is disabled or missing.';
        NcTrigger: Record "Nc Trigger";
    begin
        NcTriggerCode := '';
        if GetNcTriggerCode(Rec,NcTriggerCode) then begin
          if not IsEnabled(NcTriggerCode) then
            Error(StrSubstNo(TextTriggerDisabled,NcTriggerCode));
          AddOutputToTask(NcTriggerCode,Rec,Output,CurrentIteration,MaxIteration,Filename,Subject,Body);
          ExpectedIteration := 1;
          if CurrentIteration < MaxIteration then repeat
            if CurrentIteration <> ExpectedIteration then Error(TextWrongIteration,ExpectedIteration,CurrentIteration);
            ExpectedIteration := CurrentIteration + 1;
            NcTask := Rec;
            NcTask."Entry No." := 0;
            NcTask."Last Processing Started at" := CurrentDateTime;
            NcTask."Process Error" := true;
            NcTask.Insert(true);
            Commit;
            AddOutputToTask(NcTriggerCode,NcTask,Output,CurrentIteration,MaxIteration,Filename,Subject,Body);
            TransferOutput(NcTriggerCode,NcTask,Output,Filename,Subject,Body);
            NcTask."Last Processing Completed at" := CurrentDateTime;
            NcTask."Last Processing Duration" := (NcTask."Last Processing Completed at" - NcTask."Last Processing Started at") / 1000;
            NcTask.Processed := true;
            NcTask."Process Error" := false;
            NcTask.Modify;
            Commit;
          until (CurrentIteration >= MaxIteration);
        end else begin
          GetOutputFromTask(Rec,Output);
        end;
        //-NC2.03 [271242]
        //IF Output = '' THEN
        //  ERROR(TextNoOutput);
        if Output = '' then begin
          if NcTriggerCode <> '' then begin
            NcTrigger.Get(NcTriggerCode);
            if not NcTrigger."Error on Empty Output" then
              exit;
          end;
          Error(TextNoOutput);
        end;
        //+NC2.03 [271242]

        TransferOutput(NcTriggerCode,Rec,Output,Filename,Subject,Body);
    end;

    var
        TextWrongTable: Label 'Codeunit %1 can only be used in combination with table %2.';
        TextRecordNotFound: Label 'Record %1 not found in table %2.';
        TextNotHandled: Label 'Trigger %1 is unhandled. Please create a subscription codeunit or set the Subscriber Codeunit ID.';
        TextNoOutput: Label 'Output is missing';
        TextWrongIteration: Label 'Techncail error: the expected iteration is %1, but the subscriber returned %2.';

    local procedure AddOutputToTask(NcTriggerCode: Code[20];var NcTask: Record "Nc Task";var Output: Text;var CurrentIteration: Integer;var MaxIteration: Integer;var Filename: Text;var Subject: Text;var Body: Text)
    var
        NcTrigger: Record "Nc Trigger";
        Handled: Boolean;
        OStream: OutStream;
        TextNoSubscriber: Label 'No subscriber found for %1 %2.';
    begin
        OnRunNcTriggerTask(NcTriggerCode,Output,NcTask,Handled,CurrentIteration,MaxIteration,Filename,Subject,Body);
        if not Handled then
          Error(TextNoSubscriber,NcTrigger.TableCaption);
        NcTask."Data Output".CreateOutStream(OStream,TEXTENCODING::UTF8);
        OStream.WriteText(Output);
        NcTask.Modify(true);
    end;

    local procedure GetNcTriggerCode(NcTask: Record "Nc Task";var NcTriggerCode: Code[20]): Boolean
    var
        RecRef: RecordRef;
        NcTrigger: Record "Nc Trigger";
    begin
        if NcTask."Table No." <> DATABASE::"Nc Trigger" then
          exit(false);
        NcTrigger.SetPosition(NcTask."Record Position");
        NcTrigger.SetRange(Code,NcTrigger.Code);
        if NcTrigger.FindFirst then begin
          NcTriggerCode := NcTrigger.Code;
          exit(true);
        end else
          exit(false);
    end;

    local procedure IsEnabled(NCTriggerCode: Code[20]): Boolean
    var
        NcTrigger: Record "Nc Trigger";
    begin
        if NcTrigger.Get(NCTriggerCode) then
          if NcTrigger.Enabled then
            exit(true);
        exit(false);
    end;

    local procedure GetOutputFromTask(var NcTask: Record "Nc Task";var Output: Text)
    var
        NcEndpointEmail: Record "Nc Endpoint E-mail";
        NcEndpointFile: Record "Nc Endpoint File";
        NcEndpointFtp: Record "Nc Endpoint FTP";
        NcTaskMgt: Codeunit "Nc Task Mgt.";
        NcTriggerSyncMgt: Codeunit "Nc Trigger Sync. Mgt.";
        StreamReader: DotNet npNetStreamReader;
        InStream: InStream;
        Outstream: OutStream;
        RecRef: RecordRef;
        FieldRef: FieldRef;
        OutputEntryNo: Integer;
    begin
        if NcTask."Data Output".HasValue then begin
          NcTask.CalcFields("Data Output");
          NcTask."Data Output".CreateInStream(InStream,TEXTENCODING::UTF8);
          StreamReader := StreamReader.StreamReader(InStream);
          Output := StreamReader.ReadToEnd();
          exit;
        end;

        NcTaskMgt.RestoreRecord(NcTask."Entry No.",RecRef);
        case RecRef.Number of
          DATABASE::"Nc Endpoint FTP":
            FieldRef := RecRef.Field(NcEndpointFtp.FieldNo("Output Nc Task Entry No."));
          DATABASE::"Nc Endpoint E-mail":
            FieldRef := RecRef.Field(NcEndpointEmail.FieldNo("Output Nc Task Entry No."));
          DATABASE::"Nc Endpoint File":
            FieldRef := RecRef.Field(NcEndpointFile.FieldNo("Output Nc Task Entry No."));
          else
            exit;
        end;

        OutputEntryNo := FieldRef.Value;
        Output := NcTriggerSyncMgt.GetOutput(OutputEntryNo);
        NcTask."Data Output".CreateOutStream(Outstream,TEXTENCODING::UTF8);
        Outstream.WriteText(Output);
        NcTask.Modify(true);
    end;

    local procedure TransferOutput(NcTriggerCode: Code[20];var NcTask: Record "Nc Task";var Output: Text;var Filename: Text;var Subject: Text;var Body: Text)
    begin
        OnAfterGetOutputTriggerTask(NcTriggerCode,Output,NcTask,Filename,Subject,Body);
    end;

    local procedure InsertNCTaskPerEndpoint(NcTriggerCode: Code[20];var NcTask: Record "Nc Task";var Output: Text)
    begin
    end;

    procedure ManualTransferOutput(NcTriggerCode: Code[20];var NcTask: Record "Nc Task";var Output: Text;var Filename: Text;var Subject: Text;var Body: Text): Boolean
    var
        Outstream: OutStream;
    begin
        //-NPR5.55 [409410]
        Commit;
        asserterror begin
          if Output <> '' then begin
            NcTask."Data Output".CreateOutStream(Outstream,TEXTENCODING::UTF8);
            Outstream.WriteText(Output);
          end;
          Commit;
          OnAfterGetOutputTriggerTask(NcTriggerCode,Output,NcTask,Filename,Subject,Body);
          Commit;
          Error('');
        end;
        exit(GetLastErrorText = '');
        //+NPR5.55 [409410]
    end;

    procedure VerifyNoEndpointTriggerLinksExist(EndpointTypeCode: Code[20];EndpointCode: Code[20])
    var
        NcEndpointTriggerLink: Record "Nc Endpoint Trigger Link";
        TextEndpointTriggerLinkExist: Label '%1 records exist. Please delete these first.';
    begin
        NcEndpointTriggerLink.Reset;
        NcEndpointTriggerLink.SetRange("Endpoint Code",EndpointCode);
        if not NcEndpointTriggerLink.IsEmpty then
          Error(TextEndpointTriggerLinkExist,NcEndpointTriggerLink.TableCaption);
    end;

    local procedure "--- Events"()
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnRunNcTriggerTask(TriggerCode: Code[20];var Output: Text;var NcTask: Record "Nc Task";var Handled: Boolean;var CurrentIteration: Integer;var MaxIterations: Integer;var Filename: Text;var Subject: Text;var Body: Text)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterGetOutputTriggerTask(NcTriggerCode: Code[20];Output: Text;var NcTask: Record "Nc Task";Filename: Text;Subject: Text;Body: Text)
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnSetupNcTriggers()
    begin
    end;
}

