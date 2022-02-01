page 6014410 "NPR APIV1 - Vendors"
{
    APIGroup = 'core';
    APIPublisher = 'navipartner';
    APIVersion = 'v1.0';
    DelayedInsert = true;
    EntityCaption = 'Vendor';
    EntitySetCaption = 'Vendors';
    EntityName = 'vendor';
    EntitySetName = 'vendors';
    Extensible = false;
    ODataKeyFields = SystemId;
    PageType = API;
    SourceTable = Vendor;

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

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo(Name));
                    end;
                }
                field(displayName2; Rec."Name 2")
                {
                    Caption = 'Display Name 2', Locked = true;
                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo("Name 2"));
                    end;
                }
                field(searchName; Rec."Search Name")
                {
                    Caption = 'Search Name', Locked = true;
                }
                field(contact; Rec.Contact)
                {
                    Caption = 'Contact', Locked = true;
                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo(Contact));
                    end;
                }
                field(telexNo; Rec."Telex No.")
                {
                    Caption = 'Telex No.', Locked = true;
                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo("Telex No."));
                    end;
                }
                field(ourAccountNo; Rec."Our Account No.")
                {
                    Caption = 'Our Account No.', Locked = true;
                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo("Our Account No."));
                    end;
                }

                field(budgetedAmount; Rec."Budgeted Amount")
                {
                    Caption = 'Budgeted Amount', Locked = true;
                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo("Budgeted Amount"));
                    end;
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

                field(faxNo; Rec."Fax No.")
                {
                    Caption = 'Fax No.', Locked = true;
                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo("Fax No."));
                    end;
                }
                field(telexAnswerBack; Rec."Telex Answer Back")
                {
                    Caption = 'Telex Answer Back', Locked = true;
                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo("Telex Answer Back"));
                    end;
                }

                field(noSeries; Rec."No. Series")
                {
                    Caption = 'No. Series', Locked = true;
                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo("No. Series"));
                    end;
                }

                field(disableSearchByName; Rec."Disable Search by Name")
                {
                    Caption = 'Disable Search by Name', Locked = true;
                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo("Disable Search by Name"));
                    end;
                }
                field(taxAreaCode; Rec."Tax Area Code")
                {
                    Caption = 'Tax Area Code', Locked = true;
                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo("Tax Area Code"));
                    end;
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
                field(taxLiable; Rec."Tax Liable")
                {
                    Caption = 'Tax Liable', Locked = true;

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo("Tax Liable"));
                    end;
                }
                field(territoryCode; Rec."Territory Code")
                {
                    Caption = 'Territory Code', Locked = true;
                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo("Territory Code"));
                    end;
                }
                field(purchaserCode; Rec."Purchaser Code")
                {
                    Caption = 'Purchaser Code', Locked = true;
                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo("Purchaser Code"));
                    end;
                }
                field(locationCode; Rec."Location Code")
                {
                    Caption = 'Location Code', Locked = true;
                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo("Location Code"));
                    end;
                }
                field(shipmentMethodCode; Rec."Shipment Method Code")
                {
                    Caption = 'Shipment Method Code', Locked = true;
                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo("Shipment Method Code"));
                    end;
                }
                field(shippingAgentCode; Rec."Shipping Agent Code")
                {
                    Caption = 'Shipping Agent Code', Locked = true;
                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo("Shipping Agent Code"));
                    end;
                }

                field(invoiceDiscCode; Rec."Invoice Disc. Code")
                {
                    Caption = 'Invoice Disc. Code', Locked = true;
                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo("Invoice Disc. Code"));
                    end;
                }

                field(payToVendorNo; Rec."Pay-to Vendor No.")
                {
                    Caption = 'Pay-to Vendor No.', Locked = true;
                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo("Pay-to Vendor No."));
                    end;
                }
                field(applicationMethod; Rec."Application Method")
                {
                    Caption = 'Application Method', Locked = true;
                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo("Application Method"));
                    end;
                }

                field(partnerType; Rec."Partner Type")
                {
                    Caption = 'Partner Type', Locked = true;

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo("Partner Type"));
                    end;
                }
                field(pricesIncludingVat; Rec."Prices Including VAT")
                {
                    Caption = 'Prices Including VAT', Locked = true;
                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo("Prices Including VAT"));
                    end;
                }
                field(gln; Rec.GLN)
                {
                    Caption = 'GLN', Locked = true;
                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo(GLN));
                    end;
                }
                field(blockPaymentTolerance; Rec."Block Payment Tolerance")
                {
                    Caption = 'Block Payment Tolerance', Locked = true;
                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo("Block Payment Tolerance"));
                    end;
                }
                field(responsibilityCenter; Rec."Responsibility Center")
                {
                    Caption = 'Responsibility Center', Locked = true;
                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo("Responsibility Center"));
                    end;
                }
                field(privacyBlocked; Rec."Privacy Blocked")
                {
                    Caption = 'Privacy Blocked', Locked = true;
                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo("Privacy Blocked"));
                    end;
                }
                field(documentSendingProfile; Rec."Document Sending Profile")
                {
                    Caption = 'Document Sending Profile', Locked = true;
                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo("Document Sending Profile"));
                    end;
                }
                field(icPartnerCode; Rec."IC Partner Code")
                {
                    Caption = 'IC Partner Code', Locked = true;
                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo("IC Partner Code"));
                    end;
                }
                field(prepaymentPct; Rec."Prepayment %")
                {
                    Caption = 'Prepayment %', Locked = true;
                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo("Prepayment %"));
                    end;
                }
                field(creditorNo; Rec."Creditor No.")
                {
                    Caption = 'Creditor No.', Locked = true;
                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo("Creditor No."));
                    end;
                }
                field(preferredBankAccountCode; Rec."Preferred Bank Account Code")
                {
                    Caption = 'Preferred Bank Account Code', Locked = true;
                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo("Preferred Bank Account Code"));
                    end;
                }
                field(cashFlowPaymentTermsCode; Rec."Cash Flow Payment Terms Code")
                {
                    Caption = 'Cash Flow Payment Terms Code', Locked = true;
                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo("Cash Flow Payment Terms Code"));
                    end;
                }
                field(primaryContactNo; Rec."Primary Contact No.")
                {
                    Caption = 'Primary Contact No.', Locked = true;
                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo("Primary Contact No."));
                    end;
                }
                field(mobilePhoneNo; Rec."Mobile Phone No.")
                {
                    Caption = 'Mobile Phone No.', Locked = true;
                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo("Mobile Phone No."));
                    end;
                }

                field(leadTimeCalculation; Rec."Lead Time Calculation")
                {
                    Caption = 'Lead Time Calculation', Locked = true;
                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo("Lead Time Calculation"));
                    end;
                }

                field(priceCalculationMethod; Rec."Price Calculation Method")
                {
                    Caption = 'Price Calculation Method', Locked = true;
                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo("Price Calculation Method"));
                    end;
                }

                field(baseCalendarCode; Rec."Base Calendar Code")
                {
                    Caption = 'Base Calendar Code', Locked = true;
                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo("Base Calendar Code"));
                    end;
                }
                field(validateEUVatRegNo; Rec."Validate EU Vat Reg. No.")
                {
                    Caption = 'Validate EU Vat Reg. No.', Locked = true;
                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo("Validate EU Vat Reg. No."));
                    end;
                }

                field(overReceiptCode; Rec."Over-Receipt Code")
                {
                    Caption = 'Over-Receipt Code', Locked = true;
                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo("Over-Receipt Code"));
                    end;
                }

                field(blocked; Rec.Blocked)
                {
                    Caption = 'Blocked', Locked = true;

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo(Blocked));
                    end;
                }
                field(balance; Rec."Balance (LCY)")
                {
                    Caption = 'Balance', Locked = true;
                }

                field(languageCode; Rec."Language Code")
                {
                    Caption = 'Language Code', Locked = true;
                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo("Language Code"));
                    end;
                }

                field(globalDimension1Code; Rec."Global Dimension 1 Code")
                {
                    Caption = 'Global Dimension 1 Code', Locked = true;
                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo("Global Dimension 1 Code"));
                    end;
                }

                field(globalDimension2Code; Rec."Global Dimension 2 Code")
                {
                    Caption = 'Global Dimension 2 Code', Locked = true;
                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo("Global Dimension 2 Code"));
                    end;
                }

                field(genBusPostingGroup; Rec."Gen. Bus. Posting Group")
                {
                    Caption = 'Gen. Bus. Posting Group', Locked = true;
                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo("Gen. Bus. Posting Group"));
                    end;
                }

                field(vendorPostingGroup; Rec."Vendor Posting Group")
                {
                    Caption = 'Vendor Posting Group', Locked = true;
                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo("Vendor Posting Group"));
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

                field(finChargeTermsCode; Rec."Fin. Charge Terms Code")
                {
                    Caption = 'Fin. Charge Terms Code', Locked = true;
                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo("Fin. Charge Terms Code"));
                    end;
                }

                field(statisticsGroup; Rec."Statistics Group")
                {
                    Caption = 'Statistics Group', Locked = true;
                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo("Statistics Group"));
                    end;
                }
                field(priority; Rec.Priority)
                {
                    Caption = 'Priority', Locked = true;
                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo("Priority"));
                    end;
                }

                field(lastDateModified; Rec."Last Date Modified")
                {
                    Caption = 'Last Date Modified', Locked = true;
                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo("Last Date Modified"));
                    end;
                }

                field(lastModifiedDateTime; Rec.SystemModifiedAt)
                {
                    Caption = 'Last Modified Date', Locked = true;
                }

                field(replicationCounter; Rec."NPR Replication Counter")
                {
                    Caption = 'replicationCounter', Locked = true;
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
                    SubPageLink = Id = Field(SystemId), "Parent Type" = const(Vendor);
                }
                part(defaultDimensions; "NPR APIV1 - Default Dimensions")
                {
                    Caption = 'Default Dimensions', Locked = true;
                    EntityName = 'defaultDimension';
                    EntitySetName = 'defaultDimensions';
                    SubPageLink = ParentId = Field(SystemId), "Parent Type" = const(Vendor);
                }
            }
        }
    }

    actions
    {
    }

    trigger OnInit()
    begin
        CurrentTransactionType := TransactionType::Update;
    end;

    trigger OnAfterGetRecord()
    begin
        SetCalculatedFields();
    end;

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    var
        Vendor: Record Vendor;
        RecRef: RecordRef;
    begin
        Vendor.SetRange("No.", Rec."No.");
        if not Vendor.IsEmpty() then
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
        Vendor: Record Vendor;
    begin
        Vendor.GetBySystemId(Rec.SystemId);

        if Rec."No." = Vendor."No." then
            Rec.Modify(true)
        else begin
            Vendor.TransferFields(Rec, false);
            Vendor.Rename(Rec."No.");
            Rec.TransferFields(Vendor);
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
        PaymentMethod: Record "Payment Method";
        TempFieldSet: Record Field temporary;
        GraphMgtGeneralTools: Codeunit "Graph Mgt - General Tools";
        LCYCurrencyCode: Code[10];
        CurrencyCodeTxt: Text;
        CurrencyValuesDontMatchErr: Label 'The currency values do not match to a specific Currency.';
        CurrencyIdDoesNotMatchACurrencyErr: Label 'The "currencyId" does not match to a Currency.', Comment = 'currencyId is a field name and should not be translated.';
        CurrencyCodeDoesNotMatchACurrencyErr: Label 'The "currencyCode" does not match to a Currency.', Comment = 'currencyCode is a field name and should not be translated.';
        PaymentTermsIdDoesNotMatchAPaymentTermsErr: Label 'The "paymentTermsId" does not match to a Payment Terms.', Comment = 'paymentTermsId is a field name and should not be translated.';
        PaymentMethodIdDoesNotMatchAPaymentMethodErr: Label 'The "paymentMethodId" does not match to a Payment Method.', Comment = 'paymentMethodId is a field name and should not be translated.';
        BlankGUID: Guid;

    local procedure SetCalculatedFields()
    begin
        CurrencyCodeTxt := GraphMgtGeneralTools.TranslateNAVCurrencyCodeToCurrencyCode(LCYCurrencyCode, Rec."Currency Code");
    end;

    local procedure ClearCalculatedFields()
    begin
        Clear(Rec.SystemId);
        TempFieldSet.DeleteAll();
    end;

    local procedure RegisterFieldSet(FieldNo: Integer)
    begin
        if TempFieldSet.Get(Database::Vendor, FieldNo) then
            exit;

        TempFieldSet.Init();
        TempFieldSet.TableNo := Database::Vendor;
        TempFieldSet.Validate("No.", FieldNo);
        TempFieldSet.Insert(true);
    end;
}
