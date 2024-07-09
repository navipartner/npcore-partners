codeunit 6060039 "NPR RP Matrix Print"
{
    Access = Public;

    var
        RPMatrixPrintMgt: Codeunit "NPR RP Matrix Print Mgt.";

    procedure AddTextField(X: Integer; Y: Integer; Align: Integer; Text: Text)
    begin
        RPMatrixPrintMgt.AddTextField(X, Y, Align, Text);
    end;

    procedure AddDecimalField(X: Integer; Y: Integer; Align: Integer; Decimal: Decimal)
    begin
        RPMatrixPrintMgt.AddDecimalField(X, Y, Align, Decimal);
    end;

    procedure AddDateField(X: Integer; Y: Integer; Align: Integer; Date: Date)
    begin
        RPMatrixPrintMgt.AddDateField(X, Y, Align, Date);
    end;

    [Obsolete('Pending removal, use overload procedure instead', '2023-06-28')]
    procedure AddBarcode(BarcodeType: Text[30]; BarcodeValue: Text[30]; BarcodeWidth: Integer; Align: Integer)
    begin
        RPMatrixPrintMgt.AddBarcode(BarcodeType, BarcodeValue, BarcodeWidth, Align, false);
    end;

    procedure AddBarcode(BarcodeType: Text[30]; BarcodeValue: Text[30]; BarcodeWidth: Integer; Align: Integer; HideHRI: Boolean)
    begin
        RPMatrixPrintMgt.AddBarcode(BarcodeType, BarcodeValue, BarcodeWidth, Align, HideHRI);
    end;

    procedure NewLine()
    begin
        RPMatrixPrintMgt.NewLine();
    end;

    procedure SetFont(FontName: Text[30])
    begin
        RPMatrixPrintMgt.SetFont(FontName);
    end;

    procedure SetBold(Bold: Boolean)
    begin
        RPMatrixPrintMgt.SetBold(Bold);
    end;

    procedure ProcessBuffer(CodeunitID: Integer; PrinterDevice: Enum "NPR Matrix Printer Device"; var PrinterDeviceSettings: Record "NPR Printer Device Settings")
    begin
        RPMatrixPrintMgt.ProcessBuffer(CodeunitID, PrinterDevice, PrinterDeviceSettings);
    end;

    procedure ProcessTemplate(Template: Code[20]; var RecRef: RecordRef)
    begin
        RPMatrixPrintMgt.ProcessTemplate(Template, RecRef);
    end;

    procedure SetPrintIterationFieldNo(FieldNo: Integer)
    begin
        RPMatrixPrintMgt.SetPrintIterationFieldNo(FieldNo);
    end;

    procedure SetDecimalRounding(DecimalRoundingIn: Option "2","3","4","5")
    begin
        RPMatrixPrintMgt.SetDecimalRounding(DecimalRoundingIn);
    end;
}
