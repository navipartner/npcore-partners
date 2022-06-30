table 6014659 "NPR Auxiliary Item"
{
    Access = Public;
    Caption = 'Aux Item';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Item No."; Code[20])
        {
            Caption = 'Item No.';
            DataClassification = CustomerContent;
            TableRelation = Item;
        }
        field(10; "Item Addon No."; Code[20])
        {
            Caption = 'Item AddOn No.';
            DataClassification = CustomerContent;
            TableRelation = "NPR NpIa Item AddOn";
        }
        field(20; "TM Ticket Type"; Code[10])
        {
            Caption = 'Ticket Type';
            DataClassification = CustomerContent;
            TableRelation = "NPR TM Ticket Type";
        }
        field(30; "NPRE Item Routing Profile"; Code[20])
        {
            Caption = 'Rest. Item Routing Profile';
            DataClassification = CustomerContent;
            TableRelation = "NPR NPRE Item Routing Profile";
        }
        field(40; "Variety Group"; Code[20])
        {
            Caption = 'Variety Group';
            DataClassification = CustomerContent;
            TableRelation = "NPR Variety Group";
            trigger OnValidate()
            begin
                CopyFromVarietyGroup();
            end;
        }
        field(50; "Item Status"; Code[10])
        {
            Caption = 'Item Status';
            DataClassification = CustomerContent;
            TableRelation = "NPR Item Status";
        }
        field(60; "Attribute Set ID"; Integer)
        {
            Caption = 'Attribute Set ID';
            DataClassification = CustomerContent;
            TableRelation = "NPR Magento Attribute Set";
        }
        field(70; "Magento Brand"; Code[20])
        {
            Caption = 'Magento Brand';
            DataClassification = CustomerContent;
            TableRelation = "NPR Magento Brand";
        }
        field(80; "Has Variants"; Boolean)
        {
            //This field is used for NpXml template
            CalcFormula = Exist("Item Variant" WHERE("Item No." = FIELD("Item No.")));
            Caption = 'Has Variants';
            FieldClass = FlowField;
        }
        field(90; "Variety 1"; Code[10])
        {
            Caption = 'Variety 1';
            DataClassification = CustomerContent;
            TableRelation = "NPR Variety";
        }
        field(95; "Variety 1 Table"; Code[40])
        {
            Caption = 'Variety 1 Table';
            DataClassification = CustomerContent;
            TableRelation = "NPR Variety Table".Code WHERE(Type = FIELD("Variety 1"));
        }
        field(100; "Variety 2"; Code[10])
        {
            Caption = 'Variety 2';
            DataClassification = CustomerContent;
            TableRelation = "NPR Variety";
        }
        field(105; "Variety 2 Table"; Code[40])
        {
            Caption = 'Variety 2 Table';
            DataClassification = CustomerContent;
            TableRelation = "NPR Variety Table".Code WHERE(Type = FIELD("Variety 2"));
        }
        field(110; "Variety 3"; Code[10])
        {
            Caption = 'Variety 3';
            DataClassification = CustomerContent;
            TableRelation = "NPR Variety";
        }
        field(115; "Variety 3 Table"; Code[40])
        {
            Caption = 'Variety 3 Table';
            DataClassification = CustomerContent;
            TableRelation = "NPR Variety Table".Code WHERE(Type = FIELD("Variety 3"));
        }
        field(120; "Variety 4"; Code[10])
        {
            Caption = 'Variety 4';
            DataClassification = CustomerContent;
            TableRelation = "NPR Variety";
        }
        field(125; "Variety 4 Table"; Code[40])
        {
            Caption = 'Variety 4 Table';
            DataClassification = CustomerContent;
            TableRelation = "NPR Variety Table".Code WHERE(Type = FIELD("Variety 4"));
        }
        field(130; "Has Accessories"; Boolean)
        {
            Caption = 'Has Accessories';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(140; "Main Item/Variation"; enum "NPR Main Item/Variation")
        {
            Caption = 'Main Item/Variation';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(150; "Main Item No."; Code[20])
        {
            Caption = 'Main Item No.';
            DataClassification = CustomerContent;
            TableRelation = Item."No.";

            trigger OnValidate()
            var
                Item: Record Item;
                MainItemVariationMgt: Codeunit "NPR Main Item Variation Mgt.";
                CannotChangeManuallyErr: Label 'The field "%2" cannot be changed manually.', Comment = 'Main Item No. field caption';
            begin
                if xRec."Main Item No." = "Main Item No." then
                    exit;
                TestField("Main Item/Variation", "Main Item/Variation"::" ");
                if xRec."Main Item No." <> '' then
                    Error(CannotChangeManuallyErr, FieldCaption("Main Item No."));
                IF "Main Item No." <> '' THEN begin
                    Item.Get("Main Item No.");
                    MainItemVariationMgt.AddAsVariation(Item, Rec, "Main Item No.");
                end;
            end;
        }
        field(1000; "Replication Counter"; BigInteger)
        {
            Caption = 'Replication Counter';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Item No.")
        {
            Clustered = true;
        }
        key(Key2; "Replication Counter") { }
        key(MainItemVariationLinks; "Main Item No.", "Main Item/Variation") { }
    }

    local procedure CopyFromVarietyGroup()
    var
        Item: Record Item;
        xItem: Record Item;
        VrtGroup: Record "NPR Variety Group";
        VrtCheck: Codeunit "NPR Variety Check";
    begin
        Item.Get(Rec."Item No.");
        xItem.Get(xRec."Item No.");

        //updateitem
        if (not VrtGroup.Get(Rec."Variety Group")) then
            VrtGroup.Init();

        Rec."Variety 1" := VrtGroup."Variety 1";
        Rec."Variety 1 Table" := VrtGroup.GetVariety1Table(Item);
        Rec."Variety 2" := VrtGroup."Variety 2";
        Rec."Variety 2 Table" := VrtGroup.GetVariety2Table(Item);
        Rec."Variety 3" := VrtGroup."Variety 3";
        Rec."Variety 3 Table" := VrtGroup.GetVariety3Table(Item);
        Rec."Variety 4" := VrtGroup."Variety 4";
        Rec."Variety 4 Table" := VrtGroup.GetVariety4Table(Item);
        Item."NPR Cross Variety No." := VrtGroup."Cross Variety No.";

        //Above code will be executed IF its a temporary record - Below wont be executed if its a temporary record
        if Item.IsTemporary then
            exit;
        //check change allowed
        VrtCheck.ChangeItemVariety(Item, xItem);
        //copy base table info (if needed)
        VrtGroup.CopyTableData(Rec);
    end;
}