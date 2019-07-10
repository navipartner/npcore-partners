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
            // AL-Conversion: TODO #361608 - AL: Problems with NaviPartner.POS.JSBridge addin.
        }
    }

    actions
    {
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

