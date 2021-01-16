page 6151413 "NPR Magento Item Pict. List"
{
    // MAG1.02/MHA /20150202  CASE 199932 Object created - Contains a list of Color associated to an Item
    // MAG1.09/MHA /20150316  CASE 206395 Added Manual SetColorCode on SubPage
    // MAG1.21/MHA /20151104  CASE 223835 Changed functionality from Hardcoded Color to Variant Dimension Setup implementing Variety and VariaX without direct references
    //                                    SourceTable is temporary and Variant Dimension Value is buffered in Rec."Item No."
    // MAG1.22/MHA /20160426  CASE 239773 Change iteration on Item Variant during Setup of Variety Source Table
    // MAG2.00/MHA /20160525  CASE 242557 Magento Integration
    // MAG2.02/TS  /20170125  CASE 262261 Removed all reference to Variax
    // MAG2.22/MHA /20190625  CASE 359285 Added Variant Systems; Variety (Select on Item),Variety 1,Variety 2,Variety 3,Variety 4
    // MAG2.22/MHA /20190722  CASE 361003 Only variety values with active variants should be included
    // MAG2.25/MHA /20200318  CASE 389934 Added PagePart MagentoPictureLinkSubform2 for prettier Web Client view on Non Variant Items

    Caption = 'Item Pictures';
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = ListPlus;
    UsageCategory = Administration;
    ApplicationArea = All;
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
                        field("Item No."; "Item No.")
                        {
                            ApplicationArea = All;
                            Editable = false;
                            ToolTip = 'Specifies the value of the Item No. field';
                        }
                        field(Description; Description)
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

    actions
    {
    }

    trigger OnAfterGetCurrRecord()
    begin
        //-MAG2.22 [359285]
        case MagentoSetup."Picture Variety Type" of
            MagentoSetup."Picture Variety Type"::Fixed:
                begin
                    CurrPage.MagentoPictureLinkSubform.PAGE.SetVariantValueCode("Item No.");
                    CurrPage.MagentoPictureDragDropAddin.PAGE.SetVariantValueCode("Item No.");
                end;
            MagentoSetup."Picture Variety Type"::"Select on Item":
                begin
                    case Item."NPR Magento Pict. Variety Type" of
                        Item."NPR Magento Pict. Variety Type"::"Variety 1":
                            begin
                                CurrPage.MagentoPictureLinkSubform.PAGE.SetVarietyFilters("NPR Variety 1", "NPR Variety 1 Table", "NPR Variety 1 Value");
                                CurrPage.MagentoPictureDragDropAddin.PAGE.SetVarietyFilters("NPR Variety 1", "NPR Variety 1 Table", "NPR Variety 1 Value");
                            end;
                        Item."NPR Magento Pict. Variety Type"::"Variety 2":
                            begin
                                CurrPage.MagentoPictureLinkSubform.PAGE.SetVarietyFilters("NPR Variety 2", "NPR Variety 2 Table", "NPR Variety 2 Value");
                                CurrPage.MagentoPictureDragDropAddin.PAGE.SetVarietyFilters("NPR Variety 2", "NPR Variety 2 Table", "NPR Variety 2 Value");
                            end;
                        Item."NPR Magento Pict. Variety Type"::"Variety 3":
                            begin
                                CurrPage.MagentoPictureLinkSubform.PAGE.SetVarietyFilters("NPR Variety 3", "NPR Variety 3 Table", "NPR Variety 3 Value");
                                CurrPage.MagentoPictureDragDropAddin.PAGE.SetVarietyFilters("NPR Variety 3", "NPR Variety 3 Table", "NPR Variety 3 Value");
                            end;
                        Item."NPR Magento Pict. Variety Type"::"Variety 4":
                            begin
                                CurrPage.MagentoPictureLinkSubform.PAGE.SetVarietyFilters("NPR Variety 4", "NPR Variety 4 Table", "NPR Variety 4 Value");
                                CurrPage.MagentoPictureDragDropAddin.PAGE.SetVarietyFilters("NPR Variety 4", "NPR Variety 4 Table", "NPR Variety 4 Value");
                            end;
                    end;
                end;
            MagentoSetup."Picture Variety Type"::"Variety 1":
                begin
                    CurrPage.MagentoPictureLinkSubform.PAGE.SetVarietyFilters("NPR Variety 1", "NPR Variety 1 Table", "NPR Variety 1 Value");
                    CurrPage.MagentoPictureDragDropAddin.PAGE.SetVarietyFilters("NPR Variety 1", "NPR Variety 1 Table", "NPR Variety 1 Value");
                end;
            MagentoSetup."Picture Variety Type"::"Variety 2":
                begin
                    CurrPage.MagentoPictureLinkSubform.PAGE.SetVarietyFilters("NPR Variety 2", "NPR Variety 2 Table", "NPR Variety 2 Value");
                    CurrPage.MagentoPictureDragDropAddin.PAGE.SetVarietyFilters("NPR Variety 2", "NPR Variety 2 Table", "NPR Variety 2 Value");
                end;
            MagentoSetup."Picture Variety Type"::"Variety 3":
                begin
                    CurrPage.MagentoPictureLinkSubform.PAGE.SetVarietyFilters("NPR Variety 3", "NPR Variety 3 Table", "NPR Variety 3 Value");
                    CurrPage.MagentoPictureDragDropAddin.PAGE.SetVarietyFilters("NPR Variety 3", "NPR Variety 3 Table", "NPR Variety 3 Value");
                end;
            MagentoSetup."Picture Variety Type"::"Variety 4":
                begin
                    CurrPage.MagentoPictureLinkSubform.PAGE.SetVarietyFilters("NPR Variety 4", "NPR Variety 4 Table", "NPR Variety 4 Value");
                    CurrPage.MagentoPictureDragDropAddin.PAGE.SetVarietyFilters("NPR Variety 4", "NPR Variety 4 Table", "NPR Variety 4 Value");
                end;
        end;
        //+MAG2.22 [359285]
    end;

    trigger OnOpenPage()
    begin
        //-MAG1.21
        CurrPage.MagentoPictureLinkSubform.PAGE.SetItemNoFilter(ItemNo);
        //-MAG2.25 [389934]
        CurrPage.MagentoPictureLinkSubform2.PAGE.SetItemNoFilter(ItemNo);
        //+MAG2.25 [389934]
        CurrPage.MagentoPictureDragDropAddin.PAGE.SetItemNo(ItemNo);
        CurrPage.MagentoPictureDragDropAddin.PAGE.SetHidePicture(true);
        SetupSourceTable();
        //+MAG1.21
    end;

    var
        Item: Record Item;
        MagentoSetup: Record "NPR Magento Setup";
        ItemNo: Code[20];
        Text000: Label 'Item No. must not be blank';
        HasVariants: Boolean;
        Text001: Label 'Main Item Pictures';

    procedure SetItemNo(NewItemNo: Code[20])
    begin
        ItemNo := NewItemNo;
    end;

    local procedure SetupSourceTable()
    begin
        //-MAG1.21
        MagentoSetup.Get;
        //-MAG2.22 [359285]
        if Item.Get(ItemNo) then;
        //+MAG2.22 [359285]

        if ItemNo = '' then
            Error(Text000);

        HasVariants := false;
        Init;
        "Item No." := '';
        Code := '';
        Description := Text001;
        Insert;

        //-MAG2.22 [359285]
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
        //+MAG2.22 [359285]

        HasVariants := Count > 1;
        //+MAG1.21
    end;

    local procedure SetupVarietyFixed()
    begin
        //-MAG2.22 [359285]
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
        //+MAG2.22 [359285]
    end;

    local procedure SetupVarietySelectOnItem()
    begin
        //-MAG2.22 [359285]
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
        //+MAG2.22 [359285]
    end;

    local procedure SetupVariety1()
    var
        ItemVariant: Record "Item Variant";
        VarietyValue: Record "NPR Variety Value";
    begin
        //-MAG2.22 [359285]
        if Item."NPR Variety 1" = '' then
            exit;
        if Item."NPR Variety 1 Table" = '' then
            exit;

        VarietyValue.SetRange(Type, Item."NPR Variety 1");
        VarietyValue.SetRange(Table, Item."NPR Variety 1 Table");
        if not VarietyValue.FindSet then
            exit;

        repeat
            //-MAG2.22 [361003]
            ItemVariant.SetRange("Item No.", Item."No.");
            ItemVariant.SetRange("NPR Variety 1", VarietyValue.Type);
            ItemVariant.SetRange("NPR Variety 1 Table", VarietyValue.Table);
            ItemVariant.SetRange("NPR Variety 1 Value", VarietyValue.Value);
            ItemVariant.SetRange("NPR Blocked", false);
            //+MAG2.22 [361003]
            if ItemVariant.FindFirst then begin
                Init;
                "Item No." := VarietyValue.Value;
                Description := VarietyValue.Description;
                "NPR Variety 1" := VarietyValue.Type;
                "NPR Variety 1 Table" := VarietyValue.Table;
                "NPR Variety 1 Value" := VarietyValue.Value;
                Insert;
            end;
        until VarietyValue.Next = 0;
        //+MAG2.22 [359285]
    end;

    local procedure SetupVariety2()
    var
        ItemVariant: Record "Item Variant";
        VarietyValue: Record "NPR Variety Value";
    begin
        //-MAG2.22 [359285]
        if Item."NPR Variety 2" = '' then
            exit;
        if Item."NPR Variety 2 Table" = '' then
            exit;

        VarietyValue.SetRange(Type, Item."NPR Variety 2");
        VarietyValue.SetRange(Table, Item."NPR Variety 2 Table");
        if not VarietyValue.FindSet then
            exit;

        repeat
            //-MAG2.22 [361003]
            ItemVariant.SetRange("Item No.", Item."No.");
            ItemVariant.SetRange("NPR Variety 2", VarietyValue.Type);
            ItemVariant.SetRange("NPR Variety 2 Table", VarietyValue.Table);
            ItemVariant.SetRange("NPR Variety 2 Value", VarietyValue.Value);
            ItemVariant.SetRange("NPR Blocked", false);
            //+MAG2.22 [361003]
            if ItemVariant.FindFirst then begin
                Init;
                "Item No." := VarietyValue.Value;
                Description := VarietyValue.Description;
                "NPR Variety 2" := VarietyValue.Type;
                "NPR Variety 2 Table" := VarietyValue.Table;
                "NPR Variety 2 Value" := VarietyValue.Value;
                Insert;
            end;
        until VarietyValue.Next = 0;
        //+MAG2.22 [359285]
    end;

    local procedure SetupVariety3()
    var
        ItemVariant: Record "Item Variant";
        VarietyValue: Record "NPR Variety Value";
    begin
        //-MAG2.22 [359285]
        if Item."NPR Variety 3" = '' then
            exit;
        if Item."NPR Variety 3 Table" = '' then
            exit;

        VarietyValue.SetRange(Type, Item."NPR Variety 3");
        VarietyValue.SetRange(Table, Item."NPR Variety 3 Table");
        if not VarietyValue.FindSet then
            exit;

        repeat
            //-MAG2.22 [361003]
            ItemVariant.SetRange("Item No.", Item."No.");
            ItemVariant.SetRange("NPR Variety 3", VarietyValue.Type);
            ItemVariant.SetRange("NPR Variety 3 Table", VarietyValue.Table);
            ItemVariant.SetRange("NPR Variety 3 Value", VarietyValue.Value);
            ItemVariant.SetRange("NPR Blocked", false);
            //+MAG2.22 [361003]
            if ItemVariant.FindFirst then begin
                Init;
                "Item No." := VarietyValue.Value;
                Description := VarietyValue.Description;
                "NPR Variety 3" := VarietyValue.Type;
                "NPR Variety 3 Table" := VarietyValue.Table;
                "NPR Variety 3 Value" := VarietyValue.Value;
                Insert;
            end;
        until VarietyValue.Next = 0;
        //+MAG2.22 [359285]
    end;

    local procedure SetupVariety4()
    var
        ItemVariant: Record "Item Variant";
        VarietyValue: Record "NPR Variety Value";
    begin
        //-MAG2.22 [359285]
        if Item."NPR Variety 4" = '' then
            exit;
        if Item."NPR Variety 4 Table" = '' then
            exit;

        VarietyValue.SetRange(Type, Item."NPR Variety 4");
        VarietyValue.SetRange(Table, Item."NPR Variety 4 Table");
        if not VarietyValue.FindSet then
            exit;

        repeat
            //-MAG2.22 [361003]
            ItemVariant.SetRange("Item No.", Item."No.");
            ItemVariant.SetRange("NPR Variety 4", VarietyValue.Type);
            ItemVariant.SetRange("NPR Variety 4 Table", VarietyValue.Table);
            ItemVariant.SetRange("NPR Variety 4 Value", VarietyValue.Value);
            ItemVariant.SetRange("NPR Blocked", false);
            //-MAG2.22 [361003]
            if ItemVariant.FindFirst then begin
                Init;
                "Item No." := VarietyValue.Value;
                Description := VarietyValue.Description;
                "NPR Variety 4" := VarietyValue.Type;
                "NPR Variety 4 Table" := VarietyValue.Table;
                "NPR Variety 4 Value" := VarietyValue.Value;
                Insert;
            end;
        until VarietyValue.Next = 0;
        //+MAG2.22 [359285]
    end;
}

