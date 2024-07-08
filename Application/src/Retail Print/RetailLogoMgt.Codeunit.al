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

    procedure UploadLogo()
    var
        NotInitializedErr: Label 'Control Add-In not initialized.';
        Base64Img: Text;
        TempBlob: Codeunit "Temp Blob";
        InStr: InStream;
        ImageHelper: Codeunit "Image Helpers";
        OutStr: OutStream;
#if BC17 or BC18 or BC19 
        Base64Converter: Codeunit "Base64 Convert";
        DotNetImage: Codeunit DotNet_Image;
        DotNetImageFormat: Codeunit DotNet_ImageFormat;
        Width: Integer;
        Height: Integer;
        ImageHandler: Codeunit "Image Handler Management";
#else
        Image: Codeunit Image;
#endif
    begin
        if not CtrlAddInInitialized then
            Error(NotInitializedErr);

        TempBlob.CreateInStream(InStr);
        TempBlob.CreateOutStream(OutStr);

        if not ImportLogo(TempBlob) then
            exit;
#if BC17 or BC18 or BC19 
        ImageHandler.GetImageSize(InStr, Width, Height);
        Clear(DotNetImage);
        DotNetImage.FromStream(InStr);
        DotNetImage.FromBitmap(Width, Height);
        DotNetImageFormat.Bmp();
        DotNetImage.Save(OutStr, DotNetImageFormat);
        Base64Img := Base64Converter.ToBase64(InStr);
#else
        Image.FromStream(InStr);
        Image.SetFormat(Enum::"Image Format"::Bmp);
        Image.Save(OutStr);
        Base64Img := Image.ToBase64();
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

    procedure CreateRecord(var RetailLogo: Record "NPR Retail Logo"; sourceBase64: Text; ESCPOS: Text; Hi: Integer; Lo: Integer; CmdHi: Integer; CmdLo: Integer)
    begin
        sourceBase64 := CopyStr(sourceBase64, StrPos(sourceBase64, 'base64,') + StrLen('base64,'));

        if StrLen(ESCPOS) > 65523 then
            Error(Error000001, Format(StrLen(ESCPOS)));

        Clear(RetailLogo);
        RetailLogo.NewRecord();
        RetailLogo.Init();
        RetailLogo.Keyword := Text000001;

        WritePreviewLogo(RetailLogo, sourceBase64);
        WriteESCPOSLogo(RetailLogo, ESCPOS);
        WriteOneBitLogo(RetailLogo, sourceBase64);

        RetailLogo."ESCPOS Height Low Byte" := Lo;
        RetailLogo."ESCPOS Height High Byte" := Hi;
        RetailLogo."ESCPOS Cmd Low Byte" := CmdLo;
        RetailLogo."ESCPOS Cmd High Byte" := CmdHi;

        RetailLogo.Insert();
    end;

    local procedure WritePreviewLogo(var RetailLogo: Record "NPR Retail Logo"; sourceBase64: Text)
    var
        ImageHandler: Codeunit "Image Handler Management";
        ConvertBase64: Codeunit "Base64 Convert";
        TempBlob: Codeunit "Temp Blob";
        OStream: OutStream;
        IStream: InStream;
        Width: Integer;
        Height: Integer;
    begin
        TempBlob.CreateOutStream(OStream);
        ConvertBase64.FromBase64(sourceBase64, OStream);
        TempBlob.CreateInStream(IStream);
        RetailLogo."POS Logo".ImportStream(IStream, RetailLogo.FieldName("POS Logo"));

        ImageHandler.GetImageSize(IStream, Width, Height);

        RetailLogo.Width := Width;
        RetailLogo.Height := Height;
    end;

    local procedure WriteESCPOSLogo(var RetailLogo: Record "NPR Retail Logo"; ESCPOSBase64: Text)
    var
        Base64Convert: Codeunit "Base64 Convert";
        OStream: OutStream;
    begin
        RetailLogo.ESCPOSLogo.CreateOutStream(OStream);
        Base64Convert.FromBase64(ESCPOSBase64, OStream);
    end;

    local procedure WriteOneBitLogo(var RetailLogo: Record "NPR Retail Logo"; sourceBase64: Text)
    var
        OStream: OutStream;
        Base64Convert: Codeunit "Base64 Convert";
    begin
        RetailLogo.OneBitLogo.CreateOutStream(OStream);
        Base64Convert.FromBase64(sourceBase64, OStream);
        RetailLogo.OneBitLogoByteSize := RetailLogo.OneBitLogo.Length;
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