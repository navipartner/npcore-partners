interface "NPR BTF IFormatResponse"
{
    procedure FormatInternalError(ErrorCode: Text; ErrorDescription: Text; var Result: Codeunit "Temp Blob");
    procedure FoundErrorInResponse(Response: Codeunit "Temp Blob"): Boolean;
    procedure GetErrorDescription(Response: Codeunit "Temp Blob"): Text;
    procedure GetToken(Response: Codeunit "Temp Blob"): Text;
    procedure FoundToken(Response: Codeunit "Temp Blob"): Boolean;
    procedure GetFileExtension(): Text;
    procedure GetResourcesUri(Content: Codeunit "Temp Blob"; var ResourcesUri: List of [Text]): Boolean;
    procedure GetDocument(Content: Codeunit "Temp Blob"; var SalesHeader: Record "Sales Header"; var SalesLine: Record "Sales Line"): Boolean;

}