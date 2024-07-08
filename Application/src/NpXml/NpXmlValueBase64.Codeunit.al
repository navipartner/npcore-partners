codeunit 6151560 "NPR NpXml Value Base64"
{
    Access = Internal;
    TableNo = "NPR NpXml Custom Val. Buffer";

    trigger OnRun()
    var
        NpXmlElement: Record "NPR NpXml Element";
        RecRef: RecordRef;
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

        CustomValue := Format(GetBase64(RecRef, NpXmlElement."Field No."), 0, 9);
        RecRef.Close();

        Clear(RecRef);

        Rec.Value.CreateOutStream(OutStr);
        OutStr.WriteText(CustomValue);
        Rec.Modify();
    end;

    local procedure GetBase64(RecRef: RecordRef; FieldNo: Integer) Value: Text
    var
        TempBlob: Codeunit "Temp Blob";
        Base64Convert: Codeunit "Base64 Convert";
        FieldRef: FieldRef;
        InStr: InStream;
        Outstr: OutStream;
        ByteText: Text;
    begin
        Value := '';

        FieldRef := RecRef.Field(FieldNo);
        if LowerCase(Format(FieldRef.Type)) in ['blob'] then begin
            FieldRef.CalcField();
            Clear(TempBlob);
            TempBlob.FromFieldRef(FieldRef);
            TempBlob.CreateInStream(InStr);
            InStr.Read(ByteText);
            Value := Base64Convert.ToBase64(ByteText);
        end else begin
            Clear(TempBlob);
            TempBlob.CreateOutStream(Outstr);
            Outstr.WriteText(Format(FieldRef.Value));
            TempBlob.CreateInStream(InStr);
            InStr.Read(ByteText);
            Value := Base64Convert.ToBase64(ByteText);
        end;

        exit(Value);
    end;
}

