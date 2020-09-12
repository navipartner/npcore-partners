page 6059952 "NPR Display Content Lines"
{
    // NPR5.48/JDH /20181109 CASE 334163 Added object caption

    AutoSplitKey = true;
    Caption = 'Display Content Lines';
    DelayedInsert = true;
    LinksAllowed = false;
    MultipleNewLines = true;
    PageType = List;
    SourceTable = "NPR Display Content Lines";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Url; Url)
                {
                    ApplicationArea = All;
                    Visible = UrlIsVisible;
                }
                field(Image; Image)
                {
                    ApplicationArea = All;
                    Visible = ImageIsVisible;
                }
            }
            part(Control6014404; "NPR Disp. Content Lines Img")
            {
                SubPageLink = "Content Code" = FIELD("Content Code"),
                              "Line No." = FIELD("Line No.");
                ApplicationArea = All;
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
            DisplayContentLines.SetRange("Content Code", DisplayContent.Code);
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
        DisplayContent: Record "NPR Display Content";
        DisplayContentLines: Record "NPR Display Content Lines";
        Txt001: Label 'Only 1 webpage url is allowed';
}

