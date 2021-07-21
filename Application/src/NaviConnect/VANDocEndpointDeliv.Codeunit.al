codeunit 6059942 "NPR VAN Doc. Endpoint Deliv."
{
    TableNo = "Record Export Buffer";

    trigger OnRun()
    var
        ElectronicDocumentFormat: Record "Electronic Document Format";
        NcEndpoint: Record "NPR Nc Endpoint";
        TempNcTaskOutput: Record "NPR Nc Task Output" temporary;
        TempBlob: Codeunit "Temp Blob";
        NcEndpointMgt: Codeunit "NPR Nc Endpoint Mgt.";
        FileManagement: Codeunit "File Management";
        OStream: OutStream;
        IStream: InStream;
        Response, FileName : Text;
    begin
        ElectronicDocumentFormat.Get(Rec."Electronic Document Format");
        NcEndpoint.Get(ElectronicDocumentFormat."NPR Delivery Endpoint");
        NcEndpoint.TestField(Enabled);
        Rec.ClientFileName := FileManagement.BLOBImport(TempBlob, '');
        FileName := Rec.ClientFileName;

        TempNcTaskOutput.Data.CreateOutStream(OStream, TEXTENCODING::UTF8);

        TempBlob.CreateInStream(IStream);
        CopyStream(OStream, IStream);

        TempNcTaskOutput.Insert(false);
        TempNcTaskOutput.Name := FileName;
        if not NcEndpointMgt.RunEndpoint(TempNcTaskOutput, NcEndpoint, Response) then
            Error(SendFailedErr, NcEndpoint.Code);
    end;

    var
        SendFailedErr: Label 'Upload to Endpoint %1 failed.', Comment = '%1="NPR Nc Endpoint".Code';
}

