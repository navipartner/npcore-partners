page 6151014 "NPR NpRv Voucher Card"
{
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
                        ToolTip = 'Specifies the value of the No. field';
                    }
                    field("Voucher Type"; "Voucher Type")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Voucher Type field';
                    }
                    field(Description; Description)
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Description field';
                    }
                    field("Account No."; "Account No.")
                    {
                        ApplicationArea = All;
                        ShowMandatory = true;
                        ToolTip = 'Specifies the value of the Account No. field';
                    }
                    field("Issue Register No."; "Issue Register No.")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Issue Register No. field';
                    }
                    field("Issue Document Type"; "Issue Document Type")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Issue Document Type field';
                    }
                    field("Issue Document No."; "Issue Document No.")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Issue Document No. field';
                    }
                    field("Issue External Document No."; "Issue External Document No.")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Issue External Document No. field';
                    }
                    field("Issue Partner Code"; "Issue Partner Code")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Issue Partner Code field';
                    }
                    field("Partner Clearing"; "Partner Clearing")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Partner Clearing field';
                    }
                    field("Allow Top-up"; "Allow Top-up")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Allow Top-up field';
                    }
                }
                group(Control6014422)
                {
                    ShowCaption = false;
                    field("Issue Date"; "Issue Date")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Issue Date field';
                    }
                    field(Open; Open)
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Open field';
                    }
                    field("Initial Amount"; "Initial Amount")
                    {
                        ApplicationArea = All;
                        Editable = false;
                        ToolTip = 'Specifies the value of the Initial Amount field';
                    }
                    field(Amount; Amount)
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Amount field';
                    }
                    field("In-use Quantity"; "In-use Quantity")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the In-use Quantity field';
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
                        ToolTip = 'Specifies the value of the Send Voucher Module field';
                    }
                }
                group(Control6014415)
                {
                    ShowCaption = false;
                    field("Reference No."; "Reference No.")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Reference No. field';
                    }
                    field("Send via Print"; "Send via Print")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Send via Print field';
                    }
                    field("Print Template Code"; "Print Template Code")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Print Template Code field';
                    }
                    field("Send via E-mail"; "Send via E-mail")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Send via E-mail field';
                    }
                    field("E-mail Template Code"; "E-mail Template Code")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the E-mail Template Code field';
                    }
                    field("Send via SMS"; "Send via SMS")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Send via SMS field';
                    }
                    field("SMS Template Code"; "SMS Template Code")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the SMS Template Code field';
                    }
                    field("No. Send"; "No. Send")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the No. Send field';
                    }
                }
                group(Contact)
                {
                    Caption = 'Contact';
                    field("Customer No."; "Customer No.")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Customer No. field';
                    }
                    field("Contact No."; "Contact No.")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Contact No. field';
                    }
                    field(Name; Name)
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Name field';
                    }
                    field("Name 2"; "Name 2")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Name 2 field';
                    }
                    field(Address; Address)
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Address field';
                    }
                    field("Address 2"; "Address 2")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Address 2 field';
                    }
                    field("Post Code"; "Post Code")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Post Code field';
                    }
                    field(City; City)
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the City field';
                    }
                    field(County; County)
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the County field';
                    }
                    field("Country/Region Code"; "Country/Region Code")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Country/Region Code field';
                    }
                    field("E-mail"; "E-mail")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the E-mail field';
                    }
                    field("Phone No."; "Phone No.")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Phone No. field';
                    }
                    field("Language Code"; "Language Code")
                    {
                        ApplicationArea = All;
                        Importance = Additional;
                        ToolTip = 'Specifies the value of the Language Code field';
                    }
                    field("Voucher Message"; "Voucher Message")
                    {
                        ApplicationArea = All;
                        MultiLine = true;
                        ToolTip = 'Specifies the value of the Voucher Message field';
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
                        ToolTip = 'Specifies the value of the Validate Voucher Module field';
                    }
                }
                group(Control6014409)
                {
                    ShowCaption = false;
                    field("Starting Date"; "Starting Date")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Starting Date field';
                    }
                    field("Ending Date"; "Ending Date")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Ending Date field';
                    }
                }
            }
            group("Apply Payment")
            {
                Caption = 'Apply Payment';
                field("Apply Payment Module"; "Apply Payment Module")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Apply Payment Module field';
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
                    ApplicationArea = All;
                    ToolTip = 'Executes the Send Voucher action';

                    trigger OnAction()
                    begin
                        Codeunit.Run(codeunit::"NPR NpRv Voucher Mgt.", Rec);
                    end;
                }
            }
            action("Reset Vouchers In-use")
            {
                Caption = 'Reset Vouchers In-use';
                Image = RefreshVoucher;
                ApplicationArea = All;
                ToolTip = 'Executes the Reset Vouchers In-use action';

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
                    ApplicationArea = All;
                    ToolTip = 'Executes the Archive Coupon action';

                    trigger OnAction()
                    var
                        Voucher: Record "NPR NpRv Voucher";
                        NpRvVoucherMgt: Codeunit "NPR NpRv Voucher Mgt.";
                    begin
                        if not Confirm(Text001, false) then
                            exit;

                        Voucher.Get("No.");
                        NpRvVoucherMgt.ArchiveVouchers(Voucher);
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
                ApplicationArea = All;
                ToolTip = 'Executes the Voucher Entries action';
            }
            action("Sending Log")
            {
                Caption = 'Sending Log';
                Image = Log;
                RunObject = Page "NPR NpRv Sending Log";
                RunPageLink = "Voucher No." = FIELD("No.");
                ShortCutKey = 'Shift+Ctrl+F7';
                ApplicationArea = All;
                ToolTip = 'Executes the Sending Log action';
            }
        }
    }

    var
        Text000: Label 'Are you sure you want to delete Vouchers In-use?';
        Text001: Label 'Archive Voucher Manually?';
}