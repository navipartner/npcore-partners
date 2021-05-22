codeunit 6151555 "NPR NpXml Value Mgt."
{
    procedure GetXmlValue(RecRef: RecordRef; NpXmlElement: Record "NPR NpXml Element"; FieldNo: Integer) XmlValue: Text
    var
        TempBlob: Codeunit "Temp Blob";
        FieldRef: FieldRef;
        InStr: InStream;
        DecBuffer: Decimal;
        IntBuffer: Integer;
        OptionString: Text;
        TextBuffer: Text;
        Handled: Boolean;
    begin
        if NpXmlElement."Xml Value Codeunit ID" > 0 then begin
            OnGetXmlValue(RecRef, NpXmlElement, FieldNo, XmlValue, Handled);
            if Handled then
                exit(XmlValue);
        end;
        if NpXmlElement."Custom Codeunit ID" > 0 then
            exit(GetCustomFieldValue(RecRef, NpXmlElement));

        if FieldNo <= 0 then
            exit('');

        XmlValue := '';
        FieldRef := RecRef.Field(FieldNo);
        if LowerCase(Format(FieldRef.Class)) = 'flowfield' then
            FieldRef.CalcField();

        if NpXmlElement."Field Type" <> NpXmlElement."Field Type"::" " then
            XmlValue := GetSpecialFieldValue(RecRef, NpXmlElement, FieldNo)
        else
            case LowerCase(Format(FieldRef.Type)) of
                'integer':
                    begin
                        Evaluate(IntBuffer, Format(FieldRef.Value, 0, 9), 9);
                        if (NpXmlElement."Blank Zero" and (IntBuffer = 0)) then
                            exit('');

                        if NpXmlElement."Reverse Sign" then
                            IntBuffer := -1 * IntBuffer;
                        XmlValue := Format(IntBuffer, 0, 9);
                    end;
                'decimal':
                    begin
                        Evaluate(DecBuffer, Format(FieldRef.Value, 0, 9), 9);
                        if (NpXmlElement."Blank Zero" and (DecBuffer = 0)) then
                            exit('');
                        if NpXmlElement."Reverse Sign" then
                            DecBuffer := -1 * DecBuffer;
                        if NpXmlElement."Round Precision" > 0 then
                            DecBuffer := Round(DecBuffer, NpXmlElement."Round Precision", NpXmlElement."Round Direction");
                        XmlValue := Format(DecBuffer, 0, 9);
                    end;
                'option':
                    begin
                        OptionString := Format(FieldRef.OptionMembers);
                        if Evaluate(IntBuffer, Format(FieldRef.Value, 0, 9)) and (OptionString <> '') then begin
                            XmlValue := GetEnumOption(IntBuffer, OptionString);
                        end;
                    end;
                else
                    if LowerCase(Format(FieldRef.Type)) = 'blob' then begin
                        XmlValue := '';

                        FieldRef.CalcField();
                        TempBlob.FromFieldRef(FieldRef);
                        TempBlob.CreateInStream(InStr);
                        while not InStr.EOS do begin
                            InStr.ReadText(TextBuffer);
                            XmlValue += TextBuffer;
                        end;
                    end else
                        XmlValue := Format(FieldRef.Value, 0, 9);
            end;

        if NpXmlElement."Lower Case" then
            XmlValue := LowerCase(XmlValue);

        if (NpXmlElement.Prefix <> '') then
            XmlValue := NpXmlElement.Prefix + XmlValue;

        if NpXmlElement."No of Chars (Trunc. to Length)" > 0 then
            XmlValue := CopyStr(XmlValue, 1, NpXmlElement."No of Chars (Trunc. to Length)");

        exit(XmlValue);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnGetXmlValue(RecRef: RecordRef; NpXmlElement: Record "NPR NpXml Element"; FieldNo: Integer; var XmlValue: Text; var Handled: Boolean)
    begin
    end;

    local procedure SetRecRefCalcFieldFilter(NpXmlElement: Record "NPR NpXml Element"; RecRef: RecordRef; var RecRef2: RecordRef)
    var
        NpXmlFilter: Record "NPR NpXml Filter";
        FieldRef2: FieldRef;
        BufferDecimal: Decimal;
        BufferInteger: Integer;
    begin
        Clear(RecRef2);
        RecRef2.Open(RecRef.Number);
        RecRef2 := RecRef.Duplicate();

        NpXmlFilter.SetRange("Xml Template Code", NpXmlElement."Xml Template Code");
        NpXmlFilter.SetRange("Xml Element Line No.", NpXmlElement."Line No.");
        if NpXmlFilter.FindSet() then
            repeat
                FieldRef2 := RecRef2.Field(NpXmlFilter."Field No.");
                case NpXmlFilter."Filter Type" of
                    NpXmlFilter."Filter Type"::Constant:
                        begin
                            if NpXmlFilter."Filter Value" <> '' then begin
                                case LowerCase(Format(FieldRef2.Type)) of
                                    'boolean':
                                        FieldRef2.SetFilter('=%1', LowerCase(NpXmlFilter."Filter Value") in ['1', 'yes', 'ja', 'true']);
                                    'integer', 'option':
                                        begin
                                            if Evaluate(BufferDecimal, NpXmlFilter."Filter Value") then
                                                FieldRef2.SetFilter('=%1', BufferDecimal);
                                        end;
                                    'decimal':
                                        begin
                                            if Evaluate(BufferInteger, NpXmlFilter."Filter Value") then
                                                FieldRef2.SetFilter('=%1', BufferInteger);
                                        end;
                                    else
                                        FieldRef2.SetFilter('=%1', NpXmlFilter."Filter Value");
                                end;
                            end;
                        end;
                    NpXmlFilter."Filter Type"::Filter:
                        begin
                            FieldRef2.SetFilter(NpXmlFilter."Filter Value");
                        end;
                end;
            until NpXmlFilter.Next() = 0;

        case NpXmlElement."Iteration Type" of
            NpXmlElement."Iteration Type"::First:
                begin
                    if RecRef2.FindFirst() then
                        RecRef2.SetRecFilter();
                end;
            NpXmlElement."Iteration Type"::Last:
                begin
                    if RecRef2.FindLast() then
                        RecRef2.SetRecFilter();
                end;
        end;
    end;

    procedure FillCustomValueBuffer(RecRef: RecordRef; NPXmlElement: Record "NPR NpXml Element"; var TempNpXmlCustomValueBuffer: Record "NPR NpXml Custom Val. Buffer" temporary)
    begin
        TempNpXmlCustomValueBuffer.DeleteAll();
        TempNpXmlCustomValueBuffer.Init();
        TempNpXmlCustomValueBuffer."Table No." := RecRef.Number;
        TempNpXmlCustomValueBuffer."Record Position" := RecRef.GetPosition(false);
        TempNpXmlCustomValueBuffer."Xml Template Code" := NPXmlElement."Xml Template Code";
        TempNpXmlCustomValueBuffer."Xml Element Line No." := NPXmlElement."Line No.";
        TempNpXmlCustomValueBuffer.Insert();
    end;

    procedure GetCustomFieldValue(RecRef: RecordRef; NPXmlElement: Record "NPR NpXml Element") Value: Text
    var
        TempNpXmlCustomValueBuffer: Record "NPR NpXml Custom Val. Buffer" temporary;
        InStr: InStream;
        Line: Text;
        DecimalValue: Decimal;
    begin
        if NPXmlElement."Custom Codeunit ID" <= 0 then
            exit('');

        FillCustomValueBuffer(RecRef, NPXmlElement, TempNpXmlCustomValueBuffer);
        CODEUNIT.Run(NPXmlElement."Custom Codeunit ID", TempNpXmlCustomValueBuffer);
        Value := '';
        TempNpXmlCustomValueBuffer.CalcFields(Value);
        TempNpXmlCustomValueBuffer.Value.CreateInStream(InStr);
        while not InStr.EOS do begin
            InStr.ReadText(Line);
            Value += Line;
        end;
        if NPXmlElement."Round Precision" > 0 then begin
            if Evaluate(DecimalValue, Value) then begin
                DecimalValue := Round(DecimalValue, NpXmlElement."Round Precision", NpXmlElement."Round Direction");
                Value := Format(DecimalValue, 0, 9)
            end;
        end;
        if NPXmlElement."No of Chars (Trunc. to Length)" > 0 then
            Value := CopyStr(Value, 1, NpXmlElement."No of Chars (Trunc. to Length)");
        exit(Value);
    end;

    local procedure GetEnum(RecRef: RecordRef; NPXmlElement: Record "NPR NpXml Element"; FieldNo: Integer) EnumOption: Text
    var
        FieldRef: FieldRef;
        Option: Integer;
    begin
        FieldRef := RecRef.Field(FieldNo);
        if LowerCase(Format(FieldRef.Type)) in ['boolean', 'option', 'integer'] then begin
            if NPXmlElement."Enum List (,)" = '' then
                exit('');
            Evaluate(Option, Format(FieldRef.Value, 0, 2));
            EnumOption := GetEnumOption(Option, NPXmlElement."Enum List (,)");
            exit(EnumOption);
        end;

        exit(Format(FieldRef.Value, 0, 9));
    end;

    procedure GetEnumOption(Option: Integer; EnumString: Text) EnumOption: Text
    var
        Position: Integer;
        i: Integer;
    begin
        EnumOption := EnumString;
        for i := 0 to Option do begin
            if EnumOption = '' then
                exit('');
            if i < Option then begin
                Position := StrPos(EnumOption, ',');
                if Position = 0 then
                    exit('');
                EnumOption := DelStr(EnumOption, 1, Position);
            end;
        end;
        Position := StrPos(EnumOption, ',');
        if Position > 0 then
            EnumOption := CopyStr(EnumOption, 1, Position - 1);
        exit(EnumOption);
    end;

    procedure GetPrimaryKeyValue(var RecRef: RecordRef) PrimaryKeyValue: Text
    var
        KeyRef: KeyRef;
        FieldRef: FieldRef;
        i: Integer;
    begin
        KeyRef := RecRef.KeyIndex(1);
        for i := 1 to KeyRef.FieldCount do begin
            FieldRef := KeyRef.FieldIndex(i);
            if PrimaryKeyValue <> '' then
                PrimaryKeyValue += '_';
            PrimaryKeyValue += Format(FieldRef.Value, 0, 9);
        end;
        exit(PrimaryKeyValue);
    end;

    local procedure GetSpecialFieldValue(RecRef: RecordRef; NPXmlElement: Record "NPR NpXml Element"; FieldNo: Integer) Value: Text
    var
        RecRef2: RecordRef;
    begin
        SetRecRefCalcFieldFilter(NPXmlElement, RecRef, RecRef2);
        Value := '';
        case NPXmlElement."Field Type" of
            NPXmlElement."Field Type"::Enum:
                Value := GetEnum(RecRef, NPXmlElement, FieldNo);
            NPXmlElement."Field Type"::PrimaryKey:
                Value := GetPrimaryKeyValue(RecRef);
        end;
        RecRef2.Close();
        exit(Value);
    end;
}

