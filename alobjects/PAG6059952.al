page 6059952 "Display Content Lines"
{
    // NPR5.48/JDH /20181109 CASE 334163 Added object caption

    AutoSplitKey = true;
    Caption = 'Display Content Lines';
    DelayedInsert = true;
    LinksAllowed = false;
    MultipleNewLines = true;
    PageType = List;
    SourceTable = "Display Content Lines";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Url;Url)
                {
                    Visible = UrlIsVisible;
                }
                field(Image;Image)
                {
                    Visible = ImageIsVisible;
                }
            }
            part(Control6014404;"Display Content Lines Image")
            {
                SubPageLink = "Content Code"=FIELD("Content Code"),
                              "Line No."=FIELD("Line No.");
            }
        }
    }

    actions
    {
    }

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    begin
        if (DisplayContent.Type = DisplayContent.Type::Html) then begin
          Clear(DisplayContentLines);
          DisplayContentLines.SetRange("Content Code",DisplayContent.Code);
          if DisplayContentLines.Count > 0 then
            Error(Txt001);
        end;
    end;

    trigger OnOpenPage()
    begin

        DisplayContent.Get(GetFilter("Content Code"));
        if (DisplayContent.Type = DisplayContent.Type::Image) then begin
         ImageIsVisible := true;
         UrlIsVisible := false;
        end else begin
         ImageIsVisible := false;
         UrlIsVisible := true;
        end;
    end;

    var
        UrlIsVisible: Boolean;
        ImageIsVisible: Boolean;
        DisplayContent: Record "Display Content";
        DisplayContentLines: Record "Display Content Lines";
        Txt001: Label 'Only 1 webpage url is allowed';
}

