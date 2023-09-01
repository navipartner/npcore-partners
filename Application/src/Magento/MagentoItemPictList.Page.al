page 6151413 "NPR Magento Item Pict. List"
{
    Extensible = False;
    Caption = 'Item Pictures';
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = List;
    UsageCategory = None;
    SourceTable = "Name/Value Buffer";
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
                        field("Item No."; Rec.Name)
                        {
                            Editable = false;
                            ToolTip = 'Specifies the value of the Item No. field';
                            ApplicationArea = NPRRetail;
                        }
                        field(Description; Rec.Value)
                        {
                            Editable = false;
                            ToolTip = 'Specifies the value of the Description field';
                            ApplicationArea = NPRRetail;
                        }
                    }
                }
                part(MagentoPictureLinkSubform; "NPR Magento Pict. Link Subform")
                {
                    Caption = 'Pictures';
                    ShowFilter = false;
                    ApplicationArea = NPRRetail;
                }
            }
            part(MagentoPictureLinkSubform2; "NPR Magento Pict. Link Subform")
            {
                Caption = 'Pictures';
                ShowFilter = false;
                Visible = (NOT HasVariants);
                ApplicationArea = NPRRetail;
            }
        }
        area(factboxes)
        {
            part(MagentoPictureDragDropAddin; "NPR Magento DragDropPic. Addin")
            {
                Caption = 'Magento Picture';
                ApplicationArea = NPRRetail;
                Visible = HasVariants;
                Provider = MagentoPictureLinkSubform;
                SubPageLink = Type = const(Item),
                              Name = field("Picture Name");
            }

            part(MagentoPictureDragDropAddin2; "NPR Magento DragDropPic. Addin")
            {
                Caption = 'Magento Picture';
                ApplicationArea = NPRRetail;
                Visible = (not HasVariants);
                Provider = MagentoPictureLinkSubform2;
                SubPageLink = Type = const(Item),
                              Name = field("Picture Name");
            }
        }
    }


    trigger OnAfterGetCurrRecord()
    begin
        if (Rec.Name = '') then begin
            // If Rec.Name = '' it means we are looking at the main item line,
            // so we set the filters to blank here.
            CurrPage.MagentoPictureLinkSubform.PAGE.SetVarietyFilters('', '', '');
            CurrPage.MagentoPictureDragDropAddin.PAGE.SetVarietyFilters('', '', '');
        end else begin
#pragma warning disable AA0139
            CurrPage.MagentoPictureLinkSubform.PAGE.SetVarietyFilters(Variety, VarietyTable, Rec.Name);
            CurrPage.MagentoPictureDragDropAddin.PAGE.SetVarietyFilters(Variety, VarietyTable, Rec.Name);
#pragma warning restore
        end;
    end;

    trigger OnOpenPage()
    begin
        SetupSourceTable();
        if HasVariants then begin
            CurrPage.MagentoPictureLinkSubform.PAGE.SetItemNoFilter(ItemNo);
            CurrPage.MagentoPictureDragDropAddin.PAGE.SetItemNo(ItemNo);
            CurrPage.MagentoPictureDragDropAddin.PAGE.SetHidePicture(false);
        end else begin
            CurrPage.MagentoPictureLinkSubform2.PAGE.SetItemNoFilter(ItemNo);
            CurrPage.MagentoPictureDragDropAddin2.PAGE.SetItemNo(ItemNo);
            CurrPage.MagentoPictureDragDropAddin2.PAGE.SetHidePicture(false);
        end;
    end;

    var
        Item: Record Item;
        MagentoSetup: Record "NPR Magento Setup";
        ItemNo: Code[20];
        Variety: Code[10];
        VarietyTable: Code[40];
        ItemNoBlankErr: Label 'Item No. must not be blank';
        HasVariants: Boolean;
        MainItemPicturesLbl: Label 'Main Item Pictures';

    procedure SetItemNo(NewItemNo: Code[20])
    begin
        ItemNo := NewItemNo;
    end;

    local procedure SetupSourceTable()
    begin
        MagentoSetup.Get();
        if Item.Get(ItemNo) then;

        if ItemNo = '' then
            Error(ItemNoBlankErr);

        HasVariants := false;
        Rec.AddNewEntry('', MainItemPicturesLbl);

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

        Variety := Item."NPR Variety 1";
        VarietyTable := Item."NPR Variety 1 Table";

        VarietyValue.SetRange(Type, Item."NPR Variety 1");
        VarietyValue.SetRange(Table, Item."NPR Variety 1 Table");
        if (VarietyValue.IsEmpty()) then
            exit;

        VarietyValue.FindSet();
        repeat
            ItemVariant.SetRange("Item No.", Item."No.");
            ItemVariant.SetRange("NPR Variety 1", VarietyValue.Type);
            ItemVariant.SetRange("NPR Variety 1 Table", VarietyValue.Table);
            ItemVariant.SetRange("NPR Variety 1 Value", VarietyValue.Value);
            ItemVariant.SetRange("NPR Blocked", false);
            if (not ItemVariant.IsEmpty()) then
                Rec.AddNewEntry(UpperCase(VarietyValue.Value), VarietyValue.Description);
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

        Variety := Item."NPR Variety 2";
        VarietyTable := Item."NPR Variety 2 Table";

        VarietyValue.SetRange(Type, Item."NPR Variety 2");
        VarietyValue.SetRange(Table, Item."NPR Variety 2 Table");
        if (VarietyValue.IsEmpty()) then
            exit;

        VarietyValue.FindSet();
        repeat
            ItemVariant.SetRange("Item No.", Item."No.");
            ItemVariant.SetRange("NPR Variety 2", VarietyValue.Type);
            ItemVariant.SetRange("NPR Variety 2 Table", VarietyValue.Table);
            ItemVariant.SetRange("NPR Variety 2 Value", VarietyValue.Value);
            ItemVariant.SetRange("NPR Blocked", false);
            if (not ItemVariant.IsEmpty()) then
                Rec.AddNewEntry(UpperCase(VarietyValue.Value), VarietyValue.Description);
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

        Variety := Item."NPR Variety 3";
        VarietyTable := Item."NPR Variety 3 Table";

        VarietyValue.SetRange(Type, Item."NPR Variety 3");
        VarietyValue.SetRange(Table, Item."NPR Variety 3 Table");
        if (VarietyValue.IsEmpty()) then
            exit;

        VarietyValue.FindSet();
        repeat
            ItemVariant.SetRange("Item No.", Item."No.");
            ItemVariant.SetRange("NPR Variety 3", VarietyValue.Type);
            ItemVariant.SetRange("NPR Variety 3 Table", VarietyValue.Table);
            ItemVariant.SetRange("NPR Variety 3 Value", VarietyValue.Value);
            ItemVariant.SetRange("NPR Blocked", false);
            if (not ItemVariant.IsEmpty()) then
                Rec.AddNewEntry(UpperCase(VarietyValue.Value), VarietyValue.Description);
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

        Variety := Item."NPR Variety 4";
        VarietyTable := Item."NPR Variety 4 Table";

        VarietyValue.SetRange(Type, Item."NPR Variety 4");
        VarietyValue.SetRange(Table, Item."NPR Variety 4 Table");
        if (VarietyValue.IsEmpty()) then
            exit;

        VarietyValue.FindSet();
        repeat
            ItemVariant.SetRange("Item No.", Item."No.");
            ItemVariant.SetRange("NPR Variety 4", VarietyValue.Type);
            ItemVariant.SetRange("NPR Variety 4 Table", VarietyValue.Table);
            ItemVariant.SetRange("NPR Variety 4 Value", VarietyValue.Value);
            ItemVariant.SetRange("NPR Blocked", false);
            if (not ItemVariant.IsEmpty()) then
                Rec.AddNewEntry(UpperCase(VarietyValue.Value), VarietyValue.Description);
        until VarietyValue.Next() = 0;
    end;
}
