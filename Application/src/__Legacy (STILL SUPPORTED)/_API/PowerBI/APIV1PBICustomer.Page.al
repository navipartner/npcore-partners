page 6059914 "NPR APIV1 PBICustomer"
{
    APIGroup = 'powerBI';
    APIPublisher = 'navipartner';
    APIVersion = 'v1.0';
    PageType = API;
    EntityName = 'customer';
    EntitySetName = 'customers';
    Caption = 'PowerBI Customer';
    DataAccessIntent = ReadOnly;
    ODataKeyFields = SystemId;
    DelayedInsert = true;
    SourceTable = Customer;
    Extensible = false;
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field(id; Rec.SystemId)
                {
                    Caption = 'SystemId', Locked = true;
                }
                field(no; Rec."No.")
                {
                    Caption = 'No.', Locked = true;
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
                field(city; Rec.City)
                {
                    Caption = 'City', Locked = true;
                }
                field(email; Rec."E-Mail")
                {
                    Caption = 'E-Mail', Locked = true;
                }
                field(phoneNo; Rec."Phone No.")
                {
                    Caption = 'Phone No.', Locked = true;
                }
                field(countryRegionCode; Rec."Country/Region Code")
                {
                    Caption = 'Country/Region Code', Locked = true;
                }
                field(postCode; Rec."Post Code")
                {
                    Caption = 'Post Code', Locked = true;
                }
                field(paymentTermsCode; Rec."Payment Terms Code")
                {
                    Caption = 'Payment Terms Code', Locked = true;
                }
                field(invoiceDiscCode; Rec."Invoice Disc. Code")
                {
                    Caption = 'Invoice Disc. Code', Locked = true;
                }
                field(customerPostingGroup; Rec."Customer Posting Group")
                {
                    Caption = 'Customer Posting Group', Locked = true;
                }
                field(lastModifiedDateTime; Rec.SystemModifiedAt)
                {
                    Caption = 'Last Modified Date Time', Locked = true;
                }
#if not (BC17 or BC18 or BC19 or BC20)
                field(systemRowVersion; Rec.SystemRowVersion)
                {
                    Caption = 'System Row Version', Locked = true;
                }
#endif
            }
        }
    }
}