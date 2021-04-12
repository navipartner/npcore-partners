page 6059952 "NPR Display Content Lines"
{
    Caption = 'Display Content Lines';
    LinksAllowed = false;
    PageType = List;
    UsageCategory = Administration;
    ApplicationArea = All;
    Editable = false;
    SourceTable = "NPR Display Content Lines";
    CardPageId = "NPR Disp. Cont. Line Card";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Url; Rec.Url)
                {
                    ApplicationArea = All;
                    Visible = UrlIsVisible;
                    ToolTip = 'Specifies the value of the Url field';
                }
                field(Image; Rec.Image)
                {
                    ApplicationArea = All;
                    Visible = ImageIsVisible;
                    ToolTip = 'Specifies the value of the Image field';
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

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    begin
        if (DisplayContent.Type = DisplayContent.Type::Html) then begin
            Clear(DisplayContentLines);
            DisplayContentLines.SetRange("Content Code", DisplayContent.Code);
            if DisplayContentLines.Count() > 0 then
                Error(Txt001);
        end;
    end;

    trigger OnOpenPage()
    begin
        DisplayContent.Get(Rec.GetFilter("Content Code"));
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

