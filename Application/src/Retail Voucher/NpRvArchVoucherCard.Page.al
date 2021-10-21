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

                        ShowMandatory = true;
                        ToolTip = 'Specifies the value of the No. field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Voucher Type"; Rec."Voucher Type")
                    {

                        ToolTip = 'Specifies the value of the Voucher Type field';
                        ApplicationArea = NPRRetail;
                    }
                    field(Description; Rec.Description)
                    {

                        ToolTip = 'Specifies the value of the Description field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Account No."; Rec."Account No.")
                    {

                        ShowMandatory = true;
                        ToolTip = 'Specifies the value of the Account No. field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Issue Register No."; Rec."Issue Register No.")
                    {

                        ToolTip = 'Specifies the value of the Issue Register No. field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Issue Document Type"; Rec."Issue Document Type")
                    {

                        ToolTip = 'Specifies the value of the Issue Document Type field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Issue Document No."; Rec."Issue Document No.")
                    {

                        ToolTip = 'Specifies the value of the Issue Document No. field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Issue External Document No."; Rec."Issue External Document No.")
                    {

                        ToolTip = 'Specifies the value of the Issue External Document No. field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Issue Partner Code"; Rec."Issue Partner Code")
                    {

                        ToolTip = 'Specifies the value of the Issue Partner Code field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Partner Clearing"; Rec."Partner Clearing")
                    {

                        ToolTip = 'Specifies the value of the Partner Clearing field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Allow Top-up"; Rec."Allow Top-up")
                    {

                        ToolTip = 'Specifies the value of the Allow Top-up field';
                        ApplicationArea = NPRRetail;
                    }
                }
                group(Control6014422)
                {
                    ShowCaption = false;
                    field("Issue Date"; Rec."Issue Date")
                    {

                        ToolTip = 'Specifies the value of the Issue Date field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Initial Amount"; Rec."Initial Amount")
                    {

                        Editable = false;
                        ToolTip = 'Specifies the value of the Initial Amount field';
                        ApplicationArea = NPRRetail;
                    }
                    field(Amount; Rec.Amount)
                    {

                        ToolTip = 'Specifies the value of the Amount field';
                        ApplicationArea = NPRRetail;
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

                        ToolTip = 'Specifies the value of the Send Voucher Module field';
                        ApplicationArea = NPRRetail;
                    }
                }
                group(Control6014415)
                {
                    ShowCaption = false;
                    field("Reference No."; Rec."Reference No.")
                    {

                        ToolTip = 'Specifies the value of the Reference No. field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Send via Print"; Rec."Send via Print")
                    {
                        ToolTip = 'Specifies the value of the Send via Print field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Print Object Type"; Rec."Print Object Type")
                    {
                        Enabled = Rec."Send via Print";
                        ToolTip = 'Specifies the print object type for the voucher type';
                        ApplicationArea = NPRRetail;

                        trigger OnValidate()
                        begin
                            UpdateControls();
                        end;
                    }
                    field("Print Object ID"; Rec."Print Object ID")
                    {
                        Enabled = Rec."Send via Print" and not PrintUsingTemplate;
                        ToolTip = 'Specifies the print object Id for the voucher type';
                        ApplicationArea = NPRRetail;
                    }
                    field("Print Template Code"; Rec."Print Template Code")
                    {
                        Enabled = Rec."Send via Print" and PrintUsingTemplate;
                        ToolTip = 'Specifies the value of the Print Template Code field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Send via E-mail"; Rec."Send via E-mail")
                    {
                        ToolTip = 'Specifies the value of the Send via E-mail field';
                        ApplicationArea = NPRRetail;
                    }
                    field("E-mail Template Code"; Rec."E-mail Template Code")
                    {
                        Enabled = Rec."Send via E-mail";
                        ToolTip = 'Specifies the value of the E-mail Template Code field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Send via SMS"; Rec."Send via SMS")
                    {
                        ToolTip = 'Specifies the value of the Send via SMS field';
                        ApplicationArea = NPRRetail;
                    }
                    field("SMS Template Code"; Rec."SMS Template Code")
                    {
                        Enabled = Rec."Send via SMS";
                        ToolTip = 'Specifies the value of the SMS Template Code field';
                        ApplicationArea = NPRRetail;
                    }
                    field("No. Send"; Rec."No. Send")
                    {

                        ToolTip = 'Specifies the value of the No. Send field';
                        ApplicationArea = NPRRetail;
                    }
                }
                group(Contact)
                {
                    Caption = 'Contact';
                    field("Customer No."; Rec."Customer No.")
                    {

                        ToolTip = 'Specifies the value of the Customer No. field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Contact No."; Rec."Contact No.")
                    {

                        ToolTip = 'Specifies the value of the Contact No. field';
                        ApplicationArea = NPRRetail;
                    }
                    field(Name; Rec.Name)
                    {

                        ToolTip = 'Specifies the value of the Name field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Name 2"; Rec."Name 2")
                    {

                        ToolTip = 'Specifies the value of the Name 2 field';
                        ApplicationArea = NPRRetail;
                    }
                    field(Address; Rec.Address)
                    {

                        ToolTip = 'Specifies the value of the Address field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Address 2"; Rec."Address 2")
                    {

                        ToolTip = 'Specifies the value of the Address 2 field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Post Code"; Rec."Post Code")
                    {

                        ToolTip = 'Specifies the value of the Post Code field';
                        ApplicationArea = NPRRetail;
                    }
                    field(City; Rec.City)
                    {

                        ToolTip = 'Specifies the value of the City field';
                        ApplicationArea = NPRRetail;
                    }
                    field(County; Rec.County)
                    {

                        ToolTip = 'Specifies the value of the County field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Country/Region Code"; Rec."Country/Region Code")
                    {

                        ToolTip = 'Specifies the value of the Country/Region Code field';
                        ApplicationArea = NPRRetail;
                    }
                    field("E-mail"; Rec."E-mail")
                    {

                        ToolTip = 'Specifies the value of the E-mail field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Phone No."; Rec."Phone No.")
                    {

                        ToolTip = 'Specifies the value of the Phone No. field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Language Code"; Rec."Language Code")
                    {

                        Importance = Additional;
                        ToolTip = 'Specifies the value of the Language Code field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Voucher Message"; Rec."Voucher Message")
                    {

                        MultiLine = true;
                        ToolTip = 'Specifies the value of the Voucher Message field';
                        ApplicationArea = NPRRetail;
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

                        ToolTip = 'Specifies the value of the Validate Voucher Module field';
                        ApplicationArea = NPRRetail;
                    }
                }
                group(Control6014409)
                {
                    ShowCaption = false;
                    field("Starting Date"; Rec."Starting Date")
                    {

                        ToolTip = 'Specifies the value of the Starting Date field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Ending Date"; Rec."Ending Date")
                    {

                        ToolTip = 'Specifies the value of the Ending Date field';
                        ApplicationArea = NPRRetail;
                    }
                }
            }
            group("Apply Payment")
            {
                Caption = 'Apply Payment';
                field("Apply Payment Module"; Rec."Apply Payment Module")
                {

                    ToolTip = 'Specifies the value of the Apply Payment Module field';
                    ApplicationArea = NPRRetail;
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

                ToolTip = 'Executes the Archived Voucher Entries action';
                ApplicationArea = NPRRetail;
            }
            action("Arch. Sending Log")
            {
                Caption = 'Archived Sending Log';
                Image = Log;
                RunObject = Page "NPR NpRv Arch. Sending Log";
                RunPageLink = "Arch. Voucher No." = FIELD("No.");
                ShortCutKey = 'Shift+Ctrl+F7';

                ToolTip = 'Executes the Archived Sending Log action';
                ApplicationArea = NPRRetail;
            }
        }
    }

    var
        PrintUsingTemplate: Boolean;

    trigger OnAfterGetCurrRecord()
    begin
        UpdateControls();
    end;

    local procedure UpdateControls()
    begin
        PrintUsingTemplate := Rec."Print Object Type" = Rec."Print Object Type"::Template;
    end;
}