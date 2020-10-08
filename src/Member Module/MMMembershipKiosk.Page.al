page 6060078 "NPR MM Membership Kiosk"
{

    // 
    // https://dev90.dynamics-retail.com/NPRetail90_W1_DEV_Latest/WebClient/?page=6060078&company=RetailDemo2016

    Caption = 'Membership Kiosk';
    PageType = List;
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            usercontrol(Bridge; "NPR Bridge")
            {
                ApplicationArea = All;

                trigger OnFrameworkReady()
                begin

                    BridgeMgt.Initialize(CurrPage.Bridge);
                    BridgeMgt.SetSize('100%', '600px');
                    PageNavigation('StartPage', '');
                end;

                trigger OnInvokeMethod(method: Text; eventContent: JsonObject)
                var
                    NextPage: Integer;
                    Content: Text;
                begin
                    eventContent.WriteTo(Content);
                    PageNavigation(method, Content);
                end;
            }
        }
    }

    actions
    {
    }

    trigger OnInit()
    begin

        MemberInfoJObject := MemberInfoJObject.JObject();
    end;

    var
        BridgeMgt: Codeunit "NPR JavaScript Bridge Mgt.";
        MembershipKiosk: Codeunit "NPR MM Membership Kiosk";
        PageId: Option WELCOME,SCANTICKET,MEMBERINFO,TAKEPICTURE,PREVIEW,PRINT,SHOWERROR;
        StateMachinePageId: Integer;
        MemberInfoJObject: DotNet JObject;
        INVALID_DATE: Label 'The date %1 specified for field %2 does not conform to the expected date format %3.';
        DATE_MASK_ERROR: Label 'Date format mask %1 is not supported.';
        VALUE_REQUIRED: Label 'A value is required for field %1.';

    procedure GotoPage(CurrentPageId: Integer; DestinationPageId: Integer; EventContents: Text): Integer
    var
        JToken: DotNet JToken;
        JObject: DotNet JObject;
        ScanCode: Text;
        TicketWebService: Codeunit "NPR TM Ticket WebService";
        Status: Integer;
        MembershipItemNo: Code[20];
        DateMask: Code[20];
        ReturnDate: Date;
        ErrorMessage: Text;
    begin

        //MESSAGE ('from: %1, to: %2, params %3', FromPageId, ToPage, EventContents);
        if (EventContents <> '') then
            JObject := JObject.Parse(EventContents);

        if (DestinationPageId <> PageId::WELCOME) then begin
            case CurrentPageId of
                PageId::SCANTICKET:
                    begin
                        ScanCode := GetStringValue(JObject, ('ticketbarcode'));

                        // DEMO MODE
                        if (ScanCode = '17') then ScanCode := 'ATF-NPR0000001Y';
                        // DEMO MODE

                        CopyKeyValue(JObject, 'ticketbarcode', MemberInfoJObject, 'ticketbarcode');
                        if (ScanCode = '') then
                            DestinationPageId := ShowErrorMessage(MemberInfoJObject, 'Ticket Barcode must not be empty.');
                        Status := TicketWebService.GetComplementaryMembershipItemNo(ScanCode, MembershipItemNo);
                        case (Status) of
                            1:
                                PutStringValue(MemberInfoJObject, 'MembershipItemNumber', MembershipItemNo);
                            -10:
                                DestinationPageId := ShowErrorMessage(MemberInfoJObject, 'That ticketnumber is not valid. Try this number instead: 17');
                            -11:
                                DestinationPageId := ShowErrorMessage(MemberInfoJObject, 'Invalid ticket type.');
                            -12:
                                DestinationPageId := ShowErrorMessage(MemberInfoJObject, 'Complementary item not setup.');
                        end;
                    end;

                PageId::MEMBERINFO:
                    begin
                        CopyKeyValue(JObject, 'mmPhone', MemberInfoJObject, 'PhoneNumber');

                        DateMask := 'DD/MM/YYYY';
                        if (not TextToDate(GetStringValue(JObject, 'mmBirthDate'), DateMask, true, 'Date of Birth', ReturnDate, ErrorMessage)) then
                            DestinationPageId := ShowErrorMessage(MemberInfoJObject, ErrorMessage);
                        CopyKeyValue(JObject, 'mmBirthDate', MemberInfoJObject, 'DayOfBirth');

                        if (not CopyKeyValue(JObject, 'mmEmail', MemberInfoJObject, 'EmailAddress')) then
                            DestinationPageId := ShowErrorMessage(MemberInfoJObject, 'Email address must not be blank.');

                        if (not CopyKeyValue(JObject, 'mmLastName', MemberInfoJObject, 'LastName')) then
                            DestinationPageId := ShowErrorMessage(MemberInfoJObject, 'Last name must not be blank.');

                        if (not CopyKeyValue(JObject, 'mmFirstName', MemberInfoJObject, 'FirstName')) then
                            DestinationPageId := ShowErrorMessage(MemberInfoJObject, 'First name must not be blank.');

                    end;
            end;
        end;

        case DestinationPageId of
            PageId::WELCOME:
                MemberInfoJObject := MemberInfoJObject.JObject();
        end;

        BridgeMgt.RegisterAdHocModule('MembershipSelfService', MembershipKiosk.GetHtml(DestinationPageId, MemberInfoJObject), MembershipKiosk.GetCss(DestinationPageId), MembershipKiosk.GetScript(DestinationPageId));

        case DestinationPageId of
            PageId::PRINT:
                CreateMembership(MemberInfoJObject);
            PageId::SHOWERROR:
                DestinationPageId := CurrentPageId;
        end;

        exit(DestinationPageId);
    end;

    local procedure GetNextPage(CurrentPageId: Integer) DestinationPageId: Integer
    begin

        case CurrentPageId of
            PageId::WELCOME:
                DestinationPageId := PageId::SCANTICKET;
            PageId::SCANTICKET:
                DestinationPageId := PageId::MEMBERINFO;
            PageId::MEMBERINFO:
                DestinationPageId := PageId::TAKEPICTURE;
            PageId::TAKEPICTURE:
                DestinationPageId := PageId::PREVIEW;
            PageId::PREVIEW:
                DestinationPageId := PageId::PRINT;
            PageId::PRINT:
                DestinationPageId := PageId::WELCOME;
        end;
    end;

    local procedure GetPrevPage(FromPage: Integer) ToPage: Integer
    begin

        case FromPage of
            PageId::WELCOME:
                ToPage := PageId::WELCOME;
            PageId::SCANTICKET:
                ToPage := PageId::WELCOME;
            PageId::MEMBERINFO:
                ToPage := PageId::MEMBERINFO;
            PageId::TAKEPICTURE:
                ToPage := PageId::MEMBERINFO;
            PageId::PREVIEW:
                ToPage := PageId::MEMBERINFO;
            PageId::PRINT:
                ToPage := PageId::WELCOME;
        end;
    end;

    local procedure PageNavigation(Method: Text; EventContent: Text)
    begin

        case Method of
            'StartPage':
                StateMachinePageId := GotoPage(StateMachinePageId, PageId::WELCOME, EventContent);
            'NavigateNext':
                StateMachinePageId := GotoPage(StateMachinePageId, GetNextPage(StateMachinePageId), EventContent);
            'NavigateBack':
                StateMachinePageId := GotoPage(StateMachinePageId, GetPrevPage(StateMachinePageId), EventContent);
            'OnAfterError':
                StateMachinePageId := GotoPage(PageId::SHOWERROR, StateMachinePageId, EventContent);
            else
                Message('Page 6060078: Unhandled method %1 (value %2) ', Method, Format(EventContent));
        end;
    end;

    local procedure "--JsonHelpers"()
    begin
    end;

    local procedure GetJToken(JObject: DotNet JObject; "Key": Text; var JToken: DotNet JToken) KeyFound: Boolean
    begin

        KeyFound := true;
        JToken := JObject.GetValue(Key);
        if (IsNull(JToken)) then begin
            JToken.Parse(StrSubstNo('{%1: ""}', Key));
            KeyFound := false;
        end;

        exit(KeyFound);
    end;

    local procedure CopyKeyValue(SourceJObject: DotNet JObject; SourceKey: Text; TargetJObject: DotNet JObject; TargetKey: Text) KeyFound: Boolean
    var
        SourceJToken: DotNet JToken;
    begin

        KeyFound := (GetStringValue(SourceJObject, SourceKey) <> '');

        GetJToken(SourceJObject, SourceKey, SourceJToken);
        TargetJObject.Remove(TargetKey);
        TargetJObject.Add(TargetKey, SourceJToken);

        exit(KeyFound);
    end;

    local procedure GetStringValue(JObject: DotNet JObject; "Key": Text): Text
    var
        JToken: DotNet JToken;
    begin

        JToken := JObject.GetValue(Key);
        if (IsNull(JToken)) then
            exit('');

        exit(JToken.ToString());
    end;

    local procedure GetDateValue(JObject: DotNet JObject; "Key": Text; DateMask: Code[20]; IsOptional: Boolean) ReturnDate: Date
    var
        ErrorMessage: Text;
    begin

        if (not (TextToDate(GetStringValue(JObject, Key), DateMask, IsOptional, Key, ReturnDate, ErrorMessage))) then
            Error(ErrorMessage);
    end;

    local procedure TextToDate(FieldValue: Text; DateMask: Code[20]; FieldValueIsOptional: Boolean; FieldCaptionName: Text; var ReturnDate: Date; var ErrorMessage: Text) IsValid: Boolean
    begin

        ReturnDate := 0D;

        if (FieldValue = '') then begin

            if (FieldValueIsOptional) then
                exit(true);

            ErrorMessage := StrSubstNo(VALUE_REQUIRED, FieldCaptionName);
            exit;
        end;

        if (StrLen(FieldValue) <> StrLen(DateMask)) then begin
            ErrorMessage := StrSubstNo(INVALID_DATE, FieldValue, FieldCaptionName, DateMask);
            exit(false);
        end;

        case UpperCase(DateMask) of
            'YYYYMMDD':
                IsValid := Evaluate(ReturnDate, StrSubstNo('%1-%2-%3', CopyStr(FieldValue, 1, 4), CopyStr(FieldValue, 5, 2), CopyStr(FieldValue, 7, 2)), 9);
            'YYYY-MM-DD':
                IsValid := Evaluate(ReturnDate, StrSubstNo('%1-%2-%3', CopyStr(FieldValue, 1, 4), CopyStr(FieldValue, 6, 2), CopyStr(FieldValue, 9, 2)), 9);
            'DD/MM/YYYY':
                IsValid := Evaluate(ReturnDate, StrSubstNo('%1-%2-%3', CopyStr(FieldValue, 7, 4), CopyStr(FieldValue, 1, 2), CopyStr(FieldValue, 4, 2)), 9);
            else
                Error(DATE_MASK_ERROR, DateMask);
        end;

        if (not IsValid) then
            ErrorMessage := StrSubstNo(INVALID_DATE, FieldValue, FieldCaptionName, DateMask);

        exit(IsValid);
    end;

    local procedure PutStringValue(var JObject: DotNet JObject; "Key": Text; Value: Text)
    var
        JToken: DotNet JToken;
    begin

        JToken := JToken.Parse(StrSubstNo('{%1: "%2"}', Key, Value));
        JObject.Remove(Key);
        JObject.Add(Key, JToken.Item(Key));
    end;

    local procedure ShowErrorMessage(var JObject: DotNet JObject; ErrorMessage: Text): Integer
    var
        "Key": Text;
    begin

        PutStringValue(JObject, 'ErrorMessage', ErrorMessage);
        exit(PageId::SHOWERROR);
    end;

    local procedure "--MM interactions"()
    begin
    end;

    local procedure CreateMembership(JObject: DotNet JObject)
    var
        MemberInfoCapture: Record "NPR MM Member Info Capture";
        MembershipSalesSetup: Record "NPR MM Members. Sales Setup";
        MembershipManagement: Codeunit "NPR MM Membership Mgt.";
        MemberRetailIntegration: Codeunit "NPR MM Member Retail Integr.";
        TicketManagement: Codeunit "NPR TM Ticket Management";
        ReasonText: Text;
    begin

        MemberInfoCapture."First Name" := GetStringValue(JObject, 'FirstName');
        MemberInfoCapture."Last Name" := GetStringValue(JObject, 'LastName');
        MemberInfoCapture.Birthday := GetDateValue(JObject, 'DayOfBirth', 'DD/MM/YYYY', true);
        MemberInfoCapture."E-Mail Address" := GetStringValue(JObject, 'EmailAddress');
        MemberInfoCapture."Phone No." := GetStringValue(JObject, 'PhoneNumber');

        MemberInfoCapture."Item No." := GetStringValue(JObject, 'MembershipItemNumber');
        MemberInfoCapture."Document Date" := Today;
        MemberInfoCapture."Information Context" := MemberInfoCapture."Information Context"::NEW;
        MemberInfoCapture.Insert();

        MembershipSalesSetup.Get(MembershipSalesSetup.Type::ITEM, MemberInfoCapture."Item No.");
        MembershipManagement.CreateMembershipAll(MembershipSalesSetup, MemberInfoCapture, true);

        // MembershipManagement.UpdateMemberImage ();

        MemberRetailIntegration.PrintMemberCard(MemberInfoCapture."Member Entry No", MemberInfoCapture."Card Entry No.");
        //TicketManagement.ConsumeItem (FALSE, GetStringValue (JObject, 'ticketbarcode'), '', MemberInfoCapture."Item No.", ReasonText);
    end;
}

