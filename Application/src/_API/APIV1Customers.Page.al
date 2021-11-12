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
                    Caption = 'Id';
                    Editable = false;
                }
                field(number; Rec."No.")
                {
                    Caption = 'No.';
                }
                field(displayName; Rec.Name)
                {
                    Caption = 'Display Name';
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
                    Caption = 'Display Name 2';
                }
                field(type; Rec."Contact Type")
                {
                    Caption = 'Type';

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo("Contact Type"));
                    end;
                }
                field(addressLine1; Rec.Address)
                {
                    Caption = 'Address Line 1';

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo("Address"));
                    end;
                }
                field(addressLine2; Rec."Address 2")
                {
                    Caption = 'Address Line 2';

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo("Address 2"));
                    end;
                }
                field(city; Rec.City)
                {
                    Caption = 'City';

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo("City"));
                    end;
                }
                field(state; Rec.County)
                {
                    Caption = 'State';

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo("County"));
                    end;
                }
                field(country; Rec."Country/Region Code")
                {
                    Caption = 'Country/Region Code';

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo("Country/Region Code"));
                    end;
                }
                field(postalCode; Rec."Post Code")
                {
                    Caption = 'Post Code';

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo("Post Code"));
                    end;
                }
                field(phoneNumber; Rec."Phone No.")
                {
                    Caption = 'Phone No.';

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo("Phone No."));
                    end;
                }

                field(mobilePhoneNumber; Rec."Mobile Phone No.")
                {
                    Caption = 'Mobile Phone No.';

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo("Mobile Phone No."));
                    end;
                }
                field(email; Rec."E-Mail")
                {
                    Caption = 'Email';

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo("E-Mail"));
                    end;
                }
                field(website; Rec."Home Page")
                {
                    Caption = 'Website';

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo("Home Page"));
                    end;
                }
                field(taxLiable; Rec."Tax Liable")
                {
                    Caption = 'Tax Liable';

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo("Tax Liable"));
                    end;
                }
                field(taxAreaId; Rec."Tax Area ID")
                {
                    Caption = 'Tax Area Id';

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
                    Caption = 'Tax Area Code';
                }
                field(taxAreaDisplayName; TaxAreaDisplayNameGlobal)
                {
                    Caption = 'Tax Area Display Name';
                    Editable = false;
                }
                field(taxRegistrationNumber; Rec."VAT Registration No.")
                {
                    Caption = 'Tax Registration No.';

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo("VAT Registration No."));
                    end;
                }
                field(currencyId; Rec."Currency Id")
                {
                    Caption = 'Currency Id';

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
                    Caption = 'Currency Code';

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
                    Caption = 'Payment Terms Id';

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
                    Caption = 'Payment Terms Code';
                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo("Payment Terms Id"));
                        RegisterFieldSet(Rec.FieldNo("Payment Terms Code"));
                    end;
                }
                field(shipmentMethodId; Rec."Shipment Method Id")
                {
                    Caption = 'Shipment Method Id';

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
                    Caption = 'Shipment Method Code';
                }
                field(paymentMethodId; Rec."Payment Method Id")
                {
                    Caption = 'Payment Method Id';

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
                    Caption = 'Payment Method Code';
                }

                field(priceCalculationMethod; Rec."Price Calculation Method")
                {
                    Caption = 'Price Calculation Method';
                }

                field(baseCalendarCode; Rec."Base Calendar Code")
                {
                    Caption = 'Base Calendar Code';
                }
                field(validateEUVatRegNo; Rec."Validate EU Vat Reg. No.")
                {
                    Caption = 'Validate EU Vat Reg. No.';
                }

                field(blocked; Rec.Blocked)
                {
                    Caption = 'Blocked';

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo(Blocked));
                    end;
                }

                field(responsibilityCenter; Rec."Responsibility Center")
                {
                    Caption = 'Responsibility Center';
                }

                field(privacyBlocked; Rec."Privacy Blocked")
                {
                    Caption = 'Privacy Blocked';
                }

                field(documentSendingProfile; Rec."Document Sending Profile")
                {
                    Caption = 'Document Sending Profile';
                }
                field(icPartnerCode; Rec."IC Partner Code")
                {
                    Caption = 'IC Partner Code';
                }

                field(salespersonCode; Rec."Salesperson Code")
                {
                    Caption = 'Salesperson Code';
                }
                field(locationCode; Rec."Location Code")
                {
                    Caption = 'Location Code';
                }
                field(vatRegistrationNo; Rec."VAT Registration No.")
                {
                    Caption = 'VAT Registration No.';
                }

                field(invoiceCopies; Rec."Invoice Copies")
                {
                    Caption = 'Invoice Copies';
                }

                field(globalDimension1Code; Rec."Global Dimension 1 Code")
                {
                    Caption = 'Global Dimension 1 Code';
                }

                field(globalDimension2Code; Rec."Global Dimension 2 Code")
                {
                    Caption = 'Global Dimension 2 Code';
                }

                field(genBusPostingGroup; Rec."Gen. Bus. Posting Group")
                {
                    Caption = 'Gen. Bus. Posting Group';
                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo("Gen. Bus. Posting Group"));
                    end;
                }

                field(customerPostingGroup; Rec."Customer Posting Group")
                {
                    Caption = 'Customer Posting Group';
                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo("Customer Posting Group"));
                    end;
                }

                field(vatBusPostingGroup; Rec."VAT Bus. Posting Group")
                {
                    Caption = 'VAT Bus. Posting Group';
                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo("VAT Bus. Posting Group"));
                    end;
                }

                field(customerPriceGroup; Rec."Customer Price Group")
                {
                    Caption = 'Customer Price Group';
                }

                field(invoiceDiscCode; Rec."Invoice Disc. Code")
                {
                    Caption = 'Invoice Disc. Code';
                }

                field(pricesIncludingVAT; Rec."Prices Including VAT")
                {
                    Caption = 'Prices Including VAT';
                }

                field(customerDiscGroup; Rec."Customer Disc. Group")
                {
                    Caption = 'Customer Disc. Group';
                }
                field(allowLineDisc; Rec."Allow Line Disc.")
                {
                    Caption = 'Allow Line Disc.';
                }

                field(languageCode; Rec."Language Code")
                {
                    Caption = 'Language Code';
                }

                field(combineShipments; Rec."Combine Shipments")
                {
                    Caption = 'Combine Shipments';
                }

                field(gln; Rec.GLN)
                {
                    Caption = 'GLN';
                }

                field(creditLimitLCY; Rec."Credit Limit (LCY)")
                {
                    Caption = 'Credit Limit (LCY)';
                }

                field(prepaymentPct; Rec."Prepayment %")
                {
                    Caption = 'Prepayment %';
                }

                field(applicationMethod; Rec."Application Method")
                {
                    Caption = 'Application Method';
                }

                field(partnerType; Rec."Partner Type")
                {
                    Caption = 'Partner Type';
                }

                field(reminderTermsCode; Rec."Reminder Terms Code")
                {
                    Caption = 'Reminder Terms Code';
                }

                field(finChargeTermsCode; Rec."Fin. Charge Terms Code")
                {
                    Caption = 'Finance Charge Terms Code';
                }

                field(blockPaymentTolerance; Rec."Block Payment Tolerance")
                {
                    Caption = 'Block Payment Tolerance';
                }

                field(billToCustomerNo; Rec."Bill-to Customer No.")
                {
                    Caption = 'Bill-to Customer No.';
                }
                field(nprAnonymized; Rec."NPR Anonymized")
                {
                    Caption = 'NPR Anonymized';
                }

                field(nprAnonymizedDate; Rec."NPR Anonymized Date")
                {
                    Caption = 'NPR Anonymized Date';
                }

                field(nprExternalCustomerNo; Rec."NPR External Customer No.")
                {
                    Caption = 'NPR External Customer No.';
                }

                field(nprMagentoDisplayGroup; Rec."NPR Magento Display Group")
                {
                    Caption = 'NPR Magento Display Group';
                }

                field(nprMagentoPaymentGroup; Rec."NPR Magento Payment Group")
                {
                    Caption = 'NPR Magento Payment Group';
                }

                field(nprMagentoShippingGroup; Rec."NPR Magento Shipping Group")
                {
                    Caption = 'NPR Magento Shipping Group';
                }

                field(nprMagentoStoreCode; Rec."NPR Magento Store Code")
                {
                    Caption = 'NPR Magento Store Code';
                }

                field(nprToAnonymize; Rec."NPR To Anonymize")
                {
                    Caption = 'NPR To Anonymize';
                }

                field(nprToAnonymizeOn; Rec."NPR To Anonymize On")
                {
                    Caption = 'NPR To Anonymize On';
                }

                field(lastModifiedDateTime; Rec.SystemModifiedAt)
                {
                    Caption = 'Last Modified Date';
                }

                field(replicationCounter; Rec."NPR Replication Counter")
                {
                    Caption = 'replicationCounter', Locked = true;
                }

                part(customerFinancialDetails; "NPR APIV1 - Cust Fin Details")
                {
#IF BC17            // Multiplicity can be used only with platform version 6.3;
                    Caption = 'Multiplicity=ZeroOrOne';
#ELSE
                    Caption = 'Customer Financial Details';
                    Multiplicity = ZeroOrOne;
#ENDIF
                    EntityName = 'customerFinancialDetail';
                    EntitySetName = 'customerFinancialDetails';
                    SubPageLink = SystemId = Field(SystemId);
                }
                part(picture; "NPR APIV1 - Pictures")
                {
#IF BC17            // Multiplicity can be used only with platform version 6.3;
                    Caption = 'Multiplicity=ZeroOrOne';
#ELSE
                    Caption = 'Picture';
                    Multiplicity = ZeroOrOne;
#ENDIF
                    EntityName = 'picture';
                    EntitySetName = 'pictures';
                    SubPageLink = Id = Field(SystemId), "Parent Type" = const(Customer);
                }
                part(defaultDimensions; "NPR APIV1 - Default Dimensions")
                {
                    Caption = 'Default Dimensions';
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

