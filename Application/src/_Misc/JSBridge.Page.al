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
    ObsoleteState = Pending;
    ObsoleteTag = '2023-06-28';
    ObsoleteReason = 'The concept of a generic harder-to-debug JSBridge made sense in C/SIDE where control addins were verbose and very manual. Now, having the actual needed javascript loaded from proper .js files is the simplest, meaning there is no need for the bridge';

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

    internal procedure SetParameters(pFunctionName: Text; pFunctionParameter: Text; pJavaScript: Text)
    begin
        FunctionName := pFunctionName;
        FunctionParameter := pFunctionParameter;
        JavaScript := pJavaScript;
    end;

    internal procedure GetText(): Text
    begin
        exit('');
    end;
}
