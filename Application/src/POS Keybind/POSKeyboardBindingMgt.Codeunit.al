codeunit 6150744 "NPR POS Keyboard Binding Mgt."
{
    var
        SameKeyCodeErr: Label 'Can''t have same %1 for different %2. %1 %3 is already used on %2 %4.';
        RestoreDefaultKeybindConfirm: Label 'This will restore default keybind. Do you want to continue?';
        EmptyKeybindErr: Label '%1 can''t be empty.';
        NoSuchKeyBindErr: Label 'Keybind %1 isn''t supported.';
        ProcessNotSupportedErr: Label 'This process is no longer supported.';
        ReadingErr: Label 'reading in %1';

    local procedure MethodName(): Text
    begin
        exit('KeyPress');
    end;

    procedure DiscoverKeyboardBindings(var KeyboardBindings: List of [Text])
    var
        POSKeyboardBindingSetupTemp: Record "NPR POS Keyboard Bind. Setup" temporary;
    begin
        OnDiscoverKeyboardBindings(POSKeyboardBindingSetupTemp);
        BuildSupportedKeys();
        CheckNoMultipleKeyCodes(POSKeyboardBindingSetupTemp);
        CreateSetup(POSKeyboardBindingSetupTemp);
        BuildKeyCollection(KeyboardBindings);
    end;

    procedure CheckNoMultipleKeyCodes(var POSKeyboardBindingSetup: Record "NPR POS Keyboard Bind. Setup")
    var
        OnDiscoveryCheck: Boolean;
        POSKeyboardBindingSetup2: Record "NPR POS Keyboard Bind. Setup";
        POSKeyboardBindingSetupTemp: Record "NPR POS Keyboard Bind. Setup" temporary;
        POSKeyboardBindingSetupTemp2: Record "NPR POS Keyboard Bind. Setup" temporary;
    begin
        OnDiscoveryCheck := POSKeyboardBindingSetup.IsTemporary;
        if OnDiscoveryCheck then begin
            //we need a list that has all the records from discovered keybinds and also those from live setup
            if POSKeyboardBindingSetup2.FindSet() then
                repeat
                    if not POSKeyboardBindingSetup.Get(POSKeyboardBindingSetup2."Action Code") then begin
                        POSKeyboardBindingSetup := POSKeyboardBindingSetup2;
                        POSKeyboardBindingSetup.Enabled := false;
                        POSKeyboardBindingSetup.Insert();
                    end else begin
                        POSKeyboardBindingSetup."Key Bind" := POSKeyboardBindingSetup2."Key Bind";
                        POSKeyboardBindingSetup.Enabled := POSKeyboardBindingSetup2.Enabled;
                        POSKeyboardBindingSetup.Modify();
                    end;
                until POSKeyboardBindingSetup2.Next() = 0;
            CheckKeyBind(POSKeyboardBindingSetup, OnDiscoveryCheck);
            POSKeyboardBindingSetupTemp.Copy(POSKeyboardBindingSetup, true);

            if POSKeyboardBindingSetup.FindSet() then
                repeat
                    if POSKeyboardBindingSetup.Enabled then begin
                        POSKeyboardBindingSetupTemp.SetRange("Default Key Bind", POSKeyboardBindingSetup."Default Key Bind");
                        POSKeyboardBindingSetupTemp.SetRange(Enabled, true);
                        if POSKeyboardBindingSetupTemp.Count() > 1 then begin
                            POSKeyboardBindingSetup.Enabled := false;
                            POSKeyboardBindingSetup.Modify();
                        end;
                        POSKeyboardBindingSetupTemp.SetRange("Default Key Bind");
                        POSKeyboardBindingSetupTemp.SetRange("Key Bind", POSKeyboardBindingSetup."Key Bind");
                        if POSKeyboardBindingSetupTemp.Count() > 1 then begin
                            POSKeyboardBindingSetupTemp.FindSet();
                            repeat
                                if not POSKeyboardBindingSetupTemp2.Get(POSKeyboardBindingSetupTemp."Action Code") then begin
                                    POSKeyboardBindingSetupTemp2 := POSKeyboardBindingSetupTemp;
                                    POSKeyboardBindingSetupTemp2.Insert();
                                end;
                            until POSKeyboardBindingSetupTemp.Next() = 0;
                        end;
                        POSKeyboardBindingSetupTemp.SetRange("Key Bind");
                        POSKeyboardBindingSetupTemp.SetRange(Enabled);

                        if POSKeyboardBindingSetupTemp2.Get(POSKeyboardBindingSetup."Action Code") then begin
                            POSKeyboardBindingSetup.Enabled := false;
                            POSKeyboardBindingSetup.Modify();
                        end;
                    end;
                until POSKeyboardBindingSetup.Next() = 0;
        end else begin
            //need to check if process is still supported
            OnDiscoverKeyboardBindings(POSKeyboardBindingSetupTemp);
            if not POSKeyboardBindingSetupTemp.Get(POSKeyboardBindingSetup."Action Code") then
                Error(ProcessNotSupportedErr);
            //if yes, continue with multiple key bind check
            POSKeyboardBindingSetup2.SetRange("Key Bind", POSKeyboardBindingSetup."Key Bind");
            POSKeyboardBindingSetup2.SetRange(Enabled, true);
            POSKeyboardBindingSetup2.SetFilter("Action Code", '<>%1', POSKeyboardBindingSetup."Action Code");
            if POSKeyboardBindingSetup2.FindFirst() then
                Error(SameKeyCodeErr, POSKeyboardBindingSetup2.FieldCaption("Key Bind"), POSKeyboardBindingSetup2.FieldCaption("Action Code"),
                  POSKeyboardBindingSetup2."Key Bind", POSKeyboardBindingSetup2."Action Code");
        end;
    end;

    procedure KeyboardBindingEnabled(ActionCode: Code[20]; KeyPressed: Text; DefaultKeyCode: Text): Boolean
    var
        POSKeyboardBindingSetup: Record "NPR POS Keyboard Bind. Setup";
    begin
        POSKeyboardBindingSetup.SetRange("Action Code", ActionCode);
        POSKeyboardBindingSetup.SetRange("Key Bind", KeyPressed);
        POSKeyboardBindingSetup.SetRange("Default Key Bind", DefaultKeyCode);
        POSKeyboardBindingSetup.SetRange(Enabled, true);
        exit(not POSKeyboardBindingSetup.IsEmpty());
    end;

    local procedure CreateSetup(var POSKeyboardBindingSetup: Record "NPR POS Keyboard Bind. Setup")
    var
        POSKeyboardBindingSetup2: Record "NPR POS Keyboard Bind. Setup";
    begin
        if POSKeyboardBindingSetup.FindSet() then
            repeat
                POSKeyboardBindingSetup2 := POSKeyboardBindingSetup;
                if not POSKeyboardBindingSetup2.Insert() then
                    POSKeyboardBindingSetup2.Modify();
            until POSKeyboardBindingSetup.Next() = 0;
    end;

    local procedure BuildKeyCollection(var KeyboardBindings: List of [Text])
    var
        POSKeyboardBindingSetup: Record "NPR POS Keyboard Bind. Setup";
    begin
        if POSKeyboardBindingSetup.FindSet() then
            repeat
                KeyboardBindings.Add(POSKeyboardBindingSetup."Key Bind");
            until POSKeyboardBindingSetup.Next() = 0;
    end;

    procedure RestoreDefaultKeyBind(var Rec: Record "NPR POS Keyboard Bind. Setup")
    var
        POSKeyboardBindingSetup: Record "NPR POS Keyboard Bind. Setup";
    begin
        if not Confirm(RestoreDefaultKeybindConfirm) then
            exit;
        POSKeyboardBindingSetup.Copy(Rec);
        POSKeyboardBindingSetup.SetRecFilter();
        POSKeyboardBindingSetup.Validate("Key Bind", POSKeyboardBindingSetup."Default Key Bind");
        POSKeyboardBindingSetup.Modify();
        Rec := POSKeyboardBindingSetup;
    end;

    local procedure BuildSupportedKeys()
    var
        AvailablePOSKeybindTemp: Record "NPR Available POS Keybind" temporary;
        AvailablePOSKeybind: Record "NPR Available POS Keybind";
        EntryNo: Integer;
        DigitCount: Integer;
        Letter: Char;
        ListData: Text;
        TextList: List of [Text];
    begin
        TextList.AddRange('Escape', 'Win', 'Ctrl', 'Shift', 'Alt');

        Letter := 'A';
        repeat
            AddKey(AvailablePOSKeybindTemp, EntryNo, Letter, 0, true);
            Letter += 1;
        until Letter = 'Z';
        AddKey(AvailablePOSKeybindTemp, EntryNo, Letter, 0, true);

        DigitCount := 0;
        while DigitCount < 13 do begin
            if DigitCount < 10 then
                AddKey(AvailablePOSKeybindTemp, EntryNo, Format(DigitCount), 0, true);
            if DigitCount > 0 then
                AddKey(AvailablePOSKeybindTemp, EntryNo, ('F' + Format(DigitCount)), 0, true);
            DigitCount += 1;
        end;

        foreach ListData in TextList do
            AddKey(AvailablePOSKeybindTemp, EntryNo, ListData, (TextList.IndexOf(ListData) - 1), true);

        EntryNo := 0;
        if AvailablePOSKeybind.FindSet() then
            repeat
                AvailablePOSKeybindTemp.SetRange("Key Name", AvailablePOSKeybind."Key Name");
                if AvailablePOSKeybindTemp.FindFirst() then begin
                    AvailablePOSKeybind.Supported := true;
                    AvailablePOSKeybind."Modifier Key Priority" := AvailablePOSKeybindTemp."Modifier Key Priority";
                    AvailablePOSKeybindTemp.Delete();
                end else
                    AvailablePOSKeybind.Supported := false;
                AvailablePOSKeybind.Modify();
                EntryNo := AvailablePOSKeybind."Entry No.";
            until AvailablePOSKeybind.Next() = 0;

        AvailablePOSKeybindTemp.Reset();
        if AvailablePOSKeybindTemp.FindSet() then
            repeat
                EntryNo += 1;
                AvailablePOSKeybind.Init();
                AvailablePOSKeybind := AvailablePOSKeybindTemp;
                AvailablePOSKeybind."Entry No." := EntryNo;
                AvailablePOSKeybind.Insert();
            until AvailablePOSKeybindTemp.Next() = 0;
    end;

    local procedure AddKey(var AvailablePOSKeybind: Record "NPR Available POS Keybind"; var EntryNo: Integer; KeyName: Text[30]; ModifierKeyPriority: Integer; Supported: Boolean)
    begin
        EntryNo += 1;
        AvailablePOSKeybind.Init();
        AvailablePOSKeybind."Entry No." := EntryNo;
        AvailablePOSKeybind."Key Name" := KeyName;
        AvailablePOSKeybind."Modifier Key Priority" := ModifierKeyPriority;
        AvailablePOSKeybind.Supported := Supported;
        AvailablePOSKeybind.Insert();
    end;

    procedure CheckKeyBind(var Rec: Record "NPR POS Keyboard Bind. Setup"; OnDiscoveryCheck: Boolean)
    var
        KeyBindArr: array[2] of Text;
        AvailablePOSKeybind: Record "NPR Available POS Keybind";
        ApproveKeybind: Boolean;
        ApproveKeybindArr: array[2] of Boolean;
        IsEnabled: Boolean;
        ErrMessage: Text;
        i: Integer;
        KeyBindCaptionArr: array[2] of Text;
        IncomingFilters: Record "NPR POS Keyboard Bind. Setup";
    begin
        KeyBindCaptionArr[1] := Rec.FieldCaption("Key Bind");
        KeyBindCaptionArr[2] := Rec.FieldCaption("Default Key Bind");
        if not OnDiscoveryCheck then begin
            IncomingFilters.CopyFilters(Rec);
            Rec.SetRecFilter();
            IsEnabled := Rec.Enabled;
            KeyBindArr[1] := Rec."Key Bind";
            KeyBindArr[2] := Rec."Default Key Bind";
        end;

        if Rec.FindSet() then
            repeat
                if OnDiscoveryCheck then begin
                    IsEnabled := true;
                    KeyBindArr[1] := Rec."Key Bind";
                    KeyBindArr[2] := Rec."Default Key Bind";
                end;
                if IsEnabled then begin
                    for i := 1 to 2 do begin
                        if KeyBindArr[i] = '' then begin
                            if OnDiscoveryCheck then
                                ApproveKeybindArr[i] := false
                            else
                                Error(EmptyKeybindErr, KeyBindCaptionArr[i]);
                        end else begin
                            KeyBindArr[i] := DelChr(DelChr(KeyBindArr[i], '=', ' '), '<>', '+');
                            if StrPos(KeyBindArr[i], '+') = 0 then begin
                                ApproveKeybindArr[i] := GetSupportedKeyBind(KeyBindArr[i], AvailablePOSKeybind, ErrMessage);
                                KeyBindArr[i] := AvailablePOSKeybind."Key Name";
                            end else
                                ApproveKeybindArr[i] := RestructureKeyBind(KeyBindArr[i], ErrMessage);
                            if (not ApproveKeybindArr[1]) and (not OnDiscoveryCheck) then //only key bind field is valid for enabling record
                                Error(ErrMessage);
                        end;
                    end;
                    if ApproveKeybindArr[1] then
                        Rec."Key Bind" := KeyBindArr[1];
                    if ApproveKeybindArr[2] then
                        Rec."Default Key Bind" := KeyBindArr[2];
                    ApproveKeybind := ApproveKeybindArr[1]; //only key bind field is valid for enabling record
                    if OnDiscoveryCheck and (not ApproveKeybind) then begin
                        Rec.Enabled := false;
                        Rec.Modify();
                    end;
                end;
            until Rec.Next() = 0;

        if not OnDiscoveryCheck then begin
            if IsEnabled then
                CheckNoMultipleKeyCodes(Rec);
            Rec.Reset();
            Rec.CopyFilters(IncomingFilters);
            Rec.Enabled := IsEnabled;
        end;
    end;

    local procedure GetSupportedKeyBind(KeyBind: Text; var AvailablePOSKeybind: Record "NPR Available POS Keybind"; var ErrMessage: Text): Boolean
    var
        KeyBindLbl: Label '@%1', Locked = true;
    begin
        ErrMessage := '';
        AvailablePOSKeybind.SetFilter("Key Name", StrSubstNo(KeyBindLbl, KeyBind));
        if (not AvailablePOSKeybind.FindFirst()) or (not AvailablePOSKeybind.Supported) then begin
            ErrMessage := StrSubstNo(NoSuchKeyBindErr, KeyBind);
            exit(false);
        end;
        exit(true);
    end;

    local procedure RestructureKeyBind(var KeyBind: Text; var ErrMessage: Text): Boolean
    var
        AvailablePOSKeybindTemp: Record "NPR Available POS Keybind" temporary;
        EntryNo: Integer;
        AvailablePOSKeybind: Record "NPR Available POS Keybind";
    begin
        ErrMessage := '';
        while StrPos(KeyBind, '+') > 0 do begin
            if not GetSupportedKeyBind(CopyStr(KeyBind, 1, StrPos(KeyBind, '+') - 1), AvailablePOSKeybind, ErrMessage) then
                exit(false);
            AddKey(AvailablePOSKeybindTemp, EntryNo, AvailablePOSKeybind."Key Name", AvailablePOSKeybind."Modifier Key Priority", true);
            KeyBind := CopyStr(KeyBind, StrPos(KeyBind, '+') + 1);
        end;
        if not GetSupportedKeyBind(KeyBind, AvailablePOSKeybind, ErrMessage) then
            exit(false);
        AddKey(AvailablePOSKeybindTemp, EntryNo, AvailablePOSKeybind."Key Name", AvailablePOSKeybind."Modifier Key Priority", true);
        KeyBind := '';
        AvailablePOSKeybindTemp.SetCurrentKey("Modifier Key Priority");
        AvailablePOSKeybindTemp.SetFilter("Modifier Key Priority", '<>0');
        if AvailablePOSKeybindTemp.FindSet() then
            repeat
                if KeyBind <> '' then
                    KeyBind += '+' + AvailablePOSKeybindTemp."Key Name"
                else
                    KeyBind := AvailablePOSKeybindTemp."Key Name";
            until AvailablePOSKeybindTemp.Next() = 0;
        AvailablePOSKeybindTemp.SetRange("Modifier Key Priority", 0);
        if AvailablePOSKeybindTemp.FindSet() then
            repeat
                if KeyBind <> '' then
                    KeyBind += '+' + AvailablePOSKeybindTemp."Key Name"
                else
                    KeyBind := AvailablePOSKeybindTemp."Key Name";
            until AvailablePOSKeybindTemp.Next() = 0;
        exit(true);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150701, 'OnCustomMethod', '', true, true)]
    local procedure InvokeKeyPressMethod(Method: Text; Context: JsonObject; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean)
    var
        JSON: Codeunit "NPR POS JSON Management";
        KeyPressed: Text;
    begin
        if not (Method = MethodName()) then
            exit;

        Handled := true;
        JSON.InitializeJObjectParser(Context, FrontEnd);
        KeyPressed := JSON.GetStringOrFail('key', StrSubstNo(ReadingErr, MethodName()));

        OnInvokeKeyPress(KeyPressed, POSSession, FrontEnd, Handled);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnDiscoverKeyboardBindings(var POSKeyboardBindingSetup: Record "NPR POS Keyboard Bind. Setup")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnInvokeKeyPress(KeyPress: Text; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean)
    begin
    end;
}
