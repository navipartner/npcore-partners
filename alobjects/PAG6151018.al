page 6151018 "NpRv POS Issue Voucher Card"
{
    // NPR5.37/MHA /20171023  CASE 267346 Object created - NaviPartner Retail Voucher
    // NPR5.48/MHA /20190123  CASE 341711 Added Send Method fields

    Caption = 'Issue Retail Voucher Card';
    DataCaptionExpression = Description;
    DeleteAllowed = false;
    InsertAllowed = false;
    SourceTable = "NpRv Sale Line POS Voucher";

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field("Voucher Type";"Voucher Type")
                {
                    Editable = false;
                    Enabled = false;
                }
                field(Description;Description)
                {
                    Editable = false;
                    Enabled = false;
                }
                field("Starting Date";"Starting Date")
                {
                }
            }
            group(Contact)
            {
                Caption = 'Contact';
                field("Customer No.";"Customer No.")
                {
                }
                field("Contact No.";"Contact No.")
                {

                    trigger OnLookup(var Text: Text): Boolean
                    var
                        Contact: Record Contact;
                    begin
                        if PAGE.RunModal(PAGE::"Touch Screen - CRM Contacts",Contact) <> ACTION::LookupOK then
                          exit;

                        Validate("Contact No.",Contact."No.");
                    end;
                }
                field(Name;Name)
                {
                }
                field("Name 2";"Name 2")
                {
                }
                field(Address;Address)
                {
                }
                field("Address 2";"Address 2")
                {
                }
                field("Post Code";"Post Code")
                {
                }
                field(City;City)
                {
                }
                field(County;County)
                {
                }
                field("Country/Region Code";"Country/Region Code")
                {
                }
                field("Send via Print";"Send via Print")
                {
                }
                field("Send via E-mail";"Send via E-mail")
                {
                }
                field("E-mail";"E-mail")
                {
                }
                field("Send via SMS";"Send via SMS")
                {
                }
                field("Phone No.";"Phone No.")
                {
                }
                field("Voucher Message";"Voucher Message")
                {
                    MultiLine = true;
                }
            }
        }
    }

    actions
    {
    }
}

