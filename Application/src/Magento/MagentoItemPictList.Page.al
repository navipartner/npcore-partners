page 6151413 "NPR Magento Item Pict. List"
{
    Caption = 'Item Pictures';
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = List;
    UsageCategory = None;
    SourceTable = "Item Variant";
    SourceTableTemporary = true;

    layout
    {
        area(content)
        {
            group(Control6150618)
            {
                ShowCaption = false;
                Visible = HasVariants;
                group(Variants)
                {
                    Caption = 'Variants';
                    repeater(Group)
                    {
                        field("Item No."; Rec."Item No.")
                        {
                            ApplicationArea = All;
                            Editable = false;
                            ToolTip = 'Specifies the value of the Item No. field';
                        }
                        field(Description; Rec.Description)
                        {
                            ApplicationArea = All;
                            Editable = false;
                            ToolTip = 'Specifies the value of the Description field';
                        }
                    }
                }
                part(MagentoPictureLinkSubform; "NPR Magento Pict. Link Subform")
                {
                    Caption = 'Pictures';
                    ShowFilter = false;
                    ApplicationArea = All;
                }
            }
            part(MagentoPictureLinkSubform2; "NPR Magento Pict. Link Subform")
            {
                Caption = 'Pictures';
                ShowFilter = false;
                Visible = (NOT HasVariants);
                ApplicationArea = All;
            }
        }
        area(factboxes)
        {
            part(MagentoPictureDragDropAddin; "NPR Magento DragDropPic. Addin")
            {
                Caption = 'Magento Picture';
                ApplicationArea = All;
            }
        }
    }


    trigger OnAfterGetCurrRecord()
    begin
        case MagentoSetup."Picture Variety Type" of
            MagentoSetup."Picture Variety Type"::Fixed:
                begin
                    CurrPage.MagentoPictureLinkSubform.PAGE.SetVariantValueCode(Rec."Item No.");
                    CurrPage.MagentoPictureDragDropAddin.PAGE.SetVariantValueCode(Rec."Item No.");
                end;
            MagentoSetup."Picture Variety Type"::"Select on Item":
                begin
                    case Item."NPR Magento Pict. Variety Type" of
                        Item."NPR Magento Pict. Variety Type"::"Variety 1":
                            begin
                                CurrPage.MagentoPictureLinkSubform.PAGE.SetVarietyFilters(Rec."NPR Variety 1", Rec."NPR Variety 1 Table", Rec."NPR Variety 1 Value");
                                CurrPage.MagentoPictureDragDropAddin.PAGE.SetVarietyFilters(Rec."NPR Variety 1", Rec."NPR Variety 1 Table", Rec."NPR Variety 1 Value");
                            end;
                        Item."NPR Magento Pict. Variety Type"::"Variety 2":
                            begin
                                CurrPage.MagentoPictureLinkSubform.PAGE.SetVarietyFilters(Rec."NPR Variety 2", Rec."NPR Variety 2 Table", Rec."NPR Variety 2 Value");
                                CurrPage.MagentoPictureDragDropAddin.PAGE.SetVarietyFilters(Rec."NPR Variety 2", Rec."NPR Variety 2 Table", Rec."NPR Variety 2 Value");
                            end;
                        Item."NPR Magento Pict. Variety Type"::"Variety 3":
                            begin
                                CurrPage.MagentoPictureLinkSubform.PAGE.SetVarietyFilters(Rec."NPR Variety 3", Rec."NPR Variety 3 Table", Rec."NPR Variety 3 Value");
                                CurrPage.MagentoPictureDragDropAddin.PAGE.SetVarietyFilters(Rec."NPR Variety 3", Rec."NPR Variety 3 Table", Rec."NPR Variety 3 Value");
                            end;
                        Item."NPR Magento Pict. Variety Type"::"Variety 4":
                            begin
                                CurrPage.MagentoPictureLinkSubform.PAGE.SetVarietyFilters(Rec."NPR Variety 4", Rec."NPR Variety 4 Table", Rec."NPR Variety 4 Value");
                                CurrPage.MagentoPictureDragDropAddin.PAGE.SetVarietyFilters(Rec."NPR Variety 4", Rec."NPR Variety 4 Table", Rec."NPR Variety 4 Value");
                            end;
                    end;
                end;
            MagentoSetup."Picture Variety Type"::"Variety 1":
                begin
                    CurrPage.MagentoPictureLinkSubform.PAGE.SetVarietyFilters(Rec."NPR Variety 1", Rec."NPR Variety 1 Table", Rec."NPR Variety 1 Value");
                    CurrPage.MagentoPictureDragDropAddin.PAGE.SetVarietyFilters(Rec."NPR Variety 1", Rec."NPR Variety 1 Table", Rec."NPR Variety 1 Value");
                end;
            MagentoSetup."Picture Variety Type"::"Variety 2":
                begin
                    CurrPage.MagentoPictureLinkSubform.PAGE.SetVarietyFilters(Rec."NPR Variety 2", Rec."NPR Variety 2 Table", Rec."NPR Variety 2 Value");
                    CurrPage.MagentoPictureDragDropAddin.PAGE.SetVarietyFilters(Rec."NPR Variety 2", Rec."NPR Variety 2 Table", Rec."NPR Variety 2 Value");
                end;
            MagentoSetup."Picture Variety Type"::"Variety 3":
                begin
                    CurrPage.MagentoPictureLinkSubform.PAGE.SetVarietyFilters(Rec."NPR Variety 3", Rec."NPR Variety 3 Table", Rec."NPR Variety 3 Value");
                    CurrPage.MagentoPictureDragDropAddin.PAGE.SetVarietyFilters(Rec."NPR Variety 3", Rec."NPR Variety 3 Table", Rec."NPR Variety 3 Value");
                end;
            MagentoSetup."Picture Variety Type"::"Variety 4":
                begin
                    CurrPage.MagentoPictureLinkSubform.PAGE.SetVarietyFilters(Rec."NPR Variety 4", Rec."NPR Variety 4 Table", Rec."NPR Variety 4 Value");
                    CurrPage.MagentoPictureDragDropAddin.PAGE.SetVarietyFilters(Rec."NPR Variety 4", Rec."NPR Variety 4 Table", Rec."NPR Variety 4 Value");
                end;
        end;
    end;

    trigger OnOpenPage()
    begin
        CurrPage.MagentoPictureLinkSubform.PAGE.SetItemNoFilter(ItemNo);
        CurrPage.MagentoPictureLinkSubform2.PAGE.SetItemNoFilter(ItemNo);
        CurrPage.MagentoPictureDragDropAddin.PAGE.SetItemNo(ItemNo);
        CurrPage.MagentoPictureDragDropAddin.PAGE.SetHidePicture(true);
        SetupSourceTable();
    end;

    var
        Item: Record Item;
        MagentoSetup: Record "NPR Magento Setup";
        ItemNo: Code[20];
        Text000: Label 'Item No. must not be blank';
        HasVariants: Boolean;
        Text001: Label 'Main Item Pictures';
        VarietyTooLongErr: Label 'You cannot use variety with more than %1 characters.';

    procedure SetItemNo(NewItemNo: Code[20])
    begin
        ItemNo := NewItemNo;
    end;

    local procedure SetupSourceTable()
    begin
        MagentoSetup.Get();
        if Item.Get(ItemNo) then;

        if ItemNo = '' then
            Error(Text000);

        HasVariants := false;
        Rec.Init();
        Rec."Item No." := '';
        Rec.Code := '';
        Rec.Description := Text001;
        Rec.Insert();

        case MagentoSetup."Variant System" of
            MagentoSetup."Variant System"::Variety:
                begin
                    case MagentoSetup."Picture Variety Type" of
                        MagentoSetup."Picture Variety Type"::Fixed:
                            begin
                                SetupVarietyFixed();
                            end;
                        MagentoSetup."Picture Variety Type"::"Select on Item":
                            begin
                                SetupVarietySelectOnItem();
                            end;
                        MagentoSetup."Picture Variety Type"::"Variety 1":
                            begin
                                SetupVariety1();
                            end;
                        MagentoSetup."Picture Variety Type"::"Variety 2":
                            begin
                                SetupVariety2();
                            end;
                        MagentoSetup."Picture Variety Type"::"Variety 3":
                            begin
                                SetupVariety3()
                            end;
                        MagentoSetup."Picture Variety Type"::"Variety 4":
                            begin
                                SetupVariety4();
                            end;
                    end;
                end;
        end;

        HasVariants := Rec.Count() > 1;
    end;

    local procedure SetupVarietyFixed()
    begin
        if MagentoSetup."Variant Picture Dimension" = '' then
            exit;

        case MagentoSetup."Variant Picture Dimension" of
            Item."NPR Variety 1":
                begin
                    SetupVariety1();
                end;
            Item."NPR Variety 2":
                begin
                    SetupVariety2();
                end;
            Item."NPR Variety 3":
                begin
                    SetupVariety3();
                end;
            Item."NPR Variety 4":
                begin
                    SetupVariety4();
                end;
        end;
    end;

    local procedure SetupVarietySelectOnItem()
    begin
        case Item."NPR Magento Pict. Variety Type" of
            Item."NPR Magento Pict. Variety Type"::"Variety 1":
                begin
                    SetupVariety1();
                end;
            Item."NPR Magento Pict. Variety Type"::"Variety 2":
                begin
                    SetupVariety2();
                end;
            Item."NPR Magento Pict. Variety Type"::"Variety 3":
                begin
                    SetupVariety3();
                end;
            Item."NPR Magento Pict. Variety Type"::"Variety 4":
                begin
                    SetupVariety4();
                end;
        end;
    end;

    local procedure SetupVariety1()
    var
        ItemVariant: Record "Item Variant";
        VarietyValue: Record "NPR Variety Value";
    begin
        if Item."NPR Variety 1" = '' then
            exit;
        if Item."NPR Variety 1 Table" = '' then
            exit;

        VarietyValue.SetRange(Type, Item."NPR Variety 1");
        VarietyValue.SetRange(Table, Item."NPR Variety 1 Table");
        if not VarietyValue.FindSet() then
            exit;

        repeat
            ItemVariant.SetRange("Item No.", Item."No.");
            ItemVariant.SetRange("NPR Variety 1", VarietyValue.Type);
            ItemVariant.SetRange("NPR Variety 1 Table", VarietyValue.Table);
            ItemVariant.SetRange("NPR Variety 1 Value", VarietyValue.Value);
            ItemVariant.SetRange("NPR Blocked", false);
            if ItemVariant.FindFirst() then begin
                Rec.Init();
                if StrLen(VarietyValue.Value) > MaxStrLen(Rec."Item No.") then
                    Error(VarietyTooLongErr)
                else
                    Rec."Item No." := CopyStr(VarietyValue.Value, 1, MaxStrLen(Rec."Item No."));
                Rec.Description := VarietyValue.Description;
                Rec."NPR Variety 1" := VarietyValue.Type;
                Rec."NPR Variety 1 Table" := VarietyValue.Table;
                Rec."NPR Variety 1 Value" := VarietyValue.Value;
                Rec.Insert();
            end;
        until VarietyValue.Next() = 0;
    end;

    local procedure SetupVariety2()
    var
        ItemVariant: Record "Item Variant";
        VarietyValue: Record "NPR Variety Value";
    begin
        if Item."NPR Variety 2" = '' then
            exit;
        if Item."NPR Variety 2 Table" = '' then
            exit;

        VarietyValue.SetRange(Type, Item."NPR Variety 2");
        VarietyValue.SetRange(Table, Item."NPR Variety 2 Table");
        if not VarietyValue.FindSet() then
            exit;

        repeat
            ItemVariant.SetRange("Item No.", Item."No.");
            ItemVariant.SetRange("NPR Variety 2", VarietyValue.Type);
            ItemVariant.SetRange("NPR Variety 2 Table", VarietyValue.Table);
            ItemVariant.SetRange("NPR Variety 2 Value", VarietyValue.Value);
            ItemVariant.SetRange("NPR Blocked", false);
            if ItemVariant.FindFirst() then begin
                Rec.Init();
                if StrLen(VarietyValue.Value) > MaxStrLen(Rec."Item No.") then
                    Error(VarietyTooLongErr)
                else
                    Rec."Item No." := CopyStr(VarietyValue.Value, 1, MaxStrLen(Rec."Item No."));
                Rec.Description := VarietyValue.Description;
                Rec."NPR Variety 2" := VarietyValue.Type;
                Rec."NPR Variety 2 Table" := VarietyValue.Table;
                Rec."NPR Variety 2 Value" := VarietyValue.Value;
                Rec.Insert();
            end;
        until VarietyValue.Next() = 0;
    end;

    local procedure SetupVariety3()
    var
        ItemVariant: Record "Item Variant";
        VarietyValue: Record "NPR Variety Value";
    begin
        if Item."NPR Variety 3" = '' then
            exit;
        if Item."NPR Variety 3 Table" = '' then
            exit;

        VarietyValue.SetRange(Type, Item."NPR Variety 3");
        VarietyValue.SetRange(Table, Item."NPR Variety 3 Table");
        if not VarietyValue.FindSet() then
            exit;

        repeat
            ItemVariant.SetRange("Item No.", Item."No.");
            ItemVariant.SetRange("NPR Variety 3", VarietyValue.Type);
            ItemVariant.SetRange("NPR Variety 3 Table", VarietyValue.Table);
            ItemVariant.SetRange("NPR Variety 3 Value", VarietyValue.Value);
            ItemVariant.SetRange("NPR Blocked", false);
            if ItemVariant.FindFirst() then begin
                Rec.Init();
                if StrLen(VarietyValue.Value) > MaxStrLen(Rec."Item No.") then
                    Error(VarietyTooLongErr)
                else
                    Rec."Item No." := CopyStr(VarietyValue.Value, 1, MaxStrLen(Rec."Item No."));
                Rec.Description := VarietyValue.Description;
                Rec."NPR Variety 3" := VarietyValue.Type;
                Rec."NPR Variety 3 Table" := VarietyValue.Table;
                Rec."NPR Variety 3 Value" := VarietyValue.Value;
                Rec.Insert();
            end;
        until VarietyValue.Next() = 0;
    end;

    local procedure SetupVariety4()
    var
        ItemVariant: Record "Item Variant";
        VarietyValue: Record "NPR Variety Value";
    begin
        if Item."NPR Variety 4" = '' then
            exit;
        if Item."NPR Variety 4 Table" = '' then
            exit;

        VarietyValue.SetRange(Type, Item."NPR Variety 4");
        VarietyValue.SetRange(Table, Item."NPR Variety 4 Table");
        if not VarietyValue.FindSet() then
            exit;

        repeat
            ItemVariant.SetRange("Item No.", Item."No.");
            ItemVariant.SetRange("NPR Variety 4", VarietyValue.Type);
            ItemVariant.SetRange("NPR Variety 4 Table", VarietyValue.Table);
            ItemVariant.SetRange("NPR Variety 4 Value", VarietyValue.Value);
            ItemVariant.SetRange("NPR Blocked", false);
            if ItemVariant.FindFirst() then begin
                Rec.Init();
                if StrLen(VarietyValue.Value) > MaxStrLen(Rec."Item No.") then
                    Error(VarietyTooLongErr)
                else
                    Rec."Item No." := CopyStr(VarietyValue.Value, 1, MaxStrLen(Rec."Item No."));
                Rec.Description := VarietyValue.Description;
                Rec."NPR Variety 4" := VarietyValue.Type;
                Rec."NPR Variety 4 Table" := VarietyValue.Table;
                Rec."NPR Variety 4 Value" := VarietyValue.Value;
                Rec.Insert();
            end;
        until VarietyValue.Next() = 0;
    end;
}