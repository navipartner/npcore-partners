page 6151412 "NPR Magento Pict. Link Subform"
{
    AutoSplitKey = true;
    Caption = 'Magento Picture Link Subform';
    DelayedInsert = true;
    PageType = ListPart;
    UsageCategory = None;
    RefreshOnActivate = true;
    ShowFilter = false;
    SourceTable = "NPR Magento Picture Link";

    layout
    {
        area(content)
        {
            repeater(Control6150624)
            {
                ShowCaption = false;
                field(MiniatureLine; TempMagentoPicture.Picture)
                {
                    ApplicationArea = All;
                    Caption = 'Miniature';
                    Editable = false;
                    Visible = MiniatureLinePicture;
                    ToolTip = 'Specifies the value of the Miniature field';
                }
                field("Picture Name"; Rec."Picture Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Picture Name field';
                }
                field("Base Image"; Rec."Base Image")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Base Image field';
                }
                field("Small Image"; Rec."Small Image")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Small Image field';
                }
                field(Thumbnail; Rec.Thumbnail)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Thumbnail field';
                }
                field("Short Text"; Rec."Short Text")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Short Text field';

                    trigger OnValidate()
                    begin
                        Rec.TestField("Short Text");
                    end;
                }
                field("Sorting"; Rec.Sorting)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Sorting field';
                }
            }
            field(MiniatureSingle; TempMagentoPicture.Picture)
            {
                ApplicationArea = All;
                Caption = 'Miniature';
                Editable = false;
                Enabled = false;
                Visible = MiniatureSinglePicture;
                ToolTip = 'Specifies the value of the Miniature field';
            }
        }
    }

    actions
    {
    }

    trigger OnAfterGetCurrRecord()
    begin
        if MiniatureSinglePicture and not MiniatureLinePicture then
            DownloadMiniature();
    end;

    trigger OnAfterGetRecord()
    begin
        if MiniatureLinePicture then
            DownloadMiniature();
    end;

    trigger OnInit()
    begin
        GetMiniatureSetup();
        SetVariantFilters();
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        if ItemNo <> '' then
            Rec."Item No." := ItemNo;
        if VariantValueCode <> '' then
            Rec."Variant Value Code" := VariantValueCode;
        Rec."Variety Type" := VarietyTypeCode;
        Rec."Variety Table" := VarietyTableCode;
        Rec."Variety Value" := VarietyValueCode;
        Clear(TempMagentoPicture);
    end;

    var
        TempMagentoPicture: Record "NPR Magento Picture" temporary;
        MagentoSetup: Record "NPR Magento Setup";
        VariantValueCode: Code[20];
        ItemNo: Code[20];
        MiniatureLinePicture: Boolean;
        MiniatureSinglePicture: Boolean;
        VarietyTypeCode: Code[10];
        VarietyTableCode: Code[40];
        VarietyValueCode: Code[50];

    procedure SetItemNoFilter(NewItemNo: Code[20])
    begin
        ItemNo := NewItemNo;
        SetVariantFilters();
    end;

    local procedure SetVariantFilters()
    begin
        Rec.FilterGroup(2);
        if ItemNo <> '' then
            Rec.SetRange("Item No.", ItemNo);
        Rec.SetRange("Variant Value Code", VariantValueCode);
        Rec.SetRange("Variety Type", VarietyTypeCode);
        Rec.SetRange("Variety Table", VarietyTableCode);
        Rec.SetRange("Variety Value", VarietyValueCode);
        Rec.FilterGroup(0);
        CurrPage.Update(false);
    end;

    procedure SetVariantValueCode(NewVariantValueCode: Code[20])
    begin
        VariantValueCode := NewVariantValueCode;
        SetVariantFilters();
    end;

    procedure SetVarietyFilters(NewVarietyTypeCode: Code[10]; NewVarietyTableCode: Code[40]; NewVarietyValueCode: Code[50])
    begin
        VarietyTypeCode := NewVarietyTypeCode;
        VarietyTableCode := NewVarietyTableCode;
        VarietyValueCode := NewVarietyValueCode;
        SetVariantFilters();
    end;

    local procedure DownloadMiniature()
    var
        MagentoPicture: Record "NPR Magento Picture";
    begin
        if TempMagentoPicture.Get(MagentoPicture.Type::Item, Rec."Picture Name") then begin
            TempMagentoPicture.DownloadPicture(TempMagentoPicture);
            exit;
        end;

        if MagentoPicture.Get(MagentoPicture.Type::Item, Rec."Picture Name") then begin
            TempMagentoPicture.Init;
            TempMagentoPicture := MagentoPicture;
            TempMagentoPicture.Insert;
        end else begin
            TempMagentoPicture.Init;
            TempMagentoPicture.Type := MagentoPicture.Type::Item;
            TempMagentoPicture.Name := Rec."Picture Name";
            TempMagentoPicture.Insert;
        end;

        TempMagentoPicture.DownloadPicture(TempMagentoPicture);
        TempMagentoPicture.Modify;
    end;

    local procedure GetMiniatureSetup()
    begin
        if not MagentoSetup.Get then
            exit;
        MiniatureSinglePicture := MagentoSetup."Miniature Picture" in [MagentoSetup."Miniature Picture"::SinglePicutre, MagentoSetup."Miniature Picture"::"SinglePicture+LinePicture"];
        MiniatureLinePicture := MagentoSetup."Miniature Picture" in [MagentoSetup."Miniature Picture"::LinePicture, MagentoSetup."Miniature Picture"::"SinglePicture+LinePicture"];
    end;
}