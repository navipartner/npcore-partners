page 6059801 "NPR External POS Sale Card"
{
    Extensible = False;

    Caption = 'External POS Sale';
    PageType = Document;
    SourceTable = "NPR External POS Sale";
    UsageCategory = None;

    layout
    {
        area(content)
        {
            group(General)
            {
                Editable = Not Rec."Converted To POS Entry";
                field(entryNo; Rec."Entry No.")
                {
                    Caption = 'Entry No.';
                    Editable = false;
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Entry No. field';
                }

                field(registerNo; Rec."Register No.")
                {
                    Caption = 'POS Unit No.';
                    Editable = false;
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Register No. field';
                }
                field(salesTicketNo; Rec."Sales Ticket No.")
                {
                    Caption = 'Sales Ticket No.';
                    Editable = false;
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Sales Ticket No. field';
                }

                field(startTime; Rec."Start Time")
                {
                    Caption = 'Start Time';
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Start Time field';
                }
                field("date"; Rec."Date")
                {
                    Caption = 'Date';
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Date field';
                }
                field(salespersonCode; Rec."Salesperson Code")
                {
                    Caption = 'Salesperson Code';
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Sales Person Code field';
                }
                field(posStoreCode; Rec."POS Store Code")
                {
                    Caption = 'POS Store Code';
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the POS Store Code field';
                }
                field(customerNo; Rec."Customer No.")
                {
                    Caption = 'Customer No.';
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Customer No. field';
                }
                field(externalDocumentNo; Rec."External Document No.")
                {
                    Caption = 'External Document No.';
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the External Document No field';
                }
                field(reference; Rec.Reference)
                {
                    Caption = 'Reference';
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Reference field';
                }

                field("User ID"; Rec."User ID")
                {
                    Caption = 'User ID';
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the User ID field';
                }
                field(convertedToPOSEntry; Rec."Converted To POS Entry")
                {
                    Caption = 'Converted To POS Entry';
                    Editable = false;
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Converted to POS Entry field';
                }
                field(posEntrySystemId; Rec."POS Entry System Id")
                {
                    Caption = 'POS Entry System Id';
                    Editable = false;
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the POS Entry System ID field';
                    trigger OnDrillDown()
                    begin
                        OpenPOSEntry();
                    end;
                }
            }
            group(ExternalInfo)
            {
                Caption = 'External POS Info';
                field("External Pos Id"; Rec."External Pos Id")
                {
                    ApplicationArea = NPRRetail;
                    Editable = false;
                    ToolTip = 'Specifies the id of the External POS used to create this sale.';
                    Caption = 'External POS Id';
                }
                field("SMS Template"; Rec."SMS Template")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the SMS Template used when sending SMS receipt.';
                    Caption = 'SMS Template';
                }
                field("Email Template"; Rec."Email Template")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the E-mail Template used when sending E-mail receipt.';
                    Caption = 'E-mail Template';
                }
                field("External Pos Sale Id"; Rec."External Pos Sale Id")
                {
                    ApplicationArea = NPRRetail;
                    Editable = false;
                    ToolTip = 'Specifies the id of the external sale, generated by the external POS.';
                    Caption = 'External POS Sale Id ';
                }
            }
            group(CustomerInfo)
            {
                Caption = 'Customer Information';
                Editable = false;
                field("Send Receipt: Email"; Rec."Send Receipt: Email")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies if the receipt should be sent to the customer via E-mail.';
                    Caption = 'Send Receipt: Email';
                }
                field("Send Receipt: SMS"; Rec."Send Receipt: SMS")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies if the receipt should be sent to the customer via SMS.';
                    Caption = 'Send Receipt: SMS';
                }
                field("Phone Number"; Rec."Phone Number")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the customers phone number';
                    Caption = 'Phone Number';
                }
                field("E-mail"; Rec."E-mail")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the customers E-mail.';
                    Caption = 'E-mail';
                }
                field("E-mail Receipt Sent"; Rec."Email Receipt Sent")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies if the email receipt has been sent.';
                    Caption = 'E-mail Receipt Sent';
                }
                field("SMS Receipt Sent"; Rec."SMS Receipt Sent")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies if the sms receipt has been sent.';
                    Caption = 'SMS Receipt Sent';
                }
                field("SMS Receipt Log"; Rec."SMS Receipt Log")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the log of the sent SMS Receipt';
                    Caption = 'SMS Receipt Sent Log';
                }
            }

            group(ProcessingError)
            {
                Caption = 'Processing Error';
                Visible = Rec."Has Conversion Error";
                field("Has Conversion Error"; Rec."Has Conversion Error")
                {
                    Caption = 'Has Conversion Error';
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Has Conversion Error field';
                }
                field("Last Conversion Error Message"; Rec."Last Conversion Error Message")
                {
                    Caption = 'Last Conversion Error Message';
                    ApplicationArea = NPRRetail;
                    MultiLine = true;
                    ToolTip = 'Specifies the value of the Last Conversion Error Message field';
                }
            }

            part(Lines; "NPR External POS Sale Subform")
            {
                Caption = 'Sale Lines';
                Editable = NOT Rec."Converted To POS Entry";
                SubPageLink =
                    "External POS Sale Entry No." = FIELD("Entry No."),
                    "Line Type" = FILTER((<> 2));
                ApplicationArea = NPRRetail;
            }

            part(PaymentLines; "NPR External POS Sale Pay Sub")
            {
                Caption = 'Payment Lines';
                Editable = NOT Rec."Converted To POS Entry";
                SubPageLink =
                    "External POS Sale Entry No." = FIELD("Entry No."),
                    "Line Type" = FILTER(= 2);
                ApplicationArea = NPRRetail;
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(ConvertToPOSEntry)
            {
                ApplicationArea = NPRRetail;
                Caption = 'Convert To POS Entry';
                Promoted = true;
                PromotedIsBig = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                Image = PostDocument;
                ToolTip = 'Converts an External POS Sale into a POS Entry.';
                trigger OnAction()
                var
                    ExtPOSSaleConverter: Codeunit "NPR Ext. POS Sale Converter";
                    ExtPOSSaleProcessing: Codeunit "NPR Ext. POS Sale Processing";
                    CreatePOSEntryConfirm: Label 'Are you sure you want to convert this External POS Sale into POS Entry?';
                begin
                    IF Not Confirm(CreatePOSEntryConfirm) then
                        exit;
                    if (not ExtPOSSaleConverter.Run(Rec)) then begin
                        ExtPOSSaleProcessing.AddConversionError(Rec, GetLastErrorText());
                        Message(GetLastErrorText());
                    end;
                    CurrPage.Update(true);
                end;
            }
        }

        area(Navigation)
        {
            action(POSEntry)
            {
                ApplicationArea = NPRRetail;
                Caption = 'Open POS Entry';
                Promoted = true;
                PromotedIsBig = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                Image = ViewDetails;
                ToolTip = 'Shows created POS Entry';
                trigger OnAction()
                begin
                    OpenPOSEntry();
                end;
            }
        }
    }

    local procedure OpenPOSEntry()
    var
        POSEntryRec: Record "NPR POS Entry";
    begin
        Rec.TestField("Converted To POS Entry", true);
        Rec.TestField("POS Entry System Id");

        POSEntryRec.GetBySystemId(Rec."POS Entry System Id");
        PAGE.RunModal(Page::"NPR POS Entry Card", POSEntryRec);
    end;
}
