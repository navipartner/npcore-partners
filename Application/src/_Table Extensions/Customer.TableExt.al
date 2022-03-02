tableextension 6014423 "NPR Customer" extends Customer
{
    fields
    {
        field(6151060; "NPR Anonymized"; Boolean)
        {
            Caption = 'Anonymized';
            DataClassification = CustomerContent;
            Description = 'NPR5.52';
            Editable = false;
        }
        field(6151061; "NPR Anonymized Date"; DateTime)
        {
            Caption = 'Anonymized Date';
            DataClassification = CustomerContent;
            Description = 'NPR5.52';
            Editable = false;
        }
        field(6151062; "NPR To Anonymize"; Boolean)
        {
            Caption = 'To Anomymize';
            DataClassification = CustomerContent;
            Description = 'NPR5.52';
        }
        field(6151063; "NPR To Anonymize On"; Date)
        {
            Caption = 'To Anonymize On';
            DataClassification = CustomerContent;
            Description = 'NPR5.53';
        }
        field(6151450; "NPR External Customer No."; Code[20])
        {
            Caption = 'External Customer No.';
            DataClassification = CustomerContent;
            Description = 'MAG2.00';
        }
        field(6151455; "NPR Magento Display Group"; Code[255])
        {
            Caption = 'Magento Display Group';
            DataClassification = CustomerContent;
            Description = 'MAG2.00,MAG2.20';
            TableRelation = "NPR Magento Display Group";
            ValidateTableRelation = false;

            trigger OnLookup()
            var
                M2AccountLookupMgt: Codeunit "NPR M2 Account Lookup Mgt.";
            begin
                M2AccountLookupMgt.LookupDisplayGroup(Rec);
            end;

            trigger OnValidate()
            var
                M2AccountLookupMgt: Codeunit "NPR M2 Account Lookup Mgt.";
            begin
                M2AccountLookupMgt.ValidateDisplayGroup(Rec);
            end;
        }
        field(6151460; "NPR Magento Shipping Group"; Text[30])
        {
            Caption = 'Magento Shipping Group';
            DataClassification = CustomerContent;
            Description = 'NPR5.48,MAG2.20';

            trigger OnLookup()
            var
                M2AccountLookupMgt: Codeunit "NPR M2 Account Lookup Mgt.";
            begin
                M2AccountLookupMgt.LookupShippingGroup(Rec);
            end;

            trigger OnValidate()
            var
                M2AccountLookupMgt: Codeunit "NPR M2 Account Lookup Mgt.";
            begin
                M2AccountLookupMgt.ValidateShippingGroup(Rec);
            end;
        }
        field(6151465; "NPR Magento Payment Group"; Text[30])
        {
            Caption = 'Magento Payment Group';
            DataClassification = CustomerContent;
            Description = 'NPR5.48,MAG2.20';

            trigger OnLookup()
            var
                M2AccountLookupMgt: Codeunit "NPR M2 Account Lookup Mgt.";
            begin
                M2AccountLookupMgt.LookupPaymentGroup(Rec);
            end;

            trigger OnValidate()
            var
                M2AccountLookupMgt: Codeunit "NPR M2 Account Lookup Mgt.";
            begin
                M2AccountLookupMgt.ValidatePaymentGroup(Rec);
            end;
        }
        field(6151470; "NPR Magento Store Code"; Text[30])
        {
            Caption = 'Magento Store Code';
            DataClassification = CustomerContent;
            Description = 'NPR5.48,MAG2.20';
            TableRelation = "NPR Magento Store";

            trigger OnLookup()
            var
                M2AccountLookupMgt: Codeunit "NPR M2 Account Lookup Mgt.";
            begin
                M2AccountLookupMgt.LookupMagentoStore(Rec);
            end;

            trigger OnValidate()
            var
                M2AccountLookupMgt: Codeunit "NPR M2 Account Lookup Mgt.";
            begin
                M2AccountLookupMgt.ValidateMagentoStore(Rec);
            end;
        }

        field(6151479; "NPR Replication Counter"; BigInteger)
        {
            Caption = 'Replication Counter';
            DataClassification = CustomerContent;
        }
    }
    keys
    {
        key("NPR Key1"; "NPR Replication Counter")
        {
        }
    }

    trigger OnBeforeDelete()
    var
        SalesLinePOS: Record "NPR POS Sale Line";
        SalesPOS: Record "NPR POS Sale";
        POSEntry: Record "NPR POS Entry";
        DeleteCustActiveCashErr: Label 'You can''t delete customer %1 as it is used on active cash payment.', Comment = '%1 = Customer';
        DeleteCustActiveSalesDocErr: Label 'You can''t delete customer %1 as it is used on an active sales document.', Comment = '%1 = Customer';
        DeleteCustActivePostedEntriesErr: Label 'You can''t delete customer %1 as there are one or more non posted entries.', Comment = '%1 = Customer';
    begin
        if Rec."No." = '' then
            exit;

        POSEntry.SetRange("Customer No.", Rec."No.");
        POSEntry.SetRange("Post Entry Status", POSEntry."Post Entry Status"::Unposted);
        if not POSEntry.IsEmpty() then
            Error(DeleteCustActivePostedEntriesErr, Rec."No.");

        SalesPOS.SetRange("Customer No.", Rec."No.");
        if not SalesPOS.IsEmpty() then
            Error(DeleteCustActiveSalesDocErr, Rec."No.");

        SalesLinePOS.SetRange("Sale Type", SalesLinePOS."Sale Type"::Deposit);
        SalesLinePOS.SetRange(Type, SalesLinePOS.Type::Customer);
        SalesLinePOS.SetRange("No.", Rec."No.");
        if not SalesLinePOS.IsEmpty() then
            Error(DeleteCustActiveCashErr, Rec."No.");
    end;

    procedure NPR_IsRestrictedOnPOS(CheckFieldNo: Integer): Boolean
    var
        GenBusPostingGroup: Record "Gen. Business Posting Group";
        VatBusPostingGroup: Record "VAT Business Posting Group";
    begin
        case CheckFieldNo of
            Rec.FieldNo("Gen. Bus. Posting Group"):
                begin
                    if not GenBusPostingGroup.Get(Rec."Gen. Bus. Posting Group") then
                        GenBusPostingGroup.Init();
                    exit(GenBusPostingGroup."NPR Restricted on POS");
                end;

            Rec.FieldNo("VAT Bus. Posting Group"):
                begin
                    if not VatBusPostingGroup.Get(Rec."VAT Bus. Posting Group") then
                        VatBusPostingGroup.Init();
                    exit(VatBusPostingGroup."NPR Restricted on POS");
                end;
        end;

        exit(false);
    end;
}