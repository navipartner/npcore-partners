codeunit 6060103 "NPR POS Dragonglass Run Method"
{
    Access = Internal;

    var
        _Method: Text;
        _Parameters: JsonObject;

    trigger OnRun()
    var
        POSJavaScriptInterface: Codeunit "NPR POS JavaScript Interface";
    begin
        POSJavascriptInterface.InvokeMethod(_Method, _Parameters, POSJavascriptInterface);
    end;

    procedure SetMethodParameters(Method: Text; Parameters: JsonObject)
    begin
        _Method := Method;
        _Parameters := Parameters;
    end;

}