page 6150671 "NPR POS Entry Factbox"
{
    Caption = 'POS Entry Factbox';
    PageType = CardPart;
    SourceTable = "NPR POS Entry";
    UsageCategory = None;

    layout
    {
        area(Content)
        {
            field("Currency Code"; Rec."Currency Code")
            {

                ApplicationArea = NPRRetail;
                ToolTip = 'Specifies the value of the Currency Code field';
            }
            field("Item Sales (LCY)"; Rec."Item Sales (LCY)")
            {

                ApplicationArea = NPRRetail;
                ToolTip = 'Specifies the value of the Item Sales (LCY) field';

                trigger OnDrillDown()
                begin
                    SaleDetail(1);
                end;
            }
            field("Customer Sales (LCY)"; Rec."Customer Sales (LCY)")
            {

                ApplicationArea = NPRRetail;
                ToolTip = 'Specifies the value of the Customer Sales (LCY) field';
            }
            field("G/L Sales (LCY)"; Rec."G/L Sales (LCY)")
            {

                ApplicationArea = NPRRetail;
                ToolTip = 'Specifies the value of the G/L Sales (LCY) field';
            }
            field("Discount Amount"; Rec."Discount Amount")
            {

                ApplicationArea = NPRRetail;
                Caption = 'Disc. Amt Excl. VAT';
                ToolTip = 'Specifies the value of the Disc. Amt Excl. VAT field';
            }
            field("Amount Incl. Tax"; Rec."Amount Incl. Tax")
            {

                ApplicationArea = NPRRetail;
                ToolTip = 'Specifies the value of the Amount Incl. Tax field';
            }
            field("Amount Excl. Tax"; Rec."Amount Excl. Tax")
            {

                ApplicationArea = NPRRetail;
                ToolTip = 'Specifies the value of the Amount Excl. Tax field';
            }
            field("Tax Amount"; Rec."Tax Amount")
            {

                ApplicationArea = NPRRetail;
                ToolTip = 'Specifies the value of the Tax Amount field';

                trigger OnDrillDown()
                begin
                    TaxDetail();
                end;
            }
            field("Rounding Amount (LCY)"; Rec."Rounding Amount (LCY)")
            {

                ApplicationArea = NPRRetail;
                ToolTip = 'Specifies the value of the Rounding Amount (LCY) field';
            }
            field("Payment Amount"; Rec."Payment Amount")
            {

                ApplicationArea = NPRRetail;
                ToolTip = 'Specifies the value of the Payment Amount field';
            }
            field("Sales Quantity"; Rec."Sales Quantity")
            {

                ApplicationArea = NPRRetail;
                DecimalPlaces = 0 : 2;
                ToolTip = 'Specifies the value of the Sales Quantity field';
            }
            field("Return Sales Quantity"; Rec."Return Sales Quantity")
            {

                ApplicationArea = NPRRetail;
                DecimalPlaces = 0 : 2;
                ToolTip = 'Specifies the value of the Return Sales Quantity field';
            }
            field("Sale Lines"; Rec."Sale Lines")
            {

                ApplicationArea = NPRRetail;
                ToolTip = 'Specifies the value of the Sale Lines field';
            }
            field("Payment Lines"; Rec."Payment Lines")
            {

                ApplicationArea = NPRRetail;
                ToolTip = 'Specifies the value of the Payment Lines field';
            }
            field("EFT Transaction Requests"; Rec."EFT Transaction Requests")
            {
                ApplicationArea = NPRRetail;
                ToolTip = 'Specifies the value of the EFT Transaction field';

            }
            field("Tax Lines"; Rec."Tax Lines")
            {

                ApplicationArea = NPRRetail;
                ToolTip = 'Specifies the value of the Tax Lines field';
            }
            field("No. of Print Output Entries"; Rec."No. of Print Output Entries")
            {

                ApplicationArea = NPRRetail;
                ToolTip = 'Specifies the value of the No. of Print Output Entries field';
            }
            field("POS Info Exist"; Rec."POS Info Exist")
            {
                ApplicationArea = NPRRetail;
                ToolTip = 'Specifies if there are any POS informations related to the POS Entry';
            }
            field("POS Sales Digital Receipts"; Rec."POS Sales Digital Receipts")
            {
                ToolTip = 'Specifies the value of the POS Sales Digital Receipts field.';
                ApplicationArea = NPRRetail;
            }
            field("Images Exist"; Rec."Images Exist")
            {
                ApplicationArea = NPRRetail;
                ToolTip = 'Specifies if there are any images related to the POS Entry';
            }
            field("Costumer Input"; Rec."Costumer Input")
            {
                ApplicationArea = NPRRetail;
                ToolTip = 'Specifies if there are any customer input related to the POS Entry';
            }
            group(CleanCashTransactions)
            {
                ShowCaption = false;
                Visible = ShowCleanCash;
                field("Clean Cash Transactions"; Rec."Clean Cash Transactions")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the details of Clean Cash transactions';

                    trigger OnDrillDown()
                    var
                        CleanCashTransReq: Record "NPR CleanCash Trans. Request";
                    begin
                        CleanCashTransReq.FilterGroup(10);
                        CleanCashTransReq.SetRange("POS Entry No.", Rec."Entry No.");
                        CleanCashTransReq.FilterGroup(0);
                        Page.RunModal(Page::"NPR CleanCash Transactions", CleanCashTransReq);
                    end;
                }
            }
            group(DEPosAuditLog)
            {
                ShowCaption = false;
                Visible = ShowDEAudit;
                field("DE POS Audit Log"; Rec."DE POS Audit Log")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the details of DE POS Audit Log information';

                    trigger OnDrillDown()
                    var
                        DEPOSAuditLogAuxInfo: Record "NPR DE POS Audit Log Aux. Info";
                    begin
                        DEPOSAuditLogAuxInfo.FilterGroup(10);
                        DEPOSAuditLogAuxInfo.SetRange("POS Entry No.", Rec."Entry No.");
                        DEPOSAuditLogAuxInfo.FilterGroup(0);
                        Page.RunModal(Page::"NPR DE POS Audit Log Aux. Info", DEPOSAuditLogAuxInfo);
                    end;
                }
            }
            group(FRAuditLog)
            {
                ObsoleteReason = 'Replaced with table NPR FR POS Audit Log Add. Info';
                ObsoleteState = Pending;
                ObsoleteTag = 'NPR23.0';
                ShowCaption = false;
                Visible = false;
                field("FR POS Audit Log"; Rec."FR POS Audit Log")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the details of FR POS Audit Log information';
                }
            }
            group(RSPosAuditLog)
            {
                ShowCaption = false;
                Visible = ShowRSAudit;
                field("RS POS Audit Log"; Rec."RS POS Audit Log")
                {
                    ApplicationArea = NPRRetail;
                    Caption = 'RS POS Audit Log Exists';
                    ToolTip = 'Specifies the details of RS POS Audit Log information';
                    trigger OnDrillDown()
                    var
                        RSPOSAuditLogAuxInfo: Record "NPR RS POS Audit Log Aux. Info";
                    begin
                        RSPOSAuditLogAuxInfo.FilterGroup(10);
                        RSPOSAuditLogAuxInfo.SetRange("Audit Entry Type", RSPOSAuditLogAuxInfo."Audit Entry Type"::"POS Entry");
                        RSPOSAuditLogAuxInfo.SetRange("POS Entry No.", Rec."Entry No.");
                        RSPOSAuditLogAuxInfo.FilterGroup(0);
                        Page.RunModal(Page::"NPR RS POS Audit Log Aux. Info", RSPOSAuditLogAuxInfo);
                    end;
                }
            }
            group(CROPOSAuditLog)
            {
                ShowCaption = false;
                Visible = ShowCroAudit;
                field("CRO POS Audit Log"; Rec."CRO POS Audit Log")
                {
                    ApplicationArea = NPRRetail;
                    Caption = 'CRO POS Audit Log Exists';
                    ToolTip = 'Specifies the details of CRO POS Audit Log information';
                    trigger OnDrillDown()
                    var
                        CROPOSAuditLogInfo: Record "NPR CRO POS Aud. Log Aux. Info";
                    begin
                        CROPOSAuditLogInfo.FilterGroup(10);
                        CROPOSAuditLogInfo.SetRange("Audit Entry Type", CROPOSAuditLogInfo."Audit Entry Type"::"POS Entry");
                        CROPOSAuditLogInfo.SetRange("POS Entry No.", Rec."Entry No.");
                        CROPOSAuditLogInfo.FilterGroup(0);
                        Page.RunModal(Page::"NPR CRO POS Aud. Log Aux. Info", CROPOSAuditLogInfo);
                    end;
                }
            }
            group(SIPosAuditLog)
            {
                ShowCaption = false;
                Visible = ShowSIAudit;
                field("SI POS Audit Log"; Rec."SI POS Audit Log")
                {
                    Caption = 'SI POS Audit Log Exists';
                    ToolTip = 'Specifies the details of SI POS Audit Log information';
                    ApplicationArea = NPRRetail;
                    trigger OnDrillDown()
                    var
                        SIPOSAuditLogAuxInfo: Record "NPR SI POS Audit Log Aux. Info";
                    begin
                        SIPOSAuditLogAuxInfo.FilterGroup(10);
                        SIPOSAuditLogAuxInfo.SetRange("Audit Entry Type", SIPOSAuditLogAuxInfo."Audit Entry Type"::"POS Entry");
                        SIPOSAuditLogAuxInfo.SetRange("POS Entry No.", Rec."Entry No.");
                        SIPOSAuditLogAuxInfo.FilterGroup(0);
                        Page.RunModal(Page::"NPR SI POS Audit Log Aux. Info", SIPOSAuditLogAuxInfo);
                    end;
                }
            }
            group(BGSISPOSAuditLogGroup)
            {
                ShowCaption = false;
                Visible = ShowBGSISAudit;
                field("BG SIS POS Audit Log"; Rec."BG SIS POS Audit Log")
                {
                    ApplicationArea = NPRRetail;
                    Caption = 'BG SIS POS Audit Log Exists';
                    ToolTip = 'Specifies the details of BG SIS POS Audit Log information.';

                    trigger OnDrillDown()
                    var
                        BGSISPOSAuditLogAux: Record "NPR BG SIS POS Audit Log Aux.";
                    begin
                        BGSISPOSAuditLogAux.FilterGroup(10);
                        BGSISPOSAuditLogAux.SetRange("Audit Entry Type", BGSISPOSAuditLogAux."Audit Entry Type"::"POS Entry");
                        BGSISPOSAuditLogAux.SetRange("POS Entry No.", Rec."Entry No.");
                        BGSISPOSAuditLogAux.FilterGroup(0);
                        Page.RunModal(0, BGSISPOSAuditLogAux);
                    end;
                }
            }
            group(ATPOSAuditLogGroup)
            {
                ShowCaption = false;
                Visible = ShowATAudit;
                field("AT POS Audit Log"; Rec."AT POS Audit Log")
                {
                    ApplicationArea = NPRRetail;
                    Caption = 'AT POS Audit Log Exists';
                    ToolTip = 'Specifies the details of AT POS Audit Log information.';

                    trigger OnDrillDown()
                    var
                        ATPOSAuditLogAuxInfo: Record "NPR AT POS Audit Log Aux. Info";
                    begin
                        ATPOSAuditLogAuxInfo.FilterGroup(10);
                        ATPOSAuditLogAuxInfo.SetRange("Audit Entry Type", ATPOSAuditLogAuxInfo."Audit Entry Type"::"POS Entry");
                        ATPOSAuditLogAuxInfo.SetRange("POS Entry No.", Rec."Entry No.");
                        ATPOSAuditLogAuxInfo.FilterGroup(0);
                        Page.RunModal(0, ATPOSAuditLogAuxInfo);
                    end;
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        if Rec."Discount Amount" = 0 then
            UpdateDiscountAmt();
    end;

    trigger OnAfterGetCurrRecord()
    begin
        SetAuditFieldsVisibility();
    end;

    local procedure TaxDetail()
    var
        TaxAmountLine: Record "NPR POS Entry Tax Line";
    begin
        TaxAmountLine.Reset();
        TaxAmountLine.SetRange("POS Entry No.", Rec."Entry No.");
        Page.Run(0, TaxAmountLine);
    end;

    local procedure SaleDetail(Type: Integer)
    var
        SalesLine: Record "NPR POS Entry Sales Line";
    begin
        SalesLine.Reset();
        SalesLine.SetRange("POS Entry No.", Rec."Entry No.");
        case Type of
            1:
                SalesLine.SetRange(Type, SalesLine.Type::Item);
        end;
        Page.Run(0, SalesLine);
    end;

    local procedure UpdateDiscountAmt()
    var
        POSSalesLine: Record "NPR POS Entry Sales Line";
    begin
        POSSalesLine.Reset();
        POSSalesLine.SetRange("POS Entry No.", Rec."Entry No.");
        if POSSalesLine.FindSet() then
            repeat
                Rec."Discount Amount" += POSSalesLine."Line Discount Amount Excl. VAT";
            until POSSalesLine.Next() = 0;
    end;

    local procedure SetAuditFieldsVisibility()
    var
        POSAuditProfile: Record "NPR POS Audit Profile";
        POSUnit: Record "NPR POS Unit";
    begin
        ClearShowVariables();
        if not POSUnit.Get(Rec."POS Unit No.") then
            exit;
        if not POSAuditProfile.Get(POSUnit."POS Audit Profile") then
            exit;
        SetShowVariables(POSAuditProfile);
    end;

    local procedure ClearShowVariables()
    begin
        Clear(ShowCleanCash);
        Clear(ShowDEAudit);
        Clear(ShowRSAudit);
        Clear(ShowCroAudit);
        Clear(ShowSIAudit);
        Clear(ShowBGSISAudit);
        Clear(ShowATAudit);
    end;

    local procedure SetShowVariables(POSAuditProfile: Record "NPR POS Audit Profile")
    var
        CleanCashXCCSPProtocol: Codeunit "NPR CleanCash XCCSP Protocol";
        CROAuditMgt: Codeunit "NPR CRO Audit Mgt.";
        DEAuditMgt: Codeunit "NPR DE Audit Mgt.";
        RSAuditMgt: Codeunit "NPR RS Audit Mgt.";
        SIAuditMgt: Codeunit "NPR SI Audit Mgt.";
        BGSISAuditMgt: Codeunit "NPR BG SIS Audit Mgt.";
        ATAuditMgt: Codeunit "NPR AT Audit Mgt.";
    begin
        case POSAuditProfile."Audit Handler" of
            CleanCashXCCSPProtocol.HandlerCode():
                ShowCleanCash := true;
            DEAuditMgt.HandlerCode():
                ShowDEAudit := true;
            RSAuditMgt.HandlerCode():
                ShowRSAudit := true;
            CROAuditMgt.HandlerCode():
                ShowCroAudit := true;
            SIAuditMgt.HandlerCode():
                ShowSIAudit := true;
            BGSISAuditMgt.HandlerCode():
                ShowBGSISAudit := true;
            ATAuditMgt.HandlerCode():
                ShowATAudit := true;
        end;
    end;

    var
        ShowCleanCash: Boolean;
        ShowCroAudit: Boolean;
        ShowDEAudit: Boolean;
        ShowRSAudit: Boolean;
        ShowSIAudit: Boolean;
        ShowBGSISAudit: Boolean;
        ShowATAudit: Boolean;
}

