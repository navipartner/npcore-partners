table 6151421 "Magento Store Item Group"
{
    // MAG1.16/TR/20150409  CASE 210548 Table created to support multi store values for Magento item groups.
    // MAG1.17/TR/20150522 CASE 210548 Object modified for use
    // MAG2.00/MHA/20160525  CASE 242557 Magento Integration
    // MAG2.07/MHA /20170912  CASE 289369 Increased length of field 6060022 "Meta Title" from 50 to 70
    // MAG2.22/MHA /20190614  CASE 358258 Extended field 6060022 "Meta Title" from 70 to 100

    Caption = 'Magento Store Item Group';
    LookupPageID = "Magento Item Groups";

    fields
    {
        field(1;"No.";Code[20])
        {
            Caption = 'No.';
            NotBlank = true;
            TableRelation = "Magento Item Group";
        }
        field(5;"Store Code";Code[32])
        {
            Caption = 'Store Code';
            TableRelation = "Magento Store";
        }
        field(7;"Website Code";Code[32])
        {
            Caption = 'Website Code';
        }
        field(10;Name;Text[50])
        {
            Caption = 'Name';
        }
        field(14;"Parent Item Group No.";Code[20])
        {
            Caption = 'Parent Item Group No.';

            trigger OnValidate()
            var
                Overgruppe: Record "Magento Item Group";
                "---": Integer;
                ok: Boolean;
            begin
            end;
        }
        field(30;"Is Active";Boolean)
        {
            Caption = 'Is Active';
            InitValue = true;
        }
        field(45;"Show In Navigation Menu";Boolean)
        {
            Caption = 'Show In Navigation Menu';
            InitValue = true;
        }
        field(6059806;Picture;Text[100])
        {
            Caption = 'Picture';

            trigger OnLookup()
            var
                PictureName: Text;
            begin
                PictureName := NaviConnectFunctions.LookupPicture(NaviConnectFunctions."PictureType.ItemGroup",Picture);
                if PictureName <> '' then
                  Picture := PictureName;
            end;
        }
        field(6059811;Description;BLOB)
        {
            Caption = 'Description';

            trigger OnLookup()
            var
                RecRef: RecordRef;
                FieldRef: FieldRef;
            begin
                RecRef.GetTable(Rec);
                FieldRef := RecRef.Field(FieldNo(Description));
                NaviConnectFunctions.NaviEditorEditBlob(FieldRef);
                RecRef.Modify(true);
            end;
        }
        field(6059820;"Seo Link";Text[250])
        {
            Caption = 'Seo Link';

            trigger OnValidate()
            var
                "Children Alt. Item Group": Record "Magento Item Group";
                "Parent Alt. Item Group": Record "Magento Item Group";
            begin
                "Seo Link" :=  NaviConnectFunctions.SeoFormat("Seo Link");
            end;
        }
        field(6060022;"Meta Title";Text[100])
        {
            Caption = 'Meta Title';
            Description = 'MAG2.07,MAG2.22';
        }
        field(6060024;"Meta Keywords";Text[250])
        {
            Caption = 'Meta Keywords';
        }
        field(6060026;"Meta Description";Text[250])
        {
            Caption = 'Meta Description';
        }
    }

    keys
    {
        key(Key1;"No.","Store Code")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    var
        ItemGroups: Record "Magento Item Group";
    begin
    end;

    trigger OnInsert()
    var
        MagentoStore: Record "Magento Store";
    begin
        MagentoStore.Get("Store Code");
        "Website Code" := MagentoStore."Website Code";
        TransferFromItemGroup();
    end;

    trigger OnModify()
    var
        "Parent Item group": Record "Magento Item Group";
        "Local Item Groups": Record "Magento Item Group";
    begin
        if MagentoItemGroup.Get("No.") then
          "Parent Item Group No." := MagentoItemGroup."Parent Item Group No.";
    end;

    trigger OnRename()
    var
        MagentoStore: Record "Magento Store";
    begin
        MagentoStore.Get("Store Code");
        "Website Code" := MagentoStore."Website Code";

        if MagentoItemGroup.Get("No.") then
          "Parent Item Group No." := MagentoItemGroup."Parent Item Group No.";
    end;

    var
        MagentoItemGroup: Record "Magento Item Group";
        NaviConnectFunctions: Codeunit "Magento Functions";
        SilentDelete: Boolean;

    procedure TransferFromItemGroup()
    begin
        if MagentoItemGroup.Get("No.") then begin
          Name := MagentoItemGroup.Name;
          "Parent Item Group No." := MagentoItemGroup."Parent Item Group No.";
          "Is Active" :=MagentoItemGroup."Is Active";
          "Show In Navigation Menu" := MagentoItemGroup."Show In Navigation Menu";
          Picture := MagentoItemGroup.Picture;
          MagentoItemGroup.CalcFields(Description);
          Description := MagentoItemGroup.Description;
          "Seo Link" := MagentoItemGroup."Seo Link";
          "Meta Title" := MagentoItemGroup."Meta Title";
          "Meta Keywords" := MagentoItemGroup."Meta Keywords";
          "Meta Description" := MagentoItemGroup."Meta Description";
        end;
    end;
}

