table 6151414 "Magento Category"
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
    // MAG2.26/MHA /20200601  CASE 404580 Magento "Item Group" renamed to "Category"

    Caption = 'Magento Category';
    DrillDownPageID = "Magento Category List";
    LookupPageID = "Magento Category List";

    fields
    {
        field(1;Id;Code[20])
        {
            Caption = 'Id';
            Description = 'MAG2.26';
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
        field(4;"Parent Category Id";Code[20])
        {
            Caption = 'Parent Category Id';
            Description = 'MAG2.26';
            TableRelation = "Magento Category";

            trigger OnValidate()
            var
                Overgruppe: Record "Magento Category";
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
            CalcFormula = Exist("Magento Category" WHERE ("Parent Category Id"=FIELD(Id)));
            Caption = 'Has Child Groups';
            Description = 'MAG2.26';
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
            CalcFormula = Count("Magento Category Link" WHERE ("Category Id"=FIELD(Id)));
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
        key(Key1;Id)
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
        MagentoCategory: Record "Magento Category";
        MagentoCategoryLink: Record "Magento Category Link";
        MagentoSetupMgt: Codeunit "Magento Setup Mgt.";
    begin
        if (not SilentDelete) and (not GuiAllowed) then
          if not Confirm(Text000,false) then
            Error('');

        MagentoCategory.SetRange("Parent Category Id",Id);
        MagentoCategory.SetSilentDelete(true);
        if MagentoCategory.FindSet then repeat
          MagentoCategory.Delete(true);
        until MagentoCategory.Next = 0;

        //-MAG2.26 [404580]
        if (not SilentDelete) and (not GuiAllowed) then
        //+MAG2.26 [404580]
        //-MAG1.20
          if not Confirm(Text000,false) then
            Error('');
        MagentoCategoryLink.SetRange("Category Id",Id);
        if MagentoCategoryLink.FindSet then repeat
           MagentoCategoryLink.Delete(true);
        until MagentoCategoryLink.Next = 0;
        //+MAG1.20
    end;

    trigger OnInsert()
    var
        MagentoSetupMgt: Codeunit "Magento Setup Mgt.";
    begin
        //-MAG2.26 [404580]
        if MagentoSetupMgt.HasSetupCategories() then
          exit;
        //+MAG2.26 [404580]

        Path := GetPath();
        //-MAG1.21
        "Root No." := GetRootNo();
        //+MAG1.21
    end;

    trigger OnModify()
    var
        MagentoSetupMgt: Codeunit "Magento Setup Mgt.";
    begin
        //-MAG2.26 [404580]
        if MagentoSetupMgt.HasSetupCategories() then
          exit;
        //+MAG2.26 [404580]

        Path := GetPath();
        //-MAG1.21
        "Root No." := GetRootNo();
        //+MAG1.21
        UpdateChildPath();
    end;

    var
        NaviConnectFunctions: Codeunit "Magento Functions";
        Text000: Label 'Do you wish to delete this category with its subcategories and all the item links?';
        SilentDelete: Boolean;

    procedure GetChildrenCount() ChildrenCount: Integer
    var
        MagentoCategory: Record "Magento Category";
    begin
        MagentoCategory.SetRange("Parent Category Id",Id);
        ChildrenCount := MagentoCategory.Count;
        if MagentoCategory.FindSet then
          repeat
            ChildrenCount += MagentoCategory.GetChildrenCount();
          until MagentoCategory.Next = 0;

        exit(ChildrenCount);
    end;

    procedure GetNewChildGroupNo() NewChildGroupNo: Code[20]
    var
        MagentoCategory: Record "Magento Category";
    begin
        MagentoCategory.SetRange("Parent Category Id",Id);
        if not MagentoCategory.FindLast then
          exit(Id + '00');

        exit(IncStr(MagentoCategory.Id));
    end;

    procedure GetPath() MagentoCategoryPath: Text[250]
    var
        MagentoCategory: Record "Magento Category";
    begin
        MagentoCategoryPath := Id;
        if MagentoCategory.Get("Parent Category Id") then repeat
          MagentoCategoryPath := MagentoCategory.Id + '/' + MagentoCategoryPath;
        until (not MagentoCategory.Get(MagentoCategory."Parent Category Id")) or (MagentoCategory.Id = '');

        exit(MagentoCategoryPath);
    end;

    local procedure GetRootNo() RootNo: Code[20]
    var
        MagentoCategory: Record "Magento Category";
    begin
        //-MAG1.21
        if Root then
          exit(Id);

        if MagentoCategory.Get("Parent Category Id") then;
          exit(MagentoCategory."Root No.");

        exit('');
        //+MAG1.21
    end;

    procedure SetSilentDelete(Value: Boolean)
    begin
        SilentDelete := Value;
    end;

    procedure UpdateChildPath()
    var
        MagentoCategory: Record "Magento Category";
        MagentoSetupMgt: Codeunit "Magento Setup Mgt.";
        NewPath: Text;
    begin
        MagentoCategory.SetRange("Parent Category Id",Id);
        if MagentoCategory.FindSet then
          repeat
            //-MAG1.21
            //MagentoCategory.Path := Path + '/' + MagentoCategory.Id;
            //MagentoCategory.MODIFY;
            NewPath := Path + '/' + MagentoCategory.Id;
            if (MagentoCategory.Path <> NewPath) or (MagentoCategory."Root No." <> "Root No.") then begin
              MagentoCategory.Path := NewPath;
              MagentoCategory."Root No." := "Root No.";
              MagentoCategory.Modify;
            end;
            //+MAG1.21
            MagentoCategory.UpdateChildPath();
          until MagentoCategory.Next = 0;
    end;
}

