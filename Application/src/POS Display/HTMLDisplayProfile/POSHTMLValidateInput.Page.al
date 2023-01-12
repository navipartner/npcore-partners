page 6059906 "NPR POS HTML Validate Input"
{
    Extensible = False;
    PageType = Card;
    UsageCategory = None;
    Editable = false;
    DeleteAllowed = false;
    InsertAllowed = false;
    Caption = 'Input Validation';



    layout
    {
        area(Content)
        {

            usercontrol("Input Validation"; "NPR HTML Display Input")
            {
                ApplicationArea = NPRRetail;

                trigger Ready()
                begin
                    CurrPage."Input Validation".SendInputData(jsInput, True);
                end;

                trigger OkInput()
                begin
                    Result := 'OK';
                    CurrPage.Close();
                end;

                trigger RedoInput()
                begin
                    Result := 'REDO';
                    CurrPage.Close();
                end;
            }
        }

    }
    procedure ValidateInput(input: JsonObject): Text
    var
        action: Action;
    begin
        jsInput := input;
        action := CurrPage.RunModal();
        if ((Result <> 'OK') and (Result <> 'REDO')) then
            Result := 'CANCEL';
        exit(Result);
    end;

    var
        jsInput: JsonObject;
        Result: Text;

}