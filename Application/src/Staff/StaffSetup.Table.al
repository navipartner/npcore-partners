table 6014485 "NPR Staff Setup"
{
    Caption = 'Staff Setup';
    DataClassification = CustomerContent;
    ObsoleteState = Removed;
    ObsoleteReason = 'Not used.';

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            Caption = 'Primary Key';
            DataClassification = CustomerContent;
        }
        field(10; "Internal Unit Price"; Option)
        {
            Caption = 'Internal Unit Price';
            DataClassification = CustomerContent;
            OptionCaption = 'Unit Cost,Last Direct Cost';
            OptionMembers = "Unit Cost","Last Direct";
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used';
        }
        field(30; "Staff Disc. Group"; Code[20])
        {
            Caption = 'Staff Disc. Group';
            DataClassification = CustomerContent;
            TableRelation = "Customer Discount Group";
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used';
        }
        field(40; "Staff Price Group"; Code[10])
        {
            Caption = 'Staff Price Group';
            DataClassification = CustomerContent;
            TableRelation = "Customer Price Group";
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used';
        }
        field(50; "Staff SalesPrice Calc Codeunit"; Integer)
        {
            Caption = 'Staff SalesPrice Calc Codeunit';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used';
        }
    }

    keys
    {
        key(PK; "Primary Key")
        {
            Clustered = true;
        }
    }
}
