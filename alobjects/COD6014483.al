codeunit 6014483 "NP Service Process"
{
    // NPR70.01.00.00/MH/20140610  Refactored: Http DotNet variables are utilized instead of Automation Variables.
    // NPR4.21/KN/20160218 CASE 213605 Exploiting new webservice.
    // NPR5.41/JDH /20180427 CASE 313106 Removed unused code and vars
    // NPR5.49/MHA /20190206 CASE 341836 Changed WS endpoint to Azure Api Management, removed deprecated WebInvoke functionality, and cleared green code

    TableNo = "Retail List";

    trigger OnRun()
    var
        AmountUsed: Decimal;
    begin
        if StrLen(Value) >0 then begin
          if Evaluate(AmountUsed,Value) then;
          AmountUsed := AmountUsed / 100;
          if ProcessServiceAmount(Choice,AmountUsed) = false then
            Chosen := false;
        end else
          if ProcessService(Choice) = false then
            Chosen := false;
    end;

    var
        IComm: Record "I-Comm";
        Envfunc: Codeunit "NPR Environment Mgt.";

    procedure IsUserSubscribed(SubscriptionUserId: Text[50];CustomerNo: Code[20];ServiceId: Code[20]) Result: Boolean
    var
        NpXmlDomMgt: Codeunit "NpXml Dom Mgt.";
        HttpWebRequest: DotNet HttpWebRequest;
        HttpWebResponse: DotNet HttpWebResponse;
        Uri: DotNet Uri;
        WebException: DotNet WebException;
        XmlDoc: DotNet XmlDocument;
        ServiceMethod: Text;
        ReturnValue: Text;
    begin
        //-NPR5.49 [341836]
        ServiceMethod := 'IsUserSubscribed';
        Uri := Uri.Uri('https://api.navipartner.dk/servicelibrary');
        HttpWebRequest := HttpWebRequest.Create(Uri);
        HttpWebRequest.Method := 'POST';
        HttpWebRequest.ContentType := 'text/xml; charset=utf-8';
        HttpWebRequest.Headers.Add('SOAPAction','urn:microsoft-dynamics-schemas/codeunit/ServiceLibrary:' + ServiceMethod);
        HttpWebRequest.Headers.Add('Ocp-Apim-Subscription-Key','012e067d9f514816b6504e0ad9fb4e36');
        HttpWebRequest.Timeout(5000);

        XmlDoc := XmlDoc.XmlDocument;
        XmlDoc.LoadXml(
          '<?xml version="1.0" encoding="utf-8"?>' +
          '<Envelope xmlns="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">' +
            '<Body>' +
              '<' + ServiceMethod + ' xmlns="urn:microsoft-dynamics-schemas/codeunit/ServiceLibrary">' +
                '<userID>' + SubscriptionUserId + '</userID>' +
                '<customerNo>' + CustomerNo + '</customerNo>' +
                '<serviceId>' + ServiceId + '</serviceId>' +
              '</' + ServiceMethod + '>' +
            '</Body>' +
          '</Envelope>'
        );

        if not NpXmlDomMgt.SendWebRequest(XmlDoc,HttpWebRequest,HttpWebResponse,WebException) then
          exit(false);

        ReturnValue := GetReturnValue(HttpWebResponse,ServiceMethod);
        exit(LowerCase(ReturnValue) = 'true');
        //+NPR5.49 [341836]
    end;

    procedure IsCustomerSubscribed(CustomerNo: Code[20];ServiceId: Code[20]) Result: Boolean
    var
        NpXmlDomMgt: Codeunit "NpXml Dom Mgt.";
        HttpWebRequest: DotNet HttpWebRequest;
        HttpWebResponse: DotNet HttpWebResponse;
        Uri: DotNet Uri;
        WebException: DotNet WebException;
        XmlDoc: DotNet XmlDocument;
        ServiceMethod: Text;
        ReturnValue: Text;
    begin
        //-NPR5.49 [341836]
        ServiceMethod := 'IsCustomerSubscribed';
        Uri := Uri.Uri('https://api.navipartner.dk/servicelibrary');
        HttpWebRequest := HttpWebRequest.Create(Uri);
        HttpWebRequest.Method := 'POST';
        HttpWebRequest.ContentType := 'text/xml; charset=utf-8';
        HttpWebRequest.Headers.Add('SOAPAction','urn:microsoft-dynamics-schemas/codeunit/ServiceLibrary:' + ServiceMethod);
        HttpWebRequest.Headers.Add('Ocp-Apim-Subscription-Key','012e067d9f514816b6504e0ad9fb4e36');
        HttpWebRequest.Timeout(5000);

        XmlDoc := XmlDoc.XmlDocument;
        XmlDoc.LoadXml(
          '<?xml version="1.0" encoding="utf-8"?>' +
          '<Envelope xmlns="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">' +
            '<Body>' +
              '<' + ServiceMethod + ' xmlns="urn:microsoft-dynamics-schemas/codeunit/ServiceLibrary">' +
                '<customerNo>' + CustomerNo + '</customerNo>' +
                '<serviceId>' + ServiceId + '</serviceId>' +
              '</' + ServiceMethod + '>' +
            '</Body>' +
          '</Envelope>'
        );

        if not NpXmlDomMgt.SendWebRequest(XmlDoc,HttpWebRequest,HttpWebResponse,WebException) then
          exit(false);

        ReturnValue := GetReturnValue(HttpWebResponse,ServiceMethod);
        exit(LowerCase(ReturnValue) = 'true');
        //+NPR5.49 [341836]
    end;

    procedure CreateUserAccount(SubscriptionUserId: Text[50];CustomerNo: Code[20];ServiceId: Code[20]) Result: Boolean
    var
        NpXmlDomMgt: Codeunit "NpXml Dom Mgt.";
        HttpWebRequest: DotNet HttpWebRequest;
        HttpWebResponse: DotNet HttpWebResponse;
        Uri: DotNet Uri;
        WebException: DotNet WebException;
        XmlDoc: DotNet XmlDocument;
        ServiceMethod: Text;
        ReturnValue: Text;
    begin
        //-NPR5.49 [341836]
        ServiceMethod := 'CreateUserAccount';
        Uri := Uri.Uri('https://api.navipartner.dk/servicelibrary');
        HttpWebRequest := HttpWebRequest.Create(Uri);
        HttpWebRequest.Method := 'POST';
        HttpWebRequest.ContentType := 'text/xml; charset=utf-8';
        HttpWebRequest.Headers.Add('SOAPAction','urn:microsoft-dynamics-schemas/codeunit/ServiceLibrary:' + ServiceMethod);
        HttpWebRequest.Headers.Add('Ocp-Apim-Subscription-Key','012e067d9f514816b6504e0ad9fb4e36');
        HttpWebRequest.Timeout(5000);

        XmlDoc := XmlDoc.XmlDocument;
        XmlDoc.LoadXml(
          '<?xml version="1.0" encoding="utf-8"?>' +
          '<Envelope xmlns="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">' +
            '<Body>' +
              '<' + ServiceMethod + ' xmlns="urn:microsoft-dynamics-schemas/codeunit/ServiceLibrary">' +
                '<userId>' + SubscriptionUserId + '</userId>' +
                '<customerNo>' + CustomerNo + '</customerNo>' +
                '<serviceId>' + ServiceId + '</serviceId>' +
              '</' + ServiceMethod + '>' +
            '</Body>' +
          '</Envelope>'
        );

        if not NpXmlDomMgt.SendWebRequest(XmlDoc,HttpWebRequest,HttpWebResponse,WebException) then
          exit(false);

        ReturnValue := GetReturnValue(HttpWebResponse,ServiceMethod);
        exit(LowerCase(ReturnValue) = 'true');
        //+NPR5.49 [341836]
    end;

    procedure CreateTransactionLogEntry(SubscriptionUserId: Text[50];CustomerNo: Code[20];ServiceId: Code[20]) Result: Boolean
    var
        NpXmlDomMgt: Codeunit "NpXml Dom Mgt.";
        HttpWebRequest: DotNet HttpWebRequest;
        HttpWebResponse: DotNet HttpWebResponse;
        Uri: DotNet Uri;
        WebException: DotNet WebException;
        XmlDoc: DotNet XmlDocument;
        ServiceMethod: Text;
        ReturnValue: Text;
    begin
        //-NPR5.49 [341836]
        ServiceMethod := 'CreateTransactionLog';
        Uri := Uri.Uri('https://api.navipartner.dk/servicelibrary');
        HttpWebRequest := HttpWebRequest.Create(Uri);
        HttpWebRequest.Method := 'POST';
        HttpWebRequest.ContentType := 'text/xml; charset=utf-8';
        HttpWebRequest.Headers.Add('SOAPAction','urn:microsoft-dynamics-schemas/codeunit/ServiceLibrary:' + ServiceMethod);
        HttpWebRequest.Headers.Add('Ocp-Apim-Subscription-Key','012e067d9f514816b6504e0ad9fb4e36');
        HttpWebRequest.Timeout(5000);

        XmlDoc := XmlDoc.XmlDocument;
        XmlDoc.LoadXml(
          '<?xml version="1.0" encoding="utf-8"?>' +
          '<Envelope xmlns="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">' +
            '<Body>' +
              '<' + ServiceMethod + ' xmlns="urn:microsoft-dynamics-schemas/codeunit/ServiceLibrary">' +
                '<userId>' + SubscriptionUserId + '</userId>' +
                '<customerNo>' + CustomerNo + '</customerNo>' +
                '<serviceId>' + ServiceId + '</serviceId>' +
              '</' + ServiceMethod + '>' +
            '</Body>' +
          '</Envelope>'
        );

        if not NpXmlDomMgt.SendWebRequest(XmlDoc,HttpWebRequest,HttpWebResponse,WebException) then
          exit(false);

        ReturnValue := GetReturnValue(HttpWebResponse,ServiceMethod);
        exit(LowerCase(ReturnValue) = 'true');
        //+NPR5.49 [341836]
    end;

    procedure CreateTransactionLogEntryAmt(SubscriptionUserId: Text[50];CustomerNo: Code[20];ServiceId: Code[20];Quantity: Decimal;Description: Text[50];Amount: Decimal) Result: Boolean
    var
        NpXmlDomMgt: Codeunit "NpXml Dom Mgt.";
        HttpWebRequest: DotNet HttpWebRequest;
        HttpWebResponse: DotNet HttpWebResponse;
        Uri: DotNet Uri;
        WebException: DotNet WebException;
        XmlDoc: DotNet XmlDocument;
        ServiceMethod: Text;
        ReturnValue: Text;
    begin
        //-NPR5.49 [341836]
        ServiceMethod := 'CreateTransacLogAmt';
        Uri := Uri.Uri('https://api.navipartner.dk/servicelibrary');
        HttpWebRequest := HttpWebRequest.Create(Uri);
        HttpWebRequest.Method := 'POST';
        HttpWebRequest.ContentType := 'text/xml; charset=utf-8';
        HttpWebRequest.Headers.Add('SOAPAction','urn:microsoft-dynamics-schemas/codeunit/ServiceLibrary:' + ServiceMethod);
        HttpWebRequest.Headers.Add('Ocp-Apim-Subscription-Key','012e067d9f514816b6504e0ad9fb4e36');
        HttpWebRequest.Timeout(5000);

        XmlDoc := XmlDoc.XmlDocument;
        XmlDoc.LoadXml(
          '<?xml version="1.0" encoding="utf-8"?>' +
          '<Envelope xmlns="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">' +
            '<Body>' +
              '<' + ServiceMethod + ' xmlns="urn:microsoft-dynamics-schemas/codeunit/ServiceLibrary">' +
                '<userId>' + SubscriptionUserId + '</userId>' +
                '<customerNo>' + CustomerNo + '</customerNo>' +
                '<quantity>' + Format(Quantity,0,9) + '</quantity>' +
                '<description>' + Description + '</description>' +
                '<amount>' + Format(Amount,0,9) + '</amount>' +
              '</' + ServiceMethod + '>' +
            '</Body>' +
          '</Envelope>'
        );

        if not NpXmlDomMgt.SendWebRequest(XmlDoc,HttpWebRequest,HttpWebResponse,WebException) then
          exit(false);

        ReturnValue := GetReturnValue(HttpWebResponse,ServiceMethod);
        exit(LowerCase(ReturnValue) = 'true');
        //+NPR5.49 [341836]
    end;

    procedure ProcessService(serviceid: Code[20]): Boolean
    var
        UserSubscribed: Boolean;
        CustomerSubscribed: Boolean;
        AccountCreated: Boolean;
        ServiceUsed: Boolean;
        CustomerNo: Code[20];
        SubscriptionUserId: Text[50];
    begin
        if IComm.Get then begin
          SubscriptionUserId := Envfunc.ClientEnvironment('username');
          CustomerNo := IComm."Customer No.";
          UserSubscribed := IsUserSubscribed(SubscriptionUserId,CustomerNo,serviceid);
          if not UserSubscribed then begin
            CustomerSubscribed := IsCustomerSubscribed(CustomerNo,serviceid);
            if CustomerSubscribed then begin
              AccountCreated := CreateUserAccount(SubscriptionUserId,CustomerNo,serviceid);
              CreateTransactionLogEntry(UserId,CustomerNo,serviceid);
              ServiceUsed := true;
            end;

          end else begin
            CreateTransactionLogEntry(SubscriptionUserId,CustomerNo,serviceid);
            ServiceUsed := true;
          end;
        end;
        exit(ServiceUsed);
    end;

    procedure ProcessServiceAmount(ServiceId: Code[20];AmountUsed: Decimal) Result: Boolean
    var
        UserSubscribed: Boolean;
        CustomerSubscribed: Boolean;
        AccountCreated: Boolean;
        ServiceUsed: Boolean;
        CustomerNo: Code[20];
        SubscriptionUserId: Text[50];
        QtyUsed: Decimal;
        LogDescription: Text[50];
    begin
        if IComm.Get then begin
          SubscriptionUserId := Envfunc.ClientEnvironment('username');
          CustomerNo := IComm."Customer No.";
          UserSubscribed := IsUserSubscribed(SubscriptionUserId,CustomerNo,ServiceId);
          QtyUsed := -1;
          LogDescription := SubscriptionUserId;
          if not UserSubscribed then begin
            CustomerSubscribed := IsCustomerSubscribed(CustomerNo,ServiceId);
            if CustomerSubscribed then begin
              AccountCreated := CreateUserAccount(SubscriptionUserId,CustomerNo,ServiceId);
              CreateTransactionLogEntryAmt(SubscriptionUserId,CustomerNo,ServiceId,QtyUsed,LogDescription,AmountUsed);
              ServiceUsed := true;
            end;
          end else begin
            CreateTransactionLogEntryAmt(SubscriptionUserId,CustomerNo,ServiceId,QtyUsed,LogDescription,AmountUsed);
            ServiceUsed := true;
          end;
        end;
        exit(ServiceUsed);
    end;

    local procedure GetReturnValue(HttpWebResponse: DotNet HttpWebResponse;ServiceMethod: Text) ResponseText: Text
    var
        NpXmlDomMgt: Codeunit "NpXml Dom Mgt.";
        XmlDoc: DotNet XmlDocument;
    begin
        //-NPR5.49 [341836]
        XmlDoc := XmlDoc.XmlDocument;
        XmlDoc.Load(HttpWebResponse.GetResponseStream());
        NpXmlDomMgt.RemoveNameSpaces(XmlDoc);
        ResponseText := NpXmlDomMgt.GetXmlText(XmlDoc.DocumentElement,'//return_value',0,true);
        exit(ResponseText);
        //+NPR5.49 [341836]
    end;
}

