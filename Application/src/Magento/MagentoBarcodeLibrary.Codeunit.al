codeunit 6151409 "NPR Magento Barcode Library"
{
    ObsoleteState = Pending;
    ObsoleteReason = 'BarcodeLibrary.Codeunit is in use';

    var
        BarCodeType: DotNet NPRNetBarCodeType;
        BarCodeSettings: DotNet NPRNetBarcodeSettings;
        BarCodeGenerator: DotNet NPRNetBarCodeGenerator;
        Image: DotNet NPRNetImage;
        ImageFormat: DotNet NPRNetImageFormat;
        SizeX: Decimal;
        SizeY: Decimal;
        DpiX: Decimal;
        DpiY: Decimal;
        RotateAngle: Integer;
        BarcodeTypeText: Code[10];

    procedure GenerateBarcode(BarCode: Code[20]; var TempBlob: Codeunit "Temp Blob")
    var
        MemoryStream: DotNet NPRNetMemoryStream;
        OutStream: OutStream;
    begin
        Init(BarCode);
        BarCodeGenerator := BarCodeGenerator.BarCodeGenerator(BarCodeSettings);
        BarCodeSettings.ApplyKey('3YOZI-9N0S5-RD239-JN9R0-WCGL8');
        Image := BarCodeGenerator.GenerateImage();
        MemoryStream := MemoryStream.MemoryStream;
        Image.Save(MemoryStream, ImageFormat.Png);
        Clear(TempBlob);
        TempBlob.CreateOutStream(OutStream);
        CopyStream(OutStream, MemoryStream);
    end;

    local procedure Init(BarCode: Code[20])
    begin
        BarCodeSettings := BarCodeSettings.BarcodeSettings();
        BarCodeSettings.Data := BarCode;

        if SizeX <> 0 then BarCodeSettings.X := SizeX;
        if SizeY <> 0 then BarCodeSettings.Y := SizeY;
        if DpiX <> 0 then BarCodeSettings.DpiX := DpiX;
        if DpiY <> 0 then BarCodeSettings.DpiY := DpiY;
        if RotateAngle <> 0 then BarCodeSettings.Rotate := RotateAngle;

        case UpperCase(BarcodeTypeText) of
            'EAN13':
                BarCodeSettings.Type := BarCodeType.EAN13;
            'CODE39':
                BarCodeSettings.Type := BarCodeType.Code39;
            else begin
                    if StrLen(BarCode) = 13 then
                        BarCodeSettings.Type := BarCodeType.EAN13
                    else
                        BarCodeSettings.Type := BarCodeType.Code39;
                end;
        end;
    end;

    #region Properties

    procedure SetSizeX(Size: Decimal)
    begin
        SizeX := Size;
    end;

    procedure SetSizeY(Size: Decimal)
    begin
        SizeY := Size;
    end;

    procedure SetDpiX(X: Integer)
    begin
        DpiX := X;
    end;

    procedure SetDpiY(Y: Integer)
    begin
        DpiY := Y;
    end;

    procedure Rotate(RotateAngleIn: Integer)
    begin
        RotateAngle := RotateAngleIn;
    end;

    procedure SetBarcodeType(BarcodeTypeTextIn: Code[10])
    begin
        BarcodeTypeText := BarcodeTypeTextIn;
    end;

    #endregion
}