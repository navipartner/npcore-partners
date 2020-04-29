codeunit 6184865 "External Storage Job Queue"
{
    // NPR5.54/ALST/20200324 CASE 394895 Object created

    TableNo = "Job Queue Entry";

    trigger OnRun()
    begin
        Run(Rec);
    end;

    var
        LengthExceededErr: Label 'Parameter string must be less than or equal to 250 charracters';
        MandatoryParameterErr: Label 'Parameter value cannot be empty in job queue, please select "%1"';
        ParameterNrErr: Label 'Wrong number of parameters in "%1" opertion %2 takes %3 parameters';

    local procedure Run(JobQueueEntry: Record "Job Queue Entry")
    var
        TempStorageOperationType: Record "Storage Operation Type" temporary;
        TempStorageOperationParameter: Record "Storage Operation Parameter" temporary;
        ExternalStorageInterface: Codeunit "External Storage Interface";
    begin
        JobQueueEntry.TestField("Parameter String");

        GetOperationParameters(JobQueueEntry, TempStorageOperationParameter);

        ExternalStorageInterface.OnDiscoverStorageOperation(TempStorageOperationType);

        TempStorageOperationType.Get(TempStorageOperationParameter."Storage Type", TempStorageOperationParameter."Operation Code");

        ExternalStorageInterface.HandleOperation(GetStorageID(JobQueueEntry), TempStorageOperationType, TempStorageOperationParameter);
    end;

    local procedure GetStorageID(JobQueueEntry: Record "Job Queue Entry"): Text
    begin
        exit(SelectStr(1, JobQueueEntry."Parameter String"));
    end;

    local procedure GetStorageType(JobQueueEntry: Record "Job Queue Entry"): Text
    begin
        exit(SelectStr(2, JobQueueEntry."Parameter String"));
    end;

    local procedure GetOperationType(JobQueueEntry: Record "Job Queue Entry"): Text
    begin
        exit(SelectStr(3, JobQueueEntry."Parameter String"));
    end;

    local procedure GetOperationParameters(JobQueueEntry: Record "Job Queue Entry";var TempStorageOperationParameter: Record "Storage Operation Parameter" temporary)
    var
        ExternalStorageInterface: Codeunit "External Storage Interface";
        i: Integer;
    begin
        ExternalStorageInterface.OnDiscoverStorageOperationParameters(TempStorageOperationParameter);

        TempStorageOperationParameter.SetRange("Operation Code", GetOperationType(JobQueueEntry));
        TempStorageOperationParameter.SetRange("Storage Type", GetStorageType(JobQueueEntry));
        if not TempStorageOperationParameter.FindSet then
          exit;

        if TempStorageOperationParameter.Count + 3 <> StrLen(DelChr(JobQueueEntry."Parameter String", '=', DelChr(JobQueueEntry."Parameter String", '=', ','))) + 1 then
          Error(ParameterNrErr, JobQueueEntry.FieldName("Parameter String"), TempStorageOperationParameter."Operation Code", TempStorageOperationParameter.Count);

        i := 4;
        repeat
          TempStorageOperationParameter."Parameter Value" := SelectStr(i, JobQueueEntry."Parameter String");
          TempStorageOperationParameter.Modify;

          i += 1;
        until TempStorageOperationParameter.Next = 0;

        TempStorageOperationParameter.FindSet;
    end;

    procedure GenerateJobQueueParameter(StorageID: Text;var StorageOperationType: Record "Storage Operation Type";var TempStorageOperationParameter: Record "Storage Operation Parameter" temporary) JobQParam: Text
    var
        ExternalStorageInterface: Codeunit "External Storage Interface";
        [RunOnClient]
        Clipboard: DotNet npNetClipboard;
    begin
        with TempStorageOperationParameter do begin
          if IsEmpty then
            ExternalStorageInterface.OnDiscoverStorageOperationParameters(TempStorageOperationParameter);

          if not FindSet then;

          JobQParam += StorageID;
          JobQParam += ',' + StorageOperationType."Storage Type";
          JobQParam += ',' + StorageOperationType."Operation Code";

          if Count > 0 then
            repeat
              if ("Parameter Value" = '') and "Mandatory For Job Queue" then
                Error(MandatoryParameterErr, "Parameter Name");

              JobQParam += ',' + "Parameter Value";
            until Next = 0;
        end;

        if StrLen(JobQParam) >= 250 then
          Error(LengthExceededErr);

        if CurrentClientType = CLIENTTYPE::Windows then
          Clipboard.SetText(JobQParam)
        else
          Message(JobQParam);
    end;
}

