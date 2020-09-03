page 6151014 "NPR NpRv Voucher Card"
{
    // NPR5.37/MHA /20171023  CASE 267346 Object created - NaviPartner Retail Voucher
    // NPR5.46/MHA /20180928  CASE 330222 Removed caption on Group Control6014409
    // NPR5.48/MHA /20181122  CASE 302179 Added fields 85, 1005, 1007, 1010, 1013
    // NPR5.48/MHA /20190123  CASE 341711 Added field 90 "E-mail Template Code", 95 "SMS Template Code", 103 "Send via Print", 105 "Send via E-mail", 107 "Send via SMS"
    // NPR5.49/MHA /20190228  CASE 342811 Added Retail Voucher Partner fields used with Cross Company Vouchers
    // NPR5.50/MHA /20190426  CASE 353079 Added field 62 "Allow Top-up"
    // NPR5.53/MHA /20191211  CASE 380284 Added field 76 "Initial Amount"
    // NPR5.55/MHA /20200427  CASE 402015 Removed field 85 "In-use Quantity (External)"
    // NPR5.55/MHA /20200701  CASE 397527 Added field 270 "Language Code"
    // NPR5.55/MHA /20200702  CASE 407070 Added Sending Log

    Caption = 'Retail Voucher Card';
    SourceTable = "NPR NpRv Voucher";

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
                    field(Open; Open)
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
                    field("In-use Quantity"; "In-use Quantity")
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
        area(processing)
        {
            group(SendGroup)
            {
                Caption = '&Send';
                Image = Post;
                action(SendVoucher)
                {
                    Caption = 'Send Voucher';
                    Image = SendTo;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;

                    trigger OnAction()
                    var
                        NpRvVoucherMgt: Codeunit "NPR NpRv Voucher Mgt.";
                    begin
                        NpRvVoucherMgt.SendVoucher(Rec);
                    end;
                }
            }
            action("Reset Vouchers In-use")
            {
                Caption = 'Reset Vouchers In-use';
                Image = RefreshVoucher;

                trigger OnAction()
                var
                    NpRvVoucherMgt: Codeunit "NPR NpRv Voucher Mgt.";
                begin
                    if not Confirm(Text000) then
                        exit;

                    NpRvVoucherMgt.ResetInUseQty(Rec);
                end;
            }
            group(ArchiveGroup)
            {
                Caption = '&Archive';
                Image = Post;
                action("Archive Coupon")
                {
                    Caption = 'Archive Coupon';
                    Image = Post;

                    trigger OnAction()
                    var
                        Voucher: Record "NPR NpRv Voucher";
                        NpRvVoucherMgt: Codeunit "NPR NpRv Voucher Mgt.";
                    begin
                        if not Confirm(Text001, false) then
                            exit;

                        Voucher.Get("No.");
                        Voucher.SetRecFilter;
                        NpRvVoucherMgt.ArchiveVouchers(Rec);
                    end;
                }
            }
        }
        area(navigation)
        {
            action("Voucher Entries")
            {
                Caption = 'Voucher Entries';
                Image = Entries;
                RunObject = Page "NPR NpRv Voucher Entries";
                RunPageLink = "Voucher No." = FIELD("No.");
                ShortCutKey = 'Ctrl+F7';
            }
            action("Sending Log")
            {
                Caption = 'Sending Log';
                Image = Log;
                RunObject = Page "NPR NpRv Sending Log";
                RunPageLink = "Voucher No." = FIELD("No.");
                ShortCutKey = 'Shift+Ctrl+F7';
            }
        }
    }

    var
        Text000: Label 'Are you sure you want to delete Vouchers In-use?';
        Text001: Label 'Archive Voucher Manually?';
}

