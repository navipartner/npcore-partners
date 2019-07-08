codeunit 6014531 "Retail Logo Mgt."
{
    // NPR4.21/MMV/20151104 CASE 223223 Created CU
    // 
    // CU contains all functions for importing and retrieving logos for retail receipts, thus removing the need for storing logos in each printers non-volatile memory.
    // When uploaded, logos are converted to a ESC/POS (Epson) compatible black & white string and stored.
    // 
    // Restrictions:
    //  - Supported filetypes: BMP, GIF, JPG, PNG, TIFF, EXIF
    //  - Max file size: 1 MB
    //  - If width is above 512px image will be scaled down with constant aspect ratio. If width is below 512px will be padded with white on the right side.
    //  - Every pixel will be converted to either black or white depending on the brightness of each pixel (calculated from the RGB values).
    // 
    // Public functions:
    //  - UploadLogoFromFile(FileName : Text)
    //    For permanent storage of a logo from a file. Opens file dialog if empty filename.
    // 
    //  - UploadLogoFromBitmap(VAR Bitmap : DotNet "System.Drawing.Bitmap") : Boolean
    //    For permanent storage of logo from a .NET bitmap.
    // 
    //  - GetStoredLogoESCPOS(KeywordIn : Code[20];RegisterNo : Code[10];VAR ESCPOS : Text;VAR Width : Integer;VAR Height : Integer) : Boolean
    //    For retrieval of stored logo ESCPOS string, ie. when printing logos on an epson receipt printer.
    // 
    //  - GetLogoESCPOS(VAR Bitmap : DotNet "System.Drawing.Bitmap";VAR ESCPOS : Text) : Boolean
    //    For run-time image -> ESCPOS conversion without storage, ie. when printing a powertag or similar that changes depending on the context and thus cannot be stored in advance.
    // 
    //  - TestPrintESCPOS(VAR RetailLogo : Record "Retail Logo")
    //    Test logo print on printer specified by Object Output Selection for the regular sales ticket.
    // 
    // NPR5.22/MMV/20160427 CASE 223223 Moved image size check to after conversion.
    // NPR5.23/MMV /20160609 CASE 241549 Refactored file upload for web client support (No client .NET) & stream instead of file on nst.
    // NPR5.30/MMV /20170130 CASE 265076 Validate size after conversion to ESCPOS. (8-bit ppx rather than 32-bit ppx).
    //                                   New size limit based on fact rather than guess.
    //                                   Small refactoring.
    // NPR5.32/MMV /20170411 CASE 241995 Retail Print 2.0
    // NPR5.40/MMV /20180306 CASE 284505 Added fields for permanent storage of ESCPOS specific constants per logo.
    // NPR5.46/BHR /20180906 CASE 327525 Export Logo


    trigger OnRun()
    begin
    end;

    var
        Error000001: Label 'Maximum supported image size after conversion is 65523 bytes.\Uploaded image is %1 bytes after conversion. This usually happens if the image has too much height.';
        Error000002: Label 'No Object Output found for codeunit %1';
        Error000003: Label 'Invalid Object Output for codeunit %1';
        Error000004: Label 'No sales ticket set up in retail report selection. \The "Print Logo" action uses the sales ticket object output to select a test printer!';
        Text000001: Label 'Insert Keyword';
        Text_UploadCaption: Label 'Choose logo file';

    procedure GetRetailLogo(KeywordIn: Code[20];RegisterNo: Code[10];var RetailLogo: Record "Retail Logo"): Boolean
    var
        InStream: InStream;
        ByteArray: DotNet Array;
        MemoryStream: DotNet MemoryStream;
        Encoding: DotNet Encoding;
        FromDate: Date;
        ToDate: Date;
        RetailFormCode: Codeunit "Retail Form Code";
    begin
        //Use RetailLogo.SETAUTOCALCFIELDS() on the blobs you need, before you call this function.

        if RegisterNo = '' then
          RegisterNo := RetailFormCode.FetchRegisterNumber();

        RetailLogo.SetRange(Keyword, KeywordIn);
        RetailLogo.SetRange("Register No.", RegisterNo);
        if RetailLogo.IsEmpty then
          RetailLogo.SetRange("Register No.",'');

        RetailLogo.SetFilter("Start Date", '<=%1|=%2', Today, 0D);
        RetailLogo.SetFilter("End Date", '>=%1|=%2', Today, 0D);

        exit(RetailLogo.FindSet);
    end;

    procedure GetLogoESCPOS(var Bitmap: DotNet Bitmap): Text
    begin
        ConvertToNonIndexed32bit(Bitmap);

        exit(ConvertToESCPOS(Bitmap));
    end;

    procedure UploadLogoFromFile(FileName: Text): Boolean
    var
        Bitmap: DotNet Bitmap;
        ESCPOS: Text;
    begin
        if not ImportImage(Bitmap) then
          exit(false);

        exit(UploadLogoFromBitmap(Bitmap));
    end;

    procedure UploadLogoFromBitmap(var Bitmap: DotNet Bitmap): Boolean
    var
        ESCPOS: Text;
    begin
        ConvertToNonIndexed32bit(Bitmap);

        ESCPOS := ConvertToESCPOS(Bitmap);

        if StrLen(ESCPOS) > 65523 then
          Error(Error000001, Format(StrLen(ESCPOS)));

        CreateRecord(Bitmap,ESCPOS);

        exit(true);
    end;

    procedure TestPrintESCPOS(var RetailLogo: Record "Retail Logo")
    var
        ObjectOutputMgt: Codeunit "Object Output Mgt.";
        EpsonVLib: Codeunit "RP Epson V Device Library";
        ReportSelectionRetail: Record "Report Selection Retail";
        RetailFormCode: Codeunit "Retail Form Code";
        InStream: InStream;
        MemoryStream: DotNet MemoryStream;
        ESCPOS: Text;
        Encoding: DotNet Encoding;
        ByteArray: DotNet Array;
        ObjectOutputSelection: Record "Object Output Selection";
        PrintMethodMgt: Codeunit "Print Method Mgt.";
        tmpDeviceSettings: Record "RP Device Settings" temporary;
    begin
        //Print the test logo on the same object output printer as the sales ticket is set to use

        ReportSelectionRetail.SetRange("Report Type", ReportSelectionRetail."Report Type"::"Sales Receipt");
        ReportSelectionRetail.SetRange("Register No.", RetailFormCode.FetchRegisterNumber());
        if ReportSelectionRetail.IsEmpty then
          ReportSelectionRetail.SetRange("Register No.", '');
        if not (ReportSelectionRetail.FindFirst and ((ReportSelectionRetail."Codeunit ID" > 0) or (StrLen(ReportSelectionRetail."Print Template") <> 0))) then
          Error(Error000004);

        if not ObjectOutputMgt.TryGetOutputRec(ObjectOutputSelection."Object Type"::Codeunit, ReportSelectionRetail."Codeunit ID", ReportSelectionRetail."Print Template", UserId, ObjectOutputSelection) then
          Error(Error000002, Format(ReportSelectionRetail."Codeunit ID"));

        if (ObjectOutputSelection."Output Type" <> ObjectOutputSelection."Output Type"::"Printer Name") or (not EpsonVLib.IsThisDevice(ObjectOutputSelection."Output Path")) then
          Error(Error000003);

        if RetailLogo.ESCPOSLogo.HasValue then begin
          RetailLogo.CalcFields(ESCPOSLogo);
          RetailLogo.ESCPOSLogo.CreateInStream(InStream);
          MemoryStream := MemoryStream.MemoryStream;
          CopyStream(MemoryStream, InStream);
          ByteArray := MemoryStream.ToArray;
          Encoding := Encoding.GetEncoding('utf-8');
          ESCPOS := Encoding.GetString(ByteArray);

          EpsonVLib.Init(tmpDeviceSettings);
          //-NPR5.40 [284505]
          //EpsonVLib.PrintBitmapFromESCPOS(ESCPOS,RetailLogo.Height);
          EpsonVLib.PrintBitmapFromESCPOS(ESCPOS, RetailLogo."ESCPOS Height Low Byte", RetailLogo."ESCPOS Height High Byte", RetailLogo."ESCPOS Cmd Low Byte", RetailLogo."ESCPOS Cmd High Byte");
          //+NPR5.40 [284505]
          EpsonVLib.PrintData('P','Control',false,false,false,0,0);
          PrintMethodMgt.PrintBytesLocal(ObjectOutputMgt.ResolvePrinterName(ObjectOutputSelection."Output Path"), EpsonVLib.GetPrintBytes(), 'iso-8859-1');
        end;
    end;

    local procedure "-- Aux"()
    begin
    end;

    local procedure ImportImage(var Bitmap: DotNet Bitmap): Boolean
    var
        FileMgt: Codeunit "File Management";
        FilePath: Text;
        TempBlob: Record TempBlob temporary;
        InStream: InStream;
    begin
        FileMgt.BLOBImportWithFilter(TempBlob,Text_UploadCaption,'','Image Files (*.BMP;*.GIF;*.JPG;*.PNG;*.TIFF;*.EXIF)|*.BMP;*.GIF;*.JPG;*.PNG;*.TIFF;*.EXIF','bmp,gif,jpg,png,tiff,exif');
        if not TempBlob.Blob.HasValue then
          exit(false);

        TempBlob.Blob.CreateInStream(InStream);
        Bitmap := Bitmap.Bitmap(InStream);

        exit(true);
    end;

    local procedure ConvertToESCPOS(var Bitmap: DotNet Bitmap) ESCPOS: Text
    var
        Color: DotNet Color;
        Threshold: Decimal;
        Luminance: Decimal;
        Index: Integer;
        y: Integer;
        x: Integer;
        Black: Boolean;
        Char: Char;
        Convert: DotNet Convert;
        SliceBits: Text;
    begin
        Threshold := 127.0;
        Index := 0;
        for y := 0 to Bitmap.Height-1 do
          for x := 0 to Bitmap.Width-1 do begin
            Color     := Bitmap.GetPixel(x,y);
            Luminance := (Color.R * 0.3) + (Color.G * 0.59) + (Color.B * 0.11);
            Black := Luminance < Threshold;

            //Since we have no bit-shifting in C/AL, we use a string SliceBits to build up a byte, bit by bit. Each bit corresponds to a burn by the printerhead on that exact x,y coordinate.
            if Black then begin
              SliceBits += '1';
              Bitmap.SetPixel(x,y,Color.Black);
            end else begin
              SliceBits += '0';
              Bitmap.SetPixel(x,y,Color.White);
            end;

            if ((Index+1) mod 8) = 0 then begin
              Char := Convert.ToInt32(SliceBits,2); //Converts a textual representation of an 8-bit binary number (=byte) to integer so we can print the corresponding character.
              ESCPOS += Format(Char);
              SliceBits := '';
            end;

            Index += 1;
          end;

        if SliceBits <> '' then begin
          SliceBits := PadStr(SliceBits,8,'0');
          Char := Convert.ToInt32(SliceBits,2);
          ESCPOS += Format(Char);
        end;
    end;

    local procedure CreateRecord(var Bitmap: DotNet Bitmap;ESCPOS: Text)
    var
        RetailLogo: Record "Retail Logo";
        OutStream: OutStream;
        ImageFormat: DotNet ImageFormat;
        MemoryStream: DotNet MemoryStream;
        ByteArray: DotNet Array;
        Encoding: DotNet Encoding;
        BitConverter: DotNet BitConverter;
    begin
        RetailLogo.Init;
        RetailLogo.NewRecord;
        RetailLogo.Keyword := Text000001;
        RetailLogo.Width   := Bitmap.Width;
        RetailLogo.Height  := Bitmap.Height;

        //-NPR5.40 [284505]
        ByteArray := BitConverter.GetBytes(RetailLogo.Height);
        RetailLogo."ESCPOS Height Low Byte" := ByteArray.GetValue(0);
        RetailLogo."ESCPOS Height High Byte" := ByteArray.GetValue(1);

        ByteArray := BitConverter.GetBytes(StrLen(ESCPOS) + 10); //10 is the constant number of bytes before the variable length image data in this command.
        RetailLogo."ESCPOS Cmd Low Byte" := ByteArray.GetValue(0);
        RetailLogo."ESCPOS Cmd High Byte" := ByteArray.GetValue(1);
        //+NPR5.40 [284505]

        RetailLogo.Logo.CreateOutStream(OutStream);
        Bitmap.Save(OutStream, ImageFormat.Bmp);
        RetailLogo.Insert;

        Clear(OutStream);
        RetailLogo.ESCPOSLogo.CreateOutStream(OutStream);
        Encoding := Encoding.GetEncoding('utf-8');
        ByteArray := Encoding.GetBytes(ESCPOS);
        MemoryStream := MemoryStream.MemoryStream;
        MemoryStream.Write(ByteArray, 0, ByteArray.Length);
        MemoryStream.WriteTo(OutStream);
        RetailLogo.Modify;
    end;

    local procedure ConvertToNonIndexed32bit(var BitmapIn: DotNet Bitmap)
    var
        Bitmap: DotNet Bitmap;
        Graphics: DotNet Graphics;
        PixelFormat: DotNet PixelFormat;
        PixelOffsetMode: DotNet PixelOffsetMode;
        Rectangle: DotNet Rectangle;
        Color: DotNet Color;
        Ratio: Decimal;
        Height: Integer;
        Width: Integer;
        PaddedHeight: Integer;
    begin
        if BitmapIn.Width < 513 then begin
          Width  := BitmapIn.Width;
          Height := BitmapIn.Height;
        end else begin
          Ratio  := 512 / BitmapIn.Width;
          Height := Round(BitmapIn.Height*Ratio,1,'=');
          Width  := 512;
        end;

        if Height mod 24 <> 0 then
          PaddedHeight := Height + (24 - (Height mod 24))
        else
          PaddedHeight := Height;

        Bitmap := Bitmap.Bitmap(512, PaddedHeight, PixelFormat.Format32bppArgb);
        Bitmap.SetResolution(96,96);

        Rectangle := Rectangle.Rectangle(0,0,Width,Height);
        Graphics := Graphics.FromImage(Bitmap);
        Graphics.Clear(Color.White);
        Graphics.PixelOffsetMode := PixelOffsetMode.HighQuality;
        Graphics.DrawImage(BitmapIn, Rectangle);

        BitmapIn := Bitmap;
    end;

    procedure ExportImageBMP(RetailLogo: Record "Retail Logo")
    var
        FileManagement: Codeunit "File Management";
        TempBlob: Record TempBlob;
    begin
        //-NPR5.46 [327525]
        RetailLogo.CalcFields(Logo);
        if RetailLogo.Logo.HasValue then begin
          TempBlob.Init;
          TempBlob.Blob := RetailLogo.Logo;
          FileManagement.BLOBExport(TempBlob,RetailLogo.Keyword+Format(RetailLogo.Sequence)+'.bmp',true);
        end;
        //-NPR5.46 [327525]
    end;
}

