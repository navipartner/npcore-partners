codeunit 6185104 "NPR MM Add. Info. Req. Mgt."
{
    Access = Internal;

    internal procedure MakeAddInfoRequest(AddInfoRequestType: Enum "NPR MM Add. Info. Request"; LoginHint: Text[100];
                                          var RequestRecordRef: RecordRef; var AddInfoResponse: Record "NPR MM Add. Info. Response" temporary)
    var
        TempAddInfoRequest: Record "NPR MM Add. Info. Request" temporary;
        IAddInfoRequest: Interface "NPR MM IAdd. Info. Request";
    begin
        TempAddInfoRequest.Init();
        TempAddInfoRequest."Source Record" := RequestRecordRef.RecordId();
        TempAddInfoRequest."Source Table" := RequestRecordRef.Number();
        TempAddInfoRequest."Login Hint" := LoginHint;

        IAddInfoRequest := AddInfoRequestType;
        IAddInfoRequest.RequestAdditionalInfo(TempAddInfoRequest, AddInfoResponse);
    end;

    internal procedure NormalizePhoneNo(PhoneNo: Text[30]) NormalizedPhoneNo: Text[30]
    begin
        NormalizedPhoneNo := CopyStr(PhoneNo.Replace('-', '').Replace(' ', ''), 1, MaxStrLen(PhoneNo));
    end;

    internal procedure SetCustAdditionalInfo(var Customer: Record Customer; AddInfoResponse: Record "NPR MM Add. Info. Response" temporary)
    begin
        if AddInfoResponse.Name <> '' then
            Customer.Validate(Name, AddInfoResponse.Name);

        if AddInfoResponse."E-Mail" <> '' then
            Customer.Validate("E-Mail", AddInfoResponse."E-Mail");

        if AddInfoResponse.Address <> '' then
            Customer.Validate(Address, AddInfoResponse.Address);

        if AddInfoResponse."Address 2" <> '' then
            Customer.Validate("Address 2", AddInfoResponse."Address 2");

        if AddInfoResponse."City" <> '' then
            Customer.City := AddInfoResponse."City";

        if AddInfoResponse."Country/Region Code" <> '' then
            Customer."Country/Region Code" := AddInfoResponse."Country/Region Code";

        if AddInfoResponse."Post Code" <> '' then
            Customer."Post Code" := AddInfoResponse."Post Code";
    end;

    internal procedure SetMemberAdditionalInfo(var MemberInfoCapture: Record "NPR MM Member Info Capture"; AddInfoResponse: Record "NPR MM Add. Info. Response" temporary)
    var
        EmptyDate: Date;
    begin
        if AddInfoResponse."First Name" <> '' then
            MemberInfoCapture.Validate("First Name", AddInfoResponse."First Name");

        if AddInfoResponse."Last Name" <> '' then
            MemberInfoCapture.Validate("Last Name", AddInfoResponse."Last Name");

        if AddInfoResponse."E-Mail" <> '' then
            MemberInfoCapture.Validate("E-Mail Address", AddInfoResponse."E-Mail");

        if AddInfoResponse.Birthdate <> EmptyDate then
            MemberInfoCapture.Validate(Birthday, AddInfoResponse.Birthdate);

        if AddInfoResponse.Address <> '' then
            MemberInfoCapture.Validate(Address, AddInfoResponse.Address);

        if AddInfoResponse."Address 2" <> '' then begin
            MemberInfoCapture.Validate(Address, CopyStr(MemberInfoCapture.Address + ', ' + AddInfoResponse."Address 2", 1, 100));
        end;

        if AddInfoResponse.City <> '' then
            MemberInfoCapture.City := AddInfoResponse.City;

        if AddInfoResponse."Country/Region Code" <> '' then
            MemberInfoCapture."Country Code" := AddInfoResponse."Country/Region Code";

        if AddInfoResponse."Post Code" <> '' then
            MemberInfoCapture."Post Code Code" := AddInfoResponse."Post Code";

        if AddInfoResponse."Phone No." <> '' then
            MemberInfoCapture.Validate("Phone No.", CopyStr('+' + AddInfoResponse."Phone No.", 1, MaxStrLen(MemberInfoCapture."Phone No.")));
    end;

    internal procedure UpperCaseUrlEncode(var TextToEncode: Text);
    var
#if BC17 
        Match: Codeunit DotNet_Match;
        Regex: Codeunit DotNet_Regex;
#else 
        TempMatches: Record "Matches" temporary;
        Regex: Codeunit Regex;
#endif
        TypeHelper: Codeunit "Type Helper";
        ReadValue: Text;
    begin
        TypeHelper.UrlEncode(TextToEncode);
#if BC17
        Regex.Regex('%[a-f\d]{2}');
        Regex.Match(TextToEncode, Match);
        while Match.Success() do begin
            ReadValue := Match.Value();
            TextToEncode := Regex.Replace(TextToEncode, ReadValue, ReadValue.ToUpper());

            Regex.Match(TextToEncode, Match)
        end;
#else 
        Regex.Match(TextToEncode, '%[a-f\d]{2}', 1, TempMatches);
        repeat
            ReadValue := TempMatches.ReadValue();
            TextToEncode := Regex.Replace(TextToEncode, ReadValue, ReadValue.ToUpper());
        until TempMatches.Next() = 0;
#endif
    end;
}
