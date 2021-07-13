page 6014417 "NPR Print Tags"
{
    // NPR4.18/MMV/20151229 CASE 225584 Created Page

    Caption = 'Print Tags';
    PageType = List;
    UsageCategory = Administration;

    SourceTable = "NPR Print Tags";
    ApplicationArea = NPRRetail;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Print Tag"; Rec."Print Tag")
                {

                    ToolTip = 'Specifies the value of the Print Tag field';
                    ApplicationArea = NPRRetail;
                }
                field(Pick; Pick)
                {

                    ShowCaption = false;
                    ToolTip = 'Specifies the value of the Pick field';
                    ApplicationArea = NPRRetail;

                    trigger OnValidate()
                    begin
                        ToggleTag(Rec."Print Tag");
                    end;
                }
            }
        }
    }

    actions
    {
    }

    trigger OnAfterGetRecord()
    begin
        Pick := TempSelectedPrintTags.Get(Rec."Print Tag");
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        Pick := false;
    end;

    trigger OnOpenPage()
    begin
        if TagText <> '' then
            FromText(TagText + ',');
    end;

    var
        TempSelectedPrintTags: Record "NPR Print Tags" temporary;
        Pick: Boolean;
        TagText: Text[100];

    procedure ToText(): Text
    var
        TagString: Text;
        Tagged: Boolean;
    begin
        if TempSelectedPrintTags.FindSet() then
            repeat
                TagString += TempSelectedPrintTags."Print Tag" + ',';
                Tagged := true;
            until TempSelectedPrintTags.Next() = 0;

        if Tagged then
            TagString := DelStr(TagString, StrLen(TagString));

        exit(TagString);
    end;

    procedure FromText(TagString: Text)
    var
        StringLibrary: Codeunit "NPR String Library";
        i: Integer;
        PrevTag: Text;
        CurrTag: Text;
    begin
        StringLibrary.Construct(TagString);

        repeat
            i += 1;
            PrevTag := CurrTag;
            CurrTag := StringLibrary.SelectStringSep(i, ',');
            ToggleTag(CurrTag);
        until PrevTag = CurrTag;

        CurrPage.Update(false);
    end;

    procedure SetTagText(TagTextIn: Text[100])
    begin
        TagText := TagTextIn;
    end;

    local procedure ToggleTag(PrintTag: Text)
    begin
        if (StrLen(PrintTag) > 100) or (PrintTag = '') then exit;

        if TempSelectedPrintTags.Get(PrintTag) then
            TempSelectedPrintTags.Delete()
        else begin
            TempSelectedPrintTags.Init();
            TempSelectedPrintTags."Print Tag" := PrintTag;
            TempSelectedPrintTags.Insert();
        end;
    end;
}

