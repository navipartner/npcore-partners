table 6151412 "NPR Magento Picture Link"
{
    Caption = 'Magento Picture Link';
    DataClassification = CustomerContent;

    fields
    {
        field(2; "Item No."; Code[20])
        {
            Caption = 'No.';
            DataClassification = CustomerContent;
            TableRelation = Item;
        }
        field(3; Path; Text[150])
        {
            Caption = 'Path';
            DataClassification = CustomerContent;
        }
        field(7; "Short Text"; Text[250])
        {
            Caption = 'Short Text';
            DataClassification = CustomerContent;
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

            trigger OnValidate()
            begin
                Sorting := "Line No.";
            end;
        }
        field(25; "Base Image"; Boolean)
        {
            Caption = 'Base Image';
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                MagPicture: Record "NPR Magento Picture Link";
            begin
                MagPicture.SetRange("Variant Value Code", "Variant Value Code");
                MagPicture.SetRange("Variety Type", "Variety Type");
                MagPicture.SetRange("Variety Table", "Variety Table");
                MagPicture.SetRange("Variety Value", "Variety Value");
                MagPicture.SetRange("Item No.", "Item No.");
                MagPicture.SetFilter("Line No.", '<>%1', "Line No.");
                if "Base Image" then
                    MagPicture.ModifyAll("Base Image", false);
            end;
        }
        field(26; "Small Image"; Boolean)
        {
            Caption = 'Small Image';
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                MagPicture: Record "NPR Magento Picture Link";
            begin
                MagPicture.SetRange("Variant Value Code", "Variant Value Code");
                MagPicture.SetRange("Variety Type", "Variety Type");
                MagPicture.SetRange("Variety Table", "Variety Table");
                MagPicture.SetRange("Variety Value", "Variety Value");
                MagPicture.SetRange("Item No.", "Item No.");
                MagPicture.SetFilter("Line No.", '<>%1', "Line No.");
                if "Small Image" then
                    MagPicture.ModifyAll("Small Image", false);
            end;
        }
        field(27; Thumbnail; Boolean)
        {
            Caption = 'Thumbnail';
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                MagPicture: Record "NPR Magento Picture Link";
            begin
                MagPicture.SetRange("Variant Value Code", "Variant Value Code");
                MagPicture.SetRange("Variety Type", "Variety Type");
                MagPicture.SetRange("Variety Table", "Variety Table");
                MagPicture.SetRange("Variety Value", "Variety Value");
                MagPicture.SetRange("Item No.", "Item No.");
                MagPicture.SetFilter("Line No.", '<>%1', "Line No.");
                if Thumbnail then
                    MagPicture.ModifyAll(Thumbnail, false);
            end;
        }
        field(30; "Sorting"; Integer)
        {
            Caption = 'Sorting';
            DataClassification = CustomerContent;
        }
        field(40; "Variety Type"; Code[10])
        {
            Caption = 'Variety Type';
            DataClassification = CustomerContent;
            TableRelation = "NPR Variety";
        }
        field(50; "Variety Table"; Code[40])
        {
            Caption = 'Variety Table';
            DataClassification = CustomerContent;
            TableRelation = "NPR Variety Table".Code WHERE(Type = FIELD("Variety Type"));
        }
        field(60; "Variety Value"; Code[50])
        {
            Caption = 'Variety Value';
            DataClassification = CustomerContent;
            TableRelation = "NPR Variety Value".Value WHERE(Type = FIELD("Variety Type"),
                                                         Table = FIELD("Variety Table"));
        }
        field(90; "Picture Name"; Text[250])
        {
            Caption = 'Picture Name';
            DataClassification = CustomerContent;
            TableRelation = "NPR Magento Picture".Name WHERE(Type = CONST(Item));
            ValidateTableRelation = false;

            trigger OnLookup()
            var
                PictureName: Text;
            begin
                PictureName := MagentoFunctions.LookupPicture(Enum::"NPR Magento Picture Type"::Item, "Picture Name");
                if PictureName <> '' then begin
                    "Picture Name" := CopyStr(PictureName, 1, MaxStrLen("Picture Name"));
                    if "Short Text" = '' then
                        "Short Text" := "Picture Name";
                end;
            end;
        }
    }

    keys
    {
        key(Key1; "Item No.", "Line No.")
        {
        }
        key(Key2; "Variant Value Code")
        {
        }
    }

    trigger OnInsert()
    var
        MagPicture: Record "NPR Magento Picture Link";
    begin
        TestField("Picture Name");
        MagPicture.SetRange("Variant Value Code", "Variant Value Code");
        MagPicture.SetRange("Variety Type", "Variety Type");
        MagPicture.SetRange("Variety Table", "Variety Table");
        MagPicture.SetRange("Variety Value", "Variety Value");
        MagPicture.SetRange("Item No.", "Item No.");

        MagPicture.SetRange("Base Image", true);
        if MagPicture.IsEmpty then
            "Base Image" := true;
        if MagPicture.IsEmpty then
            "Small Image" := true;
        MagPicture.SetRange(Thumbnail, true);
        if MagPicture.IsEmpty then
            Thumbnail := true;
    end;

    trigger OnModify()
    begin
        TestField("Picture Name");
    end;

    var
        MagentoFunctions: Codeunit "NPR Magento Functions";
}
