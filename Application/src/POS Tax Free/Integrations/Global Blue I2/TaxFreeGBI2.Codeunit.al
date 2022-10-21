﻿codeunit 6014613 "NPR Tax Free GB I2" implements "NPR Tax Free Handler Interface"
{
    Access = Internal;
    // Consumes Global Blue I2 solution, GRIPS MX API v16.06
    // 
    // test credentials:
    // Shop ID: 92179
    // Desk ID: 93585 //A4 voucher
    // Desk ID: 103661 //Thermal voucher
    // Username: TEST_SHOPID_92179
    // Password: TEST_SHOPID_92179
    var
        GlobalBlueParameters: Record "NPR Tax Free GB I2 Param.";
        GlobalBlueServices: Record "NPR Tax Free GB I2 Service";
        GlobalTaxFreeUnit: Record "NPR Tax Free POS Unit";
        Caption_ReissueConfirm: Label 'Are you sure you want to proceed with reissue of tax free voucher:\\%1: %2\%3: %4\%5: %6\\Reissuing a tax free voucher voids the current voucher and issues a new one in its place.\The current voucher will no longer be valid for tax free refunding.\\Please proceed only if the customer is present in the store!';
        Caption_VoidConfirm: Label 'Are you sure you want to proceed with void of tax free voucher:\\%1: %2\%3: %4\%5: %6\\It will no longer be valid for tax free refund!';
        Error_AutoConfigureFailure: Label 'Automatic desk configuration failed for handler %1. Cancelling tax free operation.';
        Caption_CancelOperation: Label 'Cancel tax free operation?';
        Error_ConsolidationEligible: Label 'Consolidation is not eligible. VAT or issue date is outside the allowed range.';
        Caption_UseID: Label 'Does the customer have Global Blue Tax Free identification available?';
        Caption_GlobalBlueIdentifier: Label 'Global Blue Card';
        Caption_MemberCard: Label 'Global Blue Member Card';
        Error_MinimumParameters: Label 'Global Blue Shop ID, Desk ID, Username and Password must be specified before auto desk configure can be performed.';
        Caption_TravellerLookupFail: Label 'Identifier lookup failed.';
        Caption_ConfirmIdentity: Label 'I have checked the travellers identity and eligibility by verifying both passport AND country of residence.\\Traveller Name: %1\Passport Number: %2\Country Of Residence: %3';
        Caption_InvalidIdentifier: Label 'Invalid identifier: %1. Global Blue card number must be at least 10 characters.';
        Error_InvalidResponse: Label 'Invalid response received from tax free server for:\Handler: %1\Request: %2';
        Error_MissingPrintSetup: Label 'Missing object output setup';
        Caption_MobileNo: Label 'Mobile Phone No.';
        Error_NotSupported: Label 'Operation is not supported by tax free handler %1';
        Error_UserCancel: Label 'Operation was cancelled by user.';
        Caption_Passport: Label 'Passport Information';
        Caption_IdentifierType: Label 'Please select a Global Blue identifier type:';
        Error_PrintFail: Label 'Printing of tax free voucher %1 failed with error "%2".\NOTE: The voucher is correctly issued and active. Please attempt using ''Reprint Last'' or reissuing the voucher if the print error persists.';
        Error_Ineligible: Label 'Sale is not eligible. VAT or issue date is outside the allowed range.';
        Error_Unknown: Label 'Unknown handler error. Could not retrieve error message from response.';
        Error_VoidLimit: Label 'Voucher %1 cannot be voided. The time limit has passed (%2 days).';

    local procedure ServicePROD(): Text
    begin
        exit('https://tisshost3.globalblue.com');
    end;

    local procedure ServiceTEST(): Text
    begin
        exit('https://mspe4https.globalblue.com');
    end;

    procedure InitializeHandler(TaxFreeRequest: Record "NPR Tax Free Request")
    var
        TaxFreeInterface: Codeunit "NPR Tax Free Handler Mgt.";
    begin
        GlobalTaxFreeUnit.Get(TaxFreeRequest."POS Unit No.");

        GlobalBlueParameters.Get(TaxFreeRequest."POS Unit No.");
        if (GlobalBlueParameters."Date Last Auto Configured" < Today) then begin
            TaxFreeInterface.UnitAutoConfigure(GlobalTaxFreeUnit, true); //Will silently run desk config & verify that NAS jobs are configured.
            GlobalBlueParameters.Get(TaxFreeRequest."POS Unit No.");
            if GlobalBlueParameters."Date Last Auto Configured" <> Today then
                Error(Error_AutoConfigureFailure, TaxFreeRequest."Handler ID Enum");
        end;

        GlobalBlueServices.SetRange("Tax Free Unit", TaxFreeRequest."POS Unit No.");
        GlobalBlueServices.FindSet();
    end;

    #region Actions
    local procedure DownloadDeskConfiguration(var TaxFreeRequest: Record "NPR Tax Free Request")
    var
        XMLDoc: XmlDocument;
    begin
        GetDeskConfiguration(TaxFreeRequest);

        ParseDesktopConfiguration(TaxFreeRequest, XMLDoc);
    end;

    procedure ParseDesktopConfiguration(var TaxFreeRequest: Record "NPR Tax Free Request"; XMLDoc: XmlDocument)
    var
        Value: Text;
        i: Integer;
        ServiceID: Integer;
        Services: XmlNodeList;
        ServiceCount: Integer;
        Service: XmlNode;
        ServiceIDFilterString: Text;
        IsError: Boolean;
    begin
        HandleResponse(TaxFreeRequest, 'GetDeskConfiguration', XMLDoc, IsError);

        if IsError then
            Error(TaxFreeRequest."Error Message");

        if not TrySelectSingleNodeText(XMLDoc, '//ClientIdentification/ShopCountryCode', Value) then
            Error(Error_InvalidResponse, GlobalTaxFreeUnit."Handler ID Enum", TaxFreeRequest."Request Type");
        Evaluate(GlobalBlueParameters."Shop Country Code", Value, 9);

        Services := XMLDoc.GetDescendantElements('Service');
        ServiceCount := Services.Count();
        if not (ServiceCount > 0) then
            Error(Error_InvalidResponse, GlobalTaxFreeUnit."Handler ID Enum", TaxFreeRequest."Request Type");

        for i := 1 to (ServiceCount) do begin //Update or create service records
            Services.Get(i, Service);

            if not TryGetItemInnerText(Service, 'ServiceID', Value) then
                Error(Error_InvalidResponse, GlobalTaxFreeUnit."Handler ID Enum", TaxFreeRequest."Request Type");
            Evaluate(ServiceID, Value, 9);

            if not GlobalBlueServices.Get(GlobalTaxFreeUnit."POS Unit No.", ServiceID) then begin
                GlobalBlueServices.Init();
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
        GlobalBlueServices.Reset();
        GlobalBlueServices.SetRange("Tax Free Unit", GlobalTaxFreeUnit."POS Unit No.");
        GlobalBlueServices.SetFilter("Service ID", ServiceIDFilterString);
        GlobalBlueServices.DeleteAll();


        GlobalBlueParameters."Date Last Auto Configured" := Today();
        GlobalBlueParameters.Modify(true);
        Commit();

        GlobalBlueServices.Reset();
        GlobalBlueServices.SetRange("Tax Free Unit", GlobalTaxFreeUnit."POS Unit No.");
        GlobalBlueServices.FindSet();
    end;

    procedure DownloadCountries(var TaxFreeRequest: Record "NPR Tax Free Request")
    var
        GlobalBlueCountries: Record "NPR Tax Free GB Country";
        IsError: Boolean;
        CountryCount: Integer;
        i: Integer;
        Value: Text;
        XMLDoc: XmlDocument;
        Country: XmlNode;
        Countries: XmlNodeList;
    begin
        GetCountries(TaxFreeRequest);
        HandleResponse(TaxFreeRequest, 'GetCountries', XMLDoc, IsError);
        if IsError then
            Error(TaxFreeRequest."Error Message");

        Countries := XMLDoc.GetDescendantElements('Country');
        CountryCount := Countries.Count();
        if not (CountryCount > 0) then
            Error(Error_InvalidResponse, GlobalTaxFreeUnit."Handler ID Enum", TaxFreeRequest."Request Type");

        GlobalBlueCountries.DeleteAll(false);
        for i := 1 to (CountryCount) do begin
            Countries.Get(i, Country);

            GlobalBlueCountries.Init();
            TryGetItemInnerText(Country, 'CountryCode', Value);
            Evaluate(GlobalBlueCountries."Country Code", Value);

            TryGetItemInnerText(Country, 'Name', Value);
            GlobalBlueCountries.Name := Value;

            if TryGetItemInnerText(Country, 'PhonePrefix', Value) then
                Evaluate(GlobalBlueCountries."Phone Prefix", Value, 9);
            if TryGetItemInnerText(Country, 'PassportCode', Value) then
                Evaluate(GlobalBlueCountries."Passport Code", Value, 9);
            if GlobalBlueCountries.Insert(false) then;
        end;
        Commit();

        TaxFreeRequest.Success := true;
        TaxFreeRequest."Date End" := Today();
        TaxFreeRequest."Time End" := Time;
    end;

    procedure DownloadBlockedCountries(var TaxFreeRequest: Record "NPR Tax Free Request")
    var
        GlobalBlueBlockedCountries: Record "NPR TaxFree GB BlockedCountry";
        IsError: Boolean;
        CountryCount: Integer;
        i: Integer;
        XMLDoc: XmlDocument;
        Country: XmlNode;
        Countries: XmlNodeList;
    begin
        GetBlockedCountries(TaxFreeRequest);
        HandleResponse(TaxFreeRequest, 'GetBlockedCountries', XMLDoc, IsError);
        if IsError then
            Error(TaxFreeRequest."Error Message");

        Countries := XMLDoc.GetDescendantElements('CountryCode');
        CountryCount := Countries.Count();
        if not (CountryCount > 0) then
            Error(Error_InvalidResponse, GlobalTaxFreeUnit."Handler ID Enum", TaxFreeRequest."Request Type");

        GlobalBlueBlockedCountries.SetRange("Shop Country Code", GlobalBlueParameters."Shop Country Code");
        GlobalBlueBlockedCountries.DeleteAll(false);
        GlobalBlueBlockedCountries.Reset();
        for i := 1 to (CountryCount) do begin
            Countries.Get(i, Country);

            GlobalBlueBlockedCountries.Init();
            GlobalBlueBlockedCountries."Shop Country Code" := GlobalBlueParameters."Shop Country Code";
            Evaluate(GlobalBlueBlockedCountries."Country Code", Country.AsXmlElement().InnerText, 9);
            if GlobalBlueBlockedCountries.Insert(false) then;
        end;
        Commit();

        TaxFreeRequest.Success := true;
        TaxFreeRequest."Date End" := Today();
        TaxFreeRequest."Time End" := Time;
    end;

    procedure DownloadCondensedTred(var TaxFreeRequest: Record "NPR Tax Free Request")
    var
        GlobalBlueIINBlacklist: Record "NPR Tax Free GB IIN Blacklist";
        IsError: Boolean;
        i: Integer;
        RangeCount: Integer;
        Value: Text;
        XMLDoc: XmlDocument;
        Range: XmlNode;
        Ranges: XmlNodeList;
    begin
        GetCondensedTred(TaxFreeRequest);
        HandleResponse(TaxFreeRequest, 'GetCondensedTred', XMLDoc, IsError);
        if IsError then
            Error(TaxFreeRequest."Error Message");

        Ranges := XMLDoc.GetDescendantElements('Range');
        RangeCount := Ranges.Count();
        if not (RangeCount > 0) then
            Error(Error_InvalidResponse, GlobalTaxFreeUnit."Handler ID Enum", TaxFreeRequest."Request Type");

        GlobalBlueIINBlacklist.SetRange("Shop Country Code", GlobalBlueParameters."Shop Country Code");
        GlobalBlueIINBlacklist.DeleteAll(false);
        GlobalBlueIINBlacklist.Reset();
        for i := 1 to (RangeCount) do begin
            Ranges.Get(1, Range);

            GlobalBlueIINBlacklist.Init();
            GlobalBlueIINBlacklist."Shop Country Code" := GlobalBlueParameters."Shop Country Code";
            TryGetItemInnerText(Range, 'PrefixFrom', Value);
            Evaluate(GlobalBlueIINBlacklist."Range Inclusive Start", Value, 9);
            TryGetItemInnerText(Range, 'PrefixTo', Value);
            Evaluate(GlobalBlueIINBlacklist."Range Exclusive End", Value, 9);

            if GlobalBlueIINBlacklist.Insert(false) then;
        end;
        Commit();

        TaxFreeRequest.Success := true;
        TaxFreeRequest."Date End" := Today();
        TaxFreeRequest."Time End" := Time;
    end;

    local procedure IssueVoucher(var TaxFreeRequest: Record "NPR Tax Free Request"; var tmpTaxFreeConsolidation: Record "NPR Tax Free Consolidation" temporary; var tmpEligibleServices: Record "NPR Tax Free GB I2 Service" temporary)
    var
        XMLDoc: XmlDocument;
        CustomerXML: Text;
        PaymentXML: Text;
        PurchaseXML: Text;
        Handeled: Boolean;
    begin
        //tmpTaxFreeConsolidation carries the sales receipts/documents to be consolidated into one tax free voucher.
        //In a normal flow with a single sale, it only holds one record.

        TaxFreeRequest."Service ID" := SelectService(tmpEligibleServices); //Can have modal prompts
        CustomerXML := CaptureCustomerInfo(); //Has modal prompts
        PurchaseXML := GetPurchaseDetailsXML(tmpTaxFreeConsolidation);
        PaymentXML := GetPurchasePaymentMethodsXML();

        OnBeforeIssueVoucher(TaxFreeRequest, CustomerXML, PaymentXML, PurchaseXML, Handeled);
        if Handeled then
            exit;

        IssueRenderedCheque(TaxFreeRequest, PurchaseXML, PaymentXML, CustomerXML);
        ParseIssueVoucher(TaxFreeRequest, XmlDoc);
    end;

    procedure ParseIssueVoucher(var TaxFreeRequest: Record "NPR Tax Free Request"; XMLDoc: xmlDocument)
    var
        TempBlob: Codeunit "Temp Blob";
        RecRef: RecordRef;
        IsError: Boolean;
        Value: Text;
    begin
        HandleResponse(TaxFreeRequest, 'IssueRenderedCheque', XMLDoc, IsError);
        if IsError then
            Error(TaxFreeRequest."Error Message");

        if not TrySelectSingleNodeText(XMLDoc, '//RenderedTFSFormRes/NumericDocIdentifier', Value) then
            Error(Error_InvalidResponse, TaxFreeRequest."Handler ID Enum", TaxFreeRequest."Request Type");
        TaxFreeRequest."External Voucher No." := Value;
        TaxFreeRequest."External Voucher Barcode" := Value;

        if not TrySelectSingleNodeText(XMLDoc, '//RenderedTFSFormRes/TotalGrossAmount', Value) then
            Error(Error_InvalidResponse, TaxFreeRequest."Handler ID Enum", TaxFreeRequest."Request Type");
        Evaluate(TaxFreeRequest."Total Amount Incl. VAT", Value, 9);

        if not TrySelectSingleNodeText(XMLDoc, '//RenderedTFSFormRes/TotalRefundAmount', Value) then
            Error(Error_InvalidResponse, TaxFreeRequest."Handler ID Enum", TaxFreeRequest."Request Type");
        Evaluate(TaxFreeRequest."Refund Amount", Value, 9);

        if not TrySelectSingleNodeText(XMLDoc, '//RenderedTFSFormRes/@mimetype', Value) then
            Error(Error_InvalidResponse, TaxFreeRequest."Handler ID Enum", TaxFreeRequest."Request Type");
        case true of
            Value = 'application/pdf':
                TaxFreeRequest."Print Type" := TaxFreeRequest."Print Type"::PDF;
            Value = 'text/plain':
                TaxFreeRequest."Print Type" := TaxFreeRequest."Print Type"::Thermal;
            else
                Error(Error_InvalidResponse, TaxFreeRequest."Handler ID Enum", TaxFreeRequest."Request Type");
        end;

        if not TrySelectSingleNodeText(XMLDoc, '//RenderedTFSFormRes/BinaryData/Value', Value) then
            Error(Error_InvalidResponse, TaxFreeRequest."Handler ID Enum", TaxFreeRequest."Request Type");
        Base64ToBlob(Value, TempBlob);

        RecRef.GetTable(TaxFreeRequest);
        TempBlob.ToRecordRef(RecRef, TaxFreeRequest.FieldNo(Print));
        RecRef.SetTable(TaxFreeRequest);
    end;

    local procedure ReissueVoucher(var TaxFreeRequest: Record "NPR Tax Free Request"; TaxFreeVoucher: Record "NPR Tax Free Voucher")
    var
        VoucherService: Record "NPR Tax Free GB I2 Service";
        XMLDoc: XmlDocument;
        NoOfDaysLbl: Label '<%1D>', Locked = true;
    begin
        if VoucherService.Get(TaxFreeVoucher."POS Unit No.", TaxFreeVoucher."Service ID") then
            if VoucherService."Void Limit In Days" <> 0 then
                if CalcDate(StrSubstNo(NoOfDaysLbl, VoucherService."Void Limit In Days"), TaxFreeVoucher."Issued Date") < Today then
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
        ParseReissueVoucher(TaxFreeRequest, XMLDoc);
    end;

    local procedure ParseReissueVoucher(var TaxFreeRequest: Record "NPR Tax Free Request"; XMLDoc: XmlDocument)
    var
        TempBlob: Codeunit "Temp Blob";
        RecRef: RecordRef;
        IsError: Boolean;
        Value: Text;
    begin
        HandleResponse(TaxFreeRequest, 'ReissueRenderedCheque', XMLDoc, IsError);
        if IsError then
            Error(TaxFreeRequest."Error Message");

        if not TrySelectSingleNodeText(XMLDoc, '//RenderedTFSFormRes/NumericDocIdentifier', Value) then
            Error(Error_InvalidResponse, TaxFreeRequest."Handler ID Enum", TaxFreeRequest."Request Type");
        TaxFreeRequest."External Voucher No." := Value;
        TaxFreeRequest."External Voucher Barcode" := Value;

        if not TrySelectSingleNodeText(XMLDoc, '//RenderedTFSFormRes/TotalGrossAmount', Value) then
            Error(Error_InvalidResponse, TaxFreeRequest."Handler ID Enum", TaxFreeRequest."Request Type");
        Evaluate(TaxFreeRequest."Total Amount Incl. VAT", Value, 9);

        if not TrySelectSingleNodeText(XMLDoc, '//RenderedTFSFormRes/TotalRefundAmount', Value) then
            Error(Error_InvalidResponse, TaxFreeRequest."Handler ID Enum", TaxFreeRequest."Request Type");
        Evaluate(TaxFreeRequest."Refund Amount", Value, 9);

        if not TrySelectSingleNodeText(XMLDoc, '//RenderedTFSFormRes/@mimetype', Value) then
            Error(Error_InvalidResponse, TaxFreeRequest."Handler ID Enum", TaxFreeRequest."Request Type");
        case true of
            Value = 'application/pdf':
                TaxFreeRequest."Print Type" := TaxFreeRequest."Print Type"::PDF;
            Value = 'text/plain':
                TaxFreeRequest."Print Type" := TaxFreeRequest."Print Type"::Thermal;
            else
                Error(Error_InvalidResponse, TaxFreeRequest."Handler ID Enum", TaxFreeRequest."Request Type");
        end;

        if not TrySelectSingleNodeText(XMLDoc, '//RenderedTFSFormRes/BinaryData/Value', Value) then
            Error(Error_InvalidResponse, TaxFreeRequest."Handler ID Enum", TaxFreeRequest."Request Type");
        Base64ToBlob(Value, TempBlob);

        RecRef.GetTable(TaxFreeRequest);
        TempBlob.ToRecordRef(RecRef, TaxFreeRequest.FieldNo(Print));
        RecRef.SetTable(TaxFreeRequest);
    end;

    local procedure VoidVoucher(var TaxFreeRequest: Record "NPR Tax Free Request"; TaxFreeVoucher: Record "NPR Tax Free Voucher")
    var
        VoucherService: Record "NPR Tax Free GB I2 Service";
        XMLDoc: XmlDocument;
        NoOfDaysLbl: Label '<%1D>', Locked = true;
    begin
        if VoucherService.Get(TaxFreeVoucher."POS Unit No.", TaxFreeVoucher."Service ID") then
            if VoucherService."Void Limit In Days" <> 0 then
                if CalcDate(StrSubstNo(NoOfDaysLbl, VoucherService."Void Limit In Days"), TaxFreeVoucher."Issued Date") < Today then
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
        ParseVoidVoucher(TaxFreeRequest, XMLDoc);
    end;

    procedure ParseVoidVoucher(var TaxFreeRequest: Record "NPR Tax Free Request"; XMLDoc: XmlDocument)
    var
        IsError: Boolean;
    begin
        HandleResponse(TaxFreeRequest, 'VoidCheque', XMLDoc, IsError);
        if IsError then
            Error(TaxFreeRequest."Error Message");
    end;

    local procedure CheckIIN(IIN: Text): Boolean
    var
        GlobalBlueIINBlacklist: Record "NPR Tax Free GB IIN Blacklist";
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

        exit(GlobalBlueIINBlacklist.IsEmpty());
    end;

    [TryFunction]
    local procedure TryLookupTraveller(var tmpCustomerInfoCapture: Record "NPR TaxFree GB I2 Info Capt." temporary)
    var
        TaxFreeRequest: Record "NPR Tax Free Request";
        IsError: Boolean;
        Value: Text;
        XMLDoc: XmlDocument;
    begin
        TaxFreeRequest.Init();
        TaxFreeRequest."Request Type" := 'LOOKUP_TRAVELLER';
        TaxFreeRequest.Mode := GlobalTaxFreeUnit.Mode;
        TaxFreeRequest."Timeout (ms)" := GlobalTaxFreeUnit."Request Timeout (ms)";
        TaxFreeRequest."Time Start" := Time;
        TaxFreeRequest."Date Start" := Today();

        GetTraveller(TaxFreeRequest, tmpCustomerInfoCapture);
        HandleResponse(TaxFreeRequest, 'GetTraveller', XMLDoc, IsError);
        if IsError then
            Error(TaxFreeRequest."Error Message");

        //Necessary data for UI confirm
        if not TrySelectSingleNodeText(XMLDoc, '//TravellerRes/FirstName', Value) then
            Error(Error_InvalidResponse, TaxFreeRequest."Handler ID Enum", TaxFreeRequest."Request Type");
        tmpCustomerInfoCapture."First Name" := Value;

        if not TrySelectSingleNodeText(XMLDoc, '//TravellerRes/LastName', Value) then
            Error(Error_InvalidResponse, TaxFreeRequest."Handler ID Enum", TaxFreeRequest."Request Type");
        tmpCustomerInfoCapture."Last Name" := Value;

        if not TrySelectSingleNodeText(XMLDoc, '//TravellerRes/Passport/PassportNumber', Value) then
            Error(Error_InvalidResponse, TaxFreeRequest."Handler ID Enum", TaxFreeRequest."Request Type");
        tmpCustomerInfoCapture."Passport Number" := Value;

        if not TrySelectSingleNodeText(XMLDoc, '//TravellerRes/Address/CountryCode', Value) then
            Error(Error_InvalidResponse, TaxFreeRequest."Handler ID Enum", TaxFreeRequest."Request Type");
        Evaluate(tmpCustomerInfoCapture."Country Of Residence Code", Value, 9);

        if not TrySelectSingleNodeText(XMLDoc, '//TravellerRes/Address/CountryName', Value) then
            Error(Error_InvalidResponse, TaxFreeRequest."Handler ID Enum", TaxFreeRequest."Request Type");
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
        TaxFreeRequest."Date End" := Today();
        TaxFreeRequest."Time End" := Time;
    end;

    #endregion

    #region Print Functions

    [TryFunction]
    local procedure TryPrintVoucher(TaxFreeRequest: Record "NPR Tax Free Request")
    begin
        case TaxFreeRequest."Print Type" of
            TaxFreeRequest."Print Type"::Thermal:
                PrintThermal(TaxFreeRequest);
            TaxFreeRequest."Print Type"::PDF:
                PrintPDF(TaxFreeRequest);
        end;
    end;

    local procedure PrintThermal(TaxFreeRequest: Record "NPR Tax Free Request")
    var
        ObjectOutputMgt: Codeunit "NPR Object Output Mgt.";
        Printer: Codeunit "NPR RP Line Print Mgt.";
        InStream: InStream;
        Line: Text;
        Output: Text;
    begin
        Output := ObjectOutputMgt.GetCodeunitOutputPath(CODEUNIT::"NPR Tax Free Receipt");
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

        Printer.ProcessBuffer(Codeunit::"NPR Tax Free Receipt", Enum::"NPR Line Printer Device"::Epson);
    end;

    local procedure PrintThermalLine(var Printer: Codeunit "NPR RP Line Print Mgt."; Line: Text)
    var
        Bold: Boolean;
        Center: Boolean;
        HFont: Boolean;
        Inverse: Boolean;
        String: Text;
        StringUpper: Text;
        Value: Text;
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

    local procedure PrintPDF(TaxFreeRequest: Record "NPR Tax Free Request")
    var
        ObjectOutputSelection: Record "NPR Object Output Selection";
        ObjectOutputMgt: Codeunit "NPR Object Output Mgt.";
        PrintMethodMgt: Codeunit "NPR Print Method Mgt.";
        InStream: InStream;
        OutputType: Integer;
        Output: Text;
    begin
        TaxFreeRequest.Print.CreateInStream(InStream);

        Output := ObjectOutputMgt.GetCodeunitOutputPath(CODEUNIT::"NPR Tax Free Receipt");
        OutputType := ObjectOutputMgt.GetCodeunitOutputType(CODEUNIT::"NPR Tax Free Receipt");

        if Output = '' then
            Error(Error_MissingPrintSetup);

        case OutputType of
            ObjectOutputSelection."Output Type"::"Printer Name".AsInteger():
                PrintMethodMgt.PrintFileLocal(Output, InStream, 'pdf');
        end;
    end;

    local procedure Base64ToBlob(base64: Text; var TempBlobOut: Codeunit "Temp Blob")
    var
        Base64Convert: Codeunit "Base64 Convert";
        OutStream: OutStream;
    begin
        TempBlobOut.CreateOutStream(OutStream);
        Base64Convert.FromBase64(base64, OutStream);
    end;

    #endregion

    #region API Functions

    local procedure GetDeskConfiguration(var TaxFreeRequest: Record "NPR Tax Free Request")
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

    local procedure GetTraveller(var TaxFreeRequest: Record "NPR Tax Free Request"; var tmpCustomerInfoCapture: Record "NPR TaxFree GB I2 Info Capt." temporary)
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

    local procedure IssueRenderedCheque(var TaxFreeRequest: Record "NPR Tax Free Request"; PurchaseDetailsXML: Text; PaymentMethodsXML: Text; TravellerInfoXML: Text)
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

    local procedure ReissueRenderedCheque(var TaxFreeRequest: Record "NPR Tax Free Request"; VoucherID: Text; TotalGrossAmount: Text)
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
              '<Version>' + POSVersion() + '</Version>' +
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

    local procedure VoidCheque(var TaxFreeRequest: Record "NPR Tax Free Request"; VoucherID: Text; TotalGrossAmount: Text)
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
              '<Version>' + POSVersion() + '</Version>' +
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

    local procedure GetCountries(var TaxFreeRequest: Record "NPR Tax Free Request")
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

    local procedure GetBlockedCountries(var TaxFreeRequest: Record "NPR Tax Free Request")
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

    local procedure GetCondensedTred(var TaxFreeRequest: Record "NPR Tax Free Request")
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

    local procedure InvokeService(XMLRequest: Text; var TaxFreeRequest: Record "NPR Tax Free Request"): Text
    var
        HttpClient: HttpClient;
        HttpContent: HttpContent;
        HttpResponseMessage: HttpResponseMessage;
        HttpRequestMessage: HttpRequestMessage;
        OutStream: OutStream;
        Result: Text;
        HttpHeaders: HttpHeaders;
    begin
        if (GlobalBlueParameters."Shop ID" = '') or (GlobalBlueParameters."Desk ID" = '') or (GlobalBlueParameters.Username = '') or (GlobalBlueParameters.Password = '') then
            Error(Error_MinimumParameters);

        TaxFreeRequest.Request.CreateOutStream(OutStream, TEXTENCODING::UTF8);
        OutStream.Write(XMLRequest);
        Clear(OutStream);

        HttpClient.DefaultRequestHeaders.Clear();

        if TaxFreeRequest.Mode = TaxFreeRequest.Mode::PROD then
            HttpRequestMessage.SetRequestUri(ServicePROD())
        else
            HttpRequestMessage.SetRequestUri(ServiceTEST());

        if TaxFreeRequest."Timeout (ms)" > 0 then
            HttpClient.Timeout := TaxFreeRequest."Timeout (ms)"
        else
            HttpClient.Timeout := 10000;

        HttpContent.WriteFrom(XMLRequest);
        HttpContent.GetHeaders(HttpHeaders);

        HttpHeaders.Remove('Content-Type');
        HttpHeaders.Add('Content-Type', 'text/xml; charset="utf-8"');

        HttpRequestMessage.Method('POST');
        HttpRequestMessage.Content := HttpContent;

        if not HttpClient.Send(HttpRequestMessage, HttpResponseMessage) then
            error('%1 - %2', HttpResponseMessage.HttpStatusCode, HttpResponseMessage.ReasonPhrase);

        TaxFreeRequest.Response.CreateOutStream(OutStream, TEXTENCODING::UTF8);
        HttpResponseMessage.Content.ReadAs(Result);
        OutStream.Write(Result);
    end;

    local procedure HandleResponse(var TaxFreeRequest: Record "NPR Tax Free Request"; ExpectedOperation: Text; var XMLDoc: XmlDocument; var IsError: Boolean)
    var
        XMLDOMMtg: Codeunit "XML DOM Management";
        InStream: InStream;
        Value: Text;
        XMLMessage: Text;
    begin
        TaxFreeRequest.Response.CreateInStream(InStream);
        InStream.Read(XMLMessage);

        XMLMessage := XMLDOMMtg.RemoveNamespaces(XMLMessage);

        XmlDocument.ReadFrom(XMLMessage, XMLDoc);

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
        TypeHelper: Codeunit "Type Helper";
    begin
        TypeHelper.HtmlEncode(Value);
        exit(Value);
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
        SystemEventWrapper: Codeunit "NPR System Event Wrapper";
    begin
        exit(EscapeSpecialChars(SystemEventWrapper.ApplicationVersion()));
    end;

    local procedure FormattedDateTime(): Text
    begin
        exit(Format(CurrentDateTime, 0, 9));
    end;

    var
        ParsingHandlerErr: Label 'Parsing Error TrySelectSingleNodeText';

    [TryFunction]
    local procedure TrySelectSingleNodeText(var XMLDoc: XmlDocument; XPath: Text; var Value: Text)
    var
        XMLNode: XmlNode;

    begin
        XMLDoc.SelectSingleNode(XPath, XMLNode);
        case true of
            XMLNode.IsXmlElement:
                Value := XMLNode.AsXmlElement().InnerText;
            XMLNode.IsXmlAttribute:
                Value := XMLNode.AsXmlAttribute().Value;
            else
                Error(ParsingHandlerErr);
        end
    end;

    [TryFunction]
    local procedure TryGetItemInnerText(var XmlNode: XmlNode; ItemName: Text; var Value: Text)
    var
        InnerTextNode: XmlNode;
    begin
        XmlNode.SelectSingleNode(ItemName, InnerTextNode);
        case true of
            XMLNode.IsXmlElement:
                Value := InnerTextNode.AsXmlElement().InnerText;
            XMLNode.IsXmlAttribute:
                Value := InnerTextNode.AsXmlAttribute().Value;
            else
                Error(ParsingHandlerErr);
        end
    end;
    #endregion

    #region Aux

    local procedure CaptureCustomerInfo(): Text
    var
        TempCustomerInfoCapture: Record "NPR TaxFree GB I2 Info Capt." temporary;
    begin
        TempCustomerInfoCapture.Init();
        TempCustomerInfoCapture."Shop Country Code" := GlobalBlueParameters."Shop Country Code";
        TempCustomerInfoCapture.Insert();

        if Confirm(Caption_UseID) then begin
            if not ScanCustomerID(TempCustomerInfoCapture) then
                exit(CaptureCustomerInfo()); //Aborted - Restart capture flow
        end;

        if not IsAllRequiredCustomerInfoCaptured(TempCustomerInfoCapture) then begin
            TempCustomerInfoCapture."Is Identity Checked" := false;
            if not ManualCustomerInfoEntry(TempCustomerInfoCapture) then begin
                if Confirm(Caption_CancelOperation) then
                    Error(Error_UserCancel)
                else
                    exit(CaptureCustomerInfo()); //Restart capture flow
            end;
        end;

        exit(GetCustomerInfoXML(TempCustomerInfoCapture));
    end;

    local procedure ScanCustomerID(var tmpCustomerInfoCapture: Record "NPR TaxFree GB I2 Info Capt." temporary): Boolean
    var
        Captured: Boolean;
        IDType: Integer;
        CustomerIDLbl: Label '%1,%2,%3', Locked = true;
    begin
        IDType := StrMenu(StrSubstNo(CustomerIDLbl, Caption_MemberCard, Caption_MobileNo, Caption_Passport), 1, Caption_IdentifierType);

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

    local procedure GetMobileNoIdentifier(var tmpCustomerInfoCapture: Record "NPR TaxFree GB I2 Info Capt." temporary): Boolean
    var
        TravellerInfoCapture: Page "NPR Tax Free GB I2 Info Capt.";
        TempMobilePhoneNoCapture: Record "NPR TaxFree GB I2 Info Capt." temporary;
        TempMobilePhoneRequiredParam: Record "NPR Tax Free GB I2 Param." temporary;
    begin
        TempMobilePhoneRequiredParam.Init();
        TempMobilePhoneRequiredParam."(Dialog) Mobile No." := TempMobilePhoneRequiredParam."(Dialog) Mobile No."::Required;
        TempMobilePhoneRequiredParam.Insert();
        TempMobilePhoneNoCapture.Init();
        TempMobilePhoneNoCapture."Shop Country Code" := GlobalBlueParameters."Shop Country Code";
        TempMobilePhoneNoCapture.Insert();

        TravellerInfoCapture.SetModes(TempMobilePhoneRequiredParam);
        TravellerInfoCapture.SetRec(TempMobilePhoneNoCapture);
        TravellerInfoCapture.LookupMode(true);
        if TravellerInfoCapture.RunModal() <> ACTION::LookupOK then
            exit(false); //Restart capture flow

        TravellerInfoCapture.GetRec(TempMobilePhoneNoCapture);
        tmpCustomerInfoCapture."Mobile No." := TempMobilePhoneNoCapture."Mobile No.";
        tmpCustomerInfoCapture."Mobile No. Country" := TempMobilePhoneNoCapture."Mobile No. Country";
        tmpCustomerInfoCapture."Mobile No. Prefix" := TempMobilePhoneNoCapture."Mobile No. Prefix";
        tmpCustomerInfoCapture."Mobile No. Prefix Formatted" := TempMobilePhoneNoCapture."Mobile No. Prefix Formatted";

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

    local procedure GetPassportIdentifier(var tmpCustomerInfoCapture: Record "NPR TaxFree GB I2 Info Capt." temporary): Boolean
    var
        TravellerInfoCapture: Page "NPR Tax Free GB I2 Info Capt.";
        TempPassportCapture: Record "NPR TaxFree GB I2 Info Capt." temporary;
        TempPassportRequiredParam: Record "NPR Tax Free GB I2 Param." temporary;
    begin
        TempPassportRequiredParam.Init();
        TempPassportRequiredParam."(Dialog) Passport Number" := TempPassportRequiredParam."(Dialog) Passport Number"::Required;
        TempPassportRequiredParam."(Dialog) Passport Country Code" := TempPassportRequiredParam."(Dialog) Passport Country Code"::Required;
        TempPassportRequiredParam.Insert();
        TempPassportCapture.Init();
        TempPassportCapture."Shop Country Code" := GlobalBlueParameters."Shop Country Code";
        TempPassportCapture.Insert();

        TravellerInfoCapture.SetModes(TempPassportRequiredParam);
        TravellerInfoCapture.SetRec(TempPassportCapture);
        TravellerInfoCapture.LookupMode(true);
        if TravellerInfoCapture.RunModal() <> ACTION::LookupOK then
            exit(false); //Restart capture flow

        TravellerInfoCapture.GetRec(TempPassportCapture);
        tmpCustomerInfoCapture."Passport Country" := TempPassportCapture."Passport Country";
        tmpCustomerInfoCapture."Passport Country Code" := TempPassportCapture."Passport Country Code";
        tmpCustomerInfoCapture."Passport Number" := TempPassportCapture."Passport Number";

        //Identifier = [Passport Country Code]+[UPPERCASE(Passport Number)]
        tmpCustomerInfoCapture."Global Blue Identifier" := Format(tmpCustomerInfoCapture."Passport Country Code") + '+' + UpperCase(tmpCustomerInfoCapture."Passport Number");

        if not TryLookupTraveller(tmpCustomerInfoCapture) then begin
            Message(Caption_TravellerLookupFail);
            exit(false); //Restart capture flow
        end;

        exit(true);
    end;

    local procedure GetGlobalBlueCardIdentifier(var tmpCustomerInfoCapture: Record "NPR TaxFree GB I2 Info Capt." temporary): Boolean
    var
        InputDialog: Page "NPR Input Dialog";
        ScanAction: Action;
        Input: Text;
    begin
        InputDialog.LookupMode(true);
        InputDialog.SetInput(1, Input, Caption_GlobalBlueIdentifier);
        ScanAction := InputDialog.RunModal();
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

    local procedure ManualCustomerInfoEntry(var tmpCustomerInfoCapture: Record "NPR TaxFree GB I2 Info Capt." temporary): Boolean
    var
        TravellerInfoCapture: Page "NPR Tax Free GB I2 Info Capt.";
    begin
        TravellerInfoCapture.SetModes(GlobalBlueParameters);
        TravellerInfoCapture.SetRec(tmpCustomerInfoCapture); //Will set filled out data as read-only.
        TravellerInfoCapture.LookupMode(true);
        if TravellerInfoCapture.RunModal() = ACTION::LookupOK then begin
            TravellerInfoCapture.GetRec(tmpCustomerInfoCapture);
            exit(true);
        end;
    end;

    local procedure IsAllRequiredCustomerInfoCaptured(var tmpCustomerInfoCapture: Record "NPR TaxFree GB I2 Info Capt." temporary): Boolean
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

    local procedure IsConsolidationEligible(var tmpTaxFreeConsolidation: Record "NPR Tax Free Consolidation" temporary; var tmpEligibleServices: Record "NPR Tax Free GB I2 Service" temporary): Boolean
    begin
        if not GlobalBlueParameters."Consolidation Allowed" then
            exit(false);

        if not tmpTaxFreeConsolidation.FindSet() then
            exit(false);

        if GlobalBlueParameters."Consolidation Separate Limits" then
            exit(IsConsolidationEligibleSeperate(tmpTaxFreeConsolidation, tmpEligibleServices))
        else
            exit(IsConsolidationEligibleShared(tmpTaxFreeConsolidation, tmpEligibleServices));
    end;

    local procedure IsConsolidationEligibleSeperate(var tmpTaxFreeConsolidation: Record "NPR Tax Free Consolidation" temporary; var tmpEligibleServices: Record "NPR Tax Free GB I2 Service" temporary): Boolean
    var
        TempSharedEligibleServices: Record "NPR Tax Free GB I2 Service" temporary;
        Eligible: Boolean;
        First: Boolean;
        FilterString: Text;
    begin
        //Check each sale seperately and make sure they share an eligible service

        First := true;
        repeat
            Eligible := IsStoredSaleEligible(tmpTaxFreeConsolidation."Sales Ticket No.", tmpEligibleServices);

            if Eligible then begin
                tmpEligibleServices.FindSet();
                repeat
                    if First then begin
                        TempSharedEligibleServices.Init();
                        TempSharedEligibleServices.TransferFields(tmpEligibleServices);
                        TempSharedEligibleServices.Insert();
                    end else begin
                        if not TempSharedEligibleServices.Get(tmpEligibleServices."Tax Free Unit", tmpEligibleServices."Service ID") then begin
                            if FilterString <> '' then
                                FilterString += '&';
                            FilterString += '<>' + Format(tmpEligibleServices."Service ID");
                        end;
                    end;
                until tmpEligibleServices.Next() = 0;

                if FilterString <> '' then begin
                    //Delete every non-shared service
                    TempSharedEligibleServices.SetFilter("Service ID", FilterString);
                    TempSharedEligibleServices.DeleteAll();
                    TempSharedEligibleServices.SetRange("Service ID");
                end;
            end;

            First := false;
            tmpEligibleServices.DeleteAll();
            Clear(tmpEligibleServices);
            Clear(FilterString);
            Eligible := Eligible and (not TempSharedEligibleServices.IsEmpty());
        until (tmpTaxFreeConsolidation.Next() = 0) or (not Eligible);

        if Eligible then
            tmpEligibleServices.Copy(TempSharedEligibleServices, true);

        exit(Eligible);
    end;

    local procedure IsConsolidationEligibleShared(var tmpTaxFreeConsolidation: Record "NPR Tax Free Consolidation" temporary; var tmpEligibleServices: Record "NPR Tax Free GB I2 Service" temporary): Boolean
    var
        Item: Record Item;
        POSSalesLine: Record "NPR POS Entry Sales Line";
        SalesAmount: Decimal;
        POSEntry: Record "NPR POS Entry";
    begin
        repeat
            POSSalesLine.Reset();
            Clear(POSSalesLine);

            POSSalesLine.SetCurrentKey("Document No.", "Line No.");
            POSSalesLine.SetRange("Document No.", tmpTaxFreeConsolidation."Sales Ticket No.");
            POSSalesLine.SetRange(Type, POSSalesLine.Type::Item);
            POSSalesLine.SetFilter(Quantity, '>0');
            POSSalesLine.SetFilter("VAT %", '>0');

            if not POSSalesLine.FindSet() then
                exit(false);

            POSEntry.Get(POSSalesLine."POS Entry No.");

            if POSEntry."Entry Type" <> POSEntry."Entry Type"::"Direct Sale" then
                exit;

            POSSalesLine.CalcFields("Entry Date");
            if CalcDate(GlobalBlueParameters."Voucher Issue Date Limit", POSSalesLine."Entry Date") < Today then
                exit(false);

            if GlobalBlueParameters."Count Zero VAT Goods For Limit" then
                POSSalesLine.SetRange("VAT %");

            if GlobalBlueParameters."Services Eligible" then begin
                POSSalesLine.CalcSums("Amount Incl. VAT");
                SalesAmount += POSSalesLine."Amount Incl. VAT";
            end else begin
                repeat
                    Item.Get(POSSalesLine."No.");
                    if Item.Type = Item.Type::Inventory then
                        SalesAmount += POSSalesLine."Amount Incl. VAT";
                until POSSalesLine.Next() = 0;
            end;
        until tmpTaxFreeConsolidation.Next() = 0;

        GetEligibleServices(SalesAmount, tmpEligibleServices);
        exit(not tmpEligibleServices.IsEmpty());
    end;

    local procedure IsStoredSaleEligible(SalesTicketNo: Text; var tmpEligibleServices: Record "NPR Tax Free GB I2 Service" temporary): Boolean
    var
        Item: Record Item;
        POSSalesLine: Record "NPR POS Entry Sales Line";
        SaleAmount: Decimal;
        POSEntry: Record "NPR POS Entry";
    begin
        POSSalesLine.SetCurrentKey("Document No.", "Line No.");
        POSSalesLine.SetRange("Document No.", SalesTicketNo);
        POSSalesLine.SetRange(Type, POSSalesLine.Type::Item);
        POSSalesLine.SetFilter(Quantity, '>0');
        POSSalesLine.SetFilter("VAT %", '>0');

        if not POSSalesLine.FindSet() then
            exit(false);

        POSEntry.Get(POSSalesLine."POS Entry No.");

        if POSEntry."Entry Type" <> POSEntry."Entry Type"::"Direct Sale" then
            exit;

        POSSalesLine.CalcFields("Entry Date");
        if CalcDate(GlobalBlueParameters."Voucher Issue Date Limit", POSSalesLine."Entry Date") < Today then
            exit(false);

        if GlobalBlueParameters."Count Zero VAT Goods For Limit" then
            POSSalesLine.SetRange("VAT %");

        if GlobalBlueParameters."Services Eligible" then begin
            POSSalesLine.CalcSums("Amount Incl. VAT");
            SaleAmount := POSSalesLine."Amount Incl. VAT";
        end else begin
            repeat
                Item.Get(POSSalesLine."No.");
                if Item.Type = Item.Type::Inventory then
                    SaleAmount += POSSalesLine."Amount Incl. VAT";
            until POSSalesLine.Next() = 0;
        end;

        GetEligibleServices(SaleAmount, tmpEligibleServices);
        exit(not tmpEligibleServices.IsEmpty());
    end;

    local procedure IsActiveSaleEligible(SalesTicketNo: Text; var tmpEligibleServices: Record "NPR Tax Free GB I2 Service" temporary): Boolean
    var
        Item: Record Item;
        SaleLinePOS: Record "NPR POS Sale Line";
        SalePOS: Record "NPR POS Sale";
        SaleAmount: Decimal;
    begin
        SaleLinePOS.SetRange("Sales Ticket No.", SalesTicketNo);
        SaleLinePOS.SetRange("Line Type", SaleLinePOS."Line Type"::Item);
        SaleLinePOS.SetFilter(Quantity, '>0');
        SaleLinePOS.SetFilter("VAT %", '>0');

        if not SaleLinePOS.FindSet() then
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
            until SaleLinePOS.Next() = 0;
        end;

        GetEligibleServices(SaleAmount, tmpEligibleServices);
        exit(not tmpEligibleServices.IsEmpty());
    end;

    local procedure GetEligibleServices(SaleAmount: Decimal; var tmpEligibleServices: Record "NPR Tax Free GB I2 Service" temporary)
    begin
        if GlobalBlueServices.FindSet() then
            repeat
                if (GlobalBlueServices."Minimum Purchase Amount" <> 0) and (GlobalBlueServices."Maximum Purchase Amount" <> 0) then begin //Both upper and lower bound
                    if (GlobalBlueServices."Minimum Purchase Amount" <= SaleAmount) and (SaleAmount <= GlobalBlueServices."Maximum Purchase Amount") then begin
                        tmpEligibleServices.Init();
                        tmpEligibleServices.TransferFields(GlobalBlueServices);
                        tmpEligibleServices.Insert();
                    end;
                end else
                    if (GlobalBlueServices."Maximum Purchase Amount" = 0) then begin //Only lower bound
                        if (GlobalBlueServices."Minimum Purchase Amount" <= SaleAmount) then begin
                            tmpEligibleServices.Init();
                            tmpEligibleServices.TransferFields(GlobalBlueServices);
                            tmpEligibleServices.Insert();
                        end;
                    end else begin //Only upper bound
                        if (SaleAmount <= GlobalBlueServices."Maximum Purchase Amount") then begin
                            tmpEligibleServices.Init();
                            tmpEligibleServices.TransferFields(GlobalBlueServices);
                            tmpEligibleServices.Insert();
                        end;
                    end;
            until GlobalBlueServices.Next() = 0;
    end;

    local procedure SelectService(var tmpEligibleServices: Record "NPR Tax Free GB I2 Service" temporary): Integer
    begin
        if tmpEligibleServices.Count() = 1 then
            exit(tmpEligibleServices."Service ID");

        tmpEligibleServices.FindSet();
        if PAGE.RunModal(PAGE::"NPR Tax Free GB I2 Serv. Sel.", tmpEligibleServices) <> ACTION::LookupOK then begin
            if Confirm(Caption_CancelOperation) then
                Error(Error_UserCancel)
            else
                exit(SelectService(tmpEligibleServices));
        end;

        exit(tmpEligibleServices."Service ID");
    end;

    local procedure GetPurchaseDetailsXML(var tmpTaxFreeConsolidation: Record "NPR Tax Free Consolidation" temporary): Text
    var
        Item: Record Item;
        PosSalesLine: Record "NPR POS Entry Sales Line";
        XML: Text;
        XmlLbl: Label '<ReceiptDateTime>%1</ReceiptDateTime>', Locked = true;
        Xml2Lbl: Label '<ReceiptNumber>%1</ReceiptNumber>', Locked = true;
    begin
        XML := '<PurchaseDetails>';
        tmpTaxFreeConsolidation.FindSet();
        repeat
            PosSalesLine.Reset();
            Clear(PosSalesLine);
            PosSalesLine.SetRange("Document No.", tmpTaxFreeConsolidation."Sales Ticket No.");
            PosSalesLine.SetRange(Type, PosSalesLine.Type::Item);
            PosSalesLine.SetFilter(Quantity, '>0');
            PosSalesLine.FindSet();
            POSSalesLine.CalcFields("Entry Date", "Ending Time");

            XML += '<Receipt>';
            XML += StrSubstNo(XmlLbl, Format(CreateDateTime(PosSalesLine."Entry Date", PosSalesLine."Ending Time"), 0, 9));
            XML += StrSubstNo(Xml2Lbl, Format(PosSalesLine."Document No.", 0, 9));
            XML += '<PurchaseItems>';
            repeat
                Item.Get(PosSalesLine."No.");
                if ((Item.Type = Item.Type::Inventory) or (GlobalBlueParameters."Services Eligible")) then begin
                    XML += '<PurchaseItem>';
                    XML += '<VATRate>' + Format(PosSalesLine."VAT %", 0, '<Precision,2:2><Standard Format,2>') + '</VATRate>';
                    XML += '<GrossAmount>' + Format(PosSalesLine."Amount Incl. VAT", 0, '<Precision,2:2><Standard Format,2>') + '</GrossAmount>';
                    XML += '<VATAmount>' + Format(PosSalesLine."Amount Incl. VAT" - PosSalesLine."Amount Excl. VAT", 0, '<Precision,2:2><Standard Format,2>') + '</VATAmount>';
                    XML += '<NetAmount>' + Format(PosSalesLine."Amount Excl. VAT", 0, '<Precision,2:2><Standard Format,2>') + '</NetAmount>';
                    XML += '<Quantity>' + Format(Round(PosSalesLine.Quantity, 1, '>')) + '</Quantity>'; //Round up - They only accept integer quantity
                    XML += '<GoodDescription>' + Format(CopyStr(EscapeSpecialChars(PosSalesLine.Description), 1, 50)) + '</GoodDescription>';
                    XML += '</PurchaseItem>';
                end;
            until PosSalesLine.Next() = 0;
            XML += '</PurchaseItems>';
            XML += '</Receipt>';
        until tmpTaxFreeConsolidation.Next() = 0;
        XML += '</PurchaseDetails>';

        exit(XML);
    end;

    local procedure GetPurchasePaymentMethodsXML(): Text
    begin
        //NON-MANDATORY - Will be left out for now since it doesn't make sense for consolidated vouchers either when the paymentmethod element isn't inside each receipt element.
        exit('');
    end;

    local procedure GetCustomerInfoXML(var tmpCustomerInfoCapture: Record "NPR TaxFree GB I2 Info Capt." temporary): Text
    var
        XML: Text;
        XmlLbl: Label '<IdentifierLookupValue>%1</IdentifierLookupValue>', Locked = true;
        Xml2Lbl: Label '<FirstName>%1</FirstName>', Locked = true;
        Xml3Lbl: Label '<LastName>%1</LastName>', Locked = true;
        Xml4Lbl: Label '<Email>%1</Email>', Locked = true;
        Xml5Lbl: Label '<DateOfBirth>%1</DateOfBirth>', Locked = true;
        Xml6Lbl: Label '<PassportNumber>%1</PassportNumber>', Locked = true;
        Xml7Lbl: Label '<PassportCountryCode>%1</PassportCountryCode>', Locked = true;
        Xml8Lbl: Label '<DepartureDate>%1</DepartureDate>', Locked = true;
        Xml9Lbl: Label '<ArrivalDate>%1</ArrivalDate>', Locked = true;
        Xml10Lbl: Label '<FinalDestinationCountryCode>%1</FinalDestinationCountryCode>', Locked = true;
        Xml11Lbl: Label '<PostalCode>%1</PostalCode>', Locked = true;
        Xml12Lbl: Label '<Street>%1</Street>', Locked = true;
        Xml13Lbl: Label '<CountryCode>%1</CountryCode>', Locked = true;
        Xml14Lbl: Label '<Town>%1</Town>', Locked = true;
        Xml15Lbl: Label '<MobileNumber>%1</MobileNumber>', Locked = true;
        Xml16Lbl: Label '<IdentifierLookupValue>%1</IdentifierLookupValue>', Locked = true;
    begin
        if (tmpCustomerInfoCapture."Global Blue Identifier" <> '') and (tmpCustomerInfoCapture."Is Identity Checked") then begin
            //Verified autofill - nothing else is required.
            XML := '<Traveller>' +
                     '<IsIdentityChecked>true</IsIdentityChecked>' +
                   '</Traveller>' +
                   '<TravellerIdentifier>' +
                     StrSubstNo(XmlLbl, EscapeSpecialChars(tmpCustomerInfoCapture."Global Blue Identifier")) +
                   '</TravellerIdentifier>';
            exit(XML);
        end;

        XML += '<Traveller>';
        if tmpCustomerInfoCapture."First Name" <> '' then
            XML += StrSubstNo(Xml2Lbl, EscapeSpecialChars(tmpCustomerInfoCapture."First Name"));
        if tmpCustomerInfoCapture."Last Name" <> '' then
            XML += StrSubstNo(Xml3Lbl, EscapeSpecialChars(tmpCustomerInfoCapture."Last Name"));
        if tmpCustomerInfoCapture."E-mail" <> '' then
            XML += StrSubstNo(Xml4Lbl, EscapeSpecialChars(tmpCustomerInfoCapture."E-mail"));
        if tmpCustomerInfoCapture."Date Of Birth" <> 0D then
            XML += StrSubstNo(Xml5Lbl, EscapeSpecialChars(Format(tmpCustomerInfoCapture."Date Of Birth", 0, 9)));
        if tmpCustomerInfoCapture."Global Blue Identifier" <> '' then //We have an identifier attached but manual entry was still used.
            XML += '<IsIdentityChecked>false</IsIdentityChecked>';

        if (tmpCustomerInfoCapture."Passport Number" <> '') or (tmpCustomerInfoCapture."Passport Country Code" <> 0) then begin
            XML += '<Passport>';
            if tmpCustomerInfoCapture."Passport Number" <> '' then
                XML += StrSubstNo(Xml6Lbl, EscapeSpecialChars(tmpCustomerInfoCapture."Passport Number"));
            if tmpCustomerInfoCapture."Passport Country Code" <> 0 then
                XML += StrSubstNo(Xml7Lbl, Format(tmpCustomerInfoCapture."Passport Country Code"));
            XML += '</Passport>';
        end;

        if (tmpCustomerInfoCapture."Departure Date" <> 0D) or (tmpCustomerInfoCapture."Arrival Date" <> 0D) or (tmpCustomerInfoCapture."Final Destination Country Code" <> 0) then begin
            XML += '<TravelDetails>';
            if tmpCustomerInfoCapture."Departure Date" <> 0D then
                XML += StrSubstNo(Xml8Lbl, EscapeSpecialChars(Format(tmpCustomerInfoCapture."Departure Date", 0, 9)));
            if tmpCustomerInfoCapture."Arrival Date" <> 0D then
                XML += StrSubstNo(Xml9Lbl, EscapeSpecialChars(Format(tmpCustomerInfoCapture."Arrival Date", 0, 9)));
            if tmpCustomerInfoCapture."Final Destination Country Code" <> 0 then
                XML += StrSubstNo(Xml10Lbl, Format(tmpCustomerInfoCapture."Final Destination Country Code"));
            XML += '</TravelDetails>';
        end;

        if (tmpCustomerInfoCapture."Postal Code" <> '') or
           (tmpCustomerInfoCapture.Street <> '') or
           (tmpCustomerInfoCapture."Country Of Residence Code" <> 0) or
           (tmpCustomerInfoCapture.Town <> '')
            then begin
            XML += '<Address>';
            if tmpCustomerInfoCapture."Postal Code" <> '' then
                XML += StrSubstNo(Xml11Lbl, EscapeSpecialChars(tmpCustomerInfoCapture."Postal Code"));
            if tmpCustomerInfoCapture.Street <> '' then
                XML += StrSubstNo(Xml12Lbl, EscapeSpecialChars(tmpCustomerInfoCapture.Street));
            if tmpCustomerInfoCapture."Country Of Residence Code" <> 0 then
                XML += StrSubstNo(Xml13Lbl, Format(tmpCustomerInfoCapture."Country Of Residence Code"));
            if tmpCustomerInfoCapture.Town <> '' then
                XML += StrSubstNo(Xml14Lbl, EscapeSpecialChars(tmpCustomerInfoCapture.Town));
            XML += '</Address>'
        end;

        if tmpCustomerInfoCapture."Mobile No." <> '' then //Docs doesn't specify if this should also be prefixed with 00 and country prefix.
            if tmpCustomerInfoCapture."Mobile No. Prefix" <> 0 then
                XML += StrSubstNo(Xml15Lbl, EscapeSpecialChars('00' + Format(tmpCustomerInfoCapture."Mobile No. Prefix") + tmpCustomerInfoCapture."Mobile No."))
            else
                XML += StrSubstNo(Xml15Lbl, EscapeSpecialChars('00' + tmpCustomerInfoCapture."Mobile No."));
        XML += '</Traveller>';

        if (tmpCustomerInfoCapture."Global Blue Identifier" <> '') then
            XML += '<TravellerIdentifier>' +
                     StrSubstNo(Xml16Lbl, EscapeSpecialChars(tmpCustomerInfoCapture."Global Blue Identifier")) +
                   '</TravellerIdentifier>';

        exit(XML);
    end;

    #endregion

    #region Interface integration

#pragma warning disable AA0150
    procedure OnLookupHandlerParameter(TaxFreeUnit: Record "NPR Tax Free POS Unit"; var Handled: Boolean; var tmpHandlerParameters: Record "NPR Tax Free Handler Param." temporary)
#pragma warning restore
    begin
        Error(Error_NotSupported, TaxFreeUnit."Handler ID Enum");
    end;

    procedure OnSetUnitParameters(TaxFreeUnit: Record "NPR Tax Free POS Unit"; var Handled: Boolean)
    var
        GlobalBlueI2Parameters: Record "NPR Tax Free GB I2 Param.";
        GlobalBlueParameterPage: Page "NPR Tax Free GB I2 Param.";
    begin
        Handled := true;

        if not GlobalBlueI2Parameters.Get(TaxFreeUnit."POS Unit No.") then begin
            GlobalBlueI2Parameters.Init();
            GlobalBlueI2Parameters."Tax Free Unit" := TaxFreeUnit."POS Unit No.";
            GlobalBlueI2Parameters.Insert();
            Commit();
        end;

        GlobalBlueParameterPage.SetRecord(GlobalBlueI2Parameters);
        GlobalBlueParameterPage.Editable := true;
        GlobalBlueParameterPage.RunModal();
    end;

    procedure OnUnitAutoConfigure(var TaxFreeRequest: Record "NPR Tax Free Request"; Silent: Boolean)
    var
        GetCountriesJob: Codeunit "NPR TaxFree GBI2 GetCountries";
        GetBlockedCountriesJob: Codeunit "NPR TaxFree GBI2 GetBCountries";
        GetIINBlacklistJob: Codeunit "NPR TaxFree GBI2 GetBlockedIIN";
    begin
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

    procedure OnUnitTestConnection(var TaxFreeRequest: Record "NPR Tax Free Request")
    begin
        GlobalTaxFreeUnit.Get(TaxFreeRequest."POS Unit No.");
        GlobalBlueParameters.Get(TaxFreeRequest."POS Unit No.");
        DownloadDeskConfiguration(TaxFreeRequest);
    end;

#pragma warning disable AA0150
    procedure OnVoucherIssueFromPOSSale(var TaxFreeRequest: Record "NPR Tax Free Request"; SalesReceiptNo: Code[20]; var SkipRecordHandling: Boolean)
#pragma warning restore
    var
        TempEligibleServices: Record "NPR Tax Free GB I2 Service" temporary;
        TempTaxFreeConsolidation: Record "NPR Tax Free Consolidation" temporary;
    begin
        InitializeHandler(TaxFreeRequest);

        if not IsStoredSaleEligible(SalesReceiptNo, TempEligibleServices) then
            Error(Error_Ineligible);
        if TempEligibleServices.IsEmpty then
            Error(Error_Ineligible);

        TempTaxFreeConsolidation.Init();
        TempTaxFreeConsolidation."Sales Ticket No." := SalesReceiptNo;
        TempTaxFreeConsolidation.Insert();

        IssueVoucher(TaxFreeRequest, TempTaxFreeConsolidation, TempEligibleServices);
    end;

    procedure OnVoucherVoid(var TaxFreeRequest: Record "NPR Tax Free Request"; TaxFreeVoucher: Record "NPR Tax Free Voucher")
    begin
        InitializeHandler(TaxFreeRequest);
        VoidVoucher(TaxFreeRequest, TaxFreeVoucher);
    end;

    procedure OnVoucherReissue(var TaxFreeRequest: Record "NPR Tax Free Request"; TaxFreeVoucher: Record "NPR Tax Free Voucher")
    begin
        InitializeHandler(TaxFreeRequest);
        ReissueVoucher(TaxFreeRequest, TaxFreeVoucher);
    end;

    procedure OnVoucherLookup(var TaxFreeRequest: Record "NPR Tax Free Request"; VoucherNo: Text)
    begin
        Error(Error_NotSupported, TaxFreeRequest."Handler ID Enum");
    end;

    procedure OnVoucherPrint(var TaxFreeRequest: Record "NPR Tax Free Request"; TaxFreeVoucher: Record "NPR Tax Free Voucher"; IsRecentVoucher: Boolean)
    begin
        if not IsRecentVoucher then //I2 only allows for reprint of recent voucher which is stored for the session. This can either be a just-issued voucher or a print-last attempt.
            Error(Error_NotSupported, TaxFreeRequest."Handler ID Enum");

        ClearLastError();
        if not TryPrintVoucher(TaxFreeRequest) then
            Error(Error_PrintFail, TaxFreeVoucher."External Voucher No.", GetLastErrorText);
    end;

    procedure OnVoucherConsolidate(var TaxFreeRequest: Record "NPR Tax Free Request"; var tmpTaxFreeConsolidation: Record "NPR Tax Free Consolidation" temporary)
    var
        TempEligibleServices: Record "NPR Tax Free GB I2 Service" temporary;
    begin
        InitializeHandler(TaxFreeRequest);

        if not IsConsolidationEligible(tmpTaxFreeConsolidation, TempEligibleServices) then
            Error(Error_ConsolidationEligible);
        if TempEligibleServices.IsEmpty then
            Error(Error_ConsolidationEligible);

        IssueVoucher(TaxFreeRequest, tmpTaxFreeConsolidation, TempEligibleServices);
    end;

    procedure OnIsValidTerminalIIN(var TaxFreeRequest: Record "NPR Tax Free Request"; MaskedCardNo: Text; var IsForeignIIN: Boolean)
    begin
        InitializeHandler(TaxFreeRequest);
        IsForeignIIN := CheckIIN(MaskedCardNo);
    end;

    procedure OnIsActiveSaleEligible(var TaxFreeRequest: Record "NPR Tax Free Request"; SalesTicketNo: Code[20]; var Eligible: Boolean)
    var
        TempEligibleServices: Record "NPR Tax Free GB I2 Service" temporary;
    begin
        InitializeHandler(TaxFreeRequest);
        Eligible := IsActiveSaleEligible(SalesTicketNo, TempEligibleServices);
    end;

    procedure OnIsStoredSaleEligible(var TaxFreeRequest: Record "NPR Tax Free Request"; SalesTicketNo: Code[20]; var Eligible: Boolean)
    var
        TempEligibleServices: Record "NPR Tax Free GB I2 Service" temporary;
    begin
        InitializeHandler(TaxFreeRequest);
        Eligible := IsStoredSaleEligible(SalesTicketNo, TempEligibleServices);
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR Tax Free POS Unit", 'OnAfterDeleteEvent', '', false, false)]
    local procedure OnAfterTaxFreeUnitDelete(var Rec: Record "NPR Tax Free POS Unit"; RunTrigger: Boolean)
    var
        GlobalBlueI2Parameters: Record "NPR Tax Free GB I2 Param.";
        GlobalBlueI2Services: Record "NPR Tax Free GB I2 Service";
    begin
        if Rec.IsTemporary or (not RunTrigger) then
            exit;


        if not (Rec."Handler ID Enum" = Rec."Handler ID Enum"::GLOBALBLUE_I2) then
            exit;

        GlobalBlueI2Parameters.SetRange("Tax Free Unit", Rec."POS Unit No.");
        GlobalBlueI2Parameters.DeleteAll(true);

        GlobalBlueI2Services.SetRange("Tax Free Unit", Rec."POS Unit No.");
        GlobalBlueI2Services.DeleteAll(true);
    end;

    #endregion
    [IntegrationEvent(false, false)]
    local procedure OnBeforeIssueVoucher(var TaxFreeRequest: Record "NPR Tax Free Request"; CustomerXML: Text; PaymentXML: Text; PurchaseXML: Text; var Handeled: Boolean)
    begin
    end;
}
