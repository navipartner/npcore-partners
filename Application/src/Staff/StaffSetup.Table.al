table 6014485 "NPR Staff Setup"
{
    Caption = 'Staff Setup';
    DataClassification = CustomerContent;

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
        }
        field(30; "Staff Disc. Group"; Code[20])
        {
            Caption = 'Staff Disc. Group';
            DataClassification = CustomerContent;
            TableRelation = "Customer Discount Group";
        }
        field(40; "Staff Price Group"; Code[10])
        {
            Caption = 'Staff Price Group';
            DataClassification = CustomerContent;
            TableRelation = "Customer Price Group";
        }
        field(50; "Staff SalesPrice Calc Codeunit"; Integer)
        {
            Caption = 'Staff SalesPrice Calc Codeunit';
            DataClassification = CustomerContent;
            TableRelation = Object.ID where(Type = CONST(Codeunit));

            trigger OnLookup()
            var
                AllObj: Record AllObj;
            begin
                AllObj.Reset;
                AllObj.SetRange("Object Type", AllObj."Object Type"::Codeunit);

                if Page.RunModal(696, AllObj) = ACTION::LookupOK then begin
                    "Staff SalesPrice Calc Codeunit" := AllObj."Object ID";
                    Modify();
                end;
            end;
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
