codeunit 6060024 "NPR Nemhandel"
{
    Access = Internal;

    local procedure GLNLookupNemHandel(GLN: Code[13]; VATRegNo: Text[20]; CountryCode: Code[10]; OnlyShowWarning: Boolean)
    var
        Customer: Record Customer;
        OIOUBLSetup: Record "NPR OIOUBL Setup";
        Client: HttpClient;
        ResponseMessage: HttpResponseMessage;
        Document: XmlDocument;
        Node: XmlNode;
        Uri: Text;
        ResponseXML: Text;
        InvalidResponseMsg: Label 'Response from NemHandel:\\%1', Comment = '%1 - response';
        ValidGLNLbl: Label 'Response from Nemhandel\\%1 is found and registered for %2', Comment = '%1 - VAT RegNo, %2 - Name of owner';
        MixedVATGLNIdsLbl: Label 'Response from Nemhandel\\%1 %2 is registered for %3 %4: %5.\\Not same %4 as on document (%6 %7).', Comment = '%1 %2  %3 %4 %5 %6 %7';
        NemHandelUrlLbl: Label 'https://registration.nemhandel.dk/NemHandelRegisterWeb/public/participant/info?keytype=GLN&asXML=true&key=%1', Locked = true;
        NameOfVATRegNo: Text;
        GLNName: Text;
        GLNVATRegNo: Text;
    begin
        if GLN = '' then
            exit;
        if not OIOUBLSetup.Get() then
            exit;
        if not OIOUBLSetup."Use Nemhandel Lookup" then
            exit;
        if VATRegNo <> '' then begin
            VATRegNo := RemoveCountryFromVATRegNo(VATRegNo, CountryCode);
            VATRegNoLookupNemHandel(VATRegNo, CountryCode, NameOfVATRegNo);
        end;
        Uri := StrSubstNo(NemHandelUrlLbl, GLN);
        Client.Get(Uri, ResponseMessage);
        ResponseMessage.Content.ReadAs(ResponseXML);
        if not XmlDocument.ReadFrom(ResponseXML, Document) then begin
            Message(InvalidResponseMsg, ResponseXML);
            exit;
        end;
        if Document.SelectSingleNode('ParticipantInfoDTO/Participant/UnitName', Node) then
            GLNName := Node.AsXmlElement().InnerText();

        if Document.SelectSingleNode('ParticipantInfoDTO/Participant/UnitCVR', Node) then
            GLNVATRegNo := Node.AsXmlElement().InnerText();
        if (VATRegNo <> '') and (GLNVATRegNo <> VATRegNo) then
            Message(MixedVATGLNIdsLbl, Customer.FieldCaption(GLN), GLN, GLNName, Customer.FieldCaption("VAT Registration No."), GLNVATRegNo, VATRegNo, NameOfVATRegNo)
        else
            if not OnlyShowWarning then
                Message(ValidGLNLbl, Customer.FieldCaption(GLN), GLNName);
    end;

    local procedure VATRegNoLookupNemHandel(VATRegNo: Text[20]; CountryCode: Code[10]; var NameOfOwner: Text): Boolean
    var
        Client: HttpClient;
        ResponseMessage: HttpResponseMessage;
        Document: XmlDocument;
        Node: XmlNode;
        Uri: Text;
        ResponseXML: Text;
        NemHandelUrlLbl: Label 'https://registration.nemhandel.dk/NemHandelRegisterWeb/public/participant/info?keytype=DK%3ACVR&asXML=true&key=%1', Locked = true;
    begin
        VATRegNo := RemoveCountryFromVATRegNo(VATRegNo, CountryCode);
        if VATRegNo = '' then
            exit(false);

#pragma warning disable AA0131
        Uri := StrSubstNo(NemHandelUrlLbl, VATRegNo);
#pragma warning restore
        if not Client.Get(Uri, ResponseMessage) then
            exit(false);
        ResponseMessage.Content.ReadAs(ResponseXML);
        if not XmlDocument.ReadFrom(ResponseXML, Document) then
            exit(false);
        if Document.SelectSingleNode('ParticipantInfoDTO/Participant/UnitName', Node) then
            NameOfOwner := Node.AsXmlElement().InnerText();
        exit(true);
    end;

    local procedure DoVATRegNoLookupNemHandel(VATRegNo: Text[20]; CountryCode: Code[10]; GLN: Code[13]): Boolean
    var
        OIOUBLSetup: Record "NPR OIOUBL Setup";
        CompanyInformation: Record "Company Information";
        VATRegNoSrvConfig: Record "VAT Reg. No. Srv Config";
        Customer: Record Customer;
        NameOfOwner: Text;
        ValidVATRegNoLbl: Label 'Response from Nemhandel\\%1 is found and registered for %2', Comment = '%1 - VAT RegNo, %2 - Name of owner';
        InvalidVATRegNoLbl: Label 'Response from Nemhandel\\%1 is not found', Comment = '%1 - VAT RegNo';
    begin
        if VATRegNoSrvConfig.VATRegNoSrvIsEnabled() then
            exit;
        if not OIOUBLSetup.Get() then
            exit;
        if not OIOUBLSetup."Use Nemhandel Lookup" then
            exit;
        CompanyInformation.Get();
        if (CountryCode <> '') and (CountryCode <> CompanyInformation."Country/Region Code") then
            exit;
        if VATRegNoLookupNemHandel(VATRegNo, CountryCode, NameOfOwner) then begin
            Message(ValidVATRegNoLbl, Customer.FieldCaption("VAT Registration No."), NameOfOwner);
            if GLN <> '' then
                GLNLookupNemHandel(GLN, VATRegNo, CountryCode, true);
        end else
            Message(InvalidVATRegNoLbl, Customer.FieldCaption("VAT Registration No."));
    end;



    local procedure RemoveCountryFromVATRegNo(VATRegNo: Text[20]; CountryCode: Code[10]): Text[20]
    var
        CompanyInformation: Record "Company Information";
    begin
        if CountryCode = '' then begin
            CompanyInformation.Get();
            CompanyInformation.TestField("Country/Region Code");
            CountryCode := CompanyInformation."Country/Region Code";
        end;
#pragma warning disable AA0139
        exit(VATRegNo.TrimStart(CountryCode));
#pragma warning restore
    end;

    [EventSubscriber(ObjectType::Table, Database::Customer, 'OnAfterValidateEvent', 'VAT Registration No.', true, true)]
    local procedure CustomerOnAfterValidateVATRegistrationNo(var Rec: Record Customer)
    begin
        DoVATRegNoLookupNemHandel(Rec."VAT Registration No.", Rec."Country/Region Code", Rec.GLN);
    end;

    [EventSubscriber(ObjectType::Table, Database::Customer, 'OnAfterValidateEvent', 'GLN', true, true)]
    local procedure CustomerOnAfterValidateGLN(var Rec: Record Customer)
    begin
        GLNLookupNemHandel(Rec.GLN, Rec."VAT Registration No.", Rec."Country/Region Code", false);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Header", 'OnAfterValidateEvent', 'VAT Registration No.', true, true)]
    local procedure SalesHeaderOnAfterValidateVATRegistrationNo(var Rec: Record "Sales Header")
    var
        OIOUBLSetup: Record "NPR OIOUBL Setup";
        RecRef: RecordRef;
        OIOUBLGLN: Code[13];
    begin
        if OIOUBLSetup.IsOIOUBLInstalled() then begin
            RecRef.GetTable(Rec);
            OIOUBLGLN := CopyStr(RecRef.Field(13630).Value, 1, MaxStrLen(OIOUBLGLN));
        end;
        DoVATRegNoLookupNemHandel(Rec."VAT Registration No.", Rec."Bill-to Country/Region Code", OIOUBLGLN);
    end;
}
