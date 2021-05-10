interface "NPR BTF IFormatResponse"
{
    procedure FormatInternalError(ErrorCode: Text; ErrorDescription: Text; var Result: Codeunit "Temp Blob");
    procedure FoundErrorInResponse(Response: Codeunit "Temp Blob"; StatusCode: Integer): Boolean;
    procedure GetErrorDescription(Response: Codeunit "Temp Blob"): Text;
    procedure GetToken(Response: Codeunit "Temp Blob"): Text;
    procedure FoundToken(Response: Codeunit "Temp Blob"): Boolean;
    procedure GetFileExtension(): Text;
    procedure GetOrder(Content: Codeunit "Temp Blob"; var SalesHeader: Record "Sales Header"; var SalesLine: Record "Sales Line"): Boolean;
    procedure GetInvoice(Content: Codeunit "Temp Blob"; var SalesHeader: Record "Sales Header"; var SalesLine: Record "Sales Line"): Boolean;
    procedure GetOrderResp(Content: Codeunit "Temp Blob"; var SalesHeader: Record "Sales Header"; var SalesLine: Record "Sales Line"): Boolean;
    procedure GetPriceCat(Content: Codeunit "Temp Blob"; var ItemWrks: Record "NPR Item Worksheet"; var ItemWrksLine: Record "NPR Item Worksheet Line"): Boolean;
}