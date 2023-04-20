codeunit 6060033 "NPR Tax Free PTFPI Try Print"
{
    Access = Internal;
    TableNo = "NPR Tax Free Request";

    var
        Error_MissingPrintSetup: Label 'Missing object output setup';
        Error_PrintData: Label 'Invalid print data returned from service';

    trigger OnRun()
    begin
        PrintVoucher(Rec);
    end;

    procedure PrintVoucher(var TaxFreeRequest: Record "NPR Tax Free Request")
    begin
        case TaxFreeRequest."Print Type" of
            TaxFreeRequest."Print Type"::PDF:
                PrintPDF(TaxFreeRequest);
            TaxFreeRequest."Print Type"::Thermal:
                PrintThermalReceipt(TaxFreeRequest);
        end;
    end;

    local procedure PrintThermalReceipt(var TaxFreeRequest: Record "NPR Tax Free Request")
    var
        PrinterDeviceSettings: Record "NPR Printer Device Settings";
        ObjectOutputMgt: Codeunit "NPR Object Output Mgt.";
        Printer: Codeunit "NPR RP Line Print Mgt.";
        InStream: InStream;
        i: Integer;
        Line: Text;
        Output: Text;
        XMLDoc: XmlDocument;
        XMLNode: XmlNode;
        PrintLines: XmlNodeList;
        PrintXmlChunk: Text;
        PrintXml: Text;
    begin
        //See page 55 of doc. for print line prefix explanations.
        Output := ObjectOutputMgt.GetCodeunitOutputPath(CODEUNIT::"NPR Tax Free Receipt");

        if Output = '' then
            Error(Error_MissingPrintSetup);

        TaxFreeRequest.Print.CreateInStream(InStream, TEXTENCODING::UTF8);

        while (not InStream.EOS) do begin
            InStream.Read(PrintXmlChunk);
            PrintXml += PrintXmlChunk;
        end;

        XmlDocument.ReadFrom(PrintXml, XMLDoc);

        PrintLines := XMLDoc.GetDescendantElements('print_line');//Thermal Receipt Data
        if PrintLines.Count() < 1 then
            Error(Error_PrintData);

        Printer.SetThreeColumnDistribution(0.33, 0.33, 0.33);
        Printer.SetAutoLineBreak(false);

        for i := 1 to (PrintLines.Count) do begin
            PrintLines.Get(i, XMLNode);
            Line := XMLNode.AsXmlElement().InnerText();
            case CopyStr(Line, 1, 2) of
                '01':
                    PrintThermalLine(Printer, 'TAXFREE', 'LOGO', false, 'LEFT', true, false); //Tax free logo bitmap
                '02':
                    PrintThermalLine(Printer, CopyStr(Line, 3), 'B21', true, 'LEFT', true, false);
                '03':
                    PrintThermalLine(Printer, CopyStr(Line, 3), 'B21', false, 'LEFT', true, true);
                '04':
                    PrintThermalLine(Printer, CopyStr(Line, 3), 'A11', false, 'LEFT', true, true);
                '05':
                    PrintThermalLine(Printer, CopyStr(Line, 3), 'A11', false, 'LEFT', true, false);
                '06':
                    PrintThermalLine(Printer, CopyStr(Line, 3), 'A11', true, 'LEFT', true, false);
                '07':
                    PrintThermalLine(Printer, CopyStr(Line, 3), 'A11', false, 'LEFT', true, false); //Wide font?
                '08':
                    PrintThermalLine(Printer, CopyStr(Line, 3), 'A11', false, 'RIGHT', true, false);
                '09':
                    PrintThermalLine(Printer, CopyStr(Line, 3), 'A11', false, 'CENTER', true, false);
                '10':
                    PrintThermalLine(Printer, CopyStr(Line, 3), 'B21', true, 'CENTER', true, false);
                '11':
                    if StrLen(CopyStr(Line, 3)) < 30 then
                        PrintThermalLine(Printer, CopyStr(Line, 3), 'CODE128', false, 'LEFT', true, false)
                    else
                        PrintThermalLine(Printer, CopyStr(Line, 3), 'A11', false, 'LEFT', true, false);
                '12':
                    PrintThermalLine(Printer, ' ', 'A11', false, 'LEFT', true, false);
                '13':
                    PrintThermalLine(Printer, 'PAPERCUT', 'COMMAND', false, 'LEFT', true, false);
                '14':
                    PrintThermalLine(Printer, CopyStr(Line, 3), 'A11', false, 'LEFT', false, false);
                '21': //URL for phone scan of voucher encoded as QR
                    PrintThermalLine(Printer, CopyStr(Line, 3), 'QR', false, 'LEFT', true, false);
                '50':
                    ; //Load another voucher
                '51':
                    PrintThermalLine(Printer, 'COPY', 'A11', false, 'LEFT', true, false); //Print Copy?
                '61':
                    ; //remaining print is base64 encoded
                '70':
                    begin //Store logo bitmap
                        PrintThermalLine(Printer, 'STOREDLOGO_1', 'COMMAND', false, 'LEFT', true, false);
                        PrintThermalLine(Printer, 'STOREDLOGO_2', 'COMMAND', false, 'LEFT', true, false);
                    end;
                '71':
                    ; //Store signature bitmap
                '72':
                    ; //Customer signature?
                '73':
                    ; //Country specific digital signature
            end;
        end;

        Printer.ProcessBuffer(Codeunit::"NPR Tax Free Receipt", Enum::"NPR Line Printer Device"::Epson, PrinterDeviceSettings);
    end;

    local procedure PrintThermalLine(var Printer: Codeunit "NPR RP Line Print Mgt."; Value: Text; Font: Text[30]; Bold: Boolean; Alignment: Text; CR: Boolean; Underline: Boolean)
    begin
        case true of
            (Font in ['A11', 'B21', 'COMMAND']):
                begin
                    Printer.SetFont(Font);
                    Printer.SetBold(Bold);
                    Printer.SetUnderLine(Underline);

                    case Alignment of
                        'LEFT':
                            Printer.AddTextField(1, 0, Value);
                        'CENTER':
                            Printer.AddTextField(2, 1, Value);
                        'RIGHT':
                            Printer.AddTextField(3, 2, Value);
                    end;
                end;
            (Font in ['CODE128']):
                Printer.AddBarcode(Font, Value, 2, false, 40);
            (Font in ['QR']):
                Printer.AddBarcode(Font, Value, 6, false, 0);
        end;

        if CR then
            Printer.NewLine();
    end;

    local procedure PrintPDF(var TaxFreeRequest: Record "NPR Tax Free Request")
    var
        base64: Text;
        ObjectOutputSelection: Record "NPR Object Output Selection";
        PrintMethodMgt: Codeunit "NPR Print Method Mgt.";
        Output: Text;
        OutputType: Integer;
        ObjectOutputMgt: Codeunit "NPR Object Output Mgt.";
        InStream: InStream;
        OuStream: OutStream;
        Base64Convert: Codeunit "Base64 Convert";
        TempBlob: Codeunit "Temp Blob";
        Xml: XmlDocument;
        XmlNode: XmlNode;
        XmlNodeList: XmlNodeList;
    begin
        Output := ObjectOutputMgt.GetCodeunitOutputPath(CODEUNIT::"NPR Tax Free Receipt");
        OutputType := ObjectOutputMgt.GetCodeunitOutputType(CODEUNIT::"NPR Tax Free Receipt");

        if Output = '' then
            Error(Error_MissingPrintSetup);

        TaxFreeRequest.Print.CreateInStream(InStream, TextEncoding::Utf8);
        XmlDocument.ReadFrom(InStream, Xml);
        XmlNodeList := Xml.GetDescendantElements('FormData');
        if XmlNodeList.Count <> 1 then
            Error(Error_PrintData);

        XmlNodeList.Get(0, XmlNode);
        base64 := XmlNode.AsXmlElement().InnerText; //base64 pdf data

        TempBlob.CreateOutStream(OuStream, TextEncoding::UTF8);
        Base64Convert.FromBase64(base64, OuStream);
        Clear(InStream);
        TempBlob.CreateInStream(InStream, TextEncoding::UTF8);

        case OutputType of
            ObjectOutputSelection."Output Type"::"Printer Name".AsInteger():
                PrintMethodMgt.PrintFileLocal(Output, InStream, 'pdf');
        end;
    end;
}