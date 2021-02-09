codeunit 6151456 "NPR Magento NpXml Lastname"
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
        if not RecRef.Find then
            exit;

        SetRecRefCalcFieldFilter(NpXmlElement, RecRef, RecRef2);
        CustomValue := Format(GetLastname(RecRef2, NpXmlElement."Field No."), 0, 9);
        RecRef.Close;
        RecRef2.Close;
        Clear(RecRef);

        Rec.Value.CreateOutStream(OutStr);
        OutStr.WriteText(CustomValue);
        Rec.Modify;
    end;

    procedure GetLastname(RecRef: RecordRef; FieldNo: Integer) Lastname: Text
    var
        FieldRef: FieldRef;
        Position: Integer;
    begin
        FieldRef := RecRef.Field(FieldNo);
        Lastname := Format(FieldRef.Value, 0, 9);

        Position := StrPos(Lastname, ' ');
        if Position = 0 then
            exit('');

        repeat
            Lastname := DelStr(Lastname, 1, Position);
            Position := StrPos(Lastname, ' ');
        until Position <= 0;

        exit(Lastname);
    end;

    local procedure SetRecRefCalcFieldFilter(NpXmlElement: Record "NPR NpXml Element"; RecRef: RecordRef; var RecRef2: RecordRef)
    var
        NpXmlFilter: Record "NPR NpXml Filter";
        FieldRef: FieldRef;
        FieldRef2: FieldRef;
        BufferDecimal: Decimal;
        BufferInteger: Integer;
    begin
        Clear(RecRef2);
        RecRef2.Open(RecRef.Number);
        RecRef2 := RecRef.Duplicate;

        NpXmlFilter.SetRange("Xml Template Code", NpXmlElement."Xml Template Code");
        NpXmlFilter.SetRange("Xml Element Line No.", NpXmlElement."Line No.");
        if NpXmlFilter.FindSet then
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
            until NpXmlFilter.Next = 0;

        case NpXmlElement."Iteration Type" of
            NpXmlElement."Iteration Type"::First:
                begin
                    if RecRef2.FindFirst then
                        RecRef2.SetRecFilter;
                end;
            NpXmlElement."Iteration Type"::Last:
                begin
                    if RecRef2.FindLast then
                        RecRef2.SetRecFilter;
                end;
        end;
    end;
}