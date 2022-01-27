page 6059789 "NPR E-mail Setup"
{
    Extensible = False;
    Caption = 'E-mail Setup';
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = Card;
    SourceTable = "NPR E-mail Setup";
    UsageCategory = Administration;
    ApplicationArea = NPRRetail;


    layout
    {
        area(content)
        {
            group(General)
            {
                field("Mail Server"; Rec."Mail Server")
                {

                    ShowMandatory = true;
                    ToolTip = 'Specifies the value of the Mail Server field';
                    ApplicationArea = NPRRetail;
                }
                field("Mail Server Port"; Rec."Mail Server Port")
                {

                    ToolTip = 'Specifies the value of the Mail Server Port field';
                    ApplicationArea = NPRRetail;
                }
                field("Enable Ssl"; Rec."Enable Ssl")
                {

                    ToolTip = 'Specifies the value of the Enable Ssl field';
                    ApplicationArea = NPRRetail;
                }
                field(Username; Rec.Username)
                {

                    ToolTip = 'Specifies the value of the Username field';
                    ApplicationArea = NPRRetail;
                }
                field(Password; Rec.Password)
                {

                    ToolTip = 'Specifies the value of the Password field';
                    ApplicationArea = NPRRetail;
                }
                field("From E-mail Address"; Rec."From E-mail Address")
                {

                    ShowMandatory = true;
                    ToolTip = 'Specifies the value of the From E-mail Address field';
                    ApplicationArea = NPRRetail;
                }
                field("From Name"; Rec."From Name")
                {

                    ToolTip = 'Specifies the value of the From Name field';
                    ApplicationArea = NPRRetail;
                }
            }
            group(NAS)
            {
                field("NAS Folder"; Rec."NAS Folder")
                {

                    ToolTip = 'Specifies the value of the NAS Folder field';
                    ApplicationArea = NPRRetail;
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

                ToolTip = 'Executes the Create E-mail Templates action';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                var
                    EmailDocumentMgt: Codeunit "NPR E-mail Doc. Mgt.";
                    EmailTemplateCount: Integer;
                begin
                    EmailTemplateCount := EmailDocumentMgt.CreateEmailTemplates();
                    if EmailTemplateCount > 0 then
                        Message(StrSubstNo(NoOfEmailTemplatesCreatedMsg, EmailTemplateCount));
                end;
            }
            group(CreateEmailTemplateGroup)
            {
                Caption = 'Create E-mail Template';
                action(CreateSalesQuoteEmailTemplate)
                {
                    Caption = 'Sales Quote';
                    Image = NewOrder;

                    ToolTip = 'Executes the Sales Quote action';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    var
                        EmailDocumentMgt: Codeunit "NPR E-mail Doc. Mgt.";
                        EmailTemplateCode: Code[20];
                    begin
                        EmailTemplateCode := EmailDocumentMgt.CreateEmailTemplate(EmailDocumentMgt."TemplateType.SalesQuote"());
                        Message(StrSubstNo(EMailTemplateCreatedMsg, EmailTemplateCode));
                    end;
                }
                action(CreateSalesOrderEmailTemplate)
                {
                    Caption = 'Sales Order';
                    Image = NewOrder;

                    ToolTip = 'Executes the Sales Order action';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    var
                        EmailDocumentMgt: Codeunit "NPR E-mail Doc. Mgt.";
                        EmailTemplateCode: Code[20];
                    begin
                        EmailTemplateCode := EmailDocumentMgt.CreateEmailTemplate(EmailDocumentMgt."TemplateType.SalesOrder"());
                        Message(StrSubstNo(EMailTemplateCreatedMsg, EmailTemplateCode));
                    end;
                }
                action(CreateSalesShptEmailTemplate)
                {
                    Caption = 'Sales Shipment';
                    Image = NewOrder;

                    ToolTip = 'Executes the Sales Shipment action';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    var
                        EmailDocumentMgt: Codeunit "NPR E-mail Doc. Mgt.";
                        EmailTemplateCode: Code[20];
                    begin
                        EmailTemplateCode := EmailDocumentMgt.CreateEmailTemplate(EmailDocumentMgt."TemplateType.SalesShpt"());
                        Message(StrSubstNo(EMailTemplateCreatedMsg, EmailTemplateCode));
                    end;
                }
                action(CreateSalesInvEmailTemplate)
                {
                    Caption = 'Sales Invoice';
                    Image = NewOrder;

                    ToolTip = 'Executes the Sales Invoice action';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    var
                        EmailDocumentMgt: Codeunit "NPR E-mail Doc. Mgt.";
                        EmailTemplateCode: Code[20];
                    begin
                        EmailTemplateCode := EmailDocumentMgt.CreateEmailTemplate(EmailDocumentMgt."TemplateType.SalesInv"());
                        Message(StrSubstNo(EMailTemplateCreatedMsg, EmailTemplateCode));
                    end;
                }
                action(CreateSalesCrMemoEmailTemplate)
                {
                    Caption = 'Sales Credit Memo';
                    Image = NewOrder;

                    ToolTip = 'Executes the Sales Credit Memo action';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    var
                        EmailDocumentMgt: Codeunit "NPR E-mail Doc. Mgt.";
                        EmailTemplateCode: Code[20];
                    begin
                        EmailTemplateCode := EmailDocumentMgt.CreateEmailTemplate(EmailDocumentMgt."TemplateType.SalesCrMemo"());
                        Message(StrSubstNo(EMailTemplateCreatedMsg, EmailTemplateCode));
                    end;
                }
                action(CreatePurchQuoteEmailTemplate)
                {
                    Caption = 'Purchase Quote';
                    Image = NewOrder;

                    ToolTip = 'Executes the Purchase Quote action';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    var
                        EmailDocumentMgt: Codeunit "NPR E-mail Doc. Mgt.";
                        EmailTemplateCode: Code[20];
                    begin
                        EmailTemplateCode := EmailDocumentMgt.CreateEmailTemplate(EmailDocumentMgt."TemplateType.PurchQuote"());
                        Message(StrSubstNo(EMailTemplateCreatedMsg, EmailTemplateCode));
                    end;
                }
                action(CreatePurchOrderEmailTemplate)
                {
                    Caption = 'Purchase Order';
                    Image = NewOrder;

                    ToolTip = 'Executes the Purchase Order action';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    var
                        EmailDocumentMgt: Codeunit "NPR E-mail Doc. Mgt.";
                        EmailTemplateCode: Code[20];
                    begin
                        EmailTemplateCode := EmailDocumentMgt.CreateEmailTemplate(EmailDocumentMgt."TemplateType.PurchOrder"());
                        Message(StrSubstNo(EMailTemplateCreatedMsg, EmailTemplateCode));
                    end;
                }
                action(CreatePurchRcptEmailTemplate)
                {
                    Caption = 'Purchase Receipt';
                    Image = NewOrder;

                    ToolTip = 'Executes the Purchase Receipt action';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    var
                        EmailDocumentMgt: Codeunit "NPR E-mail Doc. Mgt.";
                        EmailTemplateCode: Code[20];
                    begin
                        EmailTemplateCode := EmailDocumentMgt.CreateEmailTemplate(EmailDocumentMgt."TemplateType.PurchRcpt"());
                        Message(StrSubstNo(EMailTemplateCreatedMsg, EmailTemplateCode));
                    end;
                }
                action(CreatePurchInvEmailTemplate)
                {
                    Caption = 'Purchase Invoice';
                    Image = NewOrder;

                    ToolTip = 'Executes the Purchase Invoice action';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    var
                        EmailDocumentMgt: Codeunit "NPR E-mail Doc. Mgt.";
                        EmailTemplateCode: Code[20];
                    begin
                        EmailTemplateCode := EmailDocumentMgt.CreateEmailTemplate(EmailDocumentMgt."TemplateType.PurchInv"());
                        Message(StrSubstNo(EMailTemplateCreatedMsg, EmailTemplateCode));
                    end;
                }
                action(CreatePurchCrMemoEmailTemplate)
                {
                    Caption = 'Purchase Credit Memo';
                    Image = NewOrder;

                    ToolTip = 'Executes the Purchase Credit Memo action';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    var
                        EmailDocumentMgt: Codeunit "NPR E-mail Doc. Mgt.";
                        EmailTemplateCode: Code[20];
                    begin
                        EmailTemplateCode := EmailDocumentMgt.CreateEmailTemplate(EmailDocumentMgt."TemplateType.PurchCrMemo"());
                        Message(StrSubstNo(EMailTemplateCreatedMsg, EmailTemplateCode));
                    end;
                }
                action(CreateReminderEmailTemplate)
                {
                    Caption = 'Reminder';
                    Image = NewOrder;

                    ToolTip = 'Executes the Reminder action';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    var
                        EmailDocumentMgt: Codeunit "NPR E-mail Doc. Mgt.";
                        EmailTemplateCode: Code[20];
                    begin
                        EmailTemplateCode := EmailDocumentMgt.CreateEmailTemplate(EmailDocumentMgt."TemplateType.Reminder"());
                        Message(StrSubstNo(EMailTemplateCreatedMsg, EmailTemplateCode));
                    end;
                }
                action(CreateChargeMemoEmailTemplate)
                {
                    Caption = 'Charge Memo';
                    Image = NewOrder;

                    ToolTip = 'Executes the Charge Memo action';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    var
                        EmailDocumentMgt: Codeunit "NPR E-mail Doc. Mgt.";
                        EmailTemplateCode: Code[20];
                    begin
                        EmailTemplateCode := EmailDocumentMgt.CreateEmailTemplate(EmailDocumentMgt."TemplateType.ChargeMemo"());
                        Message(StrSubstNo(EMailTemplateCreatedMsg, EmailTemplateCode));
                    end;
                }
                action(CreateStatementEmailTemplate)
                {
                    Caption = 'Statement';
                    Image = NewOrder;

                    ToolTip = 'Executes the Statement action';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    var
                        EmailDocumentMgt: Codeunit "NPR E-mail Doc. Mgt.";
                        EmailTemplateCode: Code[20];
                    begin
                        EmailTemplateCode := EmailDocumentMgt.CreateEmailTemplate(EmailDocumentMgt."TemplateType.Statement"());
                        Message(StrSubstNo(EMailTemplateCreatedMsg, EmailTemplateCode));
                    end;
                }
                action(CreateServQuoteEmailTemplate)
                {
                    Caption = 'Service Quote';
                    Image = NewOrder;

                    ToolTip = 'Executes the Service Quote action';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    var
                        EmailDocumentMgt: Codeunit "NPR E-mail Doc. Mgt.";
                        EmailTemplateCode: Code[20];
                    begin
                        EmailTemplateCode := EmailDocumentMgt.CreateEmailTemplate(EmailDocumentMgt."TemplateType.ServQuote"());
                        Message(StrSubstNo(EMailTemplateCreatedMsg, EmailTemplateCode));
                    end;
                }
                action(CreateServOrderEmailTemplate)
                {
                    Caption = 'Service Order';
                    Image = NewOrder;

                    ToolTip = 'Executes the Service Order action';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    var
                        EmailDocumentMgt: Codeunit "NPR E-mail Doc. Mgt.";
                        EmailTemplateCode: Code[20];
                    begin
                        EmailTemplateCode := EmailDocumentMgt.CreateEmailTemplate(EmailDocumentMgt."TemplateType.ServOrder"());
                        Message(StrSubstNo(EMailTemplateCreatedMsg, EmailTemplateCode));
                    end;
                }
                action(CreateServShptEmailTemplate)
                {
                    Caption = 'Service Shipment';
                    Image = NewOrder;

                    ToolTip = 'Executes the Service Shipment action';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    var
                        EmailDocumentMgt: Codeunit "NPR E-mail Doc. Mgt.";
                        EmailTemplateCode: Code[20];
                    begin
                        EmailTemplateCode := EmailDocumentMgt.CreateEmailTemplate(EmailDocumentMgt."TemplateType.ServShpt"());
                        Message(StrSubstNo(EMailTemplateCreatedMsg, EmailTemplateCode));
                    end;
                }
                action(CreateServInvEmailTemplate)
                {
                    Caption = 'Service Invoice';
                    Image = NewOrder;

                    ToolTip = 'Executes the Service Invoice action';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    var
                        EmailDocumentMgt: Codeunit "NPR E-mail Doc. Mgt.";
                        EmailTemplateCode: Code[20];
                    begin
                        EmailTemplateCode := EmailDocumentMgt.CreateEmailTemplate(EmailDocumentMgt."TemplateType.ServInv"());
                        Message(StrSubstNo(EMailTemplateCreatedMsg, EmailTemplateCode));
                    end;
                }
                action(CreateAuditRollEmailTemplate)
                {
                    Caption = 'Sales Ticket';
                    Image = NewOrder;

                    ToolTip = 'Executes the Sales Ticket action';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    var
                        EmailDocumentMgt: Codeunit "NPR E-mail Doc. Mgt.";
                        EmailTemplateCode: Code[20];
                    begin
                        EmailTemplateCode := EmailDocumentMgt.CreateEmailTemplate(EmailDocumentMgt."TemplateType.POSEntry"());
                        Message(StrSubstNo(EMailTemplateCreatedMsg, EmailTemplateCode));
                    end;
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        Rec.Reset();
        if not Rec.Get() then
            Rec.Insert();


    end;

    var
        NoOfEmailTemplatesCreatedMsg: Label '%1 E-mail Templates Created', Comment = '%1=EmailDocumentMgt.CreateEmailTemplates()';
        EMailTemplateCreatedMsg: Label 'E-mail Template %1 Created', Comment = '%1=EmailDocumentMgt.CreateEmailTemplate(EmailDocumentMgt."TemplateType....")';

}

