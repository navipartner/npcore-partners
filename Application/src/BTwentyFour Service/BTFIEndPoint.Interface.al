interface "NPR BTF IEndPoint"
{
    #IF NOT BC17 
    Access = Internal;      
    #ENDIF
    procedure SendRequest(ServiceSetup: Record "NPR BTF Service Setup"; ServiceEndPoint: Record "NPR BTF Service EndPoint"; Request: Codeunit "Temp Blob"; var Response: Codeunit "Temp Blob"; var StatusCode: Integer);
    procedure GetDefaultFileName(ServiceEndPoint: Record "NPR BTF Service EndPoint"): Text;
    procedure ProcessImportedContent(Content: Codeunit "Temp Blob"; ServiceEndPoint: Record "NPR BTF Service EndPoint"): Boolean;
    procedure ProcessImportedContentOffline(Content: Codeunit "Temp Blob"; ServiceEndPoint: Record "NPR BTF Service EndPoint");
    procedure GetImportListUpdateHandler(): Enum "NPR Nc IL Update Handler";

}
