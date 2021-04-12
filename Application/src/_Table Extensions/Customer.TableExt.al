tableextension 6014423 "NPR Customer" extends Customer
{
    fields
    {
        field(6014400; "NPR Type"; Option)
        {
            Caption = 'Type';
            DataClassification = CustomerContent;
            OptionCaption = 'Customer,Cash';
            OptionMembers = Customer,Cash;
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used.';
        }
        field(6014402; "NPR Internal y/n"; Boolean)
        {
            Caption = 'Internal';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used.';
        }
        field(6014403; "NPR Auto"; Boolean)
        {
            Caption = 'Auto';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used.';
        }
        field(6014404; "NPR Record on Debitsale"; Option)
        {
            Caption = 'Record on Debitsale';
            DataClassification = CustomerContent;
            OptionCaption = ' ,Invoice,Shipping Note,Ask';
            OptionMembers = " ",Invoice,"Shipping Note",Ask;
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used.';
        }
        field(6014405; "NPR Record on neg. Debitsale"; Option)
        {
            Caption = 'Record on negative Debitsale';
            DataClassification = CustomerContent;
            OptionCaption = ' ,Return Order,Credit Memo,Ask';
            OptionMembers = " ","Return Order","Credit Memo",Ask;
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used.';
        }
        field(6014407; "NPR Primary Key Length"; Integer)
        {
            Caption = 'Primary Key Length';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used.';
        }
        field(6014408; "NPR Sales invoice Report No."; Integer)
        {
            Caption = 'Sales invoice Report No.';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used.';
        }
        field(6014409; "NPR Change-to No."; Code[20])
        {
            Caption = 'Change-to No.';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used.';
        }
        field(6014415; "NPR Document Processing"; Option)
        {
            ObsoleteState = Removed;
            ObsoleteReason = 'Use standard field Document Sending Profile';
            Caption = 'Document Processing';
            DataClassification = CustomerContent;
            Description = 'PN1.00';
            OptionCaption = 'Print,E-mail,OIO,Print and E-Mail';
            OptionMembers = Print,Email,OIO,PrintAndEmail;
            InitValue = Email;
        }
        field(6014416; "NPR Bill-to Company"; Text[30])
        {
            Caption = 'Bill-to Company (IC)';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used.';
        }
        field(6014417; "NPR Bill-to Vendor No."; Code[20])
        {
            Caption = 'Bill-to Vendor No. (IC)';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used.';
        }
        field(6059771; "NPR Loyalty Customer"; Boolean)
        {
            Caption = 'Loyalty Customer';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used.';
        }
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
        field(6151455; "NPR Magento Display Group"; Code[20])
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

    var
        SalesSetup: Record "Sales & Receivables Setup";
}