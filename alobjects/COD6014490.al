codeunit 6014490 "Pakkelabels.dk Mgnt"
{
    // NPR5.26/BHR/20160926/integrating Codeunit to our retail solution
    // NPR5.29/BHR /20160926  CASE 248684
    // NPR5.29/CLVA/20161121  CASE 248684 Added web exception handling
    // NPR5.33/MHA /20170609  CASE 280137 Added check on ISTEMPORARY for Table Trigger Subscriber Functions
    // NPR5.33/BHR /20170629  CASE 282205 Corrected bug
    // NPR5.34/BHR /20170507  CASE 283061 Enable silent Processing
    // NPR5.36/BHR /20170904  CASE 248912 unable to send option value to pakkelabels.
    // NPR5.38/BHR /20180110  CASE 290780 Correct exception error message so that correct message is displayed.
    //                                    set weight to grams
    // NPR5.43/BHR /20180504  CASE 313475 Testfield only valid shipping agents
    // NPR5.43/BHR /20180508  CASE 304453 Return label functionality added.
    // NPR5.43/BHR /20180612  CASE 314692 Agreement option
    // NPR5.45/BHR /20180817  CASE 318441 Move code for delivery_instruction
    // NPR5.45/BHR /20180830  CASE 326205 Skip Entries that are not for Pakkelabels
    // NPR5.51/MHA /20190704  CASE 360780 Wrapped C80OnAfterPostSalesDoc() with ASSERTERROR to avoid hard errors
    // NPR5.51/BHR /20190919  CASE 362106 Update correct sales order with Correspondin foreign shipment details


    trigger OnRun()
    var
        ShipmentDocument: Record "Pacsoft Shipment Document";
    begin

        //-NPR5.36 [290780]
        TQSendPakkeLabel;
        //-NPR5.36 [290780]
    end;

    var
        RequestString: Text;
        RequestURL: Text;
        ResponseString: Text;
        ConvertBase64: DotNet npNetConvert;
        Bytes: DotNet npNetArray;
        MemoryStream: DotNet npNetMemoryStream;
        TempBlob: Record TempBlob temporary;
        OStream: OutStream;
        "<--NP-->": Integer;
        HttpWebRequest: DotNet npNetHttpWebRequest;
        ReqStream: DotNet npNetStream;
        ReqStreamWriter: DotNet npNetStreamWriter;
        HttpWebResponse: DotNet npNetHttpWebResponse;
        ResponseStream: DotNet npNetStream;
        ResponseStreamReader: DotNet npNetStreamReader;
        Text0001: Label 'Login Details Missing';
        int: Decimal;
        PackageProviderSetup: Record "Pacsoft Setup";
        Counter: Integer;
        "-- Web handling": Integer;
        WebException: DotNet npNetWebException;
        DotNetExceptionHandler: Codeunit "DotNet Exception Handler";
        WebExceptionStatus: DotNet npNetWebExceptionStatus;
        HttpStatusCode: DotNet npNetHttpStatusCode;
        ErrorText: Text;
        Err0000: Label 'Not authenticated';
        ErrorTextFound: Text;
        Err0001: Label 'Pakkelabels Return the following  error: %1';
        Text0002: Label 'Test Connection successful.';

    procedure Login(var Token: Text;Silent: Boolean)
    begin
        if not InitPackageProvider then
          exit;
        //-NPR5.34 [283061]
        ErrorTextFound:='';
        //+NPR5.34 [283061]
        RequestString := StrSubstNo('{"api_user":"%1","api_key":"%2"}',PackageProviderSetup."Api User",PackageProviderSetup."Api Key");
        RequestURL := 'https://app.pakkelabels.dk/api/public/v2/users/login';

        //-NPR5.29
        if not ExecuteCall('POST') then begin
        //-NPR5.34 [283061]
          GetExceptionMessage(Silent);
        //+NPR5.34 [283061]
        end;
        //-NPR5.29
        //-NPR5.34 [283061]
          if ErrorTextFound <> '' then
            exit;
        //+NPR5.34 [283061]
        GetValue('expired_at', ResponseString);
        Token := GetValue('token', ResponseString);
    end;

    procedure GetBalance(Silent: Boolean)
    var
        Token: Text;
    begin
        //-NPR5.34 [283061]
        Login(Token,Silent);
        if ErrorTextFound <>'' then
          exit;
        //+NPR5.34 [283061]
        RequestURL := StrSubstNo('https://app.pakkelabels.dk/api/public/v2/users/balance?token=%1', Token);
        RequestString := '';

        //-NPR5.29
        if not ExecuteCall('GET') then begin
        //-NPR5.34 [283061]
          GetExceptionMessage(Silent);
        //+NPR5.34 [283061]
        end;
        //-NPR5.29
        //-NPR5.34 [283061]
          if ErrorTextFound <> '' then
            exit;
        //+NPR5.34 [283061]
        Message('Balance: %1', GetValue('balance', ResponseString));
    end;

    procedure GetFreightRates(Silent: Boolean)
    var
        Token: Text;
    begin
        //-NPR5.34 [283061]
         Login(Token,Silent);
         if ErrorTextFound <>'' then
           exit;
        //+NPR5.34 [283061]

        RequestURL := StrSubstNo('https://app.pakkelabels.dk/api/public/v2/shipments/freight_rates?token=%1&country=%2', Token, 'DK');
        RequestString := '';
        //-NPR5.29
        if not ExecuteCall('GET') then begin
        //-NPR5.34 [283061]
          GetExceptionMessage(Silent);
        //+NPR5.34 [283061]
        end;
        //-NPR5.29

        Message(GetValue('services',ResponseString));
    end;

    procedure CreateShipment(var ShipmentDocument: Record "Pacsoft Shipment Document";Silent: Boolean)
    var
        Token: Text;
        CompanyInformation: Record "Company Information";
        ShippingAgent: Record "Shipping Agent";
        AutoDropPoint: Text;
        ServicePointIDPDK: Text;
        ServicePointIDGLS: Text;
        LabelType: Option Post,Return;
    begin
        //-NPR5.43 [304453]
        if not InitPackageProvider then
          exit;
        if not CompanyInformation.Get then exit;

        if not ShipmentDocument."Print Return Label" then begin
          if ShipmentDocument."Response Shipment ID" <> '' then begin
            if Silent then
              ErrorTextFound := Text0001
            else
              Error(Text0001);
          end;
        end else
         if ShipmentDocument."Response Shipment ID" <> '' then
            exit;

        Login(Token,Silent);
        if ErrorTextFound <>'' then
          exit;

        ShippingAgent.Get(ShipmentDocument."Shipping Agent Code");
        //-NPR5.45 [326205]
        if ShippingAgent."Shipping Method" = ShippingAgent."Shipping Method"::" " then
           exit;
        //+NPR5.45 [326205]
        if ShippingAgent."Drop Point Service" then begin
          case ShippingAgent."Shipping Method" of
           ShippingAgent."Shipping Method"::GLS:
             begin
                if ShipmentDocument."Delivery Location" ='' then
                  AutoDropPoint :='"true"'
                else begin
                  ServicePointIDGLS := ShipmentDocument."Ship-to Address 2";
                  ShipmentDocument."Address 2" :='';
                end;
             end;
           ShippingAgent."Shipping Method"::PDK:
             begin
                if ShipmentDocument."Delivery Location"<>'' then begin
                  ServicePointIDPDK := ShipmentDocument."Delivery Location";
                 end;
             end;
          end;
        end;


         RequestURL := 'https://app.pakkelabels.dk/api/public/v2/shipments/shipment';
         RequestString := '{';
         RequestString += StrSubstNo('"token":"%1",', Token);
         RequestString += StrSubstNo('"shipping_agent":"%1",',LowerCase(Format(ShipmentDocument."Shipping Method Code")));
         RequestString += StrSubstNo('"weight":"%1",',Format(ShipmentDocument."Total Weight",0,1));
         RequestString += StrSubstNo('"receiver_name":"%1",',ShipmentDocument.Name);
         RequestString += StrSubstNo('"receiver_attention":"%1",',ShipmentDocument.Contact);
         RequestString += StrSubstNo('"receiver_address1":"%1",',ShipmentDocument.Address+' '+ShipmentDocument."Address 2");
         if ServicePointIDGLS <>'' then
           RequestString += StrSubstNo('"receiver_address2":"%1",',ServicePointIDGLS);
         RequestString += StrSubstNo('"receiver_zipcode":"%1",',ShipmentDocument."Post Code");
         RequestString += StrSubstNo('"receiver_city":"%1",',ShipmentDocument.City);
         RequestString += StrSubstNo('"receiver_country":"%1",',ShipmentDocument."Country/Region Code");
         RequestString += StrSubstNo('"receiver_email":"%1",',ShipmentDocument."E-Mail");
         RequestString += StrSubstNo('"receiver_mobile":"%1",',ShipmentDocument."SMS No.");
         RequestString += StrSubstNo('"sender_name":"%1",',CompanyInformation.Name);
         RequestString += StrSubstNo('"sender_address1":"%1",',CompanyInformation.Address);
         RequestString += StrSubstNo('"sender_zipcode":"%1",',CompanyInformation."Post Code");
         RequestString += StrSubstNo('"sender_city":"%1",',CompanyInformation.City);
         RequestString += StrSubstNo('"sender_country":"%1",',CompanyInformation."Country/Region Code");
         RequestString += StrSubstNo('"shipping_product_id":"%1",',ShipmentDocument."Shipping Agent Code");
         RequestString += StrSubstNo('"services":"%1",',ShipmentDocument."Shipping Agent Service Code");
        if AutoDropPoint <>'' then
           RequestString += StrSubstNo('"auto_select_droppoint":"true",');
         RequestString += StrSubstNo('"order_id":"%1",',ShipmentDocument."Order No.");
         RequestString += StrSubstNo('"reference":"%1",',ShipmentDocument.Reference);
         RequestString += StrSubstNo('"label_format":"a5",');
         RequestString += StrSubstNo('"number_of_collis":"%1",',Format(ShipmentDocument."Parcel Qty."));

        if ServicePointIDPDK <>'' then begin
           RequestString += StrSubstNo('"custom_delivery":"true",');
           RequestString += StrSubstNo('"service_point_id":"%1",',ServicePointIDPDK);
          end;
        if PackageProviderSetup."Use Pakkelable Printer API" then
          RequestString += StrSubstNo('"add_to_print_queue":"true",');
        //-NPR5.45 [318441]
        if (PackageProviderSetup."Send Delivery Instructions") and (ShipmentDocument."Delivery Instructions" <> '') then
           RequestString += StrSubstNo('"delivery_instruction":"%1",',ShipmentDocument."Delivery Instructions");
        //+NPR5.45 [318441]

        if PackageProviderSetup."Pakkelable Test Mode" then
          RequestString += '"test":"true"'
         else
         RequestString += '"test":"false"';
        //-NPR5.45 [318441]
        //IF (PackageProviderSetup."Send Delivery Instructions") AND (ShipmentDocument."Delivery Instructions" <> '') THEN
         //  RequestString += STRSUBSTNO('"delivery_instruction":"%1",',ShipmentDocument."Delivery Instructions");
        //+NPR5.45 [318441]
         RequestString += '}';

        if not ExecuteCall('POST') then begin
          GetExceptionMessage(Silent);

        end;
        if ErrorTextFound <>'' then
          exit;
        ShipmentDocument."Response Shipment ID" := GetValue('shipment_id', ResponseString);
        ShipmentDocument."Response Package No." := GetValue('pkg_no', ResponseString);
        ShipmentDocument.Modify;

        GetPDFByShipmentId(ShipmentDocument,Silent,LabelType::Post);

        //+NPR5.43 [304453]
    end;

    procedure CreateShipmentOwnCustomerNo(var ShipmentDocument: Record "Pacsoft Shipment Document";Silent: Boolean)
    var
        Token: Text;
        CompanyInformation: Record "Company Information";
        Text0001: Label 'The document has already sent to Pakkelabels.';
        ShippingAgent: Record "Shipping Agent";
        AutoDropPoint: Text;
        ServicePointIDPDK: Text;
        ServicePointIDGLS: Text;
        LabelType: Option Post,Return;
    begin
        if not InitPackageProvider then
          exit;
        if not CompanyInformation.Get then exit;

        //-NPR5.34 [283061]
        //-[NPR5.43] [304453]
        if not ShipmentDocument."Print Return Label" then begin
        //+[NPR5.43] [304453]
          if ShipmentDocument."Response Shipment ID" <> '' then begin
            if Silent then
              ErrorTextFound := Text0001
            else
              Error(Text0001);
          end;
        //-[NPR5.43] [304453]
        end else
         if ShipmentDocument."Response Shipment ID" <> '' then
            exit;

        //+[NPR5.43] [304453]
        Login(Token,Silent);
        if ErrorTextFound <>'' then
          exit;
        //+NPR5.34 [283061]

        //-NPR5.29 [248684]
        ShippingAgent.Get(ShipmentDocument."Shipping Agent Code");
        //-NPR5.45 [326205]
        if ShippingAgent."Shipping Method" = ShippingAgent."Shipping Method"::" " then
           exit;
        //+NPR5.45 [326205]
        if ShippingAgent."Drop Point Service" then begin
          case ShippingAgent."Shipping Method" of
           ShippingAgent."Shipping Method"::GLS:
             begin
                if ShipmentDocument."Delivery Location" ='' then
                  AutoDropPoint :='"true"'
                else begin
                  ServicePointIDGLS := ShipmentDocument."Ship-to Address 2";
                  ShipmentDocument."Address 2" :='';
                end;
             end;
           ShippingAgent."Shipping Method"::PDK:
             begin
                if ShipmentDocument."Delivery Location"<>'' then begin
                  ServicePointIDPDK := ShipmentDocument."Delivery Location";
                 end;
             end;
          end;
        end;
        //-NPR5.29 [248684]


         RequestURL := 'https://app.pakkelabels.dk/api/public/v2/shipments/shipment_own_customer_number';
         RequestString := '{';
         RequestString += StrSubstNo('"token":"%1",', Token);
         //-NPR5.29 [248684]
         //-290780 [290780]
         //RequestString += STRSUBSTNO('"shipping_agent":"%1",',LOWERCASE(FORMAT(ShippingAgent."Shipping Method")));
         RequestString += StrSubstNo('"shipping_agent":"%1",',LowerCase(Format(ShipmentDocument."Shipping Method Code")));
         //+290780 [290780]
         //+NPR5.29 [248684]
         RequestString += StrSubstNo('"weight":"%1",',Format(ShipmentDocument."Total Weight",0,1)); //from where to get
         RequestString += StrSubstNo('"receiver_name":"%1",',ShipmentDocument.Name);
         RequestString += StrSubstNo('"receiver_attention":"%1",',ShipmentDocument.Contact);
         RequestString += StrSubstNo('"receiver_address1":"%1",',ShipmentDocument.Address+' '+ShipmentDocument."Address 2");
        //-NPR5.29 [248684]
        if ServicePointIDGLS <>'' then
           RequestString += StrSubstNo('"receiver_address2":"%1",',ServicePointIDGLS);
        //+NPR5.29 [248684]
         RequestString += StrSubstNo('"receiver_zipcode":"%1",',ShipmentDocument."Post Code");
         RequestString += StrSubstNo('"receiver_city":"%1",',ShipmentDocument.City);
         RequestString += StrSubstNo('"receiver_country":"%1",',ShipmentDocument."Country/Region Code");
         RequestString += StrSubstNo('"receiver_email":"%1",',ShipmentDocument."E-Mail");
         RequestString += StrSubstNo('"receiver_mobile":"%1",',ShipmentDocument."SMS No.");
         RequestString += StrSubstNo('"sender_name":"%1",',CompanyInformation.Name);
         RequestString += StrSubstNo('"sender_address1":"%1",',CompanyInformation.Address);
         RequestString += StrSubstNo('"sender_zipcode":"%1",',CompanyInformation."Post Code");
         RequestString += StrSubstNo('"sender_city":"%1",',CompanyInformation.City);
         RequestString += StrSubstNo('"sender_country":"%1",',CompanyInformation."Country/Region Code");
         RequestString += StrSubstNo('"shipping_product_id":"%1",',ShipmentDocument."Shipping Agent Code");
         RequestString += StrSubstNo('"services":"%1",',ShipmentDocument."Shipping Agent Service Code");
         //-NPR5.29 [248684]
        if AutoDropPoint <>'' then
           RequestString += StrSubstNo('"auto_select_droppoint":"true",');
        //+NPR5.29 [248684]
         RequestString += StrSubstNo('"order_id":"%1",',ShipmentDocument."Order No.");
         RequestString += StrSubstNo('"reference":"%1",',ShipmentDocument.Reference);
         RequestString += StrSubstNo('"label_format":"a5",'); //a5 or 10x19 (default is a5   ??? //from where to get
         RequestString += StrSubstNo('"number_of_collis":"%1",',Format(ShipmentDocument."Parcel Qty."));
         //-NPR5.29 [248684]
        if ServicePointIDPDK <>'' then begin
           RequestString += StrSubstNo('"custom_delivery":"true",');
           RequestString += StrSubstNo('"service_point_id":"%1",',ServicePointIDPDK);
          end;
        //+NPR5.29 [248684]
        //-NPR5.34 [283061]
        if PackageProviderSetup."Use Pakkelable Printer API" then
          RequestString += StrSubstNo('"add_to_print_queue":"true",');
        //+NPR5.34 [283061]
        //-NPR5.45 [318441]
        if (PackageProviderSetup."Send Delivery Instructions") and (ShipmentDocument."Delivery Instructions" <> '') then
           RequestString += StrSubstNo('"delivery_instruction":"%1",',ShipmentDocument."Delivery Instructions");
        //+NPR5.45 [318441]
        //-NPR5.34 [283061]
        if PackageProviderSetup."Pakkelable Test Mode" then
          RequestString += '"test":"true"'
         else
         RequestString += '"test":"false"';
        //+NPR5.34 [283061]
        //-NPR5.45 [318441]
        //-NPR5.36 [290780]
        //IF (PackageProviderSetup."Send Delivery Instructions") AND (ShipmentDocument."Delivery Instructions" <> '') THEN
        //   RequestString += STRSUBSTNO('"delivery_instruction":"%1",',ShipmentDocument."Delivery Instructions");
        //+NPR5.36 [290780]
        //-NPR5.45 [318441]
         RequestString += '}';

        //-NPR5.29
        if not ExecuteCall('POST') then begin
        //-NPR5.34 [283061]
          GetExceptionMessage(Silent);
        //+NPR5.34 [283061]

        end;
        //-NPR5.29
        //-NPR5.34 [283061]
        if ErrorTextFound <>'' then
          exit;
        //+NPR5.34 [283061]
        ShipmentDocument."Response Shipment ID" := GetValue('shipment_id', ResponseString);
        ShipmentDocument."Response Package No." := GetValue('pkg_no', ResponseString);
        ShipmentDocument.Modify;
        //+NPR5.26 [248912]
        //-[NPR5.43] [304453]
        GetPDFByShipmentId(ShipmentDocument,Silent,LabelType::Post);
        //+[NPR5.43] [304453]
    end;

    procedure CreateReturnShipmentOwnCustomerNo(var ShipmentDocument: Record "Pacsoft Shipment Document";Silent: Boolean)
    var
        Token: Text;
        CompanyInformation: Record "Company Information";
        ShippingAgent: Record "Shipping Agent";
        Text00001: Label 'The document has already been sent to Pakkelabels.';
        LabelType: Option Post,Return;
    begin
        if not CompanyInformation.Get then exit;
        //-NPR5.34 [283061]
        //-[NPR5.43] [304453]
        if not ShipmentDocument."Print Return Label" then
          exit;
        if ShipmentDocument."Response Shipment ID" = '' then
            exit;
        //IF ShipmentDocument."Response Shipment ID"<>'' THEN BEGIN
        if ShipmentDocument."Return Response Shipment ID" <> '' then begin
        //+[NPR5.43] [304453]
          if Silent then
            ErrorTextFound := Text00001
          else
            Error(Text00001);
        end;

        Login(Token,Silent);
        if ErrorTextFound <>'' then
          exit;
        //+NPR5.34 [283061]

         RequestURL := 'https://app.pakkelabels.dk/api/public/v2/shipments/shipment_own_customer_number';
         RequestString := '{';
         RequestString += StrSubstNo('"token":"%1",', Token);
         RequestString += StrSubstNo('"shipping_agent":"%1",',LowerCase(ShipmentDocument."Shipping Method Code"));
         RequestString += StrSubstNo('"weight":"%1",',Format(ShipmentDocument."Total Weight",0,1)); //from where to get

         RequestString += StrSubstNo('"receiver_name":"%1",',CompanyInformation.Name);
         RequestString += StrSubstNo('"receiver_attention":"%1",',CompanyInformation.Name);
         RequestString += StrSubstNo('"receiver_address1":"%1",',CompanyInformation.Address);
         RequestString += StrSubstNo('"receiver_zipcode":"%1",',CompanyInformation."Post Code");
         RequestString += StrSubstNo('"receiver_city":"%1",',CompanyInformation.City);
         RequestString += StrSubstNo('"receiver_country":"%1",',CompanyInformation."Country/Region Code");
         RequestString += StrSubstNo('"receiver_email":"%1",',CompanyInformation."E-Mail");
         RequestString += StrSubstNo('"receiver_mobile":"%1",',CompanyInformation."Phone No.");

         RequestString += StrSubstNo('"sender_name":"%1",',ShipmentDocument.Name);
         RequestString += StrSubstNo('"sender_address1":"%1",',ShipmentDocument.Address+' '+ShipmentDocument."Address 2");
         RequestString += StrSubstNo('"sender_zipcode":"%1",',ShipmentDocument."Post Code");
         RequestString += StrSubstNo('"sender_city":"%1",',ShipmentDocument.City);
         RequestString += StrSubstNo('"sender_country":"%1",',ShipmentDocument."Country/Region Code");
         //-[NPR5.43] [304453]
         // RequestString += STRSUBSTNO('"shipping_product_id":"%1",',ShipmentDocument."Shipping Agent Code");
         RequestString += StrSubstNo('"shipping_product_id":"%1",',ShipmentDocument."Return Shipping Agent Code");
         //+[NPR5.43] [304453]
         RequestString += StrSubstNo('"order_id":"%1",',ShipmentDocument."Order No.");
         RequestString += StrSubstNo('"reference":"%1",',ShipmentDocument.Reference);
         RequestString += StrSubstNo('"label_format":"a5",'); //a5 or 10x19 (default is a5   ??? //from where to get
         RequestString += StrSubstNo('"number_of_collis":"%1",',Format(ShipmentDocument."Parcel Qty."));
        //-NPR5.34 [283061]
        if PackageProviderSetup."Use Pakkelable Printer API" then
          RequestString += StrSubstNo('"add_to_print_queue":"true",');
        //+NPR5.34 [283061]
         RequestString += '"test":"false"';
         RequestString += '}';
        //-NPR5.29
        if not ExecuteCall('POST') then begin
        //-NPR5.34 [283061]
          GetExceptionMessage(Silent);
        //+NPR5.34 [283061]

        end;
        //-NPR5.29

        //-NPR5.34 [283061]
        if ErrorTextFound <>'' then
          exit;
        //+NPR5.34 [283061]
        //-[NPR5.43] [304453]
        ShipmentDocument."Return Response Shipment ID" := GetValue('shipment_id', ResponseString);
        ShipmentDocument."Return Response Package No." := GetValue('pkg_no', ResponseString);
        //+[NPR5.43] [304453]
        ShipmentDocument.Modify;

        //+NPR5.26 [248912]

        //-[NPR5.43] [304453]
        GetPDFByShipmentId(ShipmentDocument,Silent,LabelType::Return);
        //+[NPR5.43] [304453]
    end;

    procedure GetShipmentByShipmentId(ShipmentDocument: Record "Pacsoft Shipment Document";Silent: Boolean)
    var
        ShipmentID: Code[10];
        Token: Text;
    begin
        //-NPR5.34 [283061]
        Login(Token,Silent);
        if ErrorTextFound <>'' then exit;
        //+NPR5.34 [283061]

        ShipmentID := ShipmentDocument."Response Shipment ID";
        RequestURL := StrSubstNo('https://app.pakkelabels.dk/api/public/v2/shipments/shipment?token=%1&id=%2', Token, ShipmentID);
        RequestString := '';

        //-NPR5.29
        if not ExecuteCall('GET') then begin
        //-NPR5.34 [283061]
          GetExceptionMessage(Silent);
        //+NPR5.34 [283061]
        end;
        //-NPR5.29

        Message(ResponseString);
    end;

    procedure GetPDFByShipmentId(var ShipmentDocument: Record "Pacsoft Shipment Document";Silent: Boolean;LabelType: Option Post,Return)
    var
        ShipmentID: Code[10];
        Base64Text: Text;
        TempFilePath: Text;
        TempFileName: Text;
        Token: Text;
        FileManagement: Codeunit "File Management";
        ClientFileName: Text;
    begin
        //-NPR5.34 [283061]
        if not InitPackageProvider then
          exit;
        if PackageProviderSetup."Use Pakkelable Printer API" then
          exit;
        //-290780 [290780]
        if PackageProviderSetup."Pakkelable Test Mode" then
          exit;
        //+290780 [290780]
        Login(Token,Silent);
        if ErrorTextFound <>'' then exit;
        //+NPR5.34 [283061]

        //-[NPR5.43] [304453]
        //ShipmentID := ShipmentDocument."Response Shipment ID";
        case LabelType  of
          LabelType::Post :
            ShipmentID := ShipmentDocument."Response Shipment ID";
          LabelType::Return:
            ShipmentID := ShipmentDocument."Return Response Shipment ID";
          end;
        //+[NPR5.43] [304453]
        RequestURL := StrSubstNo('https://app.pakkelabels.dk/api/public/v2/shipments/pdf?token=%1&id=%2', Token, ShipmentID);
        RequestString := '';

        //-NPR5.29
        if not ExecuteCall('GET') then begin
        //-NPR5.34 [283061]
          GetExceptionMessage(Silent);
        //+NPR5.34 [283061]
        end;
        //-NPR5.29
        //-NPR5.34 [283061]
        if ErrorTextFound <>'' then exit;
        //+NPR5.34 [283061]
        Base64Text := GetValue('base64', ResponseString);
        Bytes := ConvertBase64.FromBase64String(Base64Text);
        MemoryStream := MemoryStream.MemoryStream(Bytes);
        TempBlob.Blob.CreateOutStream(OStream);
        MemoryStream.WriteTo(OStream);

        TempFileName := StrSubstNo('pakkelabelsdk_%1.pdf', ShipmentID);
        TempFilePath := StrSubstNo('%1%2', TemporaryPath, TempFileName);
        TempBlob.Blob.Export(TempFilePath);

        //-NPR5.29 [248684]
        if CurrentClientType <> CLIENTTYPE::Windows then
          Download(TempFilePath,'Download label','','PDF file(*.pdf)|*.pdf',TempFileName) else
         begin
          ClientFileName:=FileManagement.ClientTempFileName('pdf');
          FileManagement.DownloadToFile(TempFilePath,ClientFileName);
          PrintAnyDocument(ClientFileName);
        end;
        //-NPR5.29 [248684]
        if FILE.Erase(TempFilePath) then;
    end;

    procedure GetShipmentsByOrderId(var ShipmentDocument: Record "Pacsoft Shipment Document";Silent: Boolean)
    var
        NAVOrderID: Code[20];
        Token: Text;
    begin
        //-NPR5.34 [283061]
        Login(Token,Silent);
        if ErrorTextFound <>'' then exit;
        //+NPR5.34 [283061]

        NAVOrderID := ShipmentDocument."Order No.";
        RequestURL := StrSubstNo('https://app.pakkelabels.dk/api/public/v2/shipments/shipments?token=%1&order_id=%2', Token, NAVOrderID);
        RequestString := '';

        //-NPR5.29
        if not ExecuteCall('GET') then begin
        //-NPR5.34 [283061]
          GetExceptionMessage(Silent);
        //+NPR5.34 [283061]
        end;
        //-NPR5.29

        Message(ResponseString);
    end;

    local procedure AddToPrintQueue(var ShipmentDocument: Record "Pacsoft Shipment Document";Silent: Boolean;LabelType: Option Post,Return)
    var
        ShipmentID: Code[10];
        Token: Text;
    begin
        //-NPR5.34 [283061]
        if not InitPackageProvider then
          exit;
        if not PackageProviderSetup."Use Pakkelable Printer API" then
          exit;

        Login(Token,Silent);
        if ErrorTextFound <>'' then exit;

        //-[NPR5.43] [304453]
        //ShipmentID := ShipmentDocument."Response Shipment ID";
        case LabelType  of
          LabelType::Post :
            ShipmentID := ShipmentDocument."Response Shipment ID";
          LabelType::Return:
            ShipmentID := ShipmentDocument."Return Response Shipment ID";
          end;
        //+[NPR5.43] [304453]


        RequestURL := 'https://app.pakkelabels.dk/api/public/v2/shipments/add_to_print_queue';
        RequestString := StrSubstNo('{"token":"%1","ids":"%2"}',Token,ShipmentID);

        if not ExecuteCall('POST') then
          GetExceptionMessage(Silent);
        //-NPR5.34 [283061]
    end;

    local procedure GetValue("Key": Text;Input: Text) Value: Text
    var
        KeyPos: Integer;
        KeyWithQuotes: Text;
        ColonPos: Integer;
        QuotePos: Integer;
        EndPos: Integer;
    begin
        //-NPR5.38 [290780]
        if StrPos(Input,'"[\') <> 0 then
          Input:=DelStr(Input,StrPos(Input,'"[\') ,3);
        //+NPR5.38 [290780]

        if Key = '' then
          exit('');
        KeyWithQuotes := StrSubstNo('"%1"', Key);
        KeyPos := StrPos(Input, KeyWithQuotes);
        Value := CopyStr(Input, KeyPos + StrLen(KeyWithQuotes));
        ColonPos := StrPos(Value, ':');
        Value:= CopyStr(Value, ColonPos + StrLen(':'));
        if CopyStr(Value,1,1) = '"' then begin
          Value := CopyStr(Value,2);
          QuotePos := StrPos(Value, '"');
          if QuotePos > 1 then
            Value := CopyStr(Value,1,QuotePos-1)
          else
            Value := '';
        end else begin
          //get the value until a comma or }
          EndPos := StrPos(Value, ',');
          if EndPos > 0 then begin
            Value := CopyStr(Value,1,EndPos-1)
          end else begin
            EndPos := StrPos(Value, '}');
            if EndPos > 0 then
              Value := CopyStr(Value,1,EndPos-1)
            else
              Value := '';
          end;
        end;
    end;

    [TryFunction]
    local procedure ExecuteCall(Method: Code[10])
    var
        HeaderTxt: Text;
    begin
        HttpWebRequest := HttpWebRequest.Create(RequestURL);
        HttpWebRequest.ContentType('application/json');
        HttpWebRequest.Accept('application/json');
        HttpWebRequest.Method(Method); //E.g. GET or POST

        if Method = 'POST' then begin
          ReqStream := HttpWebRequest.GetRequestStream;
          ReqStreamWriter := ReqStreamWriter.StreamWriter(ReqStream);
          ReqStreamWriter.Write(RequestString);
          ReqStreamWriter.Flush;
          ReqStreamWriter.Close;
          Clear(ReqStreamWriter);
          Clear(ReqStream);
        end;

        HttpWebResponse := HttpWebRequest.GetResponse;
        ResponseStream := HttpWebResponse.GetResponseStream;
        ResponseStreamReader := ResponseStreamReader.StreamReader(ResponseStream);
        ResponseString := ResponseStreamReader.ReadToEnd;
        if HttpWebResponse.StatusCode <> 200 then
          Error('%1 - %2 - %3',HttpWebResponse.StatusCode, HttpWebResponse.StatusDescription, ResponseString );
    end;

    local procedure GetExceptionMessage(Silent: Boolean)
    begin
        //-NPR5.34 [283061]
        DotNetExceptionHandler.Collect;

        if not DotNetExceptionHandler.CastToType(WebException,GetDotNetType(WebException)) then
          DotNetExceptionHandler.Rethrow;

        ResponseStream := WebException.Response.GetResponseStream;
        ResponseStreamReader := ResponseStreamReader.StreamReader(ResponseStream);
        ErrorText := ResponseStreamReader.ReadToEnd;
        if Silent then
          ErrorTextFound := GetValue('message', ErrorText)
        else
          Error(GetValue('message', ErrorText));
        //-NPR5.34 [283061]
    end;

    local procedure "==="()
    begin
    end;

    local procedure ValidateShipmentMethodCode(Rec: Record "Sales Header")
    var
        SalesLine: Record "Sales Line";
    begin
        if not InitPackageProvider then
          exit;
        if Rec."Shipment Method Code"='' then exit;

        if PackageProviderSetup."Default Weight" <=0 then exit;

        SalesLine.SetRange(SalesLine."Document Type",Rec."Document Type");
        SalesLine.SetRange("Document No.",Rec."No.");
        SalesLine.SetRange(Type,SalesLine.Type::Item);
        SalesLine.SetRange("Net Weight",0);
        SalesLine.ModifyAll("Net Weight",PackageProviderSetup."Default Weight");
    end;

    [EventSubscriber(ObjectType::Table, 36, 'OnAfterValidateEvent', 'Shipping Agent Service Code', false, false)]
    local procedure OnAfterModifyShippingAgentSerEventSalesHeader(var Rec: Record "Sales Header";var xRec: Record "Sales Header";CurrFieldNo: Integer)
    begin
        //-NPR5.34 [283061]
        if Rec.IsTemporary then
          exit;
        ValidateShipmentMethodCode(Rec);
        //-NPR5.34 [283061]
    end;

    [EventSubscriber(ObjectType::Table, 37, 'OnAfterValidateEvent', 'Quantity', false, false)]
    local procedure OnAfterModifyQtyEventSalesLine(var Rec: Record "Sales Line";var xRec: Record "Sales Line";CurrFieldNo: Integer)
    var
        SalesHeader: Record "Sales Header";
    begin
        //-NPR5.34 [283061]
        if Rec.IsTemporary then
          exit;

        if Rec.Quantity = 0 then
          exit;
        if not SalesHeader.Get(Rec."Document Type",Rec."Document No.") then
          exit;
        if SalesHeader."Shipment Method Code"='' then
          exit;
        if not InitPackageProvider then
          exit;

        if PackageProviderSetup."Default Weight" <=0 then exit;

        if Rec."Net Weight"= 0 then begin
         Rec."Net Weight":= PackageProviderSetup."Default Weight";
         Rec.Modify;
        end;
        //+NPR5.34 [283061]
    end;

    procedure PrintAnyDocument(FullPath: Text)
    var
        Err0001: Label 'Not able to print %1.\\ error : %2';
    begin
         if not TryPrintAnyDocument(FullPath) then
           Error(Err0001,FullPath,GetLastErrorText);
    end;

    [TryFunction]
    local procedure TryPrintAnyDocument(FullPath: Text)
    var
        [RunOnClient]
        ProcessStartInfo: DotNet npNetProcessStartInfo;
        [RunOnClient]
        Process: DotNet npNetProcess;
        [RunOnClient]
        ProcessWindowsStyle: DotNet npNetProcessWindowStyle;
    begin
        ProcessStartInfo := ProcessStartInfo.ProcessStartInfo(FullPath);
        with ProcessStartInfo do begin
          Verb := 'Print';
          CreateNoWindow := true;
          WindowStyle := ProcessWindowsStyle.Minimized;
        end;

        Process.Start(ProcessStartInfo);
    end;

    [EventSubscriber(ObjectType::Page, 6014574, 'GetPackageProvider', '', true, true)]
    local procedure IdentifyMe_GetPackageProvider(var Sender: Page "Pacsoft Setup";var tmpAllObjWithCaption: Record AllObjWithCaption temporary)
    var
        AllObjWithCaption: Record AllObjWithCaption;
    begin
        if tmpAllObjWithCaption.IsTemporary then begin
          AllObjWithCaption.Get(OBJECTTYPE::Codeunit, 6014490);
          tmpAllObjWithCaption.Init;
          tmpAllObjWithCaption."Object Type"  := AllObjWithCaption."Object Type" ;
          tmpAllObjWithCaption."Object ID" := AllObjWithCaption."Object ID";
          tmpAllObjWithCaption."Object Name" := AllObjWithCaption."Object Name";
          tmpAllObjWithCaption."Object Caption"  := AllObjWithCaption."Object Caption";
          tmpAllObjWithCaption.Insert;
        end;
    end;

    local procedure "--Codeunit 80 Sales-Post--"()
    begin
    end;

    [EventSubscriber(ObjectType::Codeunit, 80, 'OnBeforePostSalesDoc', '', true, false)]
    local procedure C80OnBeforePostSalesDoc(var SalesHeader: Record "Sales Header")
    var
        RetailCodeunitCode: Codeunit "Std. Codeunit Code";
        ShipmentDocument: Record "Pacsoft Shipment Document";
        RecRefSalesHeader: RecordRef;
    begin
        if not InitPackageProvider then
          exit;
        RecRefSalesHeader.GetTable(SalesHeader);
        TestFieldPakkelabels(RecRefSalesHeader);
    end;

    [EventSubscriber(ObjectType::Codeunit, 80, 'OnAfterPostSalesDoc', '', false, false)]
    local procedure C80OnAfterPostSalesDoc(var SalesHeader: Record "Sales Header";var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line";SalesShptHdrNo: Code[20];RetRcpHdrNo: Code[20];SalesInvHdrNo: Code[20];SalesCrMemoHdrNo: Code[20])
    var
        RecRef: RecordRef;
        SalesInvHeader: Record "Sales Invoice Header";
        SalesShptHeader: Record "Sales Shipment Header";
        SalesSetup: Record "Sales & Receivables Setup";
        ShipmentDocument: Record "Pacsoft Shipment Document";
        RecRefShipment: RecordRef;
        LastErrorText: Text;
    begin
        if not InitPackageProvider then
          exit;
        //-NPR5.51 [360780]
        asserterror begin
          if SalesHeader.Ship then
            if (SalesHeader."Document Type" = SalesHeader."Document Type"::Order) or
                ((SalesHeader."Document Type" = SalesHeader."Document Type"::Invoice) and SalesSetup."Shipment on Invoice") then
              if SalesShptHeader.Get(SalesShptHdrNo) then begin
                  RecRefShipment.GetTable(SalesShptHeader);
                  AddEntry(RecRefShipment,false,true);
                  //-NPR5.34 [283061]
                  if ErrorTextFound <> '' then
                    Message(Err0001,ErrorTextFound);
                  //+NPR5.34 [283061]
          end;
          Commit;
          Error('');
        end;
        LastErrorText := GetLastErrorText;
        if LastErrorText <> '' then
          Message(LastErrorText);
        //+NPR5.51 [360780]
    end;

    local procedure InitPackageProvider(): Boolean
    begin
        if not PackageProviderSetup.Get then
          exit(false);

        if PackageProviderSetup."Package Service Codeunit ID" = 0 then
          exit(false);
        if (PackageProviderSetup."Package Service Codeunit ID" <> CODEUNIT::"Pakkelabels.dk Mgnt") then
          exit(false);

        if (PackageProviderSetup."Api User" = '') or (PackageProviderSetup."Api Key" = '') then
         Error(Text0001);

        exit(true);
    end;

    procedure TestFieldPakkelabels(RecRef: RecordRef)
    var
        Customer: Record Customer;
        SalesLine: Record "Sales Line";
        ShippingAgentServices: Record "Shipping Agent Services";
        ShippingAgent: Record "Shipping Agent";
        ShiptoAddress: Record "Ship-to Address";
        SalesHeader: Record "Sales Header";
        SalesShipmentHeader: Record "Sales Shipment Header";
    begin
        case RecRef.Number of
          DATABASE::"Sales Header" :  begin
                                        RecRef.SetTable(SalesHeader);
                                        with SalesHeader do begin
                                          if ("Document Type" = SalesHeader."Document Type"::Invoice) or ("Document Type" = SalesHeader."Document Type"::Order) then begin

                                            if "Ship-to Country/Region Code"<>'DK' then
                                               exit;
                                            //-NPR5.34 [283061]
                                            if Kolli = 0 then
                                               exit;
                                            //+NPR5.34 [283061]
                                            SalesLine.SetRange("Document Type",SalesHeader."Document Type");
                                            SalesLine.SetRange("Document No.","No.");
                                            SalesLine.SetRange(Type, SalesLine.Type::Item);
                                            SalesLine.SetFilter("Net Weight",'<>0');
                                            if not SalesLine.FindFirst then
                                               exit;

                                            TestField("Shipment Method Code") ;
                                            TestField("Shipping Agent Code");
                                            //-[NPR5.43] [313475]
                                            ShippingAgent.Get("Shipping Agent Code");
                                            if ShippingAgent."Shipping Method" <> ShippingAgent."Shipping Method"::" " then
                                            //+[NPR5.43] [313475]
                                              TestField("Shipping Agent Service Code");


                                            ShippingAgentServices.Get("Shipping Agent Code","Shipping Agent Service Code");
                                            if SalesHeader."Ship-to Code" <> '' then begin
                                                //-282205 [282205]
                                                 ShiptoAddress.Get("Sell-to Customer No.","Ship-to Code");
                                                //+282205 [282205]
                                              if ShippingAgentServices."Phone Mandatory" then
                                                ShiptoAddress.TestField("Phone No.");

                                              if ShippingAgentServices."Email Mandatory" then
                                                ShiptoAddress.TestField("E-Mail");

                                            end else begin

                                              Customer.Get("Sell-to Customer No.");
                                              if ShippingAgentServices."Phone Mandatory" then
                                              Customer.TestField("Phone No.");

                                              if ShippingAgentServices."Email Mandatory" then
                                              Customer.TestField("E-Mail");
                                              end;

                                              TestField("Ship-to Name");
                                              TestField("Ship-to Address");
                                              TestField("Ship-to Post Code");
                                              TestField("Ship-to City");

                                              ShippingAgent.Get("Shipping Agent Code");
                                              if ShippingAgent."Ship to Contact Mandatory" then
                                                TestField("Ship-to Contact");
                                            end;
                                          end;
                                        end;
          DATABASE::"Sales Shipment Header" :  begin
                                             RecRef.SetTable(SalesShipmentHeader);
                                             with SalesShipmentHeader do begin

                                              //IF "Ship-to Country/Region Code"<>'DK' THEN EXIT;

                                              TestField("Shipment Method Code") ;
                                              TestField("Shipping Agent Code");
                                              //-[NPR5.43] [313475]
                                              ShippingAgent.Get("Shipping Agent Code");
                                              if ShippingAgent."Shipping Method" <> ShippingAgent."Shipping Method"::" " then
                                              //+[NPR5.43] [313475]
                                                TestField("Shipping Agent Service Code");

                                              ShippingAgentServices.Get("Shipping Agent Code","Shipping Agent Service Code");
                                              if SalesHeader."Ship-to Code" <> '' then begin
                                                //-282205 [282205]
                                                 ShiptoAddress.Get("Sell-to Customer No.","Ship-to Code");
                                                //+282205 [282205]
                                                if ShippingAgentServices."Phone Mandatory" then
                                                  ShiptoAddress.TestField("Phone No.");

                                                if ShippingAgentServices."Email Mandatory" then
                                                  ShiptoAddress.TestField("E-Mail");

                                              end else begin

                                                Customer.Get("Sell-to Customer No.");
                                                if ShippingAgentServices."Phone Mandatory" then
                                                Customer.TestField("Phone No.");

                                                if ShippingAgentServices."Email Mandatory" then
                                                Customer.TestField("E-Mail");
                                                end;

                                                TestField("Ship-to Name");
                                                TestField("Ship-to Address");
                                                TestField("Ship-to Post Code");
                                                TestField("Ship-to City");

                                                ShippingAgent.Get("Shipping Agent Code");
                                                if ShippingAgent."Ship to Contact Mandatory" then
                                                  TestField("Ship-to Contact");
                                              end;
                                            end;
        end;
    end;

    local procedure CheckNetWeight(SalesShipmentHeader: Record "Sales Shipment Header"): Boolean
    var
        SalesShipmentLine: Record "Sales Shipment Line";
    begin
        //-NPR5.34 [283061]
         SalesShipmentLine.SetRange("Document No.", SalesShipmentHeader."No.");
         SalesShipmentLine.SetFilter("Net Weight",'<>%1',0);
         exit(SalesShipmentLine.FindSet);
        //+NPR5.34 [283061]
    end;

    procedure AddEntry(RecRef: RecordRef;ShowWindow: Boolean;Silent: Boolean)
    var
        CompanyInfo: Record "Company Information";
        ShipmentDocument: Record "Pacsoft Shipment Document";
        ShipmentDocument2: Record "Pacsoft Shipment Document";
        ShipmentDocServices: Record "Pacsoft Shipment Doc. Services";
        CustomsItemRows: Record "Pacsoft Customs Item Rows";
        Customer: Record Customer;
        SalesShipmentHeader: Record "Sales Shipment Header";
        ShipToAddress: Record "Ship-to Address";
        ShippingAgentServices: Record "Shipping Agent Services";
        TextNotActivated: Label 'The Pacsoft integration is not activated.';
        CreateShipmentDocument: Page "Pacsoft Shipment Document";
        "//-PS1.01": Integer;
        ShippingAgentServicesCode: Code[10];
        "//+PS1.01": Integer;
        SalesShipmentLine: Record "Sales Shipment Line";
        DocFound: Boolean;
        ShippingAgent: Record "Shipping Agent";
        ReturnShippingAgent: Record "Shipping Agent";
    begin

        //-NPR5.29 [248684]

        ShipmentDocument.SetRange("Table No.",RecRef.Number);
        ShipmentDocument.SetRange(RecordID,RecRef.RecordId);
        if ShipmentDocument.FindLast then
          DocFound := true
        else begin
          Clear(ShipmentDocument);
          ShipmentDocument.Init;
          ShipmentDocument.Validate("Entry No.", 0);
          ShipmentDocument.Validate("Table No.",RecRef.Number);
          ShipmentDocument.Validate(RecordID, RecRef.RecordId);
          ShipmentDocument.Validate("Creation Time", CurrentDateTime);
        end;
        case RecRef.Number of

          DATABASE::"Sales Shipment Header" :  begin
                                                 RecRef.SetTable(SalesShipmentHeader);
                                                 if SalesShipmentHeader.Find then
                                                   with SalesShipmentHeader do begin

                                                     if SalesShipmentHeader."Shipment Method Code" = '' then exit;
                                                     //-NPR5.34 [283061]
                                                      if CheckNetWeight(SalesShipmentHeader) = false then exit;
                                                      if Kolli = 0 then exit;
                                                     //-NPR5.34 [283061]
                                                     if not DocFound then
                                                       ShipmentDocument.Insert(true);
                                                     Customer.Get("Sell-to Customer No.");
                                                     Clear(ShipToAddress);
                                                     //-283061 [283061]
                                                     if ShipToAddress.Get("Sell-to Customer No.", "Ship-to Code") then begin
                                                     //-283061 [283061]
                                                     //-NPR5.33 [282205]
                                                        ShipmentDocument."Ship-to Code" := "Ship-to Code";
                                                        ShipmentDocument."E-Mail" := ShipToAddress."E-Mail";
                                                        ShipmentDocument."SMS No." := ShipToAddress."Phone No.";
                                                        ShipmentDocument."Phone No." := ShipToAddress."Phone No.";
                                                        ShipmentDocument."Fax No." := ShipToAddress."Fax No.";
                                                     end else begin
                                                        ShipmentDocument."E-Mail" := Customer."E-Mail";
                                                        ShipmentDocument."SMS No." := Customer."Phone No.";
                                                        ShipmentDocument."Phone No." := Customer."Phone No.";
                                                        ShipmentDocument."Fax No." := Customer."Fax No.";
                                                    end;
                                                    //+NPR5.33 [282205]
                                                     //-NPR5.33 [282205]
                                                     ShipmentDocument."Receiver ID" := "Sell-to Customer No.";
                                                     //+NPR5.33 [282205]
                                                     ShipmentDocument.Name := "Ship-to Name";
                                                     ShipmentDocument.Address := "Ship-to Address";
                                                     ShipmentDocument."Address 2" := "Ship-to Address 2";
                                                     ShipmentDocument."Post Code" := "Ship-to Post Code";
                                                     ShipmentDocument.City := "Ship-to City";
                                                     ShipmentDocument.County := "Ship-to County";
                                                     ShipmentDocument."Country/Region Code" := "Ship-to Country/Region Code";
                                                     ShipmentDocument.Contact := "Ship-to Contact";
                                                     ShipmentDocument.Reference := "Your Reference";
                                                     ShipmentDocument."Shipment Date" := "Shipment Date";
                                                     ShipmentDocument."VAT Registration No." := Customer."VAT Registration No.";

                                                     ShipmentDocument."Shipping Method Code":= "Shipment Method Code";
                                                     ShipmentDocument."Shipping Agent Code" := "Shipping Agent Code";
                                                     ShipmentDocument."Shipping Agent Service Code" := "Shipping Agent Service Code";
                                                     ShipmentDocument."Parcel Qty." := SalesShipmentHeader.Kolli;
                                                     ShippingAgentServicesCode := "Shipping Agent Service Code";
                                                     if ShipmentDocument."Shipping Agent Service Code" = '' then begin
                                                       ShippingAgentServicesCode := "Shipping Agent Service Code";
                                                     end;
                                                     ShipmentDocument."Order No.":= SalesShipmentHeader."Order No.";
                                                    ShipmentDocument."Total Weight":=0;
                                                    SalesShipmentLine.SetRange("Document No.", SalesShipmentHeader."No.");
                                                    SalesShipmentLine.SetRange(Type, SalesShipmentLine.Type::Item);
                                                    SalesShipmentLine.SetFilter("Net Weight", '<>0');
                                                    if SalesShipmentLine.FindSet then
                                                      repeat
                                                        ShipmentDocument."Total Weight" += SalesShipmentLine."Net Weight" * SalesShipmentLine.Quantity;
                                                      until SalesShipmentLine.Next = 0;
                                                      //-NPR5.38 [290780]
                                                      //ShipmentDocument."Total Weight" := ROUND(ShipmentDocument."Total Weight",1,'>');
                                                      ShipmentDocument."Total Weight" := Round(ShipmentDocument."Total Weight",1,'>') * 1000;
                                                      //-NPR5.38 [290780]
                                                     if "Delivery Location" <> '' then begin
                                                       ShipmentDocument.Name := "Bill-to Name";
                                                       ShipmentDocument.Address := "Bill-to Address";
                                                       ShipmentDocument."Address 2" := "Bill-to Address 2";
                                                       ShipmentDocument."Post Code" := "Bill-to Post Code";
                                                       ShipmentDocument.City := "Bill-to City";
                                                       ShipmentDocument.County := "Bill-to County";
                                                       ShipmentDocument."Country/Region Code" := "Bill-to Country/Region Code";

                                                       ShipmentDocument."Delivery Location" := "Delivery Location";
                                                       ShipmentDocument."Ship-to Name" := "Ship-to Name";
                                                       ShipmentDocument."Ship-to Address" := "Ship-to Address";
                                                       ShipmentDocument."Ship-to Address 2" := "Ship-to Address 2";
                                                       ShipmentDocument."Ship-to Post Code" := "Ship-to Post Code";
                                                       ShipmentDocument."Ship-to City" := "Ship-to City";
                                                       ShipmentDocument."Ship-to County" := "Ship-to County";
                                                       ShipmentDocument."Ship-to Country/Region Code" := "Ship-to Country/Region Code";
                                                       ShipmentDocument.Contact := "Ship-to Contact";
                                                     end;

                                                     if PackageProviderSetup."Order No. to Reference" then
                                                       if "Order No." <> '' then
                                                         ShipmentDocument.Reference := CopyStr("Order No.", 1,
                                                                                               MaxStrLen(ShipmentDocument.Reference));
                                                    //-NPR5.34 [283061]
                                                    if (PackageProviderSetup."Order No. or Ext Doc No to ref") then begin
                                                      if SalesShipmentHeader."External Document No." <> '' then
                                                         ShipmentDocument.Reference := SalesShipmentHeader."External Document No."
                                                      else
                                                        ShipmentDocument.Reference := "Order No.";
                                                    end;
                                                    //+NPR5.34 [283061]
                                                    //-NPR5.36 [290780]
                                                    ShipmentDocument."External Document No." := SalesShipmentHeader."External Document No.";
                                                    ShipmentDocument."Delivery Instructions" := SalesShipmentHeader."Delivery Instructions";
                                                    ShipmentDocument."Your Reference":= SalesShipmentHeader."Your Reference";
                                                    //+NPR5.36 [290780]

                                                    //-[NPR5.43] [304453]
                                                    if PackageProviderSetup."Print Return Label" then begin
                                                      ShipmentDocument."Print Return Label" := PackageProviderSetup."Print Return Label";
                                                      ShippingAgent.Get("Shipping Agent Code");

                                                      ReturnShippingAgent.SetRange("Return Shipping agent",true);
                                                      ReturnShippingAgent.SetRange("Shipping Method",ShippingAgent."Shipping Method");
                                                      if ReturnShippingAgent.FindFirst then
                                                       ShipmentDocument."Return Shipping Agent Code" := ReturnShippingAgent.Code;
                                                    end;
                                                    //+[NPR5.43] [304453]


                                                   end;
                                               end;
                                            end;

        CompanyInfo.Get;
        ShipmentDocument."Sender VAT Reg. No" := CompanyInfo."VAT Registration No.";
        if ShipmentDocument."Country/Region Code" = '' then
          ShipmentDocument."Country/Region Code" := CompanyInfo."Country/Region Code";
        if ShipmentDocument."Shipment Date" < Today then
          ShipmentDocument."Shipment Date" := Today;

        ShipmentDocument.Modify(true);

        if ShipmentDocument."Shipping Agent Code" <> '' then begin
          Clear(ShippingAgentServices);
          ShippingAgentServices.SetCurrentKey("Shipping Agent Code");
          ShippingAgentServices.SetRange("Shipping Agent Code", ShipmentDocument."Shipping Agent Code");
          ShippingAgentServices.SetRange("Default Option", true);
          if ShippingAgentServices.FindSet then begin
            repeat
              Clear(ShipmentDocServices);
              ShipmentDocServices.Validate("Entry No.", ShipmentDocument."Entry No.");
              ShipmentDocServices.Validate("Shipping Agent Code", ShippingAgentServices."Shipping Agent Code");
              ShipmentDocServices.Validate("Shipping Agent Service Code", ShippingAgentServices.Code);
              if not DocFound then
               ShipmentDocServices.Insert(true);
            until ShippingAgentServices.Next = 0;
          //-PS1.01
          end
          else begin
            if (ShippingAgentServicesCode <> '' ) and (PackageProviderSetup."Create Shipping Services Line")  then begin
              Clear(ShippingAgentServices);
              ShippingAgentServices.SetCurrentKey("Shipping Agent Code");
              ShippingAgentServices.SetRange("Shipping Agent Code", ShipmentDocument."Shipping Agent Code");
              ShippingAgentServices.SetRange(Code,ShippingAgentServicesCode);
              ShippingAgentServices.SetRange("Default Option", false);
              if ShippingAgentServices.FindSet then
                repeat
                  Clear(ShipmentDocServices);
                  ShipmentDocServices.Validate("Entry No.", ShipmentDocument."Entry No.");
                  ShipmentDocServices.Validate("Shipping Agent Code", ShippingAgentServices."Shipping Agent Code");
                  ShipmentDocServices.Validate("Shipping Agent Service Code", ShippingAgentServices.Code);
                  if not DocFound then
                  ShipmentDocServices.Insert(true);
                until ShippingAgentServices.Next = 0;
            end;
          end;
          //+PS1.01
        end;
        Commit;
        //-NPR5.43 [314692]
        if PackageProviderSetup."Send Package Doc. Immediately" then begin
          if PackageProviderSetup."Skip Own Agreement" then
            CreateShipment(ShipmentDocument,Silent)
          else
           CreateShipmentOwnCustomerNo(ShipmentDocument,Silent);
        end;
        //+NPR5.43 [314692]

        //-[NPR5.43] [304453]
        if PackageProviderSetup."Print Return Label" then
          CreateReturnShipmentOwnCustomerNo(ShipmentDocument,Silent);
        //+[NPR5.43] [304453]

        //+NPR5.29 [248684]
    end;

    [EventSubscriber(ObjectType::Page, 6014440, 'OnAfterActionEvent', 'SendDocument', true, true)]
    local procedure P6014440OnAfterActionEventSendDoc(var Rec: Record "Pacsoft Shipment Document")
    begin
        //-NPR5.29 [248684]
        if not InitPackageProvider then
          exit;
        //-NPR5.43 [314692]
          if PackageProviderSetup."Skip Own Agreement" then
            CreateShipment(Rec,false)
          else
            CreateShipmentOwnCustomerNo(Rec,false);

            //+NPR5.43 [314692]



        //-NPR5.29 [248684]
        //-[NPR5.43] [304453]
        CreateReturnShipmentOwnCustomerNo(Rec,false);
        //+[NPR5.43] [304453]
    end;

    [EventSubscriber(ObjectType::Page, 130, 'OnAfterActionEvent', 'PrintShipmentDocument', true, true)]
    local procedure P130OnAfterActionEventCreatePackage(var Rec: Record "Sales Shipment Header")
    var
        RecRef: RecordRef;
        SalesInvHeader: Record "Sales Invoice Header";
        "NaviDocs Management": Codeunit "NaviDocs Management";
        SalesShptHeader: Record "Sales Shipment Header";
        SalesSetup: Record "Sales & Receivables Setup";
        ShipmentDocument: Record "Pacsoft Shipment Document";
        RecRefShipment: RecordRef;
        text000: Label 'Do you Want to create a Package entry ?';
        Text001: Label 'Do you want to print the Document?';
        LabelType: Option Post,Return;
    begin
        //-NPR5.29 [248684]
        if not InitPackageProvider then
          exit;

        RecRef.GetTable(Rec);
        ShipmentDocument.SetRange("Table No.",RecRef.Number);
        ShipmentDocument.SetRange(RecordID,RecRef.RecordId);
        if ShipmentDocument.FindLast then begin
           if Confirm(Text001,true) then

             if ShipmentDocument."Response Shipment ID" <> '' then begin
               //-[NPR5.43] [304453]
               GetPDFByShipmentId(ShipmentDocument,false,LabelType::Post);
               if ShipmentDocument."Return Response Shipment ID" <> '' then
                 GetPDFByShipmentId(ShipmentDocument,false,LabelType::Return);
               //+[NPR5.43] [304453]
             end else begin
               AddEntry(RecRef,false,false);
               //-NPR5.43 [314692]
                if PackageProviderSetup."Skip Own Agreement" then
                  CreateShipment(ShipmentDocument,false)
                else
                  CreateShipmentOwnCustomerNo(ShipmentDocument,false);
              //+NPR5.43 [314692]
              //-[NPR5.43] [304453]
              CreateReturnShipmentOwnCustomerNo(ShipmentDocument,false);
              //+[NPR5.43] [304453]
             end;
        end else begin
          RecRefShipment.GetTable(SalesShptHeader);
          TestFieldPakkelabels(RecRefShipment);
          if Confirm(text000,true) then
            AddEntry(RecRefShipment,false,false);
        end;
        //+NPR5.29 [248684]
    end;

    [EventSubscriber(ObjectType::Page, 6014440, 'OnAfterActionEvent', 'PrintDocument', false, false)]
    local procedure P6014440OnAfterActionEventPrintDocument(var Rec: Record "Pacsoft Shipment Document")
    var
        LabelType: Option Post,Return;
    begin
        //-NPR5.29 [248684]
        if not InitPackageProvider then
          exit;
        //-[NPR5.43] [304453]
        //GetPDFByShipmentId(Rec,FALSE);
        if Rec."Response Shipment ID" <> '' then
          GetPDFByShipmentId(Rec,false,LabelType::Post);
        if Rec."Return Response Shipment ID" <>'' then
          GetPDFByShipmentId(Rec,false,LabelType::Return);
        //-[NPR5.43] [304453]
        //+NPR5.29 [248684]
        //-NPR5.34 [283061]
        //-[NPR5.43] [304453]
        //AddToPrintQueue(Rec,FALSE);
        if Rec."Response Shipment ID" <> '' then
          AddToPrintQueue(Rec,false,LabelType::Post);

        if Rec."Return Response Shipment ID" <>'' then
        AddToPrintQueue(Rec,false,LabelType::Return);
        //+NPR5.34 [283061]
        //+[NPR5.43] [304453]
    end;

    local procedure TQSendPakkeLabel()
    var
        ShipmentDocument: Record "Pacsoft Shipment Document";
    begin
        //-NPR5.36 [290780]
        ShipmentDocument.SetFilter(ShipmentDocument."Shipping Method Code",'<>%1','');
        ShipmentDocument.SetFilter("Shipping Agent Code",'<>%1','');
        ShipmentDocument.SetFilter("Shipping Agent Service Code",'<>%1','');
        ShipmentDocument.SetFilter("Response Shipment ID",'');
        if ShipmentDocument.FindSet then repeat
          //-NPR5.43 [314692]
          if PackageProviderSetup."Skip Own Agreement" then
           CreateShipment(ShipmentDocument,true)
          else
            CreateShipmentOwnCustomerNo(ShipmentDocument,true);

            //+NPR5.43 [314692]

            //-[NPR5.43] [304453]
           CreateReturnShipmentOwnCustomerNo(ShipmentDocument,true);
        //+[NPR5.43] [304453]
        until ShipmentDocument.Next=0;
        //+NPR5.36 [290780]
    end;

    [EventSubscriber(ObjectType::Page, 6014574, 'OnAfterActionEvent', 'Test Connection', false, false)]
    local procedure TestConnection(var Rec: Record "Pacsoft Setup")
    var
        Token: Text;
    begin
        //-NPR5.36 [290780]
        Login(Token,false);
        Message(Text0002);
        //-NPR5.36 [290780]
    end;

    [EventSubscriber(ObjectType::Page, 6014574, 'OnAfterActionEvent', 'Check Balance', false, false)]
    local procedure CheckBalance(var Rec: Record "Pacsoft Setup")
    var
        Token: Text;
    begin
        //-NPR5.36 [290780]
        GetBalance(false);
        //-NPR5.36 [290780]
    end;

    [EventSubscriber(ObjectType::Table, 36, 'OnAfterModifyEvent', '', true, true)]
    local procedure T36OnAfterModifyEvent(var Rec: Record "Sales Header";var xRec: Record "Sales Header";RunTrigger: Boolean)
    var
        ForeignShipmentMapping: Record "Pakke Foreign Shipment Mapping";
    begin
        //-NPR5.51 [362106]
        if not RunTrigger then
          exit;
        if not InitPackageProvider then
          exit;
        if (Rec."Shipment Method Code" = '') or (Rec."Shipping Agent Code" = '') then
          exit;
        ForeignShipmentMapping.SetRange("Shipment Method Code",Rec."Shipment Method Code");
        ForeignShipmentMapping.SetRange("Base Shipping Agent Code",Rec."Shipping Agent Code");
        ForeignShipmentMapping.SetRange("Country/Region Code",Rec."Ship-to Country/Region Code");
        if ForeignShipmentMapping.FindFirst then begin
          Rec."Shipping Agent Code" := ForeignShipmentMapping."Shipping Agent Code";
          Rec."Shipping Agent Service Code" := ForeignShipmentMapping."Shipping Agent Service Code";
          Rec.Modify(true);
        end;
        //+NPR5.51 [362106]
    end;
}

