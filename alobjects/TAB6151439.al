table 6151439 "Magento Video Link"
{
    // MAG2.15/TS  /20180531 CASE 311926 Table Created for Magento Video Link

    Caption = 'Magento Video Link';
    DataClassification = CustomerContent;

    fields
    {
        field(2; "Item No."; Code[20])
        {
            Caption = 'No.';
            DataClassification = CustomerContent;
            TableRelation = Item;
        }
        field(3; "Video Url"; Text[150])
        {
            Caption = 'Video Url';
            DataClassification = CustomerContent;
        }
        field(7; "Short Text"; Text[250])
        {
            Caption = 'Short Text';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                TestField("Video Url");
            end;
        }
        field(11; "Variant Value Code"; Code[20])
        {
            Caption = 'Variant Value Code';
            DataClassification = CustomerContent;
        }
        field(15; "Line No."; Integer)
        {
            Caption = 'Line No.';
            DataClassification = CustomerContent;
        }
        field(30; Sorting; Integer)
        {
            Caption = 'Sorting';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                TestField("Video Url");
            end;
        }
    }

    keys
    {
        key(Key1; "Item No.", "Line No.")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    var
        ErrorUsed: Label 'Error. You can not delete an image that is marked for listing.';
    begin
    end;

    trigger OnInsert()
    var
        Lineno: Integer;
    begin
        MagentoVideoLink.SetRange("Item No.", "Item No.");
        if MagentoVideoLink.FindLast then;
        Lineno := MagentoVideoLink."Line No." + 10000;

        Validate("Line No.", Lineno);
    end;

    trigger OnRename()
    var
        noRename: Label 'No rename allowed. Delete and make a new';
    begin
    end;

    var
        MagentoVideoLink: Record "Magento Video Link";
}

