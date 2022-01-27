codeunit 6151463 "NPR M2 Account Lookup Mgt."
{
    Access = Internal;
    var
        Text000: Label '%1 %2 does not exist ';

    #region Display Group

    procedure LookupDisplayGroup(var Customer: Record Customer)
    var
        MagentoSetup: Record "NPR Magento Setup";
        MagentoDisplayGroup: Record "NPR Magento Display Group";
        TempM2ValueBuffer: Record "NPR M2 Value Buffer" temporary;
        M2ValueBufferList: Page "NPR M2 Value Buffer List";
    begin
        MagentoSetup.Get();
        if MagentoSetup."Magento Version" = MagentoSetup."Magento Version"::"1" then begin
            if MagentoDisplayGroup.Get(Customer."NPR Magento Display Group") then;
            if PAGE.RunModal(0, MagentoDisplayGroup) = ACTION::LookupOK then
                Customer."NPR Magento Display Group" := MagentoDisplayGroup.Code;

            exit;
        end;

        SetupDisplayGroups(TempM2ValueBuffer);
        if TempM2ValueBuffer.FindFirst() then;
        if TempM2ValueBuffer.Get(Customer."NPR Magento Display Group") then;

        Clear(M2ValueBufferList);
        M2ValueBufferList.SetCaption(Customer.FieldCaption("NPR Magento Display Group"));
        M2ValueBufferList.SetShowValue(true);
        M2ValueBufferList.SetShowLabel(true);
        M2ValueBufferList.SetShowPosition(false);
        M2ValueBufferList.SetSourceTable(TempM2ValueBuffer);
        M2ValueBufferList.LookupMode(true);
        if M2ValueBufferList.RunModal() <> ACTION::LookupOK then
            exit;

        M2ValueBufferList.GetRecord(TempM2ValueBuffer);
        Customer."NPR Magento Display Group" := CopyStr(TempM2ValueBuffer.Value, 1, MaxStrLen(Customer."NPR Magento Display Group"));
    end;

    local procedure SetupDisplayGroups(var M2ValueBuffer: Record "NPR M2 Value Buffer" temporary)
    var
        Result: JsonToken;
        DisplayGroups: JsonArray;
        DisplayGroup: JsonToken;
        i: Integer;
    begin
        Clear(M2ValueBuffer);
        M2ValueBuffer.DeleteAll();

        MagentoApiGet('display_groups', Result);
        Result.SelectToken('$..display_group', Result);
        if Result.IsArray then
            DisplayGroups := Result.AsArray();

        foreach DisplayGroup in DisplayGroups do begin
            i += 1;

            M2ValueBuffer.Init();
            M2ValueBuffer.Value := CopyStr(UpperCase(GetJsonText(DisplayGroup, 'value')), 1, MaxStrLen(M2ValueBuffer.Value));
            M2ValueBuffer.Label := CopyStr(GetJsonText(DisplayGroup, 'label'), 1, MaxStrLen(M2ValueBuffer.Label));
            M2ValueBuffer.Position := i;
            M2ValueBuffer.Insert();
        end;
    end;

    procedure ValidateDisplayGroup(var Customer: Record Customer)
    var
        MagentoDisplayGroup: Record "NPR Magento Display Group";
        MagentoSetup: Record "NPR Magento Setup";
        M2ValueBuffer: Record "NPR M2 Value Buffer";
    begin
        if Customer."NPR Magento Display Group" = '' then
            exit;

        MagentoSetup.Get();
        if MagentoSetup."Magento Version" = MagentoSetup."Magento Version"::"1" then begin
            MagentoDisplayGroup.Get(Customer."NPR Magento Display Group");
            exit;
        end;

        SetupDisplayGroups(M2ValueBuffer);
        M2ValueBuffer.SetFilter(Value, '@' + Customer."NPR Magento Display Group");
        if not M2ValueBuffer.FindFirst() then
            M2ValueBuffer.SetFilter(Value, '@' + Customer."NPR Magento Display Group" + '*');

        if not M2ValueBuffer.FindFirst() then
            Error(Text000, Customer.FieldCaption("NPR Magento Display Group"), Customer."NPR Magento Display Group");

        Customer."NPR Magento Display Group" := CopyStr(M2ValueBuffer.Value, 1, MaxStrLen(Customer."NPR Magento Display Group"));
    end;

    #endregion

    #region Shipping Group

    procedure LookupShippingGroup(var Customer: Record Customer)
    var
        TempM2ValueBuffer: Record "NPR M2 Value Buffer" temporary;
        M2ValueBufferList: Page "NPR M2 Value Buffer List";
    begin
        SetupShippingGroups(TempM2ValueBuffer);
        if TempM2ValueBuffer.FindFirst() then;
        if TempM2ValueBuffer.Get(Customer."NPR Magento Shipping Group") then;

        Clear(M2ValueBufferList);
        M2ValueBufferList.SetCaption(Customer.FieldCaption("NPR Magento Shipping Group"));
        M2ValueBufferList.SetShowValue(true);
        M2ValueBufferList.SetShowLabel(false);
        M2ValueBufferList.SetShowPosition(false);
        M2ValueBufferList.SetSourceTable(TempM2ValueBuffer);
        M2ValueBufferList.LookupMode(true);
        if M2ValueBufferList.RunModal() <> ACTION::LookupOK then
            exit;

        M2ValueBufferList.GetRecord(TempM2ValueBuffer);
        Customer."NPR Magento Shipping Group" := CopyStr(TempM2ValueBuffer.Value, 1, MaxStrLen(Customer."NPR Magento Shipping Group"));
    end;

    local procedure SetupShippingGroups(var M2ValueBuffer: Record "NPR M2 Value Buffer" temporary)
    var
        Result: JsonToken;
        ShippingGroups: JsonArray;
        ShippingGroup: JsonToken;
        i: Integer;
    begin
        Clear(M2ValueBuffer);
        M2ValueBuffer.DeleteAll();

        MagentoApiGet('shipping_groups', Result);
        if not Result.SelectToken('$..shipping_group', Result) then
            exit;

        if Result.IsArray then
            ShippingGroups := Result.AsArray();

        foreach ShippingGroup in ShippingGroups do begin
            i += 1;

            M2ValueBuffer.Init();
            M2ValueBuffer.Value := CopyStr(GetJsonText(ShippingGroup, ''), 1, MaxStrLen(M2ValueBuffer.Value));
            M2ValueBuffer.Position := i;
            M2ValueBuffer.Insert();
        end;
    end;

    procedure ValidateShippingGroup(var Customer: Record Customer)
    var
        M2ValueBuffer: Record "NPR M2 Value Buffer";
    begin
        if Customer."NPR Magento Shipping Group" = '' then
            exit;

        SetupShippingGroups(M2ValueBuffer);
        M2ValueBuffer.SetFilter(Value, '@' + Customer."NPR Magento Shipping Group");
        if not M2ValueBuffer.FindFirst() then
            M2ValueBuffer.SetFilter(Value, '@' + Customer."NPR Magento Shipping Group" + '*');

        if not M2ValueBuffer.FindFirst() then
            Error(Text000, Customer.FieldCaption("NPR Magento Shipping Group"), Customer."NPR Magento Shipping Group");

        Customer."NPR Magento Shipping Group" := CopyStr(M2ValueBuffer.Value, 1, MaxStrLen(Customer."NPR Magento Shipping Group"));
    end;

    #endregion

    #region Payment Group

    procedure LookupPaymentGroup(var Customer: Record Customer)
    var
        TempM2ValueBuffer: Record "NPR M2 Value Buffer" temporary;
        M2ValueBufferList: Page "NPR M2 Value Buffer List";
    begin
        SetupPaymentGroups(TempM2ValueBuffer);
        if TempM2ValueBuffer.FindFirst() then;

        Clear(M2ValueBufferList);
        M2ValueBufferList.SetCaption(Customer.FieldCaption("NPR Magento Payment Group"));
        M2ValueBufferList.SetShowValue(true);
        M2ValueBufferList.SetShowLabel(false);
        M2ValueBufferList.SetShowPosition(false);
        M2ValueBufferList.SetSourceTable(TempM2ValueBuffer);
        M2ValueBufferList.LookupMode(true);
        if M2ValueBufferList.RunModal() <> ACTION::LookupOK then
            exit;

        M2ValueBufferList.GetRecord(TempM2ValueBuffer);
        Customer."NPR Magento Payment Group" := CopyStr(TempM2ValueBuffer.Value, 1, MaxStrLen(Customer."NPR Magento Payment Group"));
    end;

    local procedure SetupPaymentGroups(var M2ValueBuffer: Record "NPR M2 Value Buffer" temporary)
    var
        Result: JsonToken;
        PaymentGroups: JsonArray;
        PaymentGroup: JsonToken;
        i: Integer;
    begin
        Clear(M2ValueBuffer);
        M2ValueBuffer.DeleteAll();

        MagentoApiGet('payment_groups', Result);
        if not Result.SelectToken('$..payment_group', Result) then
            exit;

        if Result.IsArray then
            PaymentGroups := Result.AsArray();

        foreach PaymentGroup in PaymentGroups do begin
            i += 1;

            M2ValueBuffer.Init();
            M2ValueBuffer.Value := CopyStr(GetJsonText(PaymentGroup, ''), 1, MaxStrLen(M2ValueBuffer.Value));
            M2ValueBuffer.Position := i;
            M2ValueBuffer.Insert();
        end;
    end;

    procedure ValidatePaymentGroup(var Customer: Record Customer)
    var
        M2ValueBuffer: Record "NPR M2 Value Buffer";
    begin
        if Customer."NPR Magento Payment Group" = '' then
            exit;

        SetupPaymentGroups(M2ValueBuffer);
        M2ValueBuffer.SetFilter(Value, '@' + Customer."NPR Magento Payment Group");
        if not M2ValueBuffer.FindFirst() then
            M2ValueBuffer.SetFilter(Value, '@' + Customer."NPR Magento Payment Group" + '*');

        if not M2ValueBuffer.FindFirst() then
            Error(Text000, Customer.FieldCaption("NPR Magento Payment Group"), Customer."NPR Magento Payment Group");

        Customer."NPR Magento Payment Group" := CopyStr(M2ValueBuffer.Value, 1, MaxStrLen(Customer."NPR Magento Payment Group"));
    end;

    #endregion

    #region Customer Group

    procedure LookupCustomerGroup(var Contact: Record Contact)
    var
        MagentoSetup: Record "NPR Magento Setup";
        MagentoCustomerGroup: Record "NPR Magento Customer Group";
        TempM2ValueBuffer: Record "NPR M2 Value Buffer" temporary;
        M2ValueBufferList: Page "NPR M2 Value Buffer List";
    begin
        MagentoSetup.Get();
        if MagentoSetup."Magento Version" = MagentoSetup."Magento Version"::"1" then begin
            if MagentoCustomerGroup.Get(Contact."NPR Magento Customer Group") then;
            if PAGE.RunModal(0, MagentoCustomerGroup) = ACTION::LookupOK then
                Contact."NPR Magento Customer Group" := MagentoCustomerGroup.Code;

            exit;
        end;

        SetupCustomerGroups(TempM2ValueBuffer);
        if TempM2ValueBuffer.FindFirst() then;
        if TempM2ValueBuffer.Get(Contact."NPR Magento Customer Group") then;

        Clear(M2ValueBufferList);
        M2ValueBufferList.SetCaption(Contact.FieldCaption("NPR Magento Customer Group"));
        M2ValueBufferList.SetShowValue(true);
        M2ValueBufferList.SetShowLabel(true);
        M2ValueBufferList.SetShowPosition(false);
        M2ValueBufferList.SetSourceTable(TempM2ValueBuffer);
        M2ValueBufferList.LookupMode(true);
        if M2ValueBufferList.RunModal() <> ACTION::LookupOK then
            exit;

        M2ValueBufferList.GetRecord(TempM2ValueBuffer);
        Contact."NPR Magento Customer Group" := UpperCase(CopyStr(TempM2ValueBuffer.Value, 1, MaxStrLen(Contact."NPR Magento Customer Group")));
    end;

    local procedure SetupCustomerGroups(var M2ValueBuffer: Record "NPR M2 Value Buffer" temporary)
    var
        Result: JsonToken;
        CustomerGroups: JsonArray;
        CustomerGroup: JsonToken;
        i: Integer;
    begin
        Clear(M2ValueBuffer);
        M2ValueBuffer.DeleteAll();

        MagentoApiGet('customer_groups', Result);
        if not Result.SelectToken('$..customer_group', Result) then
            exit;

        if Result.IsArray then
            CustomerGroups := Result.AsArray();

        foreach CustomerGroup in CustomerGroups do begin
            i += 1;

            M2ValueBuffer.Init();
            M2ValueBuffer.Value := CopyStr(UpperCase(GetJsonText(CustomerGroup, 'customer_group_code')), 1, MaxStrLen(M2ValueBuffer.Value));
            M2ValueBuffer.Label := CopyStr(GetJsonText(CustomerGroup, 'tax_class_code'), 1, MaxStrLen(M2ValueBuffer.Label));
            M2ValueBuffer.Position := i;
            M2ValueBuffer.Insert();
        end;
    end;

    procedure ValidateCustomerGroup(var Contact: Record Contact)
    var
        MagentoCustomerGroup: Record "NPR Magento Customer Group";
        MagentoSetup: Record "NPR Magento Setup";
        M2ValueBuffer: Record "NPR M2 Value Buffer";
    begin
        if Contact."NPR Magento Customer Group" = '' then
            exit;

        MagentoSetup.Get();
        if MagentoSetup."Magento Version" = MagentoSetup."Magento Version"::"1" then begin
            MagentoCustomerGroup.Get(Contact."NPR Magento Customer Group");
            exit;
        end;

        SetupCustomerGroups(M2ValueBuffer);
        M2ValueBuffer.SetFilter(Value, '@' + Contact."NPR Magento Customer Group");
        if not M2ValueBuffer.FindFirst() then
            M2ValueBuffer.SetFilter(Value, '@' + Contact."NPR Magento Customer Group" + '*');

        if not M2ValueBuffer.FindFirst() then
            Error(Text000, Contact.FieldCaption("NPR Magento Customer Group"), Contact."NPR Magento Customer Group");

        Contact."NPR Magento Customer Group" := CopyStr(M2ValueBuffer.Value, 1, MaxStrLen(Contact."NPR Magento Customer Group"));
    end;

    #endregion

    #region Magento Store

    procedure LookupMagentoStore(var Customer: Record Customer)
    var
        MagentoSetup: Record "NPR Magento Setup";
        MagentoStore: Record "NPR Magento Store";
        TempM2ValueBuffer: Record "NPR M2 Value Buffer" temporary;
        M2ValueBufferList: Page "NPR M2 Value Buffer List";
    begin
        MagentoSetup.Get();
        if MagentoSetup."Magento Version" = MagentoSetup."Magento Version"::"1" then begin
            if MagentoStore.Get(Customer."NPR Magento Store Code") then;
            if PAGE.RunModal(0, MagentoStore) = ACTION::LookupOK then
                Customer."NPR Magento Store Code" := MagentoStore.Code;

            exit;
        end;

        SetupMagentoStores(TempM2ValueBuffer);
        if TempM2ValueBuffer.FindFirst() then;
        if TempM2ValueBuffer.Get(Customer."NPR Magento Store Code") then;

        Clear(M2ValueBufferList);
        M2ValueBufferList.SetCaption(Customer.FieldCaption("NPR Magento Store Code"));
        M2ValueBufferList.SetShowValue(true);
        M2ValueBufferList.SetShowLabel(true);
        M2ValueBufferList.SetShowPosition(false);
        M2ValueBufferList.SetSourceTable(TempM2ValueBuffer);
        M2ValueBufferList.LookupMode(true);
        if M2ValueBufferList.RunModal() <> ACTION::LookupOK then
            exit;

        M2ValueBufferList.GetRecord(TempM2ValueBuffer);
        Customer."NPR Magento Store Code" := CopyStr(TempM2ValueBuffer.Value, 1, MaxStrLen(Customer."NPR Magento Store Code"));
    end;

    local procedure SetupMagentoStores(var M2ValueBuffer: Record "NPR M2 Value Buffer" temporary)
    var
        Result: JsonToken;
        MagentoWebsites: JsonArray;
        MagentoWebsite: JsonToken;
        StoreGroups: JsonArray;
        StoreGroup: JsonToken;
        MagentoStores: JsonArray;
        MagentoStore: JsonToken;
        i: Integer;
    begin
        Clear(M2ValueBuffer);
        M2ValueBuffer.DeleteAll();

        MagentoApiGet('websites', Result);
        if not Result.SelectToken('$..website', Result) then
            exit;

        if Result.IsArray then
            MagentoWebsites := Result.AsArray();

        foreach MagentoWebsite in MagentoWebsites do begin
            MagentoWebsite.SelectToken('$.._value.store_groups.store_group', StoreGroup);
            if StoreGroup.IsArray then
                StoreGroups := StoreGroup.AsArray();

            foreach StoreGroup in StoreGroups do begin
                StoreGroup.SelectToken('$.._value.stores.store', MagentoStore);
                if MagentoStore.IsArray then
                    MagentoStores := MagentoStore.AsArray();

                foreach MagentoStore in MagentoStores do begin
                    i += 1;

                    M2ValueBuffer.Init();
                    M2ValueBuffer.Value := CopyStr(GetJsonText(MagentoStore, '_attribute.code'), 1, MaxStrLen(M2ValueBuffer.Value));
                    M2ValueBuffer.Label := CopyStr(GetJsonText(MagentoStore, '_value'), 1, MaxStrLen(M2ValueBuffer.Label));
                    M2ValueBuffer.Position := i;
                    M2ValueBuffer.Insert();
                end;
            end;
        end;
    end;

    procedure ValidateMagentoStore(var Customer: Record Customer)
    var
        MagentoStore: Record "NPR Magento Store";
        MagentoSetup: Record "NPR Magento Setup";
        M2ValueBuffer: Record "NPR M2 Value Buffer";
    begin
        if Customer."NPR Magento Store Code" = '' then
            exit;

        MagentoSetup.Get();
        if MagentoSetup."Magento Version" = MagentoSetup."Magento Version"::"1" then begin
            MagentoStore.Get(Customer."NPR Magento Store Code");
            exit;
        end;

        SetupMagentoStores(M2ValueBuffer);
        M2ValueBuffer.SetFilter(Value, '@' + Customer."NPR Magento Store Code");
        if not M2ValueBuffer.FindFirst() then
            M2ValueBuffer.SetFilter(Value, '@' + Customer."NPR Magento Store Code" + '*');

        if not M2ValueBuffer.FindFirst() then
            Error(Text000, Customer.FieldCaption("NPR Magento Store Code"), Customer."NPR Magento Store Code");

        Customer."NPR Magento Store Code" := CopyStr(M2ValueBuffer.Value, 1, MaxStrLen(Customer."NPR Magento Store Code"));
    end;

    #endregion

    #region Aux

    procedure MagentoApiGet(Method: Text; var Result: JsonToken)
    var
        MagentoSetup: Record "NPR Magento Setup";
        HttpWebRequest: HttpRequestMessage;
        HttpWebResponse: HttpResponseMessage;
        Client: HttpClient;
        Headers: HttpHeaders;
        Response: Text;
    begin
        Clear(Response);
        if Method = '' then
            exit;

        MagentoSetup.Get();
        MagentoSetup.TestField("Api Url");
        if MagentoSetup."Api Url"[StrLen(MagentoSetup."Api Url")] <> '/' then
            MagentoSetup."Api Url" += '/';

        HttpWebRequest.SetRequestUri(MagentoSetup."Api Url" + Method);
        HttpWebRequest.Method('GET');
        HttpWebRequest.GetHeaders(Headers);
        if MagentoSetup."Api Authorization" <> '' then
            Headers.Add('Authorization', MagentoSetup."Api Authorization")
        else
            Headers.Add('Authorization', 'Basic ' + MagentoSetup.GetBasicAuthInfo());

        Client.Timeout := 60000;
        Client.Send(HttpWebRequest, HttpWebResponse);
        HttpWebResponse.Content.ReadAs(Response);
        if not HttpWebResponse.IsSuccessStatusCode() then
            Error('%1 - %2  \%3', HttpWebResponse.HttpStatusCode, HttpWebResponse.ReasonPhrase, Response);

        Result.ReadFrom(Response);
    end;

    local procedure GetJsonText(JToken: JsonToken; JPath: Text) Value: Text
    var
        JToken2: JsonToken;
    begin
        if not JToken.SelectToken(JPath, JToken2) then
            exit('');

        Value := JToken2.AsValue().AsText();
        exit(Value);
    end;
}

#endregion
