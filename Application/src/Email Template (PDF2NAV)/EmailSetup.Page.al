page 6059789 "NPR E-mail Setup"
{
    Caption = 'E-mail Setup';
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = Card;
    SourceTable = "NPR E-mail Setup";
    UsageCategory = Administration;
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            group(General)
            {
                field("Mail Server"; Rec."Mail Server")
                {
                    ApplicationArea = All;
                    ShowMandatory = true;
                    ToolTip = 'Specifies the value of the Mail Server field';
                }
                field("Mail Server Port"; Rec."Mail Server Port")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Mail Server Port field';
                }
                field("Enable Ssl"; Rec."Enable Ssl")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Enable Ssl field';
                }
                field(Username; Rec.Username)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Username field';
                }
                field(Password; Rec.Password)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Password field';
                }
                field("From E-mail Address"; Rec."From E-mail Address")
                {
                    ApplicationArea = All;
                    ShowMandatory = true;
                    ToolTip = 'Specifies the value of the From E-mail Address field';
                }
                field("From Name"; Rec."From Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the From Name field';
                }
            }
            group(NAS)
            {
                field("NAS Folder"; Rec."NAS Folder")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the NAS Folder field';
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
                ApplicationArea = All;
                ToolTip = 'Executes the Create E-mail Templates action';

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
                    ApplicationArea = All;
                    ToolTip = 'Executes the Sales Quote action';

                    trigger OnAction()
                    var
                        EmailDocumentMgt: Codeunit "NPR E-mail Doc. Mgt.";
                        EmailTemplateCode: Code[20];
                    begin
                        EmailTemplateCode := EmailDocumentMgt.CreateEmailTemplate(EmailDocumentMgt."TemplateType.SalesQuote");
                        Message(StrSubstNo(EMailTemplateCreatedMsg, EmailTemplateCode));
                    end;
                }
                action(CreateSalesOrderEmailTemplate)
                {
                    Caption = 'Sales Order';
                    Image = NewOrder;
                    ApplicationArea = All;
                    ToolTip = 'Executes the Sales Order action';

                    trigger OnAction()
                    var
                        EmailDocumentMgt: Codeunit "NPR E-mail Doc. Mgt.";
                        EmailTemplateCode: Code[20];
                    begin
                        EmailTemplateCode := EmailDocumentMgt.CreateEmailTemplate(EmailDocumentMgt."TemplateType.SalesOrder");
                        Message(StrSubstNo(EMailTemplateCreatedMsg, EmailTemplateCode));
                    end;
                }
                action(CreateSalesShptEmailTemplate)
                {
                    Caption = 'Sales Shipment';
                    Image = NewOrder;
                    ApplicationArea = All;
                    ToolTip = 'Executes the Sales Shipment action';

                    trigger OnAction()
                    var
                        EmailDocumentMgt: Codeunit "NPR E-mail Doc. Mgt.";
                        EmailTemplateCode: Code[20];
                    begin
                        EmailTemplateCode := EmailDocumentMgt.CreateEmailTemplate(EmailDocumentMgt."TemplateType.SalesShpt");
                        Message(StrSubstNo(EMailTemplateCreatedMsg, EmailTemplateCode));
                    end;
                }
                action(CreateSalesInvEmailTemplate)
                {
                    Caption = 'Sales Invoice';
                    Image = NewOrder;
                    ApplicationArea = All;
                    ToolTip = 'Executes the Sales Invoice action';

                    trigger OnAction()
                    var
                        EmailDocumentMgt: Codeunit "NPR E-mail Doc. Mgt.";
                        EmailTemplateCode: Code[20];
                    begin
                        EmailTemplateCode := EmailDocumentMgt.CreateEmailTemplate(EmailDocumentMgt."TemplateType.SalesInv");
                        Message(StrSubstNo(EMailTemplateCreatedMsg, EmailTemplateCode));
                    end;
                }
                action(CreateSalesCrMemoEmailTemplate)
                {
                    Caption = 'Sales Credit Memo';
                    Image = NewOrder;
                    ApplicationArea = All;
                    ToolTip = 'Executes the Sales Credit Memo action';

                    trigger OnAction()
                    var
                        EmailDocumentMgt: Codeunit "NPR E-mail Doc. Mgt.";
                        EmailTemplateCode: Code[20];
                    begin
                        EmailTemplateCode := EmailDocumentMgt.CreateEmailTemplate(EmailDocumentMgt."TemplateType.SalesCrMemo");
                        Message(StrSubstNo(EMailTemplateCreatedMsg, EmailTemplateCode));
                    end;
                }
                action(CreatePurchQuoteEmailTemplate)
                {
                    Caption = 'Purchase Quote';
                    Image = NewOrder;
                    ApplicationArea = All;
                    ToolTip = 'Executes the Purchase Quote action';

                    trigger OnAction()
                    var
                        EmailDocumentMgt: Codeunit "NPR E-mail Doc. Mgt.";
                        EmailTemplateCode: Code[20];
                    begin
                        EmailTemplateCode := EmailDocumentMgt.CreateEmailTemplate(EmailDocumentMgt."TemplateType.PurchQuote");
                        Message(StrSubstNo(EMailTemplateCreatedMsg, EmailTemplateCode));
                    end;
                }
                action(CreatePurchOrderEmailTemplate)
                {
                    Caption = 'Purchase Order';
                    Image = NewOrder;
                    ApplicationArea = All;
                    ToolTip = 'Executes the Purchase Order action';

                    trigger OnAction()
                    var
                        EmailDocumentMgt: Codeunit "NPR E-mail Doc. Mgt.";
                        EmailTemplateCode: Code[20];
                    begin
                        EmailTemplateCode := EmailDocumentMgt.CreateEmailTemplate(EmailDocumentMgt."TemplateType.PurchOrder");
                        Message(StrSubstNo(EMailTemplateCreatedMsg, EmailTemplateCode));
                    end;
                }
                action(CreatePurchRcptEmailTemplate)
                {
                    Caption = 'Purchase Receipt';
                    Image = NewOrder;
                    ApplicationArea = All;
                    ToolTip = 'Executes the Purchase Receipt action';

                    trigger OnAction()
                    var
                        EmailDocumentMgt: Codeunit "NPR E-mail Doc. Mgt.";
                        EmailTemplateCode: Code[20];
                    begin
                        EmailTemplateCode := EmailDocumentMgt.CreateEmailTemplate(EmailDocumentMgt."TemplateType.PurchRcpt");
                        Message(StrSubstNo(EMailTemplateCreatedMsg, EmailTemplateCode));
                    end;
                }
                action(CreatePurchInvEmailTemplate)
                {
                    Caption = 'Purchase Invoice';
                    Image = NewOrder;
                    ApplicationArea = All;
                    ToolTip = 'Executes the Purchase Invoice action';

                    trigger OnAction()
                    var
                        EmailDocumentMgt: Codeunit "NPR E-mail Doc. Mgt.";
                        EmailTemplateCode: Code[20];
                    begin
                        EmailTemplateCode := EmailDocumentMgt.CreateEmailTemplate(EmailDocumentMgt."TemplateType.PurchInv");
                        Message(StrSubstNo(EMailTemplateCreatedMsg, EmailTemplateCode));
                    end;
                }
                action(CreatePurchCrMemoEmailTemplate)
                {
                    Caption = 'Purchase Credit Memo';
                    Image = NewOrder;
                    ApplicationArea = All;
                    ToolTip = 'Executes the Purchase Credit Memo action';

                    trigger OnAction()
                    var
                        EmailDocumentMgt: Codeunit "NPR E-mail Doc. Mgt.";
                        EmailTemplateCode: Code[20];
                    begin
                        EmailTemplateCode := EmailDocumentMgt.CreateEmailTemplate(EmailDocumentMgt."TemplateType.PurchCrMemo");
                        Message(StrSubstNo(EMailTemplateCreatedMsg, EmailTemplateCode));
                    end;
                }
                action(CreateReminderEmailTemplate)
                {
                    Caption = 'Reminder';
                    Image = NewOrder;
                    ApplicationArea = All;
                    ToolTip = 'Executes the Reminder action';

                    trigger OnAction()
                    var
                        EmailDocumentMgt: Codeunit "NPR E-mail Doc. Mgt.";
                        EmailTemplateCode: Code[20];
                    begin
                        EmailTemplateCode := EmailDocumentMgt.CreateEmailTemplate(EmailDocumentMgt."TemplateType.Reminder");
                        Message(StrSubstNo(EMailTemplateCreatedMsg, EmailTemplateCode));
                    end;
                }
                action(CreateChargeMemoEmailTemplate)
                {
                    Caption = 'Charge Memo';
                    Image = NewOrder;
                    ApplicationArea = All;
                    ToolTip = 'Executes the Charge Memo action';

                    trigger OnAction()
                    var
                        EmailDocumentMgt: Codeunit "NPR E-mail Doc. Mgt.";
                        EmailTemplateCode: Code[20];
                    begin
                        EmailTemplateCode := EmailDocumentMgt.CreateEmailTemplate(EmailDocumentMgt."TemplateType.ChargeMemo");
                        Message(StrSubstNo(EMailTemplateCreatedMsg, EmailTemplateCode));
                    end;
                }
                action(CreateStatementEmailTemplate)
                {
                    Caption = 'Statement';
                    Image = NewOrder;
                    ApplicationArea = All;
                    ToolTip = 'Executes the Statement action';

                    trigger OnAction()
                    var
                        EmailDocumentMgt: Codeunit "NPR E-mail Doc. Mgt.";
                        EmailTemplateCode: Code[20];
                    begin
                        EmailTemplateCode := EmailDocumentMgt.CreateEmailTemplate(EmailDocumentMgt."TemplateType.Statement");
                        Message(StrSubstNo(EMailTemplateCreatedMsg, EmailTemplateCode));
                    end;
                }
                action(CreateServQuoteEmailTemplate)
                {
                    Caption = 'Service Quote';
                    Image = NewOrder;
                    ApplicationArea = All;
                    ToolTip = 'Executes the Service Quote action';

                    trigger OnAction()
                    var
                        EmailDocumentMgt: Codeunit "NPR E-mail Doc. Mgt.";
                        EmailTemplateCode: Code[20];
                    begin
                        EmailTemplateCode := EmailDocumentMgt.CreateEmailTemplate(EmailDocumentMgt."TemplateType.ServQuote");
                        Message(StrSubstNo(EMailTemplateCreatedMsg, EmailTemplateCode));
                    end;
                }
                action(CreateServOrderEmailTemplate)
                {
                    Caption = 'Service Order';
                    Image = NewOrder;
                    ApplicationArea = All;
                    ToolTip = 'Executes the Service Order action';

                    trigger OnAction()
                    var
                        EmailDocumentMgt: Codeunit "NPR E-mail Doc. Mgt.";
                        EmailTemplateCode: Code[20];
                    begin
                        EmailTemplateCode := EmailDocumentMgt.CreateEmailTemplate(EmailDocumentMgt."TemplateType.ServOrder");
                        Message(StrSubstNo(EMailTemplateCreatedMsg, EmailTemplateCode));
                    end;
                }
                action(CreateServShptEmailTemplate)
                {
                    Caption = 'Service Shipment';
                    Image = NewOrder;
                    ApplicationArea = All;
                    ToolTip = 'Executes the Service Shipment action';

                    trigger OnAction()
                    var
                        EmailDocumentMgt: Codeunit "NPR E-mail Doc. Mgt.";
                        EmailTemplateCode: Code[20];
                    begin
                        EmailTemplateCode := EmailDocumentMgt.CreateEmailTemplate(EmailDocumentMgt."TemplateType.ServShpt");
                        Message(StrSubstNo(EMailTemplateCreatedMsg, EmailTemplateCode));
                    end;
                }
                action(CreateServInvEmailTemplate)
                {
                    Caption = 'Service Invoice';
                    Image = NewOrder;
                    ApplicationArea = All;
                    ToolTip = 'Executes the Service Invoice action';

                    trigger OnAction()
                    var
                        EmailDocumentMgt: Codeunit "NPR E-mail Doc. Mgt.";
                        EmailTemplateCode: Code[20];
                    begin
                        EmailTemplateCode := EmailDocumentMgt.CreateEmailTemplate(EmailDocumentMgt."TemplateType.ServInv");
                        Message(StrSubstNo(EMailTemplateCreatedMsg, EmailTemplateCode));
                    end;
                }
                action(CreateAuditRollEmailTemplate)
                {
                    Caption = 'Sales Ticket';
                    Image = NewOrder;
                    ApplicationArea = All;
                    ToolTip = 'Executes the Sales Ticket action';

                    trigger OnAction()
                    var
                        EmailDocumentMgt: Codeunit "NPR E-mail Doc. Mgt.";
                        EmailTemplateCode: Code[20];
                    begin
                        EmailTemplateCode := EmailDocumentMgt.CreateEmailTemplate(EmailDocumentMgt."TemplateType.POSEntry");
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

