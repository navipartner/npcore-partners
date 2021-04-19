pageextension 6014425 "NPR Customer Card" extends "Customer Card"
{
    layout
    {
        modify("Name 2")
        {
            Visible = true;
        }
        addafter(AdjProfitPct)
        {
            field("NPR To Anonymize On"; Rec."NPR To Anonymize On")
            {
                ApplicationArea = All;
                Editable = ToAnonymizeEditable;
                ToolTip = 'Specifies the value of the NPR To Anonymize On field';
            }
            field("NPR Anonymized"; Rec."NPR Anonymized")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the NPR Anonymized field';
            }
            field("NPR Anonymized Date"; Rec."NPR Anonymized Date")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the NPR Anonymized Date field';
            }
        }
        addafter("Address & Contact")
        {
            group("NPR Magento")
            {
                Caption = 'Magento';
                field("NPR Magento Display Group"; Rec."NPR Magento Display Group")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the NPR Magento Display Group field';
                }
                field("NPR Magento Store Code"; Rec."NPR Magento Store Code")
                {
                    ApplicationArea = All;
                    Visible = (MagentoVersion >= 2);
                    ToolTip = 'Specifies the value of the NPR Magento Store Code field';
                }
                field("NPR Magento Shipping Group"; Rec."NPR Magento Shipping Group")
                {
                    ApplicationArea = All;
                    Visible = (MagentoVersion >= 2);
                    ToolTip = 'Specifies the value of the NPR Magento Shipping Group field';
                }
                field("NPR Magento Payment Group"; Rec."NPR Magento Payment Group")
                {
                    ApplicationArea = All;
                    Visible = (MagentoVersion >= 2);
                    ToolTip = 'Specifies the value of the NPR Magento Payment Group field';
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
                action("NPR ItemLedgerEntries")
                {
                    Caption = 'Item Ledger Entries';
                    Image = ItemLedger;
                    ApplicationArea = All;
                    ToolTip = 'Executes the Item Ledger Entries action';

                    trigger OnAction()
                    var
                        ItemLedgerEntry: Record "Item Ledger Entry";
                    begin
                        ItemLedgerEntry.SetRange("Source No.", Rec."No.");
                        Page.RunModal(Page::"Item Ledger Entries", ItemLedgerEntry);
                    end;
                }
                action("NPR AuditRoll")
                {
                    Caption = 'Audit Roll';
                    Image = ListPage;
                    ApplicationArea = All;
                    ToolTip = 'Executes the Audit Roll action';
                }
                action("NPR AlternativeNo")
                {
                    Caption = 'Alternative No.';
                    Image = "Action";
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedOnly = true;
                    ApplicationArea = All;
                    ToolTip = 'Executes the Alternative No. action';
                }
                action("NPR PrintShippingLabel")
                {
                    Caption = 'Shipping Label';
                    Image = PrintCheck;
                    ApplicationArea = All;
                    ToolTip = 'Executes the Shipping Label action';

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
                ApplicationArea = All;
                ToolTip = 'Executes the POS Info action';
            }
        }
        addafter("Item &Tracking Entries")
        {
            action("NPR POS Entries")
            {
                Caption = 'POS Entries';
                Image = Entries;
                ApplicationArea = All;
                ToolTip = 'Executes the POS Entries action';
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
                    ApplicationArea = All;
                    ToolTip = 'Executes the Send SMS action';
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
                ApplicationArea = All;
                ToolTip = 'Executes the Customer Anonymization action';

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