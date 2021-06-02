codeunit 6184851 "NPR FR Audit Arch. Workshifts"
{
    // Finds new P monthly workshifts, refreshes all audit entries created within the workshift and archives them.

    trigger OnRun()
    var
        POSWorkshiftCheckpoint: Record "NPR POS Workshift Checkpoint";
    begin
        FRCertificationSetup.Get();
        FRCertificationSetup.TestField("Auto Archive URL");
        FRCertificationSetup.TestField("Auto Archive API Key");
        FRCertificationSetup.TestField("Auto Archive SAS");

        POSWorkshiftCheckpoint.SetFilter("Entry No.", '>%1', FRCertificationSetup."Last Auto Archived Workshift");
        POSWorkshiftCheckpoint.SetRange(Type, POSWorkshiftCheckpoint.Type::PREPORT);
        POSWorkshiftCheckpoint.SetRange("Period Type", 'FR_NF525_MONTH');
        if POSWorkshiftCheckpoint.FindSet() then
            repeat
                FRCertificationSetup."Last Auto Archived Workshift" := POSWorkshiftCheckpoint."Entry No.";
                FRCertificationSetup.Modify();

                ArchiveWorkshift(POSWorkshiftCheckpoint);

                Commit();
            until POSWorkshiftCheckpoint.Next() = 0;
    end;

    var
        FRCertificationSetup: Record "NPR FR Audit Setup";

    local procedure ArchiveWorkshift(POSWorkshiftCheckpoint: Record "NPR POS Workshift Checkpoint")
    var
        FRPeriodArchive: XMLport "NPR FR Audit Archive";
        TempBlob: Codeunit "Temp Blob";
        InStream: InStream;
        OutStream: OutStream;
        Client: HttpClient;
        Content: HttpContent;
        Headers: HttpHeaders;
        RequestMessage: HttpRequestMessage;
        ResponseMessage: HttpResponseMessage;
        XmlLine: Text;
        XmlFile: Text;
        StatusMessage: Text;
        UriLbl: Label '%1/%2?%3', Locked = true;
    begin
        POSWorkshiftCheckpoint.SetRecFilter();
        TempBlob.CreateOutStream(OutStream, TEXTENCODING::UTF8);
        FRPeriodArchive.SetDestination(OutStream);
        FRPeriodArchive.SetTableView(POSWorkshiftCheckpoint);
        FRPeriodArchive.Export();
        TempBlob.CreateInStream(InStream, TEXTENCODING::UTF8);

        while (not InStream.EOS) do begin
            InStream.ReadText(XmlLine);
            XmlFile += XmlLine;
        end;

        Content.WriteFrom(XmlFile);
        Content.GetHeaders(Headers);
        Headers.Remove('Content-Type');
        Headers.Add('Content-Type', 'text/xml; charset=utf-8');
        Headers.Add('x-ms-blob-type', 'BlockBlob');
        Headers.Add('x-ms-meta-WorkshiftEntryNo', Format(POSWorkshiftCheckpoint."Entry No."));
        Headers.Add('x-ms-meta-WorkshiftPOSUnitNo', Format(POSWorkshiftCheckpoint."POS Unit No."));
        Headers.Add('x-ms-meta-WorkshiftDateTime', Format(POSWorkshiftCheckpoint."Created At"));
        Headers.Add('Ocp-Apim-Subscription-Key', FRCertificationSetup."Auto Archive API Key");
        RequestMessage.Content(Content);
        RequestMessage.Method('PUT');
        RequestMessage.SetRequestUri(StrSubstNo(UriLbl, FRCertificationSetup."Auto Archive URL", Format(CreateGuid()), FRCertificationSetup."Auto Archive SAS"));

        Client.Timeout(60000); //1min
        Client.Send(RequestMessage, ResponseMessage);

        if not ResponseMessage.IsSuccessStatusCode then begin
            ResponseMessage.Content.ReadAs(StatusMessage);
            Error('%1: %2', FORMAT(ResponseMessage.HttpStatusCode), StatusMessage);
        end;
    end;
}