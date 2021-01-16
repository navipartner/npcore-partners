page 6014583 "NPR JS Bridge"
{
    UsageCategory = None;
    Caption = 'JS Bridge';
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;

    layout
    {
        area(content)
        {
            usercontrol(JSBridge; "NPR JSBridge")
            {
                ApplicationArea = All;

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
                    //Message(JsonText);
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
