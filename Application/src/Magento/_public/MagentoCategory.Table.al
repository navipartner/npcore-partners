﻿table 6151414 "NPR Magento Category"
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

            trigger OnValidate()
            begin
                if "Parent Category Id" = '' then
                    exit;

                if xRec."Parent Category Id" = Rec."Parent Category Id" then
                    exit;

                if Id = "Parent Category Id" then
                    Error(SameParentAndChildCattegoryIdErr, Id, "Parent Category Id");
            end;
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
                    Icon := CopyStr(IconName, 1, MaxStrLen(Icon));
            end;
        }
        field(130; "Short Description"; BLOB)
        {
            Caption = 'Short Description';
            DataClassification = CustomerContent;

            trigger OnLookup()
            var
                TempBlob: Codeunit "Temp Blob";
                OutStr: OutStream;
                InStr: InStream;
            begin
                TempBlob.CreateOutStream(OutStr);
                Rec."Short Description".CreateInStream(InStr);
                CopyStream(OutStr, InStr);
                if NaviConnectFunctions.NaviEditorEditTempBlob(TempBlob) then begin
                    if TempBlob.HasValue() then begin
                        TempBlob.CreateInStream(InStr);
                        Rec."Short Description".CreateOutStream(OutStr);
                        CopyStream(OutStr, InStr);
                    end else
                        Clear(Rec."Short Description");
                    Rec.Modify(true);
                end;
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
                    Picture := CopyStr(PictureName, 1, MaxStrLen(Picture));
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
                TempBlob: Codeunit "Temp Blob";
                OutStr: OutStream;
                InStr: InStream;
            begin
                TempBlob.CreateOutStream(OutStr);
                Rec."Description".CreateInStream(InStr);
                CopyStream(OutStr, InStr);
                if NaviConnectFunctions.NaviEditorEditTempBlob(TempBlob) then begin
                    if TempBlob.HasValue() then begin
                        TempBlob.CreateInStream(InStr);
                        Rec."Description".CreateOutStream(OutStr);
                        CopyStream(OutStr, InStr);
                    end else
                        Clear(Rec."Description");
                    Rec.Modify(true);
                end;
            end;
        }
        field(6059825; "Seo Link"; Text[250])
        {
            Caption = 'Seo Link';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                "Seo Link" := CopyStr(NaviConnectFunctions.SeoFormat("Seo Link"), 1, MaxStrLen("Seo Link"));
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
        field(6151479; "Replication Counter"; BigInteger)
        {
            Caption = 'Replication Counter';
            DataClassification = CustomerContent;
            ObsoleteState = Pending;
            ObsoleteTag = '2023-06-28';
            ObsoleteReason = 'Replaced by SystemRowVersion';
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
        key(Key3; "Replication Counter")
        {
            ObsoleteState = Pending;
            ObsoleteTag = '2023-06-28';
            ObsoleteReason = 'Replaced by SystemRowVersion';
        }
#IF NOT (BC17 or BC18 or BC19 or BC20)
        key(Key4; SystemRowVersion)
        {
        }
#ENDIF
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
        if MagentoCategory.FindSet() then
            repeat
                MagentoCategory.Delete(true);
            until MagentoCategory.Next() = 0;

        if (not SilentDelete) and (not GuiAllowed) then
            if not Confirm(Text000, false) then
                Error('');
        MagentoCategoryLink.SetRange("Category Id", Id);
        if MagentoCategoryLink.FindSet() then
            repeat
                MagentoCategoryLink.Delete(true);
            until MagentoCategoryLink.Next() = 0;
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
        SameParentAndChildCattegoryIdErr: Label 'Magento Category Id "%1" is the same as Parent Category Id "%2". It''s not allowed to have same child and parent IDs', Comment = '%1 = Id, %2 = Parent Category Id';

    internal procedure GetChildrenCount() ChildrenCount: Integer
    var
        MagentoCategory: Record "NPR Magento Category";
    begin
        MagentoCategory.SetRange("Parent Category Id", Id);
        ChildrenCount := MagentoCategory.Count();
        if MagentoCategory.FindSet() then
            repeat
                ChildrenCount += MagentoCategory.GetChildrenCount();
            until MagentoCategory.Next() = 0;

        exit(ChildrenCount);
    end;

    internal procedure GetNewChildGroupNo() NewChildGroupNo: Code[20]
    var
        MagentoCategory: Record "NPR Magento Category";
    begin
        MagentoCategory.SetRange("Parent Category Id", Id);
        if not MagentoCategory.FindLast() then
            exit(CopyStr(Id + '00', 1, MaxStrLen(NewChildGroupNo)));

        exit(IncStr(MagentoCategory.Id));
    end;

    internal procedure GetPath() MagentoCategoryPath: Text[250]
    var
        MagentoCategory: Record "NPR Magento Category";
    begin
        MagentoCategoryPath := Id;
        if MagentoCategory.Get("Parent Category Id") then
            repeat
                if MagentoCategory.Id = MagentoCategory."Parent Category Id" then
                    Error(SameParentAndChildCattegoryIdErr, MagentoCategory.Id, MagentoCategory."Parent Category Id");

                MagentoCategoryPath := CopyStr(MagentoCategory.Id + '/' + MagentoCategoryPath, 1, MaxStrLen(MagentoCategoryPath));
            until (not MagentoCategory.Get(MagentoCategory."Parent Category Id")) or (MagentoCategory.Id = '');

        exit(MagentoCategoryPath);
    end;

    local procedure GetRootNo(): Code[20]
    var
        MagentoCategory: Record "NPR Magento Category";
    begin
        if Root then
            exit(Id);

        if MagentoCategory.Get("Parent Category Id") then
            exit(MagentoCategory."Root No.");

        exit('');
    end;

    procedure SetSilentDelete(Value: Boolean)
    begin
        SilentDelete := Value;
    end;

    internal procedure UpdateChildPath()
    var
        MagentoCategory: Record "NPR Magento Category";
        NewPath: Text;
    begin
        MagentoCategory.SetRange("Parent Category Id", Id);
        if MagentoCategory.FindSet() then
            repeat
                NewPath := Path + '/' + MagentoCategory.Id;
                if (MagentoCategory.Path <> NewPath) or (MagentoCategory."Root No." <> "Root No.") then begin
                    MagentoCategory.Path := CopyStr(NewPath, 1, MaxStrLen(MagentoCategory.Path));
                    MagentoCategory."Root No." := "Root No.";
                    MagentoCategory.Modify();
                end;
                MagentoCategory.UpdateChildPath();
            until MagentoCategory.Next() = 0;
    end;
}
