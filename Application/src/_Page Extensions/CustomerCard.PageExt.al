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
            field("NPR To Anonymize On"; "NPR To Anonymize On")
            {
                ApplicationArea = All;
                Editable = ToAnonymizeEditable;
            }
            field("NPR Anonymized"; "NPR Anonymized")
            {
                ApplicationArea = All;
            }
            field("NPR Anonymized Date"; "NPR Anonymized Date")
            {
                ApplicationArea = All;
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

                trigger OnValidate()
                begin
                    NPRAttrManagement.SetMasterDataAttributeValue(DATABASE::Customer, 1, "No.", NPRAttrTextArray[1]);
                end;
            }
            field(NPRAttrTextArray_02; NPRAttrTextArray[2])
            {
                ApplicationArea = All;
                CaptionClass = '6014555,18,2,2';
                Editable = NPRAttrEditable;
                Visible = NPRAttrVisible02;

                trigger OnValidate()
                begin
                    NPRAttrManagement.SetMasterDataAttributeValue(DATABASE::Customer, 2, "No.", NPRAttrTextArray[2]);
                end;
            }
            field(NPRAttrTextArray_03; NPRAttrTextArray[3])
            {
                ApplicationArea = All;
                CaptionClass = '6014555,18,3,2';
                Editable = NPRAttrEditable;
                Visible = NPRAttrVisible03;

                trigger OnValidate()
                begin
                    NPRAttrManagement.SetMasterDataAttributeValue(DATABASE::Customer, 3, "No.", NPRAttrTextArray[3]);
                end;
            }
            field(NPRAttrTextArray_04; NPRAttrTextArray[4])
            {
                ApplicationArea = All;
                CaptionClass = '6014555,18,4,2';
                Editable = NPRAttrEditable;
                Visible = NPRAttrVisible04;

                trigger OnValidate()
                begin
                    NPRAttrManagement.SetMasterDataAttributeValue(DATABASE::Customer, 4, "No.", NPRAttrTextArray[4]);
                end;
            }
            field(NPRAttrTextArray_05; NPRAttrTextArray[5])
            {
                ApplicationArea = All;
                CaptionClass = '6014555,18,5,2';
                Editable = NPRAttrEditable;
                Visible = NPRAttrVisible05;

                trigger OnValidate()
                begin
                    NPRAttrManagement.SetMasterDataAttributeValue(DATABASE::Customer, 5, "No.", NPRAttrTextArray[5]);
                end;
            }
        }
        addafter("Address & Contact")
        {
            group("NPR Magento")
            {
                Caption = 'Magento';
                field("NPR Magento Display Group"; "NPR Magento Display Group")
                {
                    ApplicationArea = All;
                }
                field("NPR Magento Store Code"; "NPR Magento Store Code")
                {
                    ApplicationArea = All;
                    Visible = (MagentoVersion >= 2);
                }
                field("NPR Magento Shipping Group"; "NPR Magento Shipping Group")
                {
                    ApplicationArea = All;
                    Visible = (MagentoVersion >= 2);
                }
                field("NPR Magento Payment Group"; "NPR Magento Payment Group")
                {
                    ApplicationArea = All;
                    Visible = (MagentoVersion >= 2);
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

                    trigger OnValidate()
                    begin
                        NPRAttrManagement.SetMasterDataAttributeValue(DATABASE::Customer, 6, "No.", NPRAttrTextArray[6]);
                    end;
                }
                field(NPRAttrTextArray_07; NPRAttrTextArray[7])
                {
                    ApplicationArea = All;
                    CaptionClass = '6014555,18,7,2';
                    Editable = NPRAttrEditable;
                    Visible = NPRAttrVisible07;

                    trigger OnValidate()
                    begin
                        NPRAttrManagement.SetMasterDataAttributeValue(DATABASE::Customer, 7, "No.", NPRAttrTextArray[7]);
                    end;
                }
                field(NPRAttrTextArray_08; NPRAttrTextArray[8])
                {
                    ApplicationArea = All;
                    CaptionClass = '6014555,18,8,2';
                    Editable = NPRAttrEditable;
                    Visible = NPRAttrVisible08;

                    trigger OnValidate()
                    begin
                        NPRAttrManagement.SetMasterDataAttributeValue(DATABASE::Customer, 8, "No.", NPRAttrTextArray[8]);
                    end;
                }
                field(NPRAttrTextArray_09; NPRAttrTextArray[9])
                {
                    ApplicationArea = All;
                    CaptionClass = '6014555,18,9,2';
                    Editable = NPRAttrEditable;
                    Visible = NPRAttrVisible09;

                    trigger OnValidate()
                    begin
                        NPRAttrManagement.SetMasterDataAttributeValue(DATABASE::Customer, 9, "No.", NPRAttrTextArray[9]);
                    end;
                }
                field(NPRAttrTextArray_10; NPRAttrTextArray[10])
                {
                    ApplicationArea = All;
                    CaptionClass = '6014555,18,10,2';
                    Editable = NPRAttrEditable;
                    Visible = NPRAttrVisible10;

                    trigger OnValidate()
                    begin
                        NPRAttrManagement.SetMasterDataAttributeValue(DATABASE::Customer, 10, "No.", NPRAttrTextArray[10]);
                    end;
                }
            }
        }
        moveafter("VAT Registration No."; "Tax Liable")
        moveafter("VAT Registration No."; "Tax Area Code")
        addafter("Prepayment %")
        {
            field("NPR Document Processing"; "NPR Document Processing")
            {
                ApplicationArea = All;
            }
        }
    }
    actions
    {
        addfirst(Navigation)
        {
            group("NPR Retail Documents")
            {
                Caption = 'Retail Documents';
                action("NPR Selection Contract")
                {
                    Caption = 'Selections contracts';
                    Image = Document;
                    RunObject = Page "NPR Retail Document Header";
                    RunPageLink = "Document Type" = CONST("Selection Contract"),
                                  "Customer No." = FIELD("No."),
                                  "Customer Type" = CONST(Alm);
                    ApplicationArea = All;
                }
            }
            group("NPR Retail")
            {
                Caption = 'Retail';
                action("NPR Brugtvarer")
                {
                    Caption = 'Used Goods';
                    Image = "Action";
                    RunObject = Page "NPR Used Goods Reg. Card";
                    RunPageLink = "Purchased By Customer No." = FIELD("No.");
                    ApplicationArea = All;
                }
                action("NPR ItemLedgerEntries")
                {
                    Caption = 'Item Ledger Entries';
                    Image = ItemLedger;
                    ApplicationArea = All;
                }
                action("NPR AuditRoll")
                {
                    Caption = 'Audit Roll';
                    Image = ListPage;
                    ApplicationArea = All;
                }
                action("NPR AlternativeNo")
                {
                    Caption = 'Alternative No.';
                    Image = "Action";
                    Promoted = true;
                    ApplicationArea = All;
                }
                action("NPR Reparation")
                {
                    Caption = 'Reparation';
                    Image = ServiceZone;
                    RunObject = Page "NPR Customer Repair List";
                    RunPageLink = "Customer No." = FIELD("No."),
                                  "Customer Type" = CONST(Ordinary);
                    ApplicationArea = All;
                }
                action("NPR Member Cards")
                {
                    Caption = 'Member Cards';
                    Image = Card;
                    RunObject = Page "NPR Member Card Issued Cards";
                    RunPageLink = "Customer No" = FIELD("No.");
                    ApplicationArea = All;
                }
                action("NPR PrintShippingLabel")
                {
                    Caption = 'Shipping Label';
                    Image = PrintCheck;
                    ApplicationArea = All;
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
                }
                action("NPR SendAsPDF")
                {
                    Caption = 'Send Statement as PDF';
                    Image = SendEmailPDF;
                    ApplicationArea = All;
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
            }
        }
        addafter("Item &Tracking Entries")
        {
            action("NPR POS Entries")
            {
                Caption = 'POS Entries';
                Image = Entries;
                ApplicationArea = All;
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

                trigger OnAction()
                var
                    GDPRManagement: Codeunit "NPR NP GDPR Management";
                begin
                    TestField("NPR Anonymized", false);
                    if (GDPRManagement.DoAnonymization("No.", ReasonText)) then
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

