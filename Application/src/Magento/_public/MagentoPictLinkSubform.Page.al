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
                field("Picture Name"; Rec."Picture Name")
                {
                    ToolTip = 'Specifies the value of the Picture Name field';
                    ApplicationArea = NPRMagento;
                }
                field("Base Image"; Rec."Base Image")
                {
                    ToolTip = 'Specifies the value of the Base Image field';
                    ApplicationArea = NPRMagento;
                }
                field("Small Image"; Rec."Small Image")
                {
                    ToolTip = 'Specifies the value of the Small Image field';
                    ApplicationArea = NPRMagento;
                }
                field(Thumbnail; Rec.Thumbnail)
                {
                    ToolTip = 'Specifies the value of the Thumbnail field';
                    ApplicationArea = NPRMagento;
                }
                field("Short Text"; Rec."Short Text")
                {
                    ToolTip = 'Specifies the value of the Short Text field';
                    ApplicationArea = NPRMagento;

                    trigger OnValidate()
                    begin
                        Rec.TestField("Short Text");
                    end;
                }
                field("Sorting"; Rec.Sorting)
                {
                    ToolTip = 'Specifies the value of the Sorting field';
                    ApplicationArea = NPRMagento;
                }
            }
        }
    }

    trigger OnInit()
    begin
        SetVariantFilters();
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        if ItemNo <> '' then
            Rec."Item No." := ItemNo;
        Rec."Variety Type" := VarietyTypeCode;
        Rec."Variety Table" := VarietyTableCode;
        Rec."Variety Value" := VarietyValueCode;
    end;

    var
        ItemNo: Code[20];
        VarietyTypeCode: Code[10];
        VarietyTableCode: Code[40];
        VarietyValueCode: Code[50];

    internal procedure SetItemNoFilter(NewItemNo: Code[20])
    begin
        ItemNo := NewItemNo;
        SetVariantFilters();
    end;

    local procedure SetVariantFilters()
    begin
        Rec.FilterGroup(2);
        if ItemNo <> '' then
            Rec.SetRange("Item No.", ItemNo);
        Rec.SetRange("Variety Type", VarietyTypeCode);
        Rec.SetRange("Variety Table", VarietyTableCode);
        Rec.SetRange("Variety Value", VarietyValueCode);
        Rec.FilterGroup(0);
        CurrPage.Update(false);
    end;

    internal procedure SetVarietyFilters(NewVarietyTypeCode: Code[10]; NewVarietyTableCode: Code[40]; NewVarietyValueCode: Code[50])
    begin
        VarietyTypeCode := NewVarietyTypeCode;
        VarietyTableCode := NewVarietyTableCode;
        VarietyValueCode := NewVarietyValueCode;
        SetVariantFilters();
    end;
}
