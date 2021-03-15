tableextension 6014414 "NPR Purch. Cr. Memo Hdr." extends "Purch. Cr. Memo Hdr."
{
    fields
    {
        field(6014414; "NPR Pay-to E-mail"; Text[80])
        {
            Caption = 'Pay-to E-mail';
            DataClassification = CustomerContent;
            Description = 'PN1.00';
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used.';
        }
        field(6014415; "NPR Document Processing"; Option)
        {
            ObsoleteState = Removed;
            ObsoleteReason = 'Document Sending Profile from Vendor is used.';
            Caption = 'Document Processing';
            DataClassification = CustomerContent;
            Description = 'PN1.00';
            OptionCaption = 'Print,E-mail,,Print and E-Mail';
            OptionMembers = Print,Email,OIO,PrintAndEmail;
        }
        field(6014420; "NPR Sell-to Customer Name"; Text[100])
        {
            CalcFormula = Lookup(Customer.Name WHERE("No." = FIELD("Sell-to Customer No.")));
            Caption = 'Sell-to Customer Name';
            FieldClass = FlowField;
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used.';
        }
        field(6014421; "NPR Sell-to Customer Name 2"; Text[50])
        {
            CalcFormula = Lookup(Customer."Name 2" WHERE("No." = FIELD("Sell-to Customer No.")));
            Caption = 'Sell-to Customer Name 2';
            FieldClass = FlowField;
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used.';
        }
        field(6014422; "NPR Sell-to Address"; Text[50])
        {
            CalcFormula = Lookup(Customer.Address WHERE("No." = FIELD("Sell-to Customer No.")));
            Caption = 'Sell-to Address';
            FieldClass = FlowField;
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used.';
        }
        field(6014423; "NPR Sell-to Address 2"; Text[50])
        {
            CalcFormula = Lookup(Customer."Address 2" WHERE("No." = FIELD("Sell-to Customer No.")));
            Caption = 'Sell-to Address 2';
            FieldClass = FlowField;
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used.';
        }
        field(6014424; "NPR Sell-to City"; Text[30])
        {
            CalcFormula = Lookup(Customer.City WHERE("No." = FIELD("Sell-to Customer No.")));
            Caption = 'Sell-to City';
            FieldClass = FlowField;
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used.';
        }
        field(6014425; "NPR Sell-to Post Code"; Code[20])
        {
            CalcFormula = Lookup(Customer."Post Code" WHERE("No." = FIELD("Sell-to Customer No.")));
            Caption = 'Sell-to Post Code';
            FieldClass = FlowField;
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used.';
        }
        field(6014430; "NPR Sell-to Phone No."; Text[30])
        {
            CalcFormula = Lookup(Customer."Phone No." WHERE("No." = FIELD("Sell-to Customer No.")));
            Caption = 'Sell-to Phone No.';
            FieldClass = FlowField;
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used.';
        }
    }
}

