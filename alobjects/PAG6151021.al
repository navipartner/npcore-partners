page 6151021 "NpRv Arch. Voucher Card"
{
    // NPR5.37/MHA /20171023  CASE 267346 Object created - NaviPartner Retail Voucher
    // NPR5.48/MHA /20180921  CASE 302179 Added fields 1005, 1007, 1010, 1013 and deleted field 80
    // NPR5.49/MHA /20190228  CASE 342811 Added Retail Voucher Partner fields used with Cross Company Vouchers

    Caption = 'Archived Retail Voucher Card';
    Editable = false;
    SourceTable = "NpRv Arch. Voucher";

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                group(Control6014426)
                {
                    ShowCaption = false;
                    field("No.";"No.")
                    {
                        ShowMandatory = true;
                    }
                    field("Voucher Type";"Voucher Type")
                    {
                    }
                    field(Description;Description)
                    {
                    }
                    field("Account No.";"Account No.")
                    {
                        ShowMandatory = true;
                    }
                    field("Issue Register No.";"Issue Register No.")
                    {
                    }
                    field("Issue Document Type";"Issue Document Type")
                    {
                    }
                    field("Issue Document No.";"Issue Document No.")
                    {
                    }
                    field("Issue External Document No.";"Issue External Document No.")
                    {
                    }
                    field("Issue Partner Code";"Issue Partner Code")
                    {
                    }
                    field("Partner Clearing";"Partner Clearing")
                    {
                    }
                }
                group(Control6014422)
                {
                    ShowCaption = false;
                    field("Issue Date";"Issue Date")
                    {
                    }
                    field(Amount;Amount)
                    {
                    }
                }
            }
            group("Send Voucher")
            {
                Caption = 'Send Voucher';
                group(Control6014417)
                {
                    ShowCaption = false;
                    field("Send Voucher Module";"Send Voucher Module")
                    {
                    }
                }
                group(Control6014415)
                {
                    ShowCaption = false;
                    field("Reference No.";"Reference No.")
                    {
                    }
                    field("Print Template Code";"Print Template Code")
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
                    field("E-mail";"E-mail")
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
            group("Validate Voucher")
            {
                Caption = 'Validate Voucher';
                group(Control6014405)
                {
                    ShowCaption = false;
                    field("Validate Voucher Module";"Validate Voucher Module")
                    {
                    }
                }
                group(Control6014409)
                {
                    ShowCaption = false;
                    field("Starting Date";"Starting Date")
                    {
                    }
                    field("Ending Date";"Ending Date")
                    {
                    }
                }
            }
            group("Apply Payment")
            {
                Caption = 'Apply Payment';
                field("Apply Payment Module";"Apply Payment Module")
                {
                }
            }
        }
    }

    actions
    {
        area(navigation)
        {
            action("Arch. Voucher Entries")
            {
                Caption = 'Archived Voucher Entries';
                Image = Entries;
                RunObject = Page "NpRv Arch. Voucher Entries";
                RunPageLink = "Arch. Voucher No."=FIELD("No.");
                ShortCutKey = 'Ctrl+F7';
            }
        }
    }

    var
        Text000: Label 'Are you sure you want to delete Vouchers In-use?';
        Text001: Label 'Manual Post Voucher?';
}

