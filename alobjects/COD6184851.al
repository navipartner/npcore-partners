codeunit 6184851 "FR Audit Archive Workshifts"
{
    // NPR5.48/MMV /20181025 CASE 318028 Created object
    // Finds new P workshifts, refreshes all audit entries created within the workshift and archives them.


    trigger OnRun()
    var
        POSWorkshiftCheckpoint: Record "POS Workshift Checkpoint";
    begin
        FRCertificationSetup.Get;
        FRCertificationSetup.TestField("Auto Archive URL");
        FRCertificationSetup.TestField("Auto Archive API Key");
        FRCertificationSetup.TestField("Auto Archive SAS");

        POSWorkshiftCheckpoint.SetFilter("Entry No.", '>%1', FRCertificationSetup."Last Auto Archived Workshift");
        POSWorkshiftCheckpoint.SetRange(Type, POSWorkshiftCheckpoint.Type::PREPORT);
        if POSWorkshiftCheckpoint.FindSet then
          repeat
            FRCertificationSetup."Last Auto Archived Workshift" := POSWorkshiftCheckpoint."Entry No.";
            FRCertificationSetup.Modify;

            ArchiveWorkshift(POSWorkshiftCheckpoint);

            Commit;
          until POSWorkshiftCheckpoint.Next = 0;
    end;

    var
        FRCertificationSetup: Record "FR Audit Setup";

    local procedure GetLastWorkshiftPOSEntryNo(POSWorkshiftCheckpoint: Record "POS Workshift Checkpoint"): Integer
    var
        POSWorkshiftCheckpoint2: Record "POS Workshift Checkpoint";
    begin
        POSWorkshiftCheckpoint2.SetRange("POS Unit No.", POSWorkshiftCheckpoint."POS Unit No.");
        POSWorkshiftCheckpoint2.SetRange(Type, POSWorkshiftCheckpoint2.Type::PREPORT);
        POSWorkshiftCheckpoint2.SetFilter("Entry No.", '<%1', POSWorkshiftCheckpoint."Entry No.");
        if POSWorkshiftCheckpoint2.FindLast then;
        exit(POSWorkshiftCheckpoint2."Entry No.");
    end;

    local procedure ArchiveWorkshift(POSWorkshiftCheckpoint: Record "POS Workshift Checkpoint")
    var
        FRPeriodArchive: XMLport "FR Audit Archive";
        TempBlob: Record TempBlob temporary;
        InStream: InStream;
        OutStream: OutStream;
        HttpClient: DotNet HttpClient;
        Uri: DotNet Uri;
        TimeSpan: DotNet TimeSpan;
        StringContent: DotNet StringContent;
        Encoding: DotNet Encoding;
        HttpResponseMessage: DotNet HttpResponseMessage;
        XmlLine: Text;
        XmlFile: Text;
        GUID: Guid;
    begin
        POSWorkshiftCheckpoint.SetRecFilter;
        TempBlob.Blob.CreateOutStream(OutStream, TEXTENCODING::UTF8);
        FRPeriodArchive.SetDestination(OutStream);
        FRPeriodArchive.SetTableView(POSWorkshiftCheckpoint);
        FRPeriodArchive.Export();
        TempBlob.Blob.CreateInStream(InStream, TEXTENCODING::UTF8);

        while (not InStream.EOS) do begin
          InStream.ReadText(XmlLine);
          XmlFile += XmlLine;
        end;

        HttpClient := HttpClient.HttpClient();
        HttpClient.DefaultRequestHeaders.Clear();
        HttpClient.Timeout := TimeSpan.TimeSpan(0, 1, 0); //1min

        GUID := CreateGuid;

        StringContent := StringContent.StringContent(XmlFile, Encoding.UTF8, 'application/xml');
        StringContent.Headers.Add('x-ms-blob-type', 'BlockBlob');
        StringContent.Headers.Add('x-ms-meta-WorkshiftEntryNo', Format(POSWorkshiftCheckpoint."Entry No."));
        StringContent.Headers.Add('x-ms-meta-WorkshiftPOSUnitNo', Format(POSWorkshiftCheckpoint."POS Unit No."));
        StringContent.Headers.Add('x-ms-meta-WorkshiftDateTime', Format(POSWorkshiftCheckpoint."Created At"));
        StringContent.Headers.Add('Ocp-Apim-Subscription-Key', FRCertificationSetup."Auto Archive API Key");
        HttpResponseMessage := HttpClient.PutAsync(StrSubstNo('%1/%2?%3',FRCertificationSetup."Auto Archive URL", Format(GUID), FRCertificationSetup."Auto Archive SAS"), StringContent).Result();
        HttpResponseMessage.EnsureSuccessStatusCode();
    end;
}

