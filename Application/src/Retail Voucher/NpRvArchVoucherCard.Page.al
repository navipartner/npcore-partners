page 6151021 "NPR NpRv Arch. Voucher Card"
{
    // NPR5.37/MHA /20171023  CASE 267346 Object created - NaviPartner Retail Voucher
    // NPR5.48/MHA /20180921  CASE 302179 Added fields 1005, 1007, 1010, 1013 and deleted field 80
    // NPR5.49/MHA /20190228  CASE 342811 Added Retail Voucher Partner fields used with Cross Company Vouchers
    // NPR5.53/MHA /20191211  CASE 380284 Added field 76 "Initial Amount"
    // NPR5.55/MHA /20200701  CASE 397527 Added field 270 "Language Code"
    // NPR5.55/MHA /20200702  CASE 407070 Added Sending Log

    Caption = 'Archived Retail Voucher Card';
    Editable = false;
    SourceTable = "NPR NpRv Arch. Voucher";

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
                    field("No."; "No.")
                    {
                        ApplicationArea = All;
                        ShowMandatory = true;
                    }
                    field("Voucher Type"; "Voucher Type")
                    {
                        ApplicationArea = All;
                    }
                    field(Description; Description)
                    {
                        ApplicationArea = All;
                    }
                    field("Account No."; "Account No.")
                    {
                        ApplicationArea = All;
                        ShowMandatory = true;
                    }
                    field("Issue Register No."; "Issue Register No.")
                    {
                        ApplicationArea = All;
                    }
                    field("Issue Document Type"; "Issue Document Type")
                    {
                        ApplicationArea = All;
                    }
                    field("Issue Document No."; "Issue Document No.")
                    {
                        ApplicationArea = All;
                    }
                    field("Issue External Document No."; "Issue External Document No.")
                    {
                        ApplicationArea = All;
                    }
                    field("Issue Partner Code"; "Issue Partner Code")
                    {
                        ApplicationArea = All;
                    }
                    field("Partner Clearing"; "Partner Clearing")
                    {
                        ApplicationArea = All;
                    }
                    field("Allow Top-up"; "Allow Top-up")
                    {
                        ApplicationArea = All;
                    }
                }
                group(Control6014422)
                {
                    ShowCaption = false;
                    field("Issue Date"; "Issue Date")
                    {
                        ApplicationArea = All;
                    }
                    field("Initial Amount"; "Initial Amount")
                    {
                        ApplicationArea = All;
                        Editable = false;
                    }
                    field(Amount; Amount)
                    {
                        ApplicationArea = All;
                    }
                }
            }
            group("Send Voucher")
            {
                Caption = 'Send Voucher';
                group(Control6014417)
                {
                    ShowCaption = false;
                    field("Send Voucher Module"; "Send Voucher Module")
                    {
                        ApplicationArea = All;
                    }
                }
                group(Control6014415)
                {
                    ShowCaption = false;
                    field("Reference No."; "Reference No.")
                    {
                        ApplicationArea = All;
                    }
                    field("Send via Print"; "Send via Print")
                    {
                        ApplicationArea = All;
                    }
                    field("Print Template Code"; "Print Template Code")
                    {
                        ApplicationArea = All;
                    }
                    field("Send via E-mail"; "Send via E-mail")
                    {
                        ApplicationArea = All;
                    }
                    field("E-mail Template Code"; "E-mail Template Code")
                    {
                        ApplicationArea = All;
                    }
                    field("Send via SMS"; "Send via SMS")
                    {
                        ApplicationArea = All;
                    }
                    field("SMS Template Code"; "SMS Template Code")
                    {
                        ApplicationArea = All;
                    }
                    field("No. Send"; "No. Send")
                    {
                        ApplicationArea = All;
                    }
                }
                group(Contact)
                {
                    Caption = 'Contact';
                    field("Customer No."; "Customer No.")
                    {
                        ApplicationArea = All;
                    }
                    field("Contact No."; "Contact No.")
                    {
                        ApplicationArea = All;
                    }
                    field(Name; Name)
                    {
                        ApplicationArea = All;
                    }
                    field("Name 2"; "Name 2")
                    {
                        ApplicationArea = All;
                    }
                    field(Address; Address)
                    {
                        ApplicationArea = All;
                    }
                    field("Address 2"; "Address 2")
                    {
                        ApplicationArea = All;
                    }
                    field("Post Code"; "Post Code")
                    {
                        ApplicationArea = All;
                    }
                    field(City; City)
                    {
                        ApplicationArea = All;
                    }
                    field(County; County)
                    {
                        ApplicationArea = All;
                    }
                    field("Country/Region Code"; "Country/Region Code")
                    {
                        ApplicationArea = All;
                    }
                    field("E-mail"; "E-mail")
                    {
                        ApplicationArea = All;
                    }
                    field("Phone No."; "Phone No.")
                    {
                        ApplicationArea = All;
                    }
                    field("Language Code"; "Language Code")
                    {
                        ApplicationArea = All;
                        Importance = Additional;
                    }
                    field("Voucher Message"; "Voucher Message")
                    {
                        ApplicationArea = All;
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
                    field("Validate Voucher Module"; "Validate Voucher Module")
                    {
                        ApplicationArea = All;
                    }
                }
                group(Control6014409)
                {
                    ShowCaption = false;
                    field("Starting Date"; "Starting Date")
                    {
                        ApplicationArea = All;
                    }
                    field("Ending Date"; "Ending Date")
                    {
                        ApplicationArea = All;
                    }
                }
            }
            group("Apply Payment")
            {
                Caption = 'Apply Payment';
                field("Apply Payment Module"; "Apply Payment Module")
                {
                    ApplicationArea = All;
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
                RunObject = Page "NPR NpRv Arch. Voucher Entries";
                RunPageLink = "Arch. Voucher No." = FIELD("No.");
                ShortCutKey = 'Ctrl+F7';
                ApplicationArea = All;
            }
            action("Arch. Sending Log")
            {
                Caption = 'Archived Sending Log';
                Image = Log;
                RunObject = Page "NPR NpRv Arch. Sending Log";
                RunPageLink = "Arch. Voucher No." = FIELD("No.");
                ShortCutKey = 'Shift+Ctrl+F7';
                ApplicationArea = All;
            }
        }
    }

    var
        Text000: Label 'Are you sure you want to delete Vouchers In-use?';
        Text001: Label 'Manual Post Voucher?';
}

