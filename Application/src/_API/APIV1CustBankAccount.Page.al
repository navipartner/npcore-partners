page 6014691 "NPR APIV1 - Cust. Bank Account"
{

    APIGroup = 'core';
    APIPublisher = 'navipartner';
    APIVersion = 'v1.0';
    Caption = 'Customer Bank Account';
    DelayedInsert = true;
    EntityName = 'customerBankAccount';
    EntitySetName = 'customerBankAccounts';
    Extensible = false;
    ODataKeyFields = SystemId;
    PageType = API;
    SourceTable = "Customer Bank Account";

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field(id; Rec.SystemId)
                {
                    Caption = 'SystemId', Locked = true;
                }
                field("code"; Rec."Code")
                {
                    Caption = 'Code', Locked = true;
                }
                field(customerNo; Rec."Customer No.")
                {
                    Caption = 'Customer No.', Locked = true;
                }
                field(languageCode; Rec."Language Code")
                {
                    Caption = 'Language Code', Locked = true;
                }

                field(name; Rec.Name)
                {
                    Caption = 'Name', Locked = true;
                }
                field(name2; Rec."Name 2")
                {
                    Caption = 'Name 2', Locked = true;
                }
                field(phoneNo; Rec."Phone No.")
                {
                    Caption = 'Phone No.', Locked = true;
                }
                field(contact; Rec.Contact)
                {
                    Caption = 'Contact', Locked = true;
                }
                field(address; Rec.Address)
                {
                    Caption = 'Address', Locked = true;
                }
                field(address2; Rec."Address 2")
                {
                    Caption = 'Address 2', Locked = true;
                }
                field(postCode; Rec."Post Code")
                {
                    Caption = 'Post Code', Locked = true;
                }
                field(city; Rec.City)
                {
                    Caption = 'City', Locked = true;
                }
                field(county; Rec.County)
                {
                    Caption = 'County', Locked = true;
                }
                field(countryRegionCode; Rec."Country/Region Code")
                {
                    Caption = 'Country/Region Code', Locked = true;
                }
                field(currencyCode; Rec."Currency Code")
                {
                    Caption = 'Currency Code', Locked = true;
                }
                field(bankBranchNo; Rec."Bank Branch No.")
                {
                    Caption = 'Bank Branch No.', Locked = true;
                }
                field(bankAccountNo; Rec."Bank Account No.")
                {
                    Caption = 'Bank Account No.', Locked = true;
                }
                field(transitNo; Rec."Transit No.")
                {
                    Caption = 'Transit No.', Locked = true;
                }
                field(eMail; Rec."E-Mail")
                {
                    Caption = 'Email', Locked = true;
                }
                field(homePage; Rec."Home Page")
                {
                    Caption = 'Home Page', Locked = true;
                }
                field(swiftCode; Rec."SWIFT Code")
                {
                    Caption = 'SWIFT Code', Locked = true;
                }
                field(faxNo; Rec."Fax No.")
                {
                    Caption = 'Fax No.', Locked = true;
                }
                field(iban; Rec.IBAN)
                {
                    Caption = 'IBAN', Locked = true;
                }
                field(bankClearingCode; Rec."Bank Clearing Code")
                {
                    Caption = 'Bank Clearing Code', Locked = true;
                }
                field(bankClearingStandard; Rec."Bank Clearing Standard")
                {
                    Caption = 'Bank Clearing Standard', Locked = true;
                }
                field(telexNo; Rec."Telex No.")
                {
                    Caption = 'Telex No.', Locked = true;
                }
                field(telexAnswerBack; Rec."Telex Answer Back")
                {
                    Caption = 'Telex Answer Back', Locked = true;
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
