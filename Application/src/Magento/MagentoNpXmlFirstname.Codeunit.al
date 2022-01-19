codeunit 6151455 "NPR Magento NpXml Firstname"
{
    TableNo = "NPR NpXml Custom Val. Buffer";

    trigger OnRun()
    var
        NpXmlElement: Record "NPR NpXml Element";
        RecRef: RecordRef;
        RecRef2: RecordRef;
        CustomValue: Text;
        OutStr: OutStream;
    begin
        if not NpXmlElement.Get(Rec."Xml Template Code", Rec."Xml Element Line No.") then
            exit;
        Clear(RecRef);
        RecRef.Open(Rec."Table No.");
        RecRef.SetPosition(Rec."Record Position");
        if not RecRef.Find() then
            exit;

        SetRecRefCalcFieldFilter(NpXmlElement, RecRef, RecRef2);
        CustomValue := Format(GetFirstname(RecRef, NpXmlElement."Field No."), 0, 9);
        RecRef.Close();

        Clear(RecRef);

        Rec.Value.CreateOutStream(OutStr);
        OutStr.WriteText(CustomValue);
        Rec.Modify();
    end;

    procedure GetFirstname(RecRef: RecordRef; FieldNo: Integer) Firstname: Text
    var
        FieldRef: FieldRef;
        Name: Text;
        Position: Integer;
    begin
        FieldRef := RecRef.Field(FieldNo);
        Name := Format(FieldRef.Value, 0, 9);

        while Name[StrLen(Name)] = ' ' do begin
            Name := DelStr(Name, StrLen(Name));
        end;

        Position := StrPos(Name, ' ');
        if Position = 0 then
            exit(Name);

        Firstname := '';
        while (Position > 0) and (Position <= StrLen(Name)) do begin
            if Position = 1 then
                Name := DelStr(Name, 1, 1)
            else begin
                if Firstname <> '' then
                    Firstname += ' ';
                Firstname += CopyStr(Name, 1, Position - 1);
                Name := DelStr(Name, 1, Position);
            end;

            Position := StrPos(Name, ' ');
        end;
        exit(Firstname);
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
}