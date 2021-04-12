page 6151021 "NPR NpRv Arch. Voucher Card"
{
    UsageCategory = None;
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
                    field("No."; Rec."No.")
                    {
                        ApplicationArea = All;
                        ShowMandatory = true;
                        ToolTip = 'Specifies the value of the No. field';
                    }
                    field("Voucher Type"; Rec."Voucher Type")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Voucher Type field';
                    }
                    field(Description; Rec.Description)
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Description field';
                    }
                    field("Account No."; Rec."Account No.")
                    {
                        ApplicationArea = All;
                        ShowMandatory = true;
                        ToolTip = 'Specifies the value of the Account No. field';
                    }
                    field("Issue Register No."; Rec."Issue Register No.")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Issue Register No. field';
                    }
                    field("Issue Document Type"; Rec."Issue Document Type")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Issue Document Type field';
                    }
                    field("Issue Document No."; Rec."Issue Document No.")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Issue Document No. field';
                    }
                    field("Issue External Document No."; Rec."Issue External Document No.")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Issue External Document No. field';
                    }
                    field("Issue Partner Code"; Rec."Issue Partner Code")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Issue Partner Code field';
                    }
                    field("Partner Clearing"; Rec."Partner Clearing")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Partner Clearing field';
                    }
                    field("Allow Top-up"; Rec."Allow Top-up")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Allow Top-up field';
                    }
                }
                group(Control6014422)
                {
                    ShowCaption = false;
                    field("Issue Date"; Rec."Issue Date")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Issue Date field';
                    }
                    field("Initial Amount"; Rec."Initial Amount")
                    {
                        ApplicationArea = All;
                        Editable = false;
                        ToolTip = 'Specifies the value of the Initial Amount field';
                    }
                    field(Amount; Rec.Amount)
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Amount field';
                    }
                }
            }
            group("Send Voucher")
            {
                Caption = 'Send Voucher';
                group(Control6014417)
                {
                    ShowCaption = false;
                    field("Send Voucher Module"; Rec."Send Voucher Module")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Send Voucher Module field';
                    }
                }
                group(Control6014415)
                {
                    ShowCaption = false;
                    field("Reference No."; Rec."Reference No.")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Reference No. field';
                    }
                    field("Send via Print"; Rec."Send via Print")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Send via Print field';
                    }
                    field("Print Template Code"; Rec."Print Template Code")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Print Template Code field';
                    }
                    field("Send via E-mail"; Rec."Send via E-mail")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Send via E-mail field';
                    }
                    field("E-mail Template Code"; Rec."E-mail Template Code")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the E-mail Template Code field';
                    }
                    field("Send via SMS"; Rec."Send via SMS")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Send via SMS field';
                    }
                    field("SMS Template Code"; Rec."SMS Template Code")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the SMS Template Code field';
                    }
                    field("No. Send"; Rec."No. Send")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the No. Send field';
                    }
                }
                group(Contact)
                {
                    Caption = 'Contact';
                    field("Customer No."; Rec."Customer No.")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Customer No. field';
                    }
                    field("Contact No."; Rec."Contact No.")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Contact No. field';
                    }
                    field(Name; Rec.Name)
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Name field';
                    }
                    field("Name 2"; Rec."Name 2")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Name 2 field';
                    }
                    field(Address; Rec.Address)
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Address field';
                    }
                    field("Address 2"; Rec."Address 2")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Address 2 field';
                    }
                    field("Post Code"; Rec."Post Code")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Post Code field';
                    }
                    field(City; Rec.City)
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the City field';
                    }
                    field(County; Rec.County)
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the County field';
                    }
                    field("Country/Region Code"; Rec."Country/Region Code")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Country/Region Code field';
                    }
                    field("E-mail"; Rec."E-mail")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the E-mail field';
                    }
                    field("Phone No."; Rec."Phone No.")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Phone No. field';
                    }
                    field("Language Code"; Rec."Language Code")
                    {
                        ApplicationArea = All;
                        Importance = Additional;
                        ToolTip = 'Specifies the value of the Language Code field';
                    }
                    field("Voucher Message"; Rec."Voucher Message")
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
                    field("Validate Voucher Module"; Rec."Validate Voucher Module")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Validate Voucher Module field';
                    }
                }
                group(Control6014409)
                {
                    ShowCaption = false;
                    field("Starting Date"; Rec."Starting Date")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Starting Date field';
                    }
                    field("Ending Date"; Rec."Ending Date")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Ending Date field';
                    }
                }
            }
            group("Apply Payment")
            {
                Caption = 'Apply Payment';
                field("Apply Payment Module"; Rec."Apply Payment Module")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Apply Payment Module field';
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
                ToolTip = 'Executes the Archived Voucher Entries action';
            }
            action("Arch. Sending Log")
            {
                Caption = 'Archived Sending Log';
                Image = Log;
                RunObject = Page "NPR NpRv Arch. Sending Log";
                RunPageLink = "Arch. Voucher No." = FIELD("No.");
                ShortCutKey = 'Shift+Ctrl+F7';
                ApplicationArea = All;
                ToolTip = 'Executes the Archived Sending Log action';
            }
        }
    }
}

