codeunit 6059782 "NPR Generate SAF-T Cash File"
{
    Access = Internal;
    TableNo = "NPR SAF-T Cash Export Line";

    trigger OnRun()
    var
        SAFTExportHeader: Record "NPR SAF-T Cash Export Header";
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

    local procedure ExportHeader(SAFTExportHeader: Record "NPR SAF-T Cash Export Header")
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
        NOFiscalizationSetup: Record "NPR NO Fiscalization Setup";
        Vendor: Record Vendor;
        GeneratingAuditFileSenderLbl: Label 'Generating XML Audit File Sender element...';
    begin
        NOFiscalizationSetup.Get();
        if NOFiscalizationSetup."SAF-T Audit File Sender" = '' then
            exit;

        Vendor.Get(NOFiscalizationSetup."SAF-T Audit File Sender");

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

    local procedure ExportCompanyInfo(SAFTExportLine: Record "NPR SAF-T Cash Export Line")
    var
        POSStore: Record "NPR POS Store";
        IncludeEvents: Boolean;
        IncludeTransactions: Boolean;
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

        if SAFTExportLine."Master Data" then begin
            ExportBusinessPartners();
            ExportChartOfAccounts();
            // ExportVATCodes(); (optional)
            // ExportPeriods (optional)
            ExportSalespersons();
            ExportItems();
            // ExportBasics (optional)
        end;

        IncludeTransactions := not SAFTExportLine."Master Data";
        IncludeEvents := not SAFTExportLine."Master Data";
        if IncludeTransactions or IncludeEvents then
            ExportLocations(POSStore, SAFTExportLine, IncludeTransactions, IncludeEvents);

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
                if GuiAllowed() then begin
                    RecNo += 1;
                    Window.Update(2, Round(RecNo / TotalRecNo * 10000, 1));
                end;
                ExportCustomer(Customer);
            until Customer.Next() = 0;

        if Vendor.FindSet() then
            repeat
                if GuiAllowed() then begin
                    RecNo += 1;
                    Window.Update(2, Round(RecNo / TotalRecNo * 10000, 1));
                end;
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
            if GuiAllowed() then begin
                RecNo += 1;
                Window.Update(2, Round(RecNo / TotalRecNo * 10000, 1));
            end;

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
    //     SAFTExportMgt: Codeunit "NPR SAF-T Cash Export Mgt.";
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
    //     if GuiAllowed() then begin
    //         RecNo += 1;
    //         Window.Update(2, Round(RecNo / TotalRecNo * 10000, 1));
    //     end;

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
            if GuiAllowed() then begin
                RecNo += 1;
                Window.Update(2, Round(RecNo / TotalRecNo * 10000, 1));
            end;

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
        if not Item.FindSet() then
            exit;

        SAFTXMLHelper.AddNewXMLNode('articles', '');

        if GuiAllowed() then begin
            Window.Update(1, ExportingItemsTxt);
            TotalRecNo := Item.Count();
        end;

        repeat
            if GuiAllowed() then begin
                RecNo += 1;
                Window.Update(2, Round(RecNo / TotalRecNo * 10000, 1));
            end;

            SAFTXMLHelper.AddNewXMLNode('article', '');

            SAFTXMLHelper.AppendXMLNode('artID', Item."No.");
            SAFTXMLHelper.AppendXMLNode('dateOfEntry', FormatDate(DT2Date(Item.SystemCreatedAt)));
            SAFTXMLHelper.AppendXMLNode('artDesc', CombineWithSpace(Item.Description, Item."Description 2", 0));

            SAFTXMLHelper.FinalizeXMLNode();
        until Item.Next() = 0;

        SAFTXMLHelper.FinalizeXMLNode();
    end;

    local procedure ExportLocations(var POSStore: Record "NPR POS Store"; SAFTExportLine: Record "NPR SAF-T Cash Export Line"; IncludeTransactions: Boolean; IncludeEvents: Boolean)
    var
        POSAuditLog: Record "NPR POS Audit Log";
        POSEntry: Record "NPR POS Entry";
        POSUnit: Record "NPR POS Unit";
        TempPOSUnit: Record "NPR POS Unit" temporary;
        InStream: InStream;
        ExportLocationsMsg: Label 'Generating POS Stores XML element with transactions and events...';
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
                                    SAFTXMLHelper.AppendXMLNode('transAmntIn', FormatAmount(POSEntry."Amount Incl. Tax"));
                                    SAFTXMLHelper.AppendXMLNode('transAmntEx', FormatAmount(POSEntry."Amount Excl. Tax"));

                                    if POSEntry."Amount Incl. Tax" > 0 then
                                        SAFTXMLHelper.AppendXMLNode('amntTp', 'C')
                                    else
                                        SAFTXMLHelper.AppendXMLNode('amntTp', 'D');

                                    SAFTXMLHelper.AppendXMLNode('transDate', FormatDate(POSEntry."Entry Date"));
                                    SAFTXMLHelper.AppendXMLNode('transTime', Format(POSEntry."Starting Time", 0, 9));

                                    POSAuditLog.SetRange("Acted on POS Entry No.", POSEntry."Entry No.");
                                    if POSAuditLog.FindFirst() then begin
                                        Clear(InStream);
                                        Clear(Signature);
                                        POSAuditLog.CalcFields("Electronic Signature");
                                        if POSAuditLog."Electronic Signature".HasValue() then begin
                                            POSAuditLog."Electronic Signature".CreateInStream(InStream);
                                            while (not InStream.EOS) do
                                                InStream.Read(Signature);
                                        end;
                                        SAFTXMLHelper.AppendXMLNode('signature', Signature);
                                    end;

                                    SAFTXMLHelper.AppendXMLNode('keyVersion', '1');

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

    local procedure FinalizeExport(var SAFTExportLine: Record "NPR SAF-T Cash Export Line"; SAFTExportHeader: Record "NPR SAF-T Cash Export Header")
    var
        SAFTExportMgt: Codeunit "NPR SAF-T Cash Export Mgt.";
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

        SAFTExportMgt.UpdateExportStatus(SAFTExportHeader);
        SAFTExportMgt.LogSuccess(SAFTExportLine);
        SAFTExportMgt.StartExportLinesNotStartedYet(SAFTExportHeader);

        SAFTExportHeader.Get(SAFTExportHeader.ID);
        if SAFTExportHeader.Status = SAFTExportHeader.Status::Completed then
            if SAFTExportHeader.AllowedToExportIntoFolder() then
                SAFTExportMgt.GenerateZipFileFromSavedFiles(SAFTExportHeader)
            else
                SAFTExportMgt.BuildZipFilesWithAllRelatedXmlFiles(SAFTExportHeader);
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

    var
        CompanyInformation: Record "Company Information";
        SAFTXMLHelper: Codeunit "NPR SAF-T XML Helper";
        Window: Dialog;
        RecNo: Integer;
        TotalRecNo: Integer;
}