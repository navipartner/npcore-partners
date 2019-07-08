codeunit 6060137 "MM Member Camera Hook"
{
    // MM1.16/NPKNAV/20161026  CASE 240868 Transport T0003 - MM1.16


    trigger OnRun()
    begin
    end;

    var
        Convert: DotNet Convert;
        Bytes: DotNet Array;
        Encoding: DotNet Encoding;
        Txt001: Label 'data:image/jpeg;base64,';

    procedure OpenCameraMMMemberInfoCapture(var MMMemberInfoCapture: Record "MM Member Info Capture")
    var
        MMMemberInfoCaptureCamera: Page "MM Member Info Capture Camera";
        InS: InStream;
        StreamReader: DotNet StreamReader;
        Txt: Text;
        StreamWriter: DotNet StreamWriter;
        MemoryStream: DotNet MemoryStream;
    begin
        if MMMemberInfoCapture.Picture.HasValue then begin
            MMMemberInfoCapture.Picture.CreateInStream(InS);

            MemoryStream := MemoryStream.MemoryStream();
            CopyStream(MemoryStream,InS);
            Bytes := MemoryStream.ToArray();
            Txt := Txt001 + Convert.ToBase64String(Bytes);

        //    StreamReader := StreamReader.StreamReader(InS);
        //    Txt := StreamReader.ReadToEnd();
        //    StreamReader.Close();

        end;

        MMMemberInfoCaptureCamera.SetText(Txt);
        MMMemberInfoCaptureCamera.SetRecord(MMMemberInfoCapture);
        MMMemberInfoCaptureCamera.Run();
    end;

    procedure Base64Encode(plainText: Text): Text
    begin
        Bytes := Encoding.UTF8.GetBytes(plainText);
        exit(Convert.ToBase64String(Bytes));
    end;

    procedure Base64Decode(base64EncodedData: Text): Text
    begin
        Bytes := Convert.FromBase64String(base64EncodedData);
        exit(Encoding.UTF8.GetString(Bytes));
    end;
}

