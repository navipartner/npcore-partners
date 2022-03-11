tableextension 6014405 "NPR Sales Invoice Header" extends "Sales Invoice Header"
{
    fields
    {
        field(6014400; "NPR Sales Ticket No."; Code[20])
        {
            Caption = 'Sales Ticket No.';
            Description = 'NPR7.100.000';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used.';
        }
        field(6014414; "NPR Bill-to E-mail"; Text[80])
        {
            Caption = 'Bill-to E-mail';
            Description = 'PN1.00';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used.';
        }
        field(6014415; "NPR Document Processing"; Option)
        {
            ObsoleteState = Removed;
            ObsoleteReason = 'Document Sending Profile from Customer is used.';
            Caption = 'Document Processing';
            Description = 'PN1.00';
            OptionCaption = 'Print,E-mail,OIO,Print and E-Mail';
            OptionMembers = Print,Email,OIO,PrintAndEmail;
            DataClassification = CustomerContent;
        }
        field(6014420; "NPR Delivery Location"; Code[10])
        {
            Caption = 'Delivery Location';
            Description = 'PS1.00';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used.';
        }
        field(6014425; "NPR Order Type"; Option)
        {
            Caption = 'Order Type';
            OptionCaption = ',Order,Lending';
            OptionMembers = ,"Order",Lending;
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used.';
        }
        field(6014450; "NPR Kolli"; Integer)
        {
            Caption = 'Number of packages';
            Description = 'NPR7.100.000';
            InitValue = 1;
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used.';
        }
        field(6014451; "NPR Ship. Agent Serv. Code"; Code[10])
        {
            Caption = 'Shipping Agent Service Code';
            Description = 'NPR7.100.000';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used.';
        }
        field(6014470; "NPR Pacsoft Ship. Not Created"; Boolean)
        {
            Caption = 'Pacsoft Shipment Not Created';
            Description = 'PS1.01';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used.';
        }
        field(6059931; "NPR Doc. Exch. Fr.work Status"; Option)
        {
            Caption = 'Doc. Exch. Framework Status';
            Description = 'NPR5.26';
            OptionCaption = ' ,Exported to Folder,Setup Changed,Delivered to Recepient,File Validation Error';
            OptionMembers = " ","Exported to Folder","Setup Changed","Delivered to Recepient","File Validation Error";
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used.';
        }
        field(6059932; "NPR Doc. Exch. Exported"; Boolean)
        {
            Caption = 'Doc. Exch. Exported';
            Description = 'NPR5.26';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used.';
        }
        field(6059933; "NPR Doc. Exch. Setup Path Used"; RecordID)
        {
            Caption = 'Doc. Exch. Setup Path Used';
            Description = 'NPR5.26';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used.';
        }
        field(6059934; "NPR Doc. Exch. Export. to"; Text[250])
        {
            Caption = 'Doc. Exch. Exported to';
            Description = 'NPR5.26';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used.';
        }
        field(6059935; "NPR Doc. Exch. File Exists"; Boolean)
        {
            Caption = 'Doc. Exch. File Exists';
            Description = 'NPR5.26';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used.';
        }
        field(6151300; "NPR NpEc Store Code"; Code[20])
        {
            Caption = 'NpEc Store Code';
            Description = 'NPR5.53,NPR5.54';
            Enabled = false;
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used.';
        }
        field(6151305; "NPR NpEc Document No."; Code[50])
        {
            Caption = 'NpEc Document No.';
            Description = 'NPR5.53,NPR5.54';
            Enabled = false;
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used.';
        }
        field(6151400; "NPR Magento Payment Amount"; Decimal)
        {
            CalcFormula = Sum("NPR Magento Payment Line".Amount WHERE("Document Table No." = CONST(112),
                                                                   "Document No." = FIELD("No.")));
            Caption = 'Payment Amount';
            Description = 'MAG2.00';
            Editable = false;
            FieldClass = FlowField;
        }
        field(6151405; "NPR External Order No."; Code[20])
        {
            Caption = 'External Order No.';
            Description = 'MAG2.00';
            DataClassification = CustomerContent;
        }
        field(6151415; "NPR Payment No."; Text[50])
        {
            Caption = 'Payment No.';
            Description = 'MAG2.00';
            DataClassification = CustomerContent;
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

