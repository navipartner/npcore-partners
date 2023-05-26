pageextension 6014404 "NPR Sales Quote" extends "Sales Quote"
{
    layout
    {
        addafter(Status)
        {
            field("NPR Group Code"; Rec."NPR Group Code")
            {
                ApplicationArea = NPRRetail;
                ToolTip = 'Specifies the value of the Group Code field.';
            }
        }
        addafter("Salesperson Code")
        {
            field("NPR RS POS Unit"; RSAuxSalesHeader."NPR RS POS Unit")
            {
                Caption = 'RS POS Unit';
                ApplicationArea = NPRRSFiscal;
                ToolTip = 'Specifies the value of the RS POS Unit field.';
                ShowMandatory = true;
                TableRelation = "NPR POS Unit";
                trigger OnValidate()
                begin
                    RSAuxSalesHeader.Validate("NPR RS POS Unit");
                    RSAuxSalesHeader.SaveRSAuxSalesHeaderFields();
                end;
            }
            field("NPR RS Cust. Ident. Type"; RSAuxSalesHeader."NPR RS Cust. Ident. Type")
            {
                Caption = 'RS Customer Identification Type';
                ApplicationArea = NPRRSFiscal;
                ToolTip = 'Specifies the value of the RS Customer Identification Type field.';
                trigger OnValidate()
                begin
                    RSAuxSalesHeader.Validate("NPR RS Cust. Ident. Type");
                    RSAuxSalesHeader.SaveRSAuxSalesHeaderFields();
                end;
            }
            field("NPR RS Customer Ident."; RSAuxSalesHeader."NPR RS Customer Ident.")
            {
                Caption = 'RS Customer Identification';
                ApplicationArea = NPRRSFiscal;
                ToolTip = 'Specifies the value of the RS Customer Identification field.';
                trigger OnValidate()
                begin
                    RSAuxSalesHeader.Validate("NPR RS Customer Ident.");
                    RSAuxSalesHeader.SaveRSAuxSalesHeaderFields();
                end;
            }
            field("NPR RS Add. Cust. Ident. Type"; RSAuxSalesHeader."NPR RS Add. Cust. Ident. Type")
            {
                Caption = 'RS Additional Cust. Identification Type';
                ApplicationArea = NPRRSFiscal;
                ToolTip = 'Specifies the value of the RS Optional Cust. Identification Type field.';
                trigger OnValidate()
                begin
                    RSAuxSalesHeader.Validate("NPR RS Add. Cust. Ident. Type");
                    RSAuxSalesHeader.SaveRSAuxSalesHeaderFields();
                end;
            }
            field("NPR RS Add. Cust. Ident."; RSAuxSalesHeader."NPR RS Add. Cust. Ident.")
            {
                Caption = 'RS Additional Cust. Identification';
                ApplicationArea = NPRRSFiscal;
                ToolTip = 'Specifies the value of the RS Additional Cust. Identification field.';
                trigger OnValidate()
                begin
                    RSAuxSalesHeader.Validate("NPR RS Add. Cust. Ident.");
                    RSAuxSalesHeader.SaveRSAuxSalesHeaderFields();
                end;
            }
            field("NPR RS Audit Entry"; RSAuxSalesHeader."NPR RS Audit Entry")
            {
                Caption = 'RS Audit Entry';
                ApplicationArea = NPRRSFiscal;
                ToolTip = 'Specifies the value of the RS Audit Entry field.';
                Editable = false;
            }
        }
    }
    actions
    {
        addafter(Print)
        {
            action("NPR SendSMS")
            {
                Caption = 'Send SMS';
                Image = SendConfirmation;
                ToolTip = 'Specifies whether a notification SMS should be sent to a responsible person. The messages are sent using SMS templates.';
                ApplicationArea = NPRRetail;
                trigger OnAction()
                var
                    SMSMgt: Codeunit "NPR SMS Management";
                begin
                    SMSMgt.EditAndSendSMS(Rec);
                end;
            }
            action("NPR RS Thermal Print Bill")
            {
                Caption = 'Print RS Bill';
                ToolTip = 'Executing this action starts connection with hardware connector and try to print RS Bill from RS Audit Log.';
                ApplicationArea = NPRRSFiscal;
                Image = PrintCover;
                trigger OnAction()
                var
                    RSAuditMgt: Codeunit "NPR RS Audit Mgt.";
                begin
                    RSAuditMgt.TermalPrintSalesHeader(Rec);
                end;
            }
        }
    }

    var
        RSAuxSalesHeader: Record "NPR RS Aux Sales Header";

    trigger OnAfterGetCurrRecord()
    begin
        RSAuxSalesHeader.ReadRSAuxSalesHeaderFields(Rec);
    end;
}
