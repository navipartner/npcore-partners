codeunit 6014531 "NPR Retail Logo Mgt."
{
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
        TempBlob: Codeunit "Temp Blob";
        Base64Converter: Codeunit "Base64 Convert";
        InStr: InStream;
        Base64: Text;
        ImgExtension: Text;
        ImageHelper: Codeunit "Image Helpers";
        DotNetImage: Codeunit DotNet_Image;
        DotNetImageFormat: Codeunit DotNet_ImageFormat;
        OutStr: OutStream;
        Width: Integer;
        Height: Integer;
        ImageHandler: Codeunit "Image Handler Management";
    begin
        if not CtrlAddInInitialized then
            Error(NotInitializedErr);

        TempBlob.CreateInStream(InStr);
        TempBlob.CreateOutStream(OutStr);

        if not ImportLogo(TempBlob) then
            exit;

        ImageHandler.GetImageSize(InStr, Width, Height);

        Clear(DotNetImage);
        DotNetImage.FromStream(InStr);
        DotNetImage.FromBitmap(Width, Height);
        DotNetImageFormat.Bmp();
        DotNetImage.Save(OutStr, DotNetImageFormat);

        ImgExtension := ImageHelper.GetImageType(InStr);
        Base64 := Base64Converter.ToBase64(InStr);

        ResizeImage.ResizeImage(Base64, ImgExtension);
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

