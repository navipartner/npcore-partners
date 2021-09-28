page 6014692 "NPR APIV1 - Vend. Bank Account"
{

    APIGroup = 'core';
    APIPublisher = 'navipartner';
    APIVersion = 'v1.0';
    Caption = 'Vendor Bank Account';
    DelayedInsert = true;
    EntityName = 'vendorBankAccount';
    EntitySetName = 'vendorBankAccounts';
    Extensible = false;
    ODataKeyFields = SystemId;
    PageType = API;
    SourceTable = "Vendor Bank Account";
    layout
    {
        area(content)
        {
            repeater(General)
            {
                field(id; Rec.SystemId)
                {
                    Caption = 'SystemId';
                }
                field("code"; Rec."Code")
                {
                    Caption = 'Code';
                }
                field(vendorNo; Rec."Vendor No.")
                {
                    Caption = 'Vendor No.';
                }
                field(name; Rec.Name)
                {
                    Caption = 'Name';
                }
                field(name2; Rec."Name 2")
                {
                    Caption = 'Name 2';
                }
                field(address; Rec.Address)
                {
                    Caption = 'Address';
                }
                field(address2; Rec."Address 2")
                {
                    Caption = 'Address 2';
                }
                field(postCode; Rec."Post Code")
                {
                    Caption = 'Post Code';
                }
                field(city; Rec.City)
                {
                    Caption = 'City';
                }
                field(county; Rec.County)
                {
                    Caption = 'County';
                }
                field(countryRegionCode; Rec."Country/Region Code")
                {
                    Caption = 'Country/Region Code';
                }
                field(phoneNo; Rec."Phone No.")
                {
                    Caption = 'Phone No.';
                }
                field(contact; Rec.Contact)
                {
                    Caption = 'Contact';
                }
                field(currencyCode; Rec."Currency Code")
                {
                    Caption = 'Currency Code';
                }
                field(bankAccountNo; Rec."Bank Account No.")
                {
                    Caption = 'Bank Account No.';
                }
                field(bankBranchNo; Rec."Bank Branch No.")
                {
                    Caption = 'Bank Branch No.';
                }
                field(transitNo; Rec."Transit No.")
                {
                    Caption = 'Transit No.';
                }
                field(eMail; Rec."E-Mail")
                {
                    Caption = 'Email';
                }
                field(homePage; Rec."Home Page")
                {
                    Caption = 'Home Page';
                }
                field(faxNo; Rec."Fax No.")
                {
                    Caption = 'Fax No.';
                }
                field(languageCode; Rec."Language Code")
                {
                    Caption = 'Language Code';
                }
                field(telexAnswerBack; Rec."Telex Answer Back")
                {
                    Caption = 'Telex Answer Back';
                }
                field(telexNo; Rec."Telex No.")
                {
                    Caption = 'Telex No.';
                }
                field(iban; Rec.IBAN)
                {
                    Caption = 'IBAN';
                }
                field(swiftCode; Rec."SWIFT Code")
                {
                    Caption = 'SWIFT Code';
                }
                field(bankClearingCode; Rec."Bank Clearing Code")
                {
                    Caption = 'Bank Clearing Code';
                }
                field(bankClearingStandard; Rec."Bank Clearing Standard")
                {
                    Caption = 'Bank Clearing Standard';
                }
                field(systemModifiedAt; Rec.SystemModifiedAt)
                {
                    Caption = 'systemModifiedAt', Locked = true;
                }

                field(replicationCounter; Rec."NPR Replication Counter")
                {
                    Caption = 'replicationCounter', Locked = true;
                }

            }
        }
    }

    trigger OnInit()
    begin
        CurrentTransactionType := TransactionType::Update;
    end;

}
