codeunit 6184670 "NPR DK Gen. SAF-T Cash File"
{
    Access = Internal;
    TableNo = "NPR DK SAF-T Cash Export Line";

    trigger OnRun()
    var
        SAFTExportHeader: Record "NPR DK SAF-T Cash Exp. Header";
    begin
        Rec.LockTable();
        Rec.Validate("Server Instance ID", ServiceInstanceId());
        Rec.Validate("Session ID", SessionId());
        Rec.Validate("Created Date/Time", 0DT);
        Rec.Validate("No. Of Retries", 3);
        Rec.Modify();
        Commit();

        if GuiAllowed() then
            Window.Open(
                '#1#################################\\' +
                '@2@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@');

        CompanyInformation.Get();
        SAFTExportHeader.Get(Rec.ID);
        ExportHeader(SAFTExportHeader);
        ExportCompanyInfo(Rec);
        if GuiAllowed() then
            Window.Close();
        FinalizeExport(Rec, SAFTExportHeader);
    end;

    local procedure ExportHeader(SAFTExportHeader: Record "NPR DK SAF-T Cash Exp. Header")
    var
        GeneralLedgerSetup: Record "General Ledger Setup";
        BaseAppId: Codeunit "BaseApp ID";
        GeneratingHeaderTxt: Label 'Generating XML header element...';
        BusinessCentralNameLbl: Label 'Microsoft Dynamics 365 Business Central';
        MicrosoftLbl: Label 'Microsoft';
        Info: ModuleInfo;
    begin
        SAFTXMLHelper.Initialize();

        if GuiAllowed() then
            Window.Update(1, GeneratingHeaderTxt);

        SAFTXMLHelper.AddNewXMLNode('header', '');

        if Date2DMY(SAFTExportHeader."Starting Date", 3) = Date2DMY(SAFTExportHeader."Ending Date", 3) then
            SAFTXMLHelper.AppendXMLNode('fiscalYear', Format(Date2DMY(SAFTExportHeader."Starting Date", 3)))
        else
            SAFTXMLHelper.AppendXMLNode('fiscalYear',
                StrSubstNo('%1-%2', Format(Date2DMY(SAFTExportHeader."Starting Date", 3)), Format(Date2DMY(SAFTExportHeader."Ending Date", 3))));

        SAFTXMLHelper.AppendXMLNode('startDate', FormatDate(SAFTExportHeader."Starting Date"));
        SAFTXMLHelper.AppendXMLNode('endDate', FormatDate(SAFTExportHeader."Ending Date"));

        GeneralLedgerSetup.Get();
        SAFTXMLHelper.AppendXMLNode('curCode', GeneralLedgerSetup."LCY Code");

        SAFTXMLHelper.AppendXMLNode('dateCreated', FormatDate(Today()));
        SAFTXMLHelper.AppendXMLNode('timeCreated', Format(Time, 0, 9));

        SAFTXMLHelper.AppendXMLNode('softwareDesc', BusinessCentralNameLbl);

        NavApp.GetModuleInfo(BaseAppId.Get(), Info);
        SAFTXMLHelper.AppendXMLNode('softwareVersion', Format(Info.DataVersion.Major));

        SAFTXMLHelper.AppendXMLNode('softwareCompanyName', MicrosoftLbl);
        SAFTXMLHelper.AppendXMLNode('auditfileVersion', '1.0');
        SAFTXMLHelper.AppendXMLNode('eaderComment', SAFTExportHeader."Header Comment");
        SAFTXMLHelper.AppendXMLNode('userID', CopyStr(UserId(), 1, 35));

        ExportAuditFileSender();

        SAFTXMLHelper.FinalizeXMLNode();
    end;

    local procedure ExportAuditFileSender()
    var
        DKFiscalizationSetup: Record "NPR DK Fiscalization Setup";
        Vendor: Record Vendor;
        GeneratingAuditFileSenderLbl: Label 'Generating XML Audit File Sender element...';
    begin
        DKFiscalizationSetup.Get();
        if DKFiscalizationSetup."SAF-T Audit File Sender" = '' then
            exit;

        Vendor.Get(DKFiscalizationSetup."SAF-T Audit File Sender");

        if GuiAllowed() then
            Window.Update(1, GeneratingAuditFileSenderLbl);

        SAFTXMLHelper.AddNewXMLNode('auditfileSender', '');

        SAFTXMLHelper.AppendXMLNode('companyIdent', Vendor."VAT Registration No.");
        SAFTXMLHelper.AppendXMLNode('companyName', CombineWithSpace(Vendor.Name, Vendor."Name 2", 100));

        if Vendor."VAT Registration No." <> '' then begin
            SAFTXMLHelper.AppendXMLNode('taxRegistrationCountry', GetCountryISOCode(Vendor."Country/Region Code"));
            SAFTXMLHelper.AppendXMLNode('taxRegIdent', FormatVATRegNo(Vendor."VAT Registration No."));
        end;

        ExportAddress(
            'streetAddress', CombineWithSpace(Vendor.Address, Vendor."Address 2", 0),
            Vendor.City, Vendor."Post Code", Vendor.County, GetCountryISOCode(Vendor."Country/Region Code"));
        ExportAddress(
            'postalAddress', CombineWithSpace(Vendor.Address, Vendor."Address 2", 0),
            Vendor.City, Vendor."Post Code", Vendor.County, GetCountryISOCode(Vendor."Country/Region Code"));

        SAFTXMLHelper.FinalizeXMLNode();
    end;

    local procedure ExportCompanyInfo(SAFTExportLine: Record "NPR DK SAF-T Cash Export Line")
    var
        POSStore: Record "NPR POS Store";
        GeneratingCompanyInfoLbl: Label 'Generating XML Company element...';
    begin
        if GuiAllowed() then
            Window.Update(1, GeneratingCompanyInfoLbl);

        SAFTXMLHelper.AddNewXMLNode('company', '');

        SAFTXMLHelper.AppendXMLNode('companyIdent', CompanyInformation."VAT Registration No.");
        SAFTXMLHelper.AppendXMLNode('companyName', CombineWithSpace(CompanyInformation.Name, CompanyInformation."Name 2", 100));
        SAFTXMLHelper.AppendXMLNode('taxRegistrationCountry', GetCountryISOCode(CompanyInformation."Country/Region Code"));
        SAFTXMLHelper.AppendXMLNode('taxRegIdent', FormatVATRegNo(CompanyInformation."VAT Registration No."));

        ExportAddress(
            'streetAddress', CombineWithSpace(CompanyInformation.Address, CompanyInformation."Address 2", 0),
            CompanyInformation.City, CompanyInformation."Post Code", CompanyInformation.County, GetCountryISOCode(CompanyInformation."Country/Region Code"));
        ExportAddress(
            'postalAddress', CombineWithSpace(CompanyInformation.Address, CompanyInformation."Address 2", 0),
            CompanyInformation.City, CompanyInformation."Post Code", CompanyInformation.County, GetCountryISOCode(CompanyInformation."Country/Region Code"));

        ExportBusinessPartners();
        ExportChartOfAccounts();
        // ExportVATCodes(); (optional)
        // ExportPeriods (optional)
        ExportSalespersons();
        ExportItems();
        AddBasicsNode();

        ExportLocations(POSStore, SAFTExportLine, true, true);

        ExportRegisteredArticles();
        ExportRegisteredBasics();

        SAFTXMLHelper.FinalizeXMLNode();
    end;

    local procedure ExportAddress(AddressType: Text; StreetName: Text; City: Text; PostalCode: Text; County: Text; Country: Text)
    begin
        SAFTXMLHelper.AddNewXMLNode(AddressType, '');

        SAFTXMLHelper.AppendXMLNode('streetname', CopyStr(StreetName, 1, 100));

        if AddressType = 'postalAddress' then
            SAFTXMLHelper.AppendXMLNode('additionalAddressDetail', CopyStr(StreetName, 101, 100))
        else
            SAFTXMLHelper.AppendXMLNode('additionalAddressDetails', CopyStr(StreetName, 101, 100));

        SAFTXMLHelper.AppendXMLNode('city', City);
        SAFTXMLHelper.AppendXMLNode('postalCode', PostalCode);
        SAFTXMLHelper.AppendXMLNode('region', County);
        SAFTXMLHelper.AppendXMLNode('country', Country);

        SAFTXMLHelper.FinalizeXMLNode();
    end;

    local procedure ExportBusinessPartners()
    var
        Customer: Record Customer;
        Vendor: Record Vendor;
        ExportingBusPartnersTxt: Label 'Exporting Customers and Vendors to customerSuppliers XML element...';
    begin
        Customer.SetRange(Blocked, Customer.Blocked::" ");
        Vendor.SetRange(Blocked, Customer.Blocked::" ");
        if Customer.IsEmpty() and Vendor.IsEmpty() then
            exit;

        SAFTXMLHelper.AddNewXMLNode('customersSuppliers', '');
        if GuiAllowed() then begin
            Window.Update(1, ExportingBusPartnersTxt);
            TotalRecNo := Customer.Count() + Vendor.Count;
        end;

        if Customer.FindSet() then
            repeat
                CheckGuiAllowedAndUpdateWindow();
                ExportCustomer(Customer);
            until Customer.Next() = 0;

        if Vendor.FindSet() then
            repeat
                CheckGuiAllowedAndUpdateWindow();
                ExportVendor(Vendor);
            until Vendor.Next() = 0;

        SAFTXMLHelper.FinalizeXMLNode();
    end;

    local procedure ExportCustomer(Customer: Record Customer)
    begin
        SAFTXMLHelper.AddNewXMLNode('customerSupplier', '');

        if Customer."VAT Registration No." = '' then
            SAFTXMLHelper.AppendXMLNode('custSupID', ' ')
        else
            SAFTXMLHelper.AppendXMLNode('custSupID', Customer."VAT Registration No.");

        SAFTXMLHelper.AppendXMLNode('custSupName', CombineWithSpace(Customer.Name, Customer."Name 2", 100));
        SAFTXMLHelper.AppendXMLNode('custSupType', 'Customer');
        SAFTXMLHelper.AppendXMLNode('contact', CopyStr(Customer.Contact, 1, 50));
        SAFTXMLHelper.AppendXMLNode('telephone', Customer."Phone No.");
        SAFTXMLHelper.AppendXMLNode('fax', Customer."Fax No.");
        SAFTXMLHelper.AppendXMLNode('eMail', Customer."E-Mail");
        SAFTXMLHelper.AppendXMLNode('website', Customer."Home Page");
        SAFTXMLHelper.AppendXMLNode('taxRegistrationCountry', GetCountryISOCode(Customer."Country/Region Code"));
        SAFTXMLHelper.AppendXMLNode('taxRegIdent', FormatVATRegNo(Customer."VAT Registration No."));

        ExportAddress(
            'streetAddress', CombineWithSpace(Customer.Address, Customer."Address 2", 0),
            Customer.City, Customer."Post Code", Customer.County, GetCountryISOCode(Customer."Country/Region Code"));
        ExportAddress(
            'postalAddress', CombineWithSpace(Customer.Address, Customer."Address 2", 0),
            Customer.City, Customer."Post Code", Customer.County, GetCountryISOCode(Customer."Country/Region Code"));

        SAFTXMLHelper.FinalizeXMLNode();
    end;

    local procedure ExportVendor(Vendor: Record Vendor)
    begin
        SAFTXMLHelper.AddNewXMLNode('customerSupplier', '');

        if Vendor."VAT Registration No." = '' then
            SAFTXMLHelper.AppendXMLNode('custSupID', ' ')
        else
            SAFTXMLHelper.AppendXMLNode('custSupID', Vendor."VAT Registration No.");

        SAFTXMLHelper.AppendXMLNode('custSupName', CombineWithSpace(Vendor.Name, Vendor."Name 2", 100));
        SAFTXMLHelper.AppendXMLNode('custSupType', 'Supplier');
        SAFTXMLHelper.AppendXMLNode('contact', CopyStr(Vendor.Contact, 1, 50));
        SAFTXMLHelper.AppendXMLNode('telephone', Vendor."Phone No.");
        SAFTXMLHelper.AppendXMLNode('fax', Vendor."Fax No.");
        SAFTXMLHelper.AppendXMLNode('eMail', Vendor."E-Mail");
        SAFTXMLHelper.AppendXMLNode('website', Vendor."Home Page");
        SAFTXMLHelper.AppendXMLNode('taxRegistrationCountry', GetCountryISOCode(Vendor."Country/Region Code"));
        SAFTXMLHelper.AppendXMLNode('taxRegIdent', FormatVATRegNo(Vendor."VAT Registration No."));

        ExportAddress(
            'streetAddress', CombineWithSpace(Vendor.Address, Vendor."Address 2", 0),
            Vendor.City, Vendor."Post Code", Vendor.County, GetCountryISOCode(Vendor."Country/Region Code"));
        ExportAddress(
            'postalAddress', CombineWithSpace(Vendor.Address, Vendor."Address 2", 0),
            Vendor.City, Vendor."Post Code", Vendor.County, GetCountryISOCode(Vendor."Country/Region Code"));

        SAFTXMLHelper.FinalizeXMLNode();
    end;

    local procedure ExportChartOfAccounts()
    var
        GLAccount: Record "G/L Account";
        ExportingChartOfAccountsTxt: Label 'Exporting Chart of Accounts to generalLedger XML element...';
    begin
        GLAccount.SetRange("Account Type", GLAccount."Account Type"::Posting);
        if not GLAccount.FindSet() then
            exit;

        SAFTXMLHelper.AddNewXMLNode('generalLedger', '');

        if GuiAllowed() then begin
            Window.Update(1, ExportingChartOfAccountsTxt);
            TotalRecNo := GLAccount.Count();
        end;

        repeat
            CheckGuiAllowedAndUpdateWindow();

            SAFTXMLHelper.AddNewXMLNode('ledgerAccount', '');
            SAFTXMLHelper.AppendXMLNode('accID', GLAccount."No.");
            SAFTXMLHelper.AppendXMLNode('accDesc', GLAccount.Name);

            SAFTXMLHelper.FinalizeXMLNode();
        until GLAccount.Next() = 0;

        SAFTXMLHelper.FinalizeXMLNode();
    end;

    // local procedure ExportVATCodes()
    // var
    //     VATCode: Record "VAT Code";
    //     VATPostingSetup: Record "VAT Posting Setup";
    //     SAFTExportMgt: Codeunit "NPR DK SAF-T Cash Export Mgt.";
    //     NotApplicableVATCode: Code[10];
    //     FirstUsedOnPurch: Date;
    //     FirstUsedOnSales: Date;
    //     ExportingVatCodesTxt: Label 'Exporting VAT Codes to vatCodeDetails XML element...';
    // begin
    // if not VATCode.FindSet() then
    //     exit;

    // SAFTXMLHelper.AddNewXMLNode('vatCodeDetails', '');

    // if GuiAllowed() then begin
    //     Window.Update(1, ExportingVatCodesTxt);
    //     TotalRecNo := VATCode.Count();
    // end;

    // NotApplicableVATCode := SAFTExportMgt.GetNotApplicationVATCode();
    // repeat
    //     CheckGuiAllowedAndUpdateWindow();

    //     VATPostingSetup.SetRange("VAT Code", VATCode.Code);
    //     if VATPostingSetup.FindFirst() then begin
    //         if VATPostingSetup."Sales VAT Account" <> '' then
    //             FirstUsedOnSales := GetFistUsageDate(1);

    //         if VATPostingSetup."Purchase VAT Account" <> '' then
    //             FirstUsedOnPurch := GetFistUsageDate(0);

    //         if FirstUsedOnSales > FirstUsedOnPurch then
    //             ExportVatCodeDetail(VATCode.Code, VATCode.Code, CopyStr(VATPostingSetup.Description, 1, MaxStrLen(VATPostingSetup.Description)), FirstUsedOnPurch)
    //         else
    //             ExportVatCodeDetail(VATCode.Code, VATCode.Code, CopyStr(VATPostingSetup.Description, 1, MaxStrLen(VATPostingSetup.Description)), FirstUsedOnSales);
    //     end;
    // until VATCode.Next() = 0;

    // SAFTXMLHelper.FinalizeXMLNode();
    // end;

    // local procedure ExportVatCodeDetail(SAFTTaxCode: Code[20]; StandardTaxCode: Code[10]; Description: Text; FirstUsedOn: Date)
    // var
    // begin
    //     SAFTXMLHelper.AddNewXMLNode('vatCodeDetail', '');

    //     SAFTXMLHelper.AppendXMLNode('vatCode', SAFTTaxCode);
    //     SAFTXMLHelper.AppendXMLNode('dateOfEntry', FormatDate(FirstUsedOn));
    //     SAFTXMLHelper.AppendXMLNode('vatDesc', Description);
    //     SAFTXMLHelper.AppendXMLNode('standardVatCode', StandardTaxCode);

    //     SAFTXMLHelper.FinalizeXMLNode();
    // end;

    // local procedure GetFistUsageDate(EntryType: Option Purchase,Sale): Date
    // var
    //     POSEntry: Record "NPR POS Entry";
    //     POSSalesLine: Record "NPR POS Entry Sales Line";
    // begin
    //     POSSalesLine.SetCurrentKey("VAT Bus. Posting Group", "VAT Prod. Posting Group", "POS Entry No.", "Gen. Posting Type");
    //     if EntryType = EntryType::Purchase then
    //         POSSalesLine.SetRange("Gen. Posting Type", POSSalesLine."Gen. Posting Type"::Purchase)
    //     else
    //         POSSalesLine.SetFilter("Gen. Posting Type", '<>%1', POSSalesLine."Gen. Posting Type"::Purchase);

    //     if POSSalesLine.FindFirst() then
    //         if POSEntry.Get(POSSalesLine."POS Entry No.") then
    //             exit(POSEntry."Entry Date");

    //     exit(0D);
    // end;

    local procedure ExportSalespersons()
    var
        Employee: Record Employee;
        Salesperson: Record "Salesperson/Purchaser";
        ExportingSalespeopleTxt: Label 'Exporting Salesperson/Purchaser to employees XML element...';
    begin
        if not Salesperson.FindSet() then
            exit;

        SAFTXMLHelper.AddNewXMLNode('employees', '');

        if GuiAllowed() then begin
            Window.Update(1, ExportingSalespeopleTxt);
            TotalRecNo := Salesperson.Count();
        end;

        repeat
            CheckGuiAllowedAndUpdateWindow();

            Employee.SetRange("Salespers./Purch. Code", Salesperson.Code);
            if not Employee.FindFirst() then
                Employee.Init();

            SAFTXMLHelper.AddNewXMLNode('employee', '');

            SAFTXMLHelper.AppendXMLNode('emplID', Salesperson.Code);
#if BC17 or BC18 or BC19
            SAFTXMLHelper.AppendXMLNode('dateOfEntry', FormatDate(Employee."Employment Date"));
#else
            SAFTXMLHelper.AppendXMLNode('dateOfEntry', FormatDate(DT2Date(Employee.SystemCreatedAt)));
#endif
            SAFTXMLHelper.AppendXMLNode('timeOfEntry', '08:00:00');
            SAFTXMLHelper.AppendXMLNode('firstName', Employee."First Name");

            if Employee."Last Name" <> '' then
                SAFTXMLHelper.AppendXMLNode('surName', Employee."Last Name")
            else
                SAFTXMLHelper.AppendXMLNode('firstName', Salesperson.Name);

            SAFTXMLHelper.FinalizeXMLNode();
        until Salesperson.Next() = 0;

        SAFTXMLHelper.FinalizeXMLNode();
    end;

    local procedure ExportItems()
    var
        Item: Record Item;
        ExportingItemsTxt: Label 'Exporting Items to articles XML element...';
    begin
        SAFTXMLHelper.AddNewXMLNode('articles', '');
        _ArticlesXMLNode := SAFTXMLHelper.GetCurrXMLNode();

        Item.SetLoadFields(Description, "Description 2");
        if Item.FindSet() then begin
            if GuiAllowed() then begin
                Window.Update(1, ExportingItemsTxt);
                TotalRecNo := Item.Count();
            end;

            repeat
                CheckGuiAllowedAndUpdateWindow();
                ExportArticle(Item."No.", DT2Date(Item.SystemCreatedAt), CombineWithSpace(Item.Description, Item."Description 2", 0));
            until Item.Next() = 0;
        end;

        SAFTXMLHelper.FinalizeXMLNode();
    end;

    local procedure ExportArticle(ArtID: Text; DateOfEntry: Date; ArtDesc: Text)
    begin
        SAFTXMLHelper.AddNewXMLNode('article', '');

        SAFTXMLHelper.AppendXMLNode('artID', ArtID);
        SAFTXMLHelper.AppendXMLNode('dateOfEntry', FormatDate(DateOfEntry));
        SAFTXMLHelper.AppendXMLNode('artDesc', ArtDesc);

        SAFTXMLHelper.FinalizeXMLNode();
    end;

    local procedure AddBasicsNode()
    begin
        SAFTXMLHelper.AddNewXMLNode('basics', '');
        _BasicsXMLNode := SAFTXMLHelper.GetCurrXMLNode();
        SAFTXMLHelper.FinalizeXMLNode();
    end;

    local procedure GetArtID(var POSEntrySalesLine: Record "NPR POS Entry Sales Line"): Text
    var
        Prefix: Text;
    begin
        case POSEntrySalesLine.Type of
            POSEntrySalesLine.Type::Item:
                exit(POSEntrySalesLine."No.");
            POSEntrySalesLine.Type::"G/L Account":
                Prefix := 'GL';
            POSEntrySalesLine.Type::Customer:
                Prefix := 'CUST';
            POSEntrySalesLine.Type::Voucher:
                Prefix := 'VOUCHER';
            POSEntrySalesLine.Type::Payout:
                Prefix := 'PAYOUT';
            else
                Prefix := 'ROUNDING';
        end;

        if POSEntrySalesLine."No." = '' then
            exit(Prefix);
        exit(Prefix + '-' + POSEntrySalesLine."No.");
    end;

    local procedure RegisterArticle(ArtID: Text; var POSEntrySalesLine: Record "NPR POS Entry Sales Line"; FirstSoldOn: Date)
    var
        Item: Record Item;
    begin
        if ArtID = '' then
            exit;
        if _RegisteredArticles.ContainsKey(ArtID) then begin
            if FirstSoldOn < _RegisteredArticleDates.Get(ArtID) then
                _RegisteredArticleDates.Set(ArtID, FirstSoldOn);
            exit;
        end;
        if POSEntrySalesLine.Type = POSEntrySalesLine.Type::Item then begin
            if not _ExistingItems.ContainsKey(POSEntrySalesLine."No.") then begin
                Item.SetLoadFields("No.");
                _ExistingItems.Add(POSEntrySalesLine."No.", Item.Get(POSEntrySalesLine."No."));
            end;
            if _ExistingItems.Get(POSEntrySalesLine."No.") then
                exit;
        end;

        if POSEntrySalesLine.Description <> '' then
            _RegisteredArticles.Add(ArtID, POSEntrySalesLine.Description)
        else
            _RegisteredArticles.Add(ArtID, ArtID);
        _RegisteredArticleDates.Add(ArtID, FirstSoldOn);
    end;

    local procedure ExportRegisteredArticles()
    var
        ArtID: Text;
    begin
        SAFTXMLHelper.ReopenXMLNode(_ArticlesXMLNode);
        foreach ArtID in _RegisteredArticles.Keys() do
            ExportArticle(ArtID, _RegisteredArticleDates.Get(ArtID), _RegisteredArticles.Get(ArtID));
        SAFTXMLHelper.FinalizeXMLNode();

        if not _ArticlesXMLNode.HasElements() then
            _ArticlesXMLNode.Remove();
    end;

    local procedure RegisterBasic(BasicID: Text; BasicType: Text; PredefinedBasicID: Text; BasicDesc: Text)
    begin
        if _BasicIDs.Contains(BasicID) then
            exit;

        _BasicIDs.Add(BasicID);
        _BasicTypes.Add(BasicID, BasicType);
        _BasicPredefinedIDs.Add(BasicID, PredefinedBasicID);
        if BasicDesc <> '' then
            _BasicDescs.Add(BasicID, BasicDesc)
        else
            _BasicDescs.Add(BasicID, BasicID);
    end;

    local procedure ExportRegisteredBasics()
    var
        BasicID: Text;
    begin
        SAFTXMLHelper.ReopenXMLNode(_BasicsXMLNode);
        foreach BasicID in _BasicIDs do begin
            SAFTXMLHelper.AddNewXMLNode('basic', '');

            SAFTXMLHelper.AppendXMLNode('basicType', _BasicTypes.Get(BasicID));
            SAFTXMLHelper.AppendXMLNode('basicID', BasicID);
            SAFTXMLHelper.AppendXMLNode('predefinedBasicID', _BasicPredefinedIDs.Get(BasicID));
            SAFTXMLHelper.AppendXMLNode('basicDesc', _BasicDescs.Get(BasicID));

            SAFTXMLHelper.FinalizeXMLNode();
        end;
        SAFTXMLHelper.FinalizeXMLNode();

        if not _BasicsXMLNode.HasElements() then
            _BasicsXMLNode.Remove();
    end;

    local procedure ExportLocations(var POSStore: Record "NPR POS Store"; SAFTExportLine: Record "NPR DK SAF-T Cash Export Line"; IncludeTransactions: Boolean; IncludeEvents: Boolean)
    var
        POSAuditLog: Record "NPR POS Audit Log";
        POSEntry: Record "NPR POS Entry";
        POSUnit: Record "NPR POS Unit";
        SigningPOSAuditLog: Record "NPR POS Audit Log";
        TempPOSUnit: Record "NPR POS Unit" temporary;
        InStream: InStream;
        ExportLocationsMsg: Label 'Generating POS Stores XML element with transactions and events...';
        IsSigned: Boolean;
        Signature: Text;
    begin
        if GuiAllowed() then
            Window.Update(1, ExportLocationsMsg);

        if not POSStore.FindSet() then
            exit;

        repeat
            POSUnit.SetRange("POS Store Code", POSStore.Code);
            if not POSUnit.IsEmpty() then begin
                TempPOSUnit.DeleteAll();

                POSUnit.FindSet();
                repeat
                    if IncludeTransactions then begin
                        POSEntry.SetCurrentKey("POS Store Code", "POS Unit No.");
                        POSEntry.SetRange("POS Store Code", POSStore.Code);
                        POSEntry.SetRange("POS Unit No.", POSUnit."No.");
                        if not POSEntry.IsEmpty then begin
                            TempPOSUnit := POSUnit;
                            if not TempPOSUnit.Find() then
                                TempPOSUnit.Insert();
                        end;
                    end;
                    if IncludeEvents then begin
                        POSAuditLog.SetRange("Acted on POS Unit No.", POSUnit."No.");
                        if not POSAuditLog.IsEmpty then begin
                            TempPOSUnit := POSUnit;
                            if not TempPOSUnit.Find() then
                                TempPOSUnit.Insert();
                        end;
                    end;
                until POSUnit.Next() = 0;

                if TempPOSUnit.FindSet() then begin
                    SAFTXMLHelper.AddNewXMLNode('location', '');

                    SAFTXMLHelper.AppendXMLNode('name', CombineWithSpace(POSStore.Name, POSStore."Name 2", 100));

                    ExportAddress(
                        'streetAddress', CombineWithSpace(POSStore.Address, POSStore."Address 2", 0),
                        POSStore.City, POSStore."Post Code", POSStore.County, GetCountryISOCode(POSStore."Country/Region Code"));

                    repeat
                        SAFTXMLHelper.AddNewXMLNode('cashregister', '');

                        SAFTXMLHelper.AppendXMLNode('registerID', TempPOSUnit."No.");
                        SAFTXMLHelper.AppendXMLNode('regDesc', TempPOSUnit.Name);

                        if IncludeEvents then begin
                            Clear(POSAuditLog);
                            POSAuditLog.SetFilter("Log Timestamp", '%1..%2', CreateDateTime(SAFTExportLine."Starting Date", 0T), CreateDateTime(SAFTExportLine."Ending Date", 235959T));
                            POSAuditLog.SetRange("Action Type", POSAuditLog."Action Type"::DIRECT_SALE_END);
                            POSAuditLog.SetRange("Acted on POS Unit No.", TempPOSUnit."No.");
                            if POSAuditLog.FindSet() then
                                repeat
                                    SAFTXMLHelper.AddNewXMLNode('event', '');

                                    SAFTXMLHelper.AppendXMLNode('eventID', Format(POSAuditLog."Entry No."));
                                    SAFTXMLHelper.AppendXMLNode('eventType', Format(POSAuditLog."Action Type"));
                                    SAFTXMLHelper.AppendXMLNode('transID', POSAuditLog."Acted on POS Entry Fiscal No.");
                                    SAFTXMLHelper.AppendXMLNode('empID', POSAuditLog."Active Salesperson Code");
                                    SAFTXMLHelper.AppendXMLNode('eventDate', FormatDate(DT2Date(POSAuditLog."Log Timestamp")));
                                    SAFTXMLHelper.AppendXMLNode('eventTime', Format(DT2Time(POSAuditLog."Log Timestamp"), 0, 9));

                                    SAFTXMLHelper.FinalizeXMLNode();
                                until POSAuditLog.Next() = 0;
                        end;

                        if IncludeTransactions then begin
                            Clear(POSEntry);
                            POSEntry.SetCurrentKey("POS Store Code", "POS Unit No.");
                            POSEntry.SetRange("POS Store Code", POSStore.Code);
                            POSEntry.SetRange("POS Unit No.", TempPOSUnit."No.");
                            POSEntry.SetRange("Entry Date", SAFTExportLine."Starting Date", SAFTExportLine."Ending Date");
                            POSEntry.SetFilter("Entry Type", '%1|%2', POSEntry."Entry Type"::"Credit Sale", POSEntry."Entry Type"::"Direct Sale");
                            POSEntry.SetFilter("Fiscal No.", '<>%1', '');
                            if POSEntry.FindSet() then
                                repeat
                                    SAFTXMLHelper.AddNewXMLNode('cashtransaction', '');

                                    SAFTXMLHelper.AppendXMLNode('nr', Format(POSEntry."Entry No."));
                                    SAFTXMLHelper.AppendXMLNode('transID', POSEntry."Fiscal No.");
                                    SAFTXMLHelper.AppendXMLNode('transType', GetTransactionType(POSEntry));
                                    SAFTXMLHelper.AppendXMLNode('transAmntIn', FormatAmount(POSEntry."Amount Incl. Tax"));
                                    SAFTXMLHelper.AppendXMLNode('transAmntEx', FormatAmount(POSEntry."Amount Excl. Tax"));

                                    if POSEntry."Amount Incl. Tax" > 0 then
                                        SAFTXMLHelper.AppendXMLNode('amntTp', 'C')
                                    else
                                        SAFTXMLHelper.AppendXMLNode('amntTp', 'D');

                                    SAFTXMLHelper.AppendXMLNode('empID', POSEntry."Salesperson Code");
                                    SAFTXMLHelper.AppendXMLNode('transDate', FormatDate(POSEntry."Entry Date"));
                                    SAFTXMLHelper.AppendXMLNode('transTime', Format(POSEntry."Starting Time", 0, 9));

                                    ExportTransactionLines(POSEntry);
                                    ExportRounding(POSEntry);
                                    ExportPayments(POSEntry);

                                    SigningPOSAuditLog.SetRange("Acted on POS Entry No.", POSEntry."Entry No.");
                                    SigningPOSAuditLog.SetRange("Action Type", SigningPOSAuditLog."Action Type"::DIRECT_SALE_END);
                                    IsSigned := SigningPOSAuditLog.FindFirst();
                                    if IsSigned then begin
                                        Clear(InStream);
                                        Clear(Signature);
                                        SigningPOSAuditLog.CalcFields("Electronic Signature");
                                        if SigningPOSAuditLog."Electronic Signature".HasValue() then begin
                                            SigningPOSAuditLog."Electronic Signature".CreateInStream(InStream);
                                            while (not InStream.EOS) do
                                                InStream.Read(Signature);
                                        end;
                                        SAFTXMLHelper.AppendXMLNode('signature', Signature);
                                    end;

                                    SAFTXMLHelper.AppendXMLNode('keyVersion', '1');

                                    if IsSigned then
                                        SAFTXMLHelper.AppendXMLNode('certificateData', GetCertificateData(SigningPOSAuditLog."Certificate Thumbprint"));

                                    SAFTXMLHelper.AppendXMLNode('voidTransaction', 'false');
                                    SAFTXMLHelper.AppendXMLNode('trainingID', 'false');

                                    SAFTXMLHelper.FinalizeXMLNode();
                                until POSEntry.Next() = 0;
                        end;
                        SAFTXMLHelper.FinalizeXMLNode();

                    until TempPOSUnit.Next() = 0;

                    SAFTXMLHelper.FinalizeXMLNode();
                end;
            end;
        until POSStore.Next() = 0;
    end;

    local procedure GetTransactionType(POSEntry: Record "NPR POS Entry"): Text
    var
        POSEntrySalesLine: Record "NPR POS Entry Sales Line";
        HasReturns: Boolean;
        HasSales: Boolean;
        CashSaleIDTok: Label 'TRANS-CASHSALE', Locked = true;
        CashSaleTxt: Label 'Cash sale', Locked = true;
        CashSaleAndReturnIDTok: Label 'TRANS-SALERETURN', Locked = true;
        CashSaleAndReturnTxt: Label 'Cash sale and return', Locked = true;
        CreditSaleAndReturnIDTok: Label 'TRANS-CREDITSALERETURN', Locked = true;
        CreditSaleAndReturnTxt: Label 'Credit sale and return', Locked = true;
        CreditSaleIDTok: Label 'TRANS-CREDITSALE', Locked = true;
        CreditSaleTxt: Label 'Credit sale', Locked = true;
        InPaymentIDTok: Label 'TRANS-INPAYMENT', Locked = true;
        InPaymentTxt: Label 'In payment', Locked = true;
        OutPaymentIDTok: Label 'TRANS-OUTPAYMENT', Locked = true;
        OutPaymentTxt: Label 'Out payment', Locked = true;
        ReceivingPaymentIDTok: Label 'TRANS-RECEIVEPAYMENT', Locked = true;
        ReceivingPaymentTxt: Label 'Receiving payment', Locked = true;
        ReturnPaymentIDTok: Label 'TRANS-RETURN', Locked = true;
        ReturnPaymentTxt: Label 'Return payment', Locked = true;
    begin
        POSEntrySalesLine.SetRange("POS Entry No.", POSEntry."Entry No.");
        POSEntrySalesLine.SetRange(Type, POSEntrySalesLine.Type::Item);
        POSEntrySalesLine.SetFilter(Quantity, '>0');
        HasSales := not POSEntrySalesLine.IsEmpty();
        POSEntrySalesLine.SetFilter(Quantity, '<0');
        HasReturns := not POSEntrySalesLine.IsEmpty();

        if POSEntry."Entry Type" = POSEntry."Entry Type"::"Credit Sale" then begin
            if HasSales and HasReturns then begin
                RegisterBasic(CreditSaleAndReturnIDTok, '11', '11017', CreditSaleAndReturnTxt);
                exit(CreditSaleAndReturnIDTok);
            end;
            RegisterBasic(CreditSaleIDTok, '11', '11002', CreditSaleTxt);
            exit(CreditSaleIDTok);
        end;

        if not (HasSales or HasReturns) then begin
            POSEntrySalesLine.SetRange(Quantity);
            POSEntrySalesLine.SetRange(Type, POSEntrySalesLine.Type::Customer);
            if not POSEntrySalesLine.IsEmpty() then begin
                RegisterBasic(ReceivingPaymentIDTok, '11', '11005', ReceivingPaymentTxt);
                exit(ReceivingPaymentIDTok);
            end;

            POSEntrySalesLine.SetFilter(Type, '%1|%2', POSEntrySalesLine.Type::"G/L Account", POSEntrySalesLine.Type::Payout);
            if not POSEntrySalesLine.IsEmpty() then begin
                if POSEntry."Amount Incl. Tax" < 0 then begin
                    RegisterBasic(OutPaymentIDTok, '11', '11010', OutPaymentTxt);
                    exit(OutPaymentIDTok);
                end;
                RegisterBasic(InPaymentIDTok, '11', '11011', InPaymentTxt);
                exit(InPaymentIDTok);
            end;

            HasReturns := POSEntry."Amount Incl. Tax" < 0;
        end;

        case true of
            HasSales and HasReturns:
                begin
                    RegisterBasic(CashSaleAndReturnIDTok, '11', '11016', CashSaleAndReturnTxt);
                    exit(CashSaleAndReturnIDTok);
                end;
            HasReturns:
                begin
                    RegisterBasic(ReturnPaymentIDTok, '11', '11006', ReturnPaymentTxt);
                    exit(ReturnPaymentIDTok);
                end;
        end;

        RegisterBasic(CashSaleIDTok, '11', '11001', CashSaleTxt);
        exit(CashSaleIDTok);
    end;

    local procedure ExportTransactionLines(POSEntry: Record "NPR POS Entry")
    var
        POSEntrySalesLine: Record "NPR POS Entry Sales Line";
        AmountType: Text;
        ArtID: Text;
    begin
        POSEntrySalesLine.SetRange("POS Entry No.", POSEntry."Entry No.");
        POSEntrySalesLine.SetFilter(Type, '<>%1&<>%2', POSEntrySalesLine.Type::Comment, POSEntrySalesLine.Type::Rounding);
        POSEntrySalesLine.SetLoadFields("No.", Quantity, Description, "VAT %", "Amount Incl. VAT (LCY)", "Amount Excl. VAT (LCY)");
        if not POSEntrySalesLine.FindSet() then
            exit;

        repeat
            if POSEntrySalesLine."Amount Incl. VAT (LCY)" < 0 then
                AmountType := 'D'
            else
                AmountType := 'C';
            ArtID := GetArtID(POSEntrySalesLine);

            SAFTXMLHelper.AddNewXMLNode('ctLine', '');

            SAFTXMLHelper.AppendXMLNode('nr', Format(POSEntry."Entry No."));
            SAFTXMLHelper.AppendXMLNode('lineID', Format(POSEntrySalesLine."Line No."));
            SAFTXMLHelper.AppendXMLNode('lineType', GetLineType(POSEntrySalesLine));
            SAFTXMLHelper.AppendXMLNode('artID', ArtID);
            SAFTXMLHelper.AppendXMLNode('qnt', Format(Abs(POSEntrySalesLine.Quantity), 0, 9));
            SAFTXMLHelper.AppendXMLNode('lineAmntIn', FormatAmount(Abs(POSEntrySalesLine."Amount Incl. VAT (LCY)")));
            SAFTXMLHelper.AppendXMLNode('lineAmntEx', FormatAmount(Abs(POSEntrySalesLine."Amount Excl. VAT (LCY)")));
            SAFTXMLHelper.AppendXMLNode('amntTp', AmountType);
            SAFTXMLHelper.AppendXMLNode('cashTransLineDescr', POSEntrySalesLine.Description);

            SAFTXMLHelper.AddNewXMLNode('vat', '');
            SAFTXMLHelper.AppendXMLNode('vatPerc', Format(POSEntrySalesLine."VAT %", 0, 9));
            SAFTXMLHelper.AppendXMLNode('vatAmnt', FormatAmount(Abs(POSEntrySalesLine."Amount Incl. VAT (LCY)" - POSEntrySalesLine."Amount Excl. VAT (LCY)")));
            SAFTXMLHelper.AppendXMLNode('vatAmntTp', AmountType);
            SAFTXMLHelper.AppendXMLNode('vatBasAmnt', FormatAmount(Abs(POSEntrySalesLine."Amount Excl. VAT (LCY)")));
            SAFTXMLHelper.FinalizeXMLNode();

            SAFTXMLHelper.FinalizeXMLNode();

            RegisterArticle(ArtID, POSEntrySalesLine, POSEntry."Entry Date");
        until POSEntrySalesLine.Next() = 0;
    end;

    local procedure GetLineType(POSEntrySalesLine: Record "NPR POS Entry Sales Line"): Text
    var
        CustomerIDTok: Label 'LINE-CUSTOMER', Locked = true;
        CustomerTxt: Label 'Customer payment or deposit', Locked = true;
        GLAccountIDTok: Label 'LINE-GLACCOUNT', Locked = true;
        GLAccountTxt: Label 'G/L account', Locked = true;
        PayoutIDTok: Label 'LINE-PAYOUT', Locked = true;
        PayoutTxt: Label 'Payout', Locked = true;
        ReturnIDTok: Label 'LINE-RETURN', Locked = true;
        ReturnTxt: Label 'Returned item', Locked = true;
        RoundingIDTok: Label 'LINE-ROUNDING', Locked = true;
        RoundingTxt: Label 'Rounding', Locked = true;
        SaleIDTok: Label 'LINE-SALE', Locked = true;
        SaleTxt: Label 'Sold item', Locked = true;
        VoucherIDTok: Label 'LINE-VOUCHER', Locked = true;
        VoucherTxt: Label 'Voucher', Locked = true;
    begin
        case POSEntrySalesLine.Type of
            POSEntrySalesLine.Type::Item:
                begin
                    if POSEntrySalesLine.Quantity < 0 then begin
                        RegisterBasic(ReturnIDTok, '05', '', ReturnTxt);
                        exit(ReturnIDTok);
                    end;
                    RegisterBasic(SaleIDTok, '05', '', SaleTxt);
                    exit(SaleIDTok);
                end;
            POSEntrySalesLine.Type::"G/L Account":
                begin
                    RegisterBasic(GLAccountIDTok, '05', '', GLAccountTxt);
                    exit(GLAccountIDTok);
                end;
            POSEntrySalesLine.Type::Customer:
                begin
                    RegisterBasic(CustomerIDTok, '05', '', CustomerTxt);
                    exit(CustomerIDTok);
                end;
            POSEntrySalesLine.Type::Voucher:
                begin
                    RegisterBasic(VoucherIDTok, '05', '', VoucherTxt);
                    exit(VoucherIDTok);
                end;
            POSEntrySalesLine.Type::Payout:
                begin
                    RegisterBasic(PayoutIDTok, '05', '', PayoutTxt);
                    exit(PayoutIDTok);
                end;
        end;

        RegisterBasic(RoundingIDTok, '05', '', RoundingTxt);
        exit(RoundingIDTok);
    end;

    local procedure ExportRounding(POSEntry: Record "NPR POS Entry")
    var
        POSEntrySalesLine: Record "NPR POS Entry Sales Line";
    begin
        POSEntrySalesLine.SetRange("POS Entry No.", POSEntry."Entry No.");
        POSEntrySalesLine.SetRange(Type, POSEntrySalesLine.Type::Rounding);
        POSEntrySalesLine.CalcSums("Amount Incl. VAT (LCY)");
        if POSEntrySalesLine."Amount Incl. VAT (LCY)" = 0 then
            exit;

        SAFTXMLHelper.AddNewXMLNode('rounding', '');
        SAFTXMLHelper.AppendXMLNode('roundingAmnt', FormatAmount(POSEntrySalesLine."Amount Incl. VAT (LCY)"));
        SAFTXMLHelper.FinalizeXMLNode();
    end;

    local procedure ExportPayments(POSEntry: Record "NPR POS Entry")
    var
        POSEntryPaymentLine: Record "NPR POS Entry Payment Line";
    begin
        POSEntryPaymentLine.SetRange("POS Entry No.", POSEntry."Entry No.");
        POSEntryPaymentLine.SetLoadFields("POS Payment Method Code", "Amount (LCY)");
        if not POSEntryPaymentLine.FindSet() then
            exit;

        repeat
            RegisterPaymentType(POSEntryPaymentLine."POS Payment Method Code");

            SAFTXMLHelper.AddNewXMLNode('payment', '');

            SAFTXMLHelper.AppendXMLNode('paymentType', POSEntryPaymentLine."POS Payment Method Code");
            SAFTXMLHelper.AppendXMLNode('paidAmnt', FormatAmount(POSEntryPaymentLine."Amount (LCY)"));
            SAFTXMLHelper.AppendXMLNode('empID', POSEntry."Salesperson Code");
            if _BasicPredefinedIDs.Get(POSEntryPaymentLine."POS Payment Method Code") in ['12002', '12003', '12011'] then
                SAFTXMLHelper.AppendXMLNode('paymentRefID', GetEFTTransactionID(POSEntry, POSEntryPaymentLine));

            SAFTXMLHelper.FinalizeXMLNode();
        until POSEntryPaymentLine.Next() = 0;
    end;

    local procedure RegisterPaymentType(POSPaymentMethodCode: Code[10])
    var
        POSPaymentMethod: Record "NPR POS Payment Method";
        BasicDesc: Text;
    begin
        if _BasicIDs.Contains(POSPaymentMethodCode) then
            exit;

        if not POSPaymentMethod.Get(POSPaymentMethodCode) then
            Clear(POSPaymentMethod);
        BasicDesc := POSPaymentMethod.Description;
        if BasicDesc = '' then
            BasicDesc := POSPaymentMethodCode;
        RegisterBasic(POSPaymentMethodCode, '12', GetPredefinedPaymentID(GetSAFTPaymentType(POSPaymentMethod, POSPaymentMethodCode)), BasicDesc);
    end;

    local procedure GetSAFTPaymentType(POSPaymentMethod: Record "NPR POS Payment Method"; POSPaymentMethodCode: Code[10]): Enum "NPR DK SAF-T Payment Type"
    var
        DKPOSPaymMethMapping: Record "NPR DK POS Paym. Meth. Mapping";
    begin
        if DKPOSPaymMethMapping.Get(POSPaymentMethodCode) then
            if DKPOSPaymMethMapping."SAF-T Payment Type" <> DKPOSPaymMethMapping."SAF-T Payment Type"::" " then
                exit(DKPOSPaymMethMapping."SAF-T Payment Type");

        if POSPaymentMethod.Code = '' then
            exit(Enum::"NPR DK SAF-T Payment Type"::Other);

        case POSPaymentMethod."Processing Type" of
            POSPaymentMethod."Processing Type"::CASH:
                exit(Enum::"NPR DK SAF-T Payment Type"::Cash);
            POSPaymentMethod."Processing Type"::VOUCHER,
            POSPaymentMethod."Processing Type"::"FOREIGN VOUCHER":
                exit(Enum::"NPR DK SAF-T Payment Type"::"Gift Token");
            POSPaymentMethod."Processing Type"::CHECK:
                exit(Enum::"NPR DK SAF-T Payment Type"::Check);
            POSPaymentMethod."Processing Type"::EFT:
                exit(Enum::"NPR DK SAF-T Payment Type"::"Credit Card");
        end;

        exit(Enum::"NPR DK SAF-T Payment Type"::Other);
    end;

    local procedure GetPredefinedPaymentID(SAFTPaymentType: Enum "NPR DK SAF-T Payment Type"): Text
    begin
        case SAFTPaymentType of
            SAFTPaymentType::Cash:
                exit('12001');
            SAFTPaymentType::"Debit Card":
                exit('12002');
            SAFTPaymentType::"Credit Card":
                exit('12003');
            SAFTPaymentType::"Bank Account":
                exit('12004');
            SAFTPaymentType::"Gift Token":
                exit('12005');
            SAFTPaymentType::"Customer Card":
                exit('12006');
            SAFTPaymentType::Loyalty:
                exit('12007');
            SAFTPaymentType::"Bottle Deposit":
                exit('12008');
            SAFTPaymentType::Check:
                exit('12009');
            SAFTPaymentType::"Credit Note":
                exit('12010');
            SAFTPaymentType::"Mobile Phone App":
                exit('12011');
        end;

        exit('12999');
    end;

    internal procedure IsPaymentReferenceRequired(POSPaymentMethodCode: Code[10]): Boolean
    var
        POSPaymentMethod: Record "NPR POS Payment Method";
    begin
        if not POSPaymentMethod.Get(POSPaymentMethodCode) then
            Clear(POSPaymentMethod);
        exit(GetPredefinedPaymentID(GetSAFTPaymentType(POSPaymentMethod, POSPaymentMethodCode)) in ['12002', '12003', '12011']);
    end;

    internal procedure GetEFTTransactionID(POSEntry: Record "NPR POS Entry"; POSEntryPaymentLine: Record "NPR POS Entry Payment Line"): Text
    var
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
    begin
        EFTTransactionRequest.SetCurrentKey("Sales Ticket No.", "Sales Line No.");
        EFTTransactionRequest.SetRange("Sales Ticket No.", POSEntry."Document No.");
        EFTTransactionRequest.SetRange("Sales Line No.", POSEntryPaymentLine."Line No.");
        EFTTransactionRequest.SetRange("Register No.", POSEntry."POS Unit No.");
        EFTTransactionRequest.SetRange(Successful, true);
        EFTTransactionRequest.SetLoadFields("External Transaction ID", "Reference Number Output", "Authorisation Number");
        if not EFTTransactionRequest.FindLast() then
            exit('');

        if EFTTransactionRequest."External Transaction ID" <> '' then
            exit(EFTTransactionRequest."External Transaction ID");
        if EFTTransactionRequest."Reference Number Output" <> '' then
            exit(EFTTransactionRequest."Reference Number Output");
        exit(EFTTransactionRequest."Authorisation Number");
    end;

    local procedure GetCertificateData(CertificateThumbprint: Text): Text
    var
        DKFiscalizationSetup: Record "NPR DK Fiscalization Setup";
        X509Certificate2: Codeunit X509Certificate2;
        InStr: InStream;
        Base64Cert: Text;
        RawCertData: Text;
        Password: SecretText;
        Position: Integer;
        LF: Text[1];
    begin
        if not _CertificateDataLoaded then begin
            _CertificateDataLoaded := true;
            DKFiscalizationSetup.SetAutoCalcFields("Signing Certificate");
            if not DKFiscalizationSetup.Get() then
                exit('');
            if not DKFiscalizationSetup."Signing Certificate".HasValue() then
                exit('');

            DKFiscalizationSetup."Signing Certificate".CreateInStream(InStr, TextEncoding::UTF8);
            InStr.ReadText(Base64Cert);
            Password := DKFiscalizationSetup."Signing Certificate Password";
            RawCertData := Base64Cert;
            X509Certificate2.VerifyCertificate(RawCertData, Password, Enum::"X509 Content Type"::Cert);

            LF[1] := 10;
            _CertificateData := '-----BEGIN CERTIFICATE-----' + LF;
            Position := 1;
            while Position <= StrLen(RawCertData) do begin
                _CertificateData += CopyStr(RawCertData, Position, 64) + LF;
                Position += 64;
            end;
            _CertificateData += '-----END CERTIFICATE-----';
            _CertificateThumbprint := DKFiscalizationSetup."Signing Certificate Thumbprint";
        end;

        if CertificateThumbprint <> _CertificateThumbprint then
            exit('');
        exit(_CertificateData);
    end;

    local procedure FinalizeExport(var SAFTExportLine: Record "NPR DK SAF-T Cash Export Line"; SAFTExportHeader: Record "NPR DK SAF-T Cash Exp. Header")
    var
        SAFTExportMgt: Codeunit "NPR DK SAF-T Cash Export Mgt.";
        TypeHelper: Codeunit "Type Helper";
    begin
        SAFTExportLine.Get(SAFTExportLine.ID, SAFTExportLine."Line No.");
        SAFTExportLine.LockTable();

        SAFTXMLHelper.ExportXMLDocument(SAFTExportLine, SAFTExportHeader);

        SAFTExportLine.Validate(Status, SAFTExportLine.Status::Completed);
        SAFTExportLine.Validate(Progress, 10000);
        SAFTExportLine.Validate("Created Date/Time", TypeHelper.GetCurrentDateTimeInUserTimeZone());
        SAFTExportLine.Modify(true);

        Commit();

        SAFTExportHeader.Get(SAFTExportHeader.ID);
        SAFTExportMgt.UpdateExportStatus(SAFTExportHeader);
        SAFTExportMgt.LogSuccess(SAFTExportLine);
    end;

    local procedure GetCountryISOCode(CountryCode: Code[10]): Code[2]
    var
        Country: Record "Country/Region";
    begin
        if not Country.Get(CountryCode) then
            exit('');

        if Country."ISO Code" <> '' then
            exit(Country."ISO Code");

        exit('');
    end;

    local procedure CombineWithSpace(FirstString: Text; SecondString: Text; MaxLength: Integer) Result: Text
    begin
        Result := FirstString;
        if (Result <> '') and (SecondString <> '') then
            Result += ' ';
        Result += SecondString;
        if MaxLength <> 0 then
            Result := CopyStr(Result, 1, MaxLength);

        exit(Result);
    end;

    local procedure FormatDate(DateToFormat: Date): Text
    begin
        exit(Format(DateToFormat, 0, 9));
    end;

    local procedure FormatAmount(AmountToFormat: Decimal): Text
    begin
        exit(Format(AmountToFormat, 0, 9))
    end;

    local procedure FormatVATRegNo(VATRegistrationNo: Text[20]): Text
    begin
        if VATRegistrationNo = '' then
            exit('');

        exit(StrSubstNo('%1MVA', VATRegistrationNo));
    end;

    local procedure CheckGuiAllowedAndUpdateWindow()
    begin
        if GuiAllowed() then begin
            RecNo += 1;
            Window.Update(2, Round(RecNo / TotalRecNo * 10000, 1));
        end;
    end;

    var
        CompanyInformation: Record "Company Information";
        SAFTXMLHelper: Codeunit "NPR DK SAF-T XML Helper";
        Window: Dialog;
        RecNo: Integer;
        TotalRecNo: Integer;
        _ArticlesXMLNode: XmlElement;
        _BasicsXMLNode: XmlElement;
        _RegisteredArticles: Dictionary of [Text, Text];
        _RegisteredArticleDates: Dictionary of [Text, Date];
        _ExistingItems: Dictionary of [Code[20], Boolean];
        _BasicIDs: List of [Text];
        _BasicTypes: Dictionary of [Text, Text];
        _BasicPredefinedIDs: Dictionary of [Text, Text];
        _BasicDescs: Dictionary of [Text, Text];
        _CertificateDataLoaded: Boolean;
        _CertificateData: Text;
        _CertificateThumbprint: Text;
}