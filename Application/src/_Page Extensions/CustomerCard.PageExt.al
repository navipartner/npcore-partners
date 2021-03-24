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
        addafter("Disable Search by Name")
        {
            field(NPRAttrTextArray_01; NPRAttrTextArray[1])
            {
                ApplicationArea = All;
                CaptionClass = '6014555,18,1,2';
                Editable = NPRAttrEditable;
                Visible = NPRAttrVisible01;
                ToolTip = 'Specifies the value of the NPRAttrTextArray[1] field';

                trigger OnValidate()
                begin
                    NPRAttrManagement.SetMasterDataAttributeValue(Database::Customer, 1, Rec."No.", NPRAttrTextArray[1]);
                end;
            }
            field(NPRAttrTextArray_02; NPRAttrTextArray[2])
            {
                ApplicationArea = All;
                CaptionClass = '6014555,18,2,2';
                Editable = NPRAttrEditable;
                Visible = NPRAttrVisible02;
                ToolTip = 'Specifies the value of the NPRAttrTextArray[2] field';

                trigger OnValidate()
                begin
                    NPRAttrManagement.SetMasterDataAttributeValue(Database::Customer, 2, Rec."No.", NPRAttrTextArray[2]);
                end;
            }
            field(NPRAttrTextArray_03; NPRAttrTextArray[3])
            {
                ApplicationArea = All;
                CaptionClass = '6014555,18,3,2';
                Editable = NPRAttrEditable;
                Visible = NPRAttrVisible03;
                ToolTip = 'Specifies the value of the NPRAttrTextArray[3] field';

                trigger OnValidate()
                begin
                    NPRAttrManagement.SetMasterDataAttributeValue(Database::Customer, 3, Rec."No.", NPRAttrTextArray[3]);
                end;
            }
            field(NPRAttrTextArray_04; NPRAttrTextArray[4])
            {
                ApplicationArea = All;
                CaptionClass = '6014555,18,4,2';
                Editable = NPRAttrEditable;
                Visible = NPRAttrVisible04;
                ToolTip = 'Specifies the value of the NPRAttrTextArray[4] field';

                trigger OnValidate()
                begin
                    NPRAttrManagement.SetMasterDataAttributeValue(Database::Customer, 4, Rec."No.", NPRAttrTextArray[4]);
                end;
            }
            field(NPRAttrTextArray_05; NPRAttrTextArray[5])
            {
                ApplicationArea = All;
                CaptionClass = '6014555,18,5,2';
                Editable = NPRAttrEditable;
                Visible = NPRAttrVisible05;
                ToolTip = 'Specifies the value of the NPRAttrTextArray[5] field';

                trigger OnValidate()
                begin
                    NPRAttrManagement.SetMasterDataAttributeValue(Database::Customer, 5, Rec."No.", NPRAttrTextArray[5]);
                end;
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
            group("NPR Extra Fields")
            {
                Caption = 'Extra Fields';
                field(NPRAttrTextArray_06; NPRAttrTextArray[6])
                {
                    ApplicationArea = All;
                    CaptionClass = '6014555,18,6,2';
                    Editable = NPRAttrEditable;
                    Visible = NPRAttrVisible06;
                    ToolTip = 'Specifies the value of the NPRAttrTextArray[6] field';

                    trigger OnValidate()
                    begin
                        NPRAttrManagement.SetMasterDataAttributeValue(Database::Customer, 6, Rec."No.", NPRAttrTextArray[6]);
                    end;
                }
                field(NPRAttrTextArray_07; NPRAttrTextArray[7])
                {
                    ApplicationArea = All;
                    CaptionClass = '6014555,18,7,2';
                    Editable = NPRAttrEditable;
                    Visible = NPRAttrVisible07;
                    ToolTip = 'Specifies the value of the NPRAttrTextArray[7] field';

                    trigger OnValidate()
                    begin
                        NPRAttrManagement.SetMasterDataAttributeValue(Database::Customer, 7, Rec."No.", NPRAttrTextArray[7]);
                    end;
                }
                field(NPRAttrTextArray_08; NPRAttrTextArray[8])
                {
                    ApplicationArea = All;
                    CaptionClass = '6014555,18,8,2';
                    Editable = NPRAttrEditable;
                    Visible = NPRAttrVisible08;
                    ToolTip = 'Specifies the value of the NPRAttrTextArray[8] field';

                    trigger OnValidate()
                    begin
                        NPRAttrManagement.SetMasterDataAttributeValue(Database::Customer, 8, Rec."No.", NPRAttrTextArray[8]);
                    end;
                }
                field(NPRAttrTextArray_09; NPRAttrTextArray[9])
                {
                    ApplicationArea = All;
                    CaptionClass = '6014555,18,9,2';
                    Editable = NPRAttrEditable;
                    Visible = NPRAttrVisible09;
                    ToolTip = 'Specifies the value of the NPRAttrTextArray[9] field';

                    trigger OnValidate()
                    begin
                        NPRAttrManagement.SetMasterDataAttributeValue(Database::Customer, 9, Rec."No.", NPRAttrTextArray[9]);
                    end;
                }
                field(NPRAttrTextArray_10; NPRAttrTextArray[10])
                {
                    ApplicationArea = All;
                    CaptionClass = '6014555,18,10,2';
                    Editable = NPRAttrEditable;
                    Visible = NPRAttrVisible10;
                    ToolTip = 'Specifies the value of the NPRAttrTextArray[10] field';

                    trigger OnValidate()
                    begin
                        NPRAttrManagement.SetMasterDataAttributeValue(Database::Customer, 10, Rec."No.", NPRAttrTextArray[10]);
                    end;
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
            group("NPR PDF2NAV")
            {
                Caption = 'PDF2NAV';
                action("NPR EmailLog")
                {
                    Caption = 'E-mail Log';
                    Image = Email;
                    ApplicationArea = All;
                    ToolTip = 'Executes the E-mail Log action';
                }
                action("NPR SendAsPDF")
                {
                    Caption = 'Send Statement as PDF';
                    Image = SendEmailPDF;
                    ApplicationArea = All;
                    ToolTip = 'Executes the Send Statement as PDF action';
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
        NPRAttrTextArray: array[40] of Text[100];
        NPRAttrManagement: Codeunit "NPR Attribute Management";
        NPRAttrEditable: Boolean;
        NPRAttrVisibleArray: array[40] of Boolean;
        NPRAttrVisible01: Boolean;
        NPRAttrVisible02: Boolean;
        NPRAttrVisible03: Boolean;
        NPRAttrVisible04: Boolean;
        NPRAttrVisible05: Boolean;
        NPRAttrVisible06: Boolean;
        NPRAttrVisible07: Boolean;
        NPRAttrVisible08: Boolean;
        NPRAttrVisible09: Boolean;
        NPRAttrVisible10: Boolean;
        MagentoVersion: Decimal;
        ReasonText: Text;
        Text000: Label 'All Customer Information wil be lost! Do you want to continue?';
        ToAnonymizeEditable: Boolean;
        UserSetup: Record "User Setup";

    trigger OnAfterGetRecord()
    begin
        NPRAttrManagement.GetMasterDataAttributeValue(NPRAttrTextArray, DATABASE::Customer, "No.");
        NPRAttrEditable := CurrPage.Editable();

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

        NPRAttrManagement.GetAttributeVisibility(DATABASE::Customer, NPRAttrVisibleArray);
        NPRAttrVisible01 := NPRAttrVisibleArray[1];
        NPRAttrVisible02 := NPRAttrVisibleArray[2];
        NPRAttrVisible03 := NPRAttrVisibleArray[3];
        NPRAttrVisible04 := NPRAttrVisibleArray[4];
        NPRAttrVisible05 := NPRAttrVisibleArray[5];
        NPRAttrVisible06 := NPRAttrVisibleArray[6];
        NPRAttrVisible07 := NPRAttrVisibleArray[7];
        NPRAttrVisible08 := NPRAttrVisibleArray[8];
        NPRAttrVisible09 := NPRAttrVisibleArray[9];
        NPRAttrVisible10 := NPRAttrVisibleArray[10];

        NPRAttrEditable := CurrPage.Editable();

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
        if not MagentoSetup.Get then
            exit;

        case MagentoSetup."Magento Version" of
            MagentoSetup."Magento Version"::"1":
                MagentoVersion := 1;
            MagentoSetup."Magento Version"::"2":
                MagentoVersion := 2;
        end;
    end;
}