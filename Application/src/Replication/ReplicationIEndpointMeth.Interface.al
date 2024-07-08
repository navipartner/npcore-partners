interface "NPR Replication IEndpoint Meth"
{
#IF NOT BC17 
    Access = Internal;      
#ENDIF
    procedure SendRequest(ServiceSetup: Record "NPR Replication Service Setup"; ServiceEndPoint: Record "NPR Replication Endpoint"; var Client: HttpClient; var Response: Codeunit "Temp Blob"; var StatusCode: integer; var Method: code[10]; var URI: Text; var NextLinkURI: Text);
    procedure GetDefaultFileName(ServiceEndPoint: Record "NPR Replication Endpoint"): Text[100];
    procedure ProcessImportedContent(Content: Codeunit "Temp Blob"; ServiceEndPoint: Record "NPR Replication Endpoint"): Boolean;
    procedure CheckResponseContainsData(Content: Codeunit "Temp Blob"): Boolean;
}
