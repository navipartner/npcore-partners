page 6014507 "NPR APIV1 - Customers"
{
    APIGroup = 'core';
    APIPublisher = 'navipartner';
    APIVersion = 'v1.0';
    ChangeTrackingAllowed = true;
    DelayedInsert = true;
    EntityCaption = 'Customer';
    EntitySetCaption = 'Customers';
    EntityName = 'customer';
    EntitySetName = 'customers';
    Extensible = false;
    ODataKeyFields = SystemId;
    PageType = API;
    SourceTable = Customer;
    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(id; Rec.SystemId)
                {
                    Caption = 'Id', Locked = true;
                    Editable = false;
                }
                field(number; Rec."No.")
                {
                    Caption = 'No.', Locked = true;
                }
                field(displayName; Rec.Name)
                {
                    Caption = 'Display Name', Locked = true;
                    ShowMandatory = true;

                    trigger OnValidate()
                    begin
                        if Rec.Name = '' then
                            Error(BlankCustomerNameErr);
                        RegisterFieldSet(Rec.FieldNo(Name));
                    end;
                }

                field(displayName2; Rec."Name 2")
                {
                    Caption = 'Display Name 2', Locked = true;
                }
                field(type; Rec."Contact Type")
                {
                    Caption = 'Type', Locked = true;

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo("Contact Type"));
                    end;
                }

                field(searchName; Rec."Search Name")
                {
                    Caption = 'Search Name', Locked = true;
                }

                field(addressLine1; Rec.Address)
                {
                    Caption = 'Address Line 1', Locked = true;

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo("Address"));
                    end;
                }
                field(addressLine2; Rec."Address 2")
                {
                    Caption = 'Address Line 2', Locked = true;

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo("Address 2"));
                    end;
                }
                field(city; Rec.City)
                {
                    Caption = 'City', Locked = true;

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo("City"));
                    end;
                }
                field(state; Rec.County)
                {
                    Caption = 'State', Locked = true;

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo("County"));
                    end;
                }
                field(country; Rec."Country/Region Code")
                {
                    Caption = 'Country/Region Code', Locked = true;

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo("Country/Region Code"));
                    end;
                }
                field(postalCode; Rec."Post Code")
                {
                    Caption = 'Post Code', Locked = true;

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo("Post Code"));
                    end;
                }
                field(phoneNumber; Rec."Phone No.")
                {
                    Caption = 'Phone No.', Locked = true;

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo("Phone No."));
                    end;
                }

                field(mobilePhoneNumber; Rec."Mobile Phone No.")
                {
                    Caption = 'Mobile Phone No.', Locked = true;

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo("Mobile Phone No."));
                    end;
                }
                field(email; Rec."E-Mail")
                {
                    Caption = 'Email', Locked = true;

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo("E-Mail"));
                    end;
                }
                field(website; Rec."Home Page")
                {
                    Caption = 'Website', Locked = true;

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo("Home Page"));
                    end;
                }

                field(contact; Rec.Contact)
                {
                    Caption = 'Contact', Locked = true;
                }

                field(telexNo; Rec."Telex No.")
                {
                    Caption = 'Telex No.', Locked = true;
                }

                field(shipToCode; Rec."Ship-to Code")
                {
                    Caption = 'Ship-to Code', Locked = true;
                }

                field(ourAccountNo; Rec."Our Account No.")
                {
                    Caption = 'Our Account No.', Locked = true;
                }

                field(territoryCode; Rec."Territory Code")
                {
                    Caption = 'Territory Code', Locked = true;
                }

                field(chainName; Rec."Chain Name")
                {
                    Caption = 'Chain Name', Locked = true;
                }

                field(budgetedAmount; Rec."Budgeted Amount")
                {
                    Caption = 'Budgeted Amount', Locked = true;
                }

                field(statisticsGroup; Rec."Statistics Group")
                {
                    Caption = 'Statistics Group', Locked = true;
                }

                field(shippingAgentCode; Rec."Shipping Agent Code")
                {
                    Caption = 'Shipping Agent Code', Locked = true;
                }

                field(placeOfExport; Rec."Place of Export")
                {
                    Caption = 'Place of Export', Locked = true;
                }

                field(collectionMethod; Rec."Collection Method")
                {
                    Caption = 'Collection Method', Locked = true;
                }
                field(amount; Rec.Amount)
                {
                    Caption = 'Amount', Locked = true;
                }

                field(lastStatementNo; Rec."Last Statement No.")
                {
                    Caption = 'Last Statement No.', Locked = true;
                }

                field(printStatements; Rec."Print Statements")
                {
                    Caption = 'Print Statements', Locked = true;
                }

                field(priority; Rec.Priority)
                {
                    Caption = 'Priority', Locked = true;
                }

                field(lastDateModified; Rec."Last Date Modified")
                {
                    Caption = 'Last Date Modified', Locked = true;
                }

                field(pricesIncludingVat; Rec."Prices Including VAT")
                {
                    Caption = 'Prices Including VAT', Locked = true;
                }
                field(taxLiable; Rec."Tax Liable")
                {
                    Caption = 'Tax Liable', Locked = true;

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo("Tax Liable"));
                    end;
                }
                field(taxAreaId; Rec."Tax Area ID")
                {
                    Caption = 'Tax Area Id', Locked = true;

                    trigger OnValidate()
                    var
                        GeneralLedgerSetup: Record "General Ledger Setup";
                    begin
                        RegisterFieldSet(Rec.FieldNo("Tax Area ID"));

                        if not GeneralLedgerSetup.UseVat() then
                            RegisterFieldSet(Rec.FieldNo("Tax Area Code"))
                        else
                            RegisterFieldSet(Rec.FieldNo("VAT Bus. Posting Group"));
                    end;
                }

                field(taxAreaCode; Rec."Tax Area Code")
                {
                    Caption = 'Tax Area Code', Locked = true;
                }
                field(taxAreaDisplayName; TaxAreaDisplayNameGlobal)
                {
                    Caption = 'Tax Area Display Name', Locked = true;
                    Editable = false;
                }
                field(taxRegistrationNumber; Rec."VAT Registration No.")
                {
                    Caption = 'Tax Registration No.', Locked = true;

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo("VAT Registration No."));
                    end;
                }
                field(currencyId; Rec."Currency Id")
                {
                    Caption = 'Currency Id', Locked = true;

                    trigger OnValidate()
                    begin
                        if Rec."Currency Id" = BlankGUID then
                            Rec."Currency Code" := ''
                        else begin
                            if not Currency.GetBySystemId(Rec."Currency Id") then
                                Error(CurrencyIdDoesNotMatchACurrencyErr);

                            Rec."Currency Code" := Currency.Code;
                        end;

                        RegisterFieldSet(Rec.FieldNo("Currency Id"));
                        RegisterFieldSet(Rec.FieldNo("Currency Code"));
                    end;
                }
                field(currencyCode; CurrencyCodeTxt)
                {
                    Caption = 'Currency Code', Locked = true;

                    trigger OnValidate()
                    begin
                        Rec."Currency Code" :=
                          GraphMgtGeneralTools.TranslateCurrencyCodeToNAVCurrencyCode(
                            LCYCurrencyCode, COPYSTR(CurrencyCodeTxt, 1, MAXSTRLEN(LCYCurrencyCode)));

                        if Currency.Code <> '' then begin
                            if Currency.Code <> Rec."Currency Code" then
                                Error(CurrencyValuesDontMatchErr);
                            exit;
                        end;

                        if Rec."Currency Code" = '' then
                            Rec."Currency Id" := BlankGUID
                        else begin
                            if not Currency.Get(Rec."Currency Code") then
                                Error(CurrencyCodeDoesNotMatchACurrencyErr);

                            Rec."Currency Id" := Currency.SystemId;
                        end;

                        RegisterFieldSet(Rec.FieldNo("Currency Id"));
                        RegisterFieldSet(Rec.FieldNo("Currency Code"));
                    end;
                }
                field(paymentTermsId; Rec."Payment Terms Id")
                {
                    Caption = 'Payment Terms Id', Locked = true;

                    trigger OnValidate()
                    begin
                        if Rec."Payment Terms Id" = BlankGUID then
                            Rec."Payment Terms Code" := ''
                        else begin
                            if not PaymentTerms.GetBySystemId(Rec."Payment Terms Id") then
                                Error(PaymentTermsIdDoesNotMatchAPaymentTermsErr);

                            Rec."Payment Terms Code" := PaymentTerms.Code;
                        end;

                        RegisterFieldSet(Rec.FieldNo("Payment Terms Id"));
                        RegisterFieldSet(Rec.FieldNo("Payment Terms Code"));
                    end;
                }

                field(paymentTermsCode; Rec."Payment Terms Code")
                {
                    Caption = 'Payment Terms Code', Locked = true;
                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo("Payment Terms Id"));
                        RegisterFieldSet(Rec.FieldNo("Payment Terms Code"));
                    end;
                }
                field(shipmentMethodId; Rec."Shipment Method Id")
                {
                    Caption = 'Shipment Method Id', Locked = true;

                    trigger OnValidate()
                    begin
                        if Rec."Shipment Method Id" = BlankGUID then
                            Rec."Shipment Method Code" := ''
                        else begin
                            if not ShipmentMethod.GetBySystemId(Rec."Shipment Method Id") then
                                Error(ShipmentMethodIdDoesNotMatchAShipmentMethodErr);

                            Rec."Shipment Method Code" := ShipmentMethod.Code;
                        end;

                        RegisterFieldSet(Rec.FieldNo("Shipment Method Id"));
                        RegisterFieldSet(Rec.FieldNo("Shipment Method Code"));
                    end;
                }

                field(shipmentMethodCode; Rec."Shipment Method Code")
                {
                    Caption = 'Shipment Method Code', Locked = true;
                }
                field(paymentMethodId; Rec."Payment Method Id")
                {
                    Caption = 'Payment Method Id', Locked = true;

                    trigger OnValidate()
                    begin
                        if Rec."Payment Method Id" = BlankGUID then
                            Rec."Payment Method Code" := ''
                        else begin
                            if not PaymentMethod.GetBySystemId(Rec."Payment Method Id") then
                                Error(PaymentMethodIdDoesNotMatchAPaymentMethodErr);

                            Rec."Payment Method Code" := PaymentMethod.Code;
                        end;

                        RegisterFieldSet(Rec.FieldNo("Payment Method Id"));
                        RegisterFieldSet(Rec.FieldNo("Payment Method Code"));
                    end;
                }

                field(paymentMethodCode; Rec."Payment Method Code")
                {
                    Caption = 'Payment Method Code', Locked = true;
                }

                field(priceCalculationMethod; Rec."Price Calculation Method")
                {
                    Caption = 'Price Calculation Method', Locked = true;
                }

                field(baseCalendarCode; Rec."Base Calendar Code")
                {
                    Caption = 'Base Calendar Code', Locked = true;
                }
                field(validateEUVatRegNo; Rec."Validate EU Vat Reg. No.")
                {
                    Caption = 'Validate EU Vat Reg. No.', Locked = true;
                }

                field(blocked; Rec.Blocked)
                {
                    Caption = 'Blocked', Locked = true;

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo(Blocked));
                    end;
                }

                field(responsibilityCenter; Rec."Responsibility Center")
                {
                    Caption = 'Responsibility Center', Locked = true;
                }

                field(privacyBlocked; Rec."Privacy Blocked")
                {
                    Caption = 'Privacy Blocked', Locked = true;
                }

                field(documentSendingProfile; Rec."Document Sending Profile")
                {
                    Caption = 'Document Sending Profile', Locked = true;
                }
                field(icPartnerCode; Rec."IC Partner Code")
                {
                    Caption = 'IC Partner Code', Locked = true;
                }

                field(salespersonCode; Rec."Salesperson Code")
                {
                    Caption = 'Salesperson Code', Locked = true;
                }
                field(locationCode; Rec."Location Code")
                {
                    Caption = 'Location Code', Locked = true;
                }
                field(vatRegistrationNo; Rec."VAT Registration No.")
                {
                    Caption = 'VAT Registration No.', Locked = true;
                }

                field(invoiceCopies; Rec."Invoice Copies")
                {
                    Caption = 'Invoice Copies', Locked = true;
                }

                field(globalDimension1Code; Rec."Global Dimension 1 Code")
                {
                    Caption = 'Global Dimension 1 Code', Locked = true;
                }

                field(globalDimension2Code; Rec."Global Dimension 2 Code")
                {
                    Caption = 'Global Dimension 2 Code', Locked = true;
                }

                field(genBusPostingGroup; Rec."Gen. Bus. Posting Group")
                {
                    Caption = 'Gen. Bus. Posting Group', Locked = true;
                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo("Gen. Bus. Posting Group"));
                    end;
                }

                field(customerPostingGroup; Rec."Customer Posting Group")
                {
                    Caption = 'Customer Posting Group', Locked = true;
                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo("Customer Posting Group"));
                    end;
                }

                field(vatBusPostingGroup; Rec."VAT Bus. Posting Group")
                {
                    Caption = 'VAT Bus. Posting Group', Locked = true;
                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo("VAT Bus. Posting Group"));
                    end;
                }

                field(customerPriceGroup; Rec."Customer Price Group")
                {
                    Caption = 'Customer Price Group', Locked = true;
                }

                field(invoiceDiscCode; Rec."Invoice Disc. Code")
                {
                    Caption = 'Invoice Disc. Code', Locked = true;
                }

                field(customerDiscGroup; Rec."Customer Disc. Group")
                {
                    Caption = 'Customer Disc. Group', Locked = true;
                }
                field(allowLineDisc; Rec."Allow Line Disc.")
                {
                    Caption = 'Allow Line Disc.', Locked = true;
                }

                field(languageCode; Rec."Language Code")
                {
                    Caption = 'Language Code', Locked = true;
                }

                field(combineShipments; Rec."Combine Shipments")
                {
                    Caption = 'Combine Shipments', Locked = true;
                }

                field(gln; Rec.GLN)
                {
                    Caption = 'GLN', Locked = true;
                }

                field(creditLimitLCY; Rec."Credit Limit (LCY)")
                {
                    Caption = 'Credit Limit (LCY)', Locked = true;
                }

                field(prepaymentPct; Rec."Prepayment %")
                {
                    Caption = 'Prepayment %', Locked = true;
                }

                field(applicationMethod; Rec."Application Method")
                {
                    Caption = 'Application Method', Locked = true;
                }

                field(partnerType; Rec."Partner Type")
                {
                    Caption = 'Partner Type', Locked = true;
                }

                field(reminderTermsCode; Rec."Reminder Terms Code")
                {
                    Caption = 'Reminder Terms Code', Locked = true;
                }

                field(finChargeTermsCode; Rec."Fin. Charge Terms Code")
                {
                    Caption = 'Finance Charge Terms Code', Locked = true;
                }

                field(blockPaymentTolerance; Rec."Block Payment Tolerance")
                {
                    Caption = 'Block Payment Tolerance', Locked = true;
                }

                field(billToCustomerNo; Rec."Bill-to Customer No.")
                {
                    Caption = 'Bill-to Customer No.', Locked = true;
                }

                field(faxNo; Rec."Fax No.")
                {
                    Caption = 'Fax No.', Locked = true;
                }

                field(telexAnswerBack; Rec."Telex Answer Back")
                {
                    Caption = 'Telex Answer Back', Locked = true;
                }

                field(useGlnInElectronicDocument; Rec."Use GLN in Electronic Document")
                {
                    Caption = 'Use GLN in Electronic Document', Locked = true;
                }

                field(noSeries; Rec."No. Series")
                {
                    Caption = 'No. Series', Locked = true;
                }

                field(reserve; Rec.Reserve)
                {
                    Caption = 'Reserve', Locked = true;
                }

                field(disableSearchByName; Rec."Disable Search by Name")
                {
                    Caption = 'Disable Search by Name', Locked = true;
                }

                field(preferredBankAccountCode; Rec."Preferred Bank Account Code")
                {
                    Caption = 'Preferred Bank Account Code', Locked = true;
                }

                field(cashFlowPaymentTermsCode; Rec."Cash Flow Payment Terms Code")
                {
                    Caption = 'Cash Flow Payment Terms Code', Locked = true;
                }

                field(primaryContactNo; Rec."Primary Contact No.")
                {
                    Caption = 'Primary Contact No.', Locked = true;
                }

                field(shippingAdvice; Rec."Shipping Advice")
                {
                    Caption = 'Shipping Advice', Locked = true;
                }

                field(shippingTime; Rec."Shipping Time")
                {
                    Caption = 'Shipping Time', Locked = true;
                }

                field(shippingAgentServiceCode; Rec."Shipping Agent Service Code")
                {
                    Caption = 'Shipping Agent Service Code', Locked = true;
                }

                field(serviceZoneCode; Rec."Service Zone Code")
                {
                    Caption = 'Service Zone Code', Locked = true;
                }

                field(copySellToAddrToQteFrom; Rec."Copy Sell-to Addr. to Qte From")
                {
                    Caption = 'Copy Sell-to Addr. to Qte From', Locked = true;
                }

                field(contactId; Rec."Contact ID")
                {
                    Caption = 'Contact ID', Locked = true;
                }

                field(contactGraphId; Rec."Contact Graph Id")
                {
                    Caption = 'Contact Graph Id', Locked = true;
                }

                field(nprAnonymized; Rec."NPR Anonymized")
                {
                    Caption = 'NPR Anonymized', Locked = true;
                }

                field(nprAnonymizedDate; Rec."NPR Anonymized Date")
                {
                    Caption = 'NPR Anonymized Date', Locked = true;
                }

                field(nprExternalCustomerNo; Rec."NPR External Customer No.")
                {
                    Caption = 'NPR External Customer No.', Locked = true;
                }

                field(nprMagentoDisplayGroup; Rec."NPR Magento Display Group")
                {
                    Caption = 'NPR Magento Display Group', Locked = true;
                }

                field(nprMagentoPaymentGroup; Rec."NPR Magento Payment Group")
                {
                    Caption = 'NPR Magento Payment Group', Locked = true;
                }

                field(nprMagentoShippingGroup; Rec."NPR Magento Shipping Group")
                {
                    Caption = 'NPR Magento Shipping Group', Locked = true;
                }

                field(nprMagentoStoreCode; Rec."NPR Magento Store Code")
                {
                    Caption = 'NPR Magento Store Code', Locked = true;
                }

                field(nprToAnonymize; Rec."NPR To Anonymize")
                {
                    Caption = 'NPR To Anonymize', Locked = true;
                }

                field(nprToAnonymizeOn; Rec."NPR To Anonymize On")
                {
                    Caption = 'NPR To Anonymize On', Locked = true;
                }

                field(lastModifiedDateTime; Rec.SystemModifiedAt)
                {
                    Caption = 'Last Modified Date', Locked = true;
                }

                field(replicationCounter; Rec."NPR Replication Counter")
                {
                    Caption = 'replicationCounter', Locked = true;
                }

                part(customerFinancialDetails; "NPR APIV1 - Cust Fin Details")
                {
#IF BC17            // Multiplicity can be used only with platform version 6.3;
                    Caption = 'Multiplicity=ZeroOrOne', Locked = true;
#ELSE
                    Caption = 'Customer Financial Details', Locked = true;
                    Multiplicity = ZeroOrOne;
#ENDIF
                    EntityName = 'customerFinancialDetail';
                    EntitySetName = 'customerFinancialDetails';
                    SubPageLink = SystemId = Field(SystemId);
                }
                part(picture; "NPR APIV1 - Pictures")
                {
#IF BC17            // Multiplicity can be used only with platform version 6.3;
                    Caption = 'Multiplicity=ZeroOrOne', Locked = true;
#ELSE
                    Caption = 'Picture', Locked = true;
                    Multiplicity = ZeroOrOne;
#ENDIF
                    EntityName = 'picture';
                    EntitySetName = 'pictures';
                    SubPageLink = Id = Field(SystemId), "Parent Type" = const(Customer);
                }
                part(defaultDimensions; "NPR APIV1 - Default Dimensions")
                {
                    Caption = 'Default Dimensions', Locked = true;
                    EntityName = 'defaultDimension';
                    EntitySetName = 'defaultDimensions';
                    SubPageLink = ParentId = Field(SystemId), "Parent Type" = const(Customer);
                }
            }
        }
    }

    actions
    {
    }

    trigger OnAfterGetRecord()
    begin
        SetCalculatedFields();
    end;

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    var
        Customer: Record Customer;
        RecRef: RecordRef;
    begin
        if Rec.Name = '' then
            Error(NotProvidedCustomerNameErr);

        Customer.SetRange("No.", Rec."No.");
        if not Customer.IsEmpty() then
            Rec.Insert();

        Rec.Insert(true);

        RecRef.GetTable(Rec);
        GraphMgtGeneralTools.ProcessNewRecordFromAPI(RecRef, TempFieldSet, CurrentDateTime());
        RecRef.SetTable(Rec);

        Rec.Modify(true);
        SetCalculatedFields();
        exit(false);
    end;

    trigger OnModifyRecord(): Boolean
    var
        Customer: Record Customer;
    begin
        Customer.GetBySystemId(Rec.SystemId);

        if Rec."No." = Customer."No." then
            Rec.Modify(true)
        else begin
            Customer.TransferFields(Rec, false);
            Customer.Rename(Rec."No.");
            Rec.TransferFields(Customer);
        end;

        SetCalculatedFields();
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        ClearCalculatedFields();
    end;

    var
        Currency: Record Currency;
        PaymentTerms: Record "Payment Terms";
        ShipmentMethod: Record "Shipment Method";
        PaymentMethod: Record "Payment Method";
        TempFieldSet: Record Field temporary;
        GraphMgtGeneralTools: Codeunit "Graph Mgt - General Tools";
        LCYCurrencyCode: Code[10];
        CurrencyCodeTxt: Text;
        TaxAreaDisplayNameGlobal: Text;
        CurrencyValuesDontMatchErr: Label 'The currency values do not match to a specific Currency.';
        CurrencyIdDoesNotMatchACurrencyErr: Label 'The "currencyId" does not match to a Currency.', Comment = 'currencyId is a field name and should not be translated.';
        CurrencyCodeDoesNotMatchACurrencyErr: Label 'The "currencyCode" does not match to a Currency.', Comment = 'currencyCode is a field name and should not be translated.';
        PaymentTermsIdDoesNotMatchAPaymentTermsErr: Label 'The "paymentTermsId" does not match to a Payment Terms.', Comment = 'paymentTermsId is a field name and should not be translated.';
        ShipmentMethodIdDoesNotMatchAShipmentMethodErr: Label 'The "shipmentMethodId" does not match to a Shipment Method.', Comment = 'shipmentMethodId is a field name and should not be translated.';
        PaymentMethodIdDoesNotMatchAPaymentMethodErr: Label 'The "paymentMethodId" does not match to a Payment Method.', Comment = 'paymentMethodId is a field name and should not be translated.';
        BlankGUID: Guid;
        NotProvidedCustomerNameErr: Label 'A "displayName" must be provided.', Comment = 'displayName is a field name and should not be translated.';
        BlankCustomerNameErr: Label 'The blank "displayName" is not allowed.', Comment = 'displayName is a field name and should not be translated.';


    trigger OnInit()
    begin
        CurrentTransactionType := TransactionType::Update;
    end;

    local procedure SetCalculatedFields()
    var
        TaxAreaBuffer: Record "Tax Area Buffer";
    begin
        CurrencyCodeTxt := GraphMgtGeneralTools.TranslateNAVCurrencyCodeToCurrencyCode(LCYCurrencyCode, Rec."Currency Code");
        TaxAreaDisplayNameGlobal := TaxAreaBuffer.GetTaxAreaDisplayName(Rec."Tax Area ID");
    end;

    local procedure ClearCalculatedFields()
    begin
        Clear(Rec.SystemId);
        Clear(TaxAreaDisplayNameGlobal);
        TempFieldSet.DeleteAll();
    end;

    local procedure RegisterFieldSet(FieldNo: Integer)
    begin
        if TempFieldSet.Get(Database::Customer, FieldNo) then
            exit;

        TempFieldSet.Init();
        TempFieldSet.TableNo := Database::Customer;
        TempFieldSet.Validate("No.", FieldNo);
        TempFieldSet.Insert(true);
    end;
}

