table 6151414 "NPR Magento Category"
{
    Caption = 'Magento Category';
    DataClassification = CustomerContent;
    DrillDownPageID = "NPR Magento Category List";
    LookupPageID = "NPR Magento Category List";

    fields
    {
        field(1; Id; Code[20])
        {
            Caption = 'Id';
            DataClassification = CustomerContent;
            NotBlank = true;
        }
        field(2; Name; Text[50])
        {
            Caption = 'Name';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if "Seo Link" = '' then
                    Validate("Seo Link", Name);
            end;
        }
        field(4; "Parent Category Id"; Code[20])
        {
            Caption = 'Parent Category Id';
            DataClassification = CustomerContent;
            TableRelation = "NPR Magento Category";
        }
        field(5; Level; Integer)
        {
            Caption = 'Level';
            DataClassification = CustomerContent;
        }
        field(10; Path; Text[250])
        {
            Caption = 'Path';
            DataClassification = CustomerContent;
        }
        field(25; "Has Child Groups"; Boolean)
        {
            CalcFormula = Exist("NPR Magento Category" WHERE("Parent Category Id" = FIELD(Id)));
            Caption = 'Has Child Groups';
            Editable = false;
            FieldClass = FlowField;
        }
        field(30; "Is Active"; Boolean)
        {
            Caption = 'Is Active';
            DataClassification = CustomerContent;
            InitValue = true;
        }
        field(40; "Is Anchor"; Boolean)
        {
            Caption = 'Is Anchor';
            DataClassification = CustomerContent;
            InitValue = true;
        }
        field(45; "Show In Navigation Menu"; Boolean)
        {
            Caption = 'Show In Navigation Menu';
            DataClassification = CustomerContent;
            InitValue = true;
        }
        field(100; Root; Boolean)
        {
            Caption = 'Root';
            DataClassification = CustomerContent;
        }
        field(110; "Root No."; Code[20])
        {
            Caption = 'Root No.';
            DataClassification = CustomerContent;
        }
        field(120; Icon; Text[250])
        {
            Caption = 'Icon';
            DataClassification = CustomerContent;

            trigger OnLookup()
            var
                MagentoFunctions: Codeunit "NPR Magento Functions";
                IconName: Text;
            begin
                IconName := MagentoFunctions.LookupPicture(Enum::"NPR Magento Picture Type"::"Item Group", Icon);
                if IconName <> '' then
                    Icon := IconName;
            end;
        }
        field(130; "Short Description"; BLOB)
        {
            Caption = 'Short Description';
            DataClassification = CustomerContent;

            trigger OnLookup()
            var
                RecRef: RecordRef;
                FieldRef: FieldRef;
            begin
                RecRef.GetTable(Rec);
                FieldRef := RecRef.Field(FieldNo("Short Description"));
                NaviConnectFunctions.NaviEditorEditBlob(FieldRef);
                RecRef.Modify(true);
            end;
        }
        field(1000; "Item Count"; Integer)
        {
            CalcFormula = Count("NPR Magento Category Link" WHERE("Category Id" = FIELD(Id)));
            Caption = 'Item Count';
            Editable = false;
            FieldClass = FlowField;
        }
        field(6059806; Picture; Text[250])
        {
            Caption = 'Picture';
            DataClassification = CustomerContent;

            trigger OnLookup()
            var
                PictureName: Text;
            begin
                PictureName := NaviConnectFunctions.LookupPicture(Enum::"NPR Magento Picture Type"::"Item Group", Picture);
                if PictureName <> '' then
                    Picture := PictureName;
            end;
        }
        field(6059808; "Sorting"; Integer)
        {
            Caption = 'Sorting';
            DataClassification = CustomerContent;
        }
        field(6059811; Description; BLOB)
        {
            Caption = 'Description';
            DataClassification = CustomerContent;

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
        field(6059825; "Seo Link"; Text[250])
        {
            Caption = 'Seo Link';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                "Seo Link" := NaviConnectFunctions.SeoFormat("Seo Link");
            end;
        }
        field(6060021; "Meta Title"; Text[100])
        {
            Caption = 'Meta Title';
            DataClassification = CustomerContent;
        }
        field(6060022; "Meta Keywords"; Text[250])
        {
            Caption = 'Meta Keywords';
            DataClassification = CustomerContent;
        }
        field(6060023; "Meta Description"; Text[250])
        {
            Caption = 'Meta Description';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; Id)
        {
        }
        key(Key2; Path)
        {
        }
    }

    trigger OnDelete()
    var
        MagentoCategory: Record "NPR Magento Category";
        MagentoCategoryLink: Record "NPR Magento Category Link";
    begin
        if (not SilentDelete) and (not GuiAllowed) then
            if not Confirm(Text000, false) then
                Error('');

        MagentoCategory.SetRange("Parent Category Id", Id);
        MagentoCategory.SetSilentDelete(true);
        if MagentoCategory.FindSet then
            repeat
                MagentoCategory.Delete(true);
            until MagentoCategory.Next = 0;

        if (not SilentDelete) and (not GuiAllowed) then
            if not Confirm(Text000, false) then
                Error('');
        MagentoCategoryLink.SetRange("Category Id", Id);
        if MagentoCategoryLink.FindSet then
            repeat
                MagentoCategoryLink.Delete(true);
            until MagentoCategoryLink.Next = 0;
    end;

    trigger OnInsert()
    var
        MagentoSetupMgt: Codeunit "NPR Magento Setup Mgt.";
    begin
        if MagentoSetupMgt.HasSetupCategories() then
            exit;

        Path := GetPath();
        "Root No." := GetRootNo();
    end;

    trigger OnModify()
    var
        MagentoSetupMgt: Codeunit "NPR Magento Setup Mgt.";
    begin
        if MagentoSetupMgt.HasSetupCategories() then
            exit;

        Path := GetPath();
        "Root No." := GetRootNo();
        UpdateChildPath();
    end;

    var
        NaviConnectFunctions: Codeunit "NPR Magento Functions";
        Text000: Label 'Do you wish to delete this category with its subcategories and all the item links?';
        SilentDelete: Boolean;

    procedure GetChildrenCount() ChildrenCount: Integer
    var
        MagentoCategory: Record "NPR Magento Category";
    begin
        MagentoCategory.SetRange("Parent Category Id", Id);
        ChildrenCount := MagentoCategory.Count;
        if MagentoCategory.FindSet then
            repeat
                ChildrenCount += MagentoCategory.GetChildrenCount();
            until MagentoCategory.Next = 0;

        exit(ChildrenCount);
    end;

    procedure GetNewChildGroupNo() NewChildGroupNo: Code[20]
    var
        MagentoCategory: Record "NPR Magento Category";
    begin
        MagentoCategory.SetRange("Parent Category Id", Id);
        if not MagentoCategory.FindLast then
            exit(Id + '00');

        exit(IncStr(MagentoCategory.Id));
    end;

    procedure GetPath() MagentoCategoryPath: Text[250]
    var
        MagentoCategory: Record "NPR Magento Category";
    begin
        MagentoCategoryPath := Id;
        if MagentoCategory.Get("Parent Category Id") then
            repeat
                MagentoCategoryPath := MagentoCategory.Id + '/' + MagentoCategoryPath;
            until (not MagentoCategory.Get(MagentoCategory."Parent Category Id")) or (MagentoCategory.Id = '');

        exit(MagentoCategoryPath);
    end;

    local procedure GetRootNo() RootNo: Code[20]
    var
        MagentoCategory: Record "NPR Magento Category";
    begin
        if Root then
            exit(Id);

        if MagentoCategory.Get("Parent Category Id") then;
        exit(MagentoCategory."Root No.");

        exit('');
    end;

    procedure SetSilentDelete(Value: Boolean)
    begin
        SilentDelete := Value;
    end;

    procedure UpdateChildPath()
    var
        MagentoCategory: Record "NPR Magento Category";
        NewPath: Text;
    begin
        MagentoCategory.SetRange("Parent Category Id", Id);
        if MagentoCategory.FindSet then
            repeat
                NewPath := Path + '/' + MagentoCategory.Id;
                if (MagentoCategory.Path <> NewPath) or (MagentoCategory."Root No." <> "Root No.") then begin
                    MagentoCategory.Path := NewPath;
                    MagentoCategory."Root No." := "Root No.";
                    MagentoCategory.Modify;
                end;
                MagentoCategory.UpdateChildPath();
            until MagentoCategory.Next = 0;
    end;
}