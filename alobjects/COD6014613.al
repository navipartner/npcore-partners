codeunit 6014613 "Tax Free GB I2"
{
    // NPR5.30/NPKNAV/20170310  CASE 261964 Transport NPR5.30 - 26 January 2017
    // 
    // Consumes Global Blue I2 solution, GRIPS MX API v16.06
    // 
    // test credentials:
    // Shop ID: 92179
    // Desk ID: 93585 //A4 voucher
    // Desk ID: 103661 //Thermal voucher
    // Username: TEST_SHOPID_92179
    // Password: TEST_SHOPID_92179
    // 
    // NPR5.40/MMV /20180112 CASE 293106 Refactored tax free module
    // NPR5.48/MMV /20181105 CASE 334588 Fixed mismatch in event subscriber signature
    // TM1.39/THRO/20181126 CASE 334644 Replaced Coudeunit 1 by Wrapper Codeunit
    // NPR5.49/MMV /20190327 CASE 293106 Fixed invalid page reference


    trigger OnRun()
    begin
    end;

    var
        Error_MissingPrintSetup: Label 'Missing object output setup';
        Error_MissingParameters: Label 'Missing parameters for handler %1 on tax free unit %2';
        Error_NotSupported: Label 'Operation is not supported by tax free handler %1';
        GlobalTaxFreeUnit: Record "Tax Free POS Unit";
        GlobalBlueParameters: Record "Tax Free GB I2 Parameter";
        GlobalBlueServices: Record "Tax Free GB I2 Service";
        Error_InvalidResponse: Label 'Invalid response received from tax free server for:\Handler: %1\Request: %2';
        Error_AutoConfigureFailure: Label 'Automatic desk configuration failed for handler %1. Cancelling tax free operation.';
        Error_Unknown: Label 'Unknown handler error. Could not retrieve error message from response.';
        Error_Ineligible: Label 'Sale is not eligible. VAT or issue date is outside the allowed range.';
        Error_ConsolidationEligible: Label 'Consolidation is not eligible. VAT or issue date is outside the allowed range.';
        Error_VoidLimit: Label 'Voucher %1 cannot be voided. The time limit has passed (%2 days).';
        Error_UserCancel: Label 'Operation was cancelled by user.';
        Error_PrintFail: Label 'Printing of tax free voucher %1 failed with error "%2".\NOTE: The voucher is correctly issued and active. Please attempt using ''Reprint Last'' or reissuing the voucher if the print error persists.';
        Error_MinimumParameters: Label 'Global Blue Shop ID, Desk ID, Username and Password must be specified before auto desk configure can be performed.';
        Caption_CancelOperation: Label 'Cancel tax free operation?';
        Caption_VoidConfirm: Label 'Are you sure you want to proceed with void of tax free voucher:\\%1: %2\%3: %4\%5: %6\\It will no longer be valid for tax free refund!';
        Caption_ReissueConfirm: Label 'Are you sure you want to proceed with reissue of tax free voucher:\\%1: %2\%3: %4\%5: %6\\Reissuing a tax free voucher voids the current voucher and issues a new one in its place.\The current voucher will no longer be valid for tax free refunding.\\Please proceed only if the customer is present in the store!';
        Caption_UseID: Label 'Does the customer have Global Blue Tax Free identification available?';
        Caption_GlobalBlueIdentifier: Label 'Global Blue Card:';
        Caption_InvalidIdentifier: Label 'Invalid identifier: %1. Global Blue card number must be at least 10 characters.';
        Caption_PassportDetected: Label 'Passport no. detected. Please select Passport Country.';
        Caption_ConfirmIdentity: Label 'I have checked the travellers identity and eligibility by verifying both passport AND country of residence.\\Traveller Name: %1\Passport Number: %2\Country Of Residence: %3';
        Caption_TravellerLookupFail: Label 'Identifier lookup failed.';
        Caption_PrefillCaptureWithNAVCustomer: Label 'Pre-fill tax free customer data with NAV customer data?';
        Caption_IdentifierType: Label 'Please select a Global Blue identifier type:';
        Caption_MemberCard: Label 'Global Blue Member Card';
        Caption_MobileNo: Label 'Mobile Phone No.';
        Caption_Passport: Label 'Passport Information';

    procedure HandlerID(): Text
    begin
        exit('GLOBALBLUE_I2')
    end;

    local procedure ServicePROD(): Text
    begin
        exit('https://tisshost3.globalblue.com');
    end;

    local procedure ServiceTEST(): Text
    begin
        exit('https://mspe4https.globalblue.com');
    end;

    procedure InitializeHandler(TaxFreeRequest: Record "Tax Free Request")
    var
        TaxFreeInterface: Codeunit "Tax Free Handler Mgt.";
    begin
        GlobalTaxFreeUnit.Get(TaxFreeRequest."POS Unit No.");

        GlobalBlueParameters.Get(TaxFreeRequest."POS Unit No.");
        if (GlobalBlueParameters."Date Last Auto Configured" < Today) then begin
            TaxFreeInterface.UnitAutoConfigure(GlobalTaxFreeUnit, true); //Will silently run desk config & verify that NAS jobs are configured.
            GlobalBlueParameters.Get(TaxFreeRequest."POS Unit No.");
            if GlobalBlueParameters."Date Last Auto Configured" <> Today then
                Error(Error_AutoConfigureFailure, TaxFreeRequest."Handler ID");
        end;

        GlobalBlueServices.SetRange("Tax Free Unit", TaxFreeRequest."POS Unit No.");
        GlobalBlueServices.FindSet;
    end;

    local procedure "--- Actions"()
    begin
    end;

    local procedure DownloadDeskConfiguration(var TaxFreeRequest: Record "Tax Free Request")
    var
        XMLDoc: DotNet npNetXmlDocument;
        IsError: Boolean;
        Value: Text;
        i: Integer;
        ServiceID: Integer;
        Services: DotNet npNetXmlNodeList;
        ServiceCount: Integer;
        Service: DotNet npNetXmlNode;
        ServiceIDFilterString: Text;
    begin
        if (GlobalBlueParameters."Shop ID" = '') or (GlobalBlueParameters."Desk ID" = '') or (GlobalBlueParameters.Username = '') or (GlobalBlueParameters.Password = '') then
            Error(Error_MinimumParameters);

        GetDeskConfiguration(TaxFreeRequest);
        HandleResponse(TaxFreeRequest, 'GetDeskConfiguration', XMLDoc, IsError);
        if IsError then
            Error(TaxFreeRequest."Error Message");

        if not TrySelectSingleNodeText(XMLDoc, '//ClientIdentification/ShopCountryCode', Value) then
            Error(Error_InvalidResponse, GlobalTaxFreeUnit."Handler ID", TaxFreeRequest."Request Type");
        Evaluate(GlobalBlueParameters."Shop Country Code", Value, 9);

        Services := XMLDoc.GetElementsByTagName('Service');
        ServiceCount := Services.Count;
        if not (ServiceCount > 0) then
            Error(Error_InvalidResponse, GlobalTaxFreeUnit."Handler ID", TaxFreeRequest."Request Type");

        for i := 0 to (ServiceCount - 1) do begin //Update or create service records
            Service := Services.ItemOf(i);

            if not TryGetItemInnerText(Service, 'ServiceID', Value) then
                Error(Error_InvalidResponse, GlobalTaxFreeUnit."Handler ID", TaxFreeRequest."Request Type");
            Evaluate(ServiceID, Value, 9);

            if not GlobalBlueServices.Get(GlobalTaxFreeUnit."POS Unit No.", ServiceID) then begin
                GlobalBlueServices.Init;
                GlobalBlueServices."Tax Free Unit" := GlobalTaxFreeUnit."POS Unit No.";
                GlobalBlueServices."Service ID" := ServiceID;
                GlobalBlueServices.Insert(true);
            end;

            if TryGetItemInnerText(Service, 'Name', Value) then
                GlobalBlueServices.Name := Value;
            if TryGetItemInnerText(Service, 'MinimumPurchaseAmount', Value) then
                Evaluate(GlobalBlueServices."Minimum Purchase Amount", Value, 9);
            if TryGetItemInnerText(Service, 'MaximumPurchaseAmount', Value) then
                Evaluate(GlobalBlueServices."Maximum Purchase Amount", Value, 9);
            if TryGetItemInnerText(Service, 'VoidLimitInDays', Value) then
                Evaluate(GlobalBlueServices."Void Limit In Days", Value, 9);

            GlobalBlueServices.Modify(true);
            if ServiceIDFilterString <> '' then
                ServiceIDFilterString += '&';
            ServiceIDFilterString += '<>' + Format(ServiceID);
        end;

        //Delete any old services that was not part of the latest auto configuration response
        GlobalBlueServices.Reset;
        GlobalBlueServices.SetRange("Tax Free Unit", GlobalTaxFreeUnit."POS Unit No.");
        GlobalBlueServices.SetFilter("Service ID", ServiceIDFilterString);
        GlobalBlueServices.DeleteAll();


        GlobalBlueParameters."Date Last Auto Configured" := Today;
        GlobalBlueParameters.Modify(true);
        Commit;

        GlobalBlueServices.Reset;
        GlobalBlueServices.SetRange("Tax Free Unit", GlobalTaxFreeUnit."POS Unit No.");
        GlobalBlueServices.FindSet;
    end;

    procedure DownloadCountries(var TaxFreeRequest: Record "Tax Free Request")
    var
        XMLDoc: DotNet npNetXmlDocument;
        IsError: Boolean;
        Countries: DotNet npNetXmlNodeList;
        CountryCount: Integer;
        i: Integer;
        Country: DotNet npNetXmlNode;
        GlobalBlueCountries: Record "Tax Free GB Country";
        Value: Text;
    begin
        GetCountries(TaxFreeRequest);
        HandleResponse(TaxFreeRequest, 'GetCountries', XMLDoc, IsError);
        if IsError then
            Error(TaxFreeRequest."Error Message");

        Countries := XMLDoc.GetElementsByTagName('Country');
        CountryCount := Countries.Count();
        if not (CountryCount > 0) then
            Error(Error_InvalidResponse, GlobalTaxFreeUnit."Handler ID", TaxFreeRequest."Request Type");

        GlobalBlueCountries.DeleteAll(false);
        for i := 0 to (CountryCount - 1) do begin
            Country := Countries.ItemOf(i);

            GlobalBlueCountries.Init;
            Evaluate(GlobalBlueCountries."Country Code", Country.Item('CountryCode').InnerText(), 9);
            GlobalBlueCountries.Name := Country.Item('Name').InnerText();
            if TryGetItemInnerText(Country, 'PhonePrefix', Value) then
                Evaluate(GlobalBlueCountries."Phone Prefix", Value, 9);
            if TryGetItemInnerText(Country, 'PassportCode', Value) then
                Evaluate(GlobalBlueCountries."Passport Code", Value, 9);
            GlobalBlueCountries.Insert(false);
        end;
        Commit;

        TaxFreeRequest.Success := true;
        TaxFreeRequest."Date End" := Today;
        TaxFreeRequest."Time End" := Time;
    end;

    procedure DownloadBlockedCountries(var TaxFreeRequest: Record "Tax Free Request")
    var
        XMLDoc: DotNet npNetXmlDocument;
        IsError: Boolean;
        Countries: DotNet npNetXmlNodeList;
        CountryCount: Integer;
        i: Integer;
        Country: DotNet npNetXmlNode;
        GlobalBlueBlockedCountries: Record "Tax Free GB Blocked Country";
    begin
        GetBlockedCountries(TaxFreeRequest);
        HandleResponse(TaxFreeRequest, 'GetBlockedCountries', XMLDoc, IsError);
        if IsError then
            Error(TaxFreeRequest."Error Message");

        Countries := XMLDoc.SelectNodes('//CountryCode');
        CountryCount := Countries.Count();
        if not (CountryCount > 0) then
            Error(Error_InvalidResponse, GlobalTaxFreeUnit."Handler ID", TaxFreeRequest."Request Type");

        GlobalBlueBlockedCountries.SetRange("Shop Country Code", GlobalBlueParameters."Shop Country Code");
        GlobalBlueBlockedCountries.DeleteAll(false);
        GlobalBlueBlockedCountries.Reset;
        for i := 0 to (CountryCount - 1) do begin
            Country := Countries.ItemOf(i);

            GlobalBlueBlockedCountries.Init;
            GlobalBlueBlockedCountries."Shop Country Code" := GlobalBlueParameters."Shop Country Code";
            Evaluate(GlobalBlueBlockedCountries."Country Code", Country.InnerText(), 9);
            GlobalBlueBlockedCountries.Insert(false);
        end;
        Commit;

        TaxFreeRequest.Success := true;
        TaxFreeRequest."Date End" := Today;
        TaxFreeRequest."Time End" := Time;
    end;

    procedure DownloadCondensedTred(var TaxFreeRequest: Record "Tax Free Request")
    var
        XMLDoc: DotNet npNetXmlDocument;
        IsError: Boolean;
        Ranges: DotNet npNetXmlNodeList;
        RangeCount: Integer;
        i: Integer;
        Range: DotNet npNetXmlNode;
        GlobalBlueIINBlacklist: Record "Tax Free GB IIN Blacklist";
    begin
        GetCondensedTred(TaxFreeRequest);
        HandleResponse(TaxFreeRequest, 'GetCondensedTred', XMLDoc, IsError);
        if IsError then
            Error(TaxFreeRequest."Error Message");

        Ranges := XMLDoc.GetElementsByTagName('Range');
        RangeCount := Ranges.Count();
        if not (RangeCount > 0) then
            Error(Error_InvalidResponse, GlobalTaxFreeUnit."Handler ID", TaxFreeRequest."Request Type");

        GlobalBlueIINBlacklist.SetRange("Shop Country Code", GlobalBlueParameters."Shop Country Code");
        GlobalBlueIINBlacklist.DeleteAll(false);
        GlobalBlueIINBlacklist.Reset;
        for i := 0 to (RangeCount - 1) do begin
            Range := Ranges.ItemOf(i);

            GlobalBlueIINBlacklist.Init;
            GlobalBlueIINBlacklist."Shop Country Code" := GlobalBlueParameters."Shop Country Code";
            Evaluate(GlobalBlueIINBlacklist."Range Inclusive Start", Range.Item('PrefixFrom').InnerText(), 9);
            Evaluate(GlobalBlueIINBlacklist."Range Exclusive End", Range.Item('PrefixTo').InnerText(), 9);
            GlobalBlueIINBlacklist.Insert(false);
        end;
        Commit;

        TaxFreeRequest.Success := true;
        TaxFreeRequest."Date End" := Today;
        TaxFreeRequest."Time End" := Time;
    end;

    local procedure IssueVoucher(var TaxFreeRequest: Record "Tax Free Request"; var tmpTaxFreeConsolidation: Record "Tax Free Consolidation" temporary; var tmpEligibleServices: Record "Tax Free GB I2 Service" temporary)
    var
        ServiceID: Text;
        CustomerXML: Text;
        PurchaseXML: Text;
        PaymentXML: Text;
        XMLDoc: DotNet npNetXmlDocument;
        IsError: Boolean;
        Value: Text;
        TempBlob: Codeunit "Temp Blob";
        RecRef: RecordRef;
    begin
        //tmpTaxFreeConsolidation carries the sales receipts/documents to be consolidated into one tax free voucher.
        //In a normal flow with a single sale, it only holds one record.

        TaxFreeRequest."Service ID" := SelectService(tmpEligibleServices); //Can have modal prompts
        CustomerXML := CaptureCustomerInfo(); //Has modal prompts
        PurchaseXML := GetPurchaseDetailsXML(tmpTaxFreeConsolidation);
        PaymentXML := GetPurchasePaymentMethodsXML(tmpTaxFreeConsolidation);

        IssueRenderedCheque(TaxFreeRequest, PurchaseXML, PaymentXML, CustomerXML);
        HandleResponse(TaxFreeRequest, 'IssueRenderedCheque', XMLDoc, IsError);
        if IsError then
            Error(TaxFreeRequest."Error Message");

        if not TrySelectSingleNodeText(XMLDoc, '//RenderedTFSFormRes/NumericDocIdentifier', Value) then
            Error(Error_InvalidResponse, TaxFreeRequest."Handler ID", TaxFreeRequest."Request Type");
        TaxFreeRequest."External Voucher No." := Value;
        TaxFreeRequest."External Voucher Barcode" := Value;

        if not TrySelectSingleNodeText(XMLDoc, '//RenderedTFSFormRes/TotalGrossAmount', Value) then
            Error(Error_InvalidResponse, TaxFreeRequest."Handler ID", TaxFreeRequest."Request Type");
        Evaluate(TaxFreeRequest."Total Amount Incl. VAT", Value, 9);

        if not TrySelectSingleNodeText(XMLDoc, '//RenderedTFSFormRes/TotalRefundAmount', Value) then
            Error(Error_InvalidResponse, TaxFreeRequest."Handler ID", TaxFreeRequest."Request Type");
        Evaluate(TaxFreeRequest."Refund Amount", Value, 9);

        if not TrySelectSingleNodeText(XMLDoc, '//RenderedTFSFormRes/@mimetype', Value) then
            Error(Error_InvalidResponse, TaxFreeRequest."Handler ID", TaxFreeRequest."Request Type");
        case true of
            Value = 'application/pdf':
                TaxFreeRequest."Print Type" := TaxFreeRequest."Print Type"::PDF;
            Value = 'text/plain':
                TaxFreeRequest."Print Type" := TaxFreeRequest."Print Type"::Thermal;
            else
                Error(Error_InvalidResponse, TaxFreeRequest."Handler ID", TaxFreeRequest."Request Type");
        end;

        if not TrySelectSingleNodeText(XMLDoc, '//RenderedTFSFormRes/BinaryData/Value', Value) then
            Error(Error_InvalidResponse, TaxFreeRequest."Handler ID", TaxFreeRequest."Request Type");
        Base64ToBlob(Value, TempBlob);

        RecRef.GetTable(TaxFreeRequest);
        TempBlob.ToRecordRef(RecRef, TaxFreeRequest.FieldNo(Print));
        RecRef.SetTable(TaxFreeRequest);
    end;

    local procedure ReissueVoucher(var TaxFreeRequest: Record "Tax Free Request"; TaxFreeVoucher: Record "Tax Free Voucher")
    var
        VoucherService: Record "Tax Free GB I2 Service";
        XMLDoc: DotNet npNetXmlDocument;
        IsError: Boolean;
        Value: Text;
        TempBlob: Codeunit "Temp Blob";
        RecRef: RecordRef;
    begin
        if VoucherService.Get(TaxFreeVoucher."POS Unit No.", TaxFreeVoucher."Service ID") then
            if VoucherService."Void Limit In Days" <> 0 then
                if CalcDate(StrSubstNo('<%1D>', VoucherService."Void Limit In Days"), TaxFreeVoucher."Issued Date") < Today then
                    Error(Error_VoidLimit, TaxFreeVoucher."External Voucher No.", VoucherService."Void Limit In Days");

        if not Confirm(
          Caption_ReissueConfirm,
          false,
          TaxFreeVoucher.FieldCaption("External Voucher No."),
          TaxFreeVoucher."External Voucher No.",
          TaxFreeVoucher.FieldCaption("Issued Date"),
          TaxFreeVoucher."Issued Date",
          TaxFreeVoucher.FieldCaption("Total Amount Incl. VAT"),
          TaxFreeVoucher."Total Amount Incl. VAT") then
            Error(Error_UserCancel);

        TaxFreeRequest."Service ID" := TaxFreeVoucher."Service ID"; //Reuse service ID.
        ReissueRenderedCheque(TaxFreeRequest, TaxFreeVoucher."External Voucher No.", Format(TaxFreeVoucher."Total Amount Incl. VAT", 0, 9));
        HandleResponse(TaxFreeRequest, 'ReissueRenderedCheque', XMLDoc, IsError);
        if IsError then
            Error(TaxFreeRequest."Error Message");

        if not TrySelectSingleNodeText(XMLDoc, '//RenderedTFSFormRes/NumericDocIdentifier', Value) then
            Error(Error_InvalidResponse, TaxFreeRequest."Handler ID", TaxFreeRequest."Request Type");
        TaxFreeRequest."External Voucher No." := Value;
        TaxFreeRequest."External Voucher Barcode" := Value;

        if not TrySelectSingleNodeText(XMLDoc, '//RenderedTFSFormRes/TotalGrossAmount', Value) then
            Error(Error_InvalidResponse, TaxFreeRequest."Handler ID", TaxFreeRequest."Request Type");
        Evaluate(TaxFreeRequest."Total Amount Incl. VAT", Value, 9);

        if not TrySelectSingleNodeText(XMLDoc, '//RenderedTFSFormRes/TotalRefundAmount', Value) then
            Error(Error_InvalidResponse, TaxFreeRequest."Handler ID", TaxFreeRequest."Request Type");
        Evaluate(TaxFreeRequest."Refund Amount", Value, 9);

        if not TrySelectSingleNodeText(XMLDoc, '//RenderedTFSFormRes/@mimetype', Value) then
            Error(Error_InvalidResponse, TaxFreeRequest."Handler ID", TaxFreeRequest."Request Type");
        case true of
            Value = 'application/pdf':
                TaxFreeRequest."Print Type" := TaxFreeRequest."Print Type"::PDF;
            Value = 'text/plain':
                TaxFreeRequest."Print Type" := TaxFreeRequest."Print Type"::Thermal;
            else
                Error(Error_InvalidResponse, TaxFreeRequest."Handler ID", TaxFreeRequest."Request Type");
        end;

        if not TrySelectSingleNodeText(XMLDoc, '//RenderedTFSFormRes/BinaryData/Value', Value) then
            Error(Error_InvalidResponse, TaxFreeRequest."Handler ID", TaxFreeRequest."Request Type");
        Base64ToBlob(Value, TempBlob);

        RecRef.GetTable(TaxFreeRequest);
        TempBlob.ToRecordRef(RecRef, TaxFreeRequest.FieldNo(Print));
        RecRef.SetTable(TaxFreeRequest);
    end;

    local procedure VoidVoucher(var TaxFreeRequest: Record "Tax Free Request"; TaxFreeVoucher: Record "Tax Free Voucher")
    var
        VoucherService: Record "Tax Free GB I2 Service";
        XMLDoc: DotNet npNetXmlDocument;
        IsError: Boolean;
    begin
        if VoucherService.Get(TaxFreeVoucher."POS Unit No.", TaxFreeVoucher."Service ID") then
            if VoucherService."Void Limit In Days" <> 0 then
                if CalcDate(StrSubstNo('<%1D>', VoucherService."Void Limit In Days"), TaxFreeVoucher."Issued Date") < Today then
                    Error(Error_VoidLimit, TaxFreeVoucher."External Voucher No.", VoucherService."Void Limit In Days");

        if not Confirm(
          Caption_VoidConfirm,
          false,
          TaxFreeVoucher.FieldCaption("External Voucher No."),
          TaxFreeVoucher."External Voucher No.",
          TaxFreeVoucher.FieldCaption("Issued Date"),
          TaxFreeVoucher."Issued Date",
          TaxFreeVoucher.FieldCaption("Total Amount Incl. VAT"),
          TaxFreeVoucher."Total Amount Incl. VAT") then
            Error(Error_UserCancel);

        VoidCheque(TaxFreeRequest, TaxFreeVoucher."External Voucher No.", Format(TaxFreeVoucher."Total Amount Incl. VAT", 0, 9));
        HandleResponse(TaxFreeRequest, 'VoidCheque', XMLDoc, IsError);
        if IsError then
            Error(TaxFreeRequest."Error Message");
    end;

    local procedure CheckIIN(IIN: Text): Boolean
    var
        GlobalBlueIINBlacklist: Record "Tax Free GB IIN Blacklist";
        IINInteger: Integer;
    begin
        if StrLen(IIN) < 6 then
            exit(false);

        IIN := CopyStr(IIN, 1, 6);
        if not Evaluate(IINInteger, IIN) then
            exit(false);

        if GlobalBlueIINBlacklist.IsEmpty then
            exit(false);

        GlobalBlueIINBlacklist.SetRange("Shop Country Code", GlobalBlueParameters."Shop Country Code");
        GlobalBlueIINBlacklist.SetFilter("Range Inclusive Start", '<=%1', IINInteger);
        GlobalBlueIINBlacklist.SetFilter("Range Exclusive End", '>%1', IINInteger);

        exit(GlobalBlueIINBlacklist.IsEmpty);
    end;

    [TryFunction]
    local procedure TryLookupTraveller(var tmpCustomerInfoCapture: Record "Tax Free GB I2 Info Capture" temporary)
    var
        TaxFreeRequest: Record "Tax Free Request";
        IsError: Boolean;
        XMLDoc: DotNet npNetXmlDocument;
        Value: Text;
        DateTime: DateTime;
    begin
        TaxFreeRequest.Init;
        TaxFreeRequest."Request Type" := 'LOOKUP_TRAVELLER';
        TaxFreeRequest.Mode := GlobalTaxFreeUnit.Mode;
        TaxFreeRequest."Timeout (ms)" := GlobalTaxFreeUnit."Request Timeout (ms)";
        TaxFreeRequest."Time Start" := Time;
        TaxFreeRequest."Date Start" := Today;

        GetTraveller(TaxFreeRequest, tmpCustomerInfoCapture);
        HandleResponse(TaxFreeRequest, 'GetTraveller', XMLDoc, IsError);
        if IsError then
            Error(TaxFreeRequest."Error Message");

        //Necessary data for UI confirm
        if not TrySelectSingleNodeText(XMLDoc, '//TravellerRes/FirstName', Value) then
            Error(Error_InvalidResponse, TaxFreeRequest."Handler ID", TaxFreeRequest."Request Type");
        tmpCustomerInfoCapture."First Name" := Value;

        if not TrySelectSingleNodeText(XMLDoc, '//TravellerRes/LastName', Value) then
            Error(Error_InvalidResponse, TaxFreeRequest."Handler ID", TaxFreeRequest."Request Type");
        tmpCustomerInfoCapture."Last Name" := Value;

        if not TrySelectSingleNodeText(XMLDoc, '//TravellerRes/Passport/PassportNumber', Value) then
            Error(Error_InvalidResponse, TaxFreeRequest."Handler ID", TaxFreeRequest."Request Type");
        tmpCustomerInfoCapture."Passport Number" := Value;

        if not TrySelectSingleNodeText(XMLDoc, '//TravellerRes/Address/CountryCode', Value) then
            Error(Error_InvalidResponse, TaxFreeRequest."Handler ID", TaxFreeRequest."Request Type");
        Evaluate(tmpCustomerInfoCapture."Country Of Residence Code", Value, 9);

        if not TrySelectSingleNodeText(XMLDoc, '//TravellerRes/Address/CountryName', Value) then
            Error(Error_InvalidResponse, TaxFreeRequest."Handler ID", TaxFreeRequest."Request Type");
        tmpCustomerInfoCapture."Country Of Residence" := Value;

        //Non-essential data:
        if TrySelectSingleNodeText(XMLDoc, '//TravellerRes/Address/Street', Value) then
            tmpCustomerInfoCapture.Street := Value;

        if TrySelectSingleNodeText(XMLDoc, '//TravellerRes/Address/PostalCode', Value) then
            tmpCustomerInfoCapture."Postal Code" := Value;

        if TrySelectSingleNodeText(XMLDoc, '//TravellerRes/Address/Town', Value) then
            tmpCustomerInfoCapture.Town := Value;

        if TrySelectSingleNodeText(XMLDoc, '//TravellerRes/Email', Value) then
            tmpCustomerInfoCapture."E-mail" := Value;

        if TrySelectSingleNodeText(XMLDoc, '//TravellerRes/MobileNumber', Value) then
            tmpCustomerInfoCapture."Mobile No." := Value;

        if TrySelectSingleNodeText(XMLDoc, '//TravellerRes/TravelDetails/DepartureDate', Value) then
            Evaluate(tmpCustomerInfoCapture."Departure Date", Value, 9);

        if TrySelectSingleNodeText(XMLDoc, '//TravellerRes/TravelDetails/ArrivalDate', Value) then
            Evaluate(tmpCustomerInfoCapture."Arrival Date", Value, 9);

        if TrySelectSingleNodeText(XMLDoc, '//TravellerRes/TravelDetails/FinalDestinationCountryCode', Value) then
            Evaluate(tmpCustomerInfoCapture."Final Destination Country Code", Value, 9);

        if TrySelectSingleNodeText(XMLDoc, '//TravellerRes/TravelDetails/FinalDestinationCountryName', Value) then
            tmpCustomerInfoCapture."Final Destination Country" := Value;

        if TrySelectSingleNodeText(XMLDoc, '//TravellerRes/Passport/PassportCountryCode', Value) then
            Evaluate(tmpCustomerInfoCapture."Passport Country Code", Value, 9);

        if TrySelectSingleNodeText(XMLDoc, '//TravellerRes/Passport/PassportCountryName', Value) then
            tmpCustomerInfoCapture."Passport Country" := Value;

        if TrySelectSingleNodeText(XMLDoc, '//TravellerRes/DateOfBirth', Value) then
            Evaluate(tmpCustomerInfoCapture."Date Of Birth", CopyStr(Value, 1, StrPos(Value, 'T') - 1), 9);

        TaxFreeRequest.Success := true;
        TaxFreeRequest."Date End" := Today;
        TaxFreeRequest."Time End" := Time;
    end;

    local procedure "--- Print Functions"()
    begin
    end;

    [TryFunction]
    local procedure TryPrintVoucher(TaxFreeRequest: Record "Tax Free Request")
    begin
        case TaxFreeRequest."Print Type" of
            TaxFreeRequest."Print Type"::Thermal:
                PrintThermal(TaxFreeRequest);
            TaxFreeRequest."Print Type"::PDF:
                PrintPDF(TaxFreeRequest);
        end;
    end;

    local procedure PrintThermal(TaxFreeRequest: Record "Tax Free Request")
    var
        ObjectOutputMgt: Codeunit "Object Output Mgt.";
        Output: Text;
        Printer: Codeunit "RP Line Print Mgt.";
        InStream: InStream;
        Line: Text;
    begin
        Output := ObjectOutputMgt.GetCodeunitOutputPath(CODEUNIT::"Report - Tax Free Receipt");
        if Output = '' then
            Error(Error_MissingPrintSetup);

        Printer.SetThreeColumnDistribution(0.33, 0.33, 0.33);
        Printer.SetAutoLineBreak(false);

        TaxFreeRequest.Print.CreateInStream(InStream, TEXTENCODING::UTF8);
        while (not InStream.EOS) do begin
            InStream.ReadText(Line);
            PrintThermalLine(Printer, Line);
        end;

        PrintThermalLine(Printer, '<TearOff>'); //A final cut is not included in the printjob from I2 server.

        Printer.ProcessBufferForCodeunit(CODEUNIT::"Report - Tax Free Receipt", ''); //Use the object output selection of old object so no new setup is needed.
    end;

    local procedure PrintThermalLine(var Printer: Codeunit "RP Line Print Mgt."; Line: Text)
    var
        Center: Boolean;
        Inverse: Boolean;
        HFont: Boolean;
        Bold: Boolean;
        Barcode: Boolean;
        Img: Boolean;
        TearOff: Boolean;
        ShopCopy: Boolean;
        Value: Text;
        String: DotNet npNetString;
        StringUpper: DotNet npNetString;
    begin
        String := Line;
        StringUpper := UpperCase(Line);

        if StringUpper.Contains('<BC>') then begin
            String := String.Replace('<BC>', '');
            String := String.Replace('</BC>', '');
            String := String.Replace('<bc>', '');
            String := String.Replace('</bc>', '');
            Value := String;
            Printer.AddBarcode('ITF', Value, 2);
            exit;
        end;

        if StringUpper.Contains('<IMG>') then begin
            Printer.SetFont('Logo');
            Printer.AddLine('TAXFREE');
            exit;
        end;

        if StringUpper.Contains('<TEAROFF>') or StringUpper.Contains('<TEAROFF/>') then begin
            Printer.SetFont('Control');
            Printer.AddLine('P');
            exit;
        end;

        if StringUpper.Contains('<CENTER>') or StringUpper.Contains('<C>') then begin
            String := String.Replace('<CENTER>', '');
            String := String.Replace('</CENTER>', '');
            String := String.Replace('<C>', '');
            String := String.Replace('</C>', '');
            String := String.Replace('<center>', '');
            String := String.Replace('</center>', '');
            String := String.Replace('<c>', '');
            String := String.Replace('</c>', '');
            Center := true;
        end;

        if StringUpper.Contains('<INVERSE>') or StringUpper.Contains('<I>') then begin
            String := String.Replace('<INVERSE>', '');
            String := String.Replace('</INVERSE>', '');
            String := String.Replace('<I>', '');
            String := String.Replace('</I>', '');
            String := String.Replace('<inverse>', '');
            String := String.Replace('</inverse>', '');
            String := String.Replace('<i>', '');
            String := String.Replace('</i>', '');
            Inverse := true;
        end;

        if StringUpper.Contains('<HFONT>') or StringUpper.Contains('<H>') then begin
            String := String.Replace('<HFONT>', '');
            String := String.Replace('</HFONT>', '');
            String := String.Replace('<H>', '');
            String := String.Replace('</H>', '');
            String := String.Replace('<hfont>', '');
            String := String.Replace('</hfont>', '');
            String := String.Replace('<h>', '');
            String := String.Replace('</h>', '');
            HFont := true;
        end;

        if StringUpper.Contains('<BOLD>') or StringUpper.Contains('<B>') then begin
            String := String.Replace('<BOLD>', '');
            String := String.Replace('</BOLD>', '');
            String := String.Replace('<B>', '');
            String := String.Replace('</B>', '');
            String := String.Replace('<bold>', '');
            String := String.Replace('</bold>', '');
            String := String.Replace('<b>', '');
            String := String.Replace('</b>', '');
            Bold := true;
        end;

        Line := String;

        Printer.SetBold(Bold or Inverse);
        Printer.SetUnderLine(Inverse); //As per agreement inverse will not actually be inverted colors. It will be highlighted via other means.
        if HFont then
            Printer.SetFont('B21')
        else
            Printer.SetFont('A11');

        if Line = '' then
            Line := ' ';

        while (Line <> '') do begin
            if Center then
                Printer.AddTextField(2, 1, CopyStr(Line, 1, 42))
            else
                Printer.AddTextField(1, 0, CopyStr(Line, 1, 42));
            Line := CopyStr(Line, 43);
            Printer.NewLine();
        end;
    end;

    local procedure PrintPDF(TaxFreeRequest: Record "Tax Free Request")
    var
        MemoryStream: DotNet npNetMemoryStream;
        InStream: InStream;
        ObjectOutputMgt: Codeunit "Object Output Mgt.";
        Output: Text;
        OutputType: Integer;
        PrintMethodMgt: Codeunit "Print Method Mgt.";
        ObjectOutputSelection: Record "Object Output Selection";
    begin
        MemoryStream := MemoryStream.MemoryStream();
        TaxFreeRequest.Print.CreateInStream(InStream);
        CopyStream(MemoryStream, InStream);

        Output := ObjectOutputMgt.GetCodeunitOutputPath(CODEUNIT::"Report - Tax Free Receipt");
        OutputType := ObjectOutputMgt.GetCodeunitOutputType(CODEUNIT::"Report - Tax Free Receipt");

        if Output = '' then
            Error(Error_MissingPrintSetup);

        case OutputType of
            ObjectOutputSelection."Output Type"::"Google Print":
                PrintMethodMgt.PrintViaGoogleCloud(Output, MemoryStream, 'application/pdf', 1, CODEUNIT::"Report - Tax Free Receipt");
            ObjectOutputSelection."Output Type"::"E-mail":
                PrintMethodMgt.PrintViaEmail(Output, MemoryStream);
            ObjectOutputSelection."Output Type"::"Printer Name":
                PrintMethodMgt.PrintFileLocal(Output, MemoryStream, 'pdf');
        end;
    end;

    local procedure Base64ToBlob(base64: Text; var TempBlobOut: Codeunit "Temp Blob")
    var
        OutStream: OutStream;
        MemoryStream: DotNet npNetMemoryStream;
        Convert: DotNet npNetConvert;
    begin
        MemoryStream := MemoryStream.MemoryStream(Convert.FromBase64String(base64));

        TempBlobOut.CreateOutStream(OutStream);
        CopyStream(OutStream, MemoryStream);
    end;

    local procedure "--- API Functions"()
    begin
    end;

    local procedure GetDeskConfiguration(var TaxFreeRequest: Record "Tax Free Request")
    var
        Request: Text;
    begin
        Request :=
        '<?xml version="1.0" encoding="UTF-8"?>' +
        '<GripsMXRequest xmlns="https://dev.global-blue.com/gripsmx/xsd/v16_06">' +
          '<Header>' +
            '<Operation>GetDeskConfiguration</Operation>' +
            '<TransmissionDate>' + FormattedDateTime() + '</TransmissionDate>' +
            '<Sender>' +
              '<SenderID>' + SenderID() + '</SenderID>' +
              '<Version>' + POSVersion() + '</Version>' +
              '<SenderSpecificData>' +
                '<parameter name="UserName" value="' + GlobalBlueParameters.Username + '"/>' +
                '<parameter name="Password" value="' + GlobalBlueParameters.Password + '"/>' +
              '</SenderSpecificData>' +
            '</Sender>' +
          '</Header>' +
          '<Message>' +
            '<DeskConfigurationReq>' +
              '<ShopIdentification>' +
                '<ShopID>' + GlobalBlueParameters."Shop ID" + '</ShopID>' +
                '<DeskID>' + GlobalBlueParameters."Desk ID" + '</DeskID>' +
              '</ShopIdentification>' +
            '</DeskConfigurationReq>' +
          '</Message>' +
        '</GripsMXRequest>';

        InvokeService(Request, TaxFreeRequest);
    end;

    local procedure GetTraveller(var TaxFreeRequest: Record "Tax Free Request"; var tmpCustomerInfoCapture: Record "Tax Free GB I2 Info Capture" temporary)
    var
        Request: Text;
    begin
        Request :=
        '<?xml version="1.0" encoding="UTF-8"?>' +
        '<GripsMXRequest xmlns="https://dev.global-blue.com/gripsmx/xsd/v16_06">' +
          '<Header>' +
            '<Operation>GetTraveller</Operation>' +
            '<TransmissionDate>' + FormattedDateTime() + '</TransmissionDate>' +
            '<Sender>' +
              '<SenderID>' + SenderID() + '</SenderID>' +
              '<Version>' + POSVersion() + '</Version>' +
              '<SenderSpecificData>' +
                '<parameter name="UserName" value="' + GlobalBlueParameters.Username + '"/>' +
                '<parameter name="Password" value="' + GlobalBlueParameters.Password + '"/>' +
              '</SenderSpecificData>' +
            '</Sender>' +
          '</Header>' +
          '<Message>' +
            '<TravellerReq>' +
              '<ShopInfo>' +
                '<ShopIdentification>' +
                  '<ShopID>' + GlobalBlueParameters."Shop ID" + '</ShopID>' +
                  '<DeskID>' + GlobalBlueParameters."Desk ID" + '</DeskID>' +
                '</ShopIdentification>' +
                '<ShopCountryCode>' + Format(GlobalBlueParameters."Shop Country Code") + '</ShopCountryCode>' +
              '</ShopInfo>' +
              '<TravellerIdentifier>' +
                '<IdentifierLookupValue>' + tmpCustomerInfoCapture."Global Blue Identifier" + '</IdentifierLookupValue>' +
              '</TravellerIdentifier>' +
            '</TravellerReq>' +
          '</Message>' +
        '</GripsMXRequest>';

        InvokeService(Request, TaxFreeRequest);
    end;

    local procedure IssueRenderedCheque(var TaxFreeRequest: Record "Tax Free Request"; PurchaseDetailsXML: Text; PaymentMethodsXML: Text; TravellerInfoXML: Text)
    var
        Request: Text;
    begin
        Request :=
        '<?xml version="1.0" encoding="UTF-8"?>' +
        '<GripsMXRequest xmlns="https://dev.global-blue.com/gripsmx/xsd/v16_06">' +
          '<Header>' +
            '<Operation>IssueRenderedCheque</Operation>' +
            '<TransmissionDate>' + FormattedDateTime() + '</TransmissionDate>' +
            '<Sender>' +
              '<SenderID>' + SenderID() + '</SenderID>' +
              '<Version>' + POSVersion() + '</Version>' +
              '<SenderSpecificData>' +
                '<parameter name="UserName" value="' + GlobalBlueParameters.Username + '"/>' +
                '<parameter name="Password" value="' + GlobalBlueParameters.Password + '"/>' +
              '</SenderSpecificData>' +
            '</Sender>' +
          '</Header>' +
          '<Message>' +
            '<CreateTFSFormReq>' +
              '<ShopInfo>' +
                '<ShopIdentification>' +
                  '<ShopID>' + GlobalBlueParameters."Shop ID" + '</ShopID>' +
                  '<DeskID>' + GlobalBlueParameters."Desk ID" + '</DeskID>' +
                '</ShopIdentification>' +
                '<ShopCountryCode>' + Format(GlobalBlueParameters."Shop Country Code") + '</ShopCountryCode>' +
              '</ShopInfo>' +
              PurchaseDetailsXML +
              '<ServiceID>' + Format(TaxFreeRequest."Service ID") + '</ServiceID>' +
              TravellerInfoXML +
              '<SalesAssistantCode>' + TaxFreeRequest."Salesperson Code" + '</SalesAssistantCode>' +
              PaymentMethodsXML +
            '</CreateTFSFormReq>' +
          '</Message>' +
        '</GripsMXRequest>';

        InvokeService(Request, TaxFreeRequest);
    end;

    local procedure ReissueRenderedCheque(var TaxFreeRequest: Record "Tax Free Request"; VoucherID: Text; TotalGrossAmount: Text)
    var
        Request: Text;
    begin
        Request :=
        '<?xml version="1.0" encoding="UTF-8"?>' +
        '<GripsMXRequest xmlns="https://dev.global-blue.com/gripsmx/xsd/v16_06">' +
          '<Header>' +
            '<Operation>ReissueRenderedCheque</Operation>' +
            '<TransmissionDate>' + FormattedDateTime() + '</TransmissionDate>' +
            '<Sender>' +
              '<SenderID>' + SenderID() + '</SenderID>' +
              '<Version>' + POSVersion + '</Version>' +
              '<SenderSpecificData>' +
                '<parameter name="UserName" value="' + GlobalBlueParameters.Username + '"/>' +
                '<parameter name="Password" value="' + GlobalBlueParameters.Password + '"/>' +
              '</SenderSpecificData>' +
            '</Sender>' +
          '</Header>' +
          '<Message>' +
            '<ReissueReq>' +
              '<ShopInfo>' +
                '<ShopIdentification>' +
                  '<ShopID>' + GlobalBlueParameters."Shop ID" + '</ShopID>' +
                  '<DeskID>' + GlobalBlueParameters."Desk ID" + '</DeskID>' +
                '</ShopIdentification>' +
                '<ShopCountryCode>' + Format(GlobalBlueParameters."Shop Country Code") + '</ShopCountryCode>' +
              '</ShopInfo>' +
              '<NumericDocIdentifier>' + VoucherID + '</NumericDocIdentifier>' +
              '<TotalGrossAmount>' + TotalGrossAmount + '</TotalGrossAmount>' +
            '</ReissueReq>' +
          '</Message>' +
        '</GripsMXRequest>';

        InvokeService(Request, TaxFreeRequest);
    end;

    local procedure VoidCheque(var TaxFreeRequest: Record "Tax Free Request"; VoucherID: Text; TotalGrossAmount: Text)
    var
        Request: Text;
    begin
        Request :=
        '<?xml version="1.0" encoding="UTF-8"?>' +
        '<GripsMXRequest xmlns="https://dev.global-blue.com/gripsmx/xsd/v16_06">' +
          '<Header>' +
            '<Operation>VoidCheque</Operation>' +
            '<TransmissionDate>' + FormattedDateTime() + '</TransmissionDate>' +
            '<Sender>' +
              '<SenderID>' + SenderID() + '</SenderID>' +
              '<Version>' + POSVersion + '</Version>' +
              '<SenderSpecificData>' +
                '<parameter name="UserName" value="' + GlobalBlueParameters.Username + '"/>' +
                '<parameter name="Password" value="' + GlobalBlueParameters.Password + '"/>' +
              '</SenderSpecificData>' +
            '</Sender>' +
          '</Header>' +
          '<Message>' +
            '<VoidTFSFormReq>' +
              '<ShopInfo>' +
                '<ShopIdentification>' +
                  '<ShopID>' + GlobalBlueParameters."Shop ID" + '</ShopID>' +
                  '<DeskID>' + GlobalBlueParameters."Desk ID" + '</DeskID>' +
                '</ShopIdentification>' +
                '<ShopCountryCode>' + Format(GlobalBlueParameters."Shop Country Code") + '</ShopCountryCode>' +
              '</ShopInfo>' +
              '<NumericDocIdentifier>' + VoucherID + '</NumericDocIdentifier>' +
              '<TotalGrossAmount>' + TotalGrossAmount + '</TotalGrossAmount>' +
            '</VoidTFSFormReq>' +
          '</Message>' +
        '</GripsMXRequest>';

        InvokeService(Request, TaxFreeRequest);
    end;

    local procedure GetCountries(var TaxFreeRequest: Record "Tax Free Request")
    var
        Request: Text;
    begin
        Request :=
        '<?xml version="1.0" encoding="UTF-8"?>' +
        '<GripsMXRequest xmlns="https://dev.global-blue.com/gripsmx/xsd/v16_06">' +
          '<Header>' +
            '<Operation>GetCountries</Operation>' +
            '<TransmissionDate>' + FormattedDateTime() + '</TransmissionDate>' +
            '<Sender>' +
              '<SenderID>' + SenderID() + '</SenderID>' +
              '<Version>' + POSVersion() + '</Version>' +
              '<SenderSpecificData>' +
                '<parameter name="UserName" value="' + GlobalBlueParameters.Username + '"/>' +
                '<parameter name="Password" value="' + GlobalBlueParameters.Password + '"/>' +
              '</SenderSpecificData>' +
            '</Sender>' +
          '</Header>' +
          '<Message>' +
            '<GetCountriesReq>' +
              '<ShopIdentification>' +
                '<ShopID>' + GlobalBlueParameters."Shop ID" + '</ShopID>' +
                '<DeskID>' + GlobalBlueParameters."Desk ID" + '</DeskID>' +
              '</ShopIdentification>' +
              '<ShopCountryCode>' + Format(GlobalBlueParameters."Shop Country Code") + '</ShopCountryCode>' +
            '</GetCountriesReq>' +
          '</Message>' +
        '</GripsMXRequest>';

        InvokeService(Request, TaxFreeRequest);
    end;

    local procedure GetBlockedCountries(var TaxFreeRequest: Record "Tax Free Request")
    var
        Request: Text;
    begin
        Request :=
        '<?xml version="1.0" encoding="UTF-8"?>' +
        '<GripsMXRequest xmlns="https://dev.global-blue.com/gripsmx/xsd/v16_06">' +
          '<Header>' +
            '<Operation>GetBlockedCountries</Operation>' +
            '<TransmissionDate>' + FormattedDateTime() + '</TransmissionDate>' +
            '<Sender>' +
              '<SenderID>' + SenderID() + '</SenderID>' +
              '<Version>' + POSVersion() + '</Version>' +
              '<SenderSpecificData>' +
                '<parameter name="UserName" value="' + GlobalBlueParameters.Username + '"/>' +
                '<parameter name="Password" value="' + GlobalBlueParameters.Password + '"/>' +
              '</SenderSpecificData>' +
            '</Sender>' +
          '</Header>' +
          '<Message>' +
            '<BlockedCountriesReq>' +
              '<ShopInfo>' +
                '<ShopIdentification>' +
                  '<ShopID>' + GlobalBlueParameters."Shop ID" + '</ShopID>' +
                  '<DeskID>' + GlobalBlueParameters."Desk ID" + '</DeskID>' +
                '</ShopIdentification>' +
                '<ShopCountryCode>' + Format(GlobalBlueParameters."Shop Country Code") + '</ShopCountryCode>' +
              '</ShopInfo>' +
            '</BlockedCountriesReq>' +
          '</Message>' +
        '</GripsMXRequest>';

        InvokeService(Request, TaxFreeRequest);
    end;

    local procedure GetCondensedTred(var TaxFreeRequest: Record "Tax Free Request")
    var
        Request: Text;
    begin
        Request :=
        '<?xml version="1.0" encoding="UTF-8"?>' +
        '<GripsMXRequest xmlns="https://dev.global-blue.com/gripsmx/xsd/v16_06">' +
          '<Header>' +
            '<Operation>GetCondensedTred</Operation>' +
            '<TransmissionDate>' + FormattedDateTime() + '</TransmissionDate>' +
            '<Sender>' +
              '<SenderID>' + SenderID() + '</SenderID>' +
              '<Version>' + POSVersion() + '</Version>' +
              '<SenderSpecificData>' +
                '<parameter name="UserName" value="' + GlobalBlueParameters.Username + '"/>' +
                '<parameter name="Password" value="' + GlobalBlueParameters.Password + '"/>' +
              '</SenderSpecificData>' +
            '</Sender>' +
          '</Header>' +
          '<Message>' +
            '<GetCondensedTredReq>' +
              '<ShopCountryCode>' + Format(GlobalBlueParameters."Shop Country Code") + '</ShopCountryCode>' +
            '</GetCondensedTredReq>' +
          '</Message>' +
        '</GripsMXRequest>';

        InvokeService(Request, TaxFreeRequest);
    end;

    local procedure InvokeService(XMLRequest: Text; var TaxFreeRequest: Record "Tax Free Request"): Text
    var
        BaseAddress: Text;
        HttpClient: DotNet npNetHttpClient;
        Uri: DotNet npNetUri;
        TimeSpan: DotNet npNetTimeSpan;
        StringContent: DotNet npNetStringContent;
        Encoding: DotNet npNetEncoding;
        HttpResponseMessage: DotNet npNetHttpResponseMessage;
        OutStream: OutStream;
        Result: Text;
    begin
        TaxFreeRequest.Request.CreateOutStream(OutStream, TEXTENCODING::UTF8);
        OutStream.Write(XMLRequest);
        Clear(OutStream);

        HttpClient := HttpClient.HttpClient();
        HttpClient.DefaultRequestHeaders.Clear();

        if TaxFreeRequest.Mode = TaxFreeRequest.Mode::PROD then
            HttpClient.BaseAddress := Uri.Uri(ServicePROD)
        else
            HttpClient.BaseAddress := Uri.Uri(ServiceTEST);

        if TaxFreeRequest."Timeout (ms)" > 0 then
            HttpClient.Timeout := TimeSpan.TimeSpan(0, 0, 0, TaxFreeRequest."Timeout (ms)")
        else
            HttpClient.Timeout := TimeSpan.TimeSpan(0, 0, 10);

        StringContent := StringContent.StringContent(XMLRequest, Encoding.UTF8, 'text/xml');
        HttpResponseMessage := HttpClient.PostAsync('', StringContent).Result();

        TaxFreeRequest.Response.CreateOutStream(OutStream, TEXTENCODING::UTF8);
        Result := HttpResponseMessage.Content.ReadAsStringAsync().Result();
        OutStream.Write(Result);
    end;

    local procedure HandleResponse(var TaxFreeRequest: Record "Tax Free Request"; ExpectedOperation: Text; var XMLDoc: DotNet npNetXmlDocument; var IsError: Boolean)
    var
        InStream: InStream;
        Value: Text;
        NpXmlDomMgt: Codeunit "NpXml Dom Mgt.";
        MemoryStream: DotNet npNetMemoryStream;
    begin
        TaxFreeRequest.Response.CreateInStream(InStream);
        MemoryStream := MemoryStream.MemoryStream();
        CopyStream(MemoryStream, InStream);
        MemoryStream.Position := 0;
        XMLDoc := XMLDoc.XmlDocument();
        XMLDoc.Load(MemoryStream);

        NpXmlDomMgt.RemoveNameSpaces(XMLDoc);

        if not (TrySelectSingleNodeText(XMLDoc, '//Header/Operation', Value)) then begin
            //Undocumented critical error
            IsError := true;
            TaxFreeRequest."Error Message" := Error_Unknown;
            exit;
        end;

        if Value <> ExpectedOperation then begin
            IsError := true;
            if Value = 'Error' then begin
                //Validation error
                if TrySelectSingleNodeText(XMLDoc, '//Message/Error/ErrorCode', Value) then
                    TaxFreeRequest."Error Code" := Value;
                if TrySelectSingleNodeText(XMLDoc, '//Message/Error/ErrorMessage', Value) then
                    TaxFreeRequest."Error Message" := Value;
            end else
                //Undocumented critical error
                TaxFreeRequest."Error Message" := Error_Unknown;
            exit;
        end;

        if TrySelectSingleNodeText(XMLDoc, '//Message/ErrorRes', Value) then begin
            //Operation result error
            IsError := true;
            if TrySelectSingleNodeText(XMLDoc, '//Message/ErrorRes/ErrorCode', Value) then
                TaxFreeRequest."Error Code" := Value;
            if TrySelectSingleNodeText(XMLDoc, '//Message/ErrorRes/Message', Value) then
                TaxFreeRequest."Error Message" := Value;
            exit;
        end;

        //No errors found in response!
    end;

    local procedure EscapeSpecialChars(Value: Text): Text
    var
        CALText: Text;
        String: DotNet npNetString;
    begin
        String := Value;
        String := String.Replace('&', '&amp;');
        String := String.Replace('"', '&quot;');
        String := String.Replace('''', '&apos;');
        String := String.Replace('<', '&lt;');
        String := String.Replace('>', '&qt;');
        CALText := String;
        exit(CALText);
    end;

    local procedure SenderID(): Text
    var
        CompanyInformation: Record "Company Information";
    begin
        CompanyInformation.Get();
        exit('NPRETAIL+' + EscapeSpecialChars(CompanyInformation.Name));
    end;

    local procedure POSVersion(): Text
    var
        SystemEventWrapper: Codeunit "System Event Wrapper";
    begin
        //-TM1.39 [334644]
        exit(EscapeSpecialChars(SystemEventWrapper.ApplicationVersion()));
        //+TM1.39 [334644]
    end;

    local procedure FormattedDateTime(): Text
    begin
        exit(Format(CurrentDateTime, 0, 9));
    end;

    [TryFunction]
    local procedure TrySelectSingleNodeText(var XMLDoc: DotNet npNetXmlDocument; XPath: Text; var Value: Text)
    begin
        Value := XMLDoc.SelectSingleNode(XPath).InnerText();
    end;

    [TryFunction]
    local procedure TryGetItemInnerText(var XmlNode: DotNet npNetXmlNode; ItemName: Text; var Value: Text)
    begin
        Value := XmlNode.Item(ItemName).InnerText;
    end;

    local procedure "--- Aux"()
    begin
    end;

    local procedure CaptureCustomerInfo(): Text
    var
        tmpCustomerInfoCapture: Record "Tax Free GB I2 Info Capture" temporary;
        LookupCompleted: Boolean;
    begin
        tmpCustomerInfoCapture.Init;
        tmpCustomerInfoCapture."Shop Country Code" := GlobalBlueParameters."Shop Country Code";
        tmpCustomerInfoCapture.Insert;

        if Confirm(Caption_UseID) then begin
            if not ScanCustomerID(tmpCustomerInfoCapture) then
                exit(CaptureCustomerInfo()); //Aborted - Restart capture flow
            LookupCompleted := true;
        end;

        if not IsAllRequiredCustomerInfoCaptured(tmpCustomerInfoCapture) then begin
            tmpCustomerInfoCapture."Is Identity Checked" := false;
            if not ManualCustomerInfoEntry(tmpCustomerInfoCapture, LookupCompleted) then begin
                if Confirm(Caption_CancelOperation) then
                    Error(Error_UserCancel)
                else
                    exit(CaptureCustomerInfo()); //Restart capture flow
            end;
        end;

        exit(GetCustomerInfoXML(tmpCustomerInfoCapture));
    end;

    local procedure ScanCustomerID(var tmpCustomerInfoCapture: Record "Tax Free GB I2 Info Capture" temporary): Boolean
    var
        IDType: Integer;
        Captured: Boolean;
    begin
        IDType := StrMenu(StrSubstNo('%1,%2,%3', Caption_MemberCard, Caption_MobileNo, Caption_Passport), 1, Caption_IdentifierType);

        case IDType of
            0:
                exit(false); //Restart capture flow
            1:
                Captured := GetGlobalBlueCardIdentifier(tmpCustomerInfoCapture);
            2:
                Captured := GetMobileNoIdentifier(tmpCustomerInfoCapture);
            3:
                Captured := GetPassportIdentifier(tmpCustomerInfoCapture);
        end;

        if not Captured then
            exit(false); //Restart capture flow

        if not Confirm(Caption_ConfirmIdentity, false, tmpCustomerInfoCapture."First Name" + ' ' + tmpCustomerInfoCapture."Last Name", tmpCustomerInfoCapture."Passport Number", tmpCustomerInfoCapture."Country Of Residence") then
            exit(false); //Restart capture flow

        tmpCustomerInfoCapture."Is Identity Checked" := true;
        exit(true);
    end;

    local procedure GetMobileNoIdentifier(var tmpCustomerInfoCapture: Record "Tax Free GB I2 Info Capture" temporary): Boolean
    var
        TravellerInfoCapture: Page "Tax Free GB I2 Info Capture";
        tmpMobilePhoneNoCapture: Record "Tax Free GB I2 Info Capture" temporary;
        tmpMobilePhoneRequiredParam: Record "Tax Free GB I2 Parameter" temporary;
    begin
        tmpMobilePhoneRequiredParam.Init;
        tmpMobilePhoneRequiredParam."(Dialog) Mobile No." := tmpMobilePhoneRequiredParam."(Dialog) Mobile No."::Required;
        tmpMobilePhoneRequiredParam.Insert;
        tmpMobilePhoneNoCapture.Init;
        tmpMobilePhoneNoCapture."Shop Country Code" := GlobalBlueParameters."Shop Country Code";
        tmpMobilePhoneNoCapture.Insert;

        TravellerInfoCapture.SetModes(tmpMobilePhoneRequiredParam);
        TravellerInfoCapture.SetRec(tmpMobilePhoneNoCapture);
        TravellerInfoCapture.LookupMode(true);
        if TravellerInfoCapture.RunModal <> ACTION::LookupOK then
            exit(false); //Restart capture flow

        TravellerInfoCapture.GetRec(tmpMobilePhoneNoCapture);
        tmpCustomerInfoCapture."Mobile No." := tmpMobilePhoneNoCapture."Mobile No.";
        tmpCustomerInfoCapture."Mobile No. Country" := tmpMobilePhoneNoCapture."Mobile No. Country";
        tmpCustomerInfoCapture."Mobile No. Prefix" := tmpMobilePhoneNoCapture."Mobile No. Prefix";
        tmpCustomerInfoCapture."Mobile No. Prefix Formatted" := tmpMobilePhoneNoCapture."Mobile No. Prefix Formatted";

        //Identifer = [00][Country Prefix][Mobile No.]
        tmpCustomerInfoCapture."Global Blue Identifier" := '00';
        if tmpCustomerInfoCapture."Mobile No. Prefix" <> 0 then
            tmpCustomerInfoCapture."Global Blue Identifier" += Format(tmpCustomerInfoCapture."Mobile No. Prefix");
        tmpCustomerInfoCapture."Global Blue Identifier" += tmpCustomerInfoCapture."Mobile No.";

        if not TryLookupTraveller(tmpCustomerInfoCapture) then begin
            Message(Caption_TravellerLookupFail);
            exit(false); //Restart capture flow
        end;

        exit(true);
    end;

    local procedure GetPassportIdentifier(var tmpCustomerInfoCapture: Record "Tax Free GB I2 Info Capture" temporary): Boolean
    var
        TravellerInfoCapture: Page "Tax Free GB I2 Info Capture";
        tmpPassportCapture: Record "Tax Free GB I2 Info Capture" temporary;
        tmpPassportRequiredParam: Record "Tax Free GB I2 Parameter" temporary;
    begin
        tmpPassportRequiredParam.Init;
        tmpPassportRequiredParam."(Dialog) Passport Number" := tmpPassportRequiredParam."(Dialog) Passport Number"::Required;
        tmpPassportRequiredParam."(Dialog) Passport Country Code" := tmpPassportRequiredParam."(Dialog) Passport Country Code"::Required;
        tmpPassportRequiredParam.Insert;
        tmpPassportCapture.Init;
        tmpPassportCapture."Shop Country Code" := GlobalBlueParameters."Shop Country Code";
        tmpPassportCapture.Insert;

        TravellerInfoCapture.SetModes(tmpPassportRequiredParam);
        TravellerInfoCapture.SetRec(tmpPassportCapture);
        TravellerInfoCapture.LookupMode(true);
        if TravellerInfoCapture.RunModal <> ACTION::LookupOK then
            exit(false); //Restart capture flow

        TravellerInfoCapture.GetRec(tmpPassportCapture);
        tmpCustomerInfoCapture."Passport Country" := tmpPassportCapture."Passport Country";
        tmpCustomerInfoCapture."Passport Country Code" := tmpPassportCapture."Passport Country Code";
        tmpCustomerInfoCapture."Passport Number" := tmpPassportCapture."Passport Number";

        //Identifier = [Passport Country Code]+[UPPERCASE(Passport Number)]
        tmpCustomerInfoCapture."Global Blue Identifier" := Format(tmpCustomerInfoCapture."Passport Country Code") + '+' + UpperCase(tmpCustomerInfoCapture."Passport Number");

        if not TryLookupTraveller(tmpCustomerInfoCapture) then begin
            Message(Caption_TravellerLookupFail);
            exit(false); //Restart capture flow
        end;

        exit(true);
    end;

    local procedure GetGlobalBlueCardIdentifier(var tmpCustomerInfoCapture: Record "Tax Free GB I2 Info Capture" temporary): Boolean
    var
        InputDialog: Page "Input Dialog";
        ScanAction: Action;
        Input: Text;
    begin
        InputDialog.LookupMode(true);
        InputDialog.SetInput(1, Input, Caption_GlobalBlueIdentifier);
        ScanAction := InputDialog.RunModal;
        if (ScanAction <> ACTION::LookupOK) or (InputDialog.InputText(1, Input) <> 1) then
            exit(false);

        if StrLen(Input) < 10 then begin
            Message(Caption_InvalidIdentifier, Input);
            exit(false);
        end;

        tmpCustomerInfoCapture."Global Blue Identifier" := Input;

        if not TryLookupTraveller(tmpCustomerInfoCapture) then begin
            Message(Caption_TravellerLookupFail);
            exit(false); //Restart capture flow
        end;

        exit(true);
    end;

    local procedure ManualCustomerInfoEntry(var tmpCustomerInfoCapture: Record "Tax Free GB I2 Info Capture" temporary; LookupCompleted: Boolean): Boolean
    var
        TravellerInfoCapture: Page "Tax Free GB I2 Info Capture";
    begin
        TravellerInfoCapture.SetModes(GlobalBlueParameters);
        TravellerInfoCapture.SetRec(tmpCustomerInfoCapture); //Will set filled out data as read-only.
        TravellerInfoCapture.LookupMode(true);
        if TravellerInfoCapture.RunModal = ACTION::LookupOK then begin
            TravellerInfoCapture.GetRec(tmpCustomerInfoCapture);
            exit(true);
        end;

        //TODO?: When full manual customer entry (LookupCompleted=FALSE), suggest pulling from NAV customer/contact if any is present on sale.
        //Requires mapping between standard NAV table data formats and Global blue data formats.
    end;

    local procedure IsAllRequiredCustomerInfoCaptured(var tmpCustomerInfoCapture: Record "Tax Free GB I2 Info Capture" temporary): Boolean
    begin
        if GlobalBlueParameters."(Dialog) Arrival Date" = GlobalBlueParameters."(Dialog) Arrival Date"::Required then
            if tmpCustomerInfoCapture."Arrival Date" = 0D then
                exit(false);

        if GlobalBlueParameters."(Dialog) Country Code" = GlobalBlueParameters."(Dialog) Country Code"::Required then
            if tmpCustomerInfoCapture."Country Of Residence Code" = 0 then
                exit(false);

        if GlobalBlueParameters."(Dialog) Date Of Birth" = GlobalBlueParameters."(Dialog) Date Of Birth"::Required then
            if tmpCustomerInfoCapture."Date Of Birth" = 0D then
                exit(false);

        if GlobalBlueParameters."(Dialog) Departure Date" = GlobalBlueParameters."(Dialog) Departure Date"::Required then
            if tmpCustomerInfoCapture."Departure Date" = 0D then
                exit(false);

        if GlobalBlueParameters."(Dialog) Dest. Country Code" = GlobalBlueParameters."(Dialog) Dest. Country Code"::Required then
            if tmpCustomerInfoCapture."Final Destination Country Code" = 0 then
                exit(false);

        if GlobalBlueParameters."(Dialog) Email" = GlobalBlueParameters."(Dialog) Email"::Required then
            if tmpCustomerInfoCapture."E-mail" = '' then
                exit(false);

        if GlobalBlueParameters."(Dialog) First Name" = GlobalBlueParameters."(Dialog) First Name"::Required then
            if tmpCustomerInfoCapture."First Name" = '' then
                exit(false);

        if GlobalBlueParameters."(Dialog) Last Name" = GlobalBlueParameters."(Dialog) Last Name"::Required then
            if tmpCustomerInfoCapture."Last Name" = '' then
                exit(false);

        if GlobalBlueParameters."(Dialog) Mobile No." = GlobalBlueParameters."(Dialog) Mobile No."::Required then
            if tmpCustomerInfoCapture."Mobile No." = '' then
                exit(false);

        if GlobalBlueParameters."(Dialog) Passport Country Code" = GlobalBlueParameters."(Dialog) Passport Country Code"::Required then
            if tmpCustomerInfoCapture."Passport Country Code" = 0 then
                exit(false);

        if GlobalBlueParameters."(Dialog) Passport Number" = GlobalBlueParameters."(Dialog) Passport Number"::Required then
            if tmpCustomerInfoCapture."Passport Number" = '' then
                exit(false);

        if GlobalBlueParameters."(Dialog) Postal Code" = GlobalBlueParameters."(Dialog) Postal Code"::Required then
            if tmpCustomerInfoCapture."Postal Code" = '' then
                exit(false);

        if GlobalBlueParameters."(Dialog) Street" = GlobalBlueParameters."(Dialog) Street"::Required then
            if tmpCustomerInfoCapture.Street = '' then
                exit(false);

        if GlobalBlueParameters."(Dialog) Town" = GlobalBlueParameters."(Dialog) Town"::Required then
            if tmpCustomerInfoCapture.Town = '' then
                exit(false);

        exit(true);
    end;

    local procedure IsConsolidationEligible(var tmpTaxFreeConsolidation: Record "Tax Free Consolidation" temporary; var tmpEligibleServices: Record "Tax Free GB I2 Service" temporary): Boolean
    begin
        if not GlobalBlueParameters."Consolidation Allowed" then
            exit(false);

        if not tmpTaxFreeConsolidation.FindSet then
            exit(false);

        if GlobalBlueParameters."Consolidation Separate Limits" then
            exit(IsConsolidationEligibleSeperate(tmpTaxFreeConsolidation, tmpEligibleServices))
        else
            exit(IsConsolidationEligibleShared(tmpTaxFreeConsolidation, tmpEligibleServices));
    end;

    local procedure IsConsolidationEligibleSeperate(var tmpTaxFreeConsolidation: Record "Tax Free Consolidation" temporary; var tmpEligibleServices: Record "Tax Free GB I2 Service" temporary): Boolean
    var
        tmpSharedEligibleServices: Record "Tax Free GB I2 Service" temporary;
        First: Boolean;
        FilterString: Text;
        Eligible: Boolean;
    begin
        //Check each sale seperately and make sure they share an eligible service

        First := true;
        repeat
            Eligible := IsStoredSaleEligible(tmpTaxFreeConsolidation."Sales Ticket No.", tmpEligibleServices);

            if Eligible then begin
                tmpEligibleServices.FindSet;
                repeat
                    if First then begin
                        tmpSharedEligibleServices.Init;
                        tmpSharedEligibleServices.TransferFields(tmpEligibleServices);
                        tmpSharedEligibleServices.Insert;
                    end else begin
                        if not tmpSharedEligibleServices.Get(tmpEligibleServices."Tax Free Unit", tmpEligibleServices."Service ID") then begin
                            if FilterString <> '' then
                                FilterString += '&';
                            FilterString += '<>' + Format(tmpEligibleServices."Service ID");
                        end;
                    end;
                until tmpEligibleServices.Next = 0;

                if FilterString <> '' then begin
                    //Delete every non-shared service
                    tmpSharedEligibleServices.SetFilter("Service ID", FilterString);
                    tmpSharedEligibleServices.DeleteAll;
                    tmpSharedEligibleServices.SetRange("Service ID");
                end;
            end;

            First := false;
            tmpEligibleServices.DeleteAll;
            Clear(tmpEligibleServices);
            Clear(FilterString);
            Eligible := Eligible and (not tmpSharedEligibleServices.IsEmpty);
        until (tmpTaxFreeConsolidation.Next = 0) or (not Eligible);

        if Eligible then
            tmpEligibleServices.Copy(tmpSharedEligibleServices, true);

        exit(Eligible);
    end;

    local procedure IsConsolidationEligibleShared(var tmpTaxFreeConsolidation: Record "Tax Free Consolidation" temporary; var tmpEligibleServices: Record "Tax Free GB I2 Service" temporary): Boolean
    var
        AuditRoll: Record "Audit Roll";
        SalesAmount: Decimal;
        Item: Record Item;
    begin
        repeat
            AuditRoll.Reset;
            Clear(AuditRoll);

            AuditRoll.SetRange("Sales Ticket No.", tmpTaxFreeConsolidation."Sales Ticket No.");
            AuditRoll.SetRange(Type, AuditRoll.Type::Item);
            AuditRoll.SetRange("Sale Type", AuditRoll."Sale Type"::Sale);
            AuditRoll.SetFilter(Quantity, '>0');
            AuditRoll.SetFilter("VAT %", '>0');

            if not AuditRoll.FindSet then
                exit(false);

            if CalcDate(GlobalBlueParameters."Voucher Issue Date Limit", AuditRoll."Sale Date") < Today then
                exit(false);

            if GlobalBlueParameters."Count Zero VAT Goods For Limit" then
                AuditRoll.SetRange("VAT %");

            if GlobalBlueParameters."Services Eligible" then begin
                AuditRoll.CalcSums("Amount Including VAT");
                SalesAmount += AuditRoll."Amount Including VAT";
            end else begin
                repeat
                    Item.Get(AuditRoll."No.");
                    if Item.Type = Item.Type::Inventory then
                        SalesAmount += AuditRoll."Amount Including VAT";
                until AuditRoll.Next = 0;
            end;
        until tmpTaxFreeConsolidation.Next = 0;

        GetEligibleServices(SalesAmount, tmpEligibleServices);
        exit(not tmpEligibleServices.IsEmpty);
    end;

    local procedure IsStoredSaleEligible(SalesTicketNo: Text; var tmpEligibleServices: Record "Tax Free GB I2 Service" temporary): Boolean
    var
        AuditRoll: Record "Audit Roll";
        SaleAmount: Decimal;
        Item: Record Item;
        AuditRoll2: Record "Audit Roll";
    begin
        AuditRoll.SetRange("Sales Ticket No.", SalesTicketNo);
        AuditRoll.SetRange(Type, AuditRoll.Type::Item);
        AuditRoll.SetRange("Sale Type", AuditRoll."Sale Type"::Sale);
        AuditRoll.SetFilter(Quantity, '>0');
        AuditRoll.SetFilter("VAT %", '>0');

        if not AuditRoll.FindSet then
            exit(false);

        if CalcDate(GlobalBlueParameters."Voucher Issue Date Limit", AuditRoll."Sale Date") < Today then
            exit(false);

        if GlobalBlueParameters."Count Zero VAT Goods For Limit" then
            AuditRoll.SetRange("VAT %");

        if GlobalBlueParameters."Services Eligible" then begin
            AuditRoll.CalcSums("Amount Including VAT");
            SaleAmount := AuditRoll."Amount Including VAT";
        end else begin
            repeat
                Item.Get(AuditRoll."No.");
                if Item.Type = Item.Type::Inventory then
                    SaleAmount += AuditRoll."Amount Including VAT";
            until AuditRoll.Next = 0;
        end;

        GetEligibleServices(SaleAmount, tmpEligibleServices);
        exit(not tmpEligibleServices.IsEmpty);
    end;

    local procedure IsActiveSaleEligible(SalesTicketNo: Text; var tmpEligibleServices: Record "Tax Free GB I2 Service" temporary): Boolean
    var
        SaleLinePOS: Record "Sale Line POS";
        Item: Record Item;
        SaleAmount: Decimal;
        SalePOS: Record "Sale POS";
    begin
        SaleLinePOS.SetRange("Sales Ticket No.", SalesTicketNo);
        SaleLinePOS.SetRange(Type, SaleLinePOS.Type::Item);
        SaleLinePOS.SetRange("Sale Type", SaleLinePOS."Sale Type"::Sale);
        SaleLinePOS.SetFilter(Quantity, '>0');
        SaleLinePOS.SetFilter("VAT %", '>0');

        if not SaleLinePOS.FindSet then
            exit(false);

        SalePOS.Get(SaleLinePOS."Register No.", SaleLinePOS."Sales Ticket No.");
        if CalcDate(GlobalBlueParameters."Voucher Issue Date Limit", SalePOS.Date) < Today then
            exit(false);

        if GlobalBlueParameters."Count Zero VAT Goods For Limit" then
            SaleLinePOS.SetRange("VAT %");

        if GlobalBlueParameters."Services Eligible" then begin
            SaleLinePOS.CalcSums("Amount Including VAT");
            SaleAmount := SaleLinePOS."Amount Including VAT";
        end else begin
            repeat
                Item.Get(SaleLinePOS."No.");
                if Item.Type = Item.Type::Inventory then
                    SaleAmount += SaleLinePOS."Amount Including VAT";
            until SaleLinePOS.Next = 0;
        end;

        GetEligibleServices(SaleAmount, tmpEligibleServices);
        exit(not tmpEligibleServices.IsEmpty);
    end;

    local procedure GetEligibleServices(SaleAmount: Decimal; var tmpEligibleServices: Record "Tax Free GB I2 Service" temporary)
    begin
        if GlobalBlueServices.FindSet then
            repeat
                if (GlobalBlueServices."Minimum Purchase Amount" <> 0) and (GlobalBlueServices."Maximum Purchase Amount" <> 0) then begin //Both upper and lower bound
                    if (GlobalBlueServices."Minimum Purchase Amount" <= SaleAmount) and (SaleAmount <= GlobalBlueServices."Maximum Purchase Amount") then begin
                        tmpEligibleServices.Init;
                        tmpEligibleServices.TransferFields(GlobalBlueServices);
                        tmpEligibleServices.Insert;
                    end;
                end else
                    if (GlobalBlueServices."Maximum Purchase Amount" = 0) then begin //Only lower bound
                        if (GlobalBlueServices."Minimum Purchase Amount" <= SaleAmount) then begin
                            tmpEligibleServices.Init;
                            tmpEligibleServices.TransferFields(GlobalBlueServices);
                            tmpEligibleServices.Insert;
                        end;
                    end else begin //Only upper bound
                        if (SaleAmount <= GlobalBlueServices."Maximum Purchase Amount") then begin
                            tmpEligibleServices.Init;
                            tmpEligibleServices.TransferFields(GlobalBlueServices);
                            tmpEligibleServices.Insert;
                        end;
                    end;
            until GlobalBlueServices.Next = 0;
    end;

    local procedure SelectService(var tmpEligibleServices: Record "Tax Free GB I2 Service" temporary): Integer
    begin
        if tmpEligibleServices.Count = 1 then
            exit(tmpEligibleServices."Service ID");

        tmpEligibleServices.FindSet;
        //-NPR5.49 [293106]
        //IF PAGE.RUNMODAL(PAGE::"Generic Filter Page", tmpEligibleServices) <> ACTION::LookupOK THEN BEGIN
        if PAGE.RunModal(PAGE::"Tax Free GB I2 Service Select", tmpEligibleServices) <> ACTION::LookupOK then begin
            //+NPR5.49 [293106]
            if Confirm(Caption_CancelOperation) then
                Error(Error_UserCancel)
            else
                exit(SelectService(tmpEligibleServices));
        end;

        exit(tmpEligibleServices."Service ID");
    end;

    local procedure GetPurchaseDetailsXML(var tmpTaxFreeConsolidation: Record "Tax Free Consolidation" temporary): Text
    var
        AuditRoll: Record "Audit Roll";
        ReceiptXML: Text;
        ItemXML: Text;
        XML: Text;
        Item: Record Item;
    begin
        XML := '<PurchaseDetails>';
        tmpTaxFreeConsolidation.FindSet;
        repeat
            AuditRoll.Reset;
            Clear(AuditRoll);
            AuditRoll.SetRange("Sales Ticket No.", tmpTaxFreeConsolidation."Sales Ticket No.");
            AuditRoll.SetRange("Sale Type", AuditRoll."Sale Type"::Sale);
            AuditRoll.SetRange(Type, AuditRoll.Type::Item);
            AuditRoll.SetFilter(Quantity, '>0');
            //AuditRoll.SETFILTER("VAT %", '>0');
            AuditRoll.FindSet;

            XML += '<Receipt>';
            XML += StrSubstNo('<ReceiptDateTime>%1</ReceiptDateTime>', Format(CreateDateTime(AuditRoll."Sale Date", AuditRoll."Closing Time"), 0, 9));
            XML += StrSubstNo('<ReceiptNumber>%1</ReceiptNumber>', Format(AuditRoll."Sales Ticket No.", 0, 9));
            XML += '<PurchaseItems>';
            repeat
                Item.Get(AuditRoll."No.");
                if (Item.Type = Item.Type::Inventory) or (GlobalBlueParameters."Services Eligible") then
                    XML +=
                    '<PurchaseItem>' +
                      '<VATRate>' + Format(AuditRoll."VAT %", 0, '<Precision,2:2><Standard Format,2>') + '</VATRate>' +
                      '<GrossAmount>' + Format(AuditRoll."Amount Including VAT", 0, '<Precision,2:2><Standard Format,2>') + '</GrossAmount>' +
                      '<VATAmount>' + Format(AuditRoll."Amount Including VAT" - AuditRoll.Amount, 0, '<Precision,2:2><Standard Format,2>') + '</VATAmount>' +
                      '<NetAmount>' + Format(AuditRoll.Amount, 0, '<Precision,2:2><Standard Format,2>') + '</NetAmount>' +
                      '<Quantity>' + Format(Round(AuditRoll.Quantity, 1, '>')) + '</Quantity>' + //Round up - They only accept integer quantity
                      '<GoodDescription>' + Format(CopyStr(EscapeSpecialChars(AuditRoll.Description), 1, 50)) + '</GoodDescription>' +
                    '</PurchaseItem>';
            until AuditRoll.Next = 0;
            XML += '</PurchaseItems>';
            XML += '</Receipt>';
        until tmpTaxFreeConsolidation.Next = 0;
        XML += '</PurchaseDetails>';

        exit(XML);
    end;

    local procedure GetPurchasePaymentMethodsXML(var tmpTaxFreeConsolidation: Record "Tax Free Consolidation" temporary): Text
    begin
        //NON-MANDATORY - Will be left out for now since it doesn't make sense for consolidated vouchers either when the paymentmethod element isn't inside each receipt element.
        exit('');
    end;

    local procedure GetCustomerInfoXML(var tmpCustomerInfoCapture: Record "Tax Free GB I2 Info Capture" temporary): Text
    var
        XML: Text;
    begin
        if (tmpCustomerInfoCapture."Global Blue Identifier" <> '') and (tmpCustomerInfoCapture."Is Identity Checked") then begin
            //Verified autofill - nothing else is required.
            XML := '<Traveller>' +
                     '<IsIdentityChecked>true</IsIdentityChecked>' +
                   '</Traveller>' +
                   '<TravellerIdentifier>' +
                     StrSubstNo('<IdentifierLookupValue>%1</IdentifierLookupValue>', EscapeSpecialChars(tmpCustomerInfoCapture."Global Blue Identifier")) +
                   '</TravellerIdentifier>';
            exit(XML);
        end;

        XML += '<Traveller>';
        if tmpCustomerInfoCapture."First Name" <> '' then
            XML += StrSubstNo('<FirstName>%1</FirstName>', EscapeSpecialChars(tmpCustomerInfoCapture."First Name"));
        if tmpCustomerInfoCapture."Last Name" <> '' then
            XML += StrSubstNo('<LastName>%1</LastName>', EscapeSpecialChars(tmpCustomerInfoCapture."Last Name"));
        if tmpCustomerInfoCapture."E-mail" <> '' then
            XML += StrSubstNo('<Email>%1</Email>', EscapeSpecialChars(tmpCustomerInfoCapture."E-mail"));
        if tmpCustomerInfoCapture."Date Of Birth" <> 0D then
            XML += StrSubstNo('<DateOfBirth>%1</DateOfBirth>', EscapeSpecialChars(Format(tmpCustomerInfoCapture."Date Of Birth", 0, 9)));
        if tmpCustomerInfoCapture."Global Blue Identifier" <> '' then //We have an identifier attached but manual entry was still used.
            XML += '<IsIdentityChecked>false</IsIdentityChecked>';

        if (tmpCustomerInfoCapture."Passport Number" <> '') or (tmpCustomerInfoCapture."Passport Country Code" <> 0) then begin
            XML += '<Passport>';
            if tmpCustomerInfoCapture."Passport Number" <> '' then
                XML += StrSubstNo('<PassportNumber>%1</PassportNumber>', EscapeSpecialChars(tmpCustomerInfoCapture."Passport Number"));
            if tmpCustomerInfoCapture."Passport Country Code" <> 0 then
                XML += StrSubstNo('<PassportCountryCode>%1</PassportCountryCode>', Format(tmpCustomerInfoCapture."Passport Country Code"));
            XML += '</Passport>';
        end;

        if (tmpCustomerInfoCapture."Departure Date" <> 0D) or (tmpCustomerInfoCapture."Arrival Date" <> 0D) or (tmpCustomerInfoCapture."Final Destination Country Code" <> 0) then begin
            XML += '<TravelDetails>';
            if tmpCustomerInfoCapture."Departure Date" <> 0D then
                XML += StrSubstNo('<DepartureDate>%1</DepartureDate>', EscapeSpecialChars(Format(tmpCustomerInfoCapture."Departure Date", 0, 9)));
            if tmpCustomerInfoCapture."Arrival Date" <> 0D then
                XML += StrSubstNo('<ArrivalDate>%1</ArrivalDate>', EscapeSpecialChars(Format(tmpCustomerInfoCapture."Arrival Date", 0, 9)));
            if tmpCustomerInfoCapture."Final Destination Country Code" <> 0 then
                XML += StrSubstNo('<FinalDestinationCountryCode>%1</FinalDestinationCountryCode>', Format(tmpCustomerInfoCapture."Final Destination Country Code"));
            XML += '</TravelDetails>';
        end;

        if (tmpCustomerInfoCapture."Postal Code" <> '') or
           (tmpCustomerInfoCapture.Street <> '') or
           (tmpCustomerInfoCapture."Country Of Residence Code" <> 0) or
           (tmpCustomerInfoCapture.Town <> '')
            then begin
            XML += '<Address>';
            if tmpCustomerInfoCapture."Postal Code" <> '' then
                XML += StrSubstNo('<PostalCode>%1</PostalCode>', EscapeSpecialChars(tmpCustomerInfoCapture."Postal Code"));
            if tmpCustomerInfoCapture.Street <> '' then
                XML += StrSubstNo('<Street>%1</Street>', EscapeSpecialChars(tmpCustomerInfoCapture.Street));
            if tmpCustomerInfoCapture."Country Of Residence Code" <> 0 then
                XML += StrSubstNo('<CountryCode>%1</CountryCode>', Format(tmpCustomerInfoCapture."Country Of Residence Code"));
            if tmpCustomerInfoCapture.Town <> '' then
                XML += StrSubstNo('<Town>%1</Town>', EscapeSpecialChars(tmpCustomerInfoCapture.Town));
            XML += '</Address>'
        end;

        if tmpCustomerInfoCapture."Mobile No." <> '' then //Docs doesn't specify if this should also be prefixed with 00 and country prefix.
            if tmpCustomerInfoCapture."Mobile No. Prefix" <> 0 then
                XML += StrSubstNo('<MobileNumber>%1</MobileNumber>', EscapeSpecialChars('00' + Format(tmpCustomerInfoCapture."Mobile No. Prefix") + tmpCustomerInfoCapture."Mobile No."))
            else
                XML += StrSubstNo('<MobileNumber>%1</MobileNumber>', EscapeSpecialChars('00' + tmpCustomerInfoCapture."Mobile No."));
        XML += '</Traveller>';

        if (tmpCustomerInfoCapture."Global Blue Identifier" <> '') then
            XML += '<TravellerIdentifier>' +
                     StrSubstNo('<IdentifierLookupValue>%1</IdentifierLookupValue>', EscapeSpecialChars(tmpCustomerInfoCapture."Global Blue Identifier")) +
                   '</TravellerIdentifier>';

        exit(XML);
    end;

    local procedure "--- Event Subscribers"()
    begin
    end;

    [EventSubscriber(ObjectType::Codeunit, 6014610, 'OnLookupHandler', '', false, false)]
    local procedure OnLookupHandler(var HashSet: DotNet npNetHashSet_Of_T)
    begin
        HashSet.Add(HandlerID);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6014610, 'OnLookupHandlerParameters', '', false, false)]
    local procedure OnLookupHandlerParameter(TaxFreeUnit: Record "Tax Free POS Unit"; var Handled: Boolean; var tmpHandlerParameters: Record "Tax Free Handler Parameters" temporary)
    begin
        if not TaxFreeUnit.IsThisHandler(HandlerID) then
            exit;

        Error(Error_NotSupported, TaxFreeUnit."Handler ID");
    end;

    [EventSubscriber(ObjectType::Codeunit, 6014610, 'OnSetUnitParameters', '', false, false)]
    local procedure OnSetUnitParameters(TaxFreeUnit: Record "Tax Free POS Unit"; var Handled: Boolean)
    var
        GlobalBlueParameters: Record "Tax Free GB I2 Parameter";
        GlobalBlueParameterPage: Page "Tax Free GB I2 Parameters";
    begin
        if not TaxFreeUnit.IsThisHandler(HandlerID) then
            exit;

        Handled := true;

        if not GlobalBlueParameters.Get(TaxFreeUnit."POS Unit No.") then begin
            GlobalBlueParameters.Init;
            GlobalBlueParameters."Tax Free Unit" := TaxFreeUnit."POS Unit No.";
            GlobalBlueParameters.Insert;
            Commit;
        end;

        GlobalBlueParameterPage.SetRecord(GlobalBlueParameters);
        GlobalBlueParameterPage.Editable := true;
        GlobalBlueParameterPage.RunModal();
    end;

    [EventSubscriber(ObjectType::Codeunit, 6014610, 'OnUnitAutoConfigure', '', false, false)]
    local procedure OnUnitAutoConfigure(var TaxFreeRequest: Record "Tax Free Request"; Silent: Boolean; var Handled: Boolean)
    var
        GetCountriesJob: Codeunit "Tax Free GB I2 GetCountries";
        GetBlockedCountriesJob: Codeunit "Tax Free GB I2 GetBCountries";
        GetIINBlacklistJob: Codeunit "Tax Free GB I2 GetBlockedIIN";
    begin
        if not TaxFreeRequest.IsThisHandler(HandlerID) then
            exit;

        Handled := true;

        GlobalTaxFreeUnit.Get(TaxFreeRequest."POS Unit No.");
        GlobalBlueParameters.Get(TaxFreeRequest."POS Unit No.");
        DownloadDeskConfiguration(TaxFreeRequest);

        if not Silent then begin
            if not GetCountriesJob.IsScheduled() then
                GetCountriesJob.Schedule();
            if not GetBlockedCountriesJob.IsScheduled() then
                GetBlockedCountriesJob.Schedule();
            if not GetIINBlacklistJob.IsScheduled() then
                GetIINBlacklistJob.Schedule();
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6014610, 'OnUnitTestConnection', '', false, false)]
    local procedure OnUnitTestConnection(var TaxFreeRequest: Record "Tax Free Request"; var Handled: Boolean)
    begin
        if not TaxFreeRequest.IsThisHandler(HandlerID) then
            exit;

        Handled := true;

        GlobalTaxFreeUnit.Get(TaxFreeRequest."POS Unit No.");
        GlobalBlueParameters.Get(TaxFreeRequest."POS Unit No.");
        DownloadDeskConfiguration(TaxFreeRequest);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6014610, 'OnVoucherIssueFromPOSSale', '', false, false)]
    local procedure OnVoucherIssueFromPOSSale(var TaxFreeRequest: Record "Tax Free Request"; SalesReceiptNo: Code[20]; var Handled: Boolean; var SkipRecordHandling: Boolean)
    var
        tmpEligibleServices: Record "Tax Free GB I2 Service" temporary;
        tmpTaxFreeConsolidation: Record "Tax Free Consolidation" temporary;
    begin
        if not TaxFreeRequest.IsThisHandler(HandlerID) then
            exit;

        Handled := true;
        InitializeHandler(TaxFreeRequest);

        if not IsStoredSaleEligible(SalesReceiptNo, tmpEligibleServices) then
            Error(Error_Ineligible);
        if tmpEligibleServices.IsEmpty then
            Error(Error_Ineligible);

        tmpTaxFreeConsolidation.Init;
        tmpTaxFreeConsolidation."Sales Ticket No." := SalesReceiptNo;
        tmpTaxFreeConsolidation.Insert;

        IssueVoucher(TaxFreeRequest, tmpTaxFreeConsolidation, tmpEligibleServices);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6014610, 'OnVoucherVoid', '', false, false)]
    local procedure OnVoucherVoid(var TaxFreeRequest: Record "Tax Free Request"; TaxFreeVoucher: Record "Tax Free Voucher"; var Handled: Boolean)
    begin
        if not TaxFreeRequest.IsThisHandler(HandlerID) then
            exit;

        Handled := true;
        InitializeHandler(TaxFreeRequest);
        VoidVoucher(TaxFreeRequest, TaxFreeVoucher);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6014610, 'OnVoucherReissue', '', false, false)]
    local procedure OnVoucherReissue(var TaxFreeRequest: Record "Tax Free Request"; TaxFreeVoucher: Record "Tax Free Voucher"; var Handled: Boolean)
    begin
        if not TaxFreeRequest.IsThisHandler(HandlerID) then
            exit;

        Handled := true;
        InitializeHandler(TaxFreeRequest);
        ReissueVoucher(TaxFreeRequest, TaxFreeVoucher);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6014610, 'OnVoucherLookup', '', false, false)]
    local procedure OnVoucherLookup(var TaxFreeRequest: Record "Tax Free Request"; VoucherNo: Text; var Handled: Boolean)
    begin
        if not TaxFreeRequest.IsThisHandler(HandlerID) then
            exit;

        Handled := true;
        Error(Error_NotSupported, TaxFreeRequest."Handler ID");
    end;

    [EventSubscriber(ObjectType::Codeunit, 6014610, 'OnVoucherPrint', '', false, false)]
    local procedure OnVoucherPrint(var TaxFreeRequest: Record "Tax Free Request"; TaxFreeVoucher: Record "Tax Free Voucher"; IsRecentVoucher: Boolean; var Handled: Boolean)
    begin
        if not TaxFreeRequest.IsThisHandler(HandlerID) then
            exit;

        Handled := true;
        if not IsRecentVoucher then //I2 only allows for reprint of recent voucher which is stored for the session. This can either be a just-issued voucher or a print-last attempt.
            Error(Error_NotSupported, TaxFreeRequest."Handler ID");

        ClearLastError;
        if not TryPrintVoucher(TaxFreeRequest) then
            Error(Error_PrintFail, TaxFreeVoucher."External Voucher No.", GetLastErrorText);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6014610, 'OnVoucherConsolidate', '', false, false)]
    local procedure OnVoucherConsolidate(var TaxFreeRequest: Record "Tax Free Request"; var tmpTaxFreeConsolidation: Record "Tax Free Consolidation" temporary; var Handled: Boolean)
    var
        tmpEligibleServices: Record "Tax Free GB I2 Service" temporary;
    begin
        if not TaxFreeRequest.IsThisHandler(HandlerID) then
            exit;

        Handled := true;
        InitializeHandler(TaxFreeRequest);

        if not IsConsolidationEligible(tmpTaxFreeConsolidation, tmpEligibleServices) then
            Error(Error_ConsolidationEligible);
        if tmpEligibleServices.IsEmpty then
            Error(Error_ConsolidationEligible);

        IssueVoucher(TaxFreeRequest, tmpTaxFreeConsolidation, tmpEligibleServices);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6014610, 'OnIsValidTerminalIIN', '', false, false)]
    local procedure OnIsValidTerminalIIN(var TaxFreeRequest: Record "Tax Free Request"; MaskedCardNo: Text; var IsForeignIIN: Boolean; var Handled: Boolean)
    begin
        if not TaxFreeRequest.IsThisHandler(HandlerID) then
            exit;

        Handled := true;
        InitializeHandler(TaxFreeRequest);
        IsForeignIIN := CheckIIN(MaskedCardNo);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6014610, 'OnIsActiveSaleEligible', '', false, false)]
    local procedure OnIsActiveSaleEligible(var TaxFreeRequest: Record "Tax Free Request"; SalesTicketNo: Code[20]; var Eligible: Boolean; var Handled: Boolean)
    var
        tmpEligibleServices: Record "Tax Free GB I2 Service" temporary;
    begin
        if not TaxFreeRequest.IsThisHandler(HandlerID) then
            exit;

        Handled := true;
        InitializeHandler(TaxFreeRequest);
        Eligible := IsActiveSaleEligible(SalesTicketNo, tmpEligibleServices);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6014610, 'OnIsStoredSaleEligible', '', false, false)]
    local procedure OnIsStoredSaleEligible(var TaxFreeRequest: Record "Tax Free Request"; SalesTicketNo: Code[20]; var Eligible: Boolean; var Handled: Boolean)
    var
        tmpEligibleServices: Record "Tax Free GB I2 Service" temporary;
    begin
        if not TaxFreeRequest.IsThisHandler(HandlerID) then
            exit;

        Handled := true;
        InitializeHandler(TaxFreeRequest);
        Eligible := IsStoredSaleEligible(SalesTicketNo, tmpEligibleServices);
    end;

    [EventSubscriber(ObjectType::Table, 6014641, 'OnAfterDeleteEvent', '', false, false)]
    local procedure OnAfterTaxFreeUnitDelete(var Rec: Record "Tax Free POS Unit"; RunTrigger: Boolean)
    var
        GlobalBlueParameters: Record "Tax Free GB I2 Parameter";
        GlobalBlueServices: Record "Tax Free GB I2 Service";
    begin
        if Rec.IsTemporary or (not RunTrigger) then
            exit;

        if not Rec.IsThisHandler(HandlerID) then
            exit;

        GlobalBlueParameters.SetRange("Tax Free Unit", Rec."POS Unit No.");
        GlobalBlueParameters.DeleteAll(true);

        GlobalBlueServices.SetRange("Tax Free Unit", Rec."POS Unit No.");
        GlobalBlueServices.DeleteAll(true);
    end;
}

