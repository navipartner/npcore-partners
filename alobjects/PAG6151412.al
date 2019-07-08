page 6151412 "Magento Picture Link Subform"
{
    // MAG1.00/MH/20150113  CASE 199932 Refactored Object from Web Integration
    // MAG1.01/MH/20150115  CASE 199932 Moved Picture Lookup to Table Field OnLookup Trigger
    // MAG1.02/MH/20150202  CASE 199932 Added Magento Colors Action
    // MAG1.04/MH/20150209  CASE 199932 Updated PictureViewer Addin
    // MAG1.09/MH/20150316  CASE 206395 Added function SetColorCode
    // MAG1.14/MH/20150508  CASE 211881 Updated PictureViewer Addin to JavaScript version
    // MAG1.21/MHA/20151104 CASE 223835 Changed Color Pictures to Variant Pictures and deleted deprecated function LoadPicture()
    // MAG1.21/MHA/20151119 CASE 227583 Added TESTFIELD of "Short Text"
    // MAG1.22/MHA/20151202 CASE 223835 Removed unused function OpenVariantPictures()
    // MAG2.00/MHA/20160525  CASE 242557 Magento Integration
    // MAG10.00.2.00/MHA/20161118  CASE 258544 Changed Miniature to use Picture instead of TempItem.Picture
    // MAG2.17/JDH /20181112 CASE 334163 Added Caption to Object
    // MAG2.20/MHA /20190430  CASE 353499 Redesigned DownloadMiniature() to consider Magento Picture not existing

    AutoSplitKey = true;
    Caption = 'Magento Picture Link Subform';
    DelayedInsert = true;
    PageType = ListPart;
    RefreshOnActivate = true;
    ShowFilter = false;
    SourceTable = "Magento Picture Link";

    layout
    {
        area(content)
        {
            group(Control6150613)
            {
                ShowCaption = false;
                group(Control6150626)
                {
                    ShowCaption = false;
                    repeater(Control6150624)
                    {
                        ShowCaption = false;
                        field(MiniatureLine;TempMagentoPicture.Picture)
                        {
                            Caption = 'Miniature';
                            Editable = false;
                            Visible = MiniatureLinePicture;
                        }
                        field("Picture Name";"Picture Name")
                        {
                        }
                        field("Base Image";"Base Image")
                        {
                        }
                        field("Small Image";"Small Image")
                        {
                        }
                        field(Thumbnail;Thumbnail)
                        {
                        }
                        field("Short Text";"Short Text")
                        {

                            trigger OnValidate()
                            begin
                                //-MAG1.21
                                TestField("Short Text");
                                //+MAG1.21
                            end;
                        }
                        field(Sorting;Sorting)
                        {
                        }
                    }
                    field(MiniatureSingle;TempMagentoPicture.Picture)
                    {
                        Caption = 'Miniature';
                        Editable = false;
                        Enabled = false;
                        Visible = MiniatureSinglePicture;
                    }
                }
            }
        }
    }

    actions
    {
    }

    trigger OnAfterGetCurrRecord()
    begin
        //-MAG1.21
        //LoadPicture();
        if MiniatureSinglePicture and not MiniatureLinePicture then
          DownloadMiniature();
        //+MAG1.21
    end;

    trigger OnAfterGetRecord()
    var
        Text: Text;
    begin
        //-MAG1.21
        //LoadPicture();
        if MiniatureLinePicture then
          DownloadMiniature();
        //+MAG1.21
    end;

    trigger OnInit()
    begin
        //-MAG1.21
        //ColorVisible := TRUE;
        GetMiniatureSetup();
        SetVariantFilters();
        //+MAG1.21
    end;

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    begin
        //-MAG1.21
        //LoadPicture();
        //+MAG1.21
    end;

    trigger OnModifyRecord(): Boolean
    begin
        //-MAG1.21
        //LoadPicture();
        //+MAG1.21
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        //-MAG1.21
        //Color := ColorCode;
        if ItemNo <> '' then
          "Item No." := ItemNo;
        if VariantValueCode <> '' then
          "Variant Value Code" := VariantValueCode;
        //+MAG1.21
        //-MAG10.00.2.00 [258544]
        Clear(TempMagentoPicture);
        //-MAG10.00.2.00 [258544]
    end;

    var
        TempMagentoPicture: Record "Magento Picture" temporary;
        MagentoSetup: Record "Magento Setup";
        VariantValueCode: Code[20];
        ItemNo: Code[20];
        MiniatureLinePicture: Boolean;
        MiniatureSinglePicture: Boolean;

    procedure GetPictureName(): Text
    begin
        exit("Picture Name");
    end;

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
          SetRange("Item No.",ItemNo);
        SetRange("Variant Value Code",VariantValueCode);
        FilterGroup(0);
        CurrPage.Update(false);
        //+MAG1.21
    end;

    procedure SetVariantValueCode(NewVariantValueCode: Code[20])
    begin
        //-MAG1.21
        //ColorCode := NewColorCode;
        VariantValueCode := NewVariantValueCode;
        SetVariantFilters();
        //+MAG1.21
    end;

    local procedure "--- Miniature"()
    begin
    end;

    local procedure DownloadMiniature()
    var
        MagentoPicture: Record "Magento Picture";
    begin
        //-MAG2.20 [353499]
        // //-MAG1.21
        // CLEAR(TempItem.Picture);
        // IF MagentoPicture.GET(MagentoPicture.Type::Item,"Picture Name") THEN
        //  MagentoPicture.DownloadPicture(TempItem);
        // //+MAG1.21
        if TempMagentoPicture.Get(TempMagentoPicture.Type::Item,"Picture Name") then begin
          TempMagentoPicture.CalcFields(Picture);
          exit;
        end;

        if MagentoPicture.Get(MagentoPicture.Type::Item,"Picture Name") then begin
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
        MiniatureSinglePicture := MagentoSetup."Miniature Picture" in [MagentoSetup."Miniature Picture"::SinglePicutre,MagentoSetup."Miniature Picture"::"SinglePicture+LinePicture"];
        MiniatureLinePicture := MagentoSetup."Miniature Picture" in [MagentoSetup."Miniature Picture"::LinePicture,MagentoSetup."Miniature Picture"::"SinglePicture+LinePicture"];
        //+MAG1.21
    end;
}

