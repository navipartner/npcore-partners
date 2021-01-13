interface "NPR BTF IEndPoint"
{
    procedure SendRequest(ServiceSetup: Record "NPR BTF Service Setup"; ServiceEndPoint: Record "NPR BTF Service EndPoint"; var Response: Codeunit "Temp Blob");
    procedure GetDefaultFileName(ServiceEndPoint: Record "NPR BTF Service EndPoint"): Text;
    procedure ProcessImportedContent(Content: Codeunit "Temp Blob"; ServiceEndPoint: Record "NPR BTF Service EndPoint");

}