codeunit 6060032 "NPR Tax Free GBI2 Try Print"
{
    Access = Internal;
    TableNo = "NPR Tax Free Request";

    var
        Error_MissingPrintSetup: Label 'Missing object output setup';


    trigger OnRun()
    begin
        PrintVoucher(Rec);
    end;

    local procedure PrintVoucher(TaxFreeRequest: Record "NPR Tax Free Request")
    begin
        case TaxFreeRequest."Print Type" of
            TaxFreeRequest."Print Type"::Thermal:
                PrintThermal(TaxFreeRequest);
            TaxFreeRequest."Print Type"::PDF:
                PrintPDF(TaxFreeRequest);
        end;
    end;

    local procedure PrintThermal(TaxFreeRequest: Record "NPR Tax Free Request")
    var
        PrinterDeviceSettings: Record "NPR Printer Device Settings";
        ObjectOutputMgt: Codeunit "NPR Object Output Mgt.";
        Printer: Codeunit "NPR RP Line Print Mgt.";
        InStream: InStream;
        Line: Text;
        Output: Text;
    begin
        Output := ObjectOutputMgt.GetCodeunitOutputPath(CODEUNIT::"NPR Tax Free Receipt");
        if Output = '' then
            Error(Error_MissingPrintSetup);

        Printer.SetThreeColumnDistribution(0.33, 0.33, 0.33);
        Printer.SetAutoLineBreak(false);

        TaxFreeRequest.Print.CreateInStream(InStream, TEXTENCODING::UTF8);
        while (not InStream.EOS) do begin
            InStream.ReadText(Line);
            PrintThermalLine(Printer, Line);
        end;

        PrintThermalLine(Printer, '<TearOff>'); //A final cut is not included in the printjob from I2 server.

        Printer.ProcessBuffer(Codeunit::"NPR Tax Free Receipt", Enum::"NPR Line Printer Device"::Epson, PrinterDeviceSettings);
    end;

    local procedure PrintThermalLine(var Printer: Codeunit "NPR RP Line Print Mgt."; Line: Text)
    var
        Bold: Boolean;
        Center: Boolean;
        HFont: Boolean;
        Inverse: Boolean;
        String: Text;
        StringUpper: Text;
        Value: Text;
    begin
        String := Line;
        StringUpper := UpperCase(Line);

        if StringUpper.Contains('<BC>') then begin
            String := String.Replace('<BC>', '');
            String := String.Replace('</BC>', '');
            String := String.Replace('<bc>', '');
            String := String.Replace('</bc>', '');
            Value := String;
            Printer.AddBarcode('ITF', Value, 2, false, 40);
            exit;
        end;

        if StringUpper.Contains('<IMG>') then begin
            Printer.SetFont('Logo');
            Printer.AddLine('TAXFREE', 0);
            exit;
        end;

        if StringUpper.Contains('<TEAROFF>') or StringUpper.Contains('<TEAROFF/>') then begin
            Printer.SetFont('COMMAND');
            Printer.AddLine('PAPERCUT', 0);
            exit;
        end;

        if StringUpper.Contains('<CENTER>') or StringUpper.Contains('<C>') then begin
            String := String.Replace('<CENTER>', '');
            String := String.Replace('</CENTER>', '');
            String := String.Replace('<C>', '');
            String := String.Replace('</C>', '');
            String := String.Replace('<center>', '');
            String := String.Replace('</center>', '');
            String := String.Replace('<c>', '');
            String := String.Replace('</c>', '');
            Center := true;
        end;

        if StringUpper.Contains('<INVERSE>') or StringUpper.Contains('<I>') then begin
            String := String.Replace('<INVERSE>', '');
            String := String.Replace('</INVERSE>', '');
            String := String.Replace('<I>', '');
            String := String.Replace('</I>', '');
            String := String.Replace('<inverse>', '');
            String := String.Replace('</inverse>', '');
            String := String.Replace('<i>', '');
            String := String.Replace('</i>', '');
            Inverse := true;
        end;

        if StringUpper.Contains('<HFONT>') or StringUpper.Contains('<H>') then begin
            String := String.Replace('<HFONT>', '');
            String := String.Replace('</HFONT>', '');
            String := String.Replace('<H>', '');
            String := String.Replace('</H>', '');
            String := String.Replace('<hfont>', '');
            String := String.Replace('</hfont>', '');
            String := String.Replace('<h>', '');
            String := String.Replace('</h>', '');
            HFont := true;
        end;

        if StringUpper.Contains('<BOLD>') or StringUpper.Contains('<B>') then begin
            String := String.Replace('<BOLD>', '');
            String := String.Replace('</BOLD>', '');
            String := String.Replace('<B>', '');
            String := String.Replace('</B>', '');
            String := String.Replace('<bold>', '');
            String := String.Replace('</bold>', '');
            String := String.Replace('<b>', '');
            String := String.Replace('</b>', '');
            Bold := true;
        end;

        Line := String;

        Printer.SetBold(Bold or Inverse);
        Printer.SetUnderLine(Inverse); //As per agreement inverse will not actually be inverted colors. It will be highlighted via other means.
        if HFont then
            Printer.SetFont('B21')
        else
            Printer.SetFont('A11');

        if Line = '' then
            Line := ' ';

        while (Line <> '') do begin
            if Center then
                Printer.AddTextField(2, 1, CopyStr(Line, 1, 42))
            else
                Printer.AddTextField(1, 0, CopyStr(Line, 1, 42));
            Line := CopyStr(Line, 43);
            Printer.NewLine();
        end;
    end;

    local procedure PrintPDF(TaxFreeRequest: Record "NPR Tax Free Request")
    var
        ObjectOutputSelection: Record "NPR Object Output Selection";
        ObjectOutputMgt: Codeunit "NPR Object Output Mgt.";
        PrintMethodMgt: Codeunit "NPR Print Method Mgt.";
        InStream: InStream;
        OutputType: Integer;
        Output: Text;
    begin
        TaxFreeRequest.Print.CreateInStream(InStream);

        Output := ObjectOutputMgt.GetCodeunitOutputPath(CODEUNIT::"NPR Tax Free Receipt");
        OutputType := ObjectOutputMgt.GetCodeunitOutputType(CODEUNIT::"NPR Tax Free Receipt");

        if Output = '' then
            Error(Error_MissingPrintSetup);

        case OutputType of
            ObjectOutputSelection."Output Type"::"Printer Name".AsInteger():
                PrintMethodMgt.PrintFileLocal(Output, InStream, 'pdf');
        end;
    end;
}