page 6014417 "NPR Print Tags"
{
    // NPR4.18/MMV/20151229 CASE 225584 Created Page

    Caption = 'Print Tags';
    PageType = List;
    UsageCategory = Administration;
    ApplicationArea = All;
    SourceTable = "NPR Print Tags";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Print Tag"; Rec."Print Tag")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Print Tag field';
                }
                field(Pick; Pick)
                {
                    ApplicationArea = All;
                    ShowCaption = false;
                    ToolTip = 'Specifies the value of the Pick field';

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
        Pick := SelectedPrintTagsTmp.Get(Rec."Print Tag");
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
        SelectedPrintTagsTmp: Record "NPR Print Tags" temporary;
        Pick: Boolean;
        TagText: Text[100];

    procedure ToText(): Text
    var
        TagString: Text;
        Tagged: Boolean;
    begin
        if SelectedPrintTagsTmp.FindSet() then
            repeat
                TagString += SelectedPrintTagsTmp."Print Tag" + ',';
                Tagged := true;
            until SelectedPrintTagsTmp.Next() = 0;

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

        if SelectedPrintTagsTmp.Get(PrintTag) then
            SelectedPrintTagsTmp.Delete()
        else begin
            SelectedPrintTagsTmp.Init();
            SelectedPrintTagsTmp."Print Tag" := PrintTag;
            SelectedPrintTagsTmp.Insert();
        end;
    end;
}

