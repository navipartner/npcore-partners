table 6151439 "NPR Magento Video Link"
{
    Access = Internal;
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
        field(30; "Sorting"; Integer)
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

    trigger OnInsert()
    var
        Lineno: Integer;
    begin
        MagentoVideoLink.SetRange("Item No.", "Item No.");
        if MagentoVideoLink.FindLast() then;
        Lineno := MagentoVideoLink."Line No." + 10000;

        Validate("Line No.", Lineno);
    end;

    var
        MagentoVideoLink: Record "NPR Magento Video Link";
}
