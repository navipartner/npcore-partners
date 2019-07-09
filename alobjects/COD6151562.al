codeunit 6151562 "NpXml Xml Value Subscribers"
{
    // #255641/MHA /20161018 CASE 2425550 Object created - contains functions for returning Xml Value during NpXml Export
    // NC2.01/MHA/20161110  CASE 242550 NaviConnect


    trigger OnRun()
    begin
    end;

    [EventSubscriber(ObjectType::Codeunit, 6151555, 'OnGetXmlValue', '', true, true)]
    local procedure GetBase64(RecRef: RecordRef;NpXmlElement: Record "NpXml Element";FieldNo: Integer;var XmlValue: Text;var Handled: Boolean)
    var
        TempBlob: Record TempBlob temporary;
        BinaryReader: DotNet npNetBinaryReader;
        Convert: DotNet npNetConvert;
        Encoding: DotNet npNetEncoding;
        MemoryStream: DotNet npNetMemoryStream;
        FieldRef: FieldRef;
        InStr: InStream;
    begin
        if Handled then
          exit;
        if not IsSubscriber(NpXmlElement,'GetBase64') then
          exit;

        Handled := true;
        XmlValue := '';

        FieldRef := RecRef.Field(FieldNo);
        if LowerCase(Format(FieldRef.Type)) <> 'blob' then begin
          XmlValue := Convert.ToBase64String(Encoding.UTF8.GetBytes(Format(FieldRef.Value)));
          exit;
        end;

        FieldRef.CalcField;
        Clear(TempBlob);
        TempBlob.Blob := FieldRef.Value;
        TempBlob.Blob.CreateInStream(InStr);
        MemoryStream := InStr;
        BinaryReader := BinaryReader.BinaryReader(InStr);
        XmlValue := Convert.ToBase64String(BinaryReader.ReadBytes(MemoryStream.Length));
        MemoryStream.Flush;
        MemoryStream.Close;
        Clear(MemoryStream);
    end;

    local procedure "--- Aux"()
    begin
    end;

    local procedure IsSubscriber(NpXmlElement: Record "NpXml Element";XmlValueFunction: Text): Boolean
    begin
        if NpXmlElement."Xml Value Codeunit ID" <> CODEUNIT::"NpXml Xml Value Subscribers" then
          exit(false);
        if NpXmlElement."Xml Value Function" <> XmlValueFunction then
          exit(false);

        exit(true);
    end;
}

