page 6248726 "NPR RO Fiscalisation Setup"
{
    ApplicationArea = NPRRetail;
    Caption = 'RO Fiscalization Setup';
    DeleteAllowed = false;
    Extensible = false;
    InsertAllowed = false;
    PageType = Card;
    SourceTable = "NPR RO Fiscalisation Setup";
    UsageCategory = Administration;

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General Settings';

                field("Enable RO Fiscal"; Rec."Enable RO Fiscal")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies whether RO Fiscalization is enabled.';

                    trigger OnValidate()
                    begin
                        if xRec."Enable RO Fiscal" <> Rec."Enable RO Fiscal" then
                            EnabledValueChanged := true;

                        if EnabledValueChanged and (not Rec."Enable RO Fiscal") then
                            DisableCustLedgerEntryPosting();
                    end;
                }
            }
            group("Customer Ledger Entry Posting Setup")
            {
                Caption = 'Customer Ledger Entry Posting Setup';

                field("Enable POS Entry CLE Posting"; Rec."Enable POS Entry CLE Posting")
                {
                    Caption = 'Enable Posting';
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Enable posting Customer Ledger Entries from POS Entry when customer is selected on POS.';
                    Enabled = Rec."Enable RO Fiscal";
                }
                field("Customer Posting Group Filter"; Rec."Customer Posting Group Filter")
                {
                    ToolTip = 'Set the Customer Posting Group for which Customer Ledger Entries Filter will be posted.';
                    ApplicationArea = NPRRetail;
                    Enabled = Rec."Enable POS Entry CLE Posting";
                }
                field("Enable Legal Ent. CLE Posting"; Rec."Enable Legal Ent. CLE Posting")
                {
                    Caption = 'Post Only for Legal Entities';
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Enable posting Customer Ledger Entries for customers that are Legal Entities - have VAT Registration No. set on their Customer Card.';
                    Enabled = Rec."Enable POS Entry CLE Posting";
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        if not Rec.Get() then begin
            Rec.Init();
            Rec.Insert();
        end;
    end;

    trigger OnClosePage()
    var
        ApplicationAreaMgmtFacade: Codeunit "Application Area Mgmt. Facade";
    begin
        if EnabledValueChanged then
            ApplicationAreaMgmtFacade.RefreshExperienceTierCurrentCompany();
    end;

    local procedure DisableCustLedgerEntryPosting()
    begin
        Clear(Rec."Enable POS Entry CLE Posting");
        Clear(Rec."Enable Legal Ent. CLE Posting");
        Clear(Rec."Customer Posting Group Filter");
    end;

    var
        EnabledValueChanged: Boolean;
}