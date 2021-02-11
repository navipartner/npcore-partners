codeunit 85015 "NPR Library - Member XML API"
{

    procedure CreateMembership(MembershipSalesItemNo: Code[20]; var MembershipEntryNo: Integer; var ResponseMessage: Text): Boolean
    var
        ActivationDate: Date;
        CompanyName: Text;
        PreAssignedCustomerNo: Code[20];
        AttributeCodeArray: array[10] of Code[10];
        ValueArray: array[10] of Code[10];
        ScannerStation: Code[10];
    begin
        ActivationDate := Today();
        exit(CreateMembership(MembershipSalesItemNo, ActivationDate, CompanyName, PreAssignedCustomerNo, AttributeCodeArray, ValueArray, ScannerStation, MembershipEntryNo, ResponseMessage));
    end;

    procedure CreateMembership(MembershipSalesItemNo: Code[20]; ActivationDate: Date; CompanyName: Text; PreAssignedCustomerNo: Code[20]; AttributeCodeArray: array[10] of Code[10]; ValueArray: array[10] of Code[10]; ScannerStation: Code[10]; var MembershipEntryNo: Integer; var ResponseMessage: Text): Boolean
    var
        NameSpace: Text;
        XmlDoc: XmlDocument;
        XmlDec: XmlDeclaration;

        Memberships: XmlElement;
        CreateMembership: XmlElement;
        Request: XmlElement;
        AttributesElement: XmlElement;
        Attribute: XmlElement;
        NAttributeCode: Integer;
    begin

        NameSpace := 'urn:microsoft-dynamics-nav/xmlports/x6060127';

        XMLDoc := XmlDocument.Create();
        XMLDec := XmlDeclaration.Create('1.0', 'utf-8', 'yes');
        XMLDoc.SetDeclaration(XMLDec);

        Request := XmlElement.Create('request', NameSpace);
        Request.Add(AddElement('membershipsalesitem', MembershipSalesItemNo, NameSpace));
        Request.Add(AddElement('activationdate', Format(ActivationDate, 0, 9), NameSpace));
        Request.Add(AddElement('companyname', CompanyName, NameSpace));
        Request.Add(AddElement('preassigned_customer_number', PreAssignedCustomerNo, NameSpace));

        AttributesElement := XmlElement.Create('attributes', NameSpace);
        for NAttributeCode := 1 to System.ArrayLen(AttributeCodeArray) do begin
            if (AttributeCodeArray[NAttributeCode] <> '') then begin
                Attribute := XmlElement.Create('attribute', NameSpace);
                Attribute.SetAttribute('code', AttributeCodeArray[NAttributeCode]);
                Attribute.SetAttribute('value', ValueArray[NAttributeCode]);
                AttributesElement.Add(Attribute);
            end;
        end;
        Request.Add(AttributesElement);

        CreateMembership := XmlElement.Create('createmembership', NameSpace);
        CreateMembership.Add(Request);

        Memberships := XmlElement.Create('memberships', NameSpace);
        Memberships.Add(CreateMembership);

        XmlDoc.Add(Memberships);
        exit(CreateMembershipAPI(XmlDoc, ScannerStation, MembershipEntryNo, ResponseMessage));

    end;

    procedure CreateMembershipAPI(XmlDoc: XmlDocument; ScannerStation: Code[10]; var MembershipEntryNo: Integer; var ResponseMessage: Text): Boolean
    var
        TmpBLOBbuffer: Record "NPR BLOB buffer" temporary;
        MemberWebService: Codeunit "NPR MM Member WebService";
        IStream: InStream;
        OStream: OutStream;
        NameSpace: Text;
        XmlAsText: Text;
        ApiStatus: Boolean;
        XmlDec: XmlDeclaration;

        ApiXmlPort: XmlPort "NPR MM Create Membership";
    begin
        XmlDoc.WriteTo(XmlAsText);
        TmpBLOBbuffer.Insert();
        TmpBLOBbuffer."Buffer 1".CreateOutStream(OStream);
        OStream.WriteText(XmlAsText);
        TmpBLOBbuffer.Modify();
        TmpBLOBbuffer."Buffer 1".CreateInStream(IStream);
        ApiXmlPort.SetSource(IStream);

        MemberWebService.CreateMembership(ApiXmlPort, ScannerStation);
        ApiStatus := ApiXmlPort.GetResponse(MembershipEntryNo, ResponseMessage);
        exit(ApiStatus);

    end;


    procedure AddMembershipMember(Membership: Record "NPR MM Membership"; MemberInfoCapture: Record "NPR MM Member Info Capture"; var MemberEntryNo: Integer; var ResponseMessage: Text): Boolean
    var
        AttributeCodeArray: array[10] of Code[10];
        ValueArray: array[10] of Code[10];
        ScannerStation: Code[10];
    begin
        exit(AddMembershipMember(Membership, MemberInfoCapture, AttributeCodeArray, ValueArray, ScannerStation, MemberEntryNo, ResponseMessage));
    end;

    procedure AddMembershipMember(Membership: Record "NPR MM Membership"; MemberInfoCapture: Record "NPR MM Member Info Capture"; AttributeCodeArray: array[10] of Code[10]; ValueArray: array[10] of Code[10]; ScannerStation: Code[10]; var MemberEntryNo: Integer; var ResponseMessage: Text): Boolean
    var
        NameSpace: Text;
        XmlDoc: XmlDocument;
        XmlDec: XmlDeclaration;

        Members: XmlElement;
        AddMember: XmlElement;
        Request: XmlElement;
        AttributesElement: XmlElement;
        Attribute: XmlElement;
        MemberCard: XmlElement;
        Guardian: XmlElement;
        NAttributeCode: Integer;
    begin

        NameSpace := 'urn:microsoft-dynamics-nav/xmlports/x6060128';

        XMLDoc := XmlDocument.Create();
        XMLDec := XmlDeclaration.Create('1.0', 'utf-8', 'yes');
        XMLDoc.SetDeclaration(XMLDec);

        Request := XmlElement.Create('request', NameSpace);
        Request.Add(AddElement('membershipnumber', Membership."External Membership No.", NameSpace));
        Request.Add(AddElement('firstname', MemberInfoCapture."First Name", NameSpace));
        Request.Add(AddElement('middlename', MemberInfoCapture."Middle Name", NameSpace));
        Request.Add(AddElement('lastname', MemberInfoCapture."Last Name", NameSpace));
        Request.Add(AddElement('address', MemberInfoCapture.Address, NameSpace));
        Request.Add(AddElement('postcode', MemberInfoCapture."Post Code Code", NameSpace));
        Request.Add(AddElement('city', MemberInfoCapture.City, NameSpace));
        Request.Add(AddElement('country', MemberInfoCapture.Country, NameSpace));
        Request.Add(AddElement('phoneno', MemberInfoCapture."Phone No.", NameSpace));
        Request.Add(AddElement('email', MemberInfoCapture."E-Mail Address", NameSpace));
        Request.Add(AddElement('birthday', Format(MemberInfoCapture.Birthday, 0, 9), NameSpace));
        Request.Add(AddElement('gender', Format(MemberInfoCapture.Gender, 0, 9), NameSpace));
        Request.Add(AddElement('newsletter', Format(MemberInfoCapture."News Letter", 0, 9), NameSpace));
        Request.Add(AddElement('username', MemberInfoCapture."User Logon ID", NameSpace));
        Request.Add(AddElement('password', MemberInfoCapture."Password SHA1", NameSpace));

        if (MemberInfoCapture."External Card No." <> '') then begin
            MemberCard := XmlElement.Create('membercard', NameSpace);
            MemberCard.Add(AddElement('cardnumber', MemberInfoCapture."External Card No.", NameSpace));
            MemberCard.Add(AddElement('is_permanent', Format(MemberInfoCapture."Temporary Member Card", 0, 9), NameSpace));
            MemberCard.Add(AddElement('valid_until', Format(MemberInfoCapture."Valid Until", 0, 9), NameSpace));
            Request.Add(Membership);
        end;

        if (MemberInfoCapture."Guardian External Member No." <> '') then begin
            Guardian := XmlElement.Create('guardian', NameSpace);
            Guardian.Add(AddElement('membernumber', MemberInfoCapture."Guardian External Member No.", NameSpace));
            Guardian.Add(AddElement('email', 'test@navipartner.dk', NameSpace)); // TODO Remove mandatory and unhandled field
            Request.Add(Guardian);
        end;

        AttributesElement := XmlElement.Create('attributes', NameSpace);
        for NAttributeCode := 1 to System.ArrayLen(AttributeCodeArray) do begin
            if (AttributeCodeArray[NAttributeCode] <> '') then begin
                Attribute := XmlElement.Create('attribute', NameSpace);
                Attribute.SetAttribute('code', AttributeCodeArray[NAttributeCode]);
                Attribute.SetAttribute('value', ValueArray[NAttributeCode]);
                AttributesElement.Add(Attribute);
            end;
        end;
        Request.Add(AttributesElement);

        Request.Add(AddElement('notificationmethod', Format(MemberInfoCapture."Notification Method", 0, 9), NameSpace));
        Request.Add(AddElement('preassigned_contact_number', MemberInfoCapture."Contact No.", NameSpace));

        AddMember := XmlElement.Create('addmember', NameSpace);
        AddMember.Add(Request);

        Members := XmlElement.Create('members', NameSpace);
        Members.Add(AddMember);

        XmlDoc.Add(Members);

        exit(AddMembershipMemberAPI(XmlDoc, ScannerStation, MemberEntryNo, ResponseMessage));

    end;


    procedure AddMembershipMemberAPI(XmlDoc: XmlDocument; ScannerStation: Code[10]; var MemberEntryNo: Integer; var ResponseMessage: Text): Boolean
    var
        TmpBLOBbuffer: Record "NPR BLOB buffer" temporary;
        MemberWebService: Codeunit "NPR MM Member WebService";
        IStream: InStream;
        OStream: OutStream;
        NameSpace: Text;
        XmlAsText: Text;
        ApiStatus: Boolean;
        XmlDec: XmlDeclaration;

        ApiXmlPort: XmlPort "NPR MM Add Member";
    begin

        XmlDoc.WriteTo(XmlAsText);
        TmpBLOBbuffer.Insert();
        TmpBLOBbuffer."Buffer 1".CreateOutStream(OStream);
        OStream.WriteText(XmlAsText);
        TmpBLOBbuffer.Modify();
        TmpBLOBbuffer."Buffer 1".CreateInStream(IStream);
        ApiXmlPort.SetSource(IStream);

        MemberWebService.AddMembershipMember(ApiXmlPort, ScannerStation);
        ApiStatus := ApiXmlPort.GetResponse(MemberEntryNo, ResponseMessage);
        exit(ApiStatus);
    end;


    procedure ActivateMembership(Membership: Record "NPR MM Membership"; ScannerStation: Code[10]): Boolean
    var
        MemberWebService: Codeunit "NPR MM Member WebService";
    begin

        exit(MemberWebService.ActivateMembership(Membership."External Membership No.", ScannerStation));

    end;


    procedure GetMembershipUsingMemberNumber(MemberNumber: Code[20]; ScannerStation: Code[10]; var TmpMembershipOut: Record "NPR MM Membership" temporary; var TmpMembershipEntryOut: Record "NPR MM Membership Entry" temporary; var TmpAttributeValueSetOut: Record "NPR Attribute Value Set" temporary; var ResponseMessage: Text): Boolean
    var
        NameSpace: Text;
        XmlDoc: XmlDocument;
        XmlDec: XmlDeclaration;

        ApiXmlPort: XmlPort "NPR MM Get Membership";
        MembershipQuery: XmlElement;
        GetMembership: XmlElement;
        Request: XmlElement;
    begin

        NameSpace := 'urn:microsoft-dynamics-nav/xmlports/x6060129';

        XMLDoc := XmlDocument.Create();
        XMLDec := XmlDeclaration.Create('1.0', 'utf-8', 'yes');
        XMLDoc.SetDeclaration(XMLDec);

        Request := XmlElement.Create('request', NameSpace);
        Request.Add(AddElement('membernumber', MemberNumber, NameSpace));
        Request.Add(AddElement('membershipnumber', '', NameSpace)); // A required field

        GetMembership := XmlElement.Create('getmembership', NameSpace);
        GetMembership.Add(Request);

        MembershipQuery := XmlElement.Create('memberships', NameSpace);
        MembershipQuery.Add(GetMembership);

        XmlDoc.Add(MembershipQuery);
        exit(GetMembershipAPI(XmlDoc, ScannerStation, TmpMembershipOut, TmpMembershipEntryOut, TmpAttributeValueSetOut, ResponseMessage));
    end;

    procedure GetMembershipAPI(XmlDoc: XmlDocument; ScannerStation: Code[10]; var TmpMembershipOut: Record "NPR MM Membership" temporary; var TmpMembershipEntryOut: Record "NPR MM Membership Entry" temporary; var TmpAttributeValueSetOut: Record "NPR Attribute Value Set" temporary; var ResponseMessage: Text): Boolean
    var
        TmpBLOBbuffer: Record "NPR BLOB buffer" temporary;
        MemberWebService: Codeunit "NPR MM Member WebService";
        IStream: InStream;
        OStream: OutStream;
        NameSpace: Text;
        XmlAsText: Text;
        ApiStatus: Boolean;

        ApiXmlPort: XmlPort "NPR MM Get Membership";
    begin

        XmlDoc.WriteTo(XmlAsText);
        TmpBLOBbuffer.Insert();
        TmpBLOBbuffer."Buffer 1".CreateOutStream(OStream);
        OStream.WriteText(XmlAsText);
        TmpBLOBbuffer.Modify();
        TmpBLOBbuffer."Buffer 1".CreateInStream(IStream);
        ApiXmlPort.SetSource(IStream);

        MemberWebService.GetMembership(ApiXmlPort, ScannerStation);
        ApiStatus := ApiXmlPort.GetResponse(TmpMembershipOut, TmpMembershipEntryOut, TmpAttributeValueSetOut, ResponseMessage);
        exit(ApiStatus);
    end;

    procedure GetMembershipMemberUsingMembership(MembershipNo: Code[20]; ScannerStation: Code[10]; var TmpMemberInfoResponseOut: Record "NPR MM Member Info Capture" temporary; var TmpAttributeValueSetOut: Record "NPR Attribute Value Set" temporary; var ResponseMessage: Text): Boolean
    var
        NameSpace: Text;
        XmlDoc: XmlDocument;
        XmlDec: XmlDeclaration;

        ApiXmlPort: XmlPort "NPR MM Get Membership";
        MemberQuery: XmlElement;
        GetMembers: XmlElement;
        Request: XmlElement;
    begin

        NameSpace := 'urn:microsoft-dynamics-nav/xmlports/x6060130';

        XMLDoc := XmlDocument.Create();
        XMLDec := XmlDeclaration.Create('1.0', 'utf-8', 'yes');
        XMLDoc.SetDeclaration(XMLDec);

        Request := XmlElement.Create('request', NameSpace);
        Request.Add(AddElement('membershipnumber', MembershipNo, NameSpace));
        Request.Add(AddElement('membernumber', '', NameSpace));
        Request.Add(AddElement('cardnumber', '', NameSpace));

        GetMembers := XmlElement.Create('getmembers', NameSpace);
        GetMembers.Add(Request);

        MemberQuery := XmlElement.Create('members', NameSpace);
        MemberQuery.Add(GetMembers);

        XmlDoc.Add(MemberQuery);
        exit(GetMembershipMemberAPI(XmlDoc, ScannerStation, TmpMemberInfoResponseOut, TmpAttributeValueSetOut, ResponseMessage));
    end;

    procedure GetMembershipMemberAPI(XmlDoc: XmlDocument; ScannerStation: Code[10]; var TmpMemberInfoResponseOut: Record "NPR MM Member Info Capture" temporary; var TmpAttributeValueSetOut: Record "NPR Attribute Value Set" temporary; var ResponseMessage: Text): Boolean
    var
        TmpBLOBbuffer: Record "NPR BLOB buffer" temporary;
        MemberWebService: Codeunit "NPR MM Member WebService";
        IStream: InStream;
        OStream: OutStream;
        NameSpace: Text;
        XmlAsText: Text;
        ApiStatus: Boolean;

        ApiXmlPort: XmlPort "NPR MM Get Members. Members";
    begin

        XmlDoc.WriteTo(XmlAsText);
        TmpBLOBbuffer.Insert();
        TmpBLOBbuffer."Buffer 1".CreateOutStream(OStream);
        OStream.WriteText(XmlAsText);
        TmpBLOBbuffer.Modify();
        TmpBLOBbuffer."Buffer 1".CreateInStream(IStream);
        ApiXmlPort.SetSource(IStream);

        MemberWebService.GetMembershipMembers(ApiXmlPort, ScannerStation);
        ApiStatus := ApiXmlPort.GetResponse(TmpMemberInfoResponseOut, TmpAttributeValueSetOut, ResponseMessage);
        exit(ApiStatus);
    end;

    procedure UpdateMember(MemberInfoCapture: Record "NPR MM Member Info Capture"; ScannerStation: Code[10]; var ResponseMessage: Text): Boolean
    var
        AttributeCodeArray: array[10] of Code[10];
        ValueArray: array[10] of Code[10];
    begin
        exit(UpdateMember(MemberInfoCapture, ScannerStation, AttributeCodeArray, ValueArray, ResponseMessage));
    end;


    procedure UpdateMember(MemberInfoCapture: Record "NPR MM Member Info Capture"; ScannerStation: Code[10]; AttributeCodeArray: array[10] of Code[10]; ValueArray: array[10] of Code[10]; var ResponseMessage: Text): Boolean
    var
        NameSpace: Text;
        XmlDoc: XmlDocument;
        XmlDec: XmlDeclaration;

        Members: XmlElement;
        UpdateMember: XmlElement;
        Request: XmlElement;
        AttributesElement: XmlElement;
        Attribute: XmlElement;
        MemberCard: XmlElement;
        Guardian: XmlElement;
        NAttributeCode: Integer;
    begin

        NameSpace := 'urn:microsoft-dynamics-nav/xmlports/x6060131';

        XMLDoc := XmlDocument.Create();
        XMLDec := XmlDeclaration.Create('1.0', 'utf-8', 'yes');
        XMLDoc.SetDeclaration(XMLDec);

        Request := XmlElement.Create('request', NameSpace);
        Request.Add(AddElement('membernumber', MemberInfoCapture."External Member No", NameSpace));
        Request.Add(AddElement('firstname', MemberInfoCapture."First Name", NameSpace));
        Request.Add(AddElement('middlename', MemberInfoCapture."Middle Name", NameSpace));
        Request.Add(AddElement('lastname', MemberInfoCapture."Last Name", NameSpace));
        Request.Add(AddElement('address', MemberInfoCapture.Address, NameSpace));
        Request.Add(AddElement('postcode', MemberInfoCapture."Post Code Code", NameSpace));
        Request.Add(AddElement('city', MemberInfoCapture.City, NameSpace));
        Request.Add(AddElement('country', MemberInfoCapture.Country, NameSpace));
        Request.Add(AddElement('phoneno', MemberInfoCapture."Phone No.", NameSpace));
        Request.Add(AddElement('email', MemberInfoCapture."E-Mail Address", NameSpace));
        Request.Add(AddElement('birthday', Format(MemberInfoCapture.Birthday, 0, 9), NameSpace));
        Request.Add(AddElement('gender', Format(MemberInfoCapture.Gender, 0, 9), NameSpace));
        Request.Add(AddElement('newsletter', Format(MemberInfoCapture."News Letter", 0, 9), NameSpace));

        if (MemberInfoCapture."Guardian External Member No." <> '') then begin
            Guardian := XmlElement.Create('guardian', NameSpace);
            Guardian.Add(AddElement('membernumber', MemberInfoCapture."Guardian External Member No.", NameSpace));
            Guardian.Add(AddElement('email', 'test@navipartner.dk', NameSpace)); // TODO Remove mandatory and unhandled field
            Request.Add(Guardian);
        end;

        AttributesElement := XmlElement.Create('attributes', NameSpace);
        for NAttributeCode := 1 to System.ArrayLen(AttributeCodeArray) do begin
            if (AttributeCodeArray[NAttributeCode] <> '') then begin
                Attribute := XmlElement.Create('attribute', NameSpace);
                Attribute.SetAttribute('code', AttributeCodeArray[NAttributeCode]);
                Attribute.SetAttribute('value', ValueArray[NAttributeCode]);
                AttributesElement.Add(Attribute);
            end;
        end;
        Request.Add(AttributesElement);

        Request.Add(AddElement('notificationmethod', Format(MemberInfoCapture."Notification Method", 0, 9), NameSpace));

        UpdateMember := XmlElement.Create('updatemember', NameSpace);
        UpdateMember.Add(Request);

        Members := XmlElement.Create('members', NameSpace);
        Members.Add(UpdateMember);

        XmlDoc.Add(Members);
        exit(UpdateMemberAPI(XmlDoc, ScannerStation, ResponseMessage));

    end;

    procedure UpdateMemberAPI(XmlDoc: XmlDocument; ScannerStation: Code[10]; var ResponseMessage: Text): Boolean
    var
        TmpBLOBbuffer: Record "NPR BLOB buffer" temporary;
        MemberWebService: Codeunit "NPR MM Member WebService";
        IStream: InStream;
        OStream: OutStream;
        NameSpace: Text;
        XmlAsText: Text;
        ApiStatus: Boolean;

        ApiXmlPort: XmlPort "NPR MM Update Member";
    begin

        XmlDoc.WriteTo(XmlAsText);
        TmpBLOBbuffer.Insert();
        TmpBLOBbuffer."Buffer 1".CreateOutStream(OStream);
        OStream.WriteText(XmlAsText);
        TmpBLOBbuffer.Modify();
        TmpBLOBbuffer."Buffer 1".CreateInStream(IStream);
        ApiXmlPort.SetSource(IStream);

        MemberWebService.UpdateMember(ApiXmlPort, ScannerStation);
        ApiStatus := ApiXmlPort.GetResponse(ResponseMessage);
        exit(ApiStatus);
    end;


    procedure UpdateMemberImageAPI(MemberNo: Code[20]; Base64Image: Text; ScannerStation: Code[20]): Boolean
    var
        MemberWebService: Codeunit "NPR MM Member WebService";
    begin
        exit(MemberWebService.UpdateMemberImage(MemberNo, Base64Image, ScannerStation));
    end;

    procedure MemberValidationAPI(MemberNo: Code[20]; ScannerStation: Code[10]): Boolean
    var
        MemberWebService: Codeunit "NPR MM Member WebService";
    begin
        exit(MemberWebService.MemberValidation(MemberNo, ScannerStation));
    end;

    procedure MembershipValidationAPI(MembershipNo: Code[20]; ScannerStation: Code[10]): Boolean
    var
        MemberWebService: Codeunit "NPR MM Member WebService";
    begin
        exit(MemberWebService.MembershipValidation(MembershipNo, ScannerStation));
    end;

    procedure MemberEmailExistsAPI(EmailToCheck: Text[100]) IsValid: Boolean
    var
        MemberWebService: Codeunit "NPR MM Member WebService";
    begin
        exit(MemberWebService.MemberEmailExists(EmailToCheck));
    end;

    procedure MemberCardNumberValidationApi(ExternalMemberCardNo: Text[50]; ScannerStation: Code[10]): Boolean
    var
        MemberWebService: Codeunit "NPR MM Member WebService";
    begin
        exit(MemberWebService.MemberCardNumberValidation(ExternalMemberCardNo, ScannerStation));
    end;

    procedure MemberRegisterArrivalAPI(ExternalMemberNo: Code[20]; AdmissionCode: Code[20]; ScannerStation: Code[10]; var MessageText: Text): Boolean
    var
        MemberWebService: Codeunit "NPR MM Member WebService";
    begin
        exit(MemberWebService.MemberRegisterArrival(ExternalMemberNo, AdmissionCode, ScannerStation, MessageText));
    end;

    procedure MemberCardRegisterArrivalAPI(ExternalMemberCardNo: Code[50]; AdmissionCode: Code[20]; ScannerStation: Code[10]; var MessageText: Text): Boolean
    var
        MemberWebService: Codeunit "NPR MM Member WebService";
    begin
        exit(MemberWebService.MemberCardRegisterArrival(ExternalMemberCardNo, AdmissionCode, ScannerStation, MessageText));
    end;

    local procedure AddElement(Name: Text; ElementValue: Text; XmlNs: Text): XmlElement
    var
        Element: XmlElement;
    begin
        Element := XmlElement.Create(Name, XmlNs);
        Element.Add(ElementValue);
        exit(Element);
    end;

}