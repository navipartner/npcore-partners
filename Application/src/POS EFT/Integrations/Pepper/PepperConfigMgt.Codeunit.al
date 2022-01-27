codeunit 6184490 "NPR Pepper Config. Mgt."
{
    Access = Internal;
    procedure GetConfigurationText(PepperConfiguration: Record "NPR Pepper Config."; TextType: Option License,Configuration,AdditionalParameters): Text
    var
        PepperVersion: Record "NPR Pepper Version";
        TempBlob: Codeunit "Temp Blob";
        StreamOut: OutStream;
        StreamIn: InStream;
        TextWhole: Text;
        TextLine: Text[1024];
    begin
        TextWhole := '';
        case TextType of
            TextType::License:
                begin
                    PepperConfiguration.CalcFields("License File");
                    if not PepperConfiguration."License File".HasValue() then
                        exit('');
                    PepperConfiguration."License File".CreateInStream(StreamIn, TEXTENCODING::UTF8);
                end;
            TextType::Configuration:
                begin
                    PepperConfiguration.TestField(Version);
                    PepperVersion.Get(PepperConfiguration.Version);
                    PepperVersion.TestField(PepperVersion."XMLport Configuration");
                    TempBlob.CreateOutStream(StreamOut, TextEncoding::UTF8);
                    XMLPORT.Export(PepperVersion."XMLport Configuration", StreamOut);
                    TempBlob.CreateInStream(StreamIn, TextEncoding::UTF8);
                end;
            TextType::AdditionalParameters:
                begin
                    PepperConfiguration.CalcFields("Additional Parameters");
                    if not PepperConfiguration."Additional Parameters".HasValue() then
                        exit('');
                    PepperConfiguration."Additional Parameters".CreateInStream(StreamIn, TEXTENCODING::UTF8);
                end;
        end;
        repeat
            StreamIn.Read(TextLine);
            TextWhole := TextWhole + TextLine;
        until StreamIn.EOS;
        exit(TextWhole);
    end;

    procedure GetTerminalText(PepperTerminal: Record "NPR Pepper Terminal"; TextType: Option License,AdditionalParameters): Text
    var
        PepperConfiguration: Record "NPR Pepper Config.";
        PepperInstance: Record "NPR Pepper Instance";
        StreamIn: InStream;
        TextWhole: Text;
        TextLine: Text[1024];
    begin
        TextWhole := '';
        case TextType of
            TextType::AdditionalParameters:
                begin
                    PepperTerminal.CalcFields("Additional Parameters File");
                    if not PepperTerminal."Additional Parameters File".HasValue() then begin
                        if PepperInstance.Get(PepperTerminal."Instance ID") then begin
                            if PepperConfiguration.Get(PepperInstance."Configuration Code") then begin
                                PepperConfiguration.CalcFields("Additional Parameters");
                                if PepperConfiguration."Additional Parameters".HasValue() then begin
                                    PepperConfiguration."Additional Parameters".CreateInStream(StreamIn, TEXTENCODING::UTF8);
                                end else
                                    exit('');
                            end else
                                exit('');
                        end else
                            exit('');
                    end else begin
                        PepperTerminal."Additional Parameters File".CreateInStream(StreamIn, TEXTENCODING::UTF8);
                    end;
                end;
            TextType::License:
                begin
                    PepperTerminal.CalcFields("License File");
                    if not PepperTerminal."License File".HasValue() then begin
                        if PepperInstance.Get(PepperTerminal."Instance ID") then begin
                            if PepperConfiguration.Get(PepperInstance."Configuration Code") then begin
                                PepperConfiguration.CalcFields("License File");
                                if PepperConfiguration."License File".HasValue() then begin
                                    PepperConfiguration."License File".CreateInStream(StreamIn, TEXTENCODING::UTF8);
                                end else
                                    exit('');
                            end else
                                exit('');
                        end else
                            exit('');
                    end else begin
                        PepperTerminal."License File".CreateInStream(StreamIn, TEXTENCODING::UTF8);
                    end;
                end;
        end;

        repeat
            StreamIn.Read(TextLine);
            TextWhole := TextWhole + TextLine;
        until StreamIn.EOS;
        exit(TextWhole);
    end;

    procedure GetZipFileAsText(PepperVersion: Record "NPR Pepper Version"): Text
    var
        StreamIn: InStream;
        TextWhole: Text;
        TextLine: Text[1024];
    begin
        TextWhole := '';
        PepperVersion.CalcFields("Install Zip File");
        if not PepperVersion."Install Zip File".HasValue() then
            exit('');
        PepperVersion."Install Zip File".CreateInStream(StreamIn, TEXTENCODING::UTF8);
        repeat
            StreamIn.Read(TextLine);
            TextWhole := TextWhole + TextLine;
        until StreamIn.EOS;
        exit(TextWhole);
    end;

    procedure GetPepperRegisterNo(RegisterNo: Code[10]): Integer
    var
        POSUnit: Record "NPR POS Unit";
        I: Integer;
    begin
        if not Evaluate(I, RegisterNo) then begin
            I := 0;
            if POSUnit.FindSet() then
                repeat
                    I := I + 1;
                    if POSUnit."No." = RegisterNo then
                        exit(I);
                until POSUnit.Next() = 0;
        end else
            exit(I);
    end;

    procedure GetHeaderFooterText(POSUnit: Record "NPR POS Unit"; PrintType: Option Transaction,"Transaction CC",Administration; TextType: Option Header,Footer): Text
    var
        Utility: Codeunit "NPR Receipt Footer Mgt.";
        TextToPrint: Text;
    begin
        TextToPrint := '';
        case PrintType of
            PrintType::Transaction,
            PrintType::"Transaction CC",
            PrintType::Administration:
                case TextType of
                    TextType::Header:
                        begin
                            Utility.GetSalesTicketReceiptText(TextToPrint, POSUnit);
                        end;
                    TextType::Footer:
                        begin
                        end;
                end;
        end;
        exit(TextToPrint);
    end;

    procedure GetReceiptText(PepperTransactionRequest: Record "NPR EFT Transaction Request"; ReceiptNo: Integer; AddBackSlash: Boolean): Text
    var
        PepperTerminal: Record "NPR Pepper Terminal";
        StreamIn: InStream;
        TextWhole: Text;
        TextLine: Text[1024];
        Separator: Char;
        TextDot: Label '______________________________';
        TextSig: Label 'Customer Signature';
    begin
        if AddBackSlash then
            Separator := '\'
        else
            Separator := 10;
        TextWhole := '';

        case ReceiptNo of
            1:
                begin
                    PepperTransactionRequest.CalcFields("Receipt 1");
                    if not PepperTransactionRequest."Receipt 1".HasValue() then
                        exit('');
                    PepperTransactionRequest."Receipt 1".CreateInStream(StreamIn);
                end;
            2:
                begin
                    PepperTransactionRequest.CalcFields("Receipt 2");
                    if not PepperTransactionRequest."Receipt 2".HasValue() then
                        exit('');
                    PepperTransactionRequest."Receipt 2".CreateInStream(StreamIn);
                end;
        end;

        repeat
            StreamIn.Read(TextLine);
            if TextWhole = '' then
                TextWhole := TextLine
            else
                TextWhole := TextWhole + Format(Separator) + TextLine
        until StreamIn.EOS;
        //-Add signature line
        if (PepperTransactionRequest."Authentication Method" = PepperTransactionRequest."Authentication Method"::Signature)
           and (ReceiptNo = 2) then begin
            PepperTerminal.Get(PepperTransactionRequest."Pepper Terminal Code");
            if PepperTerminal."Add Customer Signature Space" then begin
                TextWhole := TextWhole + Format(Separator) + Format(Separator) + Format(Separator) + Format(Separator)
                             + TextDot + Format(Separator) + TextSig + Format(Separator) + Format(Separator);
            end;
        end;
        //+Add signature line

        exit(TextWhole);
    end;

    procedure GetCustomerID(PepperTerminal: Record "NPR Pepper Terminal"): Text[8]
    var
        PepperInstance: Record "NPR Pepper Instance";
        PepperConfiguration: Record "NPR Pepper Config.";
    begin
        if PepperTerminal."Customer ID" <> '' then
            exit(PepperTerminal."Customer ID");
        if PepperInstance.Get(PepperTerminal."Instance ID") then
            if PepperConfiguration.Get(PepperInstance."Configuration Code") then
                exit(PepperConfiguration."Customer ID");
    end;

    procedure GetLicenseID(PepperTerminal: Record "NPR Pepper Terminal"): Text[8]
    var
        PepperInstance: Record "NPR Pepper Instance";
        PepperConfiguration: Record "NPR Pepper Config.";
    begin
        if PepperTerminal."License ID" <> '' then
            exit(PepperTerminal."License ID");
        if PepperInstance.Get(PepperTerminal."Instance ID") then
            if PepperConfiguration.Get(PepperInstance."Configuration Code") then
                exit(PepperConfiguration."License ID");
    end;
}

