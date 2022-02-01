pageextension 6014425 "NPR Customer Card" extends "Customer Card"
{
    layout
    {
        addafter(AdjProfitPct)
        {
            field("NPR To Anonymize On"; Rec."NPR To Anonymize On")
            {

                Editable = ToAnonymizeEditable;
                ToolTip = 'Schedule the date on which the customer will be anonymized.';
                ApplicationArea = NPRRetail;
            }
            field("NPR Anonymized"; Rec."NPR Anonymized")
            {

                ToolTip = 'Display if customer information has been Anonymized.';
                ApplicationArea = NPRRetail;
            }
            field("NPR Anonymized Date"; Rec."NPR Anonymized Date")
            {

                ToolTip = 'Specifies the date on which customer information has been anonymized.';
                ApplicationArea = NPRRetail;
            }
        }
        addafter("Address & Contact")
        {
            group("NPR Magento")
            {
                Caption = 'Magento';
                field("NPR Magento Display Group"; Rec."NPR Magento Display Group")
                {

                    ToolTip = 'Specifies how the item on the Magento webstore will be grouped and displayed.';
                    ApplicationArea = NPRRetail;
                }
                field("NPR Magento Store Code"; Rec."NPR Magento Store Code")
                {

                    Visible = (MagentoVersion >= 2);
                    ToolTip = 'View of the Magento store codes on webstore e.g Default,DK, EN.';
                    ApplicationArea = NPRRetail;
                }
                field("NPR Magento Shipping Group"; Rec."NPR Magento Shipping Group")
                {

                    Visible = (MagentoVersion >= 2);
                    ToolTip = 'Specifies the shipping configuration group e.g GLS, Free shipping.';
                    ApplicationArea = NPRRetail;
                }
                field("NPR Magento Payment Group"; Rec."NPR Magento Payment Group")
                {

                    Visible = (MagentoVersion >= 2);
                    ToolTip = 'Specifies the payment method for the item.';
                    ApplicationArea = NPRRetail;
                }
            }
        }
        moveafter("VAT Registration No."; "Tax Liable")
        moveafter("VAT Registration No."; "Tax Area Code")
    }
    actions
    {
        addfirst(Navigation)
        {
            group("NPR Retail")
            {
                Caption = 'Retail';

                action("NPR AlternativeNo")
                {
                    Caption = 'Alternative No.';
                    Image = "Action";
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedOnly = true;

                    ToolTip = 'Executes the Alternative No. action';
                    ApplicationArea = NPRRetail;
                }
                action("NPR PrintShippingLabel")
                {
                    Caption = 'Shipping Label';
                    Image = PrintCheck;

                    ToolTip = 'Creates a Shipping label with all necessary information included.';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    var
                        Customer: Record Customer;
                        LabelLibrary: Codeunit "NPR Label Library";
                        RecRef: RecordRef;
                    begin
                        Customer := Rec;
                        Customer.SetRecFilter();
                        RecRef.GetTable(Customer);
                        LabelLibrary.PrintCustomShippingLabel(RecRef, '');
                    end;
                }
            }
        }
        addafter(CustomerReportSelections)
        {
            action("NPR POS Info")
            {
                Caption = 'POS Info';
                Image = Info;
                RunObject = Page "NPR POS Info Links";
                RunPageLink = "Table ID" = CONST(18),
                              "Primary Key" = FIELD("No.");

                ToolTip = 'View the POS Info list which includes POS Info Code, POS Info Description and When To Use.';
                ApplicationArea = NPRRetail;
            }
        }
        addafter("Item &Tracking Entries")
        {
            action("NPR POS Entries")
            {
                Caption = 'POS Entries';
                Image = Entries;

                ToolTip = 'View the POS Entries list which includes Entry Date, Document No, Starting Time, Ending Time, etc.';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                var
                    POSEntryNavigation: Codeunit "NPR POS Entry Navigation";
                begin
                    POSEntryNavigation.OpenPOSEntryListFromCustomer(Rec);
                end;
            }
        }
        addafter(Documents)
        {
            group("NPR SMS")
            {
                Caption = 'SMS';
                action("NPR SendSMS")
                {
                    Caption = 'Send SMS';
                    Image = SendConfirmation;

                    ToolTip = 'Sends SMS message to the customer.';
                    ApplicationArea = NPRRetail;
                    trigger OnAction()
                    var
                        SMSMgt: Codeunit "NPR SMS Management";
                    begin
                        SMSMgt.EditAndSendSMS(Rec);
                    end;
                }
            }
        }
        addafter(PaymentRegistration)
        {
            action("NPR Customer Anonymization")
            {
                Caption = 'Customer Anonymization';
                Ellipsis = true;
                Image = AbsenceCategory;

                ToolTip = 'Executes the Anonymization action';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                var
                    GDPRManagement: Codeunit "NPR NP GDPR Management";
                begin
                    Rec.TestField("NPR Anonymized", false);
                    if (GDPRManagement.DoAnonymization(Rec."No.", ReasonText)) then
                        if (not Confirm(Text000, false)) then
                            Error('');

                    Message(ReasonText);
                end;
            }
        }
    }

    var
        UserSetup: Record "User Setup";
        MagentoVersion: Decimal;
        ReasonText: Text;
        Text000: Label 'All Customer Information wil be lost! Do you want to continue?';
        ToAnonymizeEditable: Boolean;

    trigger OnAfterGetRecord()
    begin
        if UserSetup.Get(UserId) then
            if UserSetup."NPR Anonymize Customers" then
                ToAnonymizeEditable := true
            else
                ToAnonymizeEditable := false;
    end;


    trigger OnOpenPage()
    begin
        // ToAnonymizeEditable := false; was previously in C/AL set in "OnInit()" but
        // this trigger isn't available in PageExtension object so I moved it here.
        ToAnonymizeEditable := false;

        SetMagentoVersion();

        if UserSetup.Get(UserId) then
            if UserSetup."NPR Anonymize Customers" then
                ToAnonymizeEditable := true
            else
                ToAnonymizeEditable := false;
    end;

    local procedure SetMagentoVersion()
    var
        MagentoSetup: Record "NPR Magento Setup";
    begin
        if not MagentoSetup.Get() then
            exit;

        case MagentoSetup."Magento Version" of
            MagentoSetup."Magento Version"::"1":
                MagentoVersion := 1;
            MagentoSetup."Magento Version"::"2":
                MagentoVersion := 2;
        end;
    end;
}