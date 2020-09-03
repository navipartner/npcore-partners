codeunit 6060159 "NPR Event Vers. Specific Mgt."
{
    // NPR5.35/TJ  /20170803 CASE 285826 New object - stores all .NET assemblies and their methods that are specific to NAV2016


    trigger OnRun()
    begin
    end;

    var
        [RunOnClient]
        WordHelper: DotNet NPRNetWordHelper;
        [RunOnClient]
        WordHandler: DotNet NPRNetWordHandler;
        WordXMLMerger: DotNet NPRNetWordReportManager;
        PdfWriter: DotNet NPRNetWordToPdf;
        ExchServiceWrapper: DotNet NPRNetExchangeServiceWrapper;

    procedure WordHelperGetApplication(var WordApplication: DotNet NPRNetApplicationClass; var ErrorMessage: Text)
    begin
        WordApplication := WordHelper.GetApplication(ErrorMessage);
    end;

    procedure WordHelperCallOpen(WordApplication: DotNet NPRNetApplicationClass; FileName: Text; ConfirmConversions: Boolean; OpenReadOnly: Boolean; var WordDocument: DotNet NPRNetDocument)
    begin
        WordDocument := WordHelper.CallOpen(WordApplication, FileName, ConfirmConversions, OpenReadOnly);
    end;

    procedure WordHandlerConstructor()
    begin
        Clear(WordHandler);
        WordHandler := WordHandler.WordHandler;
    end;

    procedure WordHandlerWaitForDocument(WordDocument: DotNet NPRNetDocument) NewFileName: Text
    begin
        NewFileName := WordHandler.WaitForDocument(WordDocument);
        exit(NewFileName);
    end;

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

    procedure ExchServiceWrapperGetExchangeServiceUrl() Url: Text
    begin
        Url := ExchServiceWrapper.ExchangeServiceUrl;
        exit(Url);
    end;

    procedure ExchServiceWrapperAutodiscoverServiceUrl(AutodiscoverEmailAddress: Text): Boolean
    begin
        exit(ExchServiceWrapper.AutodiscoverServiceUrl(AutodiscoverEmailAddress));
    end;

    procedure ExchServiceWrapperService(var ExchService: DotNet NPRNetExchangeService)
    begin
        ExchService := ExchServiceWrapper.Service();
    end;
}

