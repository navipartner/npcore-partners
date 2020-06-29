codeunit 6151560 "NpXml Value Base64"
{
    // NC1.16/TS/20150507  CASE 213379 Object created - Custom Values for NpXml
    // NC1.21/TS/20151105  CASE 225454 Corrected exit clause
    // NC1.22/TS/29102015  CASE 225454  Enabled other field types than Blob
    // NC2.00/MHA/20160525  CASE 240005 NaviConnect

    TableNo = "NpXml Custom Value Buffer";

    trigger OnRun()
    var
        NpXmlElement: Record "NpXml Element";
        RecRef: RecordRef;
        RecRef2: RecordRef;
        CustomValue: Text;
        OutStr: OutStream;
    begin
        if not NpXmlElement.Get("Xml Template Code", "Xml Element Line No.") then
            exit;
        Clear(RecRef);
        RecRef.Open("Table No.");
        RecRef.SetPosition("Record Position");
        //-NC1.21
        //IF RecRef.FIND THEN
        if not RecRef.Find then
            //+NC1.21
            exit;

        CustomValue := Format(GetBase64(RecRef, NpXmlElement."Field No."), 0, 9);
        RecRef.Close;

        Clear(RecRef);

        Value.CreateOutStream(OutStr);
        OutStr.WriteText(CustomValue);
        Modify;
    end;

    local procedure GetBase64(RecRef: RecordRef; FieldNo: Integer) Value: Text
    var
        TempBlob: Codeunit "Temp Blob";
        BinaryReader: DotNet npNetBinaryReader;
        MemoryStream: DotNet npNetMemoryStream;
        Convert: DotNet npNetConvert;
        FieldRef: FieldRef;
        InStr: InStream;
        Outstr: OutStream;
    begin
        Value := '';

        FieldRef := RecRef.Field(FieldNo);
        //-NC1.22
        //FieldRef.CALCFIELD;
        //+NC1.22
        if LowerCase(Format(FieldRef.Type)) in ['blob'] then begin
            //-NC1.22
            FieldRef.CalcField;
            //+NC1.22
            Clear(TempBlob);
            TempBlob.FromFieldRef(FieldRef);
            TempBlob.CreateInStream(InStr);
            MemoryStream := InStr;
            BinaryReader := BinaryReader.BinaryReader(InStr);
            Value := Convert.ToBase64String(BinaryReader.ReadBytes(MemoryStream.Length));
            MemoryStream.Flush;
            MemoryStream.Close;
            Clear(MemoryStream);
        end else begin
            //-NC1.22
            Clear(TempBlob);
            TempBlob.CreateOutStream(Outstr);
            Outstr.WriteText(Format(FieldRef.Value));
            TempBlob.CreateInStream(InStr);
            MemoryStream := InStr;
            BinaryReader := BinaryReader.BinaryReader(InStr);
            Value := Convert.ToBase64String(BinaryReader.ReadBytes(MemoryStream.Length));
            MemoryStream.Flush;
            MemoryStream.Close;
            Clear(MemoryStream);
            //+NC1.22
        end;

        exit(Value);
    end;
}

