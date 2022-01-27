page 6014583 "NPR JS Bridge"
{
    Extensible = False;
    Caption = 'JS Bridge';
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    UsageCategory = Administration;
    ApplicationArea = NPRRetail;

    layout
    {
        area(content)
        {
            usercontrol(JSBridge; "NPR JSBridge")
            {
                ApplicationArea = NPRRetail;


                trigger ControlAddInReady();
                begin
                    if FunctionName <> '' then
                        CurrPage.JSBridge.CallNativeFunction(FunctionParameter)
                    else
                        if JavaScript <> '' then
                            CurrPage.JSBridge.InjectJavaScript(JavaScript);
                end;

                trigger ActionCompleted(JsonText: Text);
                begin
                    CurrPage.Close();
                end;
            }
        }
    }

    var
        FunctionName: Text;
        FunctionParameter: Text;
        JavaScript: Text;

    procedure SetParameters(pFunctionName: Text; pFunctionParameter: Text; pJavaScript: Text)
    begin
        FunctionName := pFunctionName;
        FunctionParameter := pFunctionParameter;
        JavaScript := pJavaScript;
    end;

    procedure GetText(): Text
    begin
        exit('');
    end;
}
