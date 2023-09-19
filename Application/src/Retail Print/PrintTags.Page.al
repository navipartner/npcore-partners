page 6014417 "NPR Print Tags"
{
    Extensible = False;
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
                    ToolTip = 'Specifies a code to identify this print tag.';
                    ApplicationArea = NPRRetail;
                }
                field(Pick; Pick)
                {
                    Caption = 'Selected';
                    ToolTip = 'Specifies if this tag is selected.';
                    ApplicationArea = NPRRetail;

                    trigger OnValidate()
                    begin
                        ToggleTag(Rec."Print Tag", false);
                    end;
                }
            }
        }
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
        if _TagText <> '' then
            FromText(_TagText);
    end;

    var
        TempSelectedPrintTags: Record "NPR Print Tags" temporary;
        Pick: Boolean;
        _TagText: Text;

    internal procedure ToText(MaxLength: Integer): Text
    var
        TagString: Text;
        TooLongErr: Label 'The resulting string of selected pring tags cannot exceed %1 characters.', Comment = '%1 - maximal string length';
    begin
        if not TempSelectedPrintTags.FindSet() then
            exit('');

        repeat
            if TagString <> '' then
                TagString += ',';
            TagString += TempSelectedPrintTags."Print Tag";
        until TempSelectedPrintTags.Next() = 0;

        if StrLen(TagString) > MaxLength then
            Error(TooLongErr, MaxLength);

        exit(TagString);
    end;

    internal procedure FromText(TagString: Text)
    var
        Tag: Text;
        Tags: List of [Text];
    begin
        Tags := TagString.Split(',');
        foreach Tag in Tags do
            if StrLen(Tag) <= MaxStrLen(Rec."Print Tag") then
#pragma warning disable AA0139
                ToggleTag(Tag, true);
#pragma warning restore AA0139
        CurrPage.Update(false);
    end;

    internal procedure SetTagText(TagTextIn: Text)
    begin
        _TagText := TagTextIn;
    end;

    local procedure ToggleTag(PrintTag: Text[100]; AddOnly: Boolean)
    begin
        if PrintTag = '' then
            exit;

        if TempSelectedPrintTags.Get(PrintTag) then begin
            if not AddOnly then
                TempSelectedPrintTags.Delete();
            exit;
        end;
        TempSelectedPrintTags.Init();
        TempSelectedPrintTags."Print Tag" := PrintTag;
        TempSelectedPrintTags.Insert();
    end;
}
