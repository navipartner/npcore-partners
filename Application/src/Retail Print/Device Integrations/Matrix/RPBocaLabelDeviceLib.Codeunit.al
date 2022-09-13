codeunit 6014436 "NPR RP Boca Label Device Lib." implements "NPR IMatrix Printer"
{
    Access = Internal;

    var
        //_Encoding: Option "Windows-1252","UTF-8";
        _PrintBuffer: Codeunit "Temp Blob";
        _DotNetStream: Codeunit DotNet_Stream;
        _DotNetEncoding: Codeunit DotNet_Encoding;
        InvalidDeviceSettingErr: Label 'Invalid device setting: %1';
        SettingPrintWidthLbl: Label 'Set print width (in dots) - value between 1 and label width';
        _PrintWidth: Integer;

    procedure InitJob(var DeviceSettings: Record "NPR RP Device Settings");
    begin
        InitBuffer();

        if DeviceSettings.FindSet() then
            repeat
                case DeviceSettings.Name of
                    'PRINT_WIDTH':
                        if not Evaluate(_PrintWidth, DeviceSettings.Value) then
                            Error('The PRINT_WIDTH value is invalid.');
                    else
                        Error(InvalidDeviceSettingErr, DeviceSettings.Name);
                end;
            until DeviceSettings.Next() = 0;

        if not (_PrintWidth > 0) then
            Error('Please set a positive value for PRINT_WIDTH.');
    end;

    procedure PrintData(var POSPrintBuffer: Record "NPR RP Print Buffer" temporary);
    var
        StringLib: Codeunit "NPR String Library";
        Font: Code[10];
        FontParam: Code[10];
        R: Text[2];
    begin
        // As X-coordinates are defined from the right, we need to perform following check:
        if POSPrintBuffer.X > _PrintWidth then
            Error('The X-coordinate is outside printing space, please update the X-coordinate or increase the PRINT_WIDTH.');

        // We are rotating based on default print direction/orientation.
        case POSPrintBuffer.Rotation of
            0:
                R := 'RL';
            1:
                R := 'NR';
            2:
                R := 'RR';
            3:
                R := 'RU';
        end;

        StringLib.Construct(POSPrintBuffer.Font);
        Font := StringLib.SelectStringSep(1, ' ');
        FontParam := StringLib.SelectStringSep(2, ' ');
        if Font = FontParam then
            FontParam := '';

        case true of
            IsBarcodeFont(POSPrintBuffer.Font):
                begin
                    if (UpperCase(CopyStr(POSPrintBuffer.Font, 1, 2)) = 'QR') then
                        PrintQR(Font, (FontParam <> 'NOHRI'), POSPrintBuffer.Width, POSPrintBuffer.Align, R, POSPrintBuffer.X, POSPrintBuffer.Y, POSPrintBuffer.Text)
                    else
                        PrintBarcode(Font, (FontParam <> 'NOHRI'), POSPrintBuffer.Height, POSPrintBuffer.Width, POSPrintBuffer.Align, R, POSPrintBuffer.X, POSPrintBuffer.Y, POSPrintBuffer.Text);
                end;
            (UpperCase(CopyStr(POSPrintBuffer.Font, 1, 1)) = 'F'):
                PrintText(Font, FontParam, POSPrintBuffer.Align, R, POSPrintBuffer.X, POSPrintBuffer.Y, POSPrintBuffer.Text);
        end;
    end;

    procedure EndJob();
    begin
        AddStringToBuffer('<p>');
    end;

    procedure LookupFont(var Value: Text): Boolean;
    begin
        exit(SelectFont(Value));
    end;

    procedure LookupCommand(var Value: Text): Boolean;
    begin
        Value := '';
        exit(false);
    end;

    procedure LookupDeviceSetting(var tmpDeviceSetting: Record "NPR RP Device Settings" temporary): Boolean;
    begin
        exit(SelectDeviceSetting(tmpDeviceSetting));
    end;

    procedure PrepareJobForHTTP(var HTTPEndpoint: Text): Boolean;
    begin
        HTTPEndpoint := '';
        exit(false);
    end;

    procedure PrepareJobForBluetooth(): Boolean;
    begin
        exit(false);
    end;

    procedure GetPrintBufferAsBase64(): Text;
    var
        Base64Convert: Codeunit "Base64 Convert";
        IStream: InStream;
    begin
        _PrintBuffer.CreateInStream(IStream);
        exit(Base64Convert.ToBase64(IStream));
    end;

    local procedure AddStringToBuffer(String: Text)
    var
        DotNetCharArray: Codeunit "DotNet_Array";
        DotNetByteArray: Codeunit "DotNet_Array";
        DotNetString: Codeunit "DotNet_String";
    begin
        //This function over allocates and is verbose, all because of the beautiful DotNet wrapper codeunits.

        DotNetString.Set(String);
        DotNetString.ToCharArray(0, DotNetString.Length(), DotNetCharArray);
        _DotNetEncoding.GetBytes(DotNetCharArray, 0, DotNetCharArray.Length(), DotNetByteArray);
        _DotNetStream.Write(DotNetByteArray, 0, DotNetByteArray.Length());
    end;

    procedure SelectFont(var Value: Text): Boolean
    var
        TempRetailList: Record "NPR Retail List" temporary;
    begin
        ConstructFontSelectionList(TempRetailList);
        if PAGE.RunModal(PAGE::"NPR Retail List", TempRetailList) = ACTION::LookupOK then begin
            Value := TempRetailList.Choice;
            exit(true);
        end;
    end;

    local procedure SelectDeviceSetting(var tmpDeviceSetting: Record "NPR RP Device Settings" temporary): Boolean
    var
        TempRetailList: Record "NPR Retail List" temporary;
        RetailList: Page "NPR Retail List";
    begin
        ConstructDeviceSettingList(TempRetailList);
        RetailList.SetShowValue(true);
        RetailList.SetRec(TempRetailList);
        RetailList.LookupMode(true);
        if RetailList.RunModal() = ACTION::LookupOK then begin
            RetailList.GetRec(TempRetailList);
            tmpDeviceSetting.Name := TempRetailList.Value;
            case tmpDeviceSetting.Name of
                'PRINT_WIDTH':
                    tmpDeviceSetting."Data Type" := tmpDeviceSetting."Data Type"::Integer;
            end;
            exit(tmpDeviceSetting.Insert());

        end;
    end;

    local procedure ConstructDeviceSettingList(var tmpRetailList: Record "NPR Retail List" temporary)
    begin
        AddOption(tmpRetailList, SettingPrintWidthLbl, 'PRINT_WIDTH');
        /*
        AddOption(tmpRetailList, SettingLabelHomeLbl, 'LABEL_HOME');
        AddOption(tmpRetailList, SettingLabelLengthLbl, 'LABEL_LENGTH');
        AddOption(tmpRetailList, SettingMediaDarknessLbl, 'MEDIA_DARKNESS');
        AddOption(tmpRetailList, SettingMediaTypeLbl, 'MEDIA_TYPE');
        AddOption(tmpRetailList, SettingPrintOrientationLbl, 'PRINT_ORIENTATION');
        AddOption(tmpRetailList, SettingPrintRateLbl, 'PRINT_RATE');
        AddOption(tmpRetailList, SettingPrintWidthLbl, 'PRINT_WIDTH');
        AddOption(tmpRetailList, SettingSetDarknessLbl, 'SET_DARKNESS');
        AddOption(tmpRetailList, SettingRfidEpcMemLbl, 'RFID_EPC_MEMORY');
        AddOption(tmpRetailList, SettingEncodingLbl, 'ENCODING');
        AddOption(tmpRetailList, SettingLabelReverseLbl, 'LABEL_REVERSE');
        AddOption(tmpRetailList, SettingSensorSelectLbl, 'SENSOR_SELECT');
        */
    end;

    procedure ConstructFontSelectionList(var RetailList: Record "NPR Retail List" temporary)
    begin
        // Fonts
        AddOption(RetailList, 'F8', '');
        AddOption(RetailList, 'F8 2,1', '');
        AddOption(RetailList, 'F8 1,2', '');
        AddOption(RetailList, 'F8 2,2', '');
        AddOption(RetailList, 'F13', '');
        AddOption(RetailList, 'F13 2,1', '');
        AddOption(RetailList, 'F13 1,2', '');
        AddOption(RetailList, 'F13 2,2', '');

        AddOption(RetailList, 'F1', '');
        AddOption(RetailList, 'F2', '');
        AddOption(RetailList, 'F3', '');
        AddOption(RetailList, 'F4', '');
        AddOption(RetailList, 'F6', '');
        AddOption(RetailList, 'F7', '');
        AddOption(RetailList, 'F9', '');
        AddOption(RetailList, 'F10', '');
        AddOption(RetailList, 'F11', '');
        AddOption(RetailList, 'F12', '');

        // Regular Barcodes
        AddOption(RetailList, 'EAN13', '');
        AddOption(RetailList, 'EAN13 NOHRI', '');
        AddOption(RetailList, 'CODE128', '');
        AddOption(RetailList, 'CODE128 NOHRI', '');

        AddOption(RetailList, 'UPC', '');
        AddOption(RetailList, '3OF9', '');
        AddOption(RetailList, 'CODABAR', '');
        AddOption(RetailList, 'SOFTSTRIP', '');

        // QR
        AddOption(RetailList, 'QR', '');
        AddOption(RetailList, 'QR NOHRI', '');
        AddOption(RetailList, 'QR2L', '');
        AddOption(RetailList, 'QR2M', '');
        AddOption(RetailList, 'QR2Q', '');
        AddOption(RetailList, 'QR2H', '');
        AddOption(RetailList, 'QR7L', '');
        AddOption(RetailList, 'QR7M', '');
        AddOption(RetailList, 'QR7Q', '');
        AddOption(RetailList, 'QR7H', '');
        AddOption(RetailList, 'QR11L', '');
        AddOption(RetailList, 'QR11M', '');
        AddOption(RetailList, 'QR11Q', '');
        AddOption(RetailList, 'QR11H', '');
        AddOption(RetailList, 'QR15L', '');
        AddOption(RetailList, 'QR15M', '');
        AddOption(RetailList, 'QR15Q', '');
        AddOption(RetailList, 'QR15H', '');

        /* Might need later
        AddOption(RetailList, 'RFID EPC_HEX', '');
        AddOption(RetailList, 'RFID EPC_ASCII', '');
        AddOption(RetailList, 'RFID EPC_STD', '');
        */
    end;

    procedure AddOption(var RetailList: Record "NPR Retail List" temporary; Choice: Text; Value: Text)
    begin
        RetailList.Number += 1;
        RetailList.Choice := Choice;
        RetailList.Value := Value;
        RetailList.Insert();
    end;

    local procedure CheckMaxLengthQR(QRVersion: Integer; QRErrorCorrectionLevel: Integer): Integer
    begin
        case QRVersion of
            2:
                case QRErrorCorrectionLevel of
                    0:
                        exit(26);
                    1:
                        exit(32);
                    2:
                        exit(14);
                    3:
                        exit(20);
                end;
            7:
                case QRErrorCorrectionLevel of
                    0:
                        exit(122);
                    1:
                        exit(154);
                    2:
                        exit(64);
                    3:
                        exit(86);
                end;
            11:
                case QRErrorCorrectionLevel of
                    0:
                        exit(251);
                    1:
                        exit(321);
                    2:
                        exit(137);
                    3:
                        exit(177);
                end;
            15:
                case QRErrorCorrectionLevel of
                    0:
                        exit(412);
                    1:
                        exit(520);
                    2:
                        exit(220);
                    3:
                        exit(292);
                end;
        end;
    end;

    local procedure InitBuffer()
    var
        OStream: OutStream;
    begin
        if not _PrintBuffer.HasValue() then begin
            Clear(OStream);
            Clear(_PrintBuffer);
            Clear(_DotNetStream);
            Clear(_DotNetEncoding);
            _PrintBuffer.CreateOutStream(OStream);
            _DotNetEncoding.Encoding(850);
            _DotNetStream.FromOutStream(OStream);
        end
    end;

    local procedure PrintText(Font: Text[50]; Modifiers: Text[10]; Alignment: Option; Rotation: Text[2]; X: Integer; Y: Integer; Input: Text[100])
    var
        HW: Text[10];
        CTR: Integer;
    begin
        // We assume that the Modifiers are not ill-formatted
        if Modifiers <> '' then
            HW := Modifiers
        else
            HW := '1,1';

        case Alignment of
            0:
                AddStringToBuffer(StrSubstNo('<%1><RC%2,%3><%4><HW%5>%6', Rotation, (_PrintWidth - X), Y, Font, HW, Input));
            1:
                begin
                    // Assume that the X-coordinate is the center, hence we define the field width 2 times the location
                    if X > (_PrintWidth DIV 2) then
                        CTR := _PrintWidth - X;
                    CTR := X * 2;
                    AddStringToBuffer(StrSubstNo('<%1><RC%2,%3><%4><HW%5><CTR%6>~%7~', Rotation, ((_PrintWidth - X) + (CTR DIV 2)), Y, Font, HW, CTR, Input));
                end;
            2:
                AddStringToBuffer(StrSubstNo('<%1><RC%2,%3><%4><HW%5><RTJ%6>~%7~', Rotation, _PrintWidth, Y, Font, HW, X, Input));
        end;
    end;

    local procedure PrintBarcode(Barcode: Text[50]; HRI: Boolean; Height: Integer; Width: Integer; Alignment: Option; Rotation: Text[2]; X: Integer; Y: Integer; Input: Text[100])
    var
        H: Text[10];
        UPCEAN8Split: Integer;
    begin
        if Height > 0 then
            H := FORMAT(Height);

        AddStringToBuffer(StrSubstNo('<%1>', Rotation));
        AddStringToBuffer(StrSubstNo('<RC%1,%2>', (_PrintWidth - X), Y));

        // Alignment, will only work on new firmware 150+
        case Alignment of
            1:
                AddStringToBuffer(StrSubstNo('<CTR%1>', _PrintWidth));
        end;

        if HRI then
            AddStringToBuffer('<BI>');

        if Width > 1 then
            AddStringToBuffer(StrSubstNo('<X%1>', Width)); // set after DPI?

        case UpperCase(Barcode) of
            'EAN13':
                begin
                    AddStringToBuffer(StrSubstNo('<eL%1>', H));
                    AddStringToBuffer(StrSubstNo('%1J%2K%3L', CopyStr(Input, 1, 1), CopyStr(Input, 2, 6), CopyStr(Input, 8, 6)));
                end;
            'CODE128':
                begin
                    AddStringToBuffer(StrSubstNo('<oL%1>', H));
                    AddStringToBuffer(StrSubstNo('^%1^', Input));
                end;
            'UPC':
                begin
                    UPCEAN8Split := StrLen(Input) DIV 2; // EAN8 is roughly an 8 character UPC code (UPC is typically 12 chars), hence we just split the string in half
                    AddStringToBuffer(StrSubstNo('<uL%1>', H));
                    AddStringToBuffer(StrSubstNo('J%1K%2L', CopyStr(Input, 1, UPCEAN8Split), CopyStr(Input, UPCEAN8Split + 1, UPCEAN8Split)));
                end;
            '3OF9':
                begin
                    AddStringToBuffer(StrSubstNo('<nL%1>', H));
                    AddStringToBuffer(StrSubstNo('^%1^', Input));
                end;
            'I2OF5':
                begin
                    AddStringToBuffer(StrSubstNo('<fL%1>', H));
                    AddStringToBuffer(StrSubstNo('^:%1:^', Input));
                end;
            'CODABAR':
                begin
                    AddStringToBuffer(StrSubstNo('<cL%1>', H));
                    AddStringToBuffer(StrSubstNo('^%1^', Input));
                end;
            'SOFTSTRIP':
                begin
                    AddStringToBuffer(StrSubstNo('<sL%1>', H));
                    AddStringToBuffer(StrSubstNo('^%1^', Input));
                end;
        end;
    end;

    local procedure PrintQR(Barcode: Text[50]; HRI: Boolean; Size: Integer; Alignment: Option; Rotation: Text[2]; X: Integer; Y: Integer; Input: Text[100])
    var
        QRBarcodeVers: Integer;
        QRBarcodeErrLvl: Integer;
        QRMaxLength: Integer;
        QRWidth: Integer;
        QRCenter: Integer;
        yHRI: Integer;
    begin
        if StrPos(Barcode, '7') > 0 then
            QRBarcodeVers := 7
        else
            if StrPos(Barcode, '11') > 0 then
                QRBarcodeVers := 11
            else
                if StrPos(Barcode, '15') > 0 then
                    QRBarcodeVers := 15
                else
                    QRBarcodeVers := 2;

        case CopyStr(Barcode, strlen(Barcode)) of
            'L':
                QRBarcodeErrLvl := 1;
            'H':
                QRBarcodeErrLvl := 2;
            'Q':
                QRBarcodeErrLvl := 3;
            else
                QRBarcodeErrLvl := 0;
        end;

        QRMaxLength := CheckMaxLengthQR(QRBarcodeVers, QRBarcodeErrLvl);

        if StrLen(Input) > QRMaxLength then
            Error('The value of the QR code exceeds the max limit for current QR settings. Try Lowering the Error Correction Level or increasing the QR version.')
        else begin
            AddStringToBuffer(StrSubstNo('<QRV%1>', QRBarcodeVers));

            if (Size >= 3) and (Size <= 16) then
                QRWidth := Size
            else
                QRWidth := 6; // default

            AddStringToBuffer(StrSubstNo('<%1>', Rotation));

            // Overrule width to center
            case QRBarcodeVers of
                2:
                    begin
                        yHRI := (QRWidth * 25);
                        QRCenter := (_PrintWidth + yHRI) DIV 2
                    end;
                7:
                    begin
                        yHRI := (QRWidth * 45);
                        QRCenter := (_PrintWidth + yHRI) DIV 2
                    end;
                11:
                    begin
                        yHRI := (QRWidth * 61);
                        QRCenter := (_PrintWidth + yHRI) DIV 2
                    end;
                15:
                    begin
                        yHRI := (QRWidth * 77);
                        QRCenter := (_PrintWidth + yHRI) DIV 2
                    end;
            end;

            if Alignment = 1 then
                AddStringToBuffer(StrSubstNo('<RC%1,%2>', QRCenter, Y))
            else
                AddStringToBuffer(StrSubstNo('<RC%1,%2>', (_PrintWidth - X), Y));
            AddStringToBuffer(StrSubstNo('<QR%1,%2,%3,%4>{%5}', QRWidth, 0, 0, QRBarcodeErrLvl, Input));

            if HRI then begin
                AddStringToBuffer('<RL>');
                AddStringToBuffer(StrSubstNo('<RC%1,%2>', _PrintWidth, Y + yHRI));
                AddStringToBuffer('<F8>');
                AddStringToBuffer(StrSubstNo('<CTR%1>', _PrintWidth));
                AddStringToBuffer('~' + Input + '~');
            end;
        end;
    end;

    local procedure IsBarcodeFont(Font: Text): Boolean
    var
        StringLib: Codeunit "NPR String Library";
    begin
        Font := UpperCase(Font);

        StringLib.Construct(Font);
        Font := StringLib.SelectStringSep(1, ' ');

        if Font in ['EAN13', 'CODE128', 'UPC', '3OF9', 'I2OF5', 'CODABAR', 'SOFTSTRIP',
                    'QR', 'QR2L', 'QR2M', 'QR2Q', 'QR2H', 'QR7L', 'QR7M', 'QR7Q', 'QR7H', 'QR11L', 'QR11M', 'QR11Q', 'QR11H', 'QR15L', 'QR15M', 'QR15Q', 'QR15H'] then
            exit(true);
    end;
}