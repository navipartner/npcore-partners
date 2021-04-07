tableextension 6014432 "NPR Sales Header" extends "Sales Header"
{
    fields
    {
        modify("Prices Including VAT")
        {
            trigger OnAfterValidate()
            var
                SalesLine: Record "Sales Line";
            begin
                if Rec."Prices Including VAT" <> xRec."Prices Including VAT" then begin
                    SalesLine.SetRange("Document Type", Rec."Document Type");
                    SalesLine.SetRange("Document No.", Rec."No.");
                    SalesLine.SetRange(Type, SalesLine.Type::Item);
                    if SalesLine.FindSet(true) then
                        repeat
                            if SalesLine.NPRCalcItemGroupUnitCost() then
                                SalesLine.Modify();
                        until SalesLine.Next = 0;
                end;
            end;
        }
        field(6014400; "NPR Sales Ticket No."; Code[20])
        {
            Caption = 'Sales Ticket No.';
            DataClassification = CustomerContent;
            Description = 'NPR7.100.000';
        }
        field(6014401; "NPR Buy-From Vendor No."; Code[20])
        {
            Caption = 'Buy-from Vendor No.';
            DataClassification = CustomerContent;
            Description = 'NPR7.100.000';
        }
        field(6014406; "NPR Document Time"; Time)
        {
            Caption = 'Document Time';
            DataClassification = CustomerContent;
            Description = 'NPR7.100.000';
        }
        field(6014407; "NPR Bill-to Company"; Text[30])
        {
            Caption = 'Bill-to Company (IC)';
            DataClassification = CustomerContent;
            Description = 'NPR7.100.000';
            TableRelation = Company;
        }
        field(6014408; "NPR Bill-To Vendor No."; Code[10])
        {
            Caption = 'Bill-to Vendor No. (IC)';
            DataClassification = CustomerContent;
        }
        field(6014414; "NPR Bill-to E-mail"; Text[80])
        {
            Caption = 'Bill-to E-mail';
            DataClassification = CustomerContent;
            Description = 'PN1.00';
        }
        field(6014415; "NPR Document Processing"; Option)
        {
            ObsoleteState = Removed;
            ObsoleteReason = 'Document Sending Profile from Customer is used.';
            Caption = 'Document Processing';
            DataClassification = CustomerContent;
            Description = 'PN1.00';
            OptionCaption = 'Print,E-mail,OIO,Print and E-Mail';
            OptionMembers = Print,Email,OIO,PrintAndEmail;
        }
        field(6014420; "NPR Delivery Location"; Code[10])
        {
            Caption = 'Delivery Location';
            DataClassification = CustomerContent;
            Description = 'PS1.00';
        }
        field(6014425; "NPR Order Type"; Option)
        {
            Caption = 'Order Type';
            DataClassification = CustomerContent;
            OptionCaption = ',Order,Lending';
            OptionMembers = ,"Order",Lending;
        }
        field(6014450; "NPR Kolli"; Integer)
        {
            Caption = 'Number of packages';
            DataClassification = CustomerContent;
            Description = 'NPR7.100.000';
            InitValue = 1;
        }
        field(6014452; "NPR Delivery Instructions"; Text[50])
        {
            Caption = 'Delivery Instructions';
            DataClassification = CustomerContent;
        }
        field(6151400; "NPR Magento Payment Amount"; Decimal)
        {
            CalcFormula = Sum("NPR Magento Payment Line".Amount WHERE("Document Table No." = CONST(36),
                                                                   "Document Type" = FIELD("Document Type"),
                                                                   "Document No." = FIELD("No.")));
            Caption = 'Payment Amount';
            Description = 'MAG2.00';
            Editable = false;
            FieldClass = FlowField;
        }
        field(6151405; "NPR External Order No."; Code[20])
        {
            Caption = 'External Order No.';
            DataClassification = CustomerContent;
            Description = 'MAG2.00';
        }
        field(6151415; "NPR Payment No."; Text[50])
        {
            Caption = 'Payment No.';
            DataClassification = CustomerContent;
            Description = 'MAG2.00';
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used.';
        }

        field(6151420; "NPR Magento Coupon"; Text[20])
        {
            Caption = 'Magento Coupon';
            DataClassification = CustomerContent;
        }
    }
}