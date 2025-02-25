codeunit 6150960 "NPR RP Line Print"
{
    Access = Public;

    var
        RPLinePrintMgt: Codeunit "NPR RP Line Print Mgt.";

    procedure AddTextField(Column: Integer; Align: Integer; Text: Text)
    begin
        RPLinePrintMgt.AddTextField(Column, Align, Text);
    end;

    procedure AddDecimalField(Column: Integer; Align: Integer; Decimal: Decimal)
    begin
        RPLinePrintMgt.AddDecimalField(Column, Align, Decimal);
    end;

    procedure AddDateField(Column: Integer; Align: Integer; Date: Date)
    begin
        RPLinePrintMgt.AddDateField(Column, Align, Date);
    end;

    procedure AddBarcode(BarcodeType: Text[30]; BarcodeValue: Text; BarcodeWidth: Integer; HideHRI: Boolean; BarcodeHeight: Integer)
    begin
        RPLinePrintMgt.AddBarcode(BarcodeType, BarcodeValue, BarcodeWidth, HideHRI, BarcodeHeight);
    end;

    [Obsolete('Pending removal, use overload method instead', '2023-06-28')]
    procedure AddLine(Text: Text)
    begin
        RPLinePrintMgt.AddLine(Text, 0);
    end;

    procedure AddLine(Text: Text; Alignment: Integer)
    begin
        RPLinePrintMgt.AddLine(Text, Alignment);
    end;

    procedure NewLine()
    begin
        RPLinePrintMgt.NewLine();
    end;

    procedure SetFont(FontName: Text[30])
    begin
        RPLinePrintMgt.SetFont(FontName);
    end;

    procedure SetAutoLineBreak(AutoLineBreakIn: Boolean)
    begin
        RPLinePrintMgt.SetAutoLineBreak(AutoLineBreakIn);
    end;

    procedure SetBold(Bold: Boolean)
    begin
        RPLinePrintMgt.SetBold(Bold);
    end;

    procedure SetUnderLine(UnderLine: Boolean)
    begin
        RPLinePrintMgt.SetUnderLine(UnderLine);
    end;

    procedure SetDoubleStrike(DoubleStrike: Boolean)
    begin
        RPLinePrintMgt.SetDoubleStrike(DoubleStrike);
    end;

    procedure SetTwoColumnDistribution(Col1Factor: Decimal; Col2Factor: Decimal)
    begin
        RPLinePrintMgt.SetTwoColumnDistribution(Col1Factor, Col2Factor);
    end;

    procedure SetThreeColumnDistribution(Col1Factor: Decimal; Col2Factor: Decimal; Col3Factor: Decimal)
    begin
        RPLinePrintMgt.SetThreeColumnDistribution(Col1Factor, Col2Factor, Col3Factor);
    end;

    procedure SetFourColumnDistribution(Col1Factor: Decimal; Col2Factor: Decimal; Col3Factor: Decimal; Col4Factor: Decimal)
    begin
        RPLinePrintMgt.SetFourColumnDistribution(Col1Factor, Col2Factor, Col3Factor, Col4Factor);
    end;

    procedure SetDecimalRounding(DecimalRoundingIn: Option "2","3","4","5")
    begin
        RPLinePrintMgt.SetDecimalRounding(DecimalRoundingIn);
    end;

    procedure SetPadChar(Char: Text[1])
    begin
        RPLinePrintMgt.SetPadChar(Char);
    end;

    procedure ProcessBuffer(CodeunitID: Integer; PrinterDevice: Enum "NPR Line Printer Device"; var PrinterDeviceSettings: Record "NPR Printer Device Settings")
    begin
        RPLinePrintMgt.ProcessBuffer(CodeunitID, PrinterDevice, PrinterDeviceSettings);
    end;

    procedure ProcessTemplate("Code": Code[20]; RecordVariant: Variant)
    begin
        RPLinePrintMgt.ProcessTemplate(Code, RecordVariant);
    end;

    procedure ProcessTemplate("Code": Code[20]; RecRef: RecordRef)
    begin
        RPLinePrintMgt.ProcessTemplate(Code, RecRef);
    end;

    procedure UpdateField(Column: Integer; Align: Integer; Width: Integer; Font: Text[30]; Text: Text[2048]; HideHRI: Boolean; Height: Integer)
    begin
        RPLinePrintMgt.UpdateField(Column, Align, Width, Font, Text, HideHRI, Height);
    end;
}
