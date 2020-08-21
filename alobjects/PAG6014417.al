page 6014417 "Print Tags"
{
    // NPR4.18/MMV/20151229 CASE 225584 Created Page

    Caption = 'Print Tags';
    PageType = List;
    SourceTable = "Print Tags";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Print Tag"; "Print Tag")
                {
                    ApplicationArea = All;
                }
                field(Pick; Pick)
                {
                    ApplicationArea = All;
                    ShowCaption = false;

                    trigger OnValidate()
                    begin
                        ToggleTag("Print Tag");
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
        Pick := SelectedPrintTagsTmp.Get("Print Tag");
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        Pick := false;
    end;

    trigger OnOpenPage()
    var
        PrintTags: Record "Print Tags";
    begin
        if TagText <> '' then
            FromText(TagText + ',');
    end;

    var
        SelectedPrintTagsTmp: Record "Print Tags" temporary;
        Pick: Boolean;
        TagText: Text[100];

    procedure ToText(): Text
    var
        TagString: Text;
        Tagged: Boolean;
    begin
        if SelectedPrintTagsTmp.FindSet then
            repeat
                TagString += SelectedPrintTagsTmp."Print Tag" + ',';
                Tagged := true;
            until SelectedPrintTagsTmp.Next = 0;

        if Tagged then
            TagString := DelStr(TagString, StrLen(TagString));

        exit(TagString);
    end;

    procedure FromText(TagString: Text)
    var
        StringLibrary: Codeunit "String Library";
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
            SelectedPrintTagsTmp.Delete
        else begin
            SelectedPrintTagsTmp.Init;
            SelectedPrintTagsTmp."Print Tag" := PrintTag;
            SelectedPrintTagsTmp.Insert;
        end;
    end;
}

