codeunit 6151463 "M2 Account Lookup Mgt."
{
    // MAG2.20/MHA /20190425  CASE 320423 Object created - Buffer used with M2 GET Apis
    // MAG2.22/MHA /20190712  CASE 361786 Updated DotNet Type of System.Collections.IList to System.Collections.IEnumerable


    trigger OnRun()
    begin
    end;

    var
        Text000: Label '%1 %2 does not exist ';

    local procedure "--- Display Group"()
    begin
    end;

    procedure LookupDisplayGroup(var Customer: Record Customer)
    var
        MagentoSetup: Record "Magento Setup";
        MagentoDisplayGroup: Record "Magento Display Group";
        M2ValueBuffer: Record "M2 Value Buffer" temporary;
        M2ValueBufferList: Page "M2 Value Buffer List";
    begin
        MagentoSetup.Get;
        if MagentoSetup."Magento Version" = MagentoSetup."Magento Version"::"1" then begin
          if MagentoDisplayGroup.Get(Customer."Magento Display Group") then;
          if PAGE.RunModal(0,MagentoDisplayGroup) = ACTION::LookupOK then
            Customer."Magento Display Group" := MagentoDisplayGroup.Code;

          exit;
        end;

        SetupDisplayGroups(M2ValueBuffer);
        if M2ValueBuffer.FindFirst then;
        if M2ValueBuffer.Get(Customer."Magento Display Group") then;

        Clear(M2ValueBufferList);
        M2ValueBufferList.SetCaption(Customer.FieldCaption("Magento Display Group"));
        M2ValueBufferList.SetShowValue(true);
        M2ValueBufferList.SetShowLabel(true);
        M2ValueBufferList.SetShowPosition(false);
        M2ValueBufferList.SetSourceTable(M2ValueBuffer);
        M2ValueBufferList.LookupMode(true);
        if M2ValueBufferList.RunModal <> ACTION::LookupOK then
          exit;

        M2ValueBufferList.GetRecord(M2ValueBuffer);
        Customer."Magento Display Group" := UpperCase(CopyStr(M2ValueBuffer.Value,1,MaxStrLen(Customer."Magento Display Group")));
    end;

    local procedure SetupDisplayGroups(var M2ValueBuffer: Record "M2 Value Buffer" temporary)
    var
        Result: DotNet npNetJToken;
        DisplayGroups: DotNet npNetIEnumerable;
        DisplayGroup: DotNet npNetJToken;
        i: Integer;
    begin
        Clear(M2ValueBuffer);
        M2ValueBuffer.DeleteAll;

        MagentoApiGet('display_groups',Result);
        DisplayGroups := Result.SelectTokens('$[*].[''display_group''].[*]');
        foreach DisplayGroup in DisplayGroups do begin
          i += 1;

          M2ValueBuffer.Init;
          M2ValueBuffer.Value := UpperCase(GetJsonText(DisplayGroup,'value',MaxStrLen(M2ValueBuffer.Value)));
          M2ValueBuffer.Label := GetJsonText(DisplayGroup,'label',MaxStrLen(M2ValueBuffer.Label));
          M2ValueBuffer.Position := i;
          M2ValueBuffer.Insert;
        end;
    end;

    procedure ValidateDisplayGroup(var Customer: Record Customer)
    var
        MagentoDisplayGroup: Record "Magento Display Group";
        MagentoSetup: Record "Magento Setup";
        M2ValueBuffer: Record "M2 Value Buffer";
    begin
        if Customer."Magento Display Group" = '' then
          exit;

        MagentoSetup.Get;
        if MagentoSetup."Magento Version" = MagentoSetup."Magento Version"::"1" then begin
          MagentoDisplayGroup.Get(Customer."Magento Display Group");
          exit;
        end;

        SetupDisplayGroups(M2ValueBuffer);
        M2ValueBuffer.SetFilter(Value,'@' + Customer."Magento Display Group");
        if not M2ValueBuffer.FindFirst then
          M2ValueBuffer.SetFilter(Value,'@' + Customer."Magento Display Group" + '*');

        if not M2ValueBuffer.FindFirst then
          Error(Text000,Customer.FieldCaption("Magento Display Group"),Customer."Magento Display Group");

        Customer."Magento Display Group" := CopyStr(M2ValueBuffer.Value,1,MaxStrLen(Customer."Magento Display Group"));
    end;

    local procedure "--- Shipping Group"()
    begin
    end;

    procedure LookupShippingGroup(var Customer: Record Customer)
    var
        M2ValueBuffer: Record "M2 Value Buffer" temporary;
        M2ValueBufferList: Page "M2 Value Buffer List";
    begin
        SetupShippingGroups(M2ValueBuffer);
        if M2ValueBuffer.FindFirst then;
        if M2ValueBuffer.Get(Customer."Magento Shipping Group") then;

        Clear(M2ValueBufferList);
        M2ValueBufferList.SetCaption(Customer.FieldCaption("Magento Shipping Group"));
        M2ValueBufferList.SetShowValue(true);
        M2ValueBufferList.SetShowLabel(false);
        M2ValueBufferList.SetShowPosition(false);
        M2ValueBufferList.SetSourceTable(M2ValueBuffer);
        M2ValueBufferList.LookupMode(true);
        if M2ValueBufferList.RunModal <> ACTION::LookupOK then
          exit;

        M2ValueBufferList.GetRecord(M2ValueBuffer);
        Customer."Magento Shipping Group" := CopyStr(M2ValueBuffer.Value,1,MaxStrLen(Customer."Magento Shipping Group"));
    end;

    local procedure SetupShippingGroups(var M2ValueBuffer: Record "M2 Value Buffer" temporary)
    var
        Result: DotNet npNetJToken;
        ShippingGroups: DotNet npNetIEnumerable;
        ShippingGroup: DotNet npNetJToken;
        i: Integer;
    begin
        Clear(M2ValueBuffer);
        M2ValueBuffer.DeleteAll;

        MagentoApiGet('shipping_groups',Result);
        ShippingGroups := Result.SelectTokens('$[*].[''shipping_group''].[*]');
        foreach ShippingGroup in ShippingGroups do begin
          i += 1;

          M2ValueBuffer.Init;
          M2ValueBuffer.Value := GetJsonText(ShippingGroup,'',MaxStrLen(M2ValueBuffer.Value));
          M2ValueBuffer.Position := i;
          M2ValueBuffer.Insert;
        end;
    end;

    procedure ValidateShippingGroup(var Customer: Record Customer)
    var
        M2ValueBuffer: Record "M2 Value Buffer";
    begin
        if Customer."Magento Shipping Group" = '' then
          exit;

        SetupShippingGroups(M2ValueBuffer);
        M2ValueBuffer.SetFilter(Value,'@' + Customer."Magento Shipping Group");
        if not M2ValueBuffer.FindFirst then
          M2ValueBuffer.SetFilter(Value,'@' + Customer."Magento Shipping Group" + '*');

        if not M2ValueBuffer.FindFirst then
          Error(Text000,Customer.FieldCaption("Magento Shipping Group"),Customer."Magento Shipping Group");

        Customer."Magento Shipping Group" := CopyStr(M2ValueBuffer.Value,1,MaxStrLen(Customer."Magento Shipping Group"));
    end;

    local procedure "--- Payment Group"()
    begin
    end;

    procedure LookupPaymentGroup(var Customer: Record Customer)
    var
        M2ValueBuffer: Record "M2 Value Buffer" temporary;
        M2ValueBufferList: Page "M2 Value Buffer List";
    begin
        SetupPaymentGroups(M2ValueBuffer);
        if M2ValueBuffer.FindFirst then;

        Clear(M2ValueBufferList);
        M2ValueBufferList.SetCaption(Customer.FieldCaption("Magento Payment Group"));
        M2ValueBufferList.SetShowValue(true);
        M2ValueBufferList.SetShowLabel(false);
        M2ValueBufferList.SetShowPosition(false);
        M2ValueBufferList.SetSourceTable(M2ValueBuffer);
        M2ValueBufferList.LookupMode(true);
        if M2ValueBufferList.RunModal <> ACTION::LookupOK then
          exit;

        M2ValueBufferList.GetRecord(M2ValueBuffer);
        Customer."Magento Payment Group" := CopyStr(M2ValueBuffer.Value,1,MaxStrLen(Customer."Magento Payment Group"));
    end;

    local procedure SetupPaymentGroups(var M2ValueBuffer: Record "M2 Value Buffer" temporary)
    var
        Result: DotNet npNetJToken;
        PaymentGroups: DotNet npNetIEnumerable;
        PaymentGroup: DotNet npNetJToken;
        i: Integer;
    begin
        Clear(M2ValueBuffer);
        M2ValueBuffer.DeleteAll;

        MagentoApiGet('payment_groups',Result);
        PaymentGroups := Result.SelectTokens('[*].[''payment_group''].[*]');
        foreach PaymentGroup in PaymentGroups do begin
          i += 1;

          M2ValueBuffer.Init;
          M2ValueBuffer.Value := GetJsonText(PaymentGroup,'',MaxStrLen(M2ValueBuffer.Value));
          M2ValueBuffer.Position := i;
          M2ValueBuffer.Insert;
        end;
    end;

    procedure ValidatePaymentGroup(var Customer: Record Customer)
    var
        M2ValueBuffer: Record "M2 Value Buffer";
    begin
        if Customer."Magento Payment Group" = '' then
          exit;

        SetupPaymentGroups(M2ValueBuffer);
        M2ValueBuffer.SetFilter(Value,'@' + Customer."Magento Payment Group");
        if not M2ValueBuffer.FindFirst then
          M2ValueBuffer.SetFilter(Value,'@' + Customer."Magento Payment Group" + '*');

        if not M2ValueBuffer.FindFirst then
          Error(Text000,Customer.FieldCaption("Magento Payment Group"),Customer."Magento Payment Group");

        Customer."Magento Payment Group" := CopyStr(M2ValueBuffer.Value,1,MaxStrLen(Customer."Magento Payment Group"));
    end;

    local procedure "--- Customer Group"()
    begin
    end;

    procedure LookupCustomerGroup(var Contact: Record Contact)
    var
        MagentoSetup: Record "Magento Setup";
        MagentoCustomerGroup: Record "Magento Customer Group";
        M2ValueBuffer: Record "M2 Value Buffer" temporary;
        M2ValueBufferList: Page "M2 Value Buffer List";
    begin
        MagentoSetup.Get;
        if MagentoSetup."Magento Version" = MagentoSetup."Magento Version"::"1" then begin
          if MagentoCustomerGroup.Get(Contact."Magento Customer Group") then;
          if PAGE.RunModal(0,MagentoCustomerGroup) = ACTION::LookupOK then
            Contact."Magento Customer Group" := MagentoCustomerGroup.Code;

          exit;
        end;

        SetupCustomerGroups(M2ValueBuffer);
        if M2ValueBuffer.FindFirst then;
        if M2ValueBuffer.Get(Contact."Magento Customer Group") then;

        Clear(M2ValueBufferList);
        M2ValueBufferList.SetCaption(Contact.FieldCaption("Magento Customer Group"));
        M2ValueBufferList.SetShowValue(true);
        M2ValueBufferList.SetShowLabel(true);
        M2ValueBufferList.SetShowPosition(false);
        M2ValueBufferList.SetSourceTable(M2ValueBuffer);
        M2ValueBufferList.LookupMode(true);
        if M2ValueBufferList.RunModal <> ACTION::LookupOK then
          exit;

        M2ValueBufferList.GetRecord(M2ValueBuffer);
        Contact."Magento Customer Group" := UpperCase(CopyStr(M2ValueBuffer.Value,1,MaxStrLen(Contact."Magento Customer Group")));
    end;

    local procedure SetupCustomerGroups(var M2ValueBuffer: Record "M2 Value Buffer" temporary)
    var
        Result: DotNet npNetJToken;
        CustomerGroups: DotNet npNetIEnumerable;
        CustomerGroup: DotNet npNetJToken;
        i: Integer;
    begin
        Clear(M2ValueBuffer);
        M2ValueBuffer.DeleteAll;

        MagentoApiGet('customer_groups',Result);
        CustomerGroups := Result.SelectTokens('$[*].[''customer_group''].[*]');
        foreach CustomerGroup in CustomerGroups do begin
          i += 1;

          M2ValueBuffer.Init;
          M2ValueBuffer.Value := UpperCase(GetJsonText(CustomerGroup,'customer_group_code',MaxStrLen(M2ValueBuffer.Value)));
          M2ValueBuffer.Label := GetJsonText(CustomerGroup,'tax_class_code',MaxStrLen(M2ValueBuffer.Label));
          M2ValueBuffer.Position := i;
          M2ValueBuffer.Insert;
        end;
    end;

    procedure ValidateCustomerGroup(var Contact: Record Contact)
    var
        MagentoCustomerGroup: Record "Magento Customer Group";
        MagentoSetup: Record "Magento Setup";
        M2ValueBuffer: Record "M2 Value Buffer";
    begin
        if Contact."Magento Customer Group" = '' then
          exit;

        MagentoSetup.Get;
        if MagentoSetup."Magento Version" = MagentoSetup."Magento Version"::"1" then begin
          MagentoCustomerGroup.Get(Contact."Magento Customer Group");
          exit;
        end;

        SetupCustomerGroups(M2ValueBuffer);
        M2ValueBuffer.SetFilter(Value,'@' + Contact."Magento Customer Group");
        if not M2ValueBuffer.FindFirst then
          M2ValueBuffer.SetFilter(Value,'@' + Contact."Magento Customer Group" + '*');

        if not M2ValueBuffer.FindFirst then
          Error(Text000,Contact.FieldCaption("Magento Customer Group"),Contact."Magento Customer Group");

        Contact."Magento Customer Group" := CopyStr(M2ValueBuffer.Value,1,MaxStrLen(Contact."Magento Customer Group"));
    end;

    local procedure "--- Magento Store"()
    begin
    end;

    procedure LookupMagentoStore(var Customer: Record Customer)
    var
        MagentoSetup: Record "Magento Setup";
        MagentoStore: Record "Magento Store";
        M2ValueBuffer: Record "M2 Value Buffer" temporary;
        M2ValueBufferList: Page "M2 Value Buffer List";
    begin
        MagentoSetup.Get;
        if MagentoSetup."Magento Version" = MagentoSetup."Magento Version"::"1" then begin
          if MagentoStore.Get(Customer."Magento Store Code") then;
          if PAGE.RunModal(0,MagentoStore) = ACTION::LookupOK then
            Customer."Magento Store Code" := MagentoStore.Code;

          exit;
        end;

        SetupMagentoStores(M2ValueBuffer);
        if M2ValueBuffer.FindFirst then;
        if M2ValueBuffer.Get(Customer."Magento Store Code") then;

        Clear(M2ValueBufferList);
        M2ValueBufferList.SetCaption(Customer.FieldCaption("Magento Store Code"));
        M2ValueBufferList.SetShowValue(true);
        M2ValueBufferList.SetShowLabel(true);
        M2ValueBufferList.SetShowPosition(false);
        M2ValueBufferList.SetSourceTable(M2ValueBuffer);
        M2ValueBufferList.LookupMode(true);
        if M2ValueBufferList.RunModal <> ACTION::LookupOK then
          exit;

        M2ValueBufferList.GetRecord(M2ValueBuffer);
        Customer."Magento Store Code" := CopyStr(M2ValueBuffer.Value,1,MaxStrLen(Customer."Magento Store Code"));
    end;

    local procedure SetupMagentoStores(var M2ValueBuffer: Record "M2 Value Buffer" temporary)
    var
        Result: DotNet npNetJToken;
        MagentoWebsites: DotNet npNetIEnumerable;
        MagentoWebsite: DotNet npNetJToken;
        MagentoStores: DotNet npNetIEnumerable;
        MagentoStore: DotNet npNetJToken;
        i: Integer;
    begin
        Clear(M2ValueBuffer);
        M2ValueBuffer.DeleteAll;

        MagentoApiGet('websites',Result);
        MagentoWebsites := Result.SelectTokens('$[*].[''website''].[*]');
        foreach MagentoWebsite in MagentoWebsites do begin
          MagentoStores := MagentoWebsite.SelectTokens('$[''_value''].[''store_groups''].[''store_group''].[*].[''_value''].[''stores''].[''store''].[*]');
          foreach MagentoStore in MagentoStores do begin
            i += 1;

            M2ValueBuffer.Init;
            M2ValueBuffer.Value := GetJsonText(MagentoStore,'_attribute.code',MaxStrLen(M2ValueBuffer.Value));
            M2ValueBuffer.Label := GetJsonText(MagentoStore,'_value',MaxStrLen(M2ValueBuffer.Label));
            M2ValueBuffer.Position := i;
            M2ValueBuffer.Insert;
          end;
        end;
    end;

    procedure ValidateMagentoStore(var Customer: Record Customer)
    var
        MagentoStore: Record "Magento Store";
        MagentoSetup: Record "Magento Setup";
        M2ValueBuffer: Record "M2 Value Buffer";
    begin
        if Customer."Magento Store Code" = '' then
          exit;

        MagentoSetup.Get;
        if MagentoSetup."Magento Version" = MagentoSetup."Magento Version"::"1" then begin
          MagentoStore.Get(Customer."Magento Store Code");
          exit;
        end;

        SetupMagentoStores(M2ValueBuffer);
        M2ValueBuffer.SetFilter(Value,'@' + Customer."Magento Store Code");
        if not M2ValueBuffer.FindFirst then
          M2ValueBuffer.SetFilter(Value,'@' + Customer."Magento Store Code" + '*');

        if not M2ValueBuffer.FindFirst then
          Error(Text000,Customer.FieldCaption("Magento Store Code"),Customer."Magento Store Code");

        Customer."Magento Store Code" := CopyStr(M2ValueBuffer.Value,1,MaxStrLen(Customer."Magento Store Code"));
    end;

    local procedure "--- Aux"()
    begin
    end;

    procedure MagentoApiGet(Method: Text;var Result: DotNet npNetJToken)
    var
        MagentoSetup: Record "Magento Setup";
        HttpWebRequest: DotNet npNetHttpWebRequest;
        HttpWebResponse: DotNet npNetHttpWebResponse;
        StreamReader: DotNet npNetStreamReader;
        Response: Text;
    begin
        Clear(Response);
        if Method = '' then
          exit;

        MagentoSetup.Get;
        MagentoSetup.TestField("Api Url");
        if MagentoSetup."Api Url"[StrLen(MagentoSetup."Api Url")] <> '/' then
          MagentoSetup."Api Url" += '/';

        HttpWebRequest := HttpWebRequest.Create(MagentoSetup."Api Url"+ Method);
        HttpWebRequest.Timeout := 1000 * 60;

        HttpWebRequest.Method := 'GET';
        MagentoSetup.Get;
        if MagentoSetup."Api Authorization" <> '' then
          HttpWebRequest.Headers.Add('Authorization',MagentoSetup."Api Authorization")
        else
          HttpWebRequest.Headers.Add('Authorization','Basic ' + MagentoSetup.GetBasicAuthInfo());

        HttpWebResponse := HttpWebRequest.GetResponse();
        StreamReader := StreamReader.StreamReader(HttpWebResponse.GetResponseStream);
        Response := StreamReader.ReadToEnd;
        Result := Result.Parse(Response);
    end;

    local procedure GetJsonText(JToken: DotNet npNetJToken;JPath: Text;MaxLen: Integer) Value: Text
    var
        JToken2: DotNet npNetJToken;
    begin
        JToken2 := JToken.SelectToken(JPath);
        if IsNull(JToken2) then
          exit('');

        Value := Format(JToken2);
        if MaxLen > 0 then
          Value := CopyStr(Value,1,MaxLen);
        exit(Value);
    end;
}

