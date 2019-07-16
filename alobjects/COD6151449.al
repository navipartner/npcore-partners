codeunit 6151449 "Magento NpXml Value Mgt."
{
    // MAG2.22/MHA /20190614  CASE 355993 Object created


    trigger OnRun()
    begin
    end;

    [EventSubscriber(ObjectType::Codeunit, 6151555, 'OnGetXmlValue', '', true, true)]
    local procedure ConvertSpecialChars(RecRef: RecordRef;NpXmlElement: Record "NpXml Element";FieldNo: Integer;var XmlValue: Text;var Handled: Boolean)
    var
        FRef: FieldRef;
    begin
        if Handled then
          exit;
        if not IsSubscriber(NpXmlElement,'ConvertSpecialChars') then
          exit;

        Handled := true;

        FRef := RecRef.Field(FieldNo);
        XmlValue := Format(FRef.Value,0,9);
        XmlValue := ReplaceSpecialChar(XmlValue);
    end;

    local procedure ReplaceSpecialChar(Input: Text) Output: Text
    var
        i: Integer;
    begin
        Output := '';
        for i := 1 to StrLen(Input) do
          case Input[i] of
            '0','1','2','3','4','5','6','7','8','9',
            'a','b','c','d','e','f','g','h','i','j','A','B','C','D','E','F','G','H','I','J',
            'k','l','m','n','o','p','q','r','s','t','K','L','M','N','O','P','Q','R','S','T',
            'u','v','w','x','y','z','U','V','W','X','Y','Z','-','.','_',' ': Output += Format(Input[i]);
            '�': Output += 'ae';
            '�','�': Output += 'oe';
            '�','�': Output += 'aa';
            '�','�','�','�': Output += 'e';
            '�': Output += 'AE';
            '�','�': Output += 'OE';
            '�','�': Output += 'AA';
            '�','�','�','�': Output += 'E';
            else
              Output += '-';
          end;

        exit(Output);
    end;

    local procedure IsSubscriber(NpXmlElement: Record "NpXml Element";XmlValueFunction: Text): Boolean
    begin
        if NpXmlElement."Xml Value Codeunit ID" <> CurrCodeunitId() then
          exit(false);
        if NpXmlElement."Xml Value Function" <> XmlValueFunction then
          exit(false);

        exit(true);
    end;

    local procedure CurrCodeunitId(): Integer
    begin
        exit(CODEUNIT::"Magento NpXml Value Mgt.");
    end;
}

