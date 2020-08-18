codeunit 6151449 "Magento NpXml Value Mgt."
{
    // MAG2.22/MHA /20190614  CASE 355993 Object created
    // MAG2.26/MHA /20200430  CASE 402486 Added function GetStockQty(), GetStockStatus()


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
            'æ': Output += 'ae';
            '¢','ö': Output += 'oe';
            'å','ä': Output += 'aa';
            'è','é','ë','ê': Output += 'e';
            'Æ': Output += 'AE';
            '¥','Ö': Output += 'OE';
            'Å','Ä': Output += 'AA';
            'É','¯','®','­': Output += 'E';
            else
              Output += '-';
          end;

        exit(Output);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6151555, 'OnGetXmlValue', '', true, true)]
    local procedure GetStockQty(RecRef: RecordRef;NpXmlElement: Record "NpXml Element";FieldNo: Integer;var XmlValue: Text;var Handled: Boolean)
    var
        MagentoItemMgt: Codeunit "Magento Item Mgt.";
    begin
        //-MAG2.26 [402486]
        if Handled then
          exit;
        if not IsSubscriber(NpXmlElement,'GetStockQty') then
          exit;

        Handled := true;

        XmlValue := Format(MagentoItemMgt.GetStockQty2(RecRef),0,9);
        //+MAG2.26 [402486]
    end;

    [EventSubscriber(ObjectType::Codeunit, 6151555, 'OnGetXmlValue', '', true, true)]
    local procedure GetStockStatus(RecRef: RecordRef;NpXmlElement: Record "NpXml Element";FieldNo: Integer;var XmlValue: Text;var Handled: Boolean)
    var
        MagentoItemMgt: Codeunit "Magento Item Mgt.";
    begin
        //-MAG2.26 [402486]
        if Handled then
          exit;
        if not IsSubscriber(NpXmlElement,'GetStockStatus') then
          exit;

        Handled := true;

        XmlValue := '0';
        if MagentoItemMgt.GetStockQty2(RecRef) > 0 then
          XmlValue := '1';
        //+MAG2.26 [402486]
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

