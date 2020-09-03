codeunit 6184851 "NPR FR Audit Arch. Workshifts"
{
    // NPR5.48/MMV /20181025 CASE 318028 Created object
    // Finds new P monthly workshifts, refreshes all audit entries created within the workshift and archives them.
    // NPR5.51/MMV /20190704 CASE 356076 Added filter


    trigger OnRun()
    var
        POSWorkshiftCheckpoint: Record "NPR POS Workshift Checkpoint";
    begin
        FRCertificationSetup.Get;
        FRCertificationSetup.TestField("Auto Archive URL");
        FRCertificationSetup.TestField("Auto Archive API Key");
        FRCertificationSetup.TestField("Auto Archive SAS");

        POSWorkshiftCheckpoint.SetFilter("Entry No.", '>%1', FRCertificationSetup."Last Auto Archived Workshift");
        POSWorkshiftCheckpoint.SetRange(Type, POSWorkshiftCheckpoint.Type::PREPORT);
        //-NPR5.51 [356076]
        POSWorkshiftCheckpoint.SetRange("Period Type", 'FR_NF525_MONTH');
        //+NPR5.51 [356076]
        if POSWorkshiftCheckpoint.FindSet then
            repeat
                FRCertificationSetup."Last Auto Archived Workshift" := POSWorkshiftCheckpoint."Entry No.";
                FRCertificationSetup.Modify;

                ArchiveWorkshift(POSWorkshiftCheckpoint);

                Commit;
            until POSWorkshiftCheckpoint.Next = 0;
    end;

    var
        FRCertificationSetup: Record "NPR FR Audit Setup";

    local procedure GetLastWorkshiftPOSEntryNo(POSWorkshiftCheckpoint: Record "NPR POS Workshift Checkpoint"): Integer
    var
        POSWorkshiftCheckpoint2: Record "NPR POS Workshift Checkpoint";
    begin
        POSWorkshiftCheckpoint2.SetRange("POS Unit No.", POSWorkshiftCheckpoint."POS Unit No.");
        POSWorkshiftCheckpoint2.SetRange(Type, POSWorkshiftCheckpoint2.Type::PREPORT);
        POSWorkshiftCheckpoint2.SetFilter("Entry No.", '<%1', POSWorkshiftCheckpoint."Entry No.");
        if POSWorkshiftCheckpoint2.FindLast then;
        exit(POSWorkshiftCheckpoint2."Entry No.");
    end;

    local procedure ArchiveWorkshift(POSWorkshiftCheckpoint: Record "NPR POS Workshift Checkpoint")
    var
        FRPeriodArchive: XMLport "NPR FR Audit Archive";
        TempBlob: Codeunit "Temp Blob";
        InStream: InStream;
        OutStream: OutStream;
        HttpClient: DotNet NPRNetHttpClient;
        Uri: DotNet NPRNetUri;
        TimeSpan: DotNet NPRNetTimeSpan;
        StringContent: DotNet NPRNetStringContent;
        Encoding: DotNet NPRNetEncoding;
        HttpResponseMessage: DotNet NPRNetHttpResponseMessage;
        XmlLine: Text;
        XmlFile: Text;
        GUID: Guid;
    begin
        POSWorkshiftCheckpoint.SetRecFilter;
        TempBlob.CreateOutStream(OutStream, TEXTENCODING::UTF8);
        FRPeriodArchive.SetDestination(OutStream);
        FRPeriodArchive.SetTableView(POSWorkshiftCheckpoint);
        FRPeriodArchive.Export();
        TempBlob.CreateInStream(InStream, TEXTENCODING::UTF8);

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
        HttpResponseMessage := HttpClient.PutAsync(StrSubstNo('%1/%2?%3', FRCertificationSetup."Auto Archive URL", Format(GUID), FRCertificationSetup."Auto Archive SAS"), StringContent).Result();
        HttpResponseMessage.EnsureSuccessStatusCode();
    end;
}

