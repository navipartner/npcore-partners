page 6059789 "E-mail Setup"
{
    // PN1.00/MH/20140730  NAV-AddOn: PDF2NAV
    //   - Refactored module from the "Mail And Document Handler" Module.
    //   - This Page contains the Setups for PDF2NAV.
    //   - Actions contains functions for Creating Document Specific E-mail Templates.
    // PN1.03/MH/20140814  NAV-AddOn: PDF2NAV
    //   - Added Service Module
    // PN1.04/MH/20140819  NAV-AddOn: PDF2NAV
    //   - Added Audit Roll
    // PN1.08/MHA/20151214  CASE 228859 Added field 55 "Username" and 60 "Password"
    // PN1.09/MHA/20160115  CASE 231503 Added field 52 "Mail Server Port" and 65 "Enable Ssl"

    Caption = 'E-mail Setup';
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = Card;
    SourceTable = "E-mail Setup";
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            group(General)
            {
                field("Mail Server"; "Mail Server")
                {
                    ApplicationArea = All;
                    ShowMandatory = true;
                }
                field("Mail Server Port"; "Mail Server Port")
                {
                    ApplicationArea = All;
                }
                field("Enable Ssl"; "Enable Ssl")
                {
                    ApplicationArea = All;
                }
                field(Username; Username)
                {
                    ApplicationArea = All;
                }
                field(Password; Password)
                {
                    ApplicationArea = All;
                }
                field("From E-mail Address"; "From E-mail Address")
                {
                    ApplicationArea = All;
                    ShowMandatory = true;
                }
                field("From Name"; "From Name")
                {
                    ApplicationArea = All;
                }
            }
            group(NAS)
            {
                field("NAS Folder"; "NAS Folder")
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
            action(CreateEmailTemplates)
            {
                Caption = 'Create E-mail Templates';
                Image = New;

                trigger OnAction()
                var
                    EmailDocumentMgt: Codeunit "E-mail Document Management";
                    EmailTemplateCount: Integer;
                begin
                    //-PN1.08
                    //EmailTemplateCount := EmailMgt.CreateEmailTemplate();
                    EmailTemplateCount := EmailDocumentMgt.CreateEmailTemplates();
                    //+PN1.08
                    if EmailTemplateCount > 0 then
                        Message(StrSubstNo(Text001, EmailTemplateCount));
                end;
            }
            group(CreateEmailTemplateGroup)
            {
                Caption = 'Create E-mail Template';
                action(CreateSalesQuoteEmailTemplate)
                {
                    Caption = 'Sales Quote';
                    Image = NewOrder;

                    trigger OnAction()
                    var
                        EmailDocumentMgt: Codeunit "E-mail Document Management";
                        EmailTemplateCode: Code[20];
                    begin
                        //-PN1.08
                        //EmailTemplateCode := EmailMgt.CreateEmailTemplate(EmailMgt."TemplateType.SalesQuote");
                        EmailTemplateCode := EmailDocumentMgt.CreateEmailTemplate(EmailDocumentMgt."TemplateType.SalesQuote");
                        //+PN1.08
                        Message(StrSubstNo(Text002, EmailTemplateCode));
                    end;
                }
                action(CreateSalesOrderEmailTemplate)
                {
                    Caption = 'Sales Order';
                    Image = NewOrder;

                    trigger OnAction()
                    var
                        EmailDocumentMgt: Codeunit "E-mail Document Management";
                        EmailTemplateCode: Code[20];
                    begin
                        //-PN1.08
                        //EmailTemplateCode := EmailMgt.CreateEmailTemplate(EmailMgt."TemplateType.SalesOrder");
                        EmailTemplateCode := EmailDocumentMgt.CreateEmailTemplate(EmailDocumentMgt."TemplateType.SalesOrder");
                        Message(StrSubstNo(Text002, EmailTemplateCode));
                        //+PN1.08
                    end;
                }
                action(CreateSalesShptEmailTemplate)
                {
                    Caption = 'Sales Shipment';
                    Image = NewOrder;

                    trigger OnAction()
                    var
                        EmailDocumentMgt: Codeunit "E-mail Document Management";
                        EmailTemplateCode: Code[20];
                    begin
                        //-PN1.08
                        //EmailTemplateCode := EmailMgt.CreateEmailTemplate(EmailMgt."TemplateType.SalesShpt");
                        EmailTemplateCode := EmailDocumentMgt.CreateEmailTemplate(EmailDocumentMgt."TemplateType.SalesShpt");
                        Message(StrSubstNo(Text002, EmailTemplateCode));
                        //+PN1.08
                    end;
                }
                action(CreateSalesInvEmailTemplate)
                {
                    Caption = 'Sales Invoice';
                    Image = NewOrder;

                    trigger OnAction()
                    var
                        EmailDocumentMgt: Codeunit "E-mail Document Management";
                        EmailTemplateCode: Code[20];
                    begin
                        //-PN1.08
                        //EmailTemplateCode := EmailMgt.CreateEmailTemplate(EmailMgt."TemplateType.SalesInv");
                        EmailTemplateCode := EmailDocumentMgt.CreateEmailTemplate(EmailDocumentMgt."TemplateType.SalesInv");
                        Message(StrSubstNo(Text002, EmailTemplateCode));
                        //+PN1.08
                    end;
                }
                action(CreateSalesCrMemoEmailTemplate)
                {
                    Caption = 'Sales Credit Memo';
                    Image = NewOrder;

                    trigger OnAction()
                    var
                        EmailDocumentMgt: Codeunit "E-mail Document Management";
                        EmailTemplateCode: Code[20];
                    begin
                        //-PN1.08
                        //EmailTemplateCode := EmailMgt.CreateEmailTemplate(EmailMgt."TemplateType.SalesCrMemo");
                        EmailTemplateCode := EmailDocumentMgt.CreateEmailTemplate(EmailDocumentMgt."TemplateType.SalesCrMemo");
                        Message(StrSubstNo(Text002, EmailTemplateCode));
                        //+PN1.08
                    end;
                }
                action(CreatePurchQuoteEmailTemplate)
                {
                    Caption = 'Purchase Quote';
                    Image = NewOrder;

                    trigger OnAction()
                    var
                        EmailDocumentMgt: Codeunit "E-mail Document Management";
                        EmailTemplateCode: Code[20];
                    begin
                        //-PN1.08
                        //EmailTemplateCode := EmailMgt.CreateEmailTemplate(EmailMgt."TemplateType.PurchQuote");
                        EmailTemplateCode := EmailDocumentMgt.CreateEmailTemplate(EmailDocumentMgt."TemplateType.PurchQuote");
                        Message(StrSubstNo(Text002, EmailTemplateCode));
                        //+PN1.08
                    end;
                }
                action(CreatePurchOrderEmailTemplate)
                {
                    Caption = 'Purchase Order';
                    Image = NewOrder;

                    trigger OnAction()
                    var
                        EmailDocumentMgt: Codeunit "E-mail Document Management";
                        EmailTemplateCode: Code[20];
                    begin
                        //-PN1.08
                        //EmailTemplateCode := EmailMgt.CreateEmailTemplate(EmailMgt."TemplateType.PurchOrder");
                        EmailTemplateCode := EmailDocumentMgt.CreateEmailTemplate(EmailDocumentMgt."TemplateType.PurchOrder");
                        Message(StrSubstNo(Text002, EmailTemplateCode));
                        //+PN1.08
                    end;
                }
                action(CreatePurchRcptEmailTemplate)
                {
                    Caption = 'Purchase Receipt';
                    Image = NewOrder;

                    trigger OnAction()
                    var
                        EmailDocumentMgt: Codeunit "E-mail Document Management";
                        EmailTemplateCode: Code[20];
                    begin
                        //-PN1.08
                        //EmailTemplateCode := EmailMgt.CreateEmailTemplate(EmailMgt."TemplateType.PurchRcpt");
                        EmailTemplateCode := EmailDocumentMgt.CreateEmailTemplate(EmailDocumentMgt."TemplateType.PurchRcpt");
                        Message(StrSubstNo(Text002, EmailTemplateCode));
                        //+PN1.08
                    end;
                }
                action(CreatePurchInvEmailTemplate)
                {
                    Caption = 'Purchase Invoice';
                    Image = NewOrder;

                    trigger OnAction()
                    var
                        EmailDocumentMgt: Codeunit "E-mail Document Management";
                        EmailTemplateCode: Code[20];
                    begin
                        //-PN1.08
                        //EmailTemplateCode := EmailMgt.CreateEmailTemplate(EmailMgt."TemplateType.PurchInv");
                        EmailTemplateCode := EmailDocumentMgt.CreateEmailTemplate(EmailDocumentMgt."TemplateType.PurchInv");
                        Message(StrSubstNo(Text002, EmailTemplateCode));
                        //+PN1.08
                    end;
                }
                action(CreatePurchCrMemoEmailTemplate)
                {
                    Caption = 'Purchase Credit Memo';
                    Image = NewOrder;

                    trigger OnAction()
                    var
                        EmailDocumentMgt: Codeunit "E-mail Document Management";
                        EmailTemplateCode: Code[20];
                    begin
                        //-PN1.08
                        //EmailTemplateCode := EmailMgt.CreateEmailTemplate(EmailMgt."TemplateType.PurchCrMemo");
                        EmailTemplateCode := EmailDocumentMgt.CreateEmailTemplate(EmailDocumentMgt."TemplateType.PurchCrMemo");
                        Message(StrSubstNo(Text002, EmailTemplateCode));
                        //+PN1.08
                    end;
                }
                action(CreateReminderEmailTemplate)
                {
                    Caption = 'Reminder';
                    Image = NewOrder;

                    trigger OnAction()
                    var
                        EmailDocumentMgt: Codeunit "E-mail Document Management";
                        EmailTemplateCode: Code[20];
                    begin
                        //-PN1.08
                        //EmailTemplateCode := EmailMgt.CreateEmailTemplate(EmailMgt."TemplateType.Reminder");
                        EmailTemplateCode := EmailDocumentMgt.CreateEmailTemplate(EmailDocumentMgt."TemplateType.Reminder");
                        Message(StrSubstNo(Text002, EmailTemplateCode));
                        //+PN1.08
                    end;
                }
                action(CreateChargeMemoEmailTemplate)
                {
                    Caption = 'Charge Memo';
                    Image = NewOrder;

                    trigger OnAction()
                    var
                        EmailDocumentMgt: Codeunit "E-mail Document Management";
                        EmailTemplateCode: Code[20];
                    begin
                        //-PN1.08
                        //EmailTemplateCode := EmailMgt.CreateEmailTemplate(EmailMgt."TemplateType.ChargeMemo");
                        EmailTemplateCode := EmailDocumentMgt.CreateEmailTemplate(EmailDocumentMgt."TemplateType.ChargeMemo");
                        Message(StrSubstNo(Text002, EmailTemplateCode));
                        //+PN1.08
                    end;
                }
                action(CreateStatementEmailTemplate)
                {
                    Caption = 'Statement';
                    Image = NewOrder;

                    trigger OnAction()
                    var
                        EmailDocumentMgt: Codeunit "E-mail Document Management";
                        EmailTemplateCode: Code[20];
                    begin
                        //-PN1.08
                        //EmailTemplateCode := EmailMgt.CreateEmailTemplate(EmailMgt."TemplateType.Statement");
                        EmailTemplateCode := EmailDocumentMgt.CreateEmailTemplate(EmailDocumentMgt."TemplateType.Statement");
                        Message(StrSubstNo(Text002, EmailTemplateCode));
                        //+PN1.08
                    end;
                }
                action(CreateServQuoteEmailTemplate)
                {
                    Caption = 'Service Quote';
                    Image = NewOrder;

                    trigger OnAction()
                    var
                        EmailDocumentMgt: Codeunit "E-mail Document Management";
                        EmailTemplateCode: Code[20];
                    begin
                        //-PN1.08
                        //EmailTemplateCode := EmailMgt.CreateEmailTemplate(EmailMgt."TemplateType.ServQuote");
                        EmailTemplateCode := EmailDocumentMgt.CreateEmailTemplate(EmailDocumentMgt."TemplateType.ServQuote");
                        Message(StrSubstNo(Text002, EmailTemplateCode));
                        //+PN1.08
                    end;
                }
                action(CreateServOrderEmailTemplate)
                {
                    Caption = 'Service Order';
                    Image = NewOrder;

                    trigger OnAction()
                    var
                        EmailDocumentMgt: Codeunit "E-mail Document Management";
                        EmailTemplateCode: Code[20];
                    begin
                        //-PN1.08
                        //EmailTemplateCode := EmailMgt.CreateEmailTemplate(EmailMgt."TemplateType.ServOrder");
                        EmailTemplateCode := EmailDocumentMgt.CreateEmailTemplate(EmailDocumentMgt."TemplateType.ServOrder");
                        Message(StrSubstNo(Text002, EmailTemplateCode));
                        //+PN1.08
                    end;
                }
                action(CreateServShptEmailTemplate)
                {
                    Caption = 'Service Shipment';
                    Image = NewOrder;

                    trigger OnAction()
                    var
                        EmailDocumentMgt: Codeunit "E-mail Document Management";
                        EmailTemplateCode: Code[20];
                    begin
                        //-PN1.08
                        //EmailTemplateCode := EmailMgt.CreateEmailTemplate(EmailMgt."TemplateType.ServShpt");
                        EmailTemplateCode := EmailDocumentMgt.CreateEmailTemplate(EmailDocumentMgt."TemplateType.ServShpt");
                        Message(StrSubstNo(Text002, EmailTemplateCode));
                        //+PN1.08
                    end;
                }
                action(CreateServInvEmailTemplate)
                {
                    Caption = 'Service Invoice';
                    Image = NewOrder;

                    trigger OnAction()
                    var
                        EmailDocumentMgt: Codeunit "E-mail Document Management";
                        EmailTemplateCode: Code[20];
                    begin
                        //-PN1.08
                        //EmailTemplateCode := EmailMgt.CreateEmailTemplate(EmailMgt."TemplateType.ServInv");
                        EmailTemplateCode := EmailDocumentMgt.CreateEmailTemplate(EmailDocumentMgt."TemplateType.ServInv");
                        Message(StrSubstNo(Text002, EmailTemplateCode));
                        //+PN1.08
                    end;
                }
                action(CreateAuditRollEmailTemplate)
                {
                    Caption = 'Sales Ticket';
                    Image = NewOrder;
                    Visible = AuditRollExists;

                    trigger OnAction()
                    var
                        EmailDocumentMgt: Codeunit "E-mail Document Management";
                        EmailTemplateCode: Code[20];
                    begin
                        //-PN1.08
                        //EmailTemplateCode := EmailMgt.CreateEmailTemplate(EmailMgt."TemplateType.AuditRoll");
                        EmailTemplateCode := EmailDocumentMgt.CreateEmailTemplate(EmailDocumentMgt."TemplateType.AuditRoll");
                        Message(StrSubstNo(Text002, EmailTemplateCode));
                        //+PN1.08
                    end;
                }
                action(CreateCreditVoucherEmailTemplate)
                {
                    Caption = 'Credit Voucher';
                    Image = NewOrder;
                    Visible = CreditVoucherExists;

                    trigger OnAction()
                    var
                        EmailDocumentMgt: Codeunit "E-mail Document Management";
                        EmailTemplateCode: Code[20];
                    begin
                        //-PN1.08
                        EmailTemplateCode := EmailDocumentMgt.CreateEmailTemplate(EmailDocumentMgt."TemplateType.CreditVoucher");
                        Message(StrSubstNo(Text002, EmailTemplateCode));
                        //+PN1.08
                    end;
                }
                action(CreateGiftVoucherEmailTemplate)
                {
                    Caption = 'Gift Voucher';
                    Image = NewOrder;
                    Visible = GiftVoucherExists;

                    trigger OnAction()
                    var
                        EmailDocumentMgt: Codeunit "E-mail Document Management";
                        EmailTemplateCode: Code[20];
                    begin
                        //-PN1.08
                        EmailTemplateCode := EmailDocumentMgt.CreateEmailTemplate(EmailDocumentMgt."TemplateType.GiftVoucher");
                        Message(StrSubstNo(Text002, EmailTemplateCode));
                        //+PN1.08
                    end;
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        Reset;
        if not Get then
            Insert;

        //-PN1.08
        SetVisible();
        //+PN1.08
    end;

    var
        Text001: Label '%1 E-mail Templates Created';
        Text002: Label 'E-mail Template %1 Created';
        AuditRollExists: Boolean;
        CreditVoucherExists: Boolean;
        GiftVoucherExists: Boolean;

    local procedure SetVisible()
    var
        EmailRetailMgt: Codeunit "E-mail Retail Management";
    begin
        //-PN1.08
        AuditRollExists := EmailRetailMgt.AuditRollExists();
        CreditVoucherExists := EmailRetailMgt.CreditVoucherExists();
        GiftVoucherExists := EmailRetailMgt.GiftVoucherExists();
        //+PN1.08
    end;
}

