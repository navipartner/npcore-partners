tableextension 6014407 "NPR Sales Cr.Memo Header" extends "Sales Cr.Memo Header"
{
    fields
    {
        field(6014400; "NPR Sales Ticket No."; Code[20])
        {
            Caption = 'Sales Ticket No.';
            Description = 'NPR7.100.000';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteTag = '2023-06-28';
            ObsoleteReason = 'Not used.';
        }
        field(6014414; "NPR Bill-to E-mail"; Text[80])
        {
            Caption = 'Bill-to E-mail';
            Description = 'PN1.00';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteTag = '2023-06-28';
            ObsoleteReason = 'Not used.';
        }
        field(6014415; "NPR Document Processing"; Option)
        {
            ObsoleteState = Removed;
            ObsoleteTag = '2023-06-28';
            ObsoleteReason = 'Document Sending Profile from Customer is used.';
            Caption = 'Document Processing';
            Description = 'PN1.00';
            OptionCaption = 'Print,E-mail,OIO,Print and E-Mail';
            OptionMembers = Print,Email,OIO,PrintAndEmail;
            DataClassification = CustomerContent;
        }
        field(6014425; "NPR Order Type"; Option)
        {
            Caption = 'Order Type';
            OptionCaption = ',Order,Lending';
            OptionMembers = ,"Order",Lending;
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteTag = '2023-06-28';
            ObsoleteReason = 'Not used.';
        }
        field(6059931; "NPR Doc.Exch. F.work Status"; Option)
        {
            Caption = 'Doc. Exch. Framework Status';
            Description = 'NPR5.33';
            OptionCaption = ' ,Exported to Folder,Setup Changed,Delivered to Recepient,File Validation Error';
            OptionMembers = " ","Exported to Folder","Setup Changed","Delivered to Recepient","File Validation Error";
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteTag = '2023-06-28';
            ObsoleteReason = 'Not used.';
        }
        field(6059932; "NPR Doc. Exch. Exported"; Boolean)
        {
            Caption = 'Doc. Exch. Exported';
            Description = 'NPR5.33';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteTag = '2023-06-28';
            ObsoleteReason = 'Not used.';
        }
        field(6059933; "NPR Doc.Exch.Setup Path Used"; RecordID)
        {
            Caption = 'Doc. Exch. Setup Path Used';
            Description = 'NPR5.33';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteTag = '2023-06-28';
            ObsoleteReason = 'Not used.';
        }
        field(6059934; "NPR Doc. Exch. Exported to"; Text[250])
        {
            Caption = 'Doc. Exch. Exported to';
            Description = 'NPR5.33';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteTag = '2023-06-28';
            ObsoleteReason = 'Not used.';
        }
        field(6059935; "NPR Doc. Exch. File Exists"; Boolean)
        {
            Caption = 'Doc. Exch. File Exists';
            Description = 'NPR5.33';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteTag = '2023-06-28';
            ObsoleteReason = 'Not used.';
        }
        field(6151400; "NPR Magento Payment Amount"; Decimal)
        {
            CalcFormula = Sum("NPR Magento Payment Line".Amount WHERE("Document Table No." = CONST(114),
                                                                   "Document No." = FIELD("No.")));
            Caption = 'Payment Amount';
            Editable = false;
            FieldClass = FlowField;
        }
        field(6151405; "NPR External Order No."; Code[20])
        {
            Caption = 'External Order No.';
            Description = 'MAG2.12';
            DataClassification = CustomerContent;
        }

        field(6151420; "NPR Magento Coupon"; Text[20])
        {
            Caption = 'Magento Coupon';
            DataClassification = CustomerContent;
        }
        field(6151435; "NPR Group Code"; Code[20])
        {
            Caption = 'Group Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR Group Code".Code;
        }
        field(6151440; "NPR Sales Channel"; Code[20])
        {
            Caption = 'Sales Channel';
            DataClassification = CustomerContent;
            TableRelation = "NPR MM Loyalty Sales Channel".Code;
        }
    }
}
