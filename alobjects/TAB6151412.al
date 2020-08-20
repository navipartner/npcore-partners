table 6151412 "Magento Picture Link"
{
    // MAG1.00/MH/20150113  CASE 199932 Refactored Object from Web Integration
    // MAG1.01/MH/20150115  CASE 199932 Updated Picture Lookup
    // MAG1.09/MHA /20150316  CASE 206395 Deleted Obsolete field 6059806 "Internet Number" and associated key
    // MAG1.14/MHA /20150429  CASE 212526 Changed parameters for LookupPicture() to PictureType, PictureName
    // MAG1.16/MHA /20150401  CASE 210548 Removed Type::Attribute and added Type::Customer
    // MAG1.19/TS  /20150706  CASE 214946 Edited Option caption on Type field
    // MAG1.21/MHA /20151021  CASE 223835 Renamed field 11 from "Variax Dimension Code" to "Variant Value Code"
    //                                      Deleted unused fields:
    //                                      - 1 Type
    //                                      - 4 Color
    //                                      - 5 Size
    //                                      - 6 Text
    //                                      - 10 Variant Code
    //                                      - 12 Variant Description
    //                                      - 20 Code
    //                                      - 28 Exclude
    //                                      - 110 Entry No.
    // MAG1.21/MHA /20151119  CASE 227583 Removed TESTFIELD of "Short Text"
    // MAG2.00/MHA /20160525  CASE 242557 Magento Integration
    // MAG2.01/MHA /20161128  CASE 259281 Picture Name must have a value
    // MAG2.20/MHA /20190430  CASE 353499 Removed validation on "Picture Name"
    // MAG2.22/MHA /20190625  CASE 359285 Added fields 40 "Variety Type", 50 "Variety Table", 60 "Variety Value"

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
            Description = 'MAG1.21';
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
                MagPicture: Record "Magento Picture Link";
            begin
                //-MAG1.21
                //MagPicture.SETRANGE(Type,Type);
                MagPicture.SetRange("Variant Value Code", "Variant Value Code");
                //+MAG1.21
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
                MagPicture: Record "Magento Picture Link";
            begin
                //-MAG1.21
                //MagPicture.SETRANGE(Type,Type);
                MagPicture.SetRange("Variant Value Code", "Variant Value Code");
                //+MAG1.21
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
                MagPicture: Record "Magento Picture Link";
            begin
                //-MAG1.21
                //MagPicture.SETRANGE(Type,Type);
                MagPicture.SetRange("Variant Value Code", "Variant Value Code");
                //+MAG1.21
                MagPicture.SetRange("Item No.", "Item No.");
                MagPicture.SetFilter("Line No.", '<>%1', "Line No.");
                if Thumbnail then
                    MagPicture.ModifyAll(Thumbnail, false);
            end;
        }
        field(30; Sorting; Integer)
        {
            Caption = 'Sorting';
            DataClassification = CustomerContent;
        }
        field(40; "Variety Type"; Code[10])
        {
            Caption = 'Variety Type';
            DataClassification = CustomerContent;
            Description = 'MAG2.22';
            TableRelation = Variety;
        }
        field(50; "Variety Table"; Code[40])
        {
            Caption = 'Variety Table';
            DataClassification = CustomerContent;
            Description = 'MAG2.22';
            TableRelation = "Variety Table".Code WHERE(Type = FIELD("Variety Type"));
        }
        field(60; "Variety Value"; Code[20])
        {
            Caption = 'Variety Value';
            DataClassification = CustomerContent;
            Description = 'MAG2.22';
            TableRelation = "Variety Value".Value WHERE(Type = FIELD("Variety Type"),
                                                         Table = FIELD("Variety Table"));
        }
        field(90; "Picture Name"; Text[250])
        {
            Caption = 'Picture Name';
            DataClassification = CustomerContent;
            Description = 'MAG2.20';
            TableRelation = "Magento Picture".Name WHERE(Type = CONST(Item));
            //This property is currently not supported
            //TestTableRelation = false;
            ValidateTableRelation = false;

            trigger OnLookup()
            var
                PictureName: Text;
            begin
                PictureName := MagentoFunctions.LookupPicture(MagentoFunctions."PictureType.Item", "Picture Name");
                if PictureName <> '' then begin
                    "Picture Name" := PictureName;
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
        MagPicture: Record "Magento Picture Link";
    begin
        //-MAG1.21
        //TESTFIELD("Short Text");
        //+MAG1.21
        //-MAG1.21
        //"Entry No." := 0;
        //+MAG1.21

        //-MAG2.01 [259281]
        TestField("Picture Name");
        //+MAG2.01 [259281]
        //-MAG1.21
        ///MagPicture.SETRANGE(Type,Type);
        MagPicture.SetRange("Variant Value Code", "Variant Value Code");
        //+MAG1.21
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
        //-MAG2.01 [259281]
        TestField("Picture Name");
        //+MAG2.01 [259281]
    end;

    trigger OnRename()
    var
        noRename: Label 'No rename allowed. Delete and make a new';
    begin
    end;

    var
        MagentoFunctions: Codeunit "Magento Functions";
}

