page 6014583 "JS Bridge"
{
    // NPR5.29/CLVA/20161018 CASE 251922 Page created.

    Caption = 'JS Bridge';
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;

    layout
    {
        area(content)
        {
            usercontrol(JSBridge;"NaviPartner.POS.JSBridge")
            {

                trigger ControlAddInReady()
                begin
                    if FunctionName <> '' then
                      CurrPage.JSBridge.CallNativeFunction(FunctionParameter)
                    else if JavaScript <> '' then
                      CurrPage.JSBridge.InjectJavaScript(JavaScript);
                end;

                trigger ActionCompleted(jsonObject: Text)
                begin
                    //MESSAGE(jsonObject);
                    CurrPage.Close;
                end;
            }
        }
    }

    actions
    {
    }

    var
        FunctionName: Text;
        FunctionParameter: Text;
        JavaScript: Text;

    procedure SetParameters(pFunctionName: Text;pFunctionParameter: Text;pJavaScript: Text)
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

