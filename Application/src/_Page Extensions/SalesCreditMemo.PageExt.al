pageextension 6014412 "NPR Sales Credit Memo" extends "Sales Credit Memo"
{
    layout
    {
        addafter(Status)
        {
            field("NPR Correction"; Rec.Correction)
            {
                ApplicationArea = NPRRetail;
                Importance = Additional;
                ToolTip = 'Specifies whether this credit memo is to be posted as a corrective entry.';
            }

            field("NPR Group Code"; Rec."NPR Group Code")
            {
                ApplicationArea = NPRRetail;
                ToolTip = 'Specifies the value of the Group Code field.';
            }
            field("NPR PR POS Trans. Scheduled For Post"; Rec."NPR POS Trans. Sch. For Post")
            {
                ApplicationArea = NPRRetail;
                ToolTip = 'Specifies if there are POS entries scheduled for posting';
                Visible = AsyncEnabled;
                trigger OnDrillDown()
                var
                    POSAsyncPostingMgt: Codeunit "NPR POS Async. Posting Mgt.";
                begin
                    POSAsyncPostingMgt.ScheduledTransFromPOSOnDrillDown(Rec);
                end;
            }
            field("NPR Sales Channel"; Rec."NPR Sales Channel")
            {
                ToolTip = 'Specifies the value of the Sales Channel field';
                Visible = false;
                ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
            }
            field("NPR Posting No."; Rec."Posting No.")
            {
                ApplicationArea = NPRRetail;
                Importance = Additional;
                Visible = false;
                ToolTip = 'Specifies the value of the Posting No. field.';
            }
        }

        addlast("Credit Memo Details")
        {
            field("NPR Magento Payment Amount"; Rec."NPR Magento Payment Amount")
            {
                ApplicationArea = NPRRetail;
                ToolTip = 'Specifies the sum of Payment Lines attached to the Sales Credit Memo';
            }
        }
        addafter("Salesperson Code")
        {
            field("NPR RS POS Unit"; RSAuxSalesHeader."NPR RS POS Unit")
            {
                Caption = 'RS POS Unit';
                ApplicationArea = NPRRSFiscal;
                ToolTip = 'Specifies the value of the RS POS Unit field.';
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
            field("NPR RS Referent No."; RSAuxSalesHeader."NPR RS Referent No.")
            {
                Caption = 'RS Referent No.';
                ApplicationArea = NPRRSFiscal;
                ToolTip = 'Specifies the value of the RS Referent No. field.';
                trigger OnValidate()
                begin
                    RSAuxSalesHeader.Validate("NPR RS Referent No.");
                    RSAuxSalesHeader.SaveRSAuxSalesHeaderFields();
                end;
            }
            field("NPR RS Referent Date/Time"; RSAuxSalesHeader."NPR RS Referent Date/Time")
            {
                Caption = 'RS Referent Date/Time';
                ApplicationArea = NPRRSFiscal;
                ToolTip = 'Specifies the value of the RS Referent Date/Time field.';
                trigger OnValidate()
                begin
                    RSAuxSalesHeader.Validate("NPR RS Referent Date/Time");
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
            field("NPR CRO POS Unit"; CROAuxSalesHeader."NPR CRO POS Unit")
            {
                Caption = 'POS Unit No.';
                ApplicationArea = NPRCROFiscal;
                ToolTip = 'Specifies the value of the POS Unit No. field.';
                TableRelation = "NPR POS Unit";
                trigger OnValidate()
                begin
                    CROAuxSalesHeader.Validate("NPR CRO POS Unit");
                    CROAuxSalesHeader.SaveCROAuxSalesHeaderFields();
                end;
            }
        }
    }

    var
        RSAuxSalesHeader: Record "NPR RS Aux Sales Header";
        CROAuxSalesHeader: Record "NPR CRO Aux Sales Header";
        AsyncEnabled: Boolean;

    trigger OnAfterGetCurrRecord()
    begin
        RSAuxSalesHeader.ReadRSAuxSalesHeaderFields(Rec);
        CROAuxSalesHeader.ReadCROAuxSalesHeaderFields(Rec);
    end;

    trigger OnOpenPage()
    var
        POSAsyncPostingMgt: Codeunit "NPR POS Async. Posting Mgt.";
    begin
        AsyncEnabled := POSAsyncPostingMgt.SetVisibility();
    end;
}