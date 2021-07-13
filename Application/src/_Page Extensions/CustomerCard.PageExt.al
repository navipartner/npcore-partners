pageextension 6014425 "NPR Customer Card" extends "Customer Card"
{
    layout
    {
        addafter(AdjProfitPct)
        {
            field("NPR To Anonymize On"; Rec."NPR To Anonymize On")
            {

                Editable = ToAnonymizeEditable;
                ToolTip = 'Specifies the value of the NPR To Anonymize On field';
                ApplicationArea = NPRRetail;
            }
            field("NPR Anonymized"; Rec."NPR Anonymized")
            {

                ToolTip = 'Specifies the value of the NPR Anonymized field';
                ApplicationArea = NPRRetail;
            }
            field("NPR Anonymized Date"; Rec."NPR Anonymized Date")
            {

                ToolTip = 'Specifies the value of the NPR Anonymized Date field';
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

                    ToolTip = 'Specifies the value of the NPR Magento Display Group field';
                    ApplicationArea = NPRRetail;
                }
                field("NPR Magento Store Code"; Rec."NPR Magento Store Code")
                {

                    Visible = (MagentoVersion >= 2);
                    ToolTip = 'Specifies the value of the NPR Magento Store Code field';
                    ApplicationArea = NPRRetail;
                }
                field("NPR Magento Shipping Group"; Rec."NPR Magento Shipping Group")
                {

                    Visible = (MagentoVersion >= 2);
                    ToolTip = 'Specifies the value of the NPR Magento Shipping Group field';
                    ApplicationArea = NPRRetail;
                }
                field("NPR Magento Payment Group"; Rec."NPR Magento Payment Group")
                {

                    Visible = (MagentoVersion >= 2);
                    ToolTip = 'Specifies the value of the NPR Magento Payment Group field';
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

                    ToolTip = 'Executes the Shipping Label action';
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

                ToolTip = 'Executes the POS Info action';
                ApplicationArea = NPRRetail;
            }
        }
        addafter("Item &Tracking Entries")
        {
            action("NPR POS Entries")
            {
                Caption = 'POS Entries';
                Image = Entries;

                ToolTip = 'Executes the POS Entries action';
                ApplicationArea = NPRRetail;
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

                    ToolTip = 'Executes the Send SMS action';
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

                ToolTip = 'Executes the Customer Anonymization action';
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
        MagentoVersion: Decimal;
        ReasonText: Text;
        Text000: Label 'All Customer Information wil be lost! Do you want to continue?';
        ToAnonymizeEditable: Boolean;
        UserSetup: Record "User Setup";

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