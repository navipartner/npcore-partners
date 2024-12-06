codeunit 6185091 "NPR MM VippsMP Add. Info. Req." implements "NPR MM IAdd. Info. Request"
{
    Access = Internal;

    internal procedure RequestAdditionalInfo(AddInfoRequest: Record "NPR MM Add. Info. Request" temporary;
                                    var AddInfoResponse: Record "NPR MM Add. Info. Response" temporary)
    var
        VippsMPCommSetup: Record "NPR MM VippsMP Login Setup";
        VippsMPPollingDialog: Page "NPR MM VippsMP Polling Dialog";
        Parameters: Dictionary of [Text, Text];
        Results: Dictionary of [Text, Text];
        TaskError: ErrorInfo;
    begin
        if not VippsMPCommSetup.Get() then begin
            VippsMPCommSetup.Init();
            VippsMPCommSetup.Insert();
            Commit();
        end;

        AddInfoRequest.Environment := VippsMPCommSetup.Environment;
        AddInfoRequest.Scope := VippsMPCommSetup.GetScope(AddInfoRequest."Source Table");

        Parameters.Add('RequestPhoneNo', AddInfoRequest."Login Hint");
        Parameters.Add('RequestScope', AddInfoRequest.Scope);
        Parameters.Add('RequestEnvironment', Format(AddInfoRequest.Environment.AsInteger()));
        VippsMPPollingDialog.SetBackgroundTaskParameters(Parameters);

        VippsMPPollingDialog.RunModal();

        TaskError := VippsMPPollingDialog.GetTaskError();
        if TaskError.Message <> '' then
            Error(TaskError);

        if VippsMPPollingDialog.IsCompleted() then begin
            VippsMPPollingDialog.GetBackgroundTaskResults(Results);
            AddInfoResponse.Init();
            AddInfoResponse."Source Record" := AddInfoRequest."Source Record";
            TransferDataToResponse(AddInfoResponse, Results);
        end;
    end;

    local procedure TransferDataToResponse(var AddInfoResponse: Record "NPR MM Add. Info. Response" temporary;
                                           var Parameters: Dictionary of [Text, Text])
    begin
        if Parameters.ContainsKey('Name') then
            AddInfoResponse.Name := CopyStr(Parameters.Get('Name'), 1, MaxStrLen(AddInfoResponse.Name));

        if Parameters.ContainsKey('FirstName') then
            AddInfoResponse."First Name" := CopyStr(Parameters.Get('FirstName'), 1, MaxStrLen(AddInfoResponse."First Name"));

        if Parameters.ContainsKey('LastName') then
            AddInfoResponse."Last Name" := CopyStr(Parameters.Get('LastName'), 1, MaxStrLen(AddInfoResponse."Last Name"));

        if Parameters.ContainsKey('Email') then
            AddInfoResponse."E-Mail" := CopyStr(Parameters.Get('Email'), 1, MaxStrLen(AddInfoResponse."E-Mail"));

        if Parameters.ContainsKey('Birthdate') then
            Evaluate(AddInfoResponse.Birthdate, Parameters.Get('Birthdate'));

        if Parameters.ContainsKey('Address') then
            TransferAddressToResponse(AddInfoResponse, Parameters, '');

        if Parameters.ContainsKey('WorkAddress') then
            TransferAddressToResponse(AddInfoResponse, Parameters, 'Work');

        if Parameters.ContainsKey('AltAddress') then
            TransferAddressToResponse(AddInfoResponse, Parameters, 'Alt');

        if Parameters.ContainsKey('ConsentTime') then
            Evaluate(AddInfoResponse."Delegated Consent DateTime", Parameters.Get('ConsentTime'));

        if Parameters.ContainsKey('ConsentEmail') then
            AddInfoResponse."Delegated Consent E-Mail" := true;

        if Parameters.ContainsKey('ConsentSMS') then
            AddInfoResponse."Delegated Consent SMS" := true;

        if Parameters.ContainsKey('ConsentDigitalMarketing') then
            AddInfoResponse."Consent Digital Marketing" := true;

        if Parameters.ContainsKey('ConsentCustomizedOffers') then
            AddInfoResponse."Consent Customized Offers" := true;
    end;

    local procedure TransferAddressToResponse(var AddInfoResponse: Record "NPR MM Add. Info. Response" temporary;
                                              var Parameters: Dictionary of [Text, Text]; AddressPrefix: Text[5])
    begin
        if Parameters.ContainsKey(AddressPrefix + 'Address') then
            case AddressPrefix of
                'Work':
                    AddInfoResponse."Work Address" := CopyStr(Parameters.Get(AddressPrefix + 'Address'), 1, MaxStrLen(AddInfoResponse."Work Address"));
                'Alt':
                    AddInfoResponse."Alt. Address" := CopyStr(Parameters.Get(AddressPrefix + 'Address'), 1, MaxStrLen(AddInfoResponse."Alt. Address"));
                else
                    AddInfoResponse.Address := CopyStr(Parameters.Get('Address'), 1, MaxStrLen(AddInfoResponse.Address));
            end;

        if Parameters.ContainsKey(AddressPrefix + 'Address2') then
            case AddressPrefix of
                'Work':
                    AddInfoResponse."Work Address 2" := CopyStr(Parameters.Get(AddressPrefix + 'Address2'), 1, MaxStrLen(AddInfoResponse."Work Address 2"));
                'Alt':
                    AddInfoResponse."Alt. Address 2" := CopyStr(Parameters.Get(AddressPrefix + 'Address2'), 1, MaxStrLen(AddInfoResponse."Alt. Address 2"));
                else
                    AddInfoResponse."Address 2" := CopyStr(Parameters.Get('Address2'), 1, MaxStrLen(AddInfoResponse."Address 2"));
            end;

        if Parameters.ContainsKey(AddressPrefix + 'City') then
            case AddressPrefix of
                'Work':
                    AddInfoResponse."Work Address City" := CopyStr(Parameters.Get(AddressPrefix + 'City'), 1, MaxStrLen(AddInfoResponse."Work Address City"));
                'Alt':
                    AddInfoResponse."Alt. Address City" := CopyStr(Parameters.Get(AddressPrefix + 'City'), 1, MaxStrLen(AddInfoResponse."Alt. Address City"));
                else
                    AddInfoResponse.City := CopyStr(Parameters.Get('City'), 1, MaxStrLen(AddInfoResponse.City));
            end;

        if Parameters.ContainsKey(AddressPrefix + 'PostCode') then
            case AddressPrefix of
                'Work':
                    AddInfoResponse."Work Address Post Code" := CopyStr(Parameters.Get(AddressPrefix + 'PostCode'), 1, MaxStrLen(AddInfoResponse."Work Address Post Code"));
                'Alt':
                    AddInfoResponse."Alt. Address Post Code" := CopyStr(Parameters.Get(AddressPrefix + 'PostCode'), 1, MaxStrLen(AddInfoResponse."Alt. Address Post Code"));
                else
                    AddInfoResponse."Post Code" := CopyStr(Parameters.Get('PostCode'), 1, MaxStrLen(AddInfoResponse."Post Code"));
            end;

        if Parameters.ContainsKey(AddressPrefix + 'CountryCode') then
            case AddressPrefix of
                'Work':
                    AddInfoResponse."Work Addr. Country/Region Code" := CopyStr(Parameters.Get(AddressPrefix + 'CountryCode'), 1, MaxStrLen(AddInfoResponse."Work Addr. Country/Region Code"));
                'Alt':
                    AddInfoResponse."Alt. Addr. Country/Region Code" := CopyStr(Parameters.Get(AddressPrefix + 'CountryCode'), 1, MaxStrLen(AddInfoResponse."Alt. Addr. Country/Region Code"));
                else
                    AddInfoResponse."Country/Region Code" := CopyStr(Parameters.Get('CountryCode'), 1, MaxStrLen(AddInfoResponse."Country/Region Code"));
            end;
    end;
}
