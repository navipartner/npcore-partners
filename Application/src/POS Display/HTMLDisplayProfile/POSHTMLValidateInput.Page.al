page 6150773 "NPR POS HTML Validate Input"
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
                    CurrPage."Input Validation".SendInputDataAndLabel(jsInput, True, Format(MsgApproveInputLabel), Format(MsgRedoInputLabel), Format(MsgPhoneInputLabel), Format(NoInputLabel));
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
        MsgApproveInputLabel: Label 'ACCEPTED', Comment = 'Input ok. label', MaxLength = 100;
        MsgRedoInputLabel: Label 'MAKE AGAIN', Comment = 'Input not ok, try again. label', MaxLength = 100;
        MsgPhoneInputLabel: Label 'Phone number', Comment = 'Phone number label', MaxLength = 100;
        NoInputLabel: Label 'No User Input', Comment = 'No User input label', MaxLength = 100;

}