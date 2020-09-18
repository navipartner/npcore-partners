page 6151412 "NPR Magento Pict. Link Subform"
{
    // MAG1.00/MHA /20150113  CASE 199932 Refactored Object from Web Integration
    // MAG1.01/MHA /20150115  CASE 199932 Moved Picture Lookup to Table Field OnLookup Trigger
    // MAG1.02/MHA /20150202  CASE 199932 Added Magento Colors Action
    // MAG1.04/MHA /20150209  CASE 199932 Updated PictureViewer Addin
    // MAG1.09/MHA /20150316  CASE 206395 Added function SetColorCode
    // MAG1.14/MHA /20150508  CASE 211881 Updated PictureViewer Addin to JavaScript version
    // MAG1.21/MHA /20151104  CASE 223835 Changed Color Pictures to Variant Pictures and deleted deprecated function LoadPicture()
    // MAG1.21/MHA /20151119  CASE 227583 Added TESTFIELD of "Short Text"
    // MAG1.22/MHA /20151202  CASE 223835 Removed unused function OpenVariantPictures()
    // MAG2.00/MHA /20160525  CASE 242557 Magento Integration
    // MAG10.00.2.00/MHA/20161118  CASE 258544 Changed Miniature to use Picture instead of TempItem.Picture
    // MAG2.17/JDH /20181112  CASE 334163 Added Caption to Object
    // MAG2.20/MHA /20190430  CASE 353499 Redesigned DownloadMiniature() to consider Magento Picture not existing
    // MAG2.22/MHA /20190625  CASE 359285 Added Variant Systems; Variety (Select on Item),Variety 1,Variety 2,Variety 3,Variety 4
    // MAG2.24/YAHA/20191213  CASE 376760 Change layout of the grouping

    AutoSplitKey = true;
    Caption = 'Magento Picture Link Subform';
    DelayedInsert = true;
    PageType = ListPart;
    UsageCategory = Administration;
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
                }
                field("Picture Name"; "Picture Name")
                {
                    ApplicationArea = All;
                }
                field("Base Image"; "Base Image")
                {
                    ApplicationArea = All;
                }
                field("Small Image"; "Small Image")
                {
                    ApplicationArea = All;
                }
                field(Thumbnail; Thumbnail)
                {
                    ApplicationArea = All;
                }
                field("Short Text"; "Short Text")
                {
                    ApplicationArea = All;

                    trigger OnValidate()
                    begin
                        //-MAG1.21
                        TestField("Short Text");
                        //+MAG1.21
                    end;
                }
                field("Sorting"; Sorting)
                {
                    ApplicationArea = All;
                }
            }
            field(MiniatureSingle; TempMagentoPicture.Picture)
            {
                ApplicationArea = All;
                Caption = 'Miniature';
                Editable = false;
                Enabled = false;
                Visible = MiniatureSinglePicture;
            }
        }
    }

    actions
    {
    }

    trigger OnAfterGetCurrRecord()
    begin
        //-MAG1.21
        if MiniatureSinglePicture and not MiniatureLinePicture then
            DownloadMiniature();
        //+MAG1.21
    end;

    trigger OnAfterGetRecord()
    begin
        //-MAG1.21
        if MiniatureLinePicture then
            DownloadMiniature();
        //+MAG1.21
    end;

    trigger OnInit()
    begin
        //-MAG1.21
        GetMiniatureSetup();
        SetVariantFilters();
        //+MAG1.21
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        //-MAG1.21
        if ItemNo <> '' then
            "Item No." := ItemNo;
        if VariantValueCode <> '' then
            "Variant Value Code" := VariantValueCode;
        //+MAG1.21
        //-MAG2.22 [359285]
        "Variety Type" := VarietyTypeCode;
        "Variety Table" := VarietyTableCode;
        "Variety Value" := VarietyValueCode;
        //+MAG2.22 [359285]
        //-MAG10.00.2.00 [258544]
        Clear(TempMagentoPicture);
        //-MAG10.00.2.00 [258544]
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
        VarietyValueCode: Code[20];

    procedure SetItemNoFilter(NewItemNo: Code[20])
    begin
        //-MAG1.21
        ItemNo := NewItemNo;
        SetVariantFilters();
        //+MAG1.21
    end;

    local procedure SetVariantFilters()
    begin
        //-MAG1.21
        FilterGroup(2);
        if ItemNo <> '' then
            SetRange("Item No.", ItemNo);
        SetRange("Variant Value Code", VariantValueCode);
        //-MAG2.22 [359285]
        SetRange("Variety Type", VarietyTypeCode);
        SetRange("Variety Table", VarietyTableCode);
        SetRange("Variety Value", VarietyValueCode);
        //+MAG2.22 [359285]
        FilterGroup(0);
        CurrPage.Update(false);
        //+MAG1.21
    end;

    procedure SetVariantValueCode(NewVariantValueCode: Code[20])
    begin
        //-MAG1.21
        VariantValueCode := NewVariantValueCode;
        SetVariantFilters();
        //+MAG1.21
    end;

    procedure SetVarietyFilters(NewVarietyTypeCode: Code[10]; NewVarietyTableCode: Code[40]; NewVarietyValueCode: Code[20])
    begin
        //-MAG2.22 [359285]
        VarietyTypeCode := NewVarietyTypeCode;
        VarietyTableCode := NewVarietyTableCode;
        VarietyValueCode := NewVarietyValueCode;
        SetVariantFilters();
        //+MAG2.22 [359285]
    end;

    local procedure "--- Miniature"()
    begin
    end;

    local procedure DownloadMiniature()
    var
        MagentoPicture: Record "NPR Magento Picture";
    begin
        //-MAG2.22 [359285]
        if TempMagentoPicture.Get(MagentoPicture.Type::Item, "Picture Name") then begin
            TempMagentoPicture.DownloadPicture(TempMagentoPicture);   // NAV 2017+
            exit;
        end;
        //+MAG2.22 [359285]

        //-MAG2.20 [353499]
        if MagentoPicture.Get(MagentoPicture.Type::Item, "Picture Name") then begin
            TempMagentoPicture.Init;
            TempMagentoPicture := MagentoPicture;
            TempMagentoPicture.Insert;
        end else begin
            TempMagentoPicture.Init;
            TempMagentoPicture.Type := MagentoPicture.Type::Item;
            TempMagentoPicture.Name := "Picture Name";
            TempMagentoPicture.Insert;
        end;

        TempMagentoPicture.DownloadPicture(TempMagentoPicture);   // NAV 2017+
        TempMagentoPicture.Modify;
        //+MAG2.20 [353499]
    end;

    local procedure GetMiniatureSetup()
    begin
        //-MAG1.21
        if not MagentoSetup.Get then
            exit;
        MiniatureSinglePicture := MagentoSetup."Miniature Picture" in [MagentoSetup."Miniature Picture"::SinglePicutre, MagentoSetup."Miniature Picture"::"SinglePicture+LinePicture"];
        MiniatureLinePicture := MagentoSetup."Miniature Picture" in [MagentoSetup."Miniature Picture"::LinePicture, MagentoSetup."Miniature Picture"::"SinglePicture+LinePicture"];
        //+MAG1.21
    end;
}

