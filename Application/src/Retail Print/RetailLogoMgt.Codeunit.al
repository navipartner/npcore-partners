codeunit 6014531 "NPR Retail Logo Mgt."
{
    Access = Internal;

    var
        ResizeImage: ControlAddIn "NPR ResizeImage";
        CtrlAddInInitialized: Boolean;
        Error000001: Label 'Maximum supported image size after conversion is 65523 bytes.\Uploaded image is %1 bytes after conversion. This usually happens if the image has too much height.';
        Text000001: Label 'Insert Keyword';
        Text_UploadCaption: Label 'Choose logo file';

    procedure InitializeResizeImage(ResizeImageIn: ControlAddIn "NPR ResizeImage")
    begin
        ResizeImage := ResizeImageIn;
        CtrlAddInInitialized := true;
    end;

    procedure GetRetailLogo(KeywordIn: Code[20]; RegisterNo: Code[10]; var RetailLogo: Record "NPR Retail Logo"): Boolean
    var
        POSUnit: Record "NPR POS Unit";
    begin
        //Use RetailLogo.SETAUTOCALCFIELDS() on the blobs you need, before you call this function.

        if RegisterNo = '' then
            RegisterNo := POSUnit.GetCurrentPOSUnit();

        RetailLogo.SetRange(Keyword, KeywordIn);
        RetailLogo.SetRange("Register No.", RegisterNo);
        if RetailLogo.IsEmpty then
            RetailLogo.SetRange("Register No.", '');

        RetailLogo.SetFilter("Start Date", '<=%1|=%2', Today, 0D);
        RetailLogo.SetFilter("End Date", '>=%1|=%2', Today, 0D);

        exit(RetailLogo.FindSet());
    end;

    procedure UploadLogo()
    var
        NotInitializedErr: Label 'Control Add-In not initialized.';
        Base64Img: Text;
        TempBlob: Codeunit "Temp Blob";
        InStr: InStream;
        ImageHelper: Codeunit "Image Helpers";
        OutStr: OutStream;
#if BC20
        Image: Codeunit Image;
#else
        Base64Converter: Codeunit "Base64 Convert";
        DotNetImage: Codeunit DotNet_Image;
        DotNetImageFormat: Codeunit DotNet_ImageFormat;
        Width: Integer;
        Height: Integer;
        ImageHandler: Codeunit "Image Handler Management";
#endif
    begin
        if not CtrlAddInInitialized then
            Error(NotInitializedErr);

        TempBlob.CreateInStream(InStr);
        TempBlob.CreateOutStream(OutStr);

        if not ImportLogo(TempBlob) then
            exit;
#if BC20
        Image.FromStream(InStr);
        Image.SetFormat(Enum::"Image Format"::Bmp);
        Image.Save(OutStr);
        Base64Img := Image.ToBase64();
#else
        ImageHandler.GetImageSize(InStr, Width, Height);
        Clear(DotNetImage);
        DotNetImage.FromStream(InStr);
        DotNetImage.FromBitmap(Width, Height);
        DotNetImageFormat.Bmp();
        DotNetImage.Save(OutStr, DotNetImageFormat);
        Base64Img := Base64Converter.ToBase64(InStr);
#endif
        Clear(InStr);
        TempBlob.CreateInStream(InStr);
        ResizeImage.ResizeImage(Base64Img, ImageHelper.GetImageType(InStr));
    end;

    #region AUX

    local procedure ImportLogo(var TempBlob: Codeunit "Temp Blob"): Boolean;
    var
        FileMgt: Codeunit "File Management";
    begin
        FileMgt.BLOBImportWithFilter(TempBlob, Text_UploadCaption, '', 'Image Files (*.BMP;*.GIF;*.JPG;*.PNG;*.TIFF;*.EXIF)|*.BMP;*.GIF;*.JPG;*.PNG;*.TIFF;*.EXIF', 'bmp,gif,jpg,png,tiff,exif');
        if not TempBlob.HasValue() then
            exit(false);
        exit(true);
    end;

    procedure CreateRecord(var RetailLogo: Record "NPR Retail Logo"; sourceBase64: Text; ESCPOS: Text)
    var
        ImageHandler: Codeunit "Image Handler Management";
        ConvertBase64: Codeunit "Base64 Convert";
        TempBlob: Codeunit "Temp Blob";
        OutStr: OutStream;
        InStr: InStream;
        Width: Integer;
        Height: Integer;
        DotNetEncoding: Codeunit DotNet_Encoding;
        DotNetBinarwWriter: Codeunit DotNet_BinaryWriter;
        DotNetStream: Codeunit DotNet_Stream;
        i: Integer;
    begin
        sourceBase64 := CopyStr(sourceBase64, StrPos(sourceBase64, 'base64,') + StrLen('base64,'));

        if StrLen(ESCPOS) > 65523 then
            Error(Error000001, Format(StrLen(ESCPOS)));

        Clear(RetailLogo);
        RetailLogo.NewRecord();
        RetailLogo.Init();

        RetailLogo.Keyword := Text000001;

        TempBlob.CreateOutStream(OutStr);
        ConvertBase64.FromBase64(sourceBase64, OutStr);
        TempBlob.CreateInStream(InStr);
        RetailLogo."POS Logo".ImportStream(InStr, RetailLogo.FieldName("POS Logo"));

        ImageHandler.GetImageSize(InStr, Width, Height);

        RetailLogo.Width := Width;
        RetailLogo.Height := Height;

        RetailLogo.Insert();

        Clear(OutStr);
        Clear(InStr);

        RetailLogo.ESCPOSLogo.CreateOutStream(OutStr);

        DotNetEncoding.UTF8();
        DotNetStream.FromOutStream(OutStr);
        DotNetBinarwWriter.BinaryWriterWithEncoding(DotNetStream, DotNetEncoding);
        for i := 1 to StrLen(ESCPOS) do
            DotNetBinarwWriter.WriteChar(ESCPOS[i]);

        Clear(OutStr);
        Clear(InStr);
        RetailLogo.OneBitLogo.CreateInStream(InStr);
        RetailLogo.OneBitLogo.CreateOutStream(OutStr);
        ConvertBase64.FromBase64(sourceBase64, OutStr);

        RetailLogo.OneBitLogoByteSize := RetailLogo.OneBitLogo.Length;

        RetailLogo.Modify();
    end;

    procedure ExportImageBMP(RetailLogo: Record "NPR Retail Logo")
    var
        FileManagement: Codeunit "File Management";
        TempBlob: Codeunit "Temp Blob";
        OutStr: OutStream;
    begin
        if RetailLogo."POS Logo".HasValue() then begin
            TempBlob.CreateOutStream(OutStr);
            RetailLogo."POS Logo".ExportStream(OutStr);
            FileManagement.BLOBExport(TempBlob, RetailLogo.Keyword + Format(RetailLogo.Sequence) + '.bmp', true);
        end;
    end;

    #endregion
}