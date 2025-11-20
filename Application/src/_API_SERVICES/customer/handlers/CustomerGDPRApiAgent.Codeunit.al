#if not (BC17 or BC18 or BC19 or BC20 or BC21 or BC22)
codeunit 6248663 "NPR Customer GDPR Api Agent"
{
    Access = Internal;

    internal procedure AnonymizeCustomer(var Request: Codeunit "NPR API Request") Response: Codeunit "NPR API Response"
    var
        GDPRAnonReqWS: Codeunit "NPR GDPR Anon. Req. WS";
        Success: Boolean;
        ContactNo: Code[20];
        CustomerNo: Code[20];
        ResponseCode: Integer;
        JObject: JsonObject;
        JToken: JsonToken;
        AnonymizationFailedErr: Label 'Customer cannot be anonymized. Reason code: %1', Comment = '%1 = Response Code';
        CannotCreateRequestErr: Label 'Failed to create anonymization request';
        RequestBodyMissingErr: Label 'Request body is required';
        Email: Text[80];
    begin
        JToken := Request.BodyJson();
        if not JToken.IsObject() then begin
            Response.CreateErrorResponse(Enum::"NPR API Error Code"::invalid_input, RequestBodyMissingErr);
            exit(Response);
        end;
        JObject := JToken.AsObject();

        if JObject.Get('customerNo', JToken) then
            CustomerNo := CopyStr(JToken.AsValue().AsText(), 1, MaxStrLen(CustomerNo));
        if JObject.Get('contactNo', JToken) then
            ContactNo := CopyStr(JToken.AsValue().AsText(), 1, MaxStrLen(ContactNo));

        if CustomerNo = '' then
            if not CheckForEmail(JObject, JToken, CustomerNo, Email, Response) then
                exit(Response);

        if not GDPRAnonReqWS.CanCustomerBeAnonymized(CustomerNo, ContactNo, ResponseCode) then begin
            Response.CreateErrorResponse(Enum::"NPR API Error Code"::generic_error, StrSubstNo(AnonymizationFailedErr, ResponseCode));
            exit(Response);
        end;

        Success := GDPRAnonReqWS.AnonymizationRequest(CustomerNo, ContactNo);
        if Success then
            Response.RespondOK(CreateAnonymizationSuccessResponse(CustomerNo, ContactNo, Email))
        else
            Response.CreateErrorResponse(Enum::"NPR API Error Code"::generic_error, CannotCreateRequestErr);

        exit(Response);
    end;

    local procedure CreateAnonymizationSuccessResponse(CustomerNo: Code[20]; ContactNo: Code[20]; Email: Text[80]) JsonResponse: JsonObject
    var
        RequestCreatedLbl: Label 'Anonymization request created successfully';
    begin
        JsonResponse.Add('success', true);
        JsonResponse.Add('message', RequestCreatedLbl);
        if CustomerNo <> '' then
            JsonResponse.Add('customerNo', CustomerNo);
        if ContactNo <> '' then
            JsonResponse.Add('contactNo', ContactNo);
        if Email <> '' then
            JsonResponse.Add('email', Email);
    end;

    local procedure CheckForEmail(var JObject: JsonObject; var JToken: JsonToken; var CustomerNo: Code[20]; var Email: Text[80]; var Response: Codeunit "NPR API Response"): Boolean
    var
        Customer: Record Customer;
        CustomerNotFoundErr: Label 'Customer with specified email not found or anonymization request failed';
        EmailMissingErr: Label 'Email address is required';
    begin
        if not JObject.Get('email', JToken) then begin
            Response.CreateErrorResponse(Enum::"NPR API Error Code"::invalid_input, EmailMissingErr);
            exit(false);
        end;

        Email := CopyStr(JToken.AsValue().AsText(), 1, MaxStrLen(Email));

        if Email = '' then begin
            Response.CreateErrorResponse(Enum::"NPR API Error Code"::invalid_input, EmailMissingErr);
            exit(false);
        end;

        Customer.SetRange("E-Mail", Email);
        if not Customer.FindFirst() then begin
            Response.CreateErrorResponse(Enum::"NPR API Error Code"::invalid_input, CustomerNotFoundErr);
            exit(false);
        end;

        CustomerNo := Customer."No.";
        exit(true);
    end;
}
#endif
