page 6151222 "NPR PrintNode Printer Settings"
{
    UsageCategory = None;
    PageType = Card;
    Editable = false;
    Caption = 'PrintNode Printer Settings';
    layout
    {
        area(Content)
        {
            group(GroupName)
            {
                field(Tray; Tray)
                {
                    Caption = 'Tray';

                    ToolTip = 'Specifies the value of the Tray field';
                    ApplicationArea = NPRRetail;

                    trigger OnAssistEdit()
                    var
                        Value: Text;
                        Json: Text;
                    begin
                        if LookupValue('bins', Value, Json) then begin
                            Tray := Value;
                            TrayJson := Json;
                        end
                    end;
                }
                field(Color; Color)
                {
                    Caption = 'Color';

                    ToolTip = 'Specifies the value of the Color field';
                    ApplicationArea = NPRRetail;
                    trigger OnAssistEdit()
                    var
                        Value: Text;
                        Json: Text;
                    begin
                        if LookupValue('color', Value, Json) then begin
                            Color := Value;
                            ColorJson := Json;
                        end
                    end;
                }
                field(PageOrientation; PageOrientation)
                {
                    Caption = 'Page Orientation';

                    ToolTip = 'Specifies the value of the Page Orientation field';
                    ApplicationArea = NPRRetail;
                    trigger OnAssistEdit()
                    var
                        Value: Text;
                        Json: Text;
                    begin
                        if LookupValue('rotate', Value, Json) then begin
                            PageOrientation := Value;
                            PageOrientationJson := Json;
                        end
                    end;

                }
                field(Duplex; Duplex)
                {
                    Caption = 'Duplex';

                    ToolTip = 'Specifies the value of the Duplex field';
                    ApplicationArea = NPRRetail;
                    trigger OnAssistEdit()
                    var
                        Value: Text;
                        Json: Text;
                    begin
                        if LookupValue('duplex', Value, Json) then begin
                            Duplex := Value;
                            DuplexJson := Json;
                        end
                    end;

                }
                field(Paper; Paper)
                {
                    Caption = 'Paper';

                    ToolTip = 'Specifies the value of the Paper field';
                    ApplicationArea = NPRRetail;
                    trigger OnAssistEdit()
                    var
                        Value: Text;
                        Json: Text;
                    begin
                        if LookupValue('papers', Value, Json) then begin
                            Paper := Value;
                            PaperJson := Json;
                        end
                    end;

                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(ActionName)
            {

                ToolTip = 'Executes the ActionName action';
                Image = Action;
                ApplicationArea = NPRRetail;

                trigger OnAction()
                begin

                end;
            }
        }
    }


    procedure SetPrinterJson(Json: Text)
    begin
        PrinterJson := Json;
    end;

    procedure GetSettings(): Text;
    var
        SettingsJson: Text;
        SettingsJsonLbl: Label '{%1}', Locked = true;
    begin
        if Tray <> '' then
            SettingsJson += TrayJson + ',';
        if Color <> '' then
            SettingsJson += ColorJson + ',';
        if PageOrientation <> '' then
            SettingsJson += PageOrientationJson + ',';
        if Duplex <> '' then
            SettingsJson += DuplexJson + ',';
        if Paper <> '' then
            SettingsJson += PaperJson + ',';
        if SettingsJson = '' then
            exit('');
        SettingsJson := SettingsJson.TrimEnd(',');
        exit(StrSubstNo(SettingsJsonLbl, SettingsJson));
    end;

    procedure LoadExistingSettings(SettingsJson: Text)
    var
        JObject: JsonObject;
        TextValue: Text;
        BoolValue: Boolean;
        JsonLbl: Label '"bin":"%1"', Locked = true;
        Json2Lbl: Label '"color":%1', Locked = true;
        Json3Lbl: Label '"rotate":%1', Locked = true;
        Json4Lbl: Label '"duplex":"%1"', Locked = true;
        Json5Lbl: Label '"paper":"%1"', Locked = true;
    begin
        if not JObject.ReadFrom(SettingsJson) then
            exit;
        Tray := GetString(JObject, 'bin', false);
        if Tray <> '' then
            TrayJson := StrSubstNo(JsonLbl, Tray);
        TextValue := GetString(JObject, 'color', false);
        if Evaluate(BoolValue, TextValue) then begin
            Color := format(BoolValue);
            ColorJson := StrSubstNo(Json2Lbl, Format(BoolValue, 0, 9));
        end;
        TextValue := GetString(JObject, 'rotate', false);
        if TextValue <> '' then begin
            PageOrientation := RotateValue2Option(TextValue);
            PageOrientationJson := StrSubstNo(Json3Lbl, TextValue);
        end;
        TextValue := GetString(JObject, 'duplex', false);
        if TextValue <> '' then begin
            Duplex := DuplexValue2Option(TextValue);
            DuplexJson := StrSubstNo(Json4Lbl, TextValue);
        end;
        Paper := GetString(JObject, 'paper', false);
        if Paper <> '' then
            PaperJson := StrSubstNo(Json5Lbl, Paper);
    end;

    local procedure LookupValue(Attribute: Text; var OutValue: Text; var OutJson: Text): Boolean
    var
        TempRetailList: Record "NPR Retail List" temporary;
        JsonLbl: Label '"%1":%2', Locked = true;
        Json2Lbl: Label '"%1":"%2"', Locked = true;
    begin
        case Attribute of
            'color':
                GetBooleanOptions(Attribute, TempRetailList);
            'duplex':
                GetDuplexOptions(Attribute, TempRetailList);
            'rotate':
                GetRotateOptions(TempRetailList);
            else
                GetOptionsFromJson(Attribute, TempRetailList);
        end;
        if TempRetailList.IsEmpty then
            exit;
        if page.RunModal(Page::"NPR Retail List", TempRetailList) = Action::LookupOK then begin
            if TempRetailList.Value <> '' then begin
                OutValue := TempRetailList.Choice;
                case Attribute of
                    'color', 'rotate':
                        OutJson := StrSubstNo(JsonLbl, GetJsonName(Attribute), TempRetailList.Value);
                    else
                        OutJson := StrSubstNo(Json2Lbl, GetJsonName(Attribute), TempRetailList.Value);
                end;
            end;
            exit(true);
        end;
        exit(false);
    end;

    local procedure GetBooleanOptions(Attribute: Text; var TempRetailList: Record "NPR Retail List" temporary)
    var
        JObject: JsonObject;
    begin
        TempRetailList.Number := 1;
        TempRetailList.Choice := ClearSettingTxt;
        TempRetailList.Value := '';
        TempRetailList.Insert();

        TempRetailList.Number := 2;
        TempRetailList.Choice := Format(false);
        TempRetailList.Value := Format(false, 0, 9);
        TempRetailList.Insert();
        if JObject.ReadFrom(PrinterJson) then
            if GetBoolean(JObject, Attribute) then begin
                TempRetailList.Number := 3;
                TempRetailList.Choice := Format(true);
                TempRetailList.Value := Format(true, 0, 9);
                TempRetailList.Insert();
            end;

    end;

    local procedure GetDuplexOptions(Attribute: Text; var TempRetailList: Record "NPR Retail List" temporary)
    var
        JObject: JsonObject;
    begin
        if not JObject.ReadFrom(PrinterJson) then
            exit;
        TempRetailList.Number := 1;
        TempRetailList.Choice := SelectStr(1, DuplexOptionTxt);
        TempRetailList.Value := SelectStr(1, DuplexValueText());
        TempRetailList.Insert();
        if GetBoolean(JObject, Attribute) then begin
            TempRetailList.Number := 2;
            TempRetailList.Choice := SelectStr(2, DuplexOptionTxt);
            TempRetailList.Value := SelectStr(2, DuplexValueText());
            TempRetailList.Insert();
            TempRetailList.Number := 3;
            TempRetailList.Choice := SelectStr(3, DuplexOptionTxt);
            TempRetailList.Value := SelectStr(3, DuplexValueText());
            TempRetailList.Insert();
        end;

    end;

    local procedure GetRotateOptions(var TempRetailList: Record "NPR Retail List" temporary)
    begin
        TempRetailList.Number := 1;
        TempRetailList.Choice := SelectStr(1, RotateOptionTxt);
        TempRetailList.Value := SelectStr(1, RotateValueText());
        TempRetailList.Insert();
        TempRetailList.Number := 2;
        TempRetailList.Choice := SelectStr(2, RotateOptionTxt);
        TempRetailList.Value := SelectStr(2, RotateValueText());
        TempRetailList.Insert();
        TempRetailList.Number := 3;
        TempRetailList.Choice := SelectStr(3, RotateOptionTxt);
        TempRetailList.Value := SelectStr(3, RotateValueText());
        TempRetailList.Insert();

    end;

    local procedure GetOptionsFromJson(Attribute: Text; var TempRetailList: Record "NPR Retail List" temporary)
    var
        JObject: JsonObject;
        JToken: JsonToken;
        JArray: JsonArray;
        I: Integer;
        KeyName: Text;
    begin
        if not JObject.ReadFrom(PrinterJson) then
            exit;
        if not JObject.Get(Attribute, JToken) then
            exit;

        TempRetailList.Number := -1;
        TempRetailList.Choice := ClearSettingTxt;
        TempRetailList.Value := '';
        TempRetailList.Insert();
        if JToken.IsArray then begin
            JArray := JToken.AsArray();
            for I := 0 to JArray.Count() - 1 do begin
                JArray.Get(I, JToken);
                TempRetailList.Number := I;
                TempRetailList.Choice := CopyStr(JToken.AsValue().AsText(), 1, MaxStrLen(TempRetailList.Choice));
                TempRetailList.Value := CopyStr(JToken.AsValue().AsText(), 1, MaxStrLen(TempRetailList.Value));
                TempRetailList.Insert();
            end;
        end;
        if JToken.IsObject then begin
            foreach KeyName in JToken.AsObject().Keys do begin
                I += 1;
                TempRetailList.Number := I;
                TempRetailList.Choice := CopyStr(KeyName, 1, MaxStrLen(TempRetailList.Choice));
                TempRetailList.Value := CopyStr(KeyName, 1, MaxStrLen(TempRetailList.Value));
                TempRetailList.Insert();
            end;
        end;
    end;

    local procedure GetJsonName(Attribute: Text): Text
    begin
        case Attribute of
            'bins':
                exit('bin');
            'papers':
                exit('paper');
            else
                exit(Attribute);
        end;
    end;

    local procedure RotateValue2Option(OptionValue: Text): Text
    var
        I: Integer;
    begin
        for I := 1 to 3 do
            if OptionValue = SelectStr(I, RotateValueText()) then
                exit(SelectStr(I, RotateoptionTxt));
    end;

    local procedure DuplexValue2Option(OptionValue: Text): Text
    var
        I: Integer;
    begin
        for I := 1 to 3 do
            if OptionValue = SelectStr(I, DuplexValueText()) then
                exit(SelectStr(I, DuplexOptionTxt));
    end;

    local procedure RotateValueText(): Text
    begin
        exit(',0,90');
    end;

    local procedure DuplexValueText(): Text
    begin
        exit(',long-edge,long-up');
    end;

    local procedure GetToken(JObject: JsonObject; var JToken: JsonToken; TokenKey: Text; WithError: Boolean): Boolean
    var
        JSonString: Text;
        KeyNotFoundTxt: Label 'Property "%1" does not exist in JSON object.\\%2.';
    begin
        if not JObject.Get(TokenKey, JToken) then begin
            if WithError then begin
                JObject.WriteTo(JSonString);
                Error(KeyNotFoundTxt, TokenKey, JSonString);
            end;
            exit(false);
        end;
        exit(true);
    end;

    local procedure GetString(JObject: JsonObject; TokenKey: Text; WithError: Boolean): Text
    var
        JToken: JsonToken;
    begin
        if GetToken(JObject, JToken, TokenKey, WithError) then
            exit(JToken.AsValue().AsText());
        exit('');
    end;

    local procedure GetBoolean(JObject: JsonObject; TokenKey: Text): Boolean
    var
        BoolValue: Boolean;
    begin
        if Evaluate(BoolValue, GetString(JObject, TokenKey, false)) then
            exit(BoolValue);
        exit(false);
    end;



    var
        Tray: Text;
        TrayJson: Text;
        Color: Text;
        ColorJson: Text;
        PageOrientation: Text;
        PageOrientationJson: Text;
        Duplex: Text;
        DuplexJson: Text;
        Paper: Text;
        PaperJson: Text;
        PrinterJson: Text;
        ClearSettingTxt: Label 'Clear Setting';
        DuplexOptionTxt: Label 'Clear Setting,Yes- Flip over,Yes - Flip up';
        RotateoptionTxt: Label 'Clear Setting,Portrait,Landscape';
}
