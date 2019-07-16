table 6151414 "Magento Item Group"
{
    // MAG1.00/MH  /20150113  CASE 199932 Refactored Object from Web Integration
    // MAG1.01/MH  /20150115  CASE 199932 Updated Picture Lookup and NaviEditor Plugin
    // MAG1.04/MH  /20150217  CASE 199932 Deleted unused fields and functions
    // MAG1.12/MH  /20150409  CASE 210904 Added field 10 Path and is used for sorting in Tree View Pages
    // MAG1.14/MH  /20150429  CASE 212526 Changed parameters for LookupPicture() to PictureType, PictureName
    // MAG1.20/TS  /20150908  CASE 221542 Delete Magento Item Group Link when Item Groups are deleted
    // MAG1.21/TR  /20151023  CASE 225294 LookupPageId changed to Magento Item Group List
    // MAG1.21/TS  /20151118  CASE 227359 Deleted Field Is Used and Added Field Root
    // MAG1.21/MHA /20151120  CASE 223835 NaviConnect
    // MAG2.00/MHA /20160525  CASE 242557 Magento Integration
    // MAG2.07/MHA /20170912  CASE 289369 Increased length of field 6060021 "Meta Title" from 50 to 70
    // MAG2.17/TS  /20181017  CASE 324862 Added Field Icon
    // MAG2.17/TS  /20181031  CASE 333862 Seo Link should be filled as well
    // MAG2.20/BHR /20190409  CASE 346352 Field 130 "Short Description"
    // MAG2.22/MHA /20190614  CASE 358258 Extended field 6060021 "Meta Title" from 70 to 100

    Caption = 'Magento Item Group';
    DrillDownPageID = "Magento Item Group List";
    LookupPageID = "Magento Item Group List";

    fields
    {
        field(1;"No.";Code[20])
        {
            Caption = 'No.';
            NotBlank = true;
        }
        field(2;Name;Text[50])
        {
            Caption = 'Name';

            trigger OnValidate()
            begin
                //-MAG2.17 [333862]
                if "Seo Link" = '' then
                  Validate("Seo Link",Name);
                //+MAG2.17 [333862]
            end;
        }
        field(4;"Parent Item Group No.";Code[20])
        {
            Caption = 'Parent Item Group No.';
            TableRelation = "Magento Item Group";

            trigger OnValidate()
            var
                Overgruppe: Record "Magento Item Group";
                "---": Integer;
                ok: Boolean;
            begin
            end;
        }
        field(5;Level;Integer)
        {
            Caption = 'Level';
        }
        field(10;Path;Text[250])
        {
            Caption = 'Path';
            Description = 'MAG1.12';
        }
        field(25;"Has Child Groups";Boolean)
        {
            CalcFormula = Exist("Magento Item Group" WHERE ("Parent Item Group No."=FIELD("No.")));
            Caption = 'Has Child Groups';
            Editable = false;
            FieldClass = FlowField;
        }
        field(30;"Is Active";Boolean)
        {
            Caption = 'Is Active';
            InitValue = true;
        }
        field(40;"Is Anchor";Boolean)
        {
            Caption = 'Is Anchor';
            InitValue = true;
        }
        field(45;"Show In Navigation Menu";Boolean)
        {
            Caption = 'Show In Navigation Menu';
            InitValue = true;
        }
        field(100;Root;Boolean)
        {
            Caption = 'Root';
            Description = 'MAG1.21';
        }
        field(110;"Root No.";Code[20])
        {
            Caption = 'Root No.';
            Description = 'MAG1.21';
        }
        field(120;Icon;Text[250])
        {
            Caption = 'Icon';
            Description = 'MAG2.17';

            trigger OnLookup()
            var
                MagentoFunctions: Codeunit "Magento Functions";
                IconName: Text;
            begin
                //-MAG2.17 [324862]
                IconName := MagentoFunctions.LookupPicture(MagentoFunctions."PictureType.ItemGroup",Icon);
                if IconName <> '' then
                  Icon := IconName;
                //+324862 [324862]
            end;
        }
        field(130;"Short Description";BLOB)
        {
            Caption = 'Short Description';

            trigger OnLookup()
            var
                RecRef: RecordRef;
                FieldRef: FieldRef;
            begin
                //-MAG2.20 [346352]
                RecRef.GetTable(Rec);
                FieldRef := RecRef.Field(FieldNo("Short Description"));
                NaviConnectFunctions.NaviEditorEditBlob(FieldRef);
                RecRef.Modify(true);
                //+MAG2.20 [346352]
            end;
        }
        field(1000;"Item Count";Integer)
        {
            CalcFormula = Count("Magento Item Group Link" WHERE ("Item Group"=FIELD("No.")));
            Caption = 'Item Count';
            Editable = false;
            FieldClass = FlowField;
        }
        field(6059806;Picture;Text[250])
        {
            Caption = 'Picture';
            Description = 'MAG1.21';

            trigger OnLookup()
            var
                PictureName: Text;
            begin
                PictureName := NaviConnectFunctions.LookupPicture(NaviConnectFunctions."PictureType.ItemGroup",Picture);
                if PictureName <> '' then
                  Picture := PictureName;
            end;
        }
        field(6059808;Sorting;Integer)
        {
            Caption = 'Sorting';
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
        field(6059825;"Seo Link";Text[250])
        {
            Caption = 'Seo Link';

            trigger OnValidate()
            begin
                "Seo Link" := NaviConnectFunctions.SeoFormat("Seo Link");
            end;
        }
        field(6060021;"Meta Title";Text[100])
        {
            Caption = 'Meta Title';
            Description = 'MAG2.07,MAG2.22';
        }
        field(6060022;"Meta Keywords";Text[250])
        {
            Caption = 'Meta Keywords';
        }
        field(6060023;"Meta Description";Text[250])
        {
            Caption = 'Meta Description';
        }
    }

    keys
    {
        key(Key1;"No.")
        {
        }
        key(Key2;Path)
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    var
        ItemGroups: Record "Magento Item Group";
        MagentoItemGroupLink: Record "Magento Item Group Link";
    begin
        if (not SilentDelete) and (not GuiAllowed) then
          if not Confirm(Text000,false) then
            Error('');

        ItemGroups.SetRange("Parent Item Group No.","No.");
        ItemGroups.SetSilentDelete(true);
        if ItemGroups.FindSet then repeat
          ItemGroups.Delete(true);
        until ItemGroups.Next = 0;

        //-MAG1.20
        if not Confirm(Text000,false) then
          Error('');
        MagentoItemGroupLink.SetRange("Item Group","No.");
        if MagentoItemGroupLink.FindSet then repeat
           MagentoItemGroupLink.Delete(true);
        until MagentoItemGroupLink.Next = 0;
        //+MAG1.20
    end;

    trigger OnInsert()
    begin
        TestField(Name);

        Path := GetPath();
        //-MAG1.21
        "Root No." := GetRootNo();
        //+MAG1.21
    end;

    trigger OnModify()
    begin
        TestField(Name);

        Path := GetPath();
        //-MAG1.21
        "Root No." := GetRootNo();
        //+MAG1.21
        UpdateChildPath();
    end;

    var
        NaviConnectFunctions: Codeunit "Magento Functions";
        Text000: Label 'Do you wish to delete this category , its subcategories and all the item links  ?';
        SilentDelete: Boolean;
        Error001: Label 'Renamed is not allowed';
        Error002: Label 'Child Item Groups must be numbered with the same start number as the parent (%1##)';

    procedure GetChildrenCount() ChildrenCount: Integer
    var
        ItemGroup: Record "Magento Item Group";
    begin
        ItemGroup.SetRange("Parent Item Group No.","No.");
        ChildrenCount := ItemGroup.Count;
        if ItemGroup.FindSet then
          repeat
            ChildrenCount += ItemGroup.GetChildrenCount();
          until ItemGroup.Next = 0;

        exit(ChildrenCount);
    end;

    procedure GetNewChildGroupNo() NewChildGroupNo: Code[20]
    var
        ItemGroup: Record "Magento Item Group";
    begin
        ItemGroup.SetRange("Parent Item Group No.","No.");
        if not ItemGroup.FindLast then
          exit("No." + '00');

        exit(IncStr(ItemGroup."No."));
    end;

    procedure GetPath() ItemGroupPath: Text[250]
    var
        ItemGroup: Record "Magento Item Group";
    begin
        ItemGroupPath := "No.";
        if ItemGroup.Get("Parent Item Group No.") then repeat
          ItemGroupPath := ItemGroup."No." + '/' + ItemGroupPath;
        until (not ItemGroup.Get(ItemGroup."Parent Item Group No.")) or (ItemGroup."No." = '');

        exit(ItemGroupPath);
    end;

    local procedure GetRootNo() RootNo: Code[20]
    var
        ItemGroup: Record "Magento Item Group";
    begin
        //-MAG1.21
        if Root then
          exit("No.");

        if ItemGroup.Get("Parent Item Group No.") then;
          exit(ItemGroup."Root No.");

        exit('');
        //+MAG1.21
    end;

    procedure SetSilentDelete(Value: Boolean)
    begin
        SilentDelete := Value;
    end;

    procedure UpdateChildPath()
    var
        ItemGroup: Record "Magento Item Group";
        NewPath: Text;
    begin
        ItemGroup.SetRange("Parent Item Group No.","No.");
        if ItemGroup.FindSet then
          repeat
            //-MAG1.21
            //ItemGroup.Path := Path + '/' + ItemGroup."No.";
            //ItemGroup.MODIFY;
            NewPath := Path + '/' + ItemGroup."No.";
            if (ItemGroup.Path <> NewPath) or (ItemGroup."Root No." <> "Root No.") then begin
              ItemGroup.Path := NewPath;
              ItemGroup."Root No." := "Root No.";
              ItemGroup.Modify;
            end;
            //+MAG1.21
            ItemGroup.UpdateChildPath();
          until ItemGroup.Next = 0;
    end;
}

