codeunit 6060159 "NPR Event Vers. Specific Mgt."
{
    var
        WordXMLMerger: DotNet NPRNetWordReportManager;
        PdfWriter: DotNet NPRNetWordToPdf;
        ExchServiceWrapper: DotNet NPRNetExchangeServiceWrapper;

    procedure WordXMLMergerConstructor()
    begin
        Clear(WordXMLMerger);
        WordXMLMerger := WordXMLMerger.WordReportManager;
    end;

    procedure WordXMLMergerValidateWordDocumentTemplate(DocumentStream: InStream; NewXMLPart: Text) ValidationErrors: Text
    begin
        ValidationErrors := WordXMLMerger.ValidateWordDocumentTemplate(DocumentStream, NewXMLPart);
        exit(ValidationErrors);
    end;

    procedure WordXMLMergerMergeWordDocument(WordDocument: InStream; XmlData: InStream; OutputStream: OutStream; var WordDoc: OutStream)
    begin
        WordDoc := WordXMLMerger.MergeWordDocument(WordDocument, XmlData, OutputStream);
    end;

    procedure PdfWriterConvertToPdf(WordStream: InStream; var PdfStream: OutStream)
    begin
        PdfWriter.ConvertToPdf(WordStream, PdfStream);
    end;

    procedure ExchServiceWrapperConstructor(Username: Text; Password: Text)
    var
        ExchangeCredentials: DotNet NPRNetExchangeCredentials;
        NetworkCredential: DotNet NPRNetNetworkCredential;
        ExchangeVersion: DotNet NPRNetExchangeVersion;
    begin
        ExchServiceWrapper := ExchServiceWrapper.ExchangeServiceWrapper(
                                ExchangeCredentials.op_Implicit(
                                  NetworkCredential.NetworkCredential(Username, Password)), ExchangeVersion.Exchange2013);
    end;

    procedure ExchServiceWrapperService(var ExchService: DotNet NPRNetExchangeService)
    begin
        ExchService := ExchServiceWrapper.Service();
    end;
}

