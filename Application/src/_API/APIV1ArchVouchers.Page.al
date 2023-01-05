page 6150763 "NPR APIV1 - Arch. Vouchers"
{
    APIGroup = 'retailVoucher';
    APIPublisher = 'navipartner';
    APIVersion = 'v1.0';
    Caption = 'Archived Vouchers';
    DataAccessIntent = ReadOnly;
    DelayedInsert = true;
    Editable = false;
    EntityName = 'archivedVoucher';
    EntitySetName = 'archivedVouchers';
    Extensible = false;
    ODataKeyFields = SystemId;
    PageType = API;
    SourceTable = "NPR NpRv Arch. Voucher";

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
                field(number; Rec."No.")
                {
                    Caption = 'Number', Locked = true;
                }
                field(voucherType; Rec."Voucher Type")
                {
                    Caption = 'Voucher Type', Locked = true;
                }
                field(description; Rec.Description)
                {
                    Caption = 'Description', Locked = true;
                }
                field(referenceNo; Rec."Reference No.")
                {
                    Caption = 'Reference No.', Locked = true;
                }
                field(startingDate; Rec."Starting Date")
                {
                    Caption = 'Starting Date', Locked = true;
                }
                field(endingDate; Rec."Ending Date")
                {
                    Caption = 'Ending Date', Locked = true;
                }
                field(noSeries; Rec."No. Series")
                {
                    Caption = 'No Series', Locked = true;
                }
                field(archNoSeries; Rec."Arch. No. Series")
                {
                    Caption = 'Arch. No. Series', Locked = true;
                }
                field(archNo; Rec."Arch. No.")
                {
                    Caption = 'Arch. No.', Locked = true;
                }
                field(allowTopUp; Rec."Allow Top-up")
                {
                    Caption = 'Allow Top-up', Locked = true;
                }
                field(amount; Rec.Amount)
                {
                    Caption = 'Amount', Locked = true;
                }
                field(initialAmount; Rec."Initial Amount")
                {
                    Caption = 'Initial Amount', Locked = true;
                }
                field(customerNo; Rec."Customer No.")
                {
                    Caption = 'Customer No.', Locked = true;
                }
                field(contactNo; Rec."Contact No.")
                {
                    Caption = 'Contact No.', Locked = true;
                }
                field(name; Rec.Name)
                {
                    Caption = 'Name', Locked = true;
                }
                field(name2; Rec."Name 2")
                {
                    Caption = 'Name 2', Locked = true;
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
                    Caption = 'systemId', Locked = true;
                }
                field(county; Rec.County)
                {
                    Caption = 'County', Locked = true;
                }
                field(countryRegionCode; Rec."Country/Region Code")
                {
                    Caption = 'Country/Region Code', Locked = true;
                }
                field(email; Rec."E-mail")
                {
                    Caption = 'E-mail', Locked = true;
                }
                field(phoneNo; Rec."Phone No.")
                {
                    Caption = 'Phone No.', Locked = true;
                }
                field(languageCode; Rec."Language Code")
                {
                    Caption = 'Language Code', Locked = true;
                }
                field(voucherMessage; Rec."Voucher Message")
                {
                    Caption = 'Voucher Message', Locked = true;
                }
                field(systemModifiedAt; Rec.SystemModifiedAt)
                {
                    Caption = 'systemModifiedAt', Locked = true;
                }
#IF NOT (BC17 or BC18 or BC19 or BC20)
                field(systemRowVersion; Rec.SystemRowVersion)
                {
                    Caption = 'systemRowVersion', Locked = true;
                }
#ENDIF
                part(archivedVoucherEntries; "NPR APIV1 - Arch Vouch Entries")
                {
                    Caption = 'Archived Voucher Entries', Locked = true;
                    EntityName = 'archivedVoucherEntry';
                    EntitySetName = 'archivedVoucherEntries';
                    SubPageLink = "Arch. Voucher No." = field("No.");
                }
            }
        }
    }
}